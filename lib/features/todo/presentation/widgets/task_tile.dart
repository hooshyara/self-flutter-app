import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../../data/models/task_model.dart';
import '../todo_colors.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = TodoColors.priority(task.priority);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border(right: BorderSide(color: color, width: 4)),
            ),
            padding: const EdgeInsets.fromLTRB(10, 14, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── چک‌باکس ──────────────────────────
                _buildCheckbox(color),

                const SizedBox(width: 10),

                // ─── محتوا ────────────────────────────
                Expanded(
                  child: Opacity(
                    opacity: task.isDone ? 0.55 : 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── عنوان با خط رویش ───────────
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            decoration: task.isDone
                                ? TextDecoration.lineThrough
                                : null,
                            decorationThickness: 2,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),

                        // ─── توضیح ──────────────────────
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],

                        // ─── تایم و اولویت ──────────────
                        if (task.startTime != null ||
                            task.endTime != null ||
                            true) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              // بج اولویت
                              _buildPriorityBadge(color),

                              // زمان شروع
                              if (task.startTime != null)
                                _buildTimeChip(
                                  Icons.play_arrow_rounded,
                                  _formatTime(task.startTime!),
                                  const Color(0xFF3B82F6),
                                ),

                              // زمان پایان
                              if (task.endTime != null)
                                _buildTimeChip(
                                  Icons.flag_rounded,
                                  _formatTime(task.endTime!),
                                  _endTimeColor(task.endTime!),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ─── چک‌باکس ────────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  Widget _buildCheckbox(Color color) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: task.isDone ? color : Colors.transparent,
          border: Border.all(
            color: task.isDone ? color : color.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: task.isDone
            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
            : null,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ─── بج اولویت ───────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  Widget _buildPriorityBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(TodoColors.priorityIcon(task.priority), size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            TodoColors.priorityLabel(task.priority),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ─── چیپ زمان ────────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  Widget _buildTimeChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ─── Helpers ────────────────────────────────────────
  // ═══════════════════════════════════════════════════════

  /// فرمت زمان: «۱۴:۳۰ - ۱۲ آبان»
  /// اگه امروزه: «۱۴:۳۰ - امروز»
  /// اگه فرداست: «۱۴:۳۰ - فردا»
  String _formatTime(DateTime dt) {
    final j = Jalali.fromDateTime(dt);
    final time =
        '${_fa(dt.hour.toString().padLeft(2, '0'))}:${_fa(dt.minute.toString().padLeft(2, '0'))}';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    final diff = date.difference(today).inDays;

    String dayLabel;
    if (diff == 0) {
      dayLabel = 'امروز';
    } else if (diff == 1) {
      dayLabel = 'فردا';
    } else if (diff == -1) {
      dayLabel = 'دیروز';
    } else {
      dayLabel = '${_fa(j.day.toString())} ${j.formatter.mN}';
    }

    return '$time · $dayLabel';
  }

  /// رنگ زمان پایان: قرمز اگه گذشته، نارنجی اگه نزدیک، عادی وگرنه
  Color _endTimeColor(DateTime end) {
    final now = DateTime.now();
    final diff = end.difference(now);
    if (diff.isNegative) return const Color(0xFFE53935); // گذشته
    if (diff.inHours < 24) return const Color(0xFFF59E0B); // نزدیک
    return const Color(0xFF10B981); // فرصت داره
  }

  String _fa(String s) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    var r = s;
    for (var i = 0; i < en.length; i++) {
      r = r.replaceAll(en[i], fa[i]);
    }
    return r;
  }
}
