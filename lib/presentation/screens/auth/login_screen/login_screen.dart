// lib/presentation/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';
import '../../../controllers/auth/login_controller.dart';
import 'login_layout_spec.dart';
import 'widgets/login_brand_header.dart';
import 'widgets/login_email_field.dart';
import 'widgets/login_error_banner.dart';
import 'widgets/login_footer_links.dart';
import 'widgets/login_google_button.dart';
import 'widgets/login_greeting.dart';
import 'widgets/login_guest_button.dart';
import 'widgets/login_live_teaser.dart';
import 'widgets/login_or_divider.dart';
import 'widgets/login_password_field.dart';
import 'widgets/login_submit_button.dart';

// ═══════════════════════════════════════════════════════════
// LOGIN SCREEN — Stitch "Login - ÜniTV" tasarımının bire bir
// karşılığı. Tüm renkler AppTheme/ColorScheme üzerinden
// geldiği için light & dark tema otomatik desteklenir.
//
// NOT: Ambient glow Stack'i body seviyesinde (Scaffold = bounded),
// scroll içeriği Positioned.fill üzerinde. SingleChildScrollView
// sınırsız yükseklik verdiği için Stack asla scroll içinde olamaz.
// ═══════════════════════════════════════════════════════════

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // KURAL 5 — TEK DALLANMA NOKTASI
    final LoginSizes sizes = Responsive.isTablet(context)
        ? const LoginTabletSizes()
        : const LoginPhoneSizes();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      // ── Stack body seviyesinde: Scaffold bounded verir ✅ ──
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Ambient Luminous Background Glow (-z-10) ─────
          _AmbientGlows(sizes: sizes),

          // ── Scroll içeriği ───────────────────────────────
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: sizes.pageHPadding,
                  vertical: sizes.pageVPadding,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: sizes.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Brand Logo Header
                        LoginBrandHeader(sizes: sizes)
                            .animate()
                            .fadeIn(duration: 350.ms)
                            .slideY(
                              begin: -0.08,
                              end: 0,
                              duration: 450.ms,
                              curve: Curves.easeOutCubic,
                            ),

                        SizedBox(height: sizes.brandBottomGap),

                        // Greeting & Description
                        LoginGreeting(
                          sizes: sizes,
                        ).animate().fadeIn(delay: 120.ms, duration: 400.ms),

                        SizedBox(height: sizes.greetingBottomGap),

                        // Login Form Card
                        _LoginFormCard(sizes: sizes)
                            .animate()
                            .fadeIn(delay: 220.ms, duration: 400.ms)
                            .slideY(
                              begin: 0.06,
                              end: 0,
                              duration: 500.ms,
                              curve: Curves.easeOutCubic,
                            ),

                        SizedBox(height: sizes.footerTopGap),

                        // Register Footer Redirect
                        LoginFooterLinks(
                          sizes: sizes,
                        ).animate().fadeIn(delay: 320.ms, duration: 400.ms),

                        SizedBox(height: sizes.teaserTopGap),

                        // Campus Live Stream Preview Accent Teaser
                        LoginLiveTeaser(
                          sizes: sizes,
                        ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// AMBIENT GLOWS — bg-primary/10 blur-3xl (üst-orta) +
// bg-secondary-container/10 blur-2xl (üst-sağ).
// Scaffold body'si sınırlı olduğu için Positioned'lı Stack
// burada güvenle çalışır. Her çocuğun boyutu SizedBox ile
// sabit olduğu için Positioned olmasa bile sorun çıkmazdı,
// ama tasarım konumları için Positioned kullanılıyor.
// ═══════════════════════════════════════════════════════════

class _AmbientGlows extends StatelessWidget {
  const _AmbientGlows({required this.sizes});

  final LoginSizes sizes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // -top-12: primary glow, içeriğin hemen üstünde ortalanmış
          Positioned(
            top: sizes.glowPrimaryTop, // negatif değer Stack'te geçerli
            left: 0,
            right: 0,
            child: Center(
              child: _GlowCircle(
                size: sizes.glowPrimarySize,
                color: scheme.primary.withValues(alpha: 0.10),
              ),
            ),
          ),
          // top-48 / -right-12: secondary glow
          Positioned(
            top: sizes.glowSecondaryTop,
            right: sizes.glowSecondaryRight,
            child: _GlowCircle(
              size: sizes.glowSecondarySize,
              color: scheme.secondaryContainer.withValues(alpha: 0.10),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// LOGIN FORM CARD — surface-container-low, rounded-xl, p-6,
// iç children arası gap-4 (space-md)
// ═══════════════════════════════════════════════════════════

class _LoginFormCard extends StatefulWidget {
  final LoginSizes sizes;
  const _LoginFormCard({required this.sizes});

  @override
  State<_LoginFormCard> createState() => _LoginFormCardState();
}

class _LoginFormCardState extends State<_LoginFormCard> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;

  LoginController get _auth => Get.find<LoginController>();
  LoginSizes get _sizes => widget.sizes;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await _auth.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _continueAsGuest() => Get.offAllNamed(AppRoutes.home);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = _sizes;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(s.cardPadding),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow, // bg-surface-container-low
        borderRadius: BorderRadius.circular(s.cardRadius), // rounded-xl
        boxShadow: [
          BoxShadow(
            // shadow-md
            color: Colors.black.withValues(
              alpha: AppTheme.isDark(context) ? 0.25 : 0.08,
            ),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Email Input Field ──────────────────────
            LoginEmailField(
              controller: _emailController,
              sizes: s,
              onSubmitted: (_) => _passwordFocus.requestFocus(),
            ),

            SizedBox(height: s.cardGap),

            // ── Password Input Field ───────────────────
            LoginPasswordField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              sizes: s,
              obscure: _obscurePassword,
              onToggleObscure: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              onSubmitted: (_) => _submit(),
            ),

            // ── Forgot Password Link (-mt-1, sağa hizalı) ──
            Transform.translate(
              offset: Offset(0, -s.forgotTopOffset),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.primary,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                  child: Text(
                    'Şifremi unuttum',
                    style: TextStyle(
                      color: scheme.primary,
                      fontSize: s.fieldLabelFontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.02 * s.fieldLabelFontSize,
                    ),
                  ),
                ),
              ),
            ),

            // ── Hata mesajı ────────────────────────────
            LoginErrorBanner(sizes: s),

            // ── Submit CTA (gap-4 + mt-1) ──────────────
            SizedBox(height: s.cardGap + s.submitTopGap),
            LoginSubmitButton(sizes: s, onPressed: _submit),

            SizedBox(height: s.cardGap),

            // ── Divider ────────────────────────────────
            LoginOrDivider(sizes: s),

            SizedBox(height: s.cardGap),

            // ── Google Sign-In ─────────────────────────
            LoginGoogleButton(sizes: s),

            SizedBox(height: s.cardGap),

            // ── Guest Access ───────────────────────────
            LoginGuestButton(sizes: s, onPressed: _continueAsGuest),
          ],
        ),
      ),
    );
  }
}
