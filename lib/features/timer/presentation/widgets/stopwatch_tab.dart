import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import 'timer_ring.dart';

class StopwatchTab extends StatefulWidget {
  const StopwatchTab({super.key});

  @override
  State<StopwatchTab> createState() => _StopwatchTabState();
}

class _StopwatchTabState extends State<StopwatchTab>
    with AutomaticKeepAliveClientMixin {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  final List<Duration> _laps = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════
  // ─── منطق ───────────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  void _start() {
    _stopwatch.start();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (mounted) setState(() {});
    });
    setState(() {});
  }

  void _pause() {
    _stopwatch.stop();
    _ticker?.cancel();
    setState(() {});
  }

  void _reset() {
    _stopwatch.stop();
    _stopwatch.reset();
    _ticker?.cancel();
    _laps.clear();
    HapticFeedback.lightImpact();
    setState(() {});
  }

  void _addLap() {
    if (_stopwatch.elapsed == Duration.zero) return;
    setState(() => _laps.insert(0, _stopwatch.elapsed));
    HapticFeedback.selectionClick();
  }

  // ═══════════════════════════════════════════════════════
  // ─── فرمت ───────────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    final cs = (d.inMilliseconds % 1000) ~/ 10;

    final base = h > 0
        ? '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
        : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    return '$base.${cs.toString().padLeft(2, '0')}';
  }

  // ═══════════════════════════════════════════════════════
  // ─── BUILD ──────────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isRunning = _stopwatch.isRunning;
    final elapsed = _stopwatch.elapsed;
    final hasTime = elapsed > Duration.zero;
    final activeColor = isRunning
        ? AppColors.success
        : hasTime
        ? AppColors.warning
        : AppColors.primary;

    return Column(
      children: [
        const SizedBox(height: 32),

        // ─── حلقه + زمان ─────────────────────────
        TimerRing(
          progress: isRunning ? (elapsed.inMilliseconds % 60000) / 60000 : 0,
          color: activeColor,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _format(elapsed),
                  style: TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.w200,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: theme.textTheme.displayLarge?.color,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: activeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isRunning
                        ? 'در حال شمارش'
                        : hasTime
                        ? 'متوقف'
                        : 'آماده',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: activeColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),

        // ─── کنترل‌ها ─────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // بازنشانی
            _buildCircleButton(
              icon: Icons.refresh_rounded,
              color: hasTime ? AppColors.error : theme.dividerColor,
              onTap: hasTime ? _reset : null,
            ),
            const SizedBox(width: 24),

            // شروع / مکث
            _buildCircleButton(
              icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: isRunning ? AppColors.warning : AppColors.success,
              onTap: isRunning ? _pause : _start,
              large: true,
            ),
            const SizedBox(width: 24),

            // دور
            _buildCircleButton(
              icon: Icons.flag_rounded,
              color: isRunning ? AppColors.primary : theme.dividerColor,
              onTap: isRunning ? _addLap : null,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // ─── لیست دورها ──────────────────────────
        Expanded(
          child: _laps.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        size: 40,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'با دکمه پرچم، دور ثبت کن',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: _laps.length,
                  itemBuilder: (context, i) {
                    final lap = _laps[i];
                    final isLast = i == 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isLast
                            ? AppColors.primary.withOpacity(0.08)
                            : theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: isLast
                            ? Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'دور ${_laps.length - i}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isLast
                                  ? AppColors.primary
                                  : theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _format(lap),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    bool large = false,
  }) {
    final size = large ? 72.0 : 56.0;
    final iconSize = large ? 36.0 : 26.0;

    return Material(
      color: color.withOpacity(0.12),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: color, size: iconSize),
        ),
      ),
    );
  }
}
