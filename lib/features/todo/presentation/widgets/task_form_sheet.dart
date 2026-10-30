import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/task_model.dart';
import '../../../../data/repositories/task_repository.dart';
import 'datetime_field.dart';
import 'priority_selector.dart';

class TaskFormSheet extends StatefulWidget {
  final Task? existing;

  const TaskFormSheet({super.key, this.existing});

  static Future<bool?> show(BuildContext context, {Task? existing}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskFormSheet(existing: existing),
    );
  }

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  final _repo = TaskRepository();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  late TaskPriority _priority;
  DateTime? _startTime;
  DateTime? _endTime;
  String? _error;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _titleCtrl.text = e.title;
      _descCtrl.text = e.description;
      _priority = e.priority;
      _startTime = e.startTime;
      _endTime = e.endTime;
    } else {
      _priority = TaskPriority.medium;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════
  // ─── انتخاب تاریخ و زمان (شمسی) ────────────────────
  // ═══════════════════════════════════════════════════════
  Future<void> _pickDateTime({
    required DateTime? initial,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final now = DateTime.now();
    final initDate = initial ?? now;

    // ─── مرحله ۱: انتخاب تاریخ شمسی ──────────────────
    final pickedDate = await showPersianDatePicker(
      context: context,
      initialDate: Jalali.fromDateTime(initDate), // ← حتماً Jalali باشه
      firstDate: Jalali.fromDateTime(now.subtract(const Duration(days: 30))),
      lastDate: Jalali.fromDateTime(now.add(const Duration(days: 365))),
    );
    if (pickedDate == null || !mounted) return;

    // ─── مرحله ۲: انتخاب ساعت ────────────────────────
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initDate),
    );
    if (pickedTime == null || !mounted) return;

    // ─── تبدیل تاریخ شمسی به میلادی برای ذخیره ──────
    final miladi = pickedDate.toDateTime();
    onPicked(
      DateTime(
        miladi.year,
        miladi.month,
        miladi.day,
        pickedTime.hour,
        pickedTime.minute,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ─── ذخیره ───────────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  Future<void> _save() async {
    final title = _titleCtrl.text.trim();

    if (title.isEmpty) {
      setState(() => _error = 'عنوان کار الزامی است');
      return;
    }

    if (_startTime != null &&
        _endTime != null &&
        _endTime!.isBefore(_startTime!)) {
      setState(() => _error = 'زمان پایان باید بعد از زمان شروع باشد');
      return;
    }

    if (_isEditing) {
      final updated = widget.existing!.copyWith(
        title: title,
        description: _descCtrl.text.trim(),
        priority: _priority,
        startTime: _startTime,
        endTime: _endTime,
        clearStartTime: _startTime == null,
        clearEndTime: _endTime == null,
      );
      await _repo.update(updated);
    } else {
      await _repo.add(
        title: title,
        description: _descCtrl.text.trim(),
        priority: _priority,
        startTime: _startTime,
        endTime: _endTime,
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  // ═══════════════════════════════════════════════════════
  // ─── BUILD ──────────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 12),
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _isEditing
                            ? Icons.edit_rounded
                            : Icons.add_task_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isEditing ? 'ویرایش کار' : 'کار جدید',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('عنوان', required: true),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _titleCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'مثلاً: جلسه با تیم',
                          prefixIcon: Icon(Icons.title_rounded),
                        ),
                        onChanged: (_) {
                          if (_error != null) {
                            setState(() => _error = null);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('توضیح'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _descCtrl,
                        maxLines: 3,
                        minLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'توضیحات اضافه (اختیاری)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('اولویت'),
                      const SizedBox(height: 6),
                      PrioritySelector(
                        value: _priority,
                        onChanged: (p) => setState(() => _priority = p),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('زمان شروع'),
                      const SizedBox(height: 6),
                      DateTimeField(
                        label: 'شروع از',
                        icon: Icons.play_arrow_rounded,
                        value: _startTime,
                        accentColor: const Color(0xFF3B82F6),
                        onPick: () => _pickDateTime(
                          initial: _startTime,
                          onPicked: (d) => setState(() => _startTime = d),
                        ),
                        onClear: () => setState(() => _startTime = null),
                      ),
                      const SizedBox(height: 12),
                      _buildLabel('زمان پایان'),
                      const SizedBox(height: 6),
                      DateTimeField(
                        label: 'پایان تا',
                        icon: Icons.flag_rounded,
                        value: _endTime,
                        accentColor: const Color(0xFF10B981),
                        onPick: () => _pickDateTime(
                          initial: _endTime,
                          onPicked: (d) => setState(() => _endTime = d),
                        ),
                        onClear: () => setState(() => _endTime = null),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.error.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.error,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(color: AppColors.error, fontSize: 13),
          ),
        ],
      ],
    );
  }

  Widget _buildSaveButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _save,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isEditing ? Icons.check_rounded : Icons.add_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  _isEditing ? 'ذخیره تغییرات' : 'افزودن کار',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
