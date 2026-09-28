// lib/presentation/screens/settings/widgets/settings_hero.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../../app/themes/app_theme.dart';
import '../settings_layout_spec.dart';

class SettingsHero extends StatelessWidget {
  final SettingsLayoutSpec spec;
  const SettingsHero({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    const primary = AppTheme.primaryColor;

    return SizedBox(
      height: spec.heroHeight + topInset,
      child: Stack(
        children: [
          // Gradient bg + blobs
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
                    child: const _Blob(size: 160, opacity: 0.10),
                  ),
                  const Positioned(
                    left: -30,
                    bottom: -40,
                    child: _Blob(size: 120, opacity: 0.08),
                  ),
                  Positioned(
                    left: 100,
                    top: topInset + 30,
                    child: const _Blob(size: 50, opacity: 0.06),
                  ),
                ],
              ),
            ),
          ),

          // Floating back button
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
                  padding: EdgeInsets.all(spec.backButtonPadding),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: spec.backButtonSize,
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms),

          // Center content
          Positioned.fill(
            top: topInset,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                        width: spec.heroIconBoxSize,
                        height: spec.heroIconBoxSize,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(
                            spec.heroIconRadius,
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.45),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          color: Colors.white,
                          size: spec.heroIconSize,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scaleXY(
                        begin: 0.7,
                        end: 1,
                        duration: 550.ms,
                        curve: Curves.easeOutBack,
                      ),

                  SizedBox(height: spec.heroTitleSpacing),

                  Text(
                    'Ayarlar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: spec.heroTitleFontSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                    ),
                  ).animate().fadeIn(delay: 180.ms, duration: 400.ms),

                  const SizedBox(height: 4),

                  Text(
                    'Uygulama tercihlerinizi yönetin',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: spec.heroSubtitleFontSize,
                    ),
                  ).animate().fadeIn(delay: 320.ms, duration: 400.ms),
                ],
              ),
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