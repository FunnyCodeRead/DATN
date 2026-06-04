import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_activity_recognition/models/activity.dart';
import 'package:kid_manager/core/location/current_publish_policy.dart';
import 'package:kid_manager/core/location/motion_detector.dart';
import 'package:kid_manager/core/location/send_policy.dart';
import 'package:kid_manager/core/location/tracking_payload.dart';
import 'package:kid_manager/core/location/tracking_state.dart';
import 'package:kid_manager/core/location/tracking_tuning.dart';
import 'package:kid_manager/core/zones/zone_monitor.dart';
import 'package:kid_manager/background/tracking_runtime_store.dart';
import 'package:kid_manager/features/pipeline/tracking_pipeline.dart';
import 'package:kid_manager/l10n/app_localizations.dart';
import 'package:kid_manager/models/location/location_data.dart';
import 'package:kid_manager/models/location/transport_mode.dart';
import 'package:kid_manager/models/zones/geo_zone.dart';
import 'package:kid_manager/repositories/location/location_repository.dart';
import 'package:kid_manager/repositories/user_repository.dart';
import 'package:kid_manager/repositories/zones/zone_repository.dart';
import 'package:kid_manager/background/tracking_background_service.dart';
import 'package:kid_manager/services/location/background_tracking_status_policy.dart';
import 'package:kid_manager/services/location/location_service.dart';
import 'package:kid_manager/services/location/tracking_status_service.dart';
import 'package:kid_manager/utils/app_localizations_loader.dart';

