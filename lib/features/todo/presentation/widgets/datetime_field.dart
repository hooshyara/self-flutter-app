import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../../core/constants/app_colors.dart';

class DateTimeField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final Color accentColor;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const DateTimeField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.accentColor,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = value != null;

    return GestureDetector(
      onTap: onPick,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: hasValue
              ? accentColor.withOpacity(0.08)
              : theme.scaffoldBackgroundColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasValue ? accentColor.withOpacity(0.4) : theme.dividerColor,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: hasValue ? accentColor : theme.textTheme.bodySmall?.color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasValue ? _format(value!) : 'انتخاب نشده',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: hasValue
                          ? theme.textTheme.bodyLarge?.color
                          : theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            if (hasValue)
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                color: AppColors.error,
                onPressed: onClear,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'پاک کردن',
              ),
          ],
        ),
      ),
    );
  }

  String _format(DateTime dt) {
    final j = Jalali.fromDateTime(dt);
    final h = _fa(dt.hour.toString().padLeft(2, '0'));
    final m = _fa(dt.minute.toString().padLeft(2, '0'));
    return '${_fa(j.day.toString())} ${j.formatter.mN} · $h:$m';
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
