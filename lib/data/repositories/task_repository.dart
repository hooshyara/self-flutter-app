import 'dart:convert';

import '../../core/services/hive_service.dart';
import '../models/task_model.dart';

class TaskRepository {
  static const String _kTasksList = 'tasks_list';

  // ═══════════════════════════════════════════════════════
  // ─── خواندن ──────────────────────────────────────────
  // ═══════════════════════════════════════════════════════

  /// همه کارها، مرتب شده:
  /// ۱. انجام‌نشده‌ها اول
  /// ۲. بعد بر اساس اولویت (بالا به پایین)
  /// ۳. بعد بر اساس تاریخ (قدیمی‌تر اول)
  List<Task> getAll() {
    final tasks = _readRaw();

    tasks.sort((a, b) {
      // ۱. انجام‌شده‌ها آخر
      if (a.isDone != b.isDone) {
        return a.isDone ? 1 : -1;
      }
      // ۲. اولویت بالا اول
      if (a.priority != b.priority) {
        return b.priority.index.compareTo(a.priority.index);
      }
      // ۳. زودتر ساخته شده، اول
      return a.createdAt.compareTo(b.createdAt);
    });

    return tasks;
  }

  // ═══════════════════════════════════════════════════════
  // ─── افزودن ──────────────────────────────────────────
  // ═══════════════════════════════════════════════════════

  Future<Task> add({
    required String title,
    String description = '',
    TaskPriority priority = TaskPriority.medium,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final task = Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      description: description,
      priority: priority,
      startTime: startTime,
      endTime: endTime,
      createdAt: DateTime.now(),
    );

    final tasks = _readRaw();
    tasks.add(task);
    await _saveAll(tasks);

    return task;
  }

  // ═══════════════════════════════════════════════════════
  // ─── ویرایش ──────────────────────────────────────────
  // ═══════════════════════════════════════════════════════

  Future<void> update(Task updated) async {
    final tasks = _readRaw();
    final index = tasks.indexWhere((t) => t.id == updated.id);
    if (index == -1) return;

    tasks[index] = updated;
    await _saveAll(tasks);
  }

  /// سوییچ کردن وضعیت انجام‌شده.
  Future<void> toggleDone(String id) async {
    final tasks = _readRaw();
    final index = tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final task = tasks[index];
    tasks[index] = task.copyWith(isDone: !task.isDone);
    await _saveAll(tasks);
  }

  // ═══════════════════════════════════════════════════════
  // ─── حذف ─────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════

  Future<void> delete(String id) async {
    final tasks = _readRaw();
    tasks.removeWhere((t) => t.id == id);
    await _saveAll(tasks);
  }

  Future<void> clearAll() async {
    await HiveService.tasks.delete(_kTasksList);
  }

  // ═══════════════════════════════════════════════════════
  // ─── Helpers ─────────────────────────────────────────
  // ═══════════════════════════════════════════════════════

  List<Task> _readRaw() {
    final raw = HiveService.tasks.get(_kTasksList);
    if (raw == null) return [];

    if (raw is String) {
      try {
        final list = jsonDecode(raw) as List;
        return list.map((e) => Task.fromJson(e as String)).toList();
      } catch (_) {
        return [];
      }
    }

    if (raw is List) {
      return raw
          .map((e) {
            if (e is String) return Task.fromJson(e);
            if (e is Map) return Task.fromMap(e);
            return null;
          })
          .whereType<Task>()
          .toList();
    }

    return [];
  }

  Future<void> _saveAll(List<Task> tasks) async {
    final encoded = tasks.map((t) => t.toJson()).toList();
    await HiveService.tasks.put(_kTasksList, jsonEncode(encoded));
  }
}
