import 'package:kid_manager/features/presentation/shared/app_bottom_bar_config.dart';
import 'package:kid_manager/features/presentation/shared/state/mapbox_controller.dart';
import 'package:kid_manager/core/demo_feature_flags.dart';
import 'package:kid_manager/models/notifications/notification_source.dart';
import 'package:kid_manager/repositories/chat/family_chat_repository.dart';
import 'package:kid_manager/viewmodels/auth_vm.dart';
import 'package:kid_manager/viewmodels/user_vm.dart';
import 'package:kid_manager/viewmodels/zones/zone_status_vm.dart';
import 'package:kid_manager/views/chat/family_group_chat_screen.dart';
import 'package:kid_manager/views/child/child_location_screen.dart';
import 'package:kid_manager/views/child/schedule/child_schedule_screen.dart';
import 'package:kid_manager/views/notifications/notification_tab.dart';
import 'package:kid_manager/views/parent/dashboard/app_management_screen.dart';
import 'package:kid_manager/views/parent/location/parent_location_screen.dart';
import 'package:kid_manager/views/parent/schedule/schedule_screen.dart';
import 'package:kid_manager/views/personal_info_screen.dart';
import 'package:provider/provider.dart';

class AppShellConfig {
  const AppShellConfig(this.tabs, {required this.chatTabIndex});

  final List<BottomTabConfig> tabs;
  final int chatTabIndex;

  static AppShellConfig parent() => _adultManager();

  static AppShellConfig guardian() => AppShellConfig([
    _managerMapTab(),
    if (DemoFeatureFlags.appUsageEnabled)
      BottomTabConfig(
        iconAsset: 'assets/icons/dashboard.svg',
        root: const AppManagementScreen(),
      ),
    _familyChatTab(),
    _notificationTab(),
    if (DemoFeatureFlags.scheduleEnabled)
      BottomTabConfig(
        iconAsset: 'assets/icons/calendar.svg',
        root: const ScheduleScreen(),
        isScheduleTab: true,
      ),
    _profileTab(),
  ], chatTabIndex: DemoFeatureFlags.appUsageEnabled ? 2 : 1);

  static AppShellConfig child() => AppShellConfig([
    BottomTabConfig(
      iconAsset: 'assets/icons/location.svg',
      isMapTab: true,
      root: MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => MapboxController())],
        child: const ChildLocationScreen(),
      ),
    ),
    _familyChatTab(),
    _notificationTab(),
    if (DemoFeatureFlags.scheduleEnabled)
      BottomTabConfig(
        iconAsset: 'assets/icons/calendar.svg',
        root: const ChildScheduleScreen(),
        isScheduleTab: true,
      ),
    _profileTab(),
  ], chatTabIndex: 1);

  static AppShellConfig _adultManager() => AppShellConfig([
    _managerMapTab(),
    if (DemoFeatureFlags.appUsageEnabled)
      BottomTabConfig(
        iconAsset: 'assets/icons/dashboard.svg',
        root: const AppManagementScreen(),
      ),
    _familyChatTab(),
    _notificationTab(),
    if (DemoFeatureFlags.scheduleEnabled)
      BottomTabConfig(
        iconAsset: 'assets/icons/calendar.svg',
        root: const ScheduleScreen(),
        isScheduleTab: true,
      ),
    _profileTab(),
  ], chatTabIndex: DemoFeatureFlags.appUsageEnabled ? 2 : 1);

  static BottomTabConfig _managerMapTab() => BottomTabConfig(
    iconAsset: 'assets/icons/location.svg',
    isMapTab: true,
    root: MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MapboxController()),
        ChangeNotifierProvider(create: (_) => ZoneStatusVm()),
      ],
      child: const ParentAllChildrenMapScreen(),
    ),
  );

  static BottomTabConfig _familyChatTab() => BottomTabConfig(
    iconAsset: 'assets/icons/sms.svg',
    root: const FamilyGroupChatScreen(),
    showBadge: true,
    badgeCountStreamBuilder: (context) {
      final authVm = context.read<AuthVM>();
      if (authVm.logoutInProgress) {
        return Stream.value(0);
      }

      final userVm = context.read<UserVm>();
      final familyId = userVm.familyId;
      final me = userVm.me;

      if (familyId == null || me == null) {
        return Stream.value(0);
      }

      return FamilyChatRepository().watchUnreadCount(
        familyId: familyId,
        uid: me.uid,
      );
    },
  );

  static BottomTabConfig _notificationTab() => const BottomTabConfig(
    iconAsset: 'assets/icons/bell.svg',
    root: NotificationTab(sources: [NotificationSource.global]),
    showBadge: true,
    isNotificationTab: true,
  );

  static BottomTabConfig _profileTab() => const BottomTabConfig(
    iconAsset: 'assets/icons/user_nav.svg',
    root: PersonalInfoScreen(),
  );
}
