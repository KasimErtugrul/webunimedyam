// ─── About Tab ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../controllers/university_detail_controller.dart';
import '../../../../controllers/university_radio_controller.dart';
import '../../utils/university_detail_sizes.dart';
import 'widgets/about_tab_favorite_button.dart';
import 'widgets/description_card.dart';
import 'widgets/info_card.dart';
import 'widgets/link_button.dart';
import 'widgets/radio_in_line_card.dart';
import 'widgets/tab_section_title.dart';

class UniversityDetailAboutTab extends StatelessWidget {
  final UniversityDetailSizes sizes;
  final UniversityDetailController controller;
  final UniversityRadioController radioController;
  const UniversityDetailAboutTab({
    super.key,
    required this.sizes,
    required this.controller,
    required this.radioController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final uni = controller.university.value;
      if (uni == null) return const Center(child: CircularProgressIndicator());
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          sizes.aboutPaddingHorizontal,
          sizes.aboutPaddingTop,
          sizes.aboutPaddingHorizontal,
          sizes.aboutPaddingBottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UniversityDetailAboutTabFavoriteButton(sizes: sizes, controller: controller),
            SizedBox(height: sizes.aboutSectionSpacing),
            UniversityDetailAboutTabSectionTitle(sizes: sizes, title: 'Açıklama'),
            SizedBox(height: sizes.aboutSectionTitleSpacing),
            UniversityDetailAboutTabDescriptionCard(sizes: sizes, uni: uni),
            SizedBox(height: sizes.aboutSectionSpacing),
            UniversityDetailAboutTabSectionTitle(sizes: sizes, title: 'Genel Bilgiler'),
            SizedBox(height: sizes.aboutSectionTitleSpacing),
            UniversityDetailAboutTabInfoCard(sizes: sizes, uni: uni, controller: controller),
            SizedBox(height: sizes.aboutSectionSpacing),
            if (uni.websiteUrl != null ||
                uni.customUrl != null ||
                (uni.radioLink != null && uni.radioLink!.isNotEmpty)) ...[
              UniversityDetailAboutTabSectionTitle(sizes: sizes, title: 'Bağlantılar'),
              SizedBox(height: sizes.aboutSectionTitleSpacing),
              if (uni.websiteUrl != null && uni.websiteUrl!.isNotEmpty)
                UniversityDetailAboutTabLinkButton(
                  sizes: sizes,
                  icon: Icons.language_rounded,
                  label: 'Resmi Web Sitesi',
                  url: uni.websiteUrl!,
                ),
              if (uni.customUrl != null && uni.customUrl!.isNotEmpty) ...[
                SizedBox(height: sizes.isTablet ? 10 : 8.h),
                UniversityDetailAboutTabLinkButton(
                  sizes: sizes,
                  icon: Icons.play_circle_fill_rounded,
                  label: 'YouTube Kanalı',
                  url: 'https://www.youtube.com/${uni.customUrl}',
                  color: const Color(0xFFFF0000),
                ),
              ],
              if (uni.radioLink != null && uni.radioLink!.isNotEmpty) ...[
                SizedBox(height: sizes.isTablet ? 10 : 8.h),
                UniversityDetailAboutTabRadioInlineCard(
                  sizes: sizes,
                  university: uni,
                  radioController: radioController,
                ),
              ],
              SizedBox(height: sizes.aboutSectionSpacing),
            ],
          ],
        ),
      );
    });
  }
}