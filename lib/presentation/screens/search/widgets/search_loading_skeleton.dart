// lib/presentation/screens/search/widgets/search_loading_skeleton.dart
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../app/themes/app_theme.dart';
import '../search_layout_spec.dart';

class SearchLoadingSkeleton extends StatelessWidget {
  final SearchLayoutSpec spec;
  const SearchLoadingSkeleton({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: spec.resultsPaddingH,
          vertical: spec.resultsPaddingV,
        ),
        itemCount: 6,
        itemBuilder: (_, _) => _SkeletonCard(spec: spec),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final SearchLayoutSpec spec;
  const _SkeletonCard({required this.spec});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: spec.cardBottomMargin),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(spec.cardRadius),
      ),
      child: Row(
        children: [
          Container(
            width: spec.cardThumbW,
            height: spec.cardThumbH,
            decoration: BoxDecoration(
              color: AppTheme.surface(context),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(spec.cardRadius),
                bottomLeft: Radius.circular(spec.cardRadius),
              ),
            ),
          ),
          SizedBox(width: spec.cardThumbSpacing),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: spec.cardPaddingV),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: spec.cardTitleFontSize,
                    width: double.infinity,
                    color: AppTheme.surface(context),
                  ),
                  SizedBox(height: spec.cardSpacingSm),
                  Container(
                    height: spec.cardTitleFontSize,
                    width: 120,
                    color: AppTheme.surface(context),
                  ),
                  SizedBox(height: spec.cardSpacingSm),
                  Container(
                    height: spec.cardUniFontSize,
                    width: 80,
                    color: AppTheme.surface(context),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: spec.cardTrailingSpacing),
        ],
      ),
    );
  }
}