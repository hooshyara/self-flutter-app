import 'dart:convert';

/// یک رکورد از چرخه قاعدگی.
/// فقط تاریخ شروع رو ذخیره می‌کنیم. طول چرخه بعداً از فاصله
/// بین این رکوردها محاسبه می‌شه.
class CycleRecord {
  final DateTime startDate;
  final int? periodLength; // اختیاری: طول دوره خونریزی این چرخه

  const CycleRecord({required this.startDate, this.periodLength});

  // ─── تبدیل به Map برای ذخیره در Hive ─────────────────
  Map<String, dynamic> toMap() {
    return {
      'startDate': startDate.toIso8601String(),
      'periodLength': periodLength,
    };
  }

  // ─── ساخت از Map ──────────────────────────────────────
  factory CycleRecord.fromMap(Map<dynamic, dynamic> map) {
    return CycleRecord(
      startDate: DateTime.parse(map['startDate'] as String),
      periodLength: map['periodLength'] as int?,
    );
  }

  // ─── برای ذخیره به صورت JSON string ───────────────────
  // دلیل: Hive می‌تونه Map ذخیره کنه ولی توی لیست‌ها
  // به مشکل می‌خوره. JSON string مطمئن‌تره.
  String toJson() => jsonEncode(toMap());

  factory CycleRecord.fromJson(String json) {
    return CycleRecord.fromMap(jsonDecode(json) as Map<String, dynamic>);
  }

  @override
  String toString() =>
      'CycleRecord(start: ${startDate.toIso8601String()}, periodLength: $periodLength)';
}
