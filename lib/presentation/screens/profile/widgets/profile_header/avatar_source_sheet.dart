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
import '../../../../controllers/profile_controller.dart';

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

  Get.bottomSheet(
    SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8.h),
            Text(
              'Profil Fotoğrafı',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            ListTile(
              leading: Icon(
                Icons.photo_camera_outlined,
                color: AppTheme.textPri(context),
              ),
              title: Text(
                'Kameradan Çek',
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: 14.sp,
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
                  fontSize: 14.sp,
                ),
              ),
              onTap: () {
                Get.back();
                _pickAndNotify(controller, ImageSource.gallery);
              },
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    ),
  );
}
