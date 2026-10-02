// lib/presentation/screens/profile/widgets/profile_header/avatar_source_sheet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/responsive.dart';
import '../../../../controllers/profile_controller.dart';

class _Sizes {
  final bool isTablet;
  final double sheetRadius;
  final double handleW;
  final double handleH;
  final double handleSpacing;
  final double titleFontSize;
  final double titleSpacing;
  final double optionRadius;
  final double optionPaddingH;
  final double optionPaddingV;
  final double optionIconBox;
  final double optionIconBoxRadius;
  final double optionIconSize;
  final double optionTitleFontSize;
  final double optionSubtitleFontSize;
  final double optionSpacing;
  final double bottomPadding;

  const _Sizes._({
    required this.isTablet,
    required this.sheetRadius,
    required this.handleW,
    required this.handleH,
    required this.handleSpacing,
    required this.titleFontSize,
    required this.titleSpacing,
    required this.optionRadius,
    required this.optionPaddingH,
    required this.optionPaddingV,
    required this.optionIconBox,
    required this.optionIconBoxRadius,
    required this.optionIconSize,
    required this.optionTitleFontSize,
    required this.optionSubtitleFontSize,
    required this.optionSpacing,
    required this.bottomPadding,
  });

  factory _Sizes.of(BuildContext context) {
    // WEB (masaüstü tarayıcı, ≥1024px): tablet ölçekleri + web ince ayarları.
    if (Responsive.isWeb(context)) {
      return const _Sizes._(
        isTablet: true,
        sheetRadius: 28,
        handleW: 48,
        handleH: 5,
        handleSpacing: 14,
        titleFontSize: 21,
        titleSpacing: 22,
        optionRadius: 16,
        optionPaddingH: 16,
        optionPaddingV: 15,
        optionIconBox: 48,
        optionIconBoxRadius: 14,
        optionIconSize: 24,
        optionTitleFontSize: 16.5,
        optionSubtitleFontSize: 13.5,
        optionSpacing: 10,
        bottomPadding: 28,
      );
    }
    if (Responsive.isTablet(context)) {
      return const _Sizes._(
        isTablet: true,
        sheetRadius: 28,
        handleW: 48,
        handleH: 5,
        handleSpacing: 14,
        titleFontSize: 20,
        titleSpacing: 20,
        optionRadius: 16,
        optionPaddingH: 16,
        optionPaddingV: 14,
        optionIconBox: 48,
        optionIconBoxRadius: 14,
        optionIconSize: 24,
        optionTitleFontSize: 16,
        optionSubtitleFontSize: 13,
        optionSpacing: 10,
        bottomPadding: 24,
      );
    }
    return const _Sizes._(
      isTablet: false,
      sheetRadius: 24,
      handleW: 40,
      handleH: 4,
      handleSpacing: 12,
      titleFontSize: 17,
      titleSpacing: 16,
      optionRadius: 14,
      optionPaddingH: 14,
      optionPaddingV: 12,
      optionIconBox: 42,
      optionIconBoxRadius: 12,
      optionIconSize: 20,
      optionTitleFontSize: 15,
      optionSubtitleFontSize: 12,
      optionSpacing: 8,
      bottomPadding: 20,
    );
  }
}

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

  final spec = _Sizes.of(context);
  double w(double v) => spec.isTablet ? v : v;
  double h(double v) => spec.isTablet ? v : v;

  Get.bottomSheet(
    SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(w(spec.sheetRadius)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: h(spec.handleSpacing)),
            // Handle
            Container(
              width: w(spec.handleW),
              height: h(spec.handleH),
              decoration: BoxDecoration(
                color: AppTheme.textSec(context).withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(h(spec.handleH)),
              ),
            ),
            SizedBox(height: h(spec.handleSpacing)),

            // Başlık
            Text(
              'Profil Fotoğrafı',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: spec.titleFontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: h(spec.titleSpacing)),

            // Kamera
            _SourceOption(
              spec: spec,
              icon: Icons.photo_camera_rounded,
              color: const Color(0xFF3B82F6),
              title: 'Kameradan Çek',
              subtitle: 'Yeni bir fotoğraf çek',
              onTap: () {
                Get.back();
                _pickAndNotify(controller, ImageSource.camera);
              },
            ),
            SizedBox(height: h(spec.optionSpacing)),

            // Galeri
            _SourceOption(
              spec: spec,
              icon: Icons.photo_library_rounded,
              color: const Color(0xFF8B5CF6),
              title: 'Galeriden Seç',
              subtitle: 'Cihazındaki bir fotoğrafı kullan',
              onTap: () {
                Get.back();
                _pickAndNotify(controller, ImageSource.gallery);
              },
            ),
            SizedBox(height: h(spec.bottomPadding)),
          ],
        ),
      ),
    ),
  );
}

class _SourceOption extends StatelessWidget {
  final _Sizes spec;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SourceOption({
    required this.spec,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double w(double v) => spec.isTablet ? v : v;
    double h(double v) => spec.isTablet ? v : v;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(w(spec.optionRadius)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(w(spec.optionRadius)),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: w(spec.optionPaddingH),
              vertical: h(spec.optionPaddingV),
            ),
            child: Row(
              children: [
                Container(
                  width: w(spec.optionIconBox),
                  height: w(spec.optionIconBox),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(
                      w(spec.optionIconBoxRadius),
                    ),
                  ),
                  child: Icon(icon, color: color, size: spec.optionIconSize),
                ),
                SizedBox(width: w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppTheme.textPri(context),
                          fontSize: spec.optionTitleFontSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: h(2)),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppTheme.textSec(context),
                          fontSize: spec.optionSubtitleFontSize,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textSec(context).withValues(alpha: 0.5),
                  size: spec.optionIconSize + 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
