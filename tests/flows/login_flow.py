from __future__ import annotations

from tests.base_page import BasePage


class LoginFlow(BasePage):
    EMAIL_FIELD_KEY = "login-email-field"
    PASSWORD_FIELD_KEY = "login-password-field"
    LOGIN_BUTTON_KEY = "login-submit-button"
    EMAIL_HINTS = ("Nh\u1eadp email", "Enter email")
    PASSWORD_HINTS = ("Nh\u1eadp m\u1eadt kh\u1ea9u", "Enter password")
    LOGIN_BUTTON_TEXTS = ("\u0110\u0103ng nh\u1eadp", "Login")

    def login_as_parent(self) -> None:
        self.config.require_login_credentials()

        self.log_step("Fill parent email")
        self.type_text(
            self.finder.by_value_key(self.EMAIL_FIELD_KEY),
            self.config.test_email,
            description=f"field '{self.EMAIL_FIELD_KEY}'",
        )

        self.log_step("Fill parent password")
        self.type_text(
            self.finder.by_value_key(self.PASSWORD_FIELD_KEY),
            self.config.test_password,
            description=f"field '{self.PASSWORD_FIELD_KEY}'",
        )

        self.hide_keyboard_if_possible()
        self.log_step("Submit login form")
        self.tap_finder(
            self.finder.by_value_key(self.LOGIN_BUTTON_KEY),
            description=self.LOGIN_BUTTON_KEY,
        )
