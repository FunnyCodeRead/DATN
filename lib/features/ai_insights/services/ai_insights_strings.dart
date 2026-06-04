import 'package:flutter/widgets.dart';
import 'package:kid_manager/features/ai_insights/models/ai_insight_models.dart';
import 'package:kid_manager/features/safe_route/domain/entities/safe_route_enums.dart';

class AiInsightsStrings {
  AiInsightsStrings(Locale locale)
    : _languageCode = locale.languageCode.toLowerCase();

  final String _languageCode;

  bool get isVietnamese => _languageCode.startsWith('vi');

  String screenTitle(String childName) =>
      isVietnamese ? 'Tóm tắt AI của $childName' : 'AI insights for $childName';

  String get summaryTitle => isVietnamese ? 'Tóm tắt ngày' : 'Daily summary';

  String get searchTitle =>
      isVietnamese ? 'Tìm kiếm ngôn ngữ tự nhiên' : 'Natural-language search';

  String get searchHint => isVietnamese
      ? 'Ví dụ: SOS hôm nay, ra khỏi zone, 7h sáng'
      : 'Example: SOS today, left zone, 7 AM';

  String get timelineTitle => isVietnamese ? 'Dòng sự kiện' : 'Timeline';

  String get emptyState => isVietnamese
      ? 'Chưa có đủ dữ liệu để tạo tóm tắt cho ngày này.'
      : 'Not enough data to build insights for this day.';

  String get noSearchResult => isVietnamese
      ? 'Không tìm thấy sự kiện phù hợp với truy vấn.'
      : 'No events matched the query.';

  String get loadError => isVietnamese
      ? 'Không tải được dữ liệu AI insights.'
      : 'Failed to load AI insights.';

  String get refreshLabel => isVietnamese ? 'Làm mới' : 'Refresh';

  String get allDayLabel => isVietnamese ? 'Cả ngày' : 'All day';

  String get searchActionLabel => isVietnamese ? 'Tìm' : 'Search';

  String get clearActionLabel => isVietnamese ? 'Xóa' : 'Clear';

  String get openInsightsTooltip => isVietnamese ? 'AI hỗ trợ' : 'AI insights';

  String get assistantEyebrow => isVietnamese ? 'AI hỗ trợ' : 'AI assistant';

  String get assistantSubtitle => isVietnamese
      ? 'Tổng hợp vị trí, cảnh báo và vùng an toàn trong ngày.'
      : 'Summarizes location, alerts, and safe-zone activity for the day.';

  String get changeDayLabel => isVietnamese ? 'Đổi ngày' : 'Change day';

  String get selectedDayLabel =>
      isVietnamese ? 'Ngày đang xem' : 'Selected day';

  String get keyMetricsTitle => isVietnamese ? 'Chỉ số nhanh' : 'Key signals';

  String get insightHighlightsTitle =>
      isVietnamese ? 'Điểm cần chú ý' : 'Signals to review';

  String get askAiDescription => isVietnamese
      ? 'Nhập câu hỏi hoặc chọn gợi ý để lọc nhanh dòng sự kiện.'
      : 'Ask a question or pick a prompt to filter the timeline.';

  String get quickQuestionsLabel =>
      isVietnamese ? 'Câu hỏi gợi ý' : 'Suggested questions';

  String get activityWindowLabel =>
      isVietnamese ? 'Khoảng ghi nhận' : 'Activity window';

  String get noTimeLabel => '--:--';

  String get distanceMetricLabel => isVietnamese ? 'Quãng đường' : 'Distance';

  String get tripsMetricLabel => isVietnamese ? 'Chặng' : 'Trips';

  String get stopsMetricLabel => isVietnamese ? 'Điểm dừng' : 'Stops';

  String get alertsMetricLabel => isVietnamese ? 'Cảnh báo' : 'Alerts';

  String get zonesMetricLabel => isVietnamese ? 'Sự kiện zone' : 'Zone events';

  String get routesMetricLabel => isVietnamese ? 'Safe Route' : 'Safe Route';

  String get pointsMetricLabel => isVietnamese ? 'Điểm dữ liệu' : 'Data points';

  String get loadingTitle =>
      isVietnamese ? 'AI đang tổng hợp dữ liệu' : 'AI is building the summary';

  String get loadingSubtitle => isVietnamese
      ? 'Đang đọc lịch sử vị trí, cảnh báo và zone trong ngày.'
      : 'Reading location history, alerts, and zone events for the day.';

  String get errorTitle =>
      isVietnamese ? 'Không thể tạo phân tích' : 'Unable to build insights';

