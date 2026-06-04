import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:kid_manager/features/ai_insights/models/ai_insight_models.dart';
import 'package:kid_manager/features/safe_route/data/datasources/safe_route_remote_data_source.dart';
import 'package:kid_manager/features/safe_route/domain/entities/trip.dart';
import 'package:kid_manager/models/location/location_data.dart';
import 'package:kid_manager/models/notifications/app_notification.dart';
import 'package:kid_manager/viewmodels/location/parent_location_vm.dart';

class AiInsightsDataSource {
  AiInsightsDataSource({
    required ParentLocationVm parentLocationVm,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    SafeRouteRemoteDataSource? safeRouteRemoteDataSource,
  }) : _parentLocationVm = parentLocationVm,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _safeRouteRemoteDataSource =
           safeRouteRemoteDataSource ?? FirebaseSafeRouteRemoteDataSource();

  final ParentLocationVm _parentLocationVm;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final SafeRouteRemoteDataSource _safeRouteRemoteDataSource;

  Future<AiInsightsBundle> loadChildDay({
    required String childId,
    required DateTime day,
  }) async {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final historyFuture = _parentLocationVm.loadLocationHistoryByDay(
      childId,
      dayStart,
    );
    final zoneEventsFuture = _loadZoneEvents(
      childId: childId,
      dayStart: dayStart,
      dayEnd: dayEnd,
    );
    final alertsFuture = _loadAlerts(
      childId: childId,
      dayStart: dayStart,
      dayEnd: dayEnd,
    );
    final safeRouteTripsFuture = _loadSafeRouteTrips(
      childId: childId,
      dayStart: dayStart,
      dayEnd: dayEnd,
    );

    final resolved = await Future.wait<Object>(<Future<Object>>[
      historyFuture,
      zoneEventsFuture,
      alertsFuture,
      safeRouteTripsFuture,
    ]);

    return AiInsightsBundle(
      date: dayStart,
      history: (resolved[0] as List).cast<LocationData>(),
      zoneEvents: (resolved[1] as List).cast<AiZoneEventRecord>(),
      alerts: (resolved[2] as List).cast<AppNotification>(),
      safeRouteTrips: (resolved[3] as List).cast<Trip>(),
    );
  }

