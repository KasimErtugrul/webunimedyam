import 'package:flutter/material.dart';

import '../../../utils/university_detail_sizes.dart';

class UniversityDetailAboutTabRadioWaveAnimation extends StatelessWidget {
  final UniversityDetailSizes sizes;
  final bool isActive;
  const UniversityDetailAboutTabRadioWaveAnimation({super.key, required this.sizes, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(sizes.radioIconContainerRadius),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 400 + (index * 150)),
            width: sizes.radioWaveBarWidth,
            height: isActive
                ? (sizes.radioWaveBarMaxHeight +
                      (index % 2 == 0 ? sizes.radioWaveBarMaxHeight / 2 : 0))
                : sizes.radioWaveBarMinHeight,
            margin: EdgeInsets.symmetric(horizontal: sizes.radioWaveBarSpacing),
            decoration: BoxDecoration(
              color: const Color(
                0xFF8B5CF6,
              ).withValues(alpha: sizes.radioWaveBarAlpha),
              borderRadius: BorderRadius.circular(
                sizes.radioWaveBarBorderRadius,
              ),
            ),
          );
        }),
      ),
    );
  }
}