class BackgroundTrackingRuntime {
  BackgroundTrackingRuntime(
    this._locationRepository,
    this._locationService, {
    FirebaseAuth? auth,
    TrackingStatusService? trackingStatusService,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _trackingStatusService =
           trackingStatusService ?? TrackingStatusService() {
    _authStateSub = _auth.authStateChanges().listen(_handleAuthStateChanged);
  }

  final LocationRepository _locationRepository;
  final LocationServiceInterface _locationService;
  final FirebaseAuth _auth;
  final TrackingStatusService _trackingStatusService;

  final TrackingPipeline _engine = TrackingPipeline(
    motionDetector: MotionDetector(),
    sendPolicy: SendPolicy(),
  );

  StreamSubscription<User?>? _authStateSub;
  StreamSubscription<LocationData>? _gpsSub;
  StreamSubscription<Activity>? _activitySub;
  StreamSubscription<List<GeoZone>>? _zonesSub;
  Timer? _healthTimer;

  ZoneMonitor? _zoneMonitor;
  bool _zonesInited = false;
  String? _zoneMonitorUid;

  bool _disposed = false;
  bool _running = false;
  bool get isRunning => _running;

  bool _requireBackground = true;
  bool _currentOnly = false;
  String? _activeSharingUid;
  Activity? _lastActivity;
  LocationData? _currentLocation;
  TransportMode _transport = TransportMode.unknown;

  int _lastStatusHeartbeatAtMs = 0;
  int _lastCurrentSentAtMs = 0;
  int _lastCurrentFailureAtMs = 0;
  int _lastHistoryFailureAtMs = 0;
  bool _sentInitialCurrent = false;
  String? _lastTrackingStatus;

  Future<AppLocalizations>? _l10nFuture;
  String? _l10nUid;

  Future<bool> start({
    required bool requireBackground,
    bool currentOnly = false,
  }) async {
    try {
      if (_disposed) return false;
      if (_running) return true;

      _requireBackground = requireBackground;
      _currentOnly = currentOnly;

      final l10n = await _getL10n();
      if (_disposed) return false;

      final sharingUid = _requireUidOrNull();
      if (sharingUid == null) {
        debugPrint('BackgroundTrackingRuntime.start skipped: no auth user');
        return false;
      }

      final serviceEnabled = await _locationService.ensureServiceAndPermission(
        requireBackground: false,
        requestIfNeeded: false,
        enablePluginBackgroundMode: false,
        applyPluginLocationSettings: false,
        notificationTitle: l10n.locationForegroundServiceTitle,
        notificationSubtitle: l10n.locationForegroundServiceSubtitle,
      );

      if (!serviceEnabled) {
        await _reportStartupFailure(l10n);
        return false;
      }

      _activeSharingUid = sharingUid;
      _running = true;
      _transport = TransportMode.unknown;
      _currentLocation = null;
      _lastTrackingStatus = null;
      _lastStatusHeartbeatAtMs = 0;
      _lastCurrentSentAtMs = 0;
      _lastCurrentFailureAtMs = 0;
      _lastHistoryFailureAtMs = 0;
      _sentInitialCurrent = false;

      await _startHealthMonitor();
      if (_disposed) return false;
      await _startActivityRecognition();
      if (_disposed) return false;
      if (!_currentOnly) {
        await _ensureZoneMonitor(sharingUid);
        if (_disposed) return false;
      }

      _gpsSub = _locationService
          .getLocationStream(usePlatformPlugin: false)
          .listen(
            (raw) async {
              if (_disposed || !_running) return;

              final activeSharingUid = _activeSharingUid;
              final currentUid = _currentUidOrNull();
              if (activeSharingUid == null ||
                  currentUid == null ||
                  currentUid != activeSharingUid) {
                debugPrint(
                  'BackgroundTrackingRuntime dropping location because auth changed.',
                );
                await stop();
                return;
              }

              final result = _engine.process(
                raw,
                _lastActivity,
                previousReference: _currentLocation,
              );
              final filtered = result.filteredLocation;
              final accuracy = filtered.accuracy;

              if (_sentInitialCurrent &&
                  _currentLocation != null &&
                  _isJumpTooLarge(_currentLocation, filtered) &&
                  accuracy > TrackingTuning.jumpGuardBadAccuracyMinM) {
                return;
              }

              _currentLocation = filtered;
              _transport = result.transport;

              if (!_currentOnly) {
                try {
                  if (_zonesInited) {
                    await _zoneMonitor?.onLocation(filtered);
                  }
                } catch (e) {
                  debugPrint(
                    'BackgroundTrackingRuntime zone monitor error: $e',
                  );
                }
              }

              final payload = TrackingPayload(
                deviceId: activeSharingUid,
                location: filtered,
                motion: result.motion.name,
                transport: _transport.name,
              );

              final nowMs = DateTime.now().millisecondsSinceEpoch;
              final rejectVeryBadAcc =
                  accuracy > TrackingTuning.currentRejectAccuracyMaxM;
              final isMoving = result.motion == MotionState.moving;
              final goodHistoryAcc =
                  accuracy <= TrackingTuning.historyGoodAccuracyMaxM;
              final shouldSendInitialCurrent =
                  !_sentInitialCurrent && !rejectVeryBadAcc;

              var sentCurrentToServer = false;
              Object? sendError;

              final currentInterval = currentPublishInterval(
                motion: result.motion,
                accuracy: accuracy,
                shouldSendInitialCurrent: shouldSendInitialCurrent,
                indoorSuppressed: result.indoorSuppressed,
              );
              final shouldAttemptCurrentSend =
                  currentInterval != null &&
                  _canAttemptSend(
                    nowMs: nowMs,
                    lastSuccessAtMs: _lastCurrentSentAtMs,
                    lastFailureAtMs: _lastCurrentFailureAtMs,
                    minSuccessInterval: currentInterval,
                  );

              if (shouldAttemptCurrentSend) {
                final resolvedCurrentInterval = currentInterval;
                if (result.indoorSuppressed && kDebugMode) {
                  debugPrint(
                    'BackgroundTrackingRuntime current update anchored due to '
                    'weak GPS acc=${accuracy.toStringAsFixed(1)} '
                    'interval=${resolvedCurrentInterval.inSeconds}s',
                  );
                }
                try {
                  await _locationRepository.updateMyCurrent(payload);
                  _lastCurrentSentAtMs = nowMs;
                  _lastCurrentFailureAtMs = 0;
                  _sentInitialCurrent = true;
                  sentCurrentToServer = true;
                } catch (e) {
                  _lastCurrentFailureAtMs = nowMs;
                  sendError = e;
                  debugPrint(
                    'BackgroundTrackingRuntime current location send failed: $e',
                  );
                }
              }

              if (!_currentOnly) {
                final historySendWindowOpen = _canAttemptSend(
                  nowMs: nowMs,
                  lastSuccessAtMs: 0,
                  lastFailureAtMs: _lastHistoryFailureAtMs,
                  minSuccessInterval: Duration.zero,
                );
                if (isMoving &&
                    goodHistoryAcc &&
                    result.indoorSuppressed &&
                    historySendWindowOpen &&
                    kDebugMode) {
                  debugPrint(
                    'BackgroundTrackingRuntime history send skipped due to '
                    'indoor suppression acc=${accuracy.toStringAsFixed(1)}',
                  );
                }

                if (isMoving &&
                    !result.indoorSuppressed &&
                    result.shouldSend &&
                    goodHistoryAcc &&
                    historySendWindowOpen) {
                  try {
                    await _locationRepository.appendMyHistory(payload);
                    _lastHistoryFailureAtMs = 0;
                    _engine.acknowledgeHistorySent(filtered, result.motion);
                  } catch (e) {
                    _lastHistoryFailureAtMs = nowMs;
                    sendError ??= e;
                    debugPrint(
                      'BackgroundTrackingRuntime history location send failed: $e',
                    );
                  }
                }
              }

              if (sentCurrentToServer) {
                final runtimeL10n = await _getL10n();
                await _reportTrackingStatusIfChanged(
                  'ok',
                  message: runtimeL10n.trackingStatusOkMessage,
                );
              }

              if (sendError != null) {
                debugPrint('BackgroundTrackingRuntime send error: $sendError');
              }
            },
            onError: (Object error, StackTrace stackTrace) {
              unawaited(_handleGpsStreamError(error, stackTrace));
            },
          );

      await TrackingRuntimeStore.setPublisherReady(true);
      return true;
    } catch (e, st) {
      debugPrint('BackgroundTrackingRuntime.start fatal error: $e');
      debugPrint('$st');
      await stop();
      return false;
    }
  }

  Future<void> stop() async {
    await TrackingRuntimeStore.setPublisherReady(false);
    _running = false;
    _currentOnly = false;
    _activeSharingUid = null;
    _lastTrackingStatus = null;
    _lastStatusHeartbeatAtMs = 0;
    _lastCurrentSentAtMs = 0;
    _lastCurrentFailureAtMs = 0;
    _lastHistoryFailureAtMs = 0;
    _sentInitialCurrent = false;
    _currentLocation = null;
    _lastActivity = null;

    _engine.reset();

    await _gpsSub?.cancel();
    await _activitySub?.cancel();
    await _zonesSub?.cancel();

    _gpsSub = null;
    _activitySub = null;
    _zonesSub = null;
    _zoneMonitor = null;
    _zonesInited = false;
    _zoneMonitorUid = null;

    _healthTimer?.cancel();
    _healthTimer = null;
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await stop();
    await _authStateSub?.cancel();
    _authStateSub = null;
  }

  String? _currentUidOrNull() {
    final uid = _auth.currentUser?.uid.trim();
    if (uid == null || uid.isEmpty) {
      return null;
    }
    return uid;
  }

  String? _requireUidOrNull() {
    final uid = _currentUidOrNull();
    if (uid == null || uid.isEmpty) {
      return null;
    }
    return uid;
  }

  void _handleAuthStateChanged(User? user) {
    if (_disposed) return;
    final nextUid = user?.uid.trim();
    final activeSharingUid = _activeSharingUid;
    if (activeSharingUid == null || nextUid == activeSharingUid) {
      return;
    }

    unawaited(stop());
  }

  Future<void> _ensureZoneMonitor(String uid) async {
    if (_disposed) return;
    if (_zonesInited && _zoneMonitorUid == uid) return;

    final repo = ZoneRepository();
    await _zonesSub?.cancel();
    if (_disposed) return;

    _zoneMonitor = ZoneMonitor(repo: repo, childUid: uid);
    _zoneMonitorUid = uid;
    _zonesSub = repo
        .watchZones(uid)
        .listen(
          (zones) => _zoneMonitor?.updateZones(zones),
          onError: (e) =>
              debugPrint('BackgroundTrackingRuntime zones watch error: $e'),
        );

    _zonesInited = true;
  }

  Future<void> _reportStartupFailure(AppLocalizations l10n) async {
    try {
      final serviceEnabled = await _locationService.isServiceEnabled();
      final permissionGranted = await _locationService.hasLocationPermission(
        requireBackground: false,
      );
      final preciseGranted = await _locationService
          .hasPreciseLocationPermission();
      final backgroundSatisfied =
          await _isBackgroundTrackingSatisfiedForStatus();

      if (!serviceEnabled) {
        await _reportTrackingStatusIfChanged(
          'location_service_off',
          message: l10n.trackingStatusLocationServiceOffMessage,
        );
        return;
      }

      if (!permissionGranted || !preciseGranted) {
        await _reportTrackingStatusIfChanged(
          'location_permission_denied',
          message: preciseGranted
              ? l10n.trackingStatusLocationPermissionDeniedMessage
              : l10n.trackingStatusPreciseLocationDeniedMessage,
        );
        return;
      }

      if (!backgroundSatisfied) {
        await _reportTrackingStatusIfChanged(
          'background_disabled',
          message: l10n.trackingStatusBackgroundDisabledMessage,
        );
      }
    } catch (e) {
      debugPrint('BackgroundTrackingRuntime startup failure report error: $e');
    }
  }

  Future<void> _reportTrackingStatusIfChanged(
    String status, {
    String? message,
    bool force = false,
  }) async {
    if (_currentOnly) return;
    if (!force && _lastTrackingStatus == status) return;
    _lastTrackingStatus = status;

    try {
      await _trackingStatusService.reportStatus(
        status: status,
        message: message,
      );
    } catch (e) {
      debugPrint('BackgroundTrackingRuntime report status error: $e');
    }
  }

  Future<void> _startHealthMonitor() async {
    if (_disposed) return;
    _healthTimer?.cancel();

    _healthTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
      if (_disposed || !_running) return;

      try {
        final l10n = await _getL10n();
        final serviceEnabled = await _locationService.isServiceEnabled();
        final permissionGranted = await _locationService.hasLocationPermission(
          requireBackground: false,
        );
        final preciseGranted = await _locationService
            .hasPreciseLocationPermission();
        final backgroundSatisfied =
            await _isBackgroundTrackingSatisfiedForStatus();

        if (!serviceEnabled) {
          await _reportTrackingStatusIfChanged(
            'location_service_off',
            message: l10n.trackingStatusLocationServiceOffMessage,
          );
          return;
        }

        if (!permissionGranted || !preciseGranted) {
          await _reportTrackingStatusIfChanged(
            'location_permission_denied',
            message: preciseGranted
                ? l10n.trackingStatusLocationPermissionDeniedMessage
                : l10n.trackingStatusPreciseLocationDeniedMessage,
          );
          return;
        }

        if (!backgroundSatisfied) {
          await _reportTrackingStatusIfChanged(
            'background_disabled',
            message: l10n.trackingStatusBackgroundDisabledMessage,
          );
          return;
        }

        final nowMs = DateTime.now().millisecondsSinceEpoch;
        final shouldHeartbeatOk =
            _lastTrackingStatus != 'ok' ||
            nowMs - _lastStatusHeartbeatAtMs >= 60000;
        if (shouldHeartbeatOk) {
          _lastStatusHeartbeatAtMs = nowMs;
          await _reportTrackingStatusIfChanged(
            'ok',
            message: l10n.trackingStatusOkMessage,
            force: true,
          );
        }
      } catch (e) {
        debugPrint('BackgroundTrackingRuntime health monitor error: $e');
      }
    });
  }

