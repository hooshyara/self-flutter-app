import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/task_repository.dart';
import 'widgets/task_form_sheet.dart';
import 'widgets/task_tile.dart';

enum _Filter { all, active, done }

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final _repo = TaskRepository();
  _Filter _filter = _Filter.all;

  // ═══════════════════════════════════════════════════════
  // ─── عملیات ─────────────────────────────────────────
  // ═══════════════════════════════════════════════════════

  Future<void> _toggle(Task task) async {
    await _repo.toggleDone(task.id);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _confirmDelete(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف کار'),
        content: Text('مطمئنی می‌خوای «${task.title}» رو حذف کنی؟'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _repo.delete(task.id);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('کار حذف شد')));
  }

  Future<void> _openForm({Task? existing}) async {
    final result = await TaskFormSheet.show(context, existing: existing);
    if (result == true && mounted) setState(() {});
  }

  List<Task> _filtered() {
    final all = _repo.getAll();
    switch (_filter) {
      case _Filter.all:
        return all;
      case _Filter.active:
        return all.where((t) => !t.isDone).toList();
      case _Filter.done:
        return all.where((t) => t.isDone).toList();
    }
  }

  // ═══════════════════════════════════════════════════════
  // ─── BUILD ──────────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final tasks = _filtered();
    final activeCount = _repo.getAll().where((t) => !t.isDone).length;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.todo)),
      body: Column(
        children: [
          // ─── هدر با تعداد ──────────────────────────
          _buildHeader(activeCount, theme),

          // ─── فیلتر چیپ‌ها ─────────────────────────
          _buildFilters(theme),

          const SizedBox(height: 8),

          // ─── لیست کارها ──────────────────────────
          Expanded(
            child: tasks.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: tasks.length,
                    itemBuilder: (context, i) {
                      final task = tasks[i];
                      return Dismissible(
                        key: ValueKey(task.id),
                        direction: DismissDirection.startToEnd,
                        confirmDismiss: (_) async {
                          await _confirmDelete(task);
                          return false;
                        },
                        background: _buildSwipeBackground(),
                        child: TaskTile(
                          task: task,
                          onToggle: () => _toggle(task),
                          onTap: () => _openForm(existing: task),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ─── FAB ────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  Widget _buildFab() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ─── هدر ────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  Widget _buildHeader(int activeCount, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.checklist_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'کارهای من',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activeCount == 0
                      ? 'همه کارها انجام شده ✨'
                      : '$activeCount کار فعال داری',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ─── فیلترها ────────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  Widget _buildFilters(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip(
            label: 'همه',
            value: _Filter.all,
            icon: Icons.apps_rounded,
            theme: theme,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'فعال',
            value: _Filter.active,
            icon: Icons.radio_button_unchecked_rounded,
            theme: theme,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'انجام‌شده',
            value: _Filter.done,
            icon: Icons.check_circle_outline_rounded,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required _Filter value,
    required IconData icon,
    required ThemeData theme,
  }) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ─── حالت خالی ──────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _filter == _Filter.done
                  ? Icons.check_circle_outline_rounded
                  : Icons.inbox_rounded,
              size: 48,
              color: AppColors.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _filter == _Filter.done
                ? 'هنوز کاری انجام نشده'
                : 'هنوز کاری نداری',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'با دکمه + یه کار جدید بساز',
            style: TextStyle(
              fontSize: 13,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ─── پس‌زمینه Swipe ─────────────────────────────────
  // ═══════════════════════════════════════════════════════
  Widget _buildSwipeBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: AlignmentDirectional.centerStart,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline_rounded, color: AppColors.error),
          SizedBox(width: 8),
          Text(
            'حذف',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
