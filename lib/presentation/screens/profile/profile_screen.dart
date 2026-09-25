// lib/presentation/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../controllers/profile_controller.dart';
import 'widgets/profile_view_widget.dart';

class _Sizes {
  final bool isTablet;
  final double loadingStrokeWidth;
  final double maxContentWidth;
  final double mainPadding;
  final double avatarSize;
  final double avatarBorderWidth;
  final double avatarIconSize;
  final double titleSpacing;
  final double subtitleSpacing;
  final double buttonSpacing;
  final double titleFontSize;
  final double subtitleFontSize;
  final double subtitleLineHeight;
  final double buttonHeight;
  final double buttonRadius;
  final double buttonFontSize;

  const _Sizes._({
    required this.isTablet,
    required this.loadingStrokeWidth,
    required this.maxContentWidth,
    required this.mainPadding,
    required this.avatarSize,
    required this.avatarBorderWidth,
    required this.avatarIconSize,
    required this.titleSpacing,
    required this.subtitleSpacing,
    required this.buttonSpacing,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.subtitleLineHeight,
    required this.buttonHeight,
    required this.buttonRadius,
    required this.buttonFontSize,
  });

  factory _Sizes.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const _Sizes._(
        isTablet: true,
        loadingStrokeWidth: 3.5,
        maxContentWidth: 500,
        mainPadding: 48,
        avatarSize: 120,
        avatarBorderWidth: 2.5,
        avatarIconSize: 56,
        titleSpacing: 28,
        subtitleSpacing: 12,
        buttonSpacing: 40,
        titleFontSize: 28,
        subtitleFontSize: 16,
        subtitleLineHeight: 1.6,
        buttonHeight: 56,
        buttonRadius: 16,
        buttonFontSize: 18,
      );
    }
    return const _Sizes._(
      isTablet: false,
      loadingStrokeWidth: 3,
      maxContentWidth: double.infinity,
      mainPadding: 32,
      avatarSize: 96,
      avatarBorderWidth: 2,
      avatarIconSize: 48,
      titleSpacing: 24,
      subtitleSpacing: 10,
      buttonSpacing: 36,
      titleFontSize: 22,
      subtitleFontSize: 14,
      subtitleLineHeight: 1.5,
      buttonHeight: 52,
      buttonRadius: 14,
      buttonFontSize: 16,
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String get _tag {
    final rawArgs = Get.arguments;
    final args = rawArgs is Map<String, dynamic> ? rawArgs : null;
    final targetUserId = args?['userId'] as String?;
    if (targetUserId != null) return targetUserId;
    return Get.find<AuthRepository>().currentUserId ?? 'anonymous';
  }

  @override
  Widget build(BuildContext context) {
    final spec = _Sizes.of(context);
    final controller = Get.find<ProfileController>(tag: _tag);

    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
              strokeWidth: spec.loadingStrokeWidth,
            ),
          ),
        );
      }

      if (!controller.isLoggedIn) {
        return _NotLoggedInView(spec: spec);
      }

      return ProfileViewWidget(controller: controller);
    });
  }
}

class _NotLoggedInView extends StatelessWidget {
  final _Sizes spec;
  const _NotLoggedInView({required this.spec});

  @override
  Widget build(BuildContext context) {
    // NOT: Burada ayrı bir AppBar EKLENMEDİ — "ÜniTV / KAMPÜS YAYINI" barı
    // artık HomeScreen'in Scaffold.appBar'ında sabit; bu iç içe Scaffold
    // onun altında ikinci bir AppBar göstermemeli.
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: spec.maxContentWidth),
          child: Padding(
            padding: EdgeInsets.all(spec.mainPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: spec.avatarSize,
                  height: spec.avatarSize,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.15),
                        AppTheme.primaryColor.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      width: spec.avatarBorderWidth,
                    ),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: AppTheme.primaryColor,
                    size: spec.avatarIconSize,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scaleXY(begin: 0.8, end: 1, curve: Curves.easeOutBack),
                SizedBox(height: spec.titleSpacing),
                Text(
                  'Hesabına Giriş Yap',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: spec.titleFontSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ).animate().fadeIn(delay: 150.ms, duration: 350.ms),
                SizedBox(height: spec.subtitleSpacing),
                Text(
                  'Favorilerini, izleme geçmişini ve tüm aktivitelerini\ngörmek için giriş yap.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: spec.subtitleFontSize,
                    height: spec.subtitleLineHeight,
                  ),
                ).animate().fadeIn(delay: 250.ms, duration: 350.ms),
                SizedBox(height: spec.buttonSpacing),
                SizedBox(
                  width: double.infinity,
                  height: spec.buttonHeight,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          spec.buttonRadius,
                        ),
                      ),
                    ),
                    onPressed: () => Get.toNamed(AppRoutes.login),
                    child: Text(
                      'Giriş Yap',
                      style: TextStyle(
                        fontSize: spec.buttonFontSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 350.ms, duration: 350.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}