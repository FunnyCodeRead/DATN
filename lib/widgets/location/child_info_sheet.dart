import 'package:flutter/material.dart';
import 'package:kid_manager/l10n/app_localizations.dart';
import 'package:kid_manager/features/ai_insights/services/ai_insights_strings.dart';
import 'package:kid_manager/models/app_user.dart';
import 'package:kid_manager/models/location/location_data.dart';
import 'package:kid_manager/models/schedule.dart';
import 'package:kid_manager/models/user/user_types.dart';
import 'package:kid_manager/widgets/common/avatar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kid_manager/widgets/location/batterIcon.dart';
import 'package:kid_manager/widgets/location/location_theme.dart';

class ChildInfoSheet extends StatefulWidget {
  final AppUser member;
  final LocationData? latest;
  final bool isSearching;
  final List<Schedule> daySchedules;
  final VoidCallback onOpenChat;
  final VoidCallback? onOpenAiInsights;
  final Future<void> Function(String message) onSendQuickMessage;
  final VoidCallback onToggleSearch;

  const ChildInfoSheet({
    super.key,
    required this.member,
    required this.latest,
    required this.isSearching,
    required this.daySchedules,
    required this.onOpenChat,
    this.onOpenAiInsights,
    required this.onSendQuickMessage,
    required this.onToggleSearch,
  });

  @override
  State<ChildInfoSheet> createState() => _ChildInfoSheetState();
}

