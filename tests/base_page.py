from __future__ import annotations

import logging
import re
import time
from datetime import datetime
from pathlib import Path
from typing import Iterable

from appium.webdriver.common.appiumby import AppiumBy
from appium_flutter_finder import FlutterFinder
from selenium.common.exceptions import WebDriverException
from selenium.webdriver.remote.webdriver import WebDriver

from tests.config import AutomationConfig
from tests.driver_factory import switch_to_context


LOGGER = logging.getLogger(__name__)


class BasePage:
    def __init__(self, driver: WebDriver, config: AutomationConfig) -> None:
        self.driver = driver
        self.config = config
        self.finder = FlutterFinder()

    def log_step(self, message: str) -> None:
        LOGGER.info("STEP | %s", message)

    def switch_to_flutter(self, timeout: float = 30.0) -> None:
        switch_to_context(self.driver, "FLUTTER", timeout=timeout)

    def switch_to_native(self, timeout: float = 30.0) -> None:
        switch_to_context(self.driver, "NATIVE_APP", timeout=timeout)

    def take_screenshot(self, name: str) -> Path:
        self.config.ensure_artifact_dirs()
        path = self.config.screenshot_dir / f"{self._stamp()}_{self._slug(name)}.png"
        try:
            try:
                self.switch_to_native(timeout=5.0)
            except Exception:
                pass

            self.driver.get_screenshot_as_file(str(path))
            LOGGER.info("Saved screenshot to %s", path)
        except Exception as exc:  # pragma: no cover - best effort only
            fallback = path.with_suffix(".txt")
            fallback.write_text(
                f"Unable to capture screenshot: {exc}",
                encoding="utf-8",
            )
            LOGGER.warning("Screenshot capture failed: %s", exc)
            LOGGER.info("Saved screenshot failure note to %s", fallback)
            return fallback
        return path

    def dump_page_source(self, name: str) -> Path:
        self.config.ensure_artifact_dirs()
        context = self._safe_current_context()
        context_slug = self._slug(context or "unknown-context")
        path = self.config.page_source_dir / (
            f"{self._stamp()}_{self._slug(name)}_{context_slug}.xml"
        )
        try:
            if context == "FLUTTER":
                source = self.driver.execute_script("flutter:getRenderTree")
            else:
                source = self.driver.page_source
        except Exception as exc:  # pragma: no cover - best effort only
            source = f"Unable to capture page source in context {context!r}: {exc}"
        path.write_text(str(source), encoding="utf-8")
        LOGGER.info("Saved page source to %s", path)
        return path

    def wait_for_text(self, texts: Iterable[str], timeout: float = 20.0) -> str:
        description, _finder = self.wait_for_any_finder(
            ((text, self.finder.by_text(text)) for text in texts),
            timeout=timeout,
        )
        return description

    def wait_for_key(self, key: str, timeout: float = 20.0) -> None:
        self.wait_for_any_finder(((key, self.finder.by_value_key(key)),), timeout=timeout)

    def wait_for_type(self, type_name: str, timeout: float = 20.0) -> None:
        self.wait_for_any_finder(((type_name, self.finder.by_type(type_name)),), timeout=timeout)

    def is_visible(self, finder_obj: object) -> bool:
        try:
            self.wait_for_flutter_finder(finder_obj, timeout_ms=1000)
            return True
        except Exception:
            return False

    def wait_for_flutter_finder(self, finder_obj: object, *, timeout_ms: int = 10000) -> None:
        self.switch_to_flutter()
        self.driver.execute_script("flutter:waitFor", finder_obj, timeout_ms)

    def wait_for_any_finder(
        self,
        candidates: Iterable[tuple[str, object]],
        *,
        timeout: float = 20.0,
        poll_interval: float = 0.75,
    ) -> tuple[str, object]:
        candidate_list = list(candidates)
        deadline = time.monotonic() + timeout
        last_error: Exception | None = None

        while time.monotonic() < deadline:
            for description, finder_obj in candidate_list:
                try:
                    self.wait_for_flutter_finder(finder_obj, timeout_ms=int(poll_interval * 1000))
                    return description, finder_obj
                except Exception as exc:
                    last_error = exc

            time.sleep(poll_interval)

        message = (
            f"Unable to find any expected Flutter target within {timeout:.0f}s: "
            f"{[description for description, _ in candidate_list]}"
        )
        try:
            isolate = self.driver.execute_script("flutter:getIsolate")
            message = f"{message}. Current isolate: {isolate}"
        except Exception:
            pass
        if last_error:
            raise TimeoutError(message) from last_error
        raise TimeoutError(message)

    def wait_for_tappable(self, finder_obj: object, *, timeout_ms: int = 10000) -> None:
        self.switch_to_flutter()
        self.driver.execute_script("flutter:waitForTappable", finder_obj, timeout_ms)

    def wait_until_key_absent(
        self,
        key: str,
        *,
        timeout: float = 12.0,
        poll_interval: float = 0.5,
    ) -> None:
        deadline = time.monotonic() + timeout
        finder_obj = self.finder.by_value_key(key)
        while time.monotonic() < deadline:
            if not self.is_visible(finder_obj):
                return
            time.sleep(poll_interval)
        raise TimeoutError(f"Widget with key '{key}' did not disappear within {timeout:.0f}s.")

    def tap_finder(self, finder_obj: object, *, description: str) -> None:
        self.switch_to_flutter()
        self.wait_for_tappable(finder_obj)
        self.log_step(f"Tap Flutter target: {description}")
        self.driver.execute_script(
            "flutter:clickElement",
            finder_obj,
            {"timeout": 2000},
        )

    def tap_first_visible_text(
        self,
        texts: Iterable[str],
        *,
        timeout: float = 8.0,
        raise_on_missing: bool = True,
    ) -> str | None:
        try:
            description, finder_obj = self.wait_for_any_finder(
                ((text, self.finder.by_text(text)) for text in texts),
                timeout=timeout,
            )
        except TimeoutError:
            if raise_on_missing:
                raise
            return None

        self.tap_finder(finder_obj, description=description)
        return description

    def type_text(self, finder_obj: object, value: str, *, description: str) -> None:
        self.switch_to_flutter()
        self.wait_for_tappable(finder_obj)
        self.log_step(f"Type text into {description}")
        self.driver.execute_script(
            "flutter:clickElement",
            finder_obj,
            {"timeout": 2000},
        )
        try:
            self.driver.execute_script("flutter:enterText", value)
        except Exception:
            # Retry once after reacquiring focus to reduce flaky input on Android devices.
            self.driver.execute_script(
                "flutter:clickElement",
                finder_obj,
                {"timeout": 2000},
            )
            self.driver.execute_script("flutter:enterText", value)

    def type_into_first_visible_text_field(
        self,
        hints: Iterable[str],
        value: str,
        *,
        timeout: float = 12.0,
    ) -> str:
        hint, hint_finder = self.wait_for_any_finder(
            ((hint, self.finder.by_text(hint)) for hint in hints),
            timeout=timeout,
        )
        field_finder = self.finder.by_ancestor(
            hint_finder,
            self.finder.by_type("TextField"),
            match_root=False,
            first_match_only=True,
        )
        if not self.is_visible(field_finder):
            field_finder = hint_finder
        self.type_text(field_finder, value, description=f"field '{hint}'")
        return hint

    def hide_keyboard_if_possible(self) -> None:
        try:
            self.switch_to_native(timeout=5.0)
            self.driver.hide_keyboard()
        except Exception:
            return
        finally:
            try:
                self.switch_to_flutter(timeout=5.0)
            except Exception:
                pass

    def click_native_if_present(
        self,
        *,
        resource_ids: Iterable[str] = (),
        texts: Iterable[str] = (),
    ) -> bool:
        self.switch_to_native()

        for resource_id in resource_ids:
            elements = self.driver.find_elements(AppiumBy.ID, resource_id)
            if elements:
                LOGGER.info("Clicked native element by id: %s", resource_id)
                elements[0].click()
                return True

        for text in texts:
            xpath = f"//*[@text={self._xpath_literal(text)} or @content-desc={self._xpath_literal(text)}]"
            elements = self.driver.find_elements(AppiumBy.XPATH, xpath)
            if elements:
                LOGGER.info("Clicked native element by text: %s", text)
                elements[0].click()
                return True

        return False

    def _safe_current_context(self) -> str | None:
        try:
            return self.driver.current_context
        except WebDriverException:
            return None

    @staticmethod
    def _stamp() -> str:
        return datetime.now().strftime("%Y%m%d_%H%M%S")

    @staticmethod
    def _slug(value: str) -> str:
        cleaned = re.sub(r"[^a-zA-Z0-9._-]+", "_", value.strip())
        return cleaned.strip("_") or "artifact"

    @staticmethod
    def _xpath_literal(value: str) -> str:
        if "'" not in value:
            return f"'{value}'"
        if '"' not in value:
            return f'"{value}"'
        parts = value.split("'")
        quoted = ", \"'\", ".join(f"'{part}'" for part in parts)
        return f"concat({quoted})"
