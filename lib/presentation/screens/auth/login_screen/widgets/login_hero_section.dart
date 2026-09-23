/* // lib/presentation/screens/auth/widgets/login_hero_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../app/themes/app_theme.dart';
import '../login_layout_spec.dart';

class LoginHeroSection extends StatelessWidget {
  final LoginLayoutSpec spec;
  const LoginHeroSection({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final primary = AppTheme.primaryColor;

    return SizedBox(
      height: spec.heroHeight + topInset,
      child: Stack(
        children: [
          // ── Gradient arka plan ─────────────────────────
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
                  // Ambient blobs
                  Positioned(
                    right: -40.w,
                    top: topInset - 30.h,
                    child: _Blob(size: 180.w, opacity: 0.10),
                  ),
                  Positioned(
                    left: -30.w,
                    bottom: -40.h,
                    child: _Blob(size: 140.w, opacity: 0.08),
                  ),
                  Positioned(
                    left: 80.w,
                    top: topInset + 40.h,
                    child: _Blob(size: 60.w, opacity: 0.06),
                  ),
                ],
              ),
            ),
          ),

          // ── Geri butonu ────────────────────────────────
          Positioned(
            top: topInset + 8.h,
            left: 8.w,
            child: Material(
              color: Colors.white.withValues(alpha: 0.15),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: Get.back,
                child: Padding(
                  padding: EdgeInsets.all(spec.backButtonPadding.w),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: spec.backButtonSize.sp,
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms),

          // ── Ortalanmış içerik ──────────────────────────
          Positioned.fill(
            top: topInset,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: spec.heroLogoSize.w,
                  height: spec.heroLogoSize.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(spec.heroLogoRadius.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.5),
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: spec.heroIconSize.sp,
                  ),
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

                SizedBox(height: spec.heroTitleSpacing.h),

                // Başlık
                Text(
                  'ÇOMÜ TV',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: spec.heroTitleFontSize.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
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

                SizedBox(height: spec.heroSubtitleSpacing.h),

                // Alt başlık
                Text(
                  'Üniversite Video Platformu',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: spec.heroSubtitleFontSize.sp,
                    letterSpacing: 0.4,
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
} */