import 'dart:convert';

/// اولویت‌های ممکن برای یه کار.
enum TaskPriority {
  low, // کم — آبی/سبز
  medium, // متوسط — نارنجی/زرد
  high, // زیاد — قرمز
}

/// مدل یک کار در تسک‌لیست.
class Task {
  final String id; // شناسه یکتا
  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime? startTime; // اختیاری
  final DateTime? endTime; // اختیاری
  final bool isDone;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.priority = TaskPriority.medium,
    this.startTime,
    this.endTime,
    this.isDone = false,
    required this.createdAt,
  });

  // ─── کپی با تغییرات ──────────────────────────────────
  Task copyWith({
    String? title,
    String? description,
    TaskPriority? priority,
    DateTime? startTime,
    DateTime? endTime,
    bool? isDone,
    bool clearStartTime = false,
    bool clearEndTime = false,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      startTime: clearStartTime ? null : (startTime ?? this.startTime),
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
      isDone: isDone ?? this.isDone,
      createdAt: createdAt,
    );
  }

  // ─── ذخیره‌سازی ───────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isDone': isDone,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<dynamic, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == (map['priority'] as String? ?? 'medium'),
        orElse: () => TaskPriority.medium,
      ),
      startTime: map['startTime'] != null
          ? DateTime.parse(map['startTime'] as String)
          : null,
      endTime: map['endTime'] != null
          ? DateTime.parse(map['endTime'] as String)
          : null,
      isDone: (map['isDone'] as bool?) ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Task.fromJson(String json) =>
      Task.fromMap(jsonDecode(json) as Map<String, dynamic>);
}
