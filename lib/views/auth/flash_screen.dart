import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kid_manager/core/demo_feature_flags.dart';
import 'package:kid_manager/core/storage_keys.dart';
import 'package:kid_manager/features/sessionguard/session_guard.dart';
import 'package:kid_manager/l10n/app_localizations.dart';
import 'package:kid_manager/services/notifications/local_alarm_service.dart';
import 'package:kid_manager/services/notifications/local_notification_service.dart';
import 'package:kid_manager/services/notifications/notification_service.dart';
import 'package:kid_manager/services/storage_service.dart';
import 'package:kid_manager/viewmodels/app_management_vm.dart';
import 'package:kid_manager/viewmodels/session/session_vm.dart';
import 'package:kid_manager/widgets/common/loading_view.dart';
import 'package:provider/provider.dart';

class FlashScreen extends StatefulWidget {
  const FlashScreen({super.key});

  @override
  State<FlashScreen> createState() => _FlashScreenState();
}

String _maskToken(String? token) {
  if (token == null || token.isEmpty) return 'null';
  if (token.length <= 8) return '***';
  return '${token.substring(0, 4)}...${token.substring(token.length - 4)}';
}

Future<void> _runDeferredStartupTasks() async {
  try {
    await LocalNotificationService.init();
    await NotificationService.init();
  } catch (e) {
    debugPrint('Notification bootstrap failed: $e');
  }

  try {
    await LocalAlarmService.I.init();
  } catch (e) {
    debugPrint('LocalAlarm init failed: $e');
  }

  try {
    await initializeDateFormatting('vi_VN', '');
  } catch (e) {
    debugPrint('Date formatting init failed: $e');
  }

  try {
    final token = await FirebaseMessaging.instance.getToken();
    if (kDebugMode) {
      debugPrint('FCM token=${_maskToken(token)}');
    }
  } catch (e) {
    debugPrint('FCM token fetch failed: $e');
  }
}

class _FlashScreenState extends State<FlashScreen> {
  Future<void> _onContinue() async {
    await context.read<StorageService>().setBool(StorageKeys.flashSeenV1, true);

    await _runDeferredStartupTasks();
    if (!mounted) return;

    context.read<SessionVM>().finishSplash();
    unawaited(
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const StartupGate())),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAppLoading = DemoFeatureFlags.appUsageEnabled
        ? context.watch<AppManagementVM>().loading
        : false;
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (isAppLoading) {
      return const LoadingOverlay();
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LogoStack(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 241,
                      child: Text(
                        l10n.flashWelcomeTitle,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontSize: 24,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          height: 1.42,
                          letterSpacing: -0.80,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 241,
                      child: Text(
                        l10n.flashWelcomeSubtitle,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w400,
                          height: 1.71,
                          letterSpacing: -0.30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40, right: 53, top: 24),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _onContinue,
                  child: SizedBox(
                    width: 41,
                    child: Text(
                      l10n.flashNext,
                      textAlign: TextAlign.right,
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        height: 1.56,
                        letterSpacing: -0.40,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoStack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 294.43,
      height: 267.16,
      child: Stack(
        alignment: Alignment.center,
        children: [Image.asset('assets/images/Illustration.png')],
      ),
    );
  }
}
