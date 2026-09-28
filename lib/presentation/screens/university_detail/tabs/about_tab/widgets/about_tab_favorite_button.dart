import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../../../controllers/university_detail_controller.dart';
import '../../../utils/university_detail_sizes.dart';

class UniversityDetailAboutTabFavoriteButton extends StatelessWidget {
  final UniversityDetailSizes sizes;
  final UniversityDetailController controller;
  const UniversityDetailAboutTabFavoriteButton({super.key, required this.sizes, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isFav = controller.isFavorite.value;
      final isLoading = controller.isFavoriteLoading.value;
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : controller.toggleFavorite,
          icon: isLoading
              ? SizedBox(
                  width: sizes.favButtonLoadingSize,
                  height: sizes.favButtonLoadingSize,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  isFav
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: sizes.favButtonIconSize,
                ),
          label: Text(
            isFav ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
            style: TextStyle(
              fontSize: sizes.favButtonFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isFav
                ? AppTheme.card(context)
                : AppTheme.primaryColor,
            foregroundColor: isFav ? AppTheme.primaryColor : Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(
              vertical: sizes.favButtonPaddingVertical,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(sizes.favButtonBorderRadius),
              side: isFav
                  ? BorderSide(
                      color: AppTheme.primaryColor.withValues(alpha: 0.5),
                    )
                  : BorderSide.none,
            ),
          ),
        ),
      );
    });
  }
}