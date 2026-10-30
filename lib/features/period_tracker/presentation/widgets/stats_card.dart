import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/repositories/period_repository.dart';

/// کارت آماری که میانگین، کوتاه‌ترین و بلندترین چرخه رو نشون می‌ده.
class StatsCard extends StatelessWidget {
  final PeriodRepository repo;

  const StatsCard({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final history = repo.getHistory();
    final hasEnough = history.length >= 2;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── هدر ─────────────────────────────────────
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'آمار چرخه‌ها',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_toPersianDigits(history.length.toString())} چرخه',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ─── محتوا ────────────────────────────────────
          if (!hasEnough) _buildEmptyState(theme) else _buildStats(theme),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ─── حالت خالی ──────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary.withOpacity(0.6),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'برای دیدن میانگین و آمار، حداقل دو چرخه ثبت کن.',
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ─── نمایش آمار ──────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  Widget _buildStats(ThemeData theme) {
    final avg = repo.averageCycleLength;
    final shortest = repo.shortestCycle ?? avg;
    final longest = repo.longestCycle ?? avg;

    // ─── اختلاف با تنظیمات کاربر ──────────────────────
    final diff = avg - repo.cycleLength;
    final diffLabel = diff == 0
        ? 'برابر با تنظیم تو'
        : diff > 0
        ? '${_toPersianDigits(diff.toString())} روز بیشتر از تنظیم تو'
        : '${_toPersianDigits((-diff).toString())} روز کمتر از تنظیم تو';

    return Column(
      children: [
        // ─── میانگین اصلی ────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.primary.withOpacity(0.12),
                AppColors.accent.withOpacity(0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'میانگین طول چرخه',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    diffLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: _toPersianDigits(avg.toString()),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w300,
                        color: AppColors.primary,
                        height: 1,
                      ),
                    ),
                    const TextSpan(
                      text: ' روز',
                      style: TextStyle(fontSize: 13, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ─── کوتاه‌ترین و بلندترین ────────────────────
        Row(
          children: [
            Expanded(
              child: _buildMiniStat(
                icon: Icons.trending_down_rounded,
                label: 'کوتاه‌ترین',
                value: shortest,
                color: AppColors.success,
                theme: theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMiniStat(
                icon: Icons.trending_up_rounded,
                label: 'بلندترین',
                value: longest,
                color: AppColors.accent,
                theme: theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${_toPersianDigits(value.toString())} روز',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
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
