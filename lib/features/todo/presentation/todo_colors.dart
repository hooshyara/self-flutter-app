import 'package:flutter/material.dart';

import '../../../data/models/task_model.dart';

/// رنگ‌بندی مربوط به اولویت‌ها.
class TodoColors {
  TodoColors._();

  // ─── رنگ اصلی هر اولویت ────────────────────────────
  static Color priority(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return const Color(0xFFE53935); // قرمز
      case TaskPriority.medium:
        return const Color(0xFFF59E0B); // نارنجی
      case TaskPriority.low:
        return const Color(0xFF10B981); // سبز
    }
  }

  // ─── نسخه کم‌رنگ برای پس‌زمینه ─────────────────────
  static Color prioritySoft(TaskPriority p) => priority(p).withOpacity(0.12);

  // ─── لیبل فارسی ─────────────────────────────────────
  static String priorityLabel(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return 'زیاد';
      case TaskPriority.medium:
        return 'متوسط';
      case TaskPriority.low:
        return 'کم';
    }
  }

  // ─── آیکون ──────────────────────────────────────────
  static IconData priorityIcon(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return Icons.keyboard_double_arrow_up_rounded;
      case TaskPriority.medium:
        return Icons.drag_handle_rounded;
      case TaskPriority.low:
        return Icons.keyboard_arrow_down_rounded;
    }
  }
}
