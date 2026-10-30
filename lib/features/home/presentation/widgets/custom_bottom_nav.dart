import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final inactiveColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // ─── آیتم‌های معمولی ─────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.check_circle_outline_rounded,
                    activeIcon: Icons.check_circle_rounded,
                    label: l10n.todo,
                    index: 0,
                    currentIndex: currentIndex,
                    inactiveColor: inactiveColor,
                    onTap: onTap,
                  ),
                  _NavItem(
                    icon: Icons.calendar_today_outlined,
                    activeIcon: Icons.calendar_today_rounded,
                    label: l10n.periodTracker,
                    index: 1,
                    currentIndex: currentIndex,
                    inactiveColor: inactiveColor,
                    onTap: onTap,
                  ),
                  // ─── فضای خالی برای دکمه وسط ─────────────
                  const SizedBox(width: 64),
                  _NavItem(
                    icon: Icons.timer_outlined,
                    activeIcon: Icons.timer_rounded,
                    label: l10n.timer,
                    index: 3,
                    currentIndex: currentIndex,
                    inactiveColor: inactiveColor,
                    onTap: onTap,
                  ),
                  _NavItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    activeIcon: Icons.chat_bubble_rounded,
                    label: l10n.chat,
                    index: 4,
                    currentIndex: currentIndex,
                    inactiveColor: inactiveColor,
                    onTap: onTap,
                  ),
                ],
              ),

              // ─── دکمه وسط برجسته (پروفایل) ──────────────
              Positioned(
                top: -28,
                child: _CenterNavItem(
                  isActive: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// ─── آیتم معمولی ──────────────────────────────────────
// ═══════════════════════════════════════════════════════
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final Color inactiveColor;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    final color = isActive ? AppColors.primary : inactiveColor;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isActive ? activeIcon : icon,
                  key: ValueKey(isActive),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// ─── دکمه وسط برجسته ──────────────────────────────────
// ═══════════════════════════════════════════════════════
class _CenterNavItem extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _CenterNavItem({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          border: Border.all(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(isActive ? 0.5 : 0.3),
              blurRadius: isActive ? 20 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          isActive ? Icons.person_rounded : Icons.person_outline_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}