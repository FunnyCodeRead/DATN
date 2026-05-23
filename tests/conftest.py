from __future__ import annotations

import logging

import pytest

from tests.android_device_prep import AndroidDevicePreparer
from tests.base_page import BasePage
from tests.config import AutomationConfig
from tests.driver_factory import create_driver
from tests.flutter_source_launcher import FlutterSourceLauncher, FlutterSourceSession


def pytest_configure() -> None:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
    )


@pytest.fixture(scope="session")
def automation_config() -> AutomationConfig:
    config = AutomationConfig.from_env()
    config.ensure_artifact_dirs()
    return config


@pytest.fixture(scope="function")
def driver(request: pytest.FixtureRequest, automation_config: AutomationConfig):
    flutter_session: FlutterSourceSession | None = None
    observatory_ws_uri: str | None = None
    device_preparer = (
        AndroidDevicePreparer(automation_config)
        if automation_config.auto_prepare_android_permissions
        else None
    )

    try:
        if device_preparer is not None:
            device_preparer.prepare()

        if automation_config.launch_from_source:
            launcher = FlutterSourceLauncher(automation_config)
            flutter_session = launcher.start()
            observatory_ws_uri = flutter_session.observatory_ws_uri
            if device_preparer is not None:
                device_preparer.prepare()

        session = create_driver(
            automation_config,
            observatory_ws_uri=observatory_ws_uri,
        )
    except Exception:
        if flutter_session is not None:
            flutter_session.stop()
        raise

    request.node.appium_driver = session

    try:
        yield session
    finally:
        report = getattr(request.node, "rep_call", None)
        if report and report.failed:
            helper = BasePage(session, automation_config)
            try:
                helper.take_screenshot(request.node.name)
            except Exception as exc:
                logging.getLogger(__name__).warning(
                    "Failure screenshot capture crashed: %s",
                    exc,
                )
            try:
                helper.dump_page_source(request.node.name)
            except Exception as exc:
                logging.getLogger(__name__).warning(
                    "Failure page source dump crashed: %s",
                    exc,
                )

        session.quit()
        if flutter_session is not None:
            flutter_session.stop()


@pytest.hookimpl(hookwrapper=True)
def pytest_runtest_makereport(item: pytest.Item, call: pytest.CallInfo[None]):
    outcome = yield
    report = outcome.get_result()
    setattr(item, f"rep_{report.when}", report)
