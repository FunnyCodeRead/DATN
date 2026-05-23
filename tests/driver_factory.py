from __future__ import annotations

import logging
import time

from appium import webdriver
from selenium.common.exceptions import WebDriverException
from selenium.webdriver.remote.webdriver import WebDriver

from tests.config import AutomationConfig

try:
    from appium.options.common import AppiumOptions
except ImportError:  # pragma: no cover - compatibility fallback
    from appium.options.common.base import AppiumOptions


LOGGER = logging.getLogger(__name__)


def _connect_flutter_socket(
    driver: WebDriver,
    *,
    attempts: int = 3,
    sleep_seconds: float = 2.0,
) -> None:
    last_error: Exception | None = None

    for attempt in range(1, attempts + 1):
        try:
            LOGGER.info(
                "Connecting Appium Flutter Driver socket to Observatory "
                "(attempt %s/%s)",
                attempt,
                attempts,
            )
            driver.execute_script("flutter:connectObservatoryWsUrl")
            LOGGER.info("Appium Flutter Driver socket connected successfully")
            return
        except Exception as exc:
            last_error = exc
            LOGGER.warning(
                "Flutter socket connect attempt %s/%s failed: %s",
                attempt,
                attempts,
                exc,
            )
            if attempt < attempts:
                time.sleep(sleep_seconds)

    raise RuntimeError(
        "Appium Flutter Driver could not reconnect its internal socket to the "
        "Dart VM service after the app was launched from source."
    ) from last_error


def _stabilize_flutter_session(driver: WebDriver) -> None:
    vm_info = driver.execute_script("flutter:getVMInfo")
    isolates = vm_info.get("isolates", []) if isinstance(vm_info, dict) else []
    LOGGER.info("Flutter VM isolates: %s", isolates)

    main_isolate = None
    for isolate in isolates:
        if not isinstance(isolate, dict):
            continue
        name = str(isolate.get("name") or "")
        isolate_id = isolate.get("id")
        if "main" in name.lower() and isolate_id:
            main_isolate = str(isolate_id)
            break

    if main_isolate:
        current_isolate = driver.execute_script("flutter:getIsolate")
        current_id = None
        if isinstance(current_isolate, dict):
            current_id = current_isolate.get("id")
        if current_id != main_isolate:
            LOGGER.info(
                "Switching Flutter isolate from %s to main isolate %s",
                current_id,
                main_isolate,
            )
            driver.execute_script("flutter:setIsolateId", main_isolate)

    driver.execute_script("flutter:waitForFirstFrame")
    health = driver.execute_script("flutter:checkHealth")
    LOGGER.info("Flutter health check: %s", health)


def switch_to_context(
    driver: WebDriver,
    target_context: str,
    *,
    timeout: float = 30.0,
    poll_interval: float = 1.0,
) -> None:
    deadline = time.monotonic() + timeout
    last_contexts: list[str] = []

    while time.monotonic() < deadline:
        try:
            last_contexts = list(driver.contexts)
            if target_context in last_contexts:
                driver.switch_to.context(target_context)
                return
        except WebDriverException:
            pass

        time.sleep(poll_interval)

    raise TimeoutError(
        f"Context '{target_context}' was not available within {timeout:.0f}s. "
        f"Last contexts: {last_contexts}"
    )


def create_driver(
    config: AutomationConfig,
    *,
    observatory_ws_uri: str | None = None,
) -> WebDriver:
    LOGGER.info("Creating Appium session for %s", config.device_name)

    options = AppiumOptions()
    capabilities = config.capabilities()
    if observatory_ws_uri:
        capabilities.pop("appium:app", None)
        capabilities.pop("appium:appPackage", None)
        capabilities.pop("appium:appActivity", None)
        capabilities["appium:observatoryWsUri"] = observatory_ws_uri
        capabilities["appium:skipPortForward"] = True
    options.load_capabilities(capabilities)
    try:
        driver = webdriver.Remote(config.appium_url, options=options)
        driver.implicitly_wait(0)

        if observatory_ws_uri:
            _connect_flutter_socket(
                driver,
                attempts=max(2, min(config.observatory_max_retry_count, 5)),
                sleep_seconds=max(1.0, config.vm_service_settle_time / 2),
            )

        switch_to_context(driver, "FLUTTER", timeout=90.0)
        _stabilize_flutter_session(driver)
        LOGGER.info(
            "Flutter session attached. Desired text entry emulation=%s "
            "(startup command disabled due to driver-side null socket issue).",
            config.text_entry_emulation,
        )
        LOGGER.info("Appium session started successfully")
        return driver
    except WebDriverException as exc:
        install_hint = (
            "APK_PATH was not set, so Appium launched whatever build is already installed "
            f"for package '{config.app_package}'."
        )
        if config.apk_path is not None:
            install_hint = f"APK_PATH is set to '{config.apk_path}'."

        raise RuntimeError(
            "Appium Flutter Driver could not attach to the Dart VM / Observatory.\n"
            "Most common causes:\n"
            "1. The launched app is not a Flutter debug/profile build.\n"
            "2. The app under test does not include flutter_driver + "
            "enableFlutterDriverExtension().\n"
            "3. The app starts too slowly and the Observatory is not ready yet.\n\n"
            f"launch_from_source={config.launch_from_source}\n"
            f"observatory_ws_uri={observatory_ws_uri or 'auto-detect-from-app'}\n"
            f"effective_capabilities={capabilities}\n"
            f"original_appium_error={exc}\n\n"
            f"{install_hint}\n"
            "Recommended next steps:\n"
            f"- Set APK_PATH to the debug APK in this repo: "
            f"'{config.project_root / 'build' / 'app' / 'outputs' / 'flutter-apk' / 'app-debug.apk'}'\n"
            "- Add flutter_driver in pubspec.yaml and call "
            "enableFlutterDriverExtension() before WidgetsFlutterBinding.ensureInitialized() "
            "in the app entrypoint used for automation.\n"
            "- If you do not want to instrument the app, switch strategy to Appium "
            "UiAutomator2 black-box testing instead of appium-flutter-driver."
        ) from exc
