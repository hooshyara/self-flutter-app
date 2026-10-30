import 'package:flutter/material.dart';

import '../../../../data/models/task_model.dart';
import '../todo_colors.dart';

class PrioritySelector extends StatelessWidget {
  final TaskPriority value;
  final ValueChanged<TaskPriority> onChanged;

  const PrioritySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TaskPriority.values.reversed.map((p) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildCard(p),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCard(TaskPriority p) {
    final color = TodoColors.priority(p);
    final selected = value == p;

    return GestureDetector(
      onTap: () => onChanged(p),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : color.withOpacity(0.25),
            width: selected ? 2 : 1.2,
          ),
        ),
        child: Column(
          children: [
            Icon(TodoColors.priorityIcon(p), color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              TodoColors.priorityLabel(p),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
