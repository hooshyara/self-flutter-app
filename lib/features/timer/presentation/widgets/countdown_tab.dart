import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import '../../../../core/constants/app_colors.dart';
import 'timer_ring.dart';

enum _TimerState { idle, running, paused, finished }

class CountdownTab extends StatefulWidget {
  const CountdownTab({super.key});

  @override
  State<CountdownTab> createState() => _CountdownTabState();
}

class _CountdownTabState extends State<CountdownTab>
    with AutomaticKeepAliveClientMixin {
  static const int _defaultMinutes = 25;
  static const List<int> _presetMinutes = [5, 10, 15, 25, 45, 60];

  _TimerState _state = _TimerState.idle;
  Duration _total = const Duration(minutes: _defaultMinutes);
  Duration _remaining = const Duration(minutes: _defaultMinutes);
  DateTime? _endTime;
  Timer? _ticker;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _ticker?.cancel();
    _stopAlarm();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════
  // ─── منطق ───────────────────────────────────────────
  // ═══════════════════════════════════════════════════════

  /// آیا زمان فعلی یکی از presetها نیست (یعنی سفارشیه)؟
  bool get _isCustomSelection {
    if (_total.inSeconds % 60 != 0) return true;
    return !_presetMinutes.contains(_total.inMinutes);
  }

  void _setDuration(int minutes) {
    if (_state == _TimerState.running || _state == _TimerState.paused) return;
    setState(() {
      _total = Duration(minutes: minutes);
      _remaining = _total;
      _state = _TimerState.idle;
    });
  }

  Future<void> _pickCustomDuration() async {
    final result = await showModalBottomSheet<Duration>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CustomDurationSheet(initial: _total),
    );
    if (result == null || !mounted) return;
    if (result.inSeconds <= 0) return;
    setState(() {
      _total = result;
      _remaining = result;
      _state = _TimerState.idle;
    });
  }

  void _start() {
    _stopAlarm();
    setState(() {
      _endTime = DateTime.now().add(_remaining);
      _state = _TimerState.running;
    });
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), _tick);
  }

  void _pause() {
    _ticker?.cancel();
    if (_endTime != null) {
      _remaining = _endTime!.difference(DateTime.now());
      if (_remaining.isNegative) _remaining = Duration.zero;
      _endTime = null;
    }
    setState(() => _state = _TimerState.paused);
  }

  void _reset() {
    _ticker?.cancel();
    _stopAlarm();
    HapticFeedback.lightImpact();
    setState(() {
      _remaining = _total;
      _endTime = null;
      _state = _TimerState.idle;
    });
  }

  void _tick(Timer t) {
    if (_endTime == null) return;
    final diff = _endTime!.difference(DateTime.now());
    if (diff.isNegative || diff == Duration.zero) {
      t.cancel();
      _onFinished();
    } else {
      setState(() => _remaining = diff);
    }
  }

  void _onFinished() {
    setState(() {
      _remaining = Duration.zero;
      _state = _TimerState.finished;
      _endTime = null;
    });
    try {
      FlutterRingtonePlayer().playAlarm(
        looping: true,
        volume: 1.0,
        asAlarm: true,
      );
    } catch (_) {
      SystemSound.play(SystemSoundType.alert);
    }
    HapticFeedback.heavyImpact();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏰ زمان تمام شد!'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  void _stopAlarm() {
    try {
      FlutterRingtonePlayer().stop();
    } catch (_) {}
  }

  // ═══════════════════════════════════════════════════════
  // ─── رنگ و فرمت ─────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  Color _getRingColor() {
    final p = _total.inMilliseconds == 0
        ? 0.0
        : _remaining.inMilliseconds / _total.inMilliseconds;
    if (p >= 0.66) {
      final t = (1.0 - p) / 0.34;
      return Color.lerp(AppColors.primary, const Color(0xFFF59E0B), t)!;
    } else {
      final t = (0.66 - p) / 0.66;
      return Color.lerp(const Color(0xFFF59E0B), const Color(0xFFEF4444), t)!;
    }
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ═══════════════════════════════════════════════════════
  // ─── BUILD ──────────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final progress = _total.inMilliseconds == 0
        ? 0.0
        : _remaining.inMilliseconds / _total.inMilliseconds;
    final color = _getRingColor();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          if (_state == _TimerState.idle) _buildDurationChips(),
          const SizedBox(height: 32),
          TimerRing(
            progress: progress,
            color: color,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatDuration(_remaining),
                    style: TextStyle(
                      fontSize: 58,
                      fontWeight: FontWeight.w200,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: theme.textTheme.displayLarge?.color,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildStateLabel(color),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildStateLabel(Color color) {
    String text;
    switch (_state) {
      case _TimerState.idle:
        text = 'آماده';
      case _TimerState.running:
        text = 'در حال اجرا';
      case _TimerState.paused:
        text = 'مکث';
      case _TimerState.finished:
        text = 'زمان تمام شد!';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ─── چیپ‌های انتخاب زمان ────────────────────────────
  // ═══════════════════════════════════════════════════════
  Widget _buildDurationChips() {
    final currentMinutes = _total.inMinutes;
    final customSelected = _isCustomSelection;

    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: _presetMinutes.map((m) {
            final selected = !customSelected && currentMinutes == m;
            return _buildChip(
              label: '$m دقیقه',
              selected: selected,
              onTap: () => _setDuration(m),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        _buildChip(
          label: customSelected ? _formatDuration(_total) : 'زمان سفارشی',
          selected: customSelected,
          icon: Icons.edit_rounded,
          onTap: _pickCustomDuration,
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required bool selected,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected ? Colors.white : AppColors.primary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.primary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ─── کنترل‌ها ───────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  Widget _buildControls() {
    switch (_state) {
      case _TimerState.idle:
        return _buildMainButton(
          icon: Icons.play_arrow_rounded,
          label: 'شروع',
          color: AppColors.success,
          onTap: _start,
        );
      case _TimerState.running:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCircleButton(
              icon: Icons.pause_rounded,
              color: AppColors.warning,
              onTap: _pause,
            ),
            const SizedBox(width: 24),
            _buildCircleButton(
              icon: Icons.refresh_rounded,
              color: AppColors.error,
              onTap: _reset,
            ),
          ],
        );
      case _TimerState.paused:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCircleButton(
              icon: Icons.play_arrow_rounded,
              color: AppColors.success,
              onTap: _start,
            ),
            const SizedBox(width: 24),
            _buildCircleButton(
              icon: Icons.refresh_rounded,
              color: AppColors.error,
              onTap: _reset,
            ),
          ],
        );
      case _TimerState.finished:
        return _buildMainButton(
          icon: Icons.refresh_rounded,
          label: 'شروع دوباره',
          color: AppColors.primary,
          onTap: _reset,
        );
    }
  }

  Widget _buildMainButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.12),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Icon(icon, color: color, size: 32),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// ─── BottomSheet انتخاب زمان سفارشی ─────────────────
// ═══════════════════════════════════════════════════════
class _CustomDurationSheet extends StatefulWidget {
  final Duration initial;

  const _CustomDurationSheet({required this.initial});

  @override
  State<_CustomDurationSheet> createState() => _CustomDurationSheetState();
}

class _CustomDurationSheetState extends State<_CustomDurationSheet> {
  static const int _maxHours = 24;
  static const int _maxMinSec = 60;

  late final FixedExtentScrollController _hourCtrl;
  late final FixedExtentScrollController _minCtrl;
  late final FixedExtentScrollController _secCtrl;

  late int _hours;
  late int _minutes;
  late int _seconds;

  @override
  void initState() {
    super.initState();
    _hours = widget.initial.inHours.clamp(0, _maxHours - 1);
    _minutes = (widget.initial.inMinutes % 60).clamp(0, 59);
    _seconds = (widget.initial.inSeconds % 60).clamp(0, 59);
    _hourCtrl = FixedExtentScrollController(initialItem: _hours);
    _minCtrl = FixedExtentScrollController(initialItem: _minutes);
    _secCtrl = FixedExtentScrollController(initialItem: _seconds);
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minCtrl.dispose();
    _secCtrl.dispose();
    super.dispose();
  }

  int get _totalSeconds => _hours * 3600 + _minutes * 60 + _seconds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValid = _totalSeconds > 0;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.timer_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'زمان سفارشی',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // نوار هایلایت وسط
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 44,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildWheel(
                          'ساعت',
                          _maxHours,
                          _hourCtrl,
                          (v) => setState(() => _hours = v),
                        ),
                      ),
                      Expanded(
                        child: _buildWheel(
                          'دقیقه',
                          _maxMinSec,
                          _minCtrl,
                          (v) => setState(() => _minutes = v),
                        ),
                      ),
                      Expanded(
                        child: _buildWheel(
                          'ثانیه',
                          _maxMinSec,
                          _secCtrl,
                          (v) => setState(() => _seconds = v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isValid
                      ? () => Navigator.pop(
                          context,
                          Duration(
                            hours: _hours,
                            minutes: _minutes,
                            seconds: _seconds,
                          ),
                        )
                      : null,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(isValid ? 'تنظیم تایمر' : 'زمان رو انتخاب کن'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWheel(
    String label,
    int count,
    FixedExtentScrollController ctrl,
    ValueChanged<int> onChange,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListWheelScrollView.useDelegate(
            controller: ctrl,
            itemExtent: 44,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onChange,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: count,
              builder: (context, i) {
                return Center(
                  child: Text(
                    i.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