  Future<bool> _isBackgroundTrackingSatisfiedForStatus() async {
    if (!_requireBackground) {
      return true;
    }

    final serviceRunning = await TrackingBackgroundService.isRunning();
    final hasBackgroundPermission = await _locationService
        .hasBackgroundLocationPermission();

    return isBackgroundTrackingSatisfiedForStatus(
      BackgroundTrackingStatusSnapshot(
        requireBackground: _requireBackground,
        serviceRunning: serviceRunning,
        isSharing: _running,
        publishingHandledByService: true,
        hasBackgroundPermission: hasBackgroundPermission,
        backgroundModeEnabled: false,
      ),
    );
  }

  bool _canAttemptSend({
    required int nowMs,
    required int lastSuccessAtMs,
    required int lastFailureAtMs,
    required Duration minSuccessInterval,
    Duration failureBackoff = const Duration(seconds: 5),
  }) {
    final nextAfterSuccess =
        lastSuccessAtMs + minSuccessInterval.inMilliseconds;
    final nextAfterFailure = lastFailureAtMs + failureBackoff.inMilliseconds;
    return nowMs >= nextAfterSuccess && nowMs >= nextAfterFailure;
  }

  bool _isJumpTooLarge(LocationData? prev, LocationData next) {
    if (prev == null) return false;

    final dtSec = (next.timestamp - prev.timestamp) / 1000.0;
    if (dtSec <= 0) return true;

    final distanceMeters = prev.distanceTo(next) * 1000.0;
    final speedMps = distanceMeters / dtSec;
    return speedMps > 45;
  }

