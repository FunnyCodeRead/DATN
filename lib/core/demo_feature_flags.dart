import 'package:kid_manager/models/notifications/app_notification.dart';

class DemoFeatureFlags {
  const DemoFeatureFlags._();

  // Thesis/demo APK scope: hide schedule and app-usage management flows.
  static const bool scheduleEnabled = false;
  static const bool appUsageEnabled = false;

  static bool isNotificationVisible(NotificationType type) {
    if (!scheduleEnabled &&
        (type == NotificationType.schedule ||
            type == NotificationType.importExcel)) {
      return false;
    }

    if (!appUsageEnabled &&
        (type == NotificationType.appRemoved ||
            type == NotificationType.blockedApp ||
            type == NotificationType.usageLimitExceeded)) {
      return false;
    }

    return true;
  }
}
