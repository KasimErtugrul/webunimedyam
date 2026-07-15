// lib/presentation/screens/profile/widgets/profile_header/avatar_source_sheet.dart
//
// Profil fotoğrafı kaynağı (kamera/galeri) seçim sheet'i.
// Hem profil başlığındaki avatar'da hem de "Profili Düzenle" ekranında
// kullanılıyor — tek yerden yönetiliyor ki ikisi birbirinden sapmasın.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/responsive.dart';
import '../../../../controllers/profile_controller.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  static const double sheetBorderRadius = 20;
  static const double sheetVerticalPadding = 12;
  static const double sheetTopPadding = 8;
  static const double sheetBottomPadding = 8;
  static const double titleFontSize = 16;
  static const double tileFontSize = 14;
  static const double titleSpacing = 8;
}

class _TabletSizes {
  static const double sheetBorderRadius = 24;
  static const double sheetVerticalPadding = 16;
  static const double sheetTopPadding = 10;
  static const double sheetBottomPadding = 10;
  static const double titleFontSize = 20;
  static const double tileFontSize = 16;
  static const double titleSpacing = 10;
}

// ═══════════════════════════════════════════════════════════
// FUNCTIONS
// ═══════════════════════════════════════════════════════════

Future<void> _pickAndNotify(
  ProfileController controller,
  ImageSource source,
) async {
  await controller.pickAndUploadAvatar(source: source);
  if (controller.successMessage.value != null) {
    Get.snackbar('Başarılı', controller.successMessage.value!);
    controller.successMessage.value = null;
  } else if (controller.errorMessage.value != null) {
    Get.snackbar('Hata', controller.errorMessage.value!);
    controller.errorMessage.value = null;
  }
}

void showAvatarSourceSheet(BuildContext context, ProfileController controller) {
  if (!controller.isOwnProfile || controller.isUploadingAvatar.value) return;

  final isTablet = Responsive.isTablet(context);
 // final sizes = isTablet ? _TabletSizes() : _PhoneSizes();

  Get.bottomSheet(
    SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              isTablet ? _TabletSizes.sheetBorderRadius : _PhoneSizes.sheetBorderRadius.r,
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? _TabletSizes.sheetVerticalPadding : _PhoneSizes.sheetVerticalPadding.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: isTablet ? _TabletSizes.sheetTopPadding : _PhoneSizes.sheetTopPadding.h,
            ),
            Text(
              'Profil Fotoğrafı',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: isTablet ? _TabletSizes.titleFontSize : _PhoneSizes.titleFontSize.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: isTablet ? _TabletSizes.titleSpacing : _PhoneSizes.titleSpacing.h,
            ),
            ListTile(
              leading: Icon(
                Icons.photo_camera_outlined,
                color: AppTheme.textPri(context),
              ),
              title: Text(
                'Kameradan Çek',
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: isTablet ? _TabletSizes.tileFontSize : _PhoneSizes.tileFontSize.sp,
                ),
              ),
              onTap: () {
                Get.back();
                _pickAndNotify(controller, ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library_outlined,
                color: AppTheme.textPri(context),
              ),
              title: Text(
                'Galeriden Seç',
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: isTablet ? _TabletSizes.tileFontSize : _PhoneSizes.tileFontSize.sp,
                ),
              ),
              onTap: () {
                Get.back();
                _pickAndNotify(controller, ImageSource.gallery);
              },
            ),
            SizedBox(
              height: isTablet ? _TabletSizes.sheetBottomPadding : _PhoneSizes.sheetBottomPadding.h,
            ),
          ],
        ),
      ),
    ),
  );
}