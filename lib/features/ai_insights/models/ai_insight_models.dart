import 'package:kid_manager/features/safe_route/domain/entities/trip.dart';
import 'package:kid_manager/models/location/location_data.dart';
import 'package:kid_manager/models/notifications/app_notification.dart';

enum AiInsightEventType {
  dayStart,
  dayEnd,
  locationStop,
  zoneEnter,
  zoneExit,
  safeRoute,
  sos,
  trackingAlert,
  batteryAlert,
  info,
}

enum AiInsightSeverity { info, warning, critical }

class AiZoneEventRecord {
  const AiZoneEventRecord({
    required this.id,
    required this.zoneId,
    required this.zoneName,
    required this.zoneType,
    required this.action,
    required this.timestamp,
    required this.durationMinutes,
  });

  final String id;
  final String zoneId;
  final String zoneName;
  final String zoneType;
  final String action;
  final int timestamp;
  final int durationMinutes;

  DateTime get occurredAt => DateTime.fromMillisecondsSinceEpoch(timestamp);

  bool get isEnter => action == 'enter';
  bool get isExit => action == 'exit';
  bool get isDangerZone => zoneType == 'danger';
}

class AiInsightsBundle {
  const AiInsightsBundle({
    required this.date,
    required this.history,
    required this.zoneEvents,
    required this.alerts,
    required this.safeRouteTrips,
  });

  final DateTime date;
  final List<LocationData> history;
  final List<AiZoneEventRecord> zoneEvents;
  final List<AppNotification> alerts;
  final List<Trip> safeRouteTrips;
}

class AiInsightTimelineEvent {
  const AiInsightTimelineEvent({
    required this.id,
    required this.occurredAt,
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    this.keywords = const <String>[],
  });

  final String id;
  final DateTime occurredAt;
  final AiInsightEventType type;
  final AiInsightSeverity severity;
  final String title;
  final String description;
  final List<String> keywords;
}

class AiDailySummary {
  const AiDailySummary({
    required this.headline,
    required this.narrative,
    required this.highlights,
    required this.distanceKm,
    required this.tripCount,
    required this.stopCount,
    required this.alertCount,
    required this.zoneEventCount,
    required this.safeRouteCount,
    required this.pointCount,
    required this.firstSeenAt,
    required this.lastSeenAt,
  });

  final String headline;
  final String narrative;
  final List<String> highlights;
  final double distanceKm;
  final int tripCount;
  final int stopCount;
  final int alertCount;
  final int zoneEventCount;
  final int safeRouteCount;
  final int pointCount;
  final DateTime? firstSeenAt;
  final DateTime? lastSeenAt;
}

class AiSearchQuery {
  const AiSearchQuery({
    required this.raw,
    required this.normalized,
    required this.dayOffset,
    required this.startMinute,
    required this.endMinute,
    required this.includeTypes,
    required this.terms,
  });

  final String raw;
  final String normalized;
  final int dayOffset;
  final int? startMinute;
  final int? endMinute;
  final Set<AiInsightEventType> includeTypes;
  final List<String> terms;

  bool get isEmpty => raw.trim().isEmpty;
}

class AiSearchResult {
  const AiSearchResult({
    required this.event,
    required this.score,
    required this.matchedTerms,
  });

  final AiInsightTimelineEvent event;
  final int score;
  final List<String> matchedTerms;
}

