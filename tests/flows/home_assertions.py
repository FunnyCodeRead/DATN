from __future__ import annotations

from tests.base_page import BasePage


class HomeAssertions(BasePage):
    def assert_parent_home_loaded(self) -> None:
        self.log_step("Assert authenticated parent shell is visible")
        self.wait_for_type("AppShell", timeout=45.0)
        self.wait_for_type("ParentAllChildrenMapScreen", timeout=45.0)
