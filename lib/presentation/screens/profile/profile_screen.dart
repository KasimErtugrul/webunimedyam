// lib/presentation/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/responsive.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../controllers/profile_controller.dart';
import 'widgets/profile_view_widget.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // Loading
  static const double loadingStrokeWidth = 3;

  // NotLoggedIn
  static const double mainPadding = 32;
  static const double avatarSize = 96;
  static const double avatarBorderWidth = 2;
  static const double avatarIconSize = 48;
  static const double titleSpacing = 24;
  static const double subtitleSpacing = 10;
  static const double buttonSpacing = 36;
  static const double titleFontSize = 22;
  static const double subtitleFontSize = 14;
  static const double subtitleLineHeight = 1.5;
  static const double buttonHeight = 48;
  static const double buttonFontSize = 16;
  /*   static const double buttonPaddingVertical = 14;
  static const double buttonBorderRadius = 8;
  static const double buttonSpacingSmall = 12; */
}

class _TabletSizes {
  // Loading - tablet için daha büyük
  static const double loadingStrokeWidth = 3.5;

  // NotLoggedIn - tablet için daha büyük
  static const double mainPadding = 48;
  static const double avatarSize = 120;
  static const double avatarBorderWidth = 2.5;
  static const double avatarIconSize = 56;
  static const double titleSpacing = 28;
  static const double subtitleSpacing = 12;
  static const double buttonSpacing = 40;
  static const double titleFontSize = 28;
  static const double subtitleFontSize = 16;
  static const double subtitleLineHeight = 1.6;
  static const double buttonHeight = 56;
  static const double buttonFontSize = 18;
  static const double buttonPaddingVertical = 16;
  static const double buttonBorderRadius = 10;
  static const double buttonSpacingSmall = 14;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

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
    // KURAL 5 — TEK DALLANMA NOKTASI
    return Responsive.isTablet(context)
        ? _buildTablet(context)
        : _buildPhone(context);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI (BİREBİR AYNI)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPhone(BuildContext context) {
    final controller = Get.find<ProfileController>(tag: _tag);

    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
              strokeWidth: _PhoneSizes.loadingStrokeWidth.w,
            ),
          ),
        );
      }

      if (!controller.isLoggedIn) {
        return _NotLoggedInViewPhone();
      }

      return ProfileViewWidget(controller: controller);
    });
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    final controller = Get.find<ProfileController>(tag: _tag);

    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
              strokeWidth: _TabletSizes.loadingStrokeWidth,
            ),
          ),
        );
      }

      if (!controller.isLoggedIn) {
        return _NotLoggedInViewTablet();
      }

      return ProfileViewWidget(controller: controller);
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════
// KURAL 6 — ALT WIDGET (PHONE)
// ═══════════════════════════════════════════════════════════════════════

class _NotLoggedInViewPhone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(_PhoneSizes.mainPadding.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: _PhoneSizes.avatarSize.w,
                height: _PhoneSizes.avatarSize.h,
                decoration: BoxDecoration(
                  color: AppTheme.surface(context),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    width: _PhoneSizes.avatarBorderWidth.w,
                  ),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppTheme.textSec(context),
                  size: _PhoneSizes.avatarIconSize.sp,
                ),
              ),
              SizedBox(height: _PhoneSizes.titleSpacing.h),
              Text(
                'Hesabına Giriş Yap',
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: _PhoneSizes.titleFontSize.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: _PhoneSizes.subtitleSpacing.h),
              Text(
                'Favorilerini, izleme geçmişini ve tüm aktivitelerini\ngörmek için giriş yap.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: _PhoneSizes.subtitleFontSize.sp,
                  height: _PhoneSizes.subtitleLineHeight,
                ),
              ),
              SizedBox(height: _PhoneSizes.buttonSpacing.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(
                      double.infinity,
                      _PhoneSizes.buttonHeight.h,
                    ),
                  ),
                  onPressed: () => Get.toNamed(AppRoutes.login),
                  child: Text(
                    'Giriş Yap',
                    style: TextStyle(fontSize: _PhoneSizes.buttonFontSize.sp),
                  ),
                ),
              ),
              /* SizedBox(height: _PhoneSizes.buttonSpacingSmall.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textPri(context),
                    side: BorderSide(
                      color: AppTheme.surface(context),
                      width: _PhoneSizes.avatarBorderWidth.w,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: _PhoneSizes.buttonPaddingVertical.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        _PhoneSizes.buttonBorderRadius.r,
                      ),
                    ),
                    minimumSize: Size(
                      double.infinity,
                      _PhoneSizes.buttonHeight.h,
                    ),
                  ),
                  onPressed: () => Get.toNamed(AppRoutes.register),
                  child: Text(
                    'Kayıt Ol',
                    style: TextStyle(fontSize: _PhoneSizes.buttonFontSize.sp),
                  ),
                ),
              ), */
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// KURAL 6 — ALT WIDGET (TABLET)
// ═══════════════════════════════════════════════════════════════════════

class _NotLoggedInViewTablet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: EdgeInsets.all(_TabletSizes.mainPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: _TabletSizes.avatarSize,
                  height: _TabletSizes.avatarSize,
                  decoration: BoxDecoration(
                    color: AppTheme.surface(context),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      width: _TabletSizes.avatarBorderWidth,
                    ),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: AppTheme.textSec(context),
                    size: _TabletSizes.avatarIconSize,
                  ),
                ),
                SizedBox(height: _TabletSizes.titleSpacing),
                Text(
                  'Hesabına Giriş Yap',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: _TabletSizes.titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: _TabletSizes.subtitleSpacing),
                Text(
                  'Favorilerini, izleme geçmişini ve tüm aktivitelerini\ngörmek için giriş yap.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: _TabletSizes.subtitleFontSize,
                    height: _TabletSizes.subtitleLineHeight,
                  ),
                ),
                SizedBox(height: _TabletSizes.buttonSpacing),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(
                        double.infinity,
                        _TabletSizes.buttonHeight,
                      ),
                    ),
                    onPressed: () => Get.toNamed(AppRoutes.login),
                    child: Text(
                      'Giriş Yap',
                      style: TextStyle(fontSize: _TabletSizes.buttonFontSize),
                    ),
                  ),
                ),
                SizedBox(height: _TabletSizes.buttonSpacingSmall),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPri(context),
                      side: BorderSide(
                        color: AppTheme.surface(context),
                        width: _TabletSizes.avatarBorderWidth,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: _TabletSizes.buttonPaddingVertical,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          _TabletSizes.buttonBorderRadius,
                        ),
                      ),
                      minimumSize: Size(
                        double.infinity,
                        _TabletSizes.buttonHeight,
                      ),
                    ),
                    onPressed: () => Get.toNamed(AppRoutes.register),
                    child: Text(
                      'Kayıt Ol',
                      style: TextStyle(fontSize: _TabletSizes.buttonFontSize),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