  String get emptyTimelineTitle =>
      isVietnamese ? 'Chưa có sự kiện nổi bật' : 'No notable events yet';

  String timelineCountLabel(int count) {
    if (isVietnamese) return '$count sự kiện';
    return count == 1 ? '1 event' : '$count events';
  }

  String matchedTermsLabel(int count) {
    if (isVietnamese) return '$count từ khớp';
    return count == 1 ? '1 matched term' : '$count matched terms';
  }

  List<String> get suggestedQueries => isVietnamese
      ? const <String>['SOS hôm nay', 'Ra khỏi zone', 'Safe route', '7h sáng']
      : const <String>['SOS today', 'Left zone', 'Safe route', '7 AM'];

  String formatDay(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  String formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String noActivityHeadline(DateTime date) => isVietnamese
      ? 'Không có hoạt động đáng chú ý trong ${formatDay(date)}'
      : 'No meaningful activity recorded on ${formatDay(date)}';

  String noActivityNarrative(DateTime date) => isVietnamese
      ? 'Hệ thống chưa ghi nhận đủ history, alert hoặc sự kiện zone để tạo tóm tắt cho ${formatDay(date)}.'
      : 'The system did not record enough history, alerts, or zone events to summarize ${formatDay(date)}.';

  String summaryHeadline({
    required DateTime day,
    required double distanceKm,
    required int tripCount,
    required int alertCount,
  }) {
    if (isVietnamese) {
      return '${formatDay(day)}: ${distanceKm.toStringAsFixed(1)} km, $tripCount chặng, $alertCount cảnh báo';
    }
    return '${formatDay(day)}: ${distanceKm.toStringAsFixed(1)} km, $tripCount trips, $alertCount alerts';
  }

  String summaryNarrative({
    required double distanceKm,
    required int tripCount,
    required int stopCount,
    required int zoneEventCount,
    required int safeRouteCount,
    required int alertCount,
    required DateTime? firstSeenAt,
    required DateTime? lastSeenAt,
  }) {
    final firstText = firstSeenAt == null ? '--:--' : formatTime(firstSeenAt);
    final lastText = lastSeenAt == null ? '--:--' : formatTime(lastSeenAt);
    if (isVietnamese) {
      return 'Hệ thống ghi nhận từ $firstText đến $lastText, di chuyển ${distanceKm.toStringAsFixed(1)} km qua $tripCount chặng, dừng $stopCount lần, có $zoneEventCount sự kiện zone, $safeRouteCount chuyến Safe Route và $alertCount cảnh báo.';
    }
    return 'Recorded from $firstText to $lastText, ${distanceKm.toStringAsFixed(1)} km across $tripCount trips, $stopCount stops, $zoneEventCount zone events, $safeRouteCount Safe Route trips, and $alertCount alerts.';
  }

  String firstSeenHighlight(DateTime date) => isVietnamese
      ? 'Ghi nhận đầu tiên lúc ${formatTime(date)}.'
      : 'First record at ${formatTime(date)}.';

  String lastSeenHighlight(DateTime date) => isVietnamese
      ? 'Ghi nhận cuối lúc ${formatTime(date)}.'
      : 'Last record at ${formatTime(date)}.';

  String stopHighlight(int stopCount, Duration longestStop) {
    final minutes = longestStop.inMinutes;
    if (isVietnamese) {
      return 'Có $stopCount điểm dừng, lâu nhất $minutes phút.';
    }
    return '$stopCount stop points, longest stop lasted $minutes minutes.';
  }

  String zoneHighlight(AiZoneEventRecord event) {
    if (isVietnamese) {
      if (event.isEnter) {
        return 'Vào ${event.zoneType == 'danger' ? 'vùng nguy hiểm' : 'zone an toàn'} ${event.zoneName} lúc ${formatTime(event.occurredAt)}.';
      }
      return 'Rời ${event.zoneName} lúc ${formatTime(event.occurredAt)}${event.durationMinutes > 0 ? ' sau ${event.durationMinutes} phút.' : '.'}';
    }
    if (event.isEnter) {
      return 'Entered ${event.zoneType == 'danger' ? 'danger zone' : 'safe zone'} ${event.zoneName} at ${formatTime(event.occurredAt)}.';
    }
    return 'Left ${event.zoneName} at ${formatTime(event.occurredAt)}${event.durationMinutes > 0 ? ' after ${event.durationMinutes} minutes.' : '.'}';
  }

  String alertHighlight(int alertCount) => isVietnamese
      ? 'Có $alertCount cảnh báo cần xem lại.'
      : '$alertCount alerts need review.';

  String safeRouteHighlight(int safeRouteCount) => isVietnamese
      ? 'Có $safeRouteCount chuyến Safe Route trong ngày.'
      : '$safeRouteCount Safe Route trips were recorded.';

  String timelineStart(DateTime date) => isVietnamese
      ? 'Bắt đầu ghi nhận lúc ${formatTime(date)}'
      : 'Tracking started at ${formatTime(date)}';

  String timelineEnd(DateTime date) => isVietnamese
      ? 'Ghi nhận cuối lúc ${formatTime(date)}'
      : 'Last update at ${formatTime(date)}';

  String stopTitle(Duration duration) =>
      isVietnamese ? 'Dừng tại một vị trí' : 'Stopped at one location';

  String stopDescription(Duration duration, DateTime startedAt) {
    final minutes = duration.inMinutes;
    if (isVietnamese) {
      return 'Dừng khoảng $minutes phút, bắt đầu từ ${formatTime(startedAt)}.';
    }
    return 'Stopped for about $minutes minutes, starting at ${formatTime(startedAt)}.';
  }

  String zoneEnterTitle(AiZoneEventRecord event) => isVietnamese
      ? 'Vào ${event.zoneType == 'danger' ? 'vùng nguy hiểm' : 'zone an toàn'}'
      : 'Entered ${event.zoneType == 'danger' ? 'danger zone' : 'safe zone'}';

  String zoneExitTitle(AiZoneEventRecord event) =>
      isVietnamese ? 'Rời zone' : 'Exited zone';

  String zoneDescription(AiZoneEventRecord event) {
    if (isVietnamese) {
      if (event.isEnter) {
        return '${event.zoneName} lúc ${formatTime(event.occurredAt)}.';
      }
      return '${event.zoneName} lúc ${formatTime(event.occurredAt)}${event.durationMinutes > 0 ? ' sau ${event.durationMinutes} phút.' : '.'}';
    }
    if (event.isEnter) {
      return '${event.zoneName} at ${formatTime(event.occurredAt)}.';
    }
    return '${event.zoneName} at ${formatTime(event.occurredAt)}${event.durationMinutes > 0 ? ' after ${event.durationMinutes} minutes.' : '.'}';
  }

  String safeRouteTitle(String? routeName, TripStatus status) {
    final route = routeName?.trim().isNotEmpty == true
        ? routeName!.trim()
        : (isVietnamese ? 'Tuyến không tên' : 'Unnamed route');
    final label = safeRouteStatusLabel(status);
    return '$route - $label';
  }

  String safeRouteStatusLabel(TripStatus status) {
    if (isVietnamese) {
      switch (status) {
        case TripStatus.planned:
          return 'Đã lên lịch';
        case TripStatus.active:
          return 'Đang theo dõi';
        case TripStatus.temporarilyDeviated:
          return 'Lệch tạm thời';
        case TripStatus.deviated:
          return 'Lệch tuyến';
        case TripStatus.completed:
          return 'Hoàn thành';
        case TripStatus.cancelled:
          return 'Đã hủy';
      }
    }
    switch (status) {
      case TripStatus.planned:
        return 'Planned';
      case TripStatus.active:
        return 'Active';
      case TripStatus.temporarilyDeviated:
        return 'Temporarily deviated';
      case TripStatus.deviated:
        return 'Deviated';
      case TripStatus.completed:
        return 'Completed';
      case TripStatus.cancelled:
        return 'Cancelled';
    }
  }

  String safeRouteDescription(String? reason, DateTime when) {
    if (isVietnamese) {
      return reason?.trim().isNotEmpty == true
          ? '$reason · ${formatTime(when)}'
          : 'Cập nhật lúc ${formatTime(when)}.';
    }
    return reason?.trim().isNotEmpty == true
        ? '$reason · ${formatTime(when)}'
        : 'Updated at ${formatTime(when)}.';
  }

  String notificationTitle(AiInsightEventType type) {
    if (isVietnamese) {
      switch (type) {
        case AiInsightEventType.sos:
          return 'Cảnh báo SOS';
        case AiInsightEventType.batteryAlert:
          return 'Cảnh báo pin / nền';
        case AiInsightEventType.trackingAlert:
          return 'Cảnh báo theo dõi';
        default:
          return 'Cảnh báo hệ thống';
      }
    }
    switch (type) {
      case AiInsightEventType.sos:
        return 'SOS alert';
      case AiInsightEventType.batteryAlert:
        return 'Battery / background alert';
      case AiInsightEventType.trackingAlert:
        return 'Tracking alert';
      default:
        return 'System alert';
    }
  }
}
