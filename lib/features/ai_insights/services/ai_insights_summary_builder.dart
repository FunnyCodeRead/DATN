import 'package:kid_manager/features/ai_insights/models/ai_insight_models.dart';
import 'package:kid_manager/features/ai_insights/services/ai_insights_strings.dart';
import 'package:kid_manager/features/safe_route/domain/entities/safe_route_enums.dart';
import 'package:kid_manager/features/safe_route/domain/entities/trip.dart';
import 'package:kid_manager/models/location/location_data.dart';
import 'package:kid_manager/models/notifications/app_notification.dart';
import 'package:kid_manager/utils/location_history_analyzer.dart';

class AiInsightsSummaryBuilder {
  static const double _stopRadiusMeters = 35;
  static const double _stopSpeedThresholdKmh = 3;
  static const int _minStopDurationMs = 5 * 60 * 1000;

  AiDailySummary buildSummary({
    required AiInsightsBundle bundle,
    required AiInsightsStrings strings,
  }) {
    final history = [...bundle.history]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    if (history.isEmpty &&
        bundle.zoneEvents.isEmpty &&
        bundle.alerts.isEmpty &&
        bundle.safeRouteTrips.isEmpty) {
      return AiDailySummary(
        headline: strings.noActivityHeadline(bundle.date),
        narrative: strings.noActivityNarrative(bundle.date),
        highlights: const <String>[],
        distanceKm: 0,
        tripCount: 0,
        stopCount: 0,
        alertCount: 0,
        zoneEventCount: 0,
        safeRouteCount: 0,
        pointCount: 0,
        firstSeenAt: null,
        lastSeenAt: null,
      );
    }

    final metrics = LocationHistoryAnalyzer.summarize(history);
    final stops = _extractStops(history);
    final firstSeenAt = history.isEmpty
        ? null
        : DateTime.fromMillisecondsSinceEpoch(history.first.timestamp);
    final lastSeenAt = history.isEmpty
        ? null
        : DateTime.fromMillisecondsSinceEpoch(history.last.timestamp);

    final highlights = <String>[];
    if (firstSeenAt != null) {
      highlights.add(strings.firstSeenHighlight(firstSeenAt));
    }
    if (lastSeenAt != null && lastSeenAt != firstSeenAt) {
      highlights.add(strings.lastSeenHighlight(lastSeenAt));
    }
    if (stops.isNotEmpty) {
      final longest = stops
          .map((stop) => stop.duration)
          .fold(Duration.zero, (best, next) => next > best ? next : best);
      highlights.add(strings.stopHighlight(stops.length, longest));
    }
    if (bundle.zoneEvents.isNotEmpty) {
      highlights.add(strings.zoneHighlight(bundle.zoneEvents.first));
    }
    if (bundle.alerts.isNotEmpty) {
      highlights.add(strings.alertHighlight(bundle.alerts.length));
    }
    if (bundle.safeRouteTrips.isNotEmpty) {
      highlights.add(strings.safeRouteHighlight(bundle.safeRouteTrips.length));
    }

    return AiDailySummary(
      headline: strings.summaryHeadline(
        day: bundle.date,
        distanceKm: metrics.trips.totalDistanceKm,
        tripCount: metrics.trips.count,
        alertCount: bundle.alerts.length,
      ),
      narrative: strings.summaryNarrative(
        distanceKm: metrics.trips.totalDistanceKm,
        tripCount: metrics.trips.count,
        stopCount: stops.length,
        zoneEventCount: bundle.zoneEvents.length,
        safeRouteCount: bundle.safeRouteTrips.length,
        alertCount: bundle.alerts.length,
        firstSeenAt: firstSeenAt,
        lastSeenAt: lastSeenAt,
      ),
      highlights: highlights,
      distanceKm: metrics.trips.totalDistanceKm,
      tripCount: metrics.trips.count,
      stopCount: stops.length,
      alertCount: bundle.alerts.length,
      zoneEventCount: bundle.zoneEvents.length,
      safeRouteCount: bundle.safeRouteTrips.length,
      pointCount: bundle.history.length,
      firstSeenAt: firstSeenAt,
      lastSeenAt: lastSeenAt,
    );
  }

