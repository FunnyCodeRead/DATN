from __future__ import annotations

import json
import logging
import os
import queue
import re
import shutil
import subprocess
import threading
import time
from dataclasses import dataclass
from pathlib import Path

from tests.config import AutomationConfig


LOGGER = logging.getLogger(__name__)

HTTP_OBSERVATORY_RE = re.compile(r"(https?://127\.0\.0\.1:\d+/[A-Za-z0-9=_-]+/?)")
WS_OBSERVATORY_RE = re.compile(r"(ws://127\.0\.0\.1:\d+/[A-Za-z0-9=_-]+/ws)")


@dataclass
class FlutterSourceSession:
    process: subprocess.Popen[str]
    observatory_ws_uri: str

    def stop(self) -> None:
        if self.process.poll() is None:
            self.process.terminate()
            try:
                self.process.wait(timeout=20)
            except subprocess.TimeoutExpired:
                self.process.kill()
                self.process.wait(timeout=10)


class FlutterSourceLauncher:
    def __init__(self, config: AutomationConfig) -> None:
        self.config = config
        self.project_root: Path = config.project_root

    def start(self) -> FlutterSourceSession:
        flutter_command = self._resolve_flutter_command()
        command = [
            *flutter_command,
            "run",
            "--machine",
            "--debug",
            "-t",
            self.config.flutter_target,
        ]
        if self.config.flutter_device_id:
            command.extend(["-d", self.config.flutter_device_id])

        LOGGER.info("Launching latest Flutter source: %s", " ".join(command))
        try:
            process = subprocess.Popen(
                command,
                cwd=self.project_root,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                encoding="utf-8",
                errors="replace",
                bufsize=1,
            )
        except FileNotFoundError as exc:
            raise RuntimeError(
                "Flutter could not be launched. "
                "Set FLUTTER_BIN explicitly or ensure Flutter is installed and discoverable "
                "via PATH or android/local.properties."
            ) from exc

        output_queue: queue.Queue[str] = queue.Queue()
        reader = threading.Thread(
            target=self._drain_output,
            args=(process, output_queue),
            daemon=True,
        )
        reader.start()

        observatory_ws_uri = self._wait_for_observatory(process, output_queue)
        LOGGER.info("Detected Observatory WS URI: %s", observatory_ws_uri)
        if self.config.vm_service_settle_time > 0:
            LOGGER.info(
                "Waiting %.1fs for Flutter driver extension to settle",
                self.config.vm_service_settle_time,
            )
            time.sleep(self.config.vm_service_settle_time)
        return FlutterSourceSession(process=process, observatory_ws_uri=observatory_ws_uri)

    @staticmethod
    def _drain_output(process: subprocess.Popen[str], output_queue: queue.Queue[str]) -> None:
        if process.stdout is None:
            return
        for line in process.stdout:
            output_queue.put(line.rstrip())

    def _wait_for_observatory(
        self,
        process: subprocess.Popen[str],
        output_queue: queue.Queue[str],
    ) -> str:
        deadline = time.monotonic() + self.config.flutter_run_timeout
        recent_lines: list[str] = []

        while time.monotonic() < deadline:
            if process.poll() is not None:
                break

            try:
                line = output_queue.get(timeout=1.0)
            except queue.Empty:
                continue

            recent_lines.append(line)
            if len(recent_lines) > 80:
                recent_lines.pop(0)

            LOGGER.info("flutter run | %s", line)

            observatory_ws_uri = self._extract_ws_uri(line)
            if observatory_ws_uri:
                return observatory_ws_uri

        tail = "\n".join(recent_lines[-20:])
        raise RuntimeError(
            "Timed out while waiting for `flutter run` to expose the Dart VM service.\n"
            f"Last output:\n{tail}"
        )

    def _resolve_flutter_command(self) -> list[str]:
        explicit = self.config.flutter_bin
        if explicit:
            return self._wrap_flutter_executable(Path(explicit))

        for candidate in (shutil.which("flutter"), shutil.which("flutter.bat")):
            if candidate:
                return self._wrap_flutter_executable(Path(candidate))

        local_properties_candidate = self._flutter_from_local_properties()
        if local_properties_candidate is not None:
            return self._wrap_flutter_executable(local_properties_candidate)

        raise RuntimeError(
            "Flutter SDK could not be resolved.\n"
            "Tried FLUTTER_BIN, PATH, and android/local.properties.\n"
            "Set FLUTTER_BIN to your flutter executable, for example:\n"
            "FLUTTER_BIN=D:\\flutter\\bin\\flutter.bat"
        )

    def _flutter_from_local_properties(self) -> Path | None:
        local_properties_path = self.project_root / "android" / "local.properties"
        if not local_properties_path.exists():
            return None

        try:
            contents = local_properties_path.read_text(encoding="utf-8")
        except OSError:
            return None

        for line in contents.splitlines():
            if not line.startswith("flutter.sdk="):
                continue

            sdk_path = line.split("=", 1)[1].strip().replace("\\\\", "\\")
            if not sdk_path:
                return None

            sdk_dir = Path(sdk_path)
            if os.name == "nt":
                for executable_name in ("flutter.bat", "flutter.cmd", "flutter.exe"):
                    executable = sdk_dir / "bin" / executable_name
                    if executable.exists():
                        return executable
            else:
                executable = sdk_dir / "bin" / "flutter"
                if executable.exists():
                    return executable

        return None

    @staticmethod
    def _wrap_flutter_executable(executable: Path) -> list[str]:
        executable_path = str(executable)
        suffix = executable.suffix.lower()
        if os.name == "nt" and suffix in {".bat", ".cmd"}:
            return ["cmd.exe", "/c", executable_path]
        return [executable_path]

    def _extract_ws_uri(self, line: str) -> str | None:
        stripped = line.strip()
        if not stripped:
            return None

        if stripped.startswith("{"):
            try:
                payload = json.loads(stripped)
            except json.JSONDecodeError:
                payload = None

            if isinstance(payload, dict):
                for candidate in self._find_strings(payload):
                    ws_uri = self._normalize_ws_uri(candidate)
                    if ws_uri:
                        return ws_uri
            return None

        return self._normalize_ws_uri(stripped)

    def _find_strings(self, value):
        if isinstance(value, str):
            yield value
            return
        if isinstance(value, dict):
            for nested in value.values():
                yield from self._find_strings(nested)
            return
        if isinstance(value, list):
            for nested in value:
                yield from self._find_strings(nested)

    @staticmethod
    def _normalize_ws_uri(candidate: str) -> str | None:
        ws_match = WS_OBSERVATORY_RE.search(candidate)
        if ws_match:
            return ws_match.group(1)

        http_match = HTTP_OBSERVATORY_RE.search(candidate)
        if http_match:
            http_uri = http_match.group(1).rstrip("/")
            return http_uri.replace("http://", "ws://").replace(
                "https://",
                "wss://",
            ) + "/ws"

        return None
