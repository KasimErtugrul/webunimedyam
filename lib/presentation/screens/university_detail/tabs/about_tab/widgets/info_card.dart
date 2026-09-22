/* import 'package:flutter/material.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../../../controllers/university_detail_controller.dart';
import '../../../utils/university_detail_sizes.dart';
import 'info_row.dart';

class UniversityDetailAboutTabInfoCard extends StatelessWidget {
  final UniversityDetailSizes sizes;
  final dynamic uni;
  final UniversityDetailController controller;
  const UniversityDetailAboutTabInfoCard({
    super.key,
    required this.sizes,
    required this.uni,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(sizes.aboutCardBorderRadius),
        border: Border.all(
          color: AppTheme.isDark(context)
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          UniversityDetailAboutTabInfoRow(
            sizes: sizes,
            icon: Icons.location_on_rounded,
            label: 'Şehir',
            value: uni.city ?? '—',
            isFirst: true,
          ),
          UniversityDetailAboutTabInfoRow(
            sizes: sizes,
            icon: Icons.calendar_today_rounded,
            label: 'Kuruluş Yılı',
            value: uni.foundedYear != null ? '${uni.foundedYear}' : '—',
          ),
          UniversityDetailAboutTabInfoRow(
            sizes: sizes,
            icon: Icons.play_circle_rounded,
            label: 'Video Sayısı',
            value: uni.videoCount != null ? '${uni.videoCount}' : '—',
          ),
          UniversityDetailAboutTabInfoRow(
            sizes: sizes,
            icon: Icons.people_rounded,
            label: 'Abone Sayısı',
            value: uni.subscriberCount != null
                ? controller.formattedSubscriberCount
                : '—',
          ),
          UniversityDetailAboutTabInfoRow(
            sizes: sizes,
            icon: Icons.visibility_rounded,
            label: 'Toplam İzlenme',
            value: uni.viewCount != null ? controller.formattedViewCount : '—',
            isLast: true,
          ),
          UniversityDetailAboutTabInfoRow(
            sizes: sizes,
            icon: Icons.visibility_rounded,
            label: 'Adres',
            value: uni.address ?? '—',
            isLast: true,
          ),
        ],
      ),
    );
  }
}
 */