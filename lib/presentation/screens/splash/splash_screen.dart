// lib/presentation/screens/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../controllers/splash_controller.dart';

@immutable
class _Sizes {
  final bool isTablet;
  final double logoSize;
  final double logoRadius;
  final double logoIconSize;
  final double titleFontSize;
  final double titleLetterSpacing;
  final double titleSpacing;
  final double subtitleFontSize;
  final double subtitleSpacing;
  final double loadingSize;
  final double loadingStrokeWidth;
  final double loadingSpacing;
  final double glowBlur;
  final double glowOpacity;

  const _Sizes._({
    required this.isTablet,
    required this.logoSize,
    required this.logoRadius,
    required this.logoIconSize,
    required this.titleFontSize,
    required this.titleLetterSpacing,
    required this.titleSpacing,
    required this.subtitleFontSize,
    required this.subtitleSpacing,
    required this.loadingSize,
    required this.loadingStrokeWidth,
    required this.loadingSpacing,
    required this.glowBlur,
    required this.glowOpacity,
  });

  factory _Sizes.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const _Sizes._(
        isTablet: true,
        logoSize: 140,
        logoRadius: 28,
        logoIconSize: 84,
        titleFontSize: 44,
        titleLetterSpacing: 3,
        titleSpacing: 32,
        subtitleFontSize: 18,
        subtitleSpacing: 12,
        loadingSize: 52,
        loadingStrokeWidth: 3.5,
        loadingSpacing: 56,
        glowBlur: 40,
        glowOpacity: 0.35,
      );
    }
    return const _Sizes._(
      isTablet: false,
      logoSize: 100,
      logoRadius: 20,
      logoIconSize: 60,
      titleFontSize: 32,
      titleLetterSpacing: 2,
      titleSpacing: 24,
      subtitleFontSize: 14,
      subtitleSpacing: 8,
      loadingSize: 40,
      loadingStrokeWidth: 3,
      loadingSpacing: 48,
      glowBlur: 28,
      glowOpacity: 0.3,
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller'ı başlat (lazy init tetiklenir; yönlendirme oradan yönetilir)
    Get.find<SplashController>();

    final spec = _Sizes.of(context);
    final primary = AppTheme.primaryColor;

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Logo ──────────────────────────────────────
            _Logo(spec: spec, primary: primary),

            SizedBox(height: spec.titleSpacing.h),

            // ── Başlık ────────────────────────────────────
            Text(
              'ÜniTV',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: spec.titleFontSize.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: spec.titleLetterSpacing,
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

            SizedBox(height: spec.subtitleSpacing.h),

            // ── Alt başlık ────────────────────────────────
            Text(
              'Üniversite Video Platformu',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: spec.subtitleFontSize.sp,
                letterSpacing: 0.3,
              ),
            )
                .animate()
                .fadeIn(delay: 350.ms, duration: 400.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

            SizedBox(height: spec.loadingSpacing.h),

            // ── Loading ───────────────────────────────────
            SizedBox(
              width: spec.loadingSize,
              height: spec.loadingSize,
              child: CircularProgressIndicator(
                color: primary,
                strokeWidth: spec.loadingStrokeWidth,
                strokeCap: StrokeCap.round,
              ),
            ).animate().fadeIn(delay: 550.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final _Sizes spec;
  final Color primary;

  const _Logo({required this.spec, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: spec.logoSize,
      height: spec.logoSize,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF158a3e)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(spec.logoRadius),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: spec.glowOpacity),
            blurRadius: spec.glowBlur,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.play_arrow_rounded,
        color: Colors.white,
        size: spec.logoIconSize,
      ),
    )
        .animate()
        // Giriş: küçükten büyüyerek + fade
        .scaleXY(
          begin: 0.7,
          end: 1,
          duration: 550.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 400.ms)
        // Giriş sonrası sonsuz hafif nefes (glow ile birlikte)
        .then(delay: 200.ms)
        .shimmer(
          duration: 1600.ms,
          color: Colors.white.withValues(alpha: 0.15),
        );
  }
}