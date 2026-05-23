from __future__ import annotations

from tests.flows.home_assertions import HomeAssertions
from tests.flows.login_flow import LoginFlow
from tests.flows.startup_flow import StartupFlow


def test_parent_can_launch_login_and_reach_home(driver, automation_config):
    startup_flow = StartupFlow(driver, automation_config)
    login_flow = LoginFlow(driver, automation_config)
    home_assertions = HomeAssertions(driver, automation_config)

    entry_state = startup_flow.launch_until_entry_state()

    if entry_state == "login":
        login_flow.login_as_parent()

    home_assertions.assert_parent_home_loaded()
