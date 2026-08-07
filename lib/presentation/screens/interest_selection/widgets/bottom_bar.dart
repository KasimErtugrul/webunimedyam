// ═══════════════════════════════════════════════════════════
// BOTTOM BAR
// ═══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/interest_selection_controller.dart';
import '../utils/sizes.dart';

class InterestSelectionBottomBar extends StatelessWidget {
  final InterestSelectionSizes sizes;
  final InterestSelectionController controller;
  const InterestSelectionBottomBar({super.key, 
    required this.sizes,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        sizes.bottomBarPaddingLeft,
        sizes.bottomBarPaddingTop,
        sizes.bottomBarPaddingRight,
        sizes.bottomBarPaddingBottom,
      ),
      child: Obx(
        () => SizedBox(
          width: double.infinity,
          height: sizes.bottomBarButtonHeight,
          child: ElevatedButton(
            onPressed: controller.isSaving.value
                ? null
                : controller.confirmAndContinue,
            child: controller.isSaving.value
                ? SizedBox(
                    width: sizes.bottomBarLoaderSize,
                    height: sizes.bottomBarLoaderSize,
                    child: CircularProgressIndicator(
                      strokeWidth: sizes.bottomBarLoaderStrokeWidth,
                    ),
                  )
                : Text(
                    controller.selectedCount > 0
                        ? 'Devam Et (${controller.selectedCount})'
                        : 'Devam Et',
                    style: TextStyle(fontSize: sizes.bottomBarButtonFontSize),
                  ),
          ),
        ),
      ),
    );
  }
}