class _ChildInfoSheetState extends State<ChildInfoSheet> {
  final TextEditingController _msgCtl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _msgCtl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _msgCtl.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      await widget.onSendQuickMessage(text);
      _msgCtl.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).locationMessageSent),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).familyChatSendFailed('$e'),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  // ✅ Hàm lấy màu gradient theo % pin
  List<Color> _getBatteryGradient(int batteryLevel) {
    if (batteryLevel > 50) {
      return [const Color(0xFF4ADE80), const Color(0xFF16A34A)]; // green
    } else if (batteryLevel > 20) {
      return [const Color(0xFFFB923C), const Color(0xFFEA580C)]; // orange
    } else {
      return [const Color(0xFFEF4444), const Color(0xFFDC2626)]; // red
    }
  }

  // ✅ Hàm lấy icon theo % pin
  // ✅ Hàm lấy màu shadow
  Color _getBatteryShadowColor(int batteryLevel) {
    if (batteryLevel > 50) return const Color(0xFF16A34A);
    if (batteryLevel > 20) return const Color(0xFFEA580C);
    return const Color(0xFFDC2626);
  }

  String _formatScheduleTime(DateTime startAt, DateTime endAt) {
    String two(int v) => v.toString().padLeft(2, '0');
    final start = '${two(startAt.hour)}:${two(startAt.minute)}';
    final end = '${two(endAt.hour)}:${two(endAt.minute)}';
    return '$start - $end';
  }

  String _roleLabel(AppLocalizations l10n, AppUser member) {
    switch (member.role) {
      case UserRole.parent:
        return l10n.userRoleParent;
      case UserRole.child:
        return l10n.userRoleChild;
      case UserRole.guardian:
        return l10n.userRoleGuardian;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final member = widget.member;
    final latest = widget.latest;
    final panelColor = locationPanelColor(scheme);
    final panelMutedColor = locationPanelMutedColor(scheme);
    final panelBorderColor = locationPanelBorderColor(scheme);
    final panelHighlightColor = locationPanelHighlightColor(scheme);
    final insightsStrings = AiInsightsStrings(Localizations.localeOf(context));

    final name = (member.displayName?.isNotEmpty ?? false)
        ? member.displayName!
        : (member.email ?? '');
    final double circularBorder = 49;
    final schedules = List<Schedule>.from(widget.daySchedules)
      ..sort((a, b) => a.startAt.compareTo(b.startAt));
    final shownSchedules = schedules.take(4).toList();

    // ✅ TODO: thay bằng dữ liệu thật từ widget.child hoặc widget.latest
    const int batteryLevel = 20; // thử thay 90, 45, 15 để thấy màu thay đổi
    final statusText = l10n.locationStatusStudying;

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              color: panelColor,
              borderRadius: BorderRadius.circular(28),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: panelBorderColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.locationChildInfoTitle,
                        textAlign: TextAlign.center,
                        style: textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          height: 1.1,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ===== card user =====
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: panelMutedColor,
                          border: Border.all(color: panelBorderColor),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            AppAvatar(user: member, size: 66),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '${_roleLabel(l10n, member)} • ${l10n.memberManagementOnline}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: scheme.onSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: widget.onOpenChat,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: panelHighlightColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: SvgPicture.asset(
                                  "assets/icons/message.svg",
                                  fit: BoxFit.contain,
                                  colorFilter: ColorFilter.mode(
                                    scheme.primary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ===== quick message =====
                      Container(
                        width: 350,
                        height: 49,
                        decoration: BoxDecoration(
                          color: panelMutedColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: panelBorderColor, width: 1),
                        ),
                        child: Stack(
                          children: [
                            TextField(
                              controller: _msgCtl,
                              decoration: InputDecoration(
                                hintText: l10n.locationQuickMessageHint,
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: scheme.onSurfaceVariant,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.fromLTRB(
                                  12,
                                  14,
                                  44,
                                  14,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color: scheme.onSurface,
                              ),
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _send(),
                            ),
                            Positioned(
                              right: 10,
                              top: 0,
                              bottom: 0,
                              child: InkWell(
                                onTap: _sending ? null : _send,
                                borderRadius: BorderRadius.circular(8),
                                child: Center(
                                  child: _sending
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : SvgPicture.asset(
                                          "assets/icons/send-message.svg",
                                          fit: BoxFit.contain,
                                          colorFilter: ColorFilter.mode(
                                            scheme.primary,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // LEFT schedule
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(
                                12,
                                10,
                                12,
                                12,
                              ),
                              decoration: BoxDecoration(
                                color: panelMutedColor,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: panelBorderColor,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: panelColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: panelBorderColor,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.calendar_month,
                                          size: 16,
                                          color: scheme.primary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          l10n.scheduleScreenTitle,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: scheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (shownSchedules.isEmpty)
                                    Text(
                                      l10n.scheduleNoEventsInDay,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: scheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  else
                                    ...shownSchedules.asMap().entries.map((
                                      entry,
                                    ) {
                                      final i = entry.key;
                                      final s = entry.value;
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          bottom: i == shownSchedules.length - 1
                                              ? 0
                                              : 10,
                                        ),
                                        child: _ScheduleItemStyled(
                                          title: s.title,
                                          time: _formatScheduleTime(
                                            s.startAt,
                                            s.endAt,
                                          ),
                                        ),
                                      );
                                    }),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          // RIGHT buttons
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                // BATTERY PILL MỚI - gradient + shadow

                                // Thay thế widget battery pill bằng code này:
                                InkWell(
                                  onTap: () {},
                                  borderRadius: BorderRadius.circular(
                                    circularBorder,
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    height: 50,
                                    padding: const EdgeInsets.all(
                                      1,
                                    ), // khoảng cách cho border
                                    decoration: BoxDecoration(
                                      color:
                                          panelBorderColor, // border theo theme
                                      borderRadius: BorderRadius.circular(
                                        circularBorder,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _getBatteryShadowColor(
                                            batteryLevel,
                                          ).withValues(alpha: 0.25),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: panelColor, // nền theo theme
                                        borderRadius: BorderRadius.circular(
                                          circularBorder,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          // Phần pin còn lại (bên Trái) - có màu
                                          Positioned.fill(
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 800,
                                              ),
                                              curve: Curves.easeInOutCubic,
                                              alignment: Alignment.centerLeft,
                                              child: FractionallySizedBox(
                                                alignment: Alignment.centerLeft,
                                                widthFactor:
                                                    batteryLevel /
                                                    100, // % còn lại
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors:
                                                          _getBatteryGradient(
                                                            batteryLevel,
                                                          ),
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          circularBorder,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          //Shimmer effect chỉ chạy trên phần có màu
                                          Positioned.fill(
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 800,
                                              ),
                                              curve: Curves.easeInOutCubic,
                                              alignment: Alignment.centerRight,
                                              child: FractionallySizedBox(
                                                alignment:
                                                    Alignment.centerRight,
                                                widthFactor: batteryLevel / 100,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        circularBorder,
                                                      ),
                                                  child: TweenAnimationBuilder<double>(
                                                    tween: Tween(
                                                      begin: -1.0,
                                                      end: 1.0,
                                                    ),
                                                    duration: const Duration(
                                                      seconds: 2,
                                                    ),
                                                    curve: Curves.easeInOut,
                                                    builder: (context, value, child) {
                                                      return Transform.translate(
                                                        offset: Offset(
                                                          value * 100,
                                                          0,
                                                        ),
                                                        child: Container(
                                                          width: 30,
                                                          decoration: BoxDecoration(
                                                            gradient: LinearGradient(
                                                              colors: [
                                                                Colors.white
                                                                    .withValues(
                                                                      alpha: 0,
                                                                    ),
                                                                Colors.white
                                                                    .withValues(
                                                                      alpha:
                                                                          0.3,
                                                                    ),
                                                                Colors.white
                                                                    .withValues(
                                                                      alpha: 0,
                                                                    ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    onEnd: () {
                                                      if (mounted) {
                                                        setState(() {});
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                AnimatedSwitcher(
                                                  duration: const Duration(
                                                    milliseconds: 300,
                                                  ),
                                                  transitionBuilder:
                                                      (child, animation) {
                                                        return ScaleTransition(
                                                          scale: animation,
                                                          child: child,
                                                        );
                                                      },
                                                  child: BatteryIcon(
                                                    level: batteryLevel,
                                                    color: batteryLevel > 30
                                                        ? Colors.white
                                                        : scheme
                                                              .onSurfaceVariant,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                TweenAnimationBuilder<int>(
                                                  tween: IntTween(
                                                    begin: 0,
                                                    end: batteryLevel,
                                                  ),
                                                  duration: const Duration(
                                                    milliseconds: 800,
                                                  ),
                                                  curve: Curves.easeOutCubic,
                                                  builder: (context, value, child) {
                                                    return Text(
                                                      '$value%',
                                                      style: TextStyle(
                                                        color: batteryLevel > 30
                                                            ? Colors.white
                                                            : scheme
                                                                  .onSurfaceVariant,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                        shadows:
                                                            batteryLevel > 30
                                                            ? [
                                                                const Shadow(
                                                                  offset:
                                                                      Offset(
                                                                        0,
                                                                        1,
                                                                      ),
                                                                  blurRadius: 2,
                                                                  color: Colors
                                                                      .black26,
                                                                ),
                                                              ]
                                                            : null,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                _RightPill(
                                  icon: SvgPicture.asset(
                                    "assets/icons/status.svg",
                                    fit: BoxFit.contain,
                                  ),
                                  label: statusText,
                                  onTap: () {},
                                ),
                                const SizedBox(height: 10),
                                _RightPill(
                                  icon: SvgPicture.asset(
                                    "assets/icons/gps.svg",
                                    fit: BoxFit.contain,
                                  ),
                                  label: widget.isSearching
                                      ? l10n.locationStopSearching
                                      : l10n.locationSearchHint,
                                  onTap: widget.onToggleSearch,
                                ),
                                if (widget.onOpenAiInsights != null) ...[
                                  const SizedBox(height: 10),
                                  _RightPill(
                                    icon: const Icon(
                                      Icons.auto_awesome_rounded,
                                    ),
                                    label: insightsStrings.openInsightsTooltip,
                                    onTap: widget.onOpenAiInsights!,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (latest != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          l10n.locationCoordinatesSummary(
                            latest.latitude.toStringAsFixed(4),
                            latest.longitude.toStringAsFixed(4),
                          ),
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScheduleItemStyled extends StatelessWidget {
  final String title;
  final String time;

  const _ScheduleItemStyled({required this.title, required this.time});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: scheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RightPill extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  static const double circularBorder = 49;

  const _RightPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final backgroundColor = scheme.primary;
    final foregroundColor = scheme.onPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(circularBorder),
      child: Container(
        width: 156,
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(circularBorder),
          border: Border.all(color: backgroundColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconTheme(
              data: IconThemeData(color: foregroundColor, size: 18),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(foregroundColor, BlendMode.srcIn),
                child: icon,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
