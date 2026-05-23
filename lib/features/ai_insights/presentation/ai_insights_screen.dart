import 'package:flutter/material.dart';
import 'package:kid_manager/features/ai_insights/data/ai_insights_data_source.dart';
import 'package:kid_manager/features/ai_insights/models/ai_insight_models.dart';
import 'package:kid_manager/features/ai_insights/services/ai_insights_strings.dart';
import 'package:kid_manager/features/ai_insights/viewmodels/ai_insights_view_model.dart';
import 'package:kid_manager/viewmodels/location/parent_location_vm.dart';
import 'package:provider/provider.dart';

class AiInsightsScreen extends StatelessWidget {
  const AiInsightsScreen({
    super.key,
    required this.childId,
    required this.childDisplayName,
    this.childAvatarUrl,
  });

  final String childId;
  final String childDisplayName;
  final String? childAvatarUrl;

  @override
  Widget build(BuildContext context) {
    final strings = AiInsightsStrings(Localizations.localeOf(context));
    return ChangeNotifierProvider(
      create: (context) => AiInsightsViewModel(
        childId: childId,
        childDisplayName: childDisplayName,
        dataSource: AiInsightsDataSource(
          parentLocationVm: context.read<ParentLocationVm>(),
        ),
        strings: strings,
      )..loadInitial(),
      child: _AiInsightsBody(
        childDisplayName: childDisplayName,
        childAvatarUrl: childAvatarUrl,
        strings: strings,
      ),
    );
  }
}

class _AiInsightsBody extends StatefulWidget {
  const _AiInsightsBody({
    required this.childDisplayName,
    required this.childAvatarUrl,
    required this.strings,
  });

  final String childDisplayName;
  final String? childAvatarUrl;
  final AiInsightsStrings strings;

  @override
  State<_AiInsightsBody> createState() => _AiInsightsBodyState();
}

class _AiInsightsBodyState extends State<_AiInsightsBody> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDay(BuildContext context, AiInsightsViewModel vm) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.selectedDay,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    await vm.loadForDay(picked);
  }

  Future<void> _submitSearch(AiInsightsViewModel vm, String query) async {
    await vm.runSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AiInsightsViewModel>(
      builder: (context, vm, _) {
        final summary = vm.summary;
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.strings.screenTitle(widget.childDisplayName)),
            actions: [
              IconButton(
                tooltip: widget.strings.refreshLabel,
                onPressed: vm.loading ? null : () => vm.loadForDay(vm.selectedDay),
                icon: const Icon(Icons.refresh_rounded),
              ),
              IconButton(
                onPressed: vm.loading ? null : () => _pickDay(context, vm),
                icon: const Icon(Icons.calendar_today_rounded),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => vm.loadForDay(vm.selectedDay),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _HeaderCard(
                  childDisplayName: widget.childDisplayName,
                  childAvatarUrl: widget.childAvatarUrl,
                  dayLabel: widget.strings.formatDay(vm.selectedDay),
                ),
                const SizedBox(height: 16),
                if (vm.loading && summary == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  _SummaryCard(strings: widget.strings, summary: summary),
                  const SizedBox(height: 16),
                  _SearchCard(
                    strings: widget.strings,
                    controller: _controller,
                    onSubmit: (query) => _submitSearch(vm, query),
                    onClear: () async {
                      _controller.clear();
                      await vm.clearSearch();
                    },
                  ),
                  const SizedBox(height: 16),
                  if (vm.error != null)
                    _MessageCard(
                      icon: Icons.error_outline_rounded,
                      message: vm.error!,
                    )
                  else if (!vm.hasSearchQuery && vm.visibleTimeline.isEmpty)
                    _MessageCard(
                      icon: Icons.auto_awesome_outlined,
                      message: widget.strings.emptyState,
                    )
                  else if (vm.hasSearchQuery && vm.visibleTimeline.isEmpty)
                    _MessageCard(
                      icon: Icons.search_off_rounded,
                      message: widget.strings.noSearchResult,
                    )
                  else
                    _TimelineSection(
                      strings: widget.strings,
                      searchResults: vm.searchResults,
                      events: vm.visibleTimeline,
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.childDisplayName,
    required this.childAvatarUrl,
    required this.dayLabel,
  });

  final String childDisplayName;
  final String? childAvatarUrl;
  final String dayLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withOpacity(0.65),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: scheme.primary,
            backgroundImage:
                childAvatarUrl?.trim().isNotEmpty == true ? NetworkImage(childAvatarUrl!) : null,
            child: childAvatarUrl?.trim().isNotEmpty == true
                ? null
                : Text(
                    childDisplayName.trim().isEmpty
                        ? '?'
                        : childDisplayName.trim()[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  childDisplayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  dayLabel,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.strings, required this.summary});

  final AiInsightsStrings strings;
  final AiDailySummary? summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final resolved = summary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.summaryTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          if (resolved == null)
            Text(strings.emptyState)
          else ...[
            Text(
              resolved.headline,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(resolved.narrative),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricChip(label: '${resolved.distanceKm.toStringAsFixed(1)} km'),
                _MetricChip(
                  label: strings.isVietnamese
                      ? '${resolved.tripCount} chang'
                      : '${resolved.tripCount} trips',
                ),
                _MetricChip(
                  label: strings.isVietnamese
                      ? '${resolved.stopCount} diem dung'
                      : '${resolved.stopCount} stops',
                ),
                _MetricChip(
                  label: strings.isVietnamese
                      ? '${resolved.alertCount} canh bao'
                      : '${resolved.alertCount} alerts',
                ),
                _MetricChip(
                  label: strings.isVietnamese
                      ? '${resolved.zoneEventCount} zone'
                      : '${resolved.zoneEventCount} zones',
                ),
                _MetricChip(
                  label: strings.isVietnamese
                      ? '${resolved.safeRouteCount} tuyen'
                      : '${resolved.safeRouteCount} routes',
                ),
              ],
            ),
            if (resolved.highlights.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (final item in resolved.highlights)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 3),
                        child: Icon(Icons.bolt_rounded, size: 14),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item)),
                    ],
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.strings,
    required this.controller,
    required this.onSubmit,
    required this.onClear,
  });

  final AiInsightsStrings strings;
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.searchTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: onSubmit,
            decoration: InputDecoration(
              hintText: strings.searchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: strings.searchActionLabel,
                    onPressed: () => onSubmit(controller.text),
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ),
                  IconButton(
                    tooltip: strings.clearActionLabel,
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: strings.suggestedQueries
                .map(
                  (query) => ActionChip(
                    label: Text(query),
                    onPressed: () {
                      controller.text = query;
                      onSubmit(query);
                    },
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({
    required this.strings,
    required this.searchResults,
    required this.events,
  });

  final AiInsightsStrings strings;
  final List<AiSearchResult> searchResults;
  final List<AiInsightTimelineEvent> events;

  @override
  Widget build(BuildContext context) {
    final matchedTermsByEventId = <String, List<String>>{
      for (final result in searchResults) result.event.id: result.matchedTerms,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.timelineTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        for (final event in events)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TimelineCard(
              strings: strings,
              event: event,
              matchedTerms: matchedTermsByEventId[event.id] ?? const <String>[],
            ),
          ),
      ],
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    required this.strings,
    required this.event,
    required this.matchedTerms,
  });

  final AiInsightsStrings strings;
  final AiInsightTimelineEvent event;
  final List<String> matchedTerms;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final visuals = _resolveVisuals(event, scheme);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: visuals.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: visuals.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: visuals.iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(visuals.icon, color: visuals.iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      strings.formatTime(event.occurredAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(event.description),
                if (matchedTerms.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: matchedTerms
                        .toSet()
                        .map(
                          (term) => Chip(
                            label: Text(term),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                        .toList(growable: false),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _EventVisuals _resolveVisuals(
    AiInsightTimelineEvent event,
    ColorScheme scheme,
  ) {
    switch (event.type) {
      case AiInsightEventType.sos:
        return _EventVisuals(
          icon: Icons.sos_rounded,
          background: const Color(0xFFFFF1F2),
          border: const Color(0xFFFDA4AF),
          iconBackground: const Color(0xFFFEE2E2),
          iconColor: const Color(0xFFBE123C),
        );
      case AiInsightEventType.zoneEnter:
      case AiInsightEventType.zoneExit:
        return _EventVisuals(
          icon: Icons.hexagon_outlined,
          background: const Color(0xFFEFF6FF),
          border: const Color(0xFFBFDBFE),
          iconBackground: const Color(0xFFDBEAFE),
          iconColor: const Color(0xFF1D4ED8),
        );
      case AiInsightEventType.safeRoute:
        return _EventVisuals(
          icon: Icons.route_rounded,
          background: const Color(0xFFF5F3FF),
          border: const Color(0xFFDDD6FE),
          iconBackground: const Color(0xFFEDE9FE),
          iconColor: const Color(0xFF6D28D9),
        );
      case AiInsightEventType.locationStop:
        return _EventVisuals(
          icon: Icons.pause_circle_outline_rounded,
          background: const Color(0xFFF8FAFC),
          border: const Color(0xFFCBD5E1),
          iconBackground: const Color(0xFFE2E8F0),
          iconColor: const Color(0xFF334155),
        );
      case AiInsightEventType.batteryAlert:
        return _EventVisuals(
          icon: Icons.battery_alert_rounded,
          background: const Color(0xFFFFFBEB),
          border: const Color(0xFFFCD34D),
          iconBackground: const Color(0xFFFEF3C7),
          iconColor: const Color(0xFFB45309),
        );
      case AiInsightEventType.trackingAlert:
        return _EventVisuals(
          icon: Icons.warning_amber_rounded,
          background: const Color(0xFFFFF7ED),
          border: const Color(0xFFFED7AA),
          iconBackground: const Color(0xFFFFEDD5),
          iconColor: const Color(0xFFEA580C),
        );
      case AiInsightEventType.dayStart:
      case AiInsightEventType.dayEnd:
      case AiInsightEventType.info:
        return _EventVisuals(
          icon: Icons.insights_rounded,
          background: scheme.surface,
          border: scheme.outlineVariant.withOpacity(0.7),
          iconBackground: scheme.primaryContainer,
          iconColor: scheme.primary,
        );
    }
  }
}

class _EventVisuals {
  const _EventVisuals({
    required this.icon,
    required this.background,
    required this.border,
    required this.iconBackground,
    required this.iconColor,
  });

  final IconData icon;
  final Color background;
  final Color border;
  final Color iconBackground;
  final Color iconColor;
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.7)),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

