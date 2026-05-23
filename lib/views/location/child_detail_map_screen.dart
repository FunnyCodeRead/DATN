import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kid_manager/features/ai_insights/presentation/ai_insights_screen.dart';
import 'package:kid_manager/features/ai_insights/services/ai_insights_strings.dart';
import 'package:kid_manager/features/map_engine/map_engine.dart';
import 'package:kid_manager/features/map_engine/smooth/smooth_mover.dart';
import 'package:kid_manager/features/safe_route/domain/entities/route_point.dart';
import 'package:kid_manager/features/safe_route/presentation/safe_route_access.dart';
import 'package:kid_manager/features/safe_route/presentation/pages/tracking_page.dart';
import 'package:kid_manager/l10n/app_localizations.dart';
import 'package:kid_manager/models/app_user.dart';
import 'package:kid_manager/models/location/location_data.dart';
import 'package:kid_manager/models/user/app_user_extensions.dart';
import 'package:kid_manager/services/access_control/access_control_service.dart';
import 'package:kid_manager/viewmodels/location/child_detail_map_vm.dart';
import 'package:kid_manager/viewmodels/location/parent_location_vm.dart';
import 'package:kid_manager/viewmodels/user_vm.dart';
import 'package:kid_manager/views/location/child_detail_map/child_detail_map_cards.dart';
import 'package:kid_manager/views/location/child_detail_map/child_detail_map_controls.dart';
import 'package:kid_manager/views/parent/zones/child_zones_screen.dart';
import 'package:kid_manager/widgets/location/location_theme.dart';
import 'package:kid_manager/widgets/map/app_map_view.dart';
import 'package:provider/provider.dart';

class ChildDetailMapScreen extends StatelessWidget {
  final String childId;
  final String? childAvatarUrl;
  final String? childTimeZone;

  const ChildDetailMapScreen({
    super.key,
    required this.childId,
    this.childAvatarUrl,
    this.childTimeZone,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChildDetailMapVm(
        context.read<ParentLocationVm>(),
        childId: childId,
        childTimeZone: childTimeZone,
      ),
      child: _ChildDetailMapBody(
        childId: childId,
        childAvatarUrl: childAvatarUrl,
      ),
    );
  }
}

class _ChildDetailMapBody extends StatefulWidget {
  final String childId;
  final String? childAvatarUrl;

  const _ChildDetailMapBody({required this.childId, this.childAvatarUrl});

  @override
  State<_ChildDetailMapBody> createState() => _ChildDetailMapBodyState();
}

class _ChildDetailMapBodyState extends State<_ChildDetailMapBody>
    with SingleTickerProviderStateMixin {
  MapEngine? _engine;
  StreamSubscription<LocationData>? _sub;

  final SmoothMover _mover = SmoothMover(durationMs: 650);
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  Timer? _animTick;
  Timer? _renderDebounce;
  DateTime _lastMapMatchAt = DateTime.fromMillisecondsSinceEpoch(0);
  final AppMapViewController _mapViewController = AppMapViewController();
  late final AnimationController _cardAnim;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _cardFade;

  bool _hideEmptyCard = false;

  ChildDetailMapVm get _vm => context.read<ChildDetailMapVm>();
  ParentLocationVm get _parentVm => context.read<ParentLocationVm>();

  @override
  void initState() {
    super.initState();

    _cardAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardAnim, curve: Curves.easeOutCubic));
    _cardFade = CurvedAnimation(parent: _cardAnim, curve: Curves.easeIn);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _vm.preloadToday();
      if (!mounted) return;
      _syncCardAnimation();
      if (_engine != null) {
        await _renderOnMap();
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _animTick?.cancel();
    _renderDebounce?.cancel();
    _cardAnim.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _syncCardAnimation() {
    if (_vm.latest == null && _vm.selectedPoint == null) {
      if (_cardAnim.status != AnimationStatus.dismissed) {
        _cardAnim.reverse();
      }
      return;
    }
    if (_cardAnim.status != AnimationStatus.forward &&
        _cardAnim.status != AnimationStatus.completed) {
      _cardAnim.forward();
    }
  }

  Future<void> _expandSheetForSelection() async {
    if (!_sheetController.isAttached) return;
    await _sheetController.animateTo(
      0.68,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _collapseSheet() async {
    if (!_sheetController.isAttached) return;
    await _sheetController.animateTo(
      0.24,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  LocationData _canonicalHistoryPoint(LocationData point) {
    for (final entry in _vm.cachedHistory) {
      if (entry.timestamp == point.timestamp) {
        return entry;
      }
    }
    return point;
  }

  Future<void> _showPointDetails(LocationData point) async {
    final resolvedPoint = _canonicalHistoryPoint(point);
    _vm.setSelectedPoint(resolvedPoint);
    _syncCardAnimation();
    await _engine?.camera.focusOnPoint(resolvedPoint);
    await _expandSheetForSelection();
  }

  void _startAnimTick() {
    _animTick ??= Timer.periodic(const Duration(milliseconds: 16), (_) async {
      if (!mounted || _engine == null) return;
      if (_mover.isAnimating) {
        final smoothed = _mover.current();
        await _engine!.updateChildDot(smoothed);
      }
    });
  }

  Future<void> _renderOnMap() async {
    final engine = _engine;
    if (!mounted || engine == null) return;

    await engine.resetForNewHistory();
    final history = _vm.cachedHistory;

    if (history.isEmpty) {
      await engine.setHistoryDotsVisible(_vm.showDots);
      if (_vm.isToday && _vm.rangeIncludesNow) {
        await _startRealtime();
      } else {
        await _sub?.cancel();
        _sub = null;
      }
      _syncCardAnimation();
      return;
    }

    await engine.loadHistory(history, context);
    await engine.setHistoryDotsVisible(_vm.showDots);
    await _ensureSingleHistoryPointFocus(engine, history);
    _lastMapMatchAt = DateTime.now();

    if (_vm.isToday && _vm.rangeIncludesNow) {
      await _startRealtime();
    } else {
      await _sub?.cancel();
      _sub = null;
    }

    _syncCardAnimation();
  }

  Future<void> _ensureSingleHistoryPointFocus(
    MapEngine engine,
    List<LocationData> history,
  ) async {
    if (history.length != 1) {
      return;
    }

    final point = _canonicalHistoryPoint(history.single);

    // Style/marker rendering can still win the first camera race on initial
    // screen entry. Re-apply a focused camera once the point is on the map.
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!mounted || _engine != engine) {
      return;
    }

    await engine.camera.focusOnPoint(point);
  }

  Future<void> _loadForDay(DateTime day) async {
    setState(() => _hideEmptyCard = false);
    final dayOnly = DateTime(day.year, day.month, day.day);
    await _sub?.cancel();
    _sub = null;

    await _vm.loadForDay(dayOnly);
    if (!mounted) return;

    _syncCardAnimation();
    await _renderOnMap();
  }

  Future<void> _startRealtime() async {
    await _sub?.cancel();
    _sub = _parentVm.watchChildLocation(widget.childId).listen((loc) async {
      if (!mounted || !_vm.isToday) return;
      if (!_vm.isTsInSelectedRange(loc.timestamp)) {
        await _sub?.cancel();
        _sub = null;
        return;
      }

      _vm.appendRealtime(loc);
      _syncCardAnimation();

      _mover.push(loc);
      _startAnimTick();

      _renderDebounce?.cancel();
      _renderDebounce = Timer(const Duration(milliseconds: 300), () async {
        if (!mounted || _engine == null) return;
        await _engine!.renderHistoryFast(_vm.cachedHistory, context);
      });

      final now = DateTime.now();
      if (_engine != null &&
          now.difference(_lastMapMatchAt) >= const Duration(seconds: 20) &&
          _vm.cachedHistory.length >= 6) {
        _lastMapMatchAt = now;
        await _engine!.updateMatchedRouteIncremental(
          _vm.cachedHistory,
          context,
        );
      }
    });
  }

  Future<void> _applyTimeWindow(int startMinute, int endMinute) async {
    setState(() => _hideEmptyCard = false);
    await _vm.applyTimeWindow(startMinute, endMinute);
    if (!mounted) return;
    _syncCardAnimation();
    await _renderOnMap();
  }

  Future<void> _pickTimeWindow() async {
    final selection = await showChildDetailTimeWindowSheet(
      context: context,
      initialStartMinute: _vm.rangeStartMinute,
      initialEndMinute: _vm.rangeEndMinute,
      minuteLabel: _vm.minuteLabel,
    );
    if (selection == null) return;
    await _applyTimeWindow(selection.startMinute, selection.endMinute);
  }

  Future<void> _pickDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _vm.selectedDay,
      firstDate: DateTime(2024, 1, 1),
      lastDate: _vm.currentLocalDay,
      builder: (ctx, child) {
        final theme = Theme.of(ctx);
        final scheme = theme.colorScheme;
        return Theme(
          data: theme.copyWith(
            colorScheme: scheme.copyWith(
              primary: scheme.primary,
              onSurface: scheme.onSurface,
              surface: locationPanelColor(scheme),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    await _loadForDay(picked);
  }

  Future<void> _toggleDots() async {
    _vm.toggleDots();
    await _engine?.setHistoryDotsVisible(_vm.showDots);
  }

  String _fmtDay(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/'
      '${value.year}';

  String _buildAppBarSubtitle(AppLocalizations l10n, ChildDetailMapVm vm) {
    final latest = vm.latest;
    if (latest == null) {
      return '${_fmtDay(vm.selectedDay)} · ${vm.rangeLabel}';
    }

    final diffMs = DateTime.now().millisecondsSinceEpoch - latest.timestamp;
    final diff = Duration(milliseconds: diffMs < 0 ? 0 : diffMs);
    final freshness = diff.inMinutes <= 0
        ? l10n.childLocationUpdatedJustNow
        : diff.inMinutes == 1
        ? l10n.childLocationUpdatedOneMinuteAgo
        : l10n.childLocationUpdatedMinutesAgo(diff.inMinutes);

    return '$freshness · ${vm.rangeLabel}';
  }

  String _buildAvatarLabel() {
    final compact = widget.childId.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    if (compact.length >= 2) {
      return compact.substring(0, 2).toUpperCase();
    }
    if (compact.isNotEmpty) {
      return compact.toUpperCase();
    }
    return 'BE';
  }

  AppUser? _resolveTrackedMember() {
    final userVm = context.read<UserVm>();
    for (final member in userVm.locationMembers) {
      if (member.uid == widget.childId) {
        return member;
      }
    }
    for (final member in userVm.familyMembers) {
      if (member.uid == widget.childId) {
        return member;
      }
    }
    return null;
  }

  SafeRouteAccessResult? _resolveSafeRouteAccess() {
    final viewer = context.read<UserVm>().me;
    final target = _resolveTrackedMember();
    if (viewer == null || target == null) {
      return null;
    }

    return evaluateSafeRouteAccess(
      accessControl: context.read<AccessControlService>(),
      actor: viewer,
      child: target,
      requireManageChild: true,
      requireViewLocation: true,
    );
  }

  bool _canOpenSafeRoute() {
    return _resolveSafeRouteAccess()?.isAllowed ?? false;
  }

  bool _canManageZones() {
    final viewer = context.read<UserVm>().me;
    final target = _resolveTrackedMember();
    return viewer?.isAdultManager == true && target?.isChild == true;
  }

  bool _canOpenAiInsights() {
    final viewer = context.read<UserVm>().me;
    final target = _resolveTrackedMember();
    return viewer?.isAdultManager == true && target?.isChild == true;
  }

  Future<void> _openAiInsights() async {
    final target = _resolveTrackedMember();
    if (target == null || !target.isChild) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AiInsightsScreen(
          childId: widget.childId,
          childDisplayName: target.displayLabel,
          childAvatarUrl: widget.childAvatarUrl,
        ),
      ),
    );
  }

  Widget _buildAvatarBadge() {
    final scheme = Theme.of(context).colorScheme;
    final avatarUrl = widget.childAvatarUrl?.trim() ?? '';
    return Container(
      width: 36,
      height: 36,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: locationPanelHighlightColor(scheme),
      ),
      child: ClipOval(
        child: avatarUrl.isEmpty
            ? Container(
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text(
                  _buildAvatarLabel(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              )
            : Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF64748B),
                  alignment: Alignment.center,
                  child: Text(
                    _buildAvatarLabel(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ChildDetailMapVm vm) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 110,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            color: locationPanelColor(scheme).withOpacity(0.92),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: locationPanelBorderColor(scheme)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(999),
                    child: Ink(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: locationPanelHighlightColor(scheme),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vm.isToday
                              ? l10n.childLocationCurrentJourneyTitle
                              : l10n.childLocationTravelHistoryTitle,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _buildAppBarSubtitle(l10n, vm),
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildAvatarBadge(),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ChildDetailMapAppBarChip(
                      icon: Icons.calendar_today_rounded,
                      label: vm.isToday
                          ? l10n.childLocationTodayLabel
                          : _fmtDay(vm.selectedDay),
                      onTap: _pickDay,
                      highlighted: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChildDetailMapAppBarChip(
                      icon: Icons.schedule_rounded,
                      label: vm.rangeLabel,
                      onTap: _pickTimeWindow,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFabColumn(ChildDetailMapVm vm) {
    final l10n = AppLocalizations.of(context);
    final insightsStrings = AiInsightsStrings(Localizations.localeOf(context));
    final canOpenAiInsights = _canOpenAiInsights();
    final canOpenSafeRoute = _canOpenSafeRoute();
    final canManageZones = _canManageZones();
    final startPointSource = vm.selectedPoint ?? vm.latest;
    final startPoint = startPointSource == null
        ? null
        : RoutePoint(
            latitude: startPointSource.latitude,
            longitude: startPointSource.longitude,
            sequence: 0,
          );

    return Column(
      children: [
        ChildDetailMapFab(
          tooltip: vm.showDots
              ? l10n.childLocationTooltipHideDots
              : l10n.childLocationTooltipShowDots,
          icon: Icons.more_vert_rounded,
          active: vm.showDots,
          onTap: _toggleDots,
        ),
        if (canManageZones) ...[
          const SizedBox(height: 10),
          ChildDetailMapFab(
            tooltip: l10n.childLocationTooltipManageZones,
            icon: Icons.hexagon_outlined,
            active: false,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChildZonesScreen(childId: widget.childId),
              ),
            ),
          ),
        ],
        if (canOpenAiInsights) ...[
          const SizedBox(height: 10),
          ChildDetailMapFab(
            tooltip: insightsStrings.openInsightsTooltip,
            icon: Icons.auto_awesome_rounded,
            active: false,
            onTap: _openAiInsights,
          ),
        ],
        if (canOpenSafeRoute) ...[
          const SizedBox(height: 10),
          ChildDetailMapFab(
            tooltip: l10n.childLocationTooltipSafeRoute,
            icon: Icons.route_rounded,
            active: false,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TrackingPage(
                  childId: widget.childId,
                  childAvatarUrl: widget.childAvatarUrl,
                  initialStartPoint: startPoint,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 10),
        ChildDetailMapFab(
          tooltip: l10n.childLocationTooltipChooseMap,
          icon: Icons.layers_outlined,
          active: false,
          onTap: _mapViewController.showMapSelector,
        ),
      ],
    );
  }

  Widget _buildOverlay(ChildDetailMapVm vm) {
    final topInset = MediaQuery.of(context).padding.top;

    // chiều cao vùng header đang dùng:
    // AppBar 110 + khoảng đệm nhìn thực tế thêm một chút
    final fabTop = topInset + 112 + 18;

    return Stack(
      children: [
        if (!_hideEmptyCard &&
            vm.selectedPoint == null &&
            vm.historyLoaded &&
            vm.cachedHistory.isEmpty)
          Positioned(
            left: 12,
            right: 72,
            top: fabTop,
            child: ChildDetailEmptyStateCard(
              dayLabel: _fmtDay(vm.selectedDay),
              rangeLabel: vm.rangeLabel,
              onClose: () => setState(() => _hideEmptyCard = true),
            ),
          ),

        Positioned(top: fabTop, right: 12, child: _buildFabColumn(vm)),

        if (vm.latest != null || vm.selectedPoint != null)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: false,
              child: SlideTransition(
                position: _cardSlide,
                child: FadeTransition(
                  opacity: _cardFade,
                  child: ChildDetailMapBottomSheet(
                    vm: vm,
                    onPointSelected: _showPointDetails,
                    onClosePoint: () async {
                      _vm.clearSelectedPoint();
                      await _collapseSheet();
                    },
                    controller: _sheetController,
                  ),
                ),
              ),
            ),
          ),

        if (!vm.historyLoaded)
          Positioned.fill(
            child: Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: Consumer<ChildDetailMapVm>(
          builder: (context, vm, _) => _buildAppBar(vm),
        ),
      ),
      body: Stack(
        children: [
          AppMapView(
            followThemeForStreetStyle: false,
            controller: _mapViewController,
            showInternalMapTypeButton: false,
            onMapCreated: (_) {},
            onTapListener: (gesture) {
              _engine?.handleMapTap(gesture);
            },
            onStyleLoaded: (map) async {
              _engine = MapEngine(
                map,
                enableChildDot: true,
                childAvatarUrl: widget.childAvatarUrl,
                onHistoryPointSelected: (point) async {
                  if (!mounted) return;
                  await _showPointDetails(point);
                },
              );
              await _engine!.init();
              if (_vm.historyLoaded) {
                await _renderOnMap();
              }
            },
          ),
          Consumer<ChildDetailMapVm>(
            builder: (context, vm, _) => _buildOverlay(vm),
          ),
        ],
      ),
    );
  }
}
