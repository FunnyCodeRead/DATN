from __future__ import annotations

import time

from tests.base_page import BasePage
from tests.popup_handler import PopupHandler


class StartupFlow(BasePage):
    LOGIN_EMAIL_FIELD_KEY = "login-email-field"
    LOGIN_PASSWORD_FIELD_KEY = "login-password-field"
    FLASH_NEXT_TEXTS = ("Ti\u1ebfp", "Next")
    LOGIN_TEXTS = ("\u0110\u0103ng nh\u1eadp", "Login")
    LOGIN_HINTS = ("Nh\u1eadp email", "Enter email")
    LOGIN_PASSWORD_HINTS = ("Nh\u1eadp m\u1eadt kh\u1ea9u", "Enter password")
    LOGIN_TITLES = ("CH\u00c0O M\u1eeaNG TR\u1ede L\u1ea0I", "WELCOME BACK")
    PERMISSION_STEP_KEYS = (
        "notifications",
        "location",
        "background-location",
        "media",
        "usage",
        "battery",
        "accessibility",
    )
    PERMISSION_SKIP_TEXTS = ("\u0110\u1ec3 sau", "Later", "B\u1ecf qua", "Skip")

    def __init__(self, driver, config) -> None:
        super().__init__(driver, config)
        self.popups = PopupHandler(driver, config)

    def launch_until_entry_state(self) -> str:
        self.log_step("Wait for Flutter app to become interactive")
        self.switch_to_flutter(timeout=90.0)

        if self._is_parent_home_visible():
            self.log_step("App is already on an authenticated parent home state")
            return "home"

        self._maybe_dismiss_flash_screen()
        self.popups.clear_startup_interruptions()
        self._skip_permission_onboarding_if_present()
        self.popups.clear_startup_interruptions()

        if self._is_parent_home_visible():
            return "home"

        self._wait_for_login_screen()
        return "login"

    def _maybe_dismiss_flash_screen(self) -> None:
        tapped = self.tap_first_visible_text(
            self.FLASH_NEXT_TEXTS,
            timeout=6.0,
            raise_on_missing=False,
        )
        if tapped:
            self.log_step(f"Dismissed flash screen using '{tapped}'")
            time.sleep(1.0)

    def _skip_permission_onboarding_if_present(self) -> None:
        for _ in range(len(self.PERMISSION_STEP_KEYS) + 2):
            current_step = self._current_permission_step()
            if current_step is None:
                return

            self.log_step(f"Skip permission onboarding step '{current_step}'")
            selected = self.tap_first_visible_text(
                self.PERMISSION_SKIP_TEXTS,
                timeout=8.0,
                raise_on_missing=False,
            )
            if not selected:
                raise RuntimeError(
                    f"Permission step '{current_step}' is visible but no skip button was found."
                )

            self.popups.clear_startup_interruptions()
            self._wait_for_step_to_advance(current_step)

    def _current_permission_step(self) -> str | None:
        for key in self.PERMISSION_STEP_KEYS:
            if self.is_visible(self.finder.by_value_key(key)):
                return key
        return None

    def _wait_for_step_to_advance(self, current_step: str) -> None:
        deadline = time.monotonic() + 15.0

        while time.monotonic() < deadline:
            if not self.is_visible(self.finder.by_value_key(current_step)):
                return
            if self._is_login_visible() or self._is_parent_home_visible():
                return
            time.sleep(0.5)

        raise TimeoutError(
            f"Permission step '{current_step}' did not advance after tapping skip."
        )

    def _wait_for_login_screen(self) -> None:
        self.log_step("Wait for login screen")
        self.wait_for_any_finder(
            (
                (self.LOGIN_EMAIL_FIELD_KEY, self.finder.by_value_key(self.LOGIN_EMAIL_FIELD_KEY)),
                (
                    self.LOGIN_PASSWORD_FIELD_KEY,
                    self.finder.by_value_key(self.LOGIN_PASSWORD_FIELD_KEY),
                ),
                *((text, self.finder.by_text(text)) for text in self.LOGIN_TEXTS),
                *((title, self.finder.by_text(title)) for title in self.LOGIN_TITLES),
                *((hint, self.finder.by_text(hint)) for hint in self.LOGIN_HINTS),
                *((hint, self.finder.by_text(hint)) for hint in self.LOGIN_PASSWORD_HINTS),
                ("LoginScreen", self.finder.by_type("LoginScreen")),
            ),
            timeout=80.0,
        )

    def _is_login_visible(self) -> bool:
        for text in (
            self.LOGIN_EMAIL_FIELD_KEY,
            self.LOGIN_PASSWORD_FIELD_KEY,
            *self.LOGIN_TEXTS,
            *self.LOGIN_TITLES,
            *self.LOGIN_HINTS,
            *self.LOGIN_PASSWORD_HINTS,
        ):
            finder = (
                self.finder.by_value_key(text)
                if text in {self.LOGIN_EMAIL_FIELD_KEY, self.LOGIN_PASSWORD_FIELD_KEY}
                else self.finder.by_text(text)
            )
            if self.is_visible(finder):
                return True
        return self.is_visible(self.finder.by_type("LoginScreen"))

    def _is_parent_home_visible(self) -> bool:
        return self.is_visible(self.finder.by_type("AppShell")) or self.is_visible(
            self.finder.by_type("ParentAllChildrenMapScreen")
        )
