import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kid_manager/core/demo_feature_flags.dart';
import 'package:kid_manager/features/permissions/accessibility_permission_screen.dart';
import 'package:kid_manager/features/permissions/background_location_guide_video_card.dart';
import 'package:kid_manager/features/permissions/background_location_permission_screen.dart';
import 'package:kid_manager/features/permissions/battery_optimization_permission_screen.dart';
import 'package:kid_manager/features/permissions/location_permission_screen.dart';
import 'package:kid_manager/features/permissions/media_permission_screen.dart';
import 'package:kid_manager/features/permissions/notification_permission_screen.dart';
import 'package:kid_manager/features/permissions/usage_access_permission_screen.dart';
import 'package:kid_manager/l10n/app_localizations.dart';
import 'package:kid_manager/services/permission_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class PermissionOnboardingCompletion {
  const PermissionOnboardingCompletion({required this.allPermissionsGranted});

  final bool allPermissionsGranted;
}

class PermissionOnboardingFlow extends StatefulWidget {
  const PermissionOnboardingFlow({
    super.key,
    required this.onFinished,
    this.mediaBuilder,
  });

  final Future<void> Function(PermissionOnboardingCompletion completion)
  onFinished;
  final Widget Function(
    BuildContext context,
    PermissionOnboardingStepType step,
  )?
  mediaBuilder;

  @override
  State<PermissionOnboardingFlow> createState() =>
      _PermissionOnboardingFlowState();
}

enum PermissionOnboardingStepType {
  notifications,
  location,
  backgroundLocation,
  media,
  usage,
  battery,
  accessibility,
}

class _PermissionOnboardingFlowState extends State<PermissionOnboardingFlow>
    with WidgetsBindingObserver {
  late final PermissionService _permissionService;
  late final List<PermissionOnboardingStepType> _steps;

  int _stepIndex = 0;
  bool _busy = false;
  bool _openedSettings = false;
  String? _statusMessage;

  PermissionOnboardingStepType get _currentStep => _steps[_stepIndex];
  List<String> get _stepLabels => _steps.map(_labelForStep).toList();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _permissionService = context.read<PermissionService>();
    _steps = _buildSteps();
    Future.microtask(_syncCurrentStep);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_openedSettings || state != AppLifecycleState.resumed) return;
    _openedSettings = false;
    Future.delayed(const Duration(milliseconds: 350), _syncCurrentStep);
  }

  List<PermissionOnboardingStepType> _buildSteps() {
    final steps = <PermissionOnboardingStepType>[
      PermissionOnboardingStepType.notifications,
      PermissionOnboardingStepType.location,
      PermissionOnboardingStepType.backgroundLocation,
      PermissionOnboardingStepType.media,
    ];

    if (Platform.isAndroid) {
      if (DemoFeatureFlags.appUsageEnabled) {
        steps.add(PermissionOnboardingStepType.usage);
        steps.add(PermissionOnboardingStepType.accessibility);
      }
      steps.add(PermissionOnboardingStepType.battery);
    }

    return steps;
  }

  String _labelForStep(PermissionOnboardingStepType step) {
    final l10n = AppLocalizations.of(context);
    switch (step) {
      case PermissionOnboardingStepType.notifications:
        return l10n.permissionOnboardingStepNotificationsLabel;
      case PermissionOnboardingStepType.location:
        return l10n.permissionOnboardingStepLocationLabel;
      case PermissionOnboardingStepType.backgroundLocation:
        return l10n.permissionOnboardingStepBackgroundLocationLabel;
      case PermissionOnboardingStepType.media:
        return l10n.permissionOnboardingStepMediaLabel;
      case PermissionOnboardingStepType.usage:
        return l10n.permissionOnboardingStepUsageLabel;
      case PermissionOnboardingStepType.accessibility:
        return l10n.permissionOnboardingStepAccessibilityLabel;
      case PermissionOnboardingStepType.battery:
        return l10n.permissionOnboardingStepBatteryLabel;
    }
  }

  Future<void> _syncCurrentStep() async {
    if (!mounted) return;

    for (var i = 0; i < _steps.length; i++) {
      final granted = await _isGranted(_steps[i]);
      if (!granted) {
        if (!mounted) return;
        setState(() {
          _stepIndex = i;
          _statusMessage = null;
        });
        return;
      }
    }

    await _finishFlow();
  }

  Future<bool> _isGranted(PermissionOnboardingStepType type) {
    switch (type) {
      case PermissionOnboardingStepType.notifications:
        return _permissionService.hasNotificationPermission();
      case PermissionOnboardingStepType.location:
        return _permissionService.hasForegroundLocationPermission();
      case PermissionOnboardingStepType.backgroundLocation:
        return _permissionService.hasBackgroundLocationPermission();
      case PermissionOnboardingStepType.media:
        return _permissionService.hasPhotosOrStoragePermission();
      case PermissionOnboardingStepType.usage:
        return _permissionService.hasUsagePermission();
      case PermissionOnboardingStepType.accessibility:
        return _permissionService.hasAccessibilityPermission();
      case PermissionOnboardingStepType.battery:
        return _permissionService.hasBatteryOptimizationDisabled();
    }
  }

  Future<void> _handlePrimary() async {
    if (_busy) return;

    setState(() {
      _busy = true;
      _statusMessage = null;
    });

    try {
      if (_isSettingsOnlyStep(_currentStep)) {
        await _openSettings(_currentStep);
        return;
      }

      final status = await _requestPermission(_currentStep);
      if (!mounted) return;

      if (_isRequestGranted(status, _currentStep)) {
        await _moveToNextStep();
        return;
      }

      final l10n = AppLocalizations.of(context);
      if (status.isPermanentlyDenied || status.isRestricted) {
        setState(() {
          _statusMessage = l10n.permissionOnboardingSystemDeniedMessage;
        });
        return;
      }

      setState(() {
        _statusMessage = l10n.permissionOnboardingNotGrantedMessage;
      });
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _handleOpenSettings() async {
    if (_busy) return;

    setState(() {
      _busy = true;
      _statusMessage = null;
    });

    try {
      await _openSettings(_currentStep);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _handleSkip() async {
    if (_busy) return;
    await _moveToNextStep();
  }

  Future<void> _moveToNextStep() async {
    for (var i = _stepIndex + 1; i < _steps.length; i++) {
      final granted = await _isGranted(_steps[i]);
      if (!granted) {
        if (!mounted) return;
        setState(() {
          _stepIndex = i;
          _statusMessage = null;
        });
        return;
      }
    }

    await _finishFlow();
  }

  Future<void> _finishFlow() async {
    var allPermissionsGranted = true;
    for (final step in _steps) {
      if (!await _isGranted(step)) {
        allPermissionsGranted = false;
        break;
      }
    }

    await widget.onFinished(
      PermissionOnboardingCompletion(
        allPermissionsGranted: allPermissionsGranted,
      ),
    );
  }

  bool _isSettingsOnlyStep(PermissionOnboardingStepType step) {
    switch (step) {
      case PermissionOnboardingStepType.usage:
      case PermissionOnboardingStepType.accessibility:
      case PermissionOnboardingStepType.battery:
        return true;
      case PermissionOnboardingStepType.notifications:
      case PermissionOnboardingStepType.location:
      case PermissionOnboardingStepType.backgroundLocation:
      case PermissionOnboardingStepType.media:
        return false;
    }
  }

  Future<void> _openSettings(PermissionOnboardingStepType type) async {
    _openedSettings = true;
    switch (type) {
      case PermissionOnboardingStepType.notifications:
        await _permissionService.openNotificationSettings();
        break;
      case PermissionOnboardingStepType.location:
      case PermissionOnboardingStepType.backgroundLocation:
      case PermissionOnboardingStepType.media:
        if (type == PermissionOnboardingStepType.backgroundLocation) {
          await _permissionService.openLocationSettings();
        } else {
          await _permissionService.openAppSettingsPage();
        }
        break;
      case PermissionOnboardingStepType.usage:
        await _permissionService.openUsageAccessSettings();
        break;
      case PermissionOnboardingStepType.accessibility:
        await _permissionService.openAccessibilitySettings();
        break;
      case PermissionOnboardingStepType.battery:
        await _permissionService.openBatteryOptimizationSettings();
        break;
    }
  }

  Future<PermissionStatus> _requestPermission(
    PermissionOnboardingStepType type,
  ) {
    switch (type) {
      case PermissionOnboardingStepType.notifications:
        return _permissionService.requestNotificationPermission();
      case PermissionOnboardingStepType.location:
        return _permissionService.requestForegroundLocationPermission();
      case PermissionOnboardingStepType.backgroundLocation:
        return _permissionService.requestBackgroundLocationPermission();
      case PermissionOnboardingStepType.media:
        return _requestMediaPermission();
      case PermissionOnboardingStepType.usage:
      case PermissionOnboardingStepType.accessibility:
      case PermissionOnboardingStepType.battery:
        return Future.value(PermissionStatus.denied);
    }
  }

  Future<PermissionStatus> _requestMediaPermission() async {
    final granted = await _permissionService.requestPhotosOrStoragePermission();
    return granted ? PermissionStatus.granted : PermissionStatus.denied;
  }

  bool _isRequestGranted(
    PermissionStatus status,
    PermissionOnboardingStepType type,
  ) {
    if (status.isGranted) return true;
    if (type == PermissionOnboardingStepType.notifications &&
        status == PermissionStatus.provisional) {
      return true;
    }
    if (type == PermissionOnboardingStepType.media &&
        status == PermissionStatus.limited) {
      return true;
    }
    return false;
  }

  Widget _buildStepScreen() {
    final l10n = AppLocalizations.of(context);
    final currentStep = _stepIndex + 1;
    final totalSteps = _steps.length;
    final media = _buildStepMedia();

    switch (_currentStep) {
      case PermissionOnboardingStepType.notifications:
        return NotificationPermissionScreen(
          key: const ValueKey('notifications'),
          currentStep: currentStep,
          totalSteps: totalSteps,
          stepLabels: _stepLabels,
          busy: _busy,
          statusMessage: _statusMessage,
          media: media,
          helperText: l10n.permissionOnboardingNotificationHelperText,
          onAllow: () => unawaited(_handlePrimary()),
          onOpenSettings: () => unawaited(_handleOpenSettings()),
          onSkip: () => unawaited(_handleSkip()),
        );
      case PermissionOnboardingStepType.location:
        return LocationPermissionScreen(
          key: const ValueKey('location'),
          currentStep: currentStep,
          totalSteps: totalSteps,
          stepLabels: _stepLabels,
          busy: _busy,
          statusMessage: _statusMessage,
          media: media,
          onAllow: () => unawaited(_handlePrimary()),
          onOpenSettings: () => unawaited(_handleOpenSettings()),
          onSkip: () => unawaited(_handleSkip()),
        );
      case PermissionOnboardingStepType.backgroundLocation:
        return BackgroundLocationPermissionScreen(
          key: const ValueKey('background-location'),
          currentStep: currentStep,
          totalSteps: totalSteps,
          stepLabels: _stepLabels,
          busy: _busy,
          statusMessage: _statusMessage,
          media: media,
          onAllow: () => unawaited(_handlePrimary()),
          onOpenSettings: () => unawaited(_handleOpenSettings()),
          onSkip: () => unawaited(_handleSkip()),
        );
      case PermissionOnboardingStepType.media:
        return MediaPermissionScreen(
          key: const ValueKey('media'),
          currentStep: currentStep,
          totalSteps: totalSteps,
          stepLabels: _stepLabels,
          busy: _busy,
          statusMessage: _statusMessage,
          media: media,
          onAllow: () => unawaited(_handlePrimary()),
          onOpenSettings: () => unawaited(_handleOpenSettings()),
          onSkip: () => unawaited(_handleSkip()),
        );
      case PermissionOnboardingStepType.usage:
        return UsageAccessPermissionScreen(
          key: const ValueKey('usage'),
          currentStep: currentStep,
          totalSteps: totalSteps,
          stepLabels: _stepLabels,
          busy: _busy,
          statusMessage: _statusMessage,
          media: media,
          onOpenUsageAccess: () => unawaited(_handlePrimary()),
          onOpenSettings: () => unawaited(_handleOpenSettings()),
          onSkip: () => unawaited(_handleSkip()),
        );
      case PermissionOnboardingStepType.accessibility:
        return AccessibilityPermissionScreen(
          key: const ValueKey('accessibility'),
          currentStep: currentStep,
          totalSteps: totalSteps,
          stepLabels: _stepLabels,
          busy: _busy,
          statusMessage: _statusMessage,
          media: media,
          onOpenAccessibility: () => unawaited(_handlePrimary()),
          onOpenSettings: () => unawaited(_handleOpenSettings()),
          onSkip: () => unawaited(_handleSkip()),
        );
      case PermissionOnboardingStepType.battery:
        return BatteryOptimizationPermissionScreen(
          key: const ValueKey('battery'),
          currentStep: currentStep,
          totalSteps: totalSteps,
          stepLabels: _stepLabels,
          busy: _busy,
          statusMessage: _statusMessage,
          media: media,
          onOpenBatterySettings: () => unawaited(_handlePrimary()),
          onOpenSettings: () => unawaited(_handleOpenSettings()),
          onSkip: () => unawaited(_handleSkip()),
        );
    }
  }

  Widget? _buildStepMedia() {
    final override = widget.mediaBuilder?.call(context, _currentStep);
    if (override != null) return override;

    if (_currentStep == PermissionOnboardingStepType.backgroundLocation) {
      return const BackgroundLocationGuideVideoCard();
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: _buildStepScreen(),
    );
  }
}