  Future<List<AiZoneEventRecord>> _loadZoneEvents({
    required String childId,
    required DateTime dayStart,
    required DateTime dayEnd,
  }) async {
    final viewerUid = _auth.currentUser?.uid;
    if (viewerUid == null || viewerUid.isEmpty) {
      return const <AiZoneEventRecord>[];
    }

    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('receiverId', isEqualTo: viewerUid)
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart),
          )
          .where('createdAt', isLessThan: Timestamp.fromDate(dayEnd))
          .orderBy('createdAt', descending: true)
          .limit(200)
          .get();

      final events = <AiZoneEventRecord>[];
      for (final doc in snapshot.docs) {
        final item = AppNotification.fromMap(
          doc.id,
          doc.data(),
          store: NotificationStore.global,
        );
        if (item.notificationType != NotificationType.zone) continue;
        if (!_matchesChild(item, childId)) continue;

        final event = _zoneEventFromNotification(item);
        if (event == null) continue;
        if (event.timestamp < dayStart.millisecondsSinceEpoch ||
            event.timestamp >= dayEnd.millisecondsSinceEpoch) {
          continue;
        }
        events.add(event);
      }

      events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return events;
    } catch (error, stackTrace) {
      debugPrint('[AiInsightsDataSource] zone events load failed: $error');
      debugPrint('$stackTrace');
      return const <AiZoneEventRecord>[];
    }
  }

  AiZoneEventRecord? _zoneEventFromNotification(AppNotification item) {
    final data = item.data;
    final timestamp = int.tryParse((data['timestamp'] ?? '').toString()) ?? 0;
    if (timestamp <= 0) return null;

    final action = (data['action'] ?? '').toString().trim().toLowerCase();
    if (action != 'enter' && action != 'exit') return null;

    final zoneName = (data['zoneName'] ?? item.body).toString().trim();
    if (zoneName.isEmpty) return null;

    final zoneType = (data['zoneType'] ?? 'safe')
        .toString()
        .trim()
        .toLowerCase();
    final durationMinutes =
        int.tryParse((data['durationMin'] ?? '').toString()) ?? 0;

    return AiZoneEventRecord(
      id: (data['eventId'] ?? item.id).toString(),
      zoneId: (data['zoneId'] ?? '').toString(),
      zoneName: zoneName,
      zoneType: zoneType == 'danger' ? 'danger' : 'safe',
      action: action,
      timestamp: timestamp,
      durationMinutes: durationMinutes,
    );
  }

  Future<List<AppNotification>> _loadAlerts({
    required String childId,
    required DateTime dayStart,
    required DateTime dayEnd,
  }) async {
    final viewerUid = _auth.currentUser?.uid;
    if (viewerUid == null || viewerUid.isEmpty) {
      return const <AppNotification>[];
    }

    try {
      final query = await _firestore
          .collection('users')
          .doc(viewerUid)
          .collection('notifications')
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart),
          )
          .where('createdAt', isLessThan: Timestamp.fromDate(dayEnd))
          .orderBy('createdAt', descending: true)
          .limit(200)
          .get();

      final items = query.docs
          .map(
            (doc) => AppNotification.fromMap(
              doc.id,
              doc.data(),
              store: NotificationStore.userInbox,
            ),
          )
          .where((item) => _matchesChild(item, childId))
          .where(_isRelevantAlert)
          .toList(growable: false);
      return items;
    } catch (error, stackTrace) {
      debugPrint('[AiInsightsDataSource] alerts load failed: $error');
      debugPrint('$stackTrace');
      return const <AppNotification>[];
    }
  }

  bool _matchesChild(AppNotification item, String childId) {
    final candidates = <String?>[
      item.childId,
      item.data['childUid']?.toString(),
      item.data['createdByUid']?.toString(),
      item.data['createdBy']?.toString(),
      item.data['uid']?.toString(),
    ];
    for (final candidate in candidates) {
      if (candidate?.trim() == childId) {
        return true;
      }
    }
    return false;
  }

  bool _isRelevantAlert(AppNotification item) {
    final type = item.type.toLowerCase();
    if (type == 'zone') return false;
    return type == 'sos' ||
        type == 'tracking' ||
        type == 'tracking_status' ||
        type == 'battery';
  }

  Future<List<Trip>> _loadSafeRouteTrips({
    required String childId,
    required DateTime dayStart,
    required DateTime dayEnd,
  }) async {
    try {
      final trips = await _safeRouteRemoteDataSource.getTripHistoryByChildId(
        childId,
      );
      return trips
          .where((trip) => _tripTouchesDay(trip, dayStart, dayEnd))
          .cast<Trip>()
          .toList(growable: false);
    } catch (error, stackTrace) {
      debugPrint(
        '[AiInsightsDataSource] safe route history load failed: $error',
      );
      debugPrint('$stackTrace');
      return const <Trip>[];
    }
  }

  bool _tripTouchesDay(Trip trip, DateTime dayStart, DateTime dayEnd) {
    final started = trip.startedAt;
    final updated = trip.updatedAt;
    if ((started.isAtSameMomentAs(dayStart) || started.isAfter(dayStart)) &&
        started.isBefore(dayEnd)) {
      return true;
    }
    if ((updated.isAtSameMomentAs(dayStart) || updated.isAfter(dayStart)) &&
        updated.isBefore(dayEnd)) {
      return true;
    }
    final scheduled = trip.scheduledStartAt;
    if (scheduled != null &&
        (scheduled.isAtSameMomentAs(dayStart) || scheduled.isAfter(dayStart)) &&
        scheduled.isBefore(dayEnd)) {
      return true;
    }
    return started.isBefore(dayStart) && updated.isAfter(dayStart);
  }
}
