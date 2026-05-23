import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kid_manager/features/ai_insights/data/ai_insights_data_source.dart';
import 'package:kid_manager/features/ai_insights/models/ai_insight_models.dart';
import 'package:kid_manager/features/ai_insights/services/ai_insights_query_parser.dart';
import 'package:kid_manager/features/ai_insights/services/ai_insights_search_engine.dart';
import 'package:kid_manager/features/ai_insights/services/ai_insights_strings.dart';
import 'package:kid_manager/features/ai_insights/services/ai_insights_summary_builder.dart';

class AiInsightsViewModel extends ChangeNotifier {
  AiInsightsViewModel({
    required this.childId,
    required this.childDisplayName,
    required AiInsightsDataSource dataSource,
    required AiInsightsStrings strings,
    AiInsightsQueryParser? queryParser,
    AiInsightsSearchEngine? searchEngine,
    AiInsightsSummaryBuilder? summaryBuilder,
  }) : _dataSource = dataSource,
       _strings = strings,
       _queryParser = queryParser ?? AiInsightsQueryParser(),
       _searchEngine = searchEngine ?? AiInsightsSearchEngine(),
       _summaryBuilder = summaryBuilder ?? AiInsightsSummaryBuilder(),
       _selectedDay = DateUtils.dateOnly(DateTime.now());

  final String childId;
  final String childDisplayName;
  final AiInsightsDataSource _dataSource;
  final AiInsightsStrings _strings;
  final AiInsightsQueryParser _queryParser;
  final AiInsightsSearchEngine _searchEngine;
  final AiInsightsSummaryBuilder _summaryBuilder;

  DateTime _selectedDay;
  bool _loading = false;
  String? _error;
  String _query = '';
  AiInsightsBundle? _bundle;
  AiDailySummary? _summary;
  List<AiInsightTimelineEvent> _timeline = const <AiInsightTimelineEvent>[];
  List<AiSearchResult> _searchResults = const <AiSearchResult>[];

  DateTime get selectedDay => _selectedDay;
  bool get loading => _loading;
  String? get error => _error;
  String get query => _query;
  AiDailySummary? get summary => _summary;
  List<AiInsightTimelineEvent> get timeline => List.unmodifiable(_timeline);
  List<AiSearchResult> get searchResults => List.unmodifiable(_searchResults);
  bool get hasSearchQuery => _query.trim().isNotEmpty;

  List<AiInsightTimelineEvent> get visibleTimeline => hasSearchQuery
      ? _searchResults.map((result) => result.event).toList(growable: false)
      : List.unmodifiable(_timeline);

  Future<void> loadInitial() => loadForDay(_selectedDay);

  Future<void> loadForDay(DateTime day) async {
    _selectedDay = DateUtils.dateOnly(day);
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _bundle = await _dataSource.loadChildDay(childId: childId, day: _selectedDay);
      _summary = _summaryBuilder.buildSummary(
        bundle: _bundle!,
        strings: _strings,
      );
      _timeline = _summaryBuilder.buildTimeline(
        bundle: _bundle!,
        strings: _strings,
      );
      await _runSearchInternal(_query, allowDayShift: false);
    } catch (error, stackTrace) {
      debugPrint('[AiInsightsViewModel] loadForDay failed: $error');
      debugPrint('$stackTrace');
      _error = _strings.loadError;
      _summary = null;
      _timeline = const <AiInsightTimelineEvent>[];
      _searchResults = const <AiSearchResult>[];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> runSearch(String rawQuery) async {
    await _runSearchInternal(rawQuery, allowDayShift: true);
    notifyListeners();
  }

  Future<void> clearSearch() async {
    _query = '';
    _searchResults = const <AiSearchResult>[];
    notifyListeners();
  }

  Future<void> _runSearchInternal(
    String rawQuery, {
    required bool allowDayShift,
  }) async {
    _query = rawQuery.trim();
    if (_query.isEmpty) {
      _searchResults = const <AiSearchResult>[];
      return;
    }

    final parsed = _queryParser.parse(_query);
    if (allowDayShift && parsed.dayOffset != 0) {
      final targetDay = DateUtils.dateOnly(
        DateTime.now().add(Duration(days: parsed.dayOffset)),
      );
      if (!DateUtils.isSameDay(targetDay, _selectedDay)) {
        await loadForDay(targetDay);
      }
    }

    _searchResults = _searchEngine.search(
      events: _timeline,
      query: parsed,
    );
  }
}

