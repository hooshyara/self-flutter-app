
class PeriodData {
  final DateTime lastPeriodStart;
  final int cycleLength;
  final int periodLength;

  const PeriodData({
    required this.lastPeriodStart,
    this.cycleLength = 30,
    this.periodLength = 10,
  });

  // ─── تاریخ‌های نرمال شده ─────────────────────────────
  DateTime get _startDay => DateTime(
    lastPeriodStart.year,
    lastPeriodStart.month,
    lastPeriodStart.day,
  );

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // ─── محاسبات چرخه ───────────────────────────────────
  DateTime get nextPeriodStart => _startDay.add(Duration(days: cycleLength));

  int get daysUntilNext => nextPeriodStart.difference(_today).inDays;

  int get currentDayOfCycle => _today.difference(_startDay).inDays + 1;

  double get cycleProgress => (currentDayOfCycle / cycleLength).clamp(0.0, 1.0);

  DateTime get ovulationDay =>
      nextPeriodStart.subtract(const Duration(days: 14));

  DateTime get fertileStart => ovulationDay.subtract(const Duration(days: 5));

  DateTime get fertileEnd => ovulationDay.add(const Duration(days: 1));

  // ─── تشخیص نوع روز ──────────────────────────────────
  bool isPeriodDay(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final diff = d.difference(_startDay).inDays;
    if (diff < 0) return false;
    final dayInCycle = diff % cycleLength;
    return dayInCycle < periodLength;
  }

  bool isPredictedPeriodDay(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    if (!d.isAfter(_today)) return false;
    if (d.isBefore(_startDay.add(Duration(days: periodLength)))) return false;
    return isPeriodDay(d);
  }

  bool isOvulationDay(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final ov = DateTime(
      ovulationDay.year,
      ovulationDay.month,
      ovulationDay.day,
    );
    return d == ov;
  }

  bool isFertileDay(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final fs = DateTime(
      fertileStart.year,
      fertileStart.month,
      fertileStart.day,
    );
    final fe = DateTime(fertileEnd.year, fertileEnd.month, fertileEnd.day);
    return (d.isAfter(fs) || d == fs) && (d.isBefore(fe) || d == fe);
  }

  // ─── فاز فعلی چرخه ──────────────────────────────────
  String get currentPhase {
    final day = currentDayOfCycle;
    if (day <= periodLength) return 'قاعدگی';
    if (day < cycleLength - 16) return 'فولیکولی';
    if (day <= cycleLength - 12) return 'تخمک‌گذاری';
    return 'لوتئال';
  }
}
