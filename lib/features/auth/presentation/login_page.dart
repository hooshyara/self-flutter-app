import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/theme_provider.dart';
import 'auth_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ─── کنترلرها ────────────────────────────────────────
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // ─── state داخلی ─────────────────────────────────────
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  // ─── کاربر ثابت ──────────────────────────────────────
  static const String _validUsername = 'arian';
  static const String _validPassword = '123';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() => _errorMessage = null);

    if (_usernameController.text.trim().isEmpty) {
      setState(() => _errorMessage = l10n.usernameRequired);
      return;
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = l10n.passwordRequired);
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    if (_usernameController.text.trim() == _validUsername &&
        _passwordController.text == _validPassword) {
      context.go('${AppRoutes.home}?tab=${AppRoutes.profileTab}');
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = l10n.invalidCredentials;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textColor = isDark
        ? const Color(0xFFF5F5F7)
        : const Color(0xFF1A1A2E);
    final subTextColor = isDark
        ? const Color(0xFF9CA3AF)
        : const Color(0xFF6B7280);

    return Scaffold(
      body: Stack(
        children: [
          // ─── لایه ۱: پس‌زمینه گرادیانت ─────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark ? AuthColors.darkBg : AuthColors.lightBg,
                ),
              ),
            ),
          ),

          // ─── لایه ۲: حباب بالا-راست ────────────────────
          Positioned(
            top: -120,
            right: -100,
            child: _buildBlob(
              size: 320,
              colors: [
                AuthColors.blobPrimary.withOpacity(isDark ? 0.15 : 0.30),
                AuthColors.blobPrimaryLight.withOpacity(isDark ? 0.05 : 0.10),
                Colors.transparent,
              ],
            ),
          ),

          // ─── لایه ۳: حباب پایین-چپ ────────────────────
          Positioned(
            bottom: -120,
            left: -100,
            child: _buildBlob(
              size: 300,
              colors: [
                AuthColors.blobAccent.withOpacity(isDark ? 0.12 : 0.25),
                AuthColors.blobAccentLight.withOpacity(isDark ? 0.04 : 0.08),
                Colors.transparent,
              ],
            ),
          ),

          // ─── لایه ۴: محتوا ─────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 24),
                      _buildHeader(l10n, textColor, subTextColor),
                      const SizedBox(height: 40),
                      _buildGlassCard(
                        isDark: isDark,
                        l10n: l10n,
                        textColor: textColor,
                      ),
                      const SizedBox(height: 32),
                      _buildFooter(subTextColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ─── ویجت‌های کمکی ────────────────────────────────────
  // ═══════════════════════════════════════════════════════

  // ─── حباب ────────────────────────────────────────────
  Widget _buildBlob({required double size, required List<Color> colors}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }

  // ─── لوگو ────────────────────────────────────────────
  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AuthColors.logoGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: AuthColors.blobPrimary.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Icon(
        Icons.lock_outline_rounded,
        color: Colors.white,
        size: 44,
      ),
    );
  }

  // ─── هدر (عنوان + زیرعنوان) ─────────────────────────
  Widget _buildHeader(
    AppLocalizations l10n,
    Color textColor,
    Color subTextColor,
  ) {
    return Column(
      children: [
        Text(
          l10n.welcome,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.appName,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: subTextColor),
        ),
        const SizedBox(height: 16),
        // خط تزئینی کوچیک
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: AuthColors.blobPrimary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  // ─── کارت شیشه‌ای ─────────────────────────────────────
  Widget _buildGlassCard({
    required bool isDark,
    required AppLocalizations l10n,
    required Color textColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withOpacity(0.25)
                : Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.10)
                  : Colors.white.withOpacity(0.30),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUsernameField(l10n),
              const SizedBox(height: 20),
              _buildPasswordField(l10n),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                _buildErrorBox(),
              ],
              const SizedBox(height: 24),
              _buildLoginButton(l10n),
            ],
          ),
        ),
      ),
    );
  }

  // ─── فیلد نام کاربری ──────────────────────────────────
  Widget _buildUsernameField(AppLocalizations l10n) {
    return TextField(
      controller: _usernameController,
      textInputAction: TextInputAction.next,
      enabled: !_isLoading,
      decoration: InputDecoration(
        labelText: l10n.username,
        prefixIcon: const Icon(Icons.person_outline_rounded),
      ),
    );
  }

  // ─── فیلد رمز عبور ────────────────────────────────────
  Widget _buildPasswordField(AppLocalizations l10n) {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      enabled: !_isLoading,
      onSubmitted: (_) => _handleLogin(),
      decoration: InputDecoration(
        labelText: l10n.password,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
      ),
    );
  }

  // ─── جعبه خطا ─────────────────────────────────────────
  Widget _buildErrorBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFF44336),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Color(0xFFF44336), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ─── دکمه ورود ────────────────────────────────────────
  Widget _buildLoginButton(AppLocalizations l10n) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: AuthColors.buttonGradient,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AuthColors.blobPrimary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isLoading ? null : _handleLogin,
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    l10n.loginButton,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ─── footer ───────────────────────────────────────────
  Widget _buildFooter(Color subTextColor) {
    return Text(
      'Powered by Arian Hooshyar @2026',
      style: TextStyle(fontSize: 12, color: subTextColor),
    );
  }
}