  List<AiInsightTimelineEvent> buildTimeline({
    required AiInsightsBundle bundle,
    required AiInsightsStrings strings,
  }) {
    final history = [...bundle.history]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final stops = _extractStops(history);
    final timeline = <AiInsightTimelineEvent>[];

    if (history.isNotEmpty) {
      final first = history.first;
      final last = history.last;
      timeline.add(
        AiInsightTimelineEvent(
          id: 'day_start_${first.timestamp}',
          occurredAt: DateTime.fromMillisecondsSinceEpoch(first.timestamp),
          type: AiInsightEventType.dayStart,
          severity: AiInsightSeverity.info,
          title: strings.timelineStart(
            DateTime.fromMillisecondsSinceEpoch(first.timestamp),
          ),
          description: strings.firstSeenHighlight(
            DateTime.fromMillisecondsSinceEpoch(first.timestamp),
          ),
          keywords: const <String>['start', 'bat dau', 'history'],
        ),
      );
      if (last.timestamp != first.timestamp) {
        timeline.add(
          AiInsightTimelineEvent(
            id: 'day_end_${last.timestamp}',
            occurredAt: DateTime.fromMillisecondsSinceEpoch(last.timestamp),
            type: AiInsightEventType.dayEnd,
            severity: AiInsightSeverity.info,
            title: strings.timelineEnd(
              DateTime.fromMillisecondsSinceEpoch(last.timestamp),
            ),
            description: strings.lastSeenHighlight(
              DateTime.fromMillisecondsSinceEpoch(last.timestamp),
            ),
            keywords: const <String>['end', 'cuoi ngay', 'history'],
          ),
        );
      }
    }

    for (final stop in stops) {
      timeline.add(
        AiInsightTimelineEvent(
          id: 'stop_${stop.start.timestamp}_${stop.end.timestamp}',
          occurredAt: DateTime.fromMillisecondsSinceEpoch(stop.start.timestamp),
          type: AiInsightEventType.locationStop,
          severity: AiInsightSeverity.info,
          title: strings.stopTitle(stop.duration),
          description: strings.stopDescription(
            stop.duration,
            DateTime.fromMillisecondsSinceEpoch(stop.start.timestamp),
          ),
          keywords: const <String>['stop', 'dung', 'stationary'],
        ),
      );
    }

    for (final event in bundle.zoneEvents) {
      final type = event.isEnter
          ? AiInsightEventType.zoneEnter
          : AiInsightEventType.zoneExit;
      timeline.add(
        AiInsightTimelineEvent(
          id: 'zone_${event.id}',
          occurredAt: event.occurredAt,
          type: type,
          severity: event.isDangerZone
              ? AiInsightSeverity.warning
              : AiInsightSeverity.info,
          title: event.isEnter
              ? strings.zoneEnterTitle(event)
              : strings.zoneExitTitle(event),
          description: strings.zoneDescription(event),
          keywords: <String>[
            'zone',
            event.zoneName.toLowerCase(),
            event.zoneType,
            event.action,
          ],
        ),
      );
    }

    for (final trip in bundle.safeRouteTrips) {
      timeline.add(_mapTrip(trip, strings));
    }

    for (final alert in bundle.alerts) {
      final mapped = _mapAlert(alert, strings);
      if (mapped != null) {
        timeline.add(mapped);
      }
    }

    timeline.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return timeline;
  }

  AiInsightTimelineEvent _mapTrip(Trip trip, AiInsightsStrings strings) {
    final severity = switch (trip.status) {
      TripStatus.deviated || TripStatus.temporarilyDeviated =>
        AiInsightSeverity.warning,
      TripStatus.cancelled => AiInsightSeverity.warning,
      _ => AiInsightSeverity.info,
    };

    return AiInsightTimelineEvent(
      id: 'safe_route_${trip.id}',
      occurredAt: trip.updatedAt,
      type: AiInsightEventType.safeRoute,
      severity: severity,
      title: strings.safeRouteTitle(trip.routeName, trip.status),
      description: strings.safeRouteDescription(trip.reason, trip.updatedAt),
      keywords: <String>[
        'safe',
        'safe route',
        'route',
        trip.status.name,
        if (trip.routeName?.trim().isNotEmpty == true)
          trip.routeName!.toLowerCase(),
      ],
    );
  }

  AiInsightTimelineEvent? _mapAlert(
    AppNotification alert,
    AiInsightsStrings strings,
  ) {
    final type = alert.type.toLowerCase();
    final occurredAt = alert.createdAt ?? DateTime.now();
    if (type == 'sos') {
      return AiInsightTimelineEvent(
        id: 'alert_${alert.id}',
        occurredAt: occurredAt,
        type: AiInsightEventType.sos,
        severity: AiInsightSeverity.critical,
        title: strings.notificationTitle(AiInsightEventType.sos),
        description: '${alert.title}\n${alert.body}'.trim(),
        keywords: const <String>['sos', 'emergency', 'khan cap'],
      );
    }
    if (type == 'battery') {
      return AiInsightTimelineEvent(
        id: 'alert_${alert.id}',
        occurredAt: occurredAt,
        type: AiInsightEventType.batteryAlert,
        severity: AiInsightSeverity.warning,
        title: strings.notificationTitle(AiInsightEventType.batteryAlert),
        description: '${alert.title}\n${alert.body}'.trim(),
        keywords: const <String>['battery', 'pin', 'background'],
      );
    }
    if (type == 'tracking' || type == 'tracking_status') {
      return AiInsightTimelineEvent(
        id: 'alert_${alert.id}',
        occurredAt: occurredAt,
        type: AiInsightEventType.trackingAlert,
        severity: AiInsightSeverity.warning,
        title: alert.title.trim().isNotEmpty
            ? alert.title
            : strings.notificationTitle(AiInsightEventType.trackingAlert),
        description: alert.body.trim().isNotEmpty
            ? alert.body
            : strings.notificationTitle(AiInsightEventType.trackingAlert),
        keywords: <String>[
          'tracking',
          'alert',
          'canh bao',
          if (alert.title.trim().isNotEmpty) alert.title.toLowerCase(),
          if (alert.body.trim().isNotEmpty) alert.body.toLowerCase(),
        ],
      );
    }
    return null;
  }

  List<_StopSegment> _extractStops(List<LocationData> points) {
    if (points.length < 2) {
      return const <_StopSegment>[];
    }

    final sorted = [...points]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final stops = <_StopSegment>[];
    var index = 0;

    while (index < sorted.length - 1) {
      final anchor = sorted[index];
      if (anchor.speedKmh > _stopSpeedThresholdKmh) {
        index++;
        continue;
      }

      var endIndex = index;
      while (endIndex + 1 < sorted.length) {
        final next = sorted[endIndex + 1];
        final distanceMeters = anchor.distanceTo(next) * 1000;
        if (distanceMeters > _stopRadiusMeters ||
            next.speedKmh > _stopSpeedThresholdKmh) {
          break;
        }
        endIndex++;
      }

      final durationMs = sorted[endIndex].timestamp - anchor.timestamp;
      if (durationMs >= _minStopDurationMs) {
        stops.add(
          _StopSegment(
            start: anchor,
            end: sorted[endIndex],
            duration: Duration(milliseconds: durationMs),
          ),
        );
        index = endIndex + 1;
        continue;
      }

      index++;
    }

    return stops;
  }
}

class _StopSegment {
  const _StopSegment({
    required this.start,
    required this.end,
    required this.duration,
  });

  final LocationData start;
  final LocationData end;
  final Duration duration;
}

