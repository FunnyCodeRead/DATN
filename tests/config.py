from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path

from dotenv import load_dotenv


def _parse_bool(raw: str | None, *, default: bool = False) -> bool:
    if raw is None:
        return default
    return raw.strip().lower() in {"1", "true", "yes", "y", "on"}


@dataclass(frozen=True)
class AutomationConfig:
    appium_url: str
    device_name: str
    udid: str | None
    flutter_device_id: str | None
    flutter_bin: str | None
    adb_bin: str | None
    apk_path: Path | None
    app_package: str
    app_activity: str
    test_email: str
    test_password: str
    app_language: str
    launch_from_source: bool
    auto_prepare_android_permissions: bool
    flutter_target: str
    flutter_run_timeout: int
    vm_service_settle_time: float
    text_entry_emulation: bool
    no_reset: bool
    new_command_timeout: int
    observatory_retry_backoff_ms: int
    observatory_max_retry_count: int
    project_root: Path
    artifacts_root: Path
    screenshot_dir: Path
    page_source_dir: Path

    @classmethod
    def from_env(cls) -> "AutomationConfig":
        load_dotenv()

        project_root = Path(__file__).resolve().parents[1]
        artifacts_root = project_root / "artifacts"
        screenshot_dir = artifacts_root / "screenshots"
        page_source_dir = artifacts_root / "pagesource"

        apk_path_raw = os.getenv("APK_PATH")
        apk_path = Path(apk_path_raw).expanduser().resolve() if apk_path_raw else None
        if apk_path is not None and not apk_path.exists():
            raise FileNotFoundError(f"APK_PATH does not exist: {apk_path}")

        language = (os.getenv("APP_LANGUAGE") or "vi").strip().lower()
        if language not in {"vi", "en"}:
            raise ValueError("APP_LANGUAGE must be either 'vi' or 'en'.")

        return cls(
            appium_url=os.getenv("APPIUM_URL", "http://127.0.0.1:4723"),
            device_name=os.getenv("DEVICE_NAME", "Android Emulator"),
            udid=os.getenv("UDID") or None,
            flutter_device_id=os.getenv("FLUTTER_DEVICE_ID") or os.getenv("UDID") or None,
            flutter_bin=os.getenv("FLUTTER_BIN") or None,
            adb_bin=os.getenv("ADB_BIN") or None,
            apk_path=apk_path,
            app_package=os.getenv("APP_PACKAGE", "com.example.kid_manager"),
            app_activity=os.getenv("APP_ACTIVITY", ".MainActivity"),
            test_email=os.getenv("TEST_EMAIL", "").strip(),
            test_password=os.getenv("TEST_PASSWORD", ""),
            app_language=language,
            launch_from_source=_parse_bool(
                os.getenv("LAUNCH_FROM_SOURCE"),
                default=True,
            ),
            auto_prepare_android_permissions=_parse_bool(
                os.getenv("AUTO_PREPARE_ANDROID_PERMISSIONS"),
                default=True,
            ),
            flutter_target=os.getenv("FLUTTER_TARGET", "lib/main_automation.dart"),
            flutter_run_timeout=int(os.getenv("FLUTTER_RUN_TIMEOUT", "240")),
            vm_service_settle_time=float(os.getenv("VM_SERVICE_SETTLE_TIME", "5")),
            text_entry_emulation=_parse_bool(
                os.getenv("TEXT_ENTRY_EMULATION"),
                default=True,
            ),
            no_reset=_parse_bool(os.getenv("NO_RESET"), default=False),
            new_command_timeout=int(os.getenv("NEW_COMMAND_TIMEOUT", "240")),
            observatory_retry_backoff_ms=int(
                os.getenv("OBSERVATORY_RETRY_BACKOFF_MS", "3000")
            ),
            observatory_max_retry_count=int(
                os.getenv("OBSERVATORY_MAX_RETRY_COUNT", "30")
            ),
            project_root=project_root,
            artifacts_root=artifacts_root,
            screenshot_dir=screenshot_dir,
            page_source_dir=page_source_dir,
        )

    @property
    def android_locale(self) -> str:
        return "VN" if self.app_language == "vi" else "US"

    def capabilities(self) -> dict[str, object]:
        caps: dict[str, object] = {
            "platformName": "Android",
            "appium:automationName": "Flutter",
            "appium:deviceName": self.device_name,
            "appium:appPackage": self.app_package,
            "appium:appActivity": self.app_activity,
            "appium:autoGrantPermissions": False,
            "appium:noReset": self.no_reset,
            "appium:newCommandTimeout": self.new_command_timeout,
            "appium:language": self.app_language,
            "appium:locale": self.android_locale,
            "appium:retryBackoffTime": self.observatory_retry_backoff_ms,
            "appium:maxRetryCount": self.observatory_max_retry_count,
        }

        if self.udid:
            caps["appium:udid"] = self.udid
        if self.apk_path is not None and not self.launch_from_source:
            caps["appium:app"] = str(self.apk_path)

        return caps

    def ensure_artifact_dirs(self) -> None:
        self.screenshot_dir.mkdir(parents=True, exist_ok=True)
        self.page_source_dir.mkdir(parents=True, exist_ok=True)

    def require_login_credentials(self) -> None:
        if not self.test_email or not self.test_password:
            raise RuntimeError(
                "TEST_EMAIL and TEST_PASSWORD must be set before running the smoke test."
            )
