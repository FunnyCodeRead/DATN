import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kid_manager/core/app_navigator.dart';
import 'package:kid_manager/core/app_route_observer.dart';
import 'package:kid_manager/repositories/app_management_repository.dart';
import 'package:kid_manager/repositories/birthday_repository.dart';
import 'package:kid_manager/repositories/location/location_repository.dart';
import 'package:kid_manager/repositories/location/location_repository_impl.dart';
import 'package:kid_manager/repositories/notification_repository.dart';
import 'package:kid_manager/repositories/otp_repository.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kid_manager/repositories/subscription_repository.dart';
import 'package:kid_manager/repositories/terms_repository.dart';
import 'package:kid_manager/repositories/user_repository.dart';
import 'package:kid_manager/repositories/user/family_repository.dart';
import 'package:kid_manager/repositories/user/membership_repository.dart';
import 'package:kid_manager/repositories/user/profile_repository.dart';
import 'package:kid_manager/services/access_control/access_control_service.dart';
import 'package:kid_manager/services/app_state_local_service.dart';
import 'package:kid_manager/services/location/location_service.dart';
import 'package:kid_manager/services/app_installed_service.dart';
import 'package:kid_manager/services/permission_service.dart';
import 'package:kid_manager/services/schedule/schedule_notification_service.dart';
import 'package:kid_manager/services/secondary_auth_service.dart';
import 'package:kid_manager/services/storage_service.dart';
import 'package:kid_manager/viewmodels/app_init_vm.dart';
import 'package:kid_manager/viewmodels/app_management_vm.dart';
import 'package:kid_manager/viewmodels/birthday_vm.dart';
import 'package:kid_manager/viewmodels/location/parent_location_vm.dart';
import 'package:kid_manager/viewmodels/location/sos_view_model.dart';
import 'package:kid_manager/viewmodels/locale_vm.dart';
import 'package:kid_manager/viewmodels/notification_vm.dart';
import 'package:kid_manager/viewmodels/otp_vm.dart';
import 'package:kid_manager/viewmodels/schedule/schedule_history_vm.dart';
import 'package:kid_manager/viewmodels/session/session_vm.dart';
import 'package:kid_manager/viewmodels/subscription_vm.dart';
import 'package:kid_manager/viewmodels/terms_vm.dart';
import 'package:kid_manager/viewmodels/user_vm.dart';
import 'package:provider/provider.dart';

import 'core/constants.dart';
import 'core/theme.dart';

import 'features/sessionguard/session_guard.dart';
import 'l10n/app_localizations.dart';
import 'services/firebase_auth_service.dart';
import 'repositories/auth_repository.dart';
import 'viewmodels/auth_vm.dart';

import 'repositories/schedule_repository.dart';
import 'viewmodels/schedule/schedule_vm.dart';

import 'package:kid_manager/repositories/memory_day_repository.dart';
import 'package:kid_manager/services/memory_day/memory_day_reminder_sync_service.dart';
import 'package:kid_manager/viewmodels/memory_day_vm.dart';

import 'package:kid_manager/services/schedule/schedule_import_service.dart';
import 'package:kid_manager/viewmodels/schedule/schedule_import_vm.dart';

class MyApp extends StatefulWidget {
  final bool isDark;
  final Color primaryColor;

  const MyApp({super.key, required this.isDark, required this.primaryColor});

  static MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>()!;

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late final SosViewModel _sosVm;
  late final StorageService _storageService;
  late final FirebaseAuthService _authService;
  late final SecondaryAuthService _secondaryAuthService;
  late final PermissionService _permissionService;
  late final AppInstalledService _appInstalledService;
  late final AccessControlService _accessControlService;
  late final ProfileRepository _profileRepo;
  late final FamilyRepository _familyRepo;
  late final MembershipRepository _membershipRepo;
  late final UserRepository _userRepo;
  late final AuthRepository _authRepo;
  late final OtpRepository _otpRepo;
  late final TermsRepository _termsRepo;
  late final SubscriptionRepository _subscriptionRepo;
  late final ScheduleRepository _scheduleRepo;
  late final AppManagementRepository _appRepo;
  late final MemoryDayRepository _memoryRepo;
  late final BirthdayRepository _birthdayRepo;
  late final NotificationRepository _notificationRepo;
  late final LocationServiceInterface _locationService;
  late final LocationRepository _locationRepo;

  late bool _isDark;
  late Color _primaryColor;
  late Locale locale;

  @override
  void initState() {
    super.initState();

    _sosVm = SosViewModel();
    _storageService = context.read<StorageService>();
    _authService = FirebaseAuthService();
    _secondaryAuthService = SecondaryAuthService();
    _permissionService = PermissionService();
    _appInstalledService = AppInstalledService();
    _accessControlService = AccessControlService();
    _profileRepo = ProfileRepository(FirebaseFirestore.instance);
    _membershipRepo = MembershipRepository(
      FirebaseFirestore.instance,
      _secondaryAuthService,
    );
    _familyRepo = FamilyRepository(FirebaseFirestore.instance, _profileRepo);
    _userRepo = UserRepository(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
      _secondaryAuthService,
      profileRepository: _profileRepo,
      familyRepository: _familyRepo,
      membershipRepository: _membershipRepo,
    );
    _authRepo = AuthRepository(_authService, _userRepo);
    _otpRepo = OtpRepository(
      functions: FirebaseFunctions.instanceFor(region: 'asia-southeast1'),
    );
    _termsRepo = TermsRepository(FirebaseFirestore.instance);
    _subscriptionRepo = SubscriptionRepository(FirebaseFirestore.instance);
    _scheduleRepo = ScheduleRepository(FirebaseFirestore.instance);
    _appRepo = AppManagementRepository(
      _appInstalledService,
      FirebaseFirestore.instance,
      _storageService,
    );
    _memoryRepo = MemoryDayRepository(FirebaseFirestore.instance);
    _birthdayRepo = BirthdayRepository(FirebaseFirestore.instance);
    _notificationRepo = NotificationRepository();
    _locationService = LocationServiceImpl();
    _locationRepo = LocationRepositoryImpl();

    _isDark = widget.isDark;
    _primaryColor = widget.primaryColor;
  }

