import 'package:kid_manager/features/ai_insights/models/ai_insight_models.dart';
import 'package:kid_manager/features/ai_insights/services/ai_insights_query_parser.dart';

class AiInsightsSearchEngine {
  List<AiSearchResult> search({
    required List<AiInsightTimelineEvent> events,
    required AiSearchQuery query,
  }) {
    if (query.isEmpty) {
      return const <AiSearchResult>[];
    }

    final results = <AiSearchResult>[];
    for (final event in events) {
      final matchedTerms = <String>[];
      var score = 0;

      if (query.includeTypes.isNotEmpty) {
        if (!query.includeTypes.contains(event.type)) {
          continue;
        }
        score += 5;
      }

      if (query.startMinute != null && query.endMinute != null) {
        final minute = (event.occurredAt.hour * 60) + event.occurredAt.minute;
        if (minute < query.startMinute! || minute > query.endMinute!) {
          continue;
        }
        score += 3;
      }

      final normalizedContent = AiInsightsQueryParser.normalize(
        '${event.title} ${event.description} ${event.keywords.join(' ')}',
      );
      if (query.terms.isNotEmpty) {
        for (final term in query.terms) {
          if (normalizedContent.contains(term)) {
            matchedTerms.add(term);
            score += 4;
          }
        }
        if (matchedTerms.isEmpty) {
          continue;
        }
      }

      if (score <= 0) {
        continue;
      }

      results.add(
        AiSearchResult(event: event, score: score, matchedTerms: matchedTerms),
      );
    }

    results.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return b.event.occurredAt.compareTo(a.event.occurredAt);
    });
    return results;
  }
}

