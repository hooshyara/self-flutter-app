import 'package:hive_flutter/hive_flutter.dart';

/// سرویس مرکزی Hive.
/// همه باکس‌ها (Box) از اینجا باز و بسته می‌شن.
class HiveService {
  HiveService._();

  // ─── اسم باکس‌ها ──────────────────────────────────────
  static const String periodBox = 'period_box';
  static const String historyBox = 'history_box';
  static const String settingsBox = 'settings_box';

  // ─── کلیدها ───────────────────────────────────────────
  static const String kLastPeriodStart = 'last_period_start';
  static const String kCycleLength = 'cycle_length';
  static const String kPeriodLength = 'period_length';
  static const String kNotificationsEnabled = 'notifications_enabled';
  static const String kDaysBeforeNotify = 'days_before_notify';
  static const String tasksBox = 'tasks_box';

  /// توی main() قبل از runApp صدا زده می‌شه.
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(periodBox);
    await Hive.openBox(historyBox);
    await Hive.openBox(settingsBox);
    await Hive.openBox(tasksBox);
  }

  // ─── دسترسی راحت به باکس‌ها ──────────────────────────
  static Box get period => Hive.box(periodBox);
  static Box get history => Hive.box(historyBox);
  static Box get settings => Hive.box(settingsBox);
  static Box get tasks => Hive.box(tasksBox);
}