  void updateTheme(Color color, bool dark) {
    setState(() {
      _primaryColor = color;
      _isDark = dark;
    });
  }

  void updateLanguage(String lang) {
    setState(() {
      locale = Locale(lang);
    });
  }

  @override
  void dispose() {
    _sosVm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: _authService),
        Provider.value(value: _permissionService),
        Provider.value(value: _appInstalledService),
        Provider.value(value: _accessControlService),

        Provider.value(value: _profileRepo),
        Provider.value(value: _familyRepo),
        Provider.value(value: _membershipRepo),
        Provider.value(value: _userRepo),
        Provider.value(value: _authRepo),
        Provider.value(value: _appRepo),
        Provider.value(value: _otpRepo),
        Provider.value(value: _termsRepo),
        Provider.value(value: _subscriptionRepo),
        Provider.value(value: _birthdayRepo),
        Provider.value(value: _locationService),
        Provider.value(value: _locationRepo),
        Provider.value(value: _notificationRepo),

        ChangeNotifierProvider(
          create: (_) =>
              AuthVM(_authRepo, _userRepo, _otpRepo, _storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => AppInitVM(_storageService, _permissionService),
        ),
        ChangeNotifierProvider(
          create: (_) => AppManagementVM(
            _appRepo,
            _userRepo,
            _storageService,
            _accessControlService,
          ),
        ),

        ChangeNotifierProvider(create: (_) => OtpVM(_otpRepo)),
        ChangeNotifierProvider(create: (_) => TermsVM(_termsRepo)),
        ChangeNotifierProvider(
          create: (_) => SubscriptionVM(_subscriptionRepo),
        ),

        Provider<ScheduleRepository>.value(value: _scheduleRepo),

        Provider<ScheduleNotificationService>(
          create: (_) =>
              ScheduleNotificationService(_userRepo, _accessControlService),
        ),
        Provider<MemoryDayReminderSyncService>(
          create: (_) => MemoryDayReminderSyncService(
            FirebaseFirestore.instance,
            _userRepo,
          ),
        ),
        Provider<AppStateLocalService>(
          create: (_) => AppStateLocalService(_storageService),
        ),

        ChangeNotifierProvider(
          create: (context) => ScheduleViewModel(
            _scheduleRepo,
            context.read<AuthVM>(),
            context.read<ScheduleNotificationService>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => ScheduleImportVM(
            ScheduleImportService(context.read<ScheduleRepository>()),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => MemoryDayViewModel(
            _memoryRepo,
            context.read<AuthVM>(),
            context.read<ScheduleNotificationService>(),
            context.read<MemoryDayReminderSyncService>(),
          ),
        ),

        ChangeNotifierProvider(create: (_) => BirthdayViewModel(_birthdayRepo)),

        ChangeNotifierProvider(
          create: (context) =>
              ScheduleHistoryViewModel(context.read<ScheduleRepository>()),
        ),

        ChangeNotifierProvider<SessionVM>(
          lazy: false,
          create: (_) => SessionVM(_authRepo),
        ),

        ChangeNotifierProvider.value(value: _sosVm),

        ChangeNotifierProvider<UserVm>(
          create: (_) =>
              UserVm(_userRepo, _storageService, _accessControlService),
        ),

        ChangeNotifierProxyProvider<UserVm, LocaleVm>(
          create: (_) => LocaleVm(_storageService),
          update: (context, userVm, localeVm) {
            localeVm ??= LocaleVm(_storageService);
            localeVm.syncFromProfile(userVm.profile?.locale);
            return localeVm;
          },
        ),

        ChangeNotifierProvider<NotificationVM>(
          create: (_) => NotificationVM(_notificationRepo),
        ),

        ChangeNotifierProvider<ParentLocationVm>(
          create: (_) => ParentLocationVm(_locationRepo, _locationService),
        ),
      ],
      child: Builder(
        builder: (context) {
          final locale = context.watch<LocaleVm>().locale;
          return MaterialApp(
            navigatorKey: AppNavigator.navigatorKey,
            scaffoldMessengerKey: AppNavigator.messengerKey,
            debugShowCheckedModeBanner: false,
            title: AppConstants.appName,
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('vi'),
              Locale('en'),
              Locale('ja'),
              Locale('ko'),
              Locale('zh'),
              Locale('fr'),
              Locale('de'),
              Locale('es'),
              Locale('th'),
              Locale('id'),
            ],
            navigatorObservers: [routeObserver],
            themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,

            theme: AppTheme.light(seedColor: _primaryColor),

            darkTheme: AppTheme.dark(seedColor: _primaryColor),
            home: const StartupGate(),
          );
        },
      ),
    );
  }
}
