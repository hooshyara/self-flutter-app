import 'package:flutter/material.dart';
import 'package:self_profile/data/models/cycle_record.dart';
import 'package:self_profile/features/period_tracker/presentation/widgets/stats_card.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/repositories/period_repository.dart';
import '../domain/period_data.dart';

import 'widgets/cycle_ring.dart';
import 'widgets/jalali_calendar.dart';

class PeriodPage extends StatefulWidget {
  const PeriodPage({super.key});

  @override
  State<PeriodPage> createState() => _PeriodPageState();
}

class _PeriodPageState extends State<PeriodPage> {
  final _repo = PeriodRepository();

  late DateTime _lastPeriodStart;
  late int _cycleLength;
  late int _periodLength = 10;

  PeriodData get _data => PeriodData(
    lastPeriodStart: _lastPeriodStart,
    cycleLength: _cycleLength,
    periodLength: _periodLength,
  );

  @override
  void initState() {
    super.initState();
    // از Hive می‌خونیم
    _lastPeriodStart = _repo.lastPeriodStart;
    _cycleLength = _repo.cycleLength;
    _periodLength = _repo.periodLength;
  }

  // ─── انتخاب تاریخ از تقویم سیستم ────────────────────
  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastPeriodStart,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked == null || !mounted) return;

    setState(() => _lastPeriodStart = picked);
    await _repo.saveLastPeriodStart(picked);

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('تاریخ شروع ذخیره شد ✓')));
  }

  // ─── شروع دوره جدید (امروز) ─────────────────────────
  Future<void> _startNewCycle() async {
    final today = DateTime.now();

    // ─── ذخیره تاریخ فعلی ─────────────────────────────
    setState(() => _lastPeriodStart = today);
    await _repo.saveLastPeriodStart(today);

    // ─── اضافه کردن به تاریخچه ─────────────────────────
    await _repo.addCycle(
      CycleRecord(startDate: today, periodLength: _periodLength),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('دوره جدید شروع و ثبت شد 🌸')));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final data = _data;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.periodTracker)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildRingCard(data),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 20),
            JalaliCalendar(data: data),
            const SizedBox(height: 20),
            _buildLegend(theme),
            const SizedBox(height: 20),
            _buildInfoCard(data, theme),
            const SizedBox(height: 20),
            StatsCard(repo: _repo), 
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ─── کارت حلقه ──────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  Widget _buildRingCard(PeriodData data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.accent.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          CycleRing(
            daysRemaining: data.daysUntilNext.clamp(0, 999),
            progress: data.cycleProgress,
            currentDay: data.currentDayOfCycle,
            cycleLength: _cycleLength,
          ),
          const SizedBox(height: 24),
          _buildInsightRow(data),
        ],
      ),
    );
  }

  Widget _buildInsightRow(PeriodData data) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: _buildMiniCard(
            icon: Icons.auto_awesome_rounded,
            label: 'فاز فعلی',
            value: data.currentPhase,
            color: AppColors.primary,
            theme: theme,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMiniCard(
            icon: Icons.water_drop_rounded,
            label: 'پریود بعدی',
            value: _formatJalali(data.nextPeriodStart),
            color: AppColors.accent,
            theme: theme,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMiniCard(
            icon: Icons.star_rounded,
            label: 'تخمک‌گذاری',
            value: _formatJalali(data.ovulationDay),
            color: AppColors.primaryDark,
            theme: theme,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ─── دکمه‌ها ────────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildPrimaryButton(
            icon: Icons.play_arrow_rounded,
            label: 'شروع دوره',
            onTap: _startNewCycle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSecondaryButton(
            icon: Icons.calendar_month_rounded,
            label: 'تاریخ شروع',
            onTap: _pickStartDate,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ─── Legend ─────────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  Widget _buildLegend(ThemeData theme) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        _legendItem(AppColors.accent, 'قاعدگی', theme),
        _legendItem(AppColors.accent.withOpacity(0.25), 'پیش‌بینی', theme),
        _legendItem(AppColors.primary, 'تخمک‌گذاری', theme),
        _legendItem(AppColors.primary.withOpacity(0.15), 'باروری', theme),
      ],
    );
  }

  Widget _legendItem(Color color, String label, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // ─── کارت اطلاعات ────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  Widget _buildInfoCard(PeriodData data, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'اطلاعات دوره',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _infoRow('شروع دوره فعلی', _formatJalali(_lastPeriodStart), theme),
          const SizedBox(height: 10),
          _infoRow('پریود بعدی', _formatJalali(data.nextPeriodStart), theme),
          const SizedBox(height: 10),
          _infoRow('طول چرخه', '$_cycleLength روز', theme),
          const SizedBox(height: 10),
          _infoRow('طول پریود', '$_periodLength روز', theme),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  // ─── Helpers ────────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  String _formatJalali(DateTime dt) {
    final j = Jalali.fromDateTime(dt);
    return '${_toPersianDigits(j.day.toString())} ${j.formatter.mN}';
  }

  String _toPersianDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    var result = input;
    for (var i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], persian[i]);
    }
    return result;
  }
}
