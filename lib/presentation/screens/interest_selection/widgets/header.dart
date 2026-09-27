// ═══════════════════════════════════════════════════════════
// HEADER
// ═══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../controllers/interest_selection_controller.dart';
import '../utils/sizes.dart';

class InterestSelectionHeader extends StatelessWidget {
  final InterestSelectionSizes sizes;
  final InterestSelectionController controller;
  const InterestSelectionHeader({super.key, 
    required this.sizes,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        sizes.headerPaddingLeft,
        sizes.headerPaddingTop,
        sizes.headerPaddingRight,
        sizes.headerPaddingBottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'İlgilendiğin üniversiteleri seç',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: sizes.headerTitleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: controller.skip,
                child: Text(
                  'Atla',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: sizes.headerSkipFontSize,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sizes.headerDescriptionSpacing),
          Text(
            'Seni biraz tanıyalım. İstediğin kadar üniversite seçebilir, '
            'hiç seçmeden de devam edebilirsin. Bu bir zorunluluk değil.',
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: sizes.headerDescriptionFontSize,
              height: sizes.headerDescriptionLineHeight,
            ),
          ),
          SizedBox(height: sizes.headerSearchSpacing),
          TextField(
            onChanged: controller.updateSearch,
            style: TextStyle(
              color: AppTheme.textPri(context),
              fontSize: sizes.headerSearchFontSize,
            ),
            decoration: InputDecoration(
              hintText: 'Üniversite ara...',
              hintStyle: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: sizes.headerSearchHintFontSize,
              ),
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              contentPadding: EdgeInsets.symmetric(
                vertical: sizes.headerSearchContentPaddingVertical,
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(sizes.headerSearchBorderRadius),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}