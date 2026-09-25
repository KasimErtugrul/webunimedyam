// lib/presentation/screens/auth/widgets/auth_hero_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../../../app/themes/app_theme.dart';

/// Auth ekranları için ortak gradient hero.
/// İçeriği parametreli — ikon, başlık, alt başlık verilir.
class AuthHeroSection extends StatelessWidget {
  final double height;
  final double iconBoxSize;
  final double iconSize;
  final double iconRadius;
  final IconData icon;
  final String title;
  final String subtitle;
  final double titleFontSize;
  final double subtitleFontSize;
  final double titleSpacing;
  final double subtitleSpacing;
  final double backButtonSize;
  final double backButtonPadding;
  final bool showBackButton;

  const AuthHeroSection({
    super.key,
    required this.height,
    required this.iconBoxSize,
    required this.iconSize,
    required this.iconRadius,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.titleSpacing,
    required this.subtitleSpacing,
    required this.backButtonSize,
    required this.backButtonPadding,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final primary = AppTheme.primaryColor;

    return SizedBox(
      height: height + topInset,
      child: Stack(
        children: [
          // ── Gradient arka plan ──
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, Color(0xFF0F5C2A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: -40,
                    top: topInset - 30,
                    child: _Blob(size: 180, opacity: 0.10),
                  ),
                  Positioned(
                    left: -30,
                    bottom: -40,
                    child: _Blob(size: 140, opacity: 0.08),
                  ),
                  Positioned(
                    left: 80,
                    top: topInset + 40,
                    child: _Blob(size: 60, opacity: 0.06),
                  ),
                ],
              ),
            ),
          ),

          // ── Floating back button ──
          if (showBackButton)
            Positioned(
              top: topInset + 8,
              left: 8,
              child: Material(
                color: Colors.white.withValues(alpha: 0.15),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: Get.back,
                  child: Padding(
                    padding: EdgeInsets.all(backButtonPadding),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: backButtonSize,
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 300.ms),

          // ── Ortalanmış içerik ──
          Positioned.fill(
            top: topInset,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // İkon kutusu
                Container(
                  width: iconBoxSize,
                  height: iconBoxSize,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(iconRadius),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.5),
                        blurRadius: 28,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: iconSize),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scaleXY(
                      begin: 0.7,
                      end: 1,
                      duration: 550.ms,
                      curve: Curves.easeOutBack,
                    )
                    .then()
                    .shimmer(
                      duration: 1600.ms,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),

                SizedBox(height: titleSpacing),

                // Başlık
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 180.ms, duration: 400.ms)
                    .slideY(
                      begin: 0.2,
                      end: 0,
                      curve: Curves.easeOut,
                      duration: 400.ms,
                    ),

                SizedBox(height: subtitleSpacing),

                // Alt başlık
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: subtitleFontSize,
                      height: 1.4,
                    ),
                  ),
                ).animate().fadeIn(delay: 320.ms, duration: 400.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final double opacity;
  const _Blob({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}