  Future<void> _startActivityRecognition() async {
    if (_disposed) return;
    await _activitySub?.cancel();
    _activitySub = null;
    _lastActivity = null;

    if (kDebugMode) {
      debugPrint(
        'BackgroundTrackingRuntime skipping activity recognition on '
        'headless FlutterEngine because no Activity is attached.',
      );
    }
  }

  Future<AppLocalizations> _getL10n() {
    final uid = _auth.currentUser?.uid;
    if (_l10nFuture != null && _l10nUid == uid) {
      return _l10nFuture!;
    }

    final fallbackLang =
        PlatformDispatcher.instance.locale.languageCode.toLowerCase() == 'en'
        ? 'en'
        : 'vi';
    _l10nUid = uid;
    _l10nFuture = AppLocalizationsLoader.loadForUser(
      userRepository: UserRepository.background(FirebaseFirestore.instance),
      uid: uid,
      fallbackLang: fallbackLang,
    );
    return _l10nFuture!;
  }

  bool _isLocationServiceDisabledError(Object error) {
    final normalized = error.toString().toLowerCase();
    return normalized.contains('location service on the device is disabled') ||
        normalized.contains('service_status_error') ||
        normalized.contains('location service is disabled');
  }

  Future<void> _handleGpsStreamError(
    Object error,
    StackTrace stackTrace,
  ) async {
    if (_isLocationServiceDisabledError(error)) {
      final l10n = await _getL10n();
      debugPrint(
        'BackgroundTrackingRuntime GPS stream paused because location '
        'service is disabled.',
      );
      await _reportTrackingStatusIfChanged(
        'location_service_off',
        message: l10n.trackingStatusLocationServiceOffMessage,
      );
      return;
    }

    debugPrint('BackgroundTrackingRuntime GPS stream error: $error');
    debugPrint('$stackTrace');
  }
}
