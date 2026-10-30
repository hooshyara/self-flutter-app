import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/theme_provider.dart';
import 'profile_data.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // مسیر عکس انتخاب‌شده (فعلاً فقط توی حافظه)
  String? _avatarPath;

  // پکیج image_picker
  final _picker = ImagePicker();

  // ─── انتخاب عکس از گالری ─────────────────────────────
  Future<void> _pickAvatar() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (file == null) return; // کاربر کنسل کرد
      if (!mounted) return;

      setState(() => _avatarPath = file.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('خطا در انتخاب عکس: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ─── آواتار با قابلیت تغییر ─────────────────
            _buildAvatar(theme),

            const SizedBox(height: 16),

            // ─── نام و handle ──────────────────────────
            Text(
              ProfileData.username,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              ProfileData.handle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ProfileData.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            // ─── کارت bio ──────────────────────────────
            _buildBioCard(theme),
            const SizedBox(height: 24),

            // ─── کارت تنظیمات ──────────────────────────
            Card(
              child: Column(
                children: [
                  _SettingTile(
                    icon: themeProvider.isDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    title: l10n.theme,
                    subtitle: themeProvider.isDarkMode
                        ? l10n.darkMode
                        : l10n.lightMode,
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (_) => themeProvider.toggleTheme(),
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingTile(
                    icon: Icons.language_rounded,
                    title: l10n.language,
                    subtitle: localeProvider.isPersian
                        ? l10n.persian
                        : l10n.english,
                    trailing: Switch(
                      value: localeProvider.isPersian,
                      onChanged: (_) => localeProvider.toggleLocale(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── دکمه خروج ─────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.login),
                icon: const Icon(Icons.logout_rounded),
                label: Text(l10n.logout),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ─── آواتار ───────────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  Widget _buildAvatar(ThemeData theme) {
    return GestureDetector(
      onTap: _pickAvatar,
      child: Stack(
        children: [
          // ─── خود آواتار ────────────────────────────
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(child: _buildAvatarContent()),
          ),

          // ─── آیکون دوربین کوچیک ────────────────────
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent() {
    // ─── حالت ۱: عکس انتخاب شده ──────────────────────
    if (_avatarPath != null) {
      // روی وب نمی‌شه از File استفاده کرد
      if (kIsWeb) {
        return Image.network(_avatarPath!, fit: BoxFit.cover);
      }
      return Image.file(
        File(_avatarPath!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultAvatarIcon(),
      );
    }

    // ─── حالت ۲: آواتار پیش‌فرض ──────────────────────
    return _defaultAvatarIcon();
  }

  Widget _defaultAvatarIcon() {
    return Container(
      color: Colors.transparent,
      alignment: Alignment.center,
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 65),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ─── کارت bio ─────────────────────────────────────────
  // ═══════════════════════════════════════════════════════
  Widget _buildBioCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── عنوان ────────────────────────────────
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'درباره من',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ─── هر خط bio ────────────────────────────
            ...ProfileData.bio.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        line.icon,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          line.text,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// ─── آیتم تنظیمات ──────────────────────────────────────
// ═══════════════════════════════════════════════════════
class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: trailing,
    );
  }
}
