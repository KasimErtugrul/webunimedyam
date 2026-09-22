// lib/presentation/screens/university_detail/tabs/about_tab/about_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../controllers/university_detail_controller.dart';
import '../../../../controllers/university_radio_controller.dart';
import '../../university_detail_layout_spec.dart';
import 'about_widgets.dart';

class UniversityDetailAboutTab extends StatelessWidget {
  final UniversityDetailLayoutSpec spec;
  final UniversityDetailController controller;
  final UniversityRadioController radioController;

  const UniversityDetailAboutTab({
    super.key,
    required this.spec,
    required this.controller,
    required this.radioController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final uni = controller.university.value;
      if (uni == null) {
        return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        );
      }

      final hasLinks =
          (uni.websiteUrl?.isNotEmpty ?? false) ||
          (uni.customUrl?.isNotEmpty ?? false) ||
          (uni.radioLink?.isNotEmpty ?? false);

      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          spec.contentPaddingH.w,
          spec.contentPaddingTop.h,
          spec.contentPaddingH.w,
          spec.contentPaddingBottom.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Açıklama ──
            UniversityAboutSectionTitle(spec: spec, title: 'Açıklama'),
            SizedBox(height: 10.h),
            UniversityAboutDescriptionCard(
              spec: spec,
              uni: uni,
            ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0),

            SizedBox(height: spec.sectionSpacing.h),

            // ── Genel Bilgiler ──
            UniversityAboutSectionTitle(spec: spec, title: 'Genel Bilgiler'),
            SizedBox(height: 10.h),
            UniversityAboutInfoCard(
                  spec: spec,
                  uni: uni,
                  controller: controller,
                )
                .animate(delay: 80.ms)
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.05, end: 0),

            // ── Bağlantılar ──
            if (hasLinks) ...[
              SizedBox(height: spec.sectionSpacing.h),
              UniversityAboutSectionTitle(spec: spec, title: 'Bağlantılar'),
              SizedBox(height: 10.h),

              if (uni.websiteUrl?.isNotEmpty ?? false)
                UniversityAboutLinkButton(
                  spec: spec,
                  icon: Icons.language_rounded,
                  label: 'Resmi Web Sitesi',
                  url: uni.websiteUrl!,
                  color: const Color(0xFF3B82F6),
                ),
              if (uni.customUrl?.isNotEmpty ?? false) ...[
                SizedBox(height: 8.h),
                UniversityAboutLinkButton(
                  spec: spec,
                  icon: Icons.play_circle_fill_rounded,
                  label: 'YouTube Kanalı',
                  url: 'https://www.youtube.com/${uni.customUrl}',
                  color: const Color(0xFFFF0000),
                ),
              ],
              if (uni.radioLink?.isNotEmpty ?? false) ...[
                SizedBox(height: 8.h),
                UniversityAboutRadioCard(
                  spec: spec,
                  university: uni,
                  radioController: radioController,
                ),
              ],
            ],
          ],
        ),
      );
    });
  }
}
