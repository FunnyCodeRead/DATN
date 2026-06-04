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
        final events = vm.visibleTimeline;
        final scheme = Theme.of(context).colorScheme;

        return Scaffold(
          backgroundColor: _AiPalette.pageBackground(scheme),
          body: RefreshIndicator(
            color: _AiPalette.mint,
            backgroundColor: _AiPalette.panelBackground(scheme),
            onRefresh: () => vm.loadForDay(vm.selectedDay),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _HeroSection(
                    childDisplayName: widget.childDisplayName,
                    childAvatarUrl: widget.childAvatarUrl,
                    dayLabel: widget.strings.formatDay(vm.selectedDay),
                    strings: widget.strings,
                    loading: vm.loading,
                    onRefresh: vm.loading
                        ? null
                        : () => vm.loadForDay(vm.selectedDay),
                    onPickDay: vm.loading ? null : () => _pickDay(context, vm),
                  ),
                ),
                if (vm.loading && summary == null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _LoadingState(strings: widget.strings),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (vm.loading && summary != null) ...[
                          _StaggeredFadeIn(
                            index: 0,
                            child: _UpdatingStrip(strings: widget.strings),
                          ),
                          const SizedBox(height: 14),
                        ],
                        _StaggeredFadeIn(
                          index: 1,
                          child: _MetricsRibbon(
                            strings: widget.strings,
                            summary: summary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _StaggeredFadeIn(
                          index: 2,
                          child: _InsightPanel(
                            strings: widget.strings,
                            summary: summary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _StaggeredFadeIn(
                          index: 3,
                          child: _AskAiPanel(
                            strings: widget.strings,
                            controller: _controller,
                            onSubmit: (query) => _submitSearch(vm, query),
                            onClear: () async {
                              _controller.clear();
                              await vm.clearSearch();
                            },
                          ),
                        ),
                        const SizedBox(height: 18),
                        _StaggeredFadeIn(
                          index: 4,
                          child: _buildTimelineState(vm: vm, events: events),
                        ),
                      ]),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimelineState({
    required AiInsightsViewModel vm,
    required List<AiInsightTimelineEvent> events,
  }) {
    if (vm.error != null) {
      return _StateNotice(
        icon: Icons.error_outline_rounded,
        title: widget.strings.errorTitle,
        message: vm.error!,
        tone: _NoticeTone.danger,
      );
    }

    if (!vm.hasSearchQuery && events.isEmpty) {
      return _StateNotice(
        icon: Icons.auto_awesome_outlined,
        title: widget.strings.emptyTimelineTitle,
        message: widget.strings.emptyState,
        tone: _NoticeTone.neutral,
      );
    }

    if (vm.hasSearchQuery && events.isEmpty) {
      return _StateNotice(
        icon: Icons.search_off_rounded,
        title: widget.strings.noSearchResult,
        message: widget.strings.askAiDescription,
        tone: _NoticeTone.warning,
      );
    }

    return _TimelineSection(
      strings: widget.strings,
      searchResults: vm.searchResults,
      events: events,
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.childDisplayName,
    required this.childAvatarUrl,
    required this.dayLabel,
    required this.strings,
    required this.loading,
    required this.onRefresh,
    required this.onPickDay,
  });

  final String childDisplayName;
  final String? childAvatarUrl;
  final String dayLabel;
  final AiInsightsStrings strings;
  final bool loading;
  final VoidCallback? onRefresh;
  final VoidCallback? onPickDay;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _AiPalette.heroGradient(scheme),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -54,
            top: 24,
            child: _HeroOrb(size: 160, opacity: 0.12),
          ),
          const Positioned(
            left: -46,
            bottom: -58,
            child: _HeroOrb(size: 150, opacity: 0.09),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _CircleAction(
                        icon: Icons.arrow_back_rounded,
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).backButtonTooltip,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const Spacer(),
                      _CircleAction(
                        icon: Icons.calendar_today_rounded,
                        tooltip: strings.changeDayLabel,
                        onTap: onPickDay,
                      ),
                      const SizedBox(width: 10),
                      _CircleAction(
                        icon: Icons.refresh_rounded,
                        tooltip: strings.refreshLabel,
                        onTap: onRefresh,
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  _StaggeredFadeIn(
                    index: 0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _HeroAvatar(
                          name: childDisplayName,
                          avatarUrl: childAvatarUrl,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.assistantEyebrow.toUpperCase(),
                                style: const TextStyle(
                                  color: _AiPalette.mint,
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                strings.screenTitle(childDisplayName),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontSize: 28,
                                  height: 1.05,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _StaggeredFadeIn(
                    index: 1,
                    child: Text(
                      strings.assistantSubtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _StaggeredFadeIn(
                    index: 2,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _HeroPill(
                          icon: Icons.calendar_month_rounded,
                          label: '${strings.selectedDayLabel}: $dayLabel',
                        ),
                        _HeroPill(
                          icon: loading
                              ? Icons.sync_rounded
                              : Icons.check_circle_outline_rounded,
                          label: loading
                              ? strings.loadingTitle
                              : strings.summaryTitle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroAvatar extends StatelessWidget {
  const _HeroAvatar({required this.name, required this.avatarUrl});

  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl?.trim().isNotEmpty == true;
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: _AiPalette.mint.withValues(alpha: 0.22),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 31,
        backgroundColor: _AiPalette.mint,
        backgroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
        child: hasAvatar
            ? null
            : Text(
                initial,
                style: const TextStyle(
                  color: _AiPalette.ink,
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.88)),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: enabled ? 0.12 : 0.06),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(
              icon,
              color: Colors.white.withValues(alpha: enabled ? 0.9 : 0.38),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroOrb extends StatelessWidget {
  const _HeroOrb({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: opacity)),
      ),
    );
  }
}

class _UpdatingStrip extends StatelessWidget {
  const _UpdatingStrip({required this.strings});

  final AiInsightsStrings strings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _AiPalette.panelBackground(scheme),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _AiPalette.border(scheme)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              strings.loadingSubtitle,
              style: TextStyle(
                color: _AiPalette.mutedText(scheme),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsRibbon extends StatelessWidget {
  const _MetricsRibbon({required this.strings, required this.summary});

  final AiInsightsStrings strings;
  final AiDailySummary? summary;

  @override
  Widget build(BuildContext context) {
    final resolved = summary;
    if (resolved == null) return const SizedBox.shrink();

    final metrics = <_MetricSpec>[
      _MetricSpec(
        icon: Icons.route_rounded,
        label: strings.distanceMetricLabel,
        value: '${resolved.distanceKm.toStringAsFixed(1)} km',
        color: _AiPalette.mint,
      ),
      _MetricSpec(
        icon: Icons.timeline_rounded,
        label: strings.tripsMetricLabel,
        value: '${resolved.tripCount}',
        color: const Color(0xFF60A5FA),
      ),
      _MetricSpec(
        icon: Icons.notifications_active_outlined,
        label: strings.alertsMetricLabel,
        value: '${resolved.alertCount}',
        color: const Color(0xFFF97316),
      ),
      _MetricSpec(
        icon: Icons.pause_circle_outline_rounded,
        label: strings.stopsMetricLabel,
        value: '${resolved.stopCount}',
        color: const Color(0xFF64748B),
      ),
      _MetricSpec(
        icon: Icons.hexagon_outlined,
        label: strings.zonesMetricLabel,
        value: '${resolved.zoneEventCount}',
        color: const Color(0xFF2563EB),
      ),
      _MetricSpec(
        icon: Icons.alt_route_rounded,
        label: strings.routesMetricLabel,
        value: '${resolved.safeRouteCount}',
        color: const Color(0xFF7C3AED),
      ),
      _MetricSpec(
        icon: Icons.radar_rounded,
        label: strings.pointsMetricLabel,
        value: '${resolved.pointCount}',
        color: const Color(0xFFA78BFA),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: strings.keyMetricsTitle,
          trailing: strings.timelineCountLabel(
            resolved.alertCount +
                resolved.zoneEventCount +
                resolved.safeRouteCount,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              for (var i = 0; i < metrics.length; i++) ...[
                _MetricTile(spec: metrics[i]),
                if (i != metrics.length - 1) const SizedBox(width: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.spec});

  final _MetricSpec spec;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 136,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _AiPalette.panelBackground(scheme),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _AiPalette.border(scheme)),
        boxShadow: _AiPalette.softShadow(scheme),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: spec.color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(spec.icon, color: spec.color, size: 19),
          ),
          const SizedBox(height: 13),
          Text(
            spec.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _AiPalette.primaryText(scheme),
              fontFamily: 'Poppins',
              fontSize: 21,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            spec.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _AiPalette.mutedText(scheme),
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightPanel extends StatelessWidget {
  const _InsightPanel({required this.strings, required this.summary});

  final AiInsightsStrings strings;
  final AiDailySummary? summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final resolved = summary;

    if (resolved == null) {
      return _StateNotice(
        icon: Icons.auto_awesome_outlined,
        title: strings.emptyTimelineTitle,
        message: strings.emptyState,
        tone: _NoticeTone.neutral,
      );
    }

    final firstSeen = resolved.firstSeenAt == null
        ? strings.noTimeLabel
        : strings.formatTime(resolved.firstSeenAt!);
    final lastSeen = resolved.lastSeenAt == null
        ? strings.noTimeLabel
        : strings.formatTime(resolved.lastSeenAt!);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _AiPalette.panelBackground(scheme),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _AiPalette.border(scheme)),
        boxShadow: _AiPalette.softShadow(scheme),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_AiPalette.mint, _AiPalette.gold],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: _AiPalette.ink,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.summaryTitle,
                      style: TextStyle(
                        color: _AiPalette.mutedText(scheme),
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      resolved.headline,
                      style: TextStyle(
                        color: _AiPalette.primaryText(scheme),
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        height: 1.18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            resolved.narrative,
            style: TextStyle(
              color: _AiPalette.primaryText(scheme),
              fontFamily: 'Poppins',
              fontSize: 14,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          _ActivityWindow(
            label: strings.activityWindowLabel,
            value: '$firstSeen - $lastSeen',
          ),
          if (resolved.highlights.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              strings.insightHighlightsTitle,
              style: TextStyle(
                color: _AiPalette.primaryText(scheme),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            for (final item in resolved.highlights.take(4))
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: _HighlightRow(text: item),
              ),
          ],
        ],
      ),
    );
  }
}

class _ActivityWindow extends StatelessWidget {
  const _ActivityWindow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _AiPalette.softFill(scheme),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.access_time_rounded,
            color: _AiPalette.mint,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: _AiPalette.mutedText(scheme),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: _AiPalette.primaryText(scheme),
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightRow extends StatelessWidget {
  const _HighlightRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.only(top: 1),
          decoration: const BoxDecoration(
            color: _AiPalette.mint,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 15,
            color: _AiPalette.ink,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: _AiPalette.primaryText(scheme),
              fontFamily: 'Poppins',
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _AskAiPanel extends StatelessWidget {
  const _AskAiPanel({
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _AiPalette.ink,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _AiPalette.ink.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.manage_search_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.searchTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      strings.askAiDescription,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.62),
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              return TextField(
                controller: controller,
                textInputAction: TextInputAction.search,
                onSubmitted: onSubmit,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: strings.searchHint,
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.44),
                    fontFamily: 'Poppins',
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.white.withValues(alpha: 0.62),
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (value.text.trim().isNotEmpty)
                        IconButton(
                          tooltip: strings.clearActionLabel,
                          onPressed: onClear,
                          icon: Icon(
                            Icons.close_rounded,
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                      IconButton(
                        tooltip: strings.searchActionLabel,
                        onPressed: () => onSubmit(controller.text),
                        icon: const Icon(
                          Icons.arrow_forward_rounded,
                          color: _AiPalette.mint,
                        ),
                      ),
                    ],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: _AiPalette.mint, width: 1.2),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          Text(
            strings.quickQuestionsLabel,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: strings.suggestedQueries
                .map(
                  (query) => ActionChip(
                    label: Text(query),
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                    onPressed: () {
                      controller.text = query;
                      controller.selection = TextSelection.collapsed(
                        offset: query.length,
                      );
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
        _SectionTitle(
          title: strings.timelineTitle,
          trailing: strings.timelineCountLabel(events.length),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < events.length; i++)
          _StaggeredFadeIn(
            index: i + 5,
            child: _TimelineItem(
              strings: strings,
              event: events[i],
              isLast: i == events.length - 1,
              matchedTerms:
                  matchedTermsByEventId[events[i].id] ?? const <String>[],
            ),
          ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.strings,
    required this.event,
    required this.isLast,
    required this.matchedTerms,
  });

  final AiInsightsStrings strings;
  final AiInsightTimelineEvent event;
  final bool isLast;
  final List<String> matchedTerms;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final visuals = _resolveVisuals(event, scheme);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 51,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                strings.formatTime(event.occurredAt),
                style: TextStyle(
                  color: _AiPalette.mutedText(scheme),
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: visuals.accent.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(color: visuals.accent, width: 2),
                ),
                child: Icon(visuals.icon, color: visuals.accent, size: 15),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: isLast
                      ? Colors.transparent
                      : _AiPalette.border(scheme),
                ),
              ),
            ],
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: visuals.background,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: visuals.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: TextStyle(
                              color: _AiPalette.primaryText(scheme),
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              height: 1.25,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _SeverityBadge(severity: event.severity),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      event.description,
                      style: TextStyle(
                        color: _AiPalette.mutedText(scheme),
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (matchedTerms.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        strings.matchedTermsLabel(matchedTerms.toSet().length),
                        style: TextStyle(
                          color: _AiPalette.mutedText(scheme),
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: matchedTerms
                            .toSet()
                            .map((term) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: visuals.accent.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  term,
                                  style: TextStyle(
                                    color: visuals.accent,
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              );
                            })
                            .toList(growable: false),
                      ),
                    ],
                  ],
                ),
              ),
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
          accent: const Color(0xFFE11D48),
          background: _AiPalette.eventBackground(
            scheme,
            const Color(0xFFE11D48),
          ),
          border: const Color(0xFFFDA4AF),
        );
      case AiInsightEventType.zoneEnter:
      case AiInsightEventType.zoneExit:
        return _EventVisuals(
          icon: Icons.hexagon_outlined,
          accent: const Color(0xFF2563EB),
          background: _AiPalette.eventBackground(
            scheme,
            const Color(0xFF2563EB),
          ),
          border: const Color(0xFFBFDBFE),
        );
      case AiInsightEventType.safeRoute:
        return _EventVisuals(
          icon: Icons.route_rounded,
          accent: const Color(0xFF7C3AED),
          background: _AiPalette.eventBackground(
            scheme,
            const Color(0xFF7C3AED),
          ),
          border: const Color(0xFFDDD6FE),
        );
      case AiInsightEventType.locationStop:
        return _EventVisuals(
          icon: Icons.pause_circle_outline_rounded,
          accent: const Color(0xFF475569),
          background: _AiPalette.panelBackground(scheme),
          border: _AiPalette.border(scheme),
        );
      case AiInsightEventType.batteryAlert:
        return _EventVisuals(
          icon: Icons.battery_alert_rounded,
          accent: const Color(0xFFD97706),
          background: _AiPalette.eventBackground(
            scheme,
            const Color(0xFFD97706),
          ),
          border: const Color(0xFFFCD34D),
        );
      case AiInsightEventType.trackingAlert:
        return _EventVisuals(
          icon: Icons.warning_amber_rounded,
          accent: const Color(0xFFEA580C),
          background: _AiPalette.eventBackground(
            scheme,
            const Color(0xFFEA580C),
          ),
          border: const Color(0xFFFED7AA),
        );
      case AiInsightEventType.dayStart:
      case AiInsightEventType.dayEnd:
      case AiInsightEventType.info:
        return _EventVisuals(
          icon: Icons.insights_rounded,
          accent: _AiPalette.mint,
          background: _AiPalette.panelBackground(scheme),
          border: _AiPalette.border(scheme),
        );
    }
  }
}

class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge({required this.severity});

  final AiInsightSeverity severity;

  @override
  Widget build(BuildContext context) {
    final color = switch (severity) {
      AiInsightSeverity.critical => const Color(0xFFE11D48),
      AiInsightSeverity.warning => const Color(0xFFF97316),
      AiInsightSeverity.info => _AiPalette.mint,
    };

    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.only(top: 7),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _StateNotice extends StatelessWidget {
  const _StateNotice({
    required this.icon,
    required this.title,
    required this.message,
    required this.tone,
  });

  final IconData icon;
  final String title;
  final String message;
  final _NoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = switch (tone) {
      _NoticeTone.danger => const Color(0xFFE11D48),
      _NoticeTone.warning => const Color(0xFFF97316),
      _NoticeTone.neutral => _AiPalette.mint,
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _AiPalette.panelBackground(scheme),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _AiPalette.border(scheme)),
        boxShadow: _AiPalette.softShadow(scheme),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _AiPalette.primaryText(scheme),
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: TextStyle(
                    color: _AiPalette.mutedText(scheme),
                    fontFamily: 'Poppins',
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.strings});

  final AiInsightsStrings strings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 680),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 18 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _AiPalette.panelBackground(scheme),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: _AiPalette.border(scheme)),
              boxShadow: _AiPalette.softShadow(scheme),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [_AiPalette.mint, _AiPalette.gold],
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(18),
                    child: CircularProgressIndicator(
                      color: _AiPalette.ink,
                      strokeWidth: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  strings.loadingTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _AiPalette.primaryText(scheme),
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.loadingSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _AiPalette.mutedText(scheme),
                    fontFamily: 'Poppins',
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: _AiPalette.primaryText(scheme),
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _AiPalette.softFill(scheme),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              trailing!,
              style: TextStyle(
                color: _AiPalette.mutedText(scheme),
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

class _StaggeredFadeIn extends StatelessWidget {
  const _StaggeredFadeIn({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 360 + index * 45),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _MetricSpec {
  const _MetricSpec({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
}

class _EventVisuals {
  const _EventVisuals({
    required this.icon,
    required this.accent,
    required this.background,
    required this.border,
  });

  final IconData icon;
  final Color accent;
  final Color background;
  final Color border;
}

enum _NoticeTone { danger, warning, neutral }

class _AiPalette {
  const _AiPalette._();

  static const ink = Color(0xFF0B1220);
  static const mint = Color(0xFF2DD4BF);
  static const gold = Color(0xFFFBBF24);

  static bool _dark(ColorScheme scheme) => scheme.brightness == Brightness.dark;

  static Color pageBackground(ColorScheme scheme) =>
      _dark(scheme) ? const Color(0xFF07111C) : const Color(0xFFF3F0E8);

  static Color panelBackground(ColorScheme scheme) =>
      _dark(scheme) ? const Color(0xFF101A27) : Colors.white;

  static Color softFill(ColorScheme scheme) => _dark(scheme)
      ? Colors.white.withValues(alpha: 0.06)
      : const Color(0xFFF3F6F5);

  static Color border(ColorScheme scheme) => _dark(scheme)
      ? Colors.white.withValues(alpha: 0.08)
      : const Color(0xFFE4E8E5);

  static Color primaryText(ColorScheme scheme) => _dark(scheme)
      ? Colors.white.withValues(alpha: 0.92)
      : const Color(0xFF102033);

  static Color mutedText(ColorScheme scheme) => _dark(scheme)
      ? Colors.white.withValues(alpha: 0.62)
      : const Color(0xFF667085);

  static List<Color> heroGradient(ColorScheme scheme) {
    if (_dark(scheme)) {
      return const <Color>[Color(0xFF07111C), Color(0xFF0D2F32)];
    }
    return const <Color>[Color(0xFF101A27), Color(0xFF123A3B)];
  }

  static Color eventBackground(ColorScheme scheme, Color accent) =>
      _dark(scheme) ? panelBackground(scheme) : accent.withValues(alpha: 0.07);

  static List<BoxShadow> softShadow(ColorScheme scheme) {
    if (_dark(scheme)) return const <BoxShadow>[];
    return <BoxShadow>[
      BoxShadow(
        color: const Color(0xFF0F172A).withValues(alpha: 0.07),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
    ];
  }
}
