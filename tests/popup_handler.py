from __future__ import annotations

import logging
import time

from tests.base_page import BasePage


LOGGER = logging.getLogger(__name__)


class PopupHandler(BasePage):
    ANDROID_ALLOW_IDS = (
        "com.android.permissioncontroller:id/permission_allow_button",
        "com.android.permissioncontroller:id/permission_allow_foreground_only_button",
        "com.android.permissioncontroller:id/permission_allow_one_time_button",
        "com.android.permissioncontroller:id/permission_allow_always_button",
        "com.android.packageinstaller:id/permission_allow_button",
        "android:id/button1",
    )
    ANDROID_DISMISS_IDS = (
        "com.android.permissioncontroller:id/permission_deny_button",
        "com.android.permissioncontroller:id/permission_deny_and_dont_ask_again_button",
        "com.android.packageinstaller:id/permission_deny_button",
        "android:id/button2",
    )
    ANDROID_ALLOW_TEXTS = (
        "Allow",
        "Allow all the time",
        "While using the app",
        "Only this time",
        "Continue",
        "OK",
        "Cho ph\u00e9p",
        "Lu\u00f4n cho ph\u00e9p",
        "Ch\u1ec9 l\u1ea7n n\u00e0y",
        "Khi d\u00f9ng \u1ee9ng d\u1ee5ng",
        "Ti\u1ebfp t\u1ee5c",
        "\u0110\u1ed3ng \u00fd",
    )
    ANDROID_DISMISS_TEXTS = (
        "Skip",
        "Later",
        "Not now",
        "Close",
        "B\u1ecf qua",
        "\u0110\u1ec3 sau",
        "Kh\u00f4ng ph\u1ea3i b\u00e2y gi\u1edd",
        "\u0110\u00f3ng",
        "H\u1ee7y",
    )

    def clear_startup_interruptions(self, *, rounds: int = 5) -> bool:
        handled_any = False

        for _ in range(rounds):
            handled = self._handle_one_native_popup()
            if not handled:
                break
            handled_any = True
            time.sleep(0.75)

        return handled_any

    def _handle_one_native_popup(self) -> bool:
        try:
            if self.click_native_if_present(resource_ids=self.ANDROID_ALLOW_IDS):
                LOGGER.info("Handled native permission popup using resource id")
                return True
            if self.click_native_if_present(texts=self.ANDROID_ALLOW_TEXTS):
                LOGGER.info("Handled native permission popup using text")
                return True
            if self.click_native_if_present(resource_ids=self.ANDROID_DISMISS_IDS):
                LOGGER.info("Dismissed native popup using resource id")
                return True
            if self.click_native_if_present(texts=self.ANDROID_DISMISS_TEXTS):
                LOGGER.info("Dismissed native popup using text")
                return True
        except Exception as exc:
            LOGGER.debug("Popup handling probe failed: %s", exc)
        return False
