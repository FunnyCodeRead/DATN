import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kid_manager/core/location/map_focus_bus.dart';
import 'package:kid_manager/core/sos/sos_focus_bus.dart';
import 'package:kid_manager/features/ai_insights/presentation/ai_insights_screen.dart';
import 'package:kid_manager/l10n/app_localizations.dart';
import 'package:kid_manager/models/app_user.dart';
import 'package:kid_manager/repositories/chat/family_chat_repository.dart';
import 'package:kid_manager/models/schedule.dart';
import 'package:kid_manager/services/schedule/schedule_service.dart';
import 'package:kid_manager/services/access_control/access_control_service.dart';
import 'package:kid_manager/viewmodels/location/sos_view_model.dart';
import 'package:kid_manager/viewmodels/zones/zone_status_vm.dart';
import 'package:kid_manager/views/chat/family_group_chat_screen.dart';
import 'package:kid_manager/views/parent/location/parent_children_list_screen.dart';
import 'package:kid_manager/widgets/map/app_map_view.dart';
import 'package:kid_manager/widgets/sos/sos_view.dart';
import 'package:provider/provider.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx;

import 'package:kid_manager/features/presentation/shared/state/mapbox_controller.dart';
import 'package:kid_manager/models/user/app_user_extensions.dart';
import 'package:kid_manager/viewmodels/location/parent_location_vm.dart';
import 'package:kid_manager/viewmodels/user_vm.dart';
import 'package:kid_manager/widgets/location/child_info_sheet.dart';
import 'package:kid_manager/widgets/location/location_theme.dart';
import 'package:kid_manager/widgets/location/map_bottom_controls.dart';

class ParentAllChildrenMapScreen extends StatefulWidget {
  const ParentAllChildrenMapScreen({super.key});

  @override
  State<ParentAllChildrenMapScreen> createState() =>
      _ParentAllChildrenMapScreenState();
}

