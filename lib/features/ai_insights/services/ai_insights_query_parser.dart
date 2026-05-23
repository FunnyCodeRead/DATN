import 'package:kid_manager/features/ai_insights/models/ai_insight_models.dart';

class AiInsightsQueryParser {
  static const Set<String> _stopWords = <String>{
    'ai',
    'cho',
    'toi',
    'moi',
    'tim',
    'kiem',
    'va',
    'the',
    'cac',
    'su',
    'kien',
    'lich',
    'event',
    'events',
    'search',
    'for',
    'a',
    'an',
    'of',
    'is',
    'la',
    'di',
    'cua',
    'trong',
    'ngay',
    'nay',
  };

  AiSearchQuery parse(String raw) {
    final normalized = normalize(raw);
    final terms = normalized
        .split(RegExp(r'[^a-z0-9]+'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty && !_stopWords.contains(value))
        .toList(growable: false);

    final includeTypes = <AiInsightEventType>{};
    if (_containsAny(normalized, const <String>[
      'sos',
      'khan cap',
      'emergency',
    ])) {
      includeTypes.add(AiInsightEventType.sos);
    }
    if (_containsAny(normalized, const <String>[
      'zone',
      'vung',
      'safe zone',
      'danger zone',
    ])) {
      includeTypes.addAll(const <AiInsightEventType>{
        AiInsightEventType.zoneEnter,
        AiInsightEventType.zoneExit,
      });
    }
    if (_containsAny(normalized, const <String>[
      'ra khoi',
      'roi khoi',
      'left zone',
      'exit',
    ])) {
      includeTypes
        ..remove(AiInsightEventType.zoneEnter)
        ..add(AiInsightEventType.zoneExit);
    }
    if (_containsAny(normalized, const <String>['vao', 'entered', 'enter'])) {
      includeTypes
        ..remove(AiInsightEventType.zoneExit)
        ..add(AiInsightEventType.zoneEnter);
    }
    if (_containsAny(normalized, const <String>[
      'safe route',
      'tuyen an toan',
      'route',
    ])) {
      includeTypes.add(AiInsightEventType.safeRoute);
    }
    if (_containsAny(normalized, const <String>['battery', 'pin'])) {
      includeTypes.add(AiInsightEventType.batteryAlert);
    }
    if (_containsAny(normalized, const <String>[
      'tracking',
      'canh bao',
      'alert',
    ])) {
      includeTypes.add(AiInsightEventType.trackingAlert);
    }
    if (_containsAny(normalized, const <String>['dung', 'stop'])) {
      includeTypes.add(AiInsightEventType.locationStop);
    }

    var dayOffset = 0;
    if (_containsAny(normalized, const <String>['hom qua', 'yesterday'])) {
      dayOffset = -1;
    } else if (_containsAny(normalized, const <String>[
      'hom kia',
      'two days ago',
    ])) {
      dayOffset = -2;
    }

    final timeWindow = _parseTimeWindow(normalized);
    return AiSearchQuery(
      raw: raw,
      normalized: normalized,
      dayOffset: dayOffset,
      startMinute: timeWindow?.$1,
      endMinute: timeWindow?.$2,
      includeTypes: includeTypes,
      terms: terms,
    );
  }

  static String normalize(String input) {
    final lower = input.toLowerCase().trim();
    return lower
        .replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a')
        .replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e')
        .replaceAll(RegExp(r'[ìíịỉĩ]'), 'i')
        .replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o')
        .replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u')
        .replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y')
        .replaceAll(RegExp(r'[đ]'), 'd');
  }

  static bool _containsAny(String haystack, List<String> needles) {
    for (final needle in needles) {
      if (haystack.contains(needle)) {
        return true;
      }
    }
    return false;
  }

  static (int, int)? _parseTimeWindow(String normalized) {
    final match = RegExp(
      r'\b([01]?\d|2[0-3])(?:[:h\. ]([0-5]\d))?(?:\s*(sang|chieu|toi|am|pm))?\b',
    ).firstMatch(normalized);
    if (match == null) return null;

    var hour = int.tryParse(match.group(1) ?? '') ?? 0;
    final minute = int.tryParse(match.group(2) ?? '') ?? 0;
    final suffix = match.group(3) ?? '';

    if ((suffix == 'chieu' || suffix == 'toi' || suffix == 'pm') && hour < 12) {
      hour += 12;
    }

    final center = (hour * 60) + minute;
    final start = (center - 45).clamp(0, (24 * 60) - 1);
    final end = (center + 45).clamp(0, (24 * 60) - 1);
    return (start, end);
  }
}
