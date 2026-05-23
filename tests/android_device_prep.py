from __future__ import annotations

import logging
import os
import shutil
import subprocess
from pathlib import Path

from tests.config import AutomationConfig


LOGGER = logging.getLogger(__name__)


class AndroidDevicePreparer:
    RUNTIME_PERMISSIONS = (
        "android.permission.POST_NOTIFICATIONS",
        "android.permission.ACCESS_COARSE_LOCATION",
        "android.permission.ACCESS_FINE_LOCATION",
        "android.permission.ACCESS_BACKGROUND_LOCATION",
        "android.permission.READ_MEDIA_IMAGES",
        "android.permission.READ_EXTERNAL_STORAGE",
        "android.permission.READ_CONTACTS",
        "android.permission.ACTIVITY_RECOGNITION",
    )

    def __init__(self, config: AutomationConfig) -> None:
        self.config = config
        self.adb_command = self._resolve_adb_command()
        self.device_id = config.flutter_device_id or config.udid

    def prepare(self) -> None:
        self._run_adb(("start-server",), check=False)
        self._run_adb(("wait-for-device",))

        if not self._is_package_installed():
            LOGGER.info(
                "Package %s is not installed yet; skipping ADB pre-grant phase for now.",
                self.config.app_package,
            )
            return

        LOGGER.info("Pre-granting Android permissions for %s", self.config.app_package)

        for permission in self.RUNTIME_PERMISSIONS:
            self._run_shell(
                ("pm", "grant", self.config.app_package, permission),
                check=False,
            )

        self._run_shell(
            ("appops", "set", self.config.app_package, "GET_USAGE_STATS", "allow"),
            check=False,
        )
        self._run_shell(
            ("cmd", "deviceidle", "whitelist", f"+{self.config.app_package}"),
            check=False,
        )
        self._enable_accessibility_service()

    def _enable_accessibility_service(self) -> None:
        component = (
            f"{self.config.app_package}/"
            "com.example.kid_manager.AppAccessibilityService"
        )

        current_services = self._run_shell(
            ("settings", "get", "secure", "enabled_accessibility_services"),
            check=False,
            capture_output=True,
        ).strip()
        if current_services.lower() == "null":
            current_services = ""

        services = [service for service in current_services.split(":") if service]
        if component not in services:
            services.append(component)

        merged_services = ":".join(services)
        self._run_shell(
            ("settings", "put", "secure", "enabled_accessibility_services", merged_services),
            check=False,
        )
        self._run_shell(
            ("settings", "put", "secure", "accessibility_enabled", "1"),
            check=False,
        )

    def _is_package_installed(self) -> bool:
        output = self._run_shell(
            ("pm", "list", "packages", self.config.app_package),
            check=False,
            capture_output=True,
        )
        return self.config.app_package in output

    def _run_shell(
        self,
        shell_args: tuple[str, ...],
        *,
        check: bool = True,
        capture_output: bool = False,
    ) -> str:
        command = ["shell", *shell_args]
        return self._run_adb(command, check=check, capture_output=capture_output)

    def _run_adb(
        self,
        args: tuple[str, ...] | list[str],
        *,
        check: bool = True,
        capture_output: bool = False,
    ) -> str:
        command = [*self.adb_command]
        if self.device_id:
            command.extend(["-s", self.device_id])
        command.extend(args)

        LOGGER.info("adb | %s", " ".join(command))
        completed = subprocess.run(
            command,
            cwd=self.config.project_root,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            check=False,
        )

        if check and completed.returncode != 0:
            raise RuntimeError(
                f"ADB command failed ({completed.returncode}): {' '.join(command)}\n"
                f"stdout:\n{completed.stdout}\n"
                f"stderr:\n{completed.stderr}"
            )

        if completed.returncode != 0:
            LOGGER.info(
                "ADB command returned %s and was ignored: %s",
                completed.returncode,
                " ".join(command),
            )

        if completed.stdout.strip():
            LOGGER.info("adb stdout | %s", completed.stdout.strip())
        if completed.stderr.strip():
            LOGGER.info("adb stderr | %s", completed.stderr.strip())

        if capture_output:
            return completed.stdout
        return ""

    def _resolve_adb_command(self) -> list[str]:
        explicit = self.config.adb_bin
        if explicit:
            return self._wrap_executable(Path(explicit))

        for candidate in (shutil.which("adb"), shutil.which("adb.exe")):
            if candidate:
                return self._wrap_executable(Path(candidate))

        local_properties_candidate = self._adb_from_local_properties()
        if local_properties_candidate is not None:
            return self._wrap_executable(local_properties_candidate)

        raise RuntimeError(
            "ADB could not be resolved.\n"
            "Set ADB_BIN explicitly or ensure Android SDK platform-tools is available."
        )

    def _adb_from_local_properties(self) -> Path | None:
        local_properties_path = self.config.project_root / "android" / "local.properties"
        if not local_properties_path.exists():
            return None

        try:
            contents = local_properties_path.read_text(encoding="utf-8")
        except OSError:
            return None

        for line in contents.splitlines():
            if not line.startswith("sdk.dir="):
                continue

            sdk_path = line.split("=", 1)[1].strip().replace("\\\\", "\\")
            if not sdk_path:
                return None

            sdk_dir = Path(sdk_path)
            executable = sdk_dir / "platform-tools" / ("adb.exe" if os.name == "nt" else "adb")
            if executable.exists():
                return executable

        return None

    @staticmethod
    def _wrap_executable(executable: Path) -> list[str]:
        executable_path = str(executable)
        suffix = executable.suffix.lower()
        if os.name == "nt" and suffix in {".bat", ".cmd"}:
            return ["cmd.exe", "/c", executable_path]
        return [executable_path]
