import 'dart:convert';

import 'package:hive/hive.dart';

import '../../core/services/hive_service.dart';
import '../models/cycle_record.dart';

class PeriodRepository {
  // ═══════════════════════════════════════════════════════
  // ─── تنظیمات فعلی ────────────────────────────────────
  // ═══════════════════════════════════════════════════════

  DateTime get lastPeriodStart {
    final stored = HiveService.period.get(HiveService.kLastPeriodStart);
    if (stored == null) {
      return DateTime.now().subtract(const Duration(days: 10));
    }
    return DateTime.parse(stored as String);
  }

  int get cycleLength =>
      HiveService.period.get(HiveService.kCycleLength, defaultValue: 30) as int;

  int get periodLength => HiveService.period
      .get(HiveService.kPeriodLength, defaultValue: 10) as int;

  Future<void> saveLastPeriodStart(DateTime date) async {
    await HiveService.period.put(
      HiveService.kLastPeriodStart,
      date.toIso8601String(),
    );
  }

  Future<void> saveCycleLength(int length) async {
    await HiveService.period.put(HiveService.kCycleLength, length);
  }

  Future<void> savePeriodLength(int length) async {
    await HiveService.period.put(HiveService.kPeriodLength, length);
  }

  bool get hasData => HiveService.period.containsKey(
        HiveService.kLastPeriodStart,
      );

  // ═══════════════════════════════════════════════════════
  // ─── تاریخچه چرخه‌ها ────────────────────────────────
  // ═══════════════════════════════════════════════════════

  static const String _kHistoryList = 'history_list';

  /// لیست همه چرخه‌های ثبت‌شده، مرتب از قدیم به جدید.
  List<CycleRecord> getHistory() {
    final raw = HiveService.history.get(_kHistoryList);

    if (raw == null) return [];

    // ─── اگه قبلاً به صورت JSON string ذخیره شده ─────
    if (raw is String) {
      try {
        final list = jsonDecode(raw) as List;
        return list
            .map((e) => CycleRecord.fromJson(e as String))
            .toList();
      } catch (_) {
        return [];
      }
    }

    // ─── اگه به صورت List ذخیره شده ───────────────────
    if (raw is List) {
      return raw
          .map((e) {
            if (e is String) return CycleRecord.fromJson(e);
            if (e is Map) return CycleRecord.fromMap(e);
            return null;
          })
          .whereType<CycleRecord>()
          .toList();
    }

    return [];
  }

  /// افزودن یک چرخه جدید به تاریخچه.
  /// اگه چرخه‌ای با همون تاریخ قبلاً ثبت شده، دوباره اضافه نمی‌شه.
  Future<void> addCycle(CycleRecord record) async {
    final history = getHistory();

    // ─── چک تکراری ────────────────────────────────────
    final isDuplicate = history.any((r) {
      return r.startDate.year == record.startDate.year &&
          r.startDate.month == record.startDate.month &&
          r.startDate.day == record.startDate.day;
    });
    if (isDuplicate) return;

    history.add(record);

    // ─── مرتب‌سازی ────────────────────────────────────
    history.sort((a, b) => a.startDate.compareTo(b.startDate));

    await _saveHistory(history);
  }

  Future<void> removeCycle(CycleRecord record) async {
    final history = getHistory();
    history.removeWhere((r) {
      return r.startDate.year == record.startDate.year &&
          r.startDate.month == record.startDate.month &&
          r.startDate.day == record.startDate.day;
    });
    await _saveHistory(history);
  }

  Future<void> clearHistory() async {
    await HiveService.history.delete(_kHistoryList);
  }

  // ─── ذخیره لیست به صورت JSON string ─────────────────
  Future<void> _saveHistory(List<CycleRecord> history) async {
    final encoded = history.map((r) => r.toJson()).toList();
    await HiveService.history.put(_kHistoryList, jsonEncode(encoded));
  }

  // ═══════════════════════════════════════════════════════
  // ─── محاسبات آماری ──────────────────────────────────
  // ═══════════════════════════════════════════════════════

  /// میانگین طول چرخه از تاریخچه.
  /// اگه کمتر از دو چرخه ثبت شده، همون cycleLength تنظیمات برمی‌گرده.
  int get averageCycleLength {
    final history = getHistory();
    if (history.length < 2) return cycleLength;

    final lengths = <int>[];
    for (var i = 1; i < history.length; i++) {
      final diff = history[i]
          .startDate
          .difference(history[i - 1].startDate)
          .inDays;
      // فیلتر چرخه‌های غیرعادی (کمتر از ۱۵ یا بیشتر از ۶۰ روز)
      if (diff >= 15 && diff <= 60) {
        lengths.add(diff);
      }
    }

    if (lengths.isEmpty) return cycleLength;

    final sum = lengths.reduce((a, b) => a + b);
    return (sum / lengths.length).round();
  }

  /// کوتاه‌ترین چرخه ثبت‌شده
  int? get shortestCycle {
    final history = getHistory();
    if (history.length < 2) return null;

    final lengths = <int>[];
    for (var i = 1; i < history.length; i++) {
      final diff = history[i]
          .startDate
          .difference(history[i - 1].startDate)
          .inDays;
      if (diff >= 15 && diff <= 60) lengths.add(diff);
    }
    if (lengths.isEmpty) return null;
    return lengths.reduce((a, b) => a < b ? a : b);
  }

  /// بلندترین چرخه ثبت‌شده
  int? get longestCycle {
    final history = getHistory();
    if (history.length < 2) return null;

    final lengths = <int>[];
    for (var i = 1; i < history.length; i++) {
      final diff = history[i]
          .startDate
          .difference(history[i - 1].startDate)
          .inDays;
      if (diff >= 15 && diff <= 60) lengths.add(diff);
    }
    if (lengths.isEmpty) return null;
    return lengths.reduce((a, b) => a > b ? a : b);
  }

  /// لیست طول همه چرخه‌ها (برای نمودار)
  List<CycleStat> get cycleStats {
    final history = getHistory();
    if (history.length < 2) return [];

    final stats = <CycleStat>[];
    for (var i = 1; i < history.length; i++) {
      final length = history[i]
          .startDate
          .difference(history[i - 1].startDate)
          .inDays;
      stats.add(CycleStat(
        startDate: history[i].startDate,
        length: length,
      ));
    }
    return stats;
  }
}

class CycleStat {
  final DateTime startDate;
  final int length;

  const CycleStat({required this.startDate, required this.length});
}