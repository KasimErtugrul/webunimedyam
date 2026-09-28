// lib/presentation/screens/home/widgets/tabs/universities_tab/widgets/university_card_shimmer_widget.dart
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../universities_tab_layout_spec.dart';

/// Artık `Skeletonizer` paketiyle çalışır — anakart üzerinde sadece
/// statik gri bloklar çiziyoruz, shimmer efektini paket veriyor.
class UniversityCardShimmerWidget extends StatelessWidget {
  final UniversitiesTabLayoutSpec spec;
  const UniversityCardShimmerWidget({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: spec.cardBottomMargin),
      child: Container(
        padding: EdgeInsets.all(spec.cardPadding),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(spec.cardRadius),
          border: Border.all(
            color: AppTheme.textSec(context).withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            // Logo placeholder
            Container(
              width: spec.cardLogoSize,
              height: spec.cardLogoSize,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            // Metin placeholder
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        height: 10,
                        width: constraints.maxWidth * 0.6,
                        color: Colors.grey,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth = constraints.maxWidth * 0.25;
                      return Row(
                        children: [
                          Container(
                            height: 18,
                            width: itemWidth,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            height: 18,
                            width: itemWidth,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              height: spec.cardFollowHeight,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(spec.cardFollowRadius),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kart listesi için hazır `Skeletonizer` sarmalayıcı.
class UniversityCardShimmerList extends StatelessWidget {
  final UniversitiesTabLayoutSpec spec;
  final int count;
  const UniversityCardShimmerList({
    super.key,
    required this.spec,
    this.count = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: spec.contentHPadding,
        ),
        itemCount: count,
        itemBuilder: (_, _) => UniversityCardShimmerWidget(spec: spec),
      ),
    );
  }
}