class _ParentAllChildrenMapScreenState extends State<ParentAllChildrenMapScreen>
    with AutomaticKeepAliveClientMixin {
  mbx.MapboxMap? _map;

  String? _focusedChildId;

  Timer? _camDebounce;
  bool _inited = false;
  bool _didInitialFocus = false;
  bool _didFirstMapSync = false;

  late final UserVm _userVm;
  late final ParentLocationVm _locationVm;
  late final MapboxController _controller;
  late final ZoneStatusVm _zoneVm;

  bool _isMapVisualReady = false;

  Timer? _syncDebounce;
  Uint8List? _defaultAvatarBytes;
  final FamilyChatRepository _chatRepo = FamilyChatRepository();
  final ScheduleService _scheduleService = ScheduleService();

  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    sosFocusNotifier.addListener(_onSosFocus);
    mapFocusNotifier.addListener(_onMapFocus);

    Future.microtask(() async {
      final d = await rootBundle.load("assets/images/avatar_default.png");
      _defaultAvatarBytes = d.buffer.asUint8List();
    });
  }

  Future<void> _onSosFocus() async {
    final focus = sosFocusNotifier.value;
    if (!mounted || focus == null) return;

    final myFamilyId = _userVm.familyId;
    if (myFamilyId != null && focus.familyId != myFamilyId) return;

    if (_map == null) return;

    await _map!.easeTo(
      mbx.CameraOptions(
        center: mbx.Point(coordinates: mbx.Position(focus.lng, focus.lat)),
        zoom: 16,
      ),
      mbx.MapAnimationOptions(duration: 700),
    );

    sosFocusNotifier.value = null;
  }

  Future<void> _onMapFocus() async {
    final focus = mapFocusNotifier.value;
    if (!mounted || !_inited || focus == null) return;
    if (_map == null) return;

    final childUid = (focus.childUid ?? '').trim();
    final position = focus.hasPosition && focus.lat != null && focus.lng != null
        ? mbx.Position(focus.lng!, focus.lat!)
        : null;

    if (childUid.isNotEmpty) {
      final canOpenSheet =
          focus.openSheet &&
          _userVm.locationMembers.any((member) => member.uid == childUid);
      await _focusChild(
        childId: childUid,
        openSheet: canOpenSheet,
        animate: false,
        focusPosition: position,
      );
      mapFocusNotifier.value = null;
      return;
    }

    if (position != null) {
      await _controller.clearFocusBubble();
      await _map!.easeTo(
        mbx.CameraOptions(
          center: mbx.Point(coordinates: position),
          zoom: 16.5,
          pitch: 0,
          bearing: 0,
        ),
        mbx.MapAnimationOptions(duration: 700),
      );
      mapFocusNotifier.value = null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    _inited = true;

    _zoneVm = context.read<ZoneStatusVm>();
    _zoneVm.addListener(_onZoneBubbleChanged);

    _userVm = context.read<UserVm>();
    _locationVm = context.read<ParentLocationVm>();
    _controller = context.read<MapboxController>();

    _controller.addListener(_handleMapOrDataChange);
    _locationVm.addListener(_handleMapOrDataChange);
    _userVm.addListener(_handleUserChange);

    unawaited(_onMapFocus());
  }

  Future<void> _focusFirstChildOnce() async {
    if (_didInitialFocus) return;
    if (_map == null) return;
    if (_userVm.locationMembers.isEmpty) return;

    final firstChildId = _userVm.locationMembers.first.uid;
    final loc = _locationVm.childrenLocations[firstChildId];
    if (loc == null) return;

    _didInitialFocus = true;

    await _focusChild(
      childId: firstChildId,
      openSheet: false,
      animate: false,
      focusPosition: mbx.Position(loc.longitude, loc.latitude),
    );
  }

  Future<void> _focusChild({
    required String childId,
    bool openSheet = false,
    bool animate = false,
    mbx.Position? focusPosition,
  }) async {
    if (!mounted || _map == null) return;

    setState(() => _focusedChildId = childId);

    await _controller.clearFocusBubble();

    final myUid = _userVm.me?.uid;
    if (myUid != null) {
      _zoneVm.focus(viewerUid: myUid, childId: childId);
    }

    if (focusPosition != null) {
      final camera = mbx.CameraOptions(
        center: mbx.Point(coordinates: focusPosition),
        zoom: 16.5,
        pitch: 0,
        bearing: 0,
      );
      if (animate) {
        await _map!.easeTo(camera, mbx.MapAnimationOptions(duration: 700));
      } else {
        await _map!.setCamera(camera);
      }
    } else if (animate) {
      final duration = await _controller.zoomToChild(childId);
      await Future.delayed(Duration(milliseconds: duration));
    } else {
      final pos = _controller.getChildPosition(childId);
      if (pos != null) {
        await _map!.setCamera(
          mbx.CameraOptions(
            center: mbx.Point(coordinates: pos),
            zoom: 16.5,
            pitch: 0,
            bearing: 0,
          ),
        );
      }
    }

    if (openSheet) _openChildInfo(childId);
  }

  void _onZoneBubbleChanged() async {
    if (!mounted) return;
    final childId = _focusedChildId;
    final bubble = _zoneVm.bubble;
    if (childId == null || bubble == null) return;

    await _controller.setFocusBubble(
      childId: childId,
      text: bubble.text,
      icon: bubble.icon,
    );
  }

  void _handleMapOrDataChange() {
    if (!mounted) return;
    if (!_controller.isReady) return;
    if (_locationVm.childrenLocations.isEmpty) return;

    if (!_didFirstMapSync) {
      _didFirstMapSync = true;
      unawaited(() async {
        await _syncToMap();
        await _focusFirstChildOnce();
      }());
      return;
    }

    _syncDebounce?.cancel();
    _syncDebounce = Timer(const Duration(milliseconds: 150), () async {
      if (!mounted) return;
      await _syncToMap();
    });
  }

  void _handleUserChange() {
    if (!mounted) return;

    // Nếu danh sách child thay đổi sau khi map đã vào,
    // sync lại marker ngay để map luôn bám state mới nhất.
    if (_controller.isReady) {
      unawaited(_syncToMap());
    }
  }

  Future<void> _syncToMap() async {
    if (!_controller.isReady) return;

    final positions = <String, mbx.Position>{};
    final headings = <String, double>{};
    final names = <String, String>{};

    final childMap = {for (final c in _userVm.locationMembers) c.uid: c};

    for (final entry in _locationVm.childrenLocations.entries) {
      final child = childMap[entry.key];
      if (child == null) continue;

      final loc = entry.value;
      positions[child.uid] = mbx.Position(loc.longitude, loc.latitude);
      headings[child.uid] = loc.heading;
      names[child.uid] = child.displayName ?? "";
    }

    _controller.scheduleUpdate(
      positions: positions,
      headings: headings,
      names: names,
    );
  }

  Future<List<Schedule>> _loadChildSchedulesByDate({
    required String childId,
    required DateTime date,
  }) async {
    final viewer = _userVm.me;
    final accessControl = context.read<AccessControlService>();
    AppUser? target;
    for (final member in _userVm.locationMembers) {
      if (member.uid == childId) {
        target = member;
        break;
      }
    }
    if (viewer == null || target == null || !target.isChild) {
      return <Schedule>[];
    }

    if (!accessControl.canManageChild(
      actor: viewer,
      childUid: childId,
      child: target,
    )) {
      return <Schedule>[];
    }

    final parentUid = viewer.isGuardian
        ? (viewer.parentUid ?? '').trim()
        : viewer.uid.trim();
    if (parentUid.isEmpty) return <Schedule>[];

    try {
      return await _scheduleService.fetchByChildAndDate(
        parentUid: parentUid,
        childId: childId,
        date: date,
      );
    } catch (e, st) {
      debugPrint('load child schedules error: $e');
      debugPrint('$st');
      return <Schedule>[];
    }
  }

  void _openChildInfo(String childId) async {
    AppUser? foundChild;
    for (final member in _userVm.locationMembers) {
      if (member.uid == childId) {
        foundChild = member;
        break;
      }
    }
    if (foundChild == null) return;

    final child = foundChild; // non-null local
    final latest = _locationVm.childrenLocations[child.uid];
    final schedules = await _loadChildSchedulesByDate(
      childId: child.uid,
      date: DateTime.now(),
    );
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => ChildInfoSheet(
        member: child,
        latest: latest,
        isSearching: false,
        daySchedules: schedules,
        onToggleSearch: () {},
        onOpenChat: () {
          Navigator.of(sheetContext).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FamilyGroupChatScreen()),
          );
        },
        onOpenAiInsights: child.isChild
            ? () {
                Navigator.of(sheetContext).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AiInsightsScreen(
                      childId: child.uid,
                      childDisplayName: child.displayLabel,
                      childAvatarUrl: child.avatarUrl,
                    ),
                  ),
                );
              }
            : null,
        onSendQuickMessage: (msg) async {
          final me = _userVm.me;
          final familyId = _userVm.familyId;
          if (me == null || familyId == null) {
            throw StateError('Missing user or family');
          }

          try {
            await _chatRepo.sendTextMessage(
              familyId: familyId,
              sender: me,
              text: msg,
            );
          } catch (e, st) {
            debugPrint('sendTextMessage error: $e');
            debugPrint('$st');
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final userVm = context.watch<UserVm>();
    final me = userVm.me;
    if (me == null) {
      return Scaffold(
        body: ColoredBox(
          color: locationPanelMutedColor(scheme),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final children = List.of(userVm.locationMembers);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _MapLoadingPlaceholder()),
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _isMapVisualReady ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: AppMapView(
                followThemeForStreetStyle: false,
                onMapCreated: (map) {
                  _map = map;
                  _controller.attach(map);

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    _onSosFocus();
                    _onMapFocus();
                  });
                },
                onStyleLoaded: (map) async {
                  _map = map;

                  await _controller.onStyleLoaded();
                  if (!mounted) return;

                  if (!_isMapVisualReady) {
                    setState(() => _isMapVisualReady = true);
                  }

                  try {
                    final defaultBytes =
                        _defaultAvatarBytes ??
                        (await rootBundle.load(
                          "assets/images/avatar_default.png",
                        )).buffer.asUint8List();

                    await _controller.setDefaultAvatar(defaultBytes);
                    await _syncToMap();
                    await _focusFirstChildOnce();

                    for (final c in _userVm.locationMembers) {
                      unawaited(
                        _controller.setAvatarSmart(
                          childId: c.uid,
                          photoUrlOrData: c.avatarUrl,
                          defaultBytes: defaultBytes,
                        ),
                      );
                    }
                  } catch (e, st) {
                    debugPrint("🔥 Setup Error: $e");
                    debugPrint("$st");
                  }
                },
                onTapListener: (tapContext) async {
                  if (_map == null) return;

                  final features = await _map!.queryRenderedFeatures(
                    mbx.RenderedQueryGeometry.fromScreenCoordinate(
                      tapContext.touchPosition,
                    ),
                    mbx.RenderedQueryOptions(
                      layerIds: ["children-layer"],
                      filter: null,
                    ),
                  );

                  if (features.isEmpty) return;

                  final queried = features.first?.queriedFeature;
                  if (queried == null) return;

                  final rawFeature = queried.feature as Map<String?, Object?>?;
                  if (rawFeature == null) return;

                  final props = rawFeature["properties"] as Map?;
                  if (props == null) return;

                  final childId = props["id"]?.toString();
                  if (childId == null) return;

                  await _focusChild(
                    childId: childId,
                    openSheet: true,
                    animate: true,
                  );
                },
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: 90,
            child: SafeArea(
              child: SosCircleButton(
                onPressed: () async {
                  final sosVm = context.read<SosViewModel>();
                  var myLocation = _locationVm.myLocation;
                  debugPrint('Vo denn day');
                  final displayName =
                      context.read<UserVm>().me?.displayName ??
                      l10n.parentLocationUnknownUser;

                  debugPrint('myLocation=$myLocation');
                  debugPrint('sending=${sosVm.sending}');
                  myLocation ??= await _locationVm.getMyLocationOnce();
                  if (!context.mounted) return;
                  if (myLocation == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.currentLocationError)),
                    );
                    return;
                  }
                  if (sosVm.sending) return;

                  final sosId = await sosVm.triggerSos(
                    lat: myLocation.latitude,
                    lng: myLocation.longitude,
                    acc: myLocation.accuracy,
                    createdByName: displayName,
                  );

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        sosId != null
                            ? l10n.parentLocationSosSent
                            : l10n.parentLocationSosFailed,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          Positioned(
            left: 12,
            right: 12,
            bottom: 16,
            child: SafeArea(
              child: MapBottomControls(
                children: children,
                onMyLocation: () async {
                  await _syncToMap();
                },
                onTapChild: (child) async {
                  await _syncToMap();
                  await _focusChild(
                    childId: child.uid,
                    openSheet: true,
                    animate: true,
                  );
                },
                onMore: () async {
                  final selectedChild = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ParentChildrenListScreen(),
                    ),
                  );

                  if (!mounted) return;
                  if (selectedChild == null) return;

                  await _syncToMap();
                  await _focusChild(
                    childId: selectedChild.uid,
                    openSheet: true,
                    animate: true,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _syncDebounce?.cancel();
    _camDebounce?.cancel();

    _controller.removeListener(_handleMapOrDataChange);
    _locationVm.removeListener(_handleMapOrDataChange);
    _userVm.removeListener(_handleUserChange);

    _controller.clearFocusBubble();
    sosFocusNotifier.removeListener(_onSosFocus);
    mapFocusNotifier.removeListener(_onMapFocus);
    _zoneVm.removeListener(_onZoneBubbleChanged);

    _controller.detach();
    super.dispose();
  }
}

class _MapLoadingPlaceholder extends StatelessWidget {
  const _MapLoadingPlaceholder();

  Widget _fakeMarker(
    BuildContext context, {
    required double top,
    required double left,
    double size = 18,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.18),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Container(
            width: size * 0.42,
            height: size * 0.42,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/map_placeholder.webp', fit: BoxFit.cover),

        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.05),
                Colors.transparent,
                Colors.black.withOpacity(0.10),
              ],
            ),
          ),
        ),

        _fakeMarker(context, top: 160, left: 72),
        _fakeMarker(context, top: 240, left: 250, size: 20),
        _fakeMarker(context, top: 380, left: 140, size: 16),

        Align(
          alignment: Alignment.center,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            constraints: const BoxConstraints(maxWidth: 270),
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.94),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: colorScheme.outline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.parentLocationMapLoadingTitle,
                        style: textTheme.titleMedium?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.parentLocationMapLoadingSubtitle,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12.5,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
