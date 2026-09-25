import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../utils/university_detail_sizes.dart';

class UniversityDetailVideosTabErrorViewVideoShimmer extends StatelessWidget {
  final UniversityDetailSizes sizes;
  const UniversityDetailVideosTabErrorViewVideoShimmer({
    super.key,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: sizes.isTablet ? 18 : 14,
        vertical: sizes.isTablet ? 10 : 8,
      ),
      child: Shimmer.fromColors(
        baseColor: AppTheme.isDark(context)
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFE0E0E0),
        highlightColor: AppTheme.isDark(context)
            ? const Color(0xFF3A3A3A)
            : const Color(0xFFF5F5F5),
        child: Container(
          height: sizes.shimmerVideoHeight,
          decoration: BoxDecoration(
            color: AppTheme.card(context),
            borderRadius: BorderRadius.circular(sizes.shimmerVideoBorderRadius),
          ),
        ),
      ),
    );
  }
}
