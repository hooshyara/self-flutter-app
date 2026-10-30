import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/period_data.dart';

class JalaliCalendar extends StatefulWidget {
  final PeriodData data;

  const JalaliCalendar({super.key, required this.data});

  @override
  State<JalaliCalendar> createState() => _JalaliCalendarState();
}

class _JalaliCalendarState extends State<JalaliCalendar> {
  late Jalali _focusedMonth;

  static const _weekDays = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

  @override
  void initState() {
    super.initState();
    _focusedMonth = Jalali.now();
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth = _focusedMonth.month == 1
          ? Jalali(_focusedMonth.year - 1, 12, 1)
          : Jalali(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = _focusedMonth.month == 12
          ? Jalali(_focusedMonth.year + 1, 1, 1)
          : Jalali(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstOfMonth = Jalali(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = firstOfMonth.monthLength;
    final emptyCells = firstOfMonth.weekDay - 1;
    final totalCells = emptyCells + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final totalGrid = rows * 7;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // ─── هدر: ماه + دکمه‌های جابجایی ────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _prevMonth,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
              Text(
                '${firstOfMonth.formatter.mN} ${_toPersianDigits(_focusedMonth.year.toString())}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // ─── هدر هفته ─────────────────────────────
          Row(
            children: _weekDays.map((d) {
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // ─── شبکه روزها ───────────────────────────
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: totalGrid,
            itemBuilder: (context, index) {
              if (index < emptyCells || index >= emptyCells + daysInMonth) {
                return const SizedBox.shrink();
              }
              final day = index - emptyCells + 1;
              final jalali = Jalali(
                _focusedMonth.year,
                _focusedMonth.month,
                day,
              );
              return _buildDayCell(jalali, theme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(Jalali jalali, ThemeData theme) {
    final dateTime = jalali.toDateTime();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dt = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final isToday = dt == today;
    final isPeriod = widget.data.isPeriodDay(dt);
    final isPredicted = widget.data.isPredictedPeriodDay(dt);
    final isOvulation = widget.data.isOvulationDay(dt);
    final isFertile = widget.data.isFertileDay(dt);

    Color bgColor = Colors.transparent;
    Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    if (isPeriod && !isPredicted) {
      bgColor = AppColors.accent;
      textColor = Colors.white;
    } else if (isPredicted) {
      bgColor = AppColors.accent.withOpacity(0.25);
      textColor = AppColors.accent;
    } else if (isOvulation) {
      bgColor = AppColors.primary;
      textColor = Colors.white;
    } else if (isFertile) {
      bgColor = AppColors.primary.withOpacity(0.15);
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: isToday ? Border.all(color: AppColors.primary, width: 2) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        _toPersianDigits(jalali.day.toString()),
        style: TextStyle(
          fontSize: 13,
          color: textColor,
          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  String _toPersianDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    var result = input;
    for (var i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], persian[i]);
    }
    return result;
  }
}
