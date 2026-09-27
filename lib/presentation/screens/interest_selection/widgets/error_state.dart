// ═══════════════════════════════════════════════════════════
// ERROR STATE
// ═══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../controllers/interest_selection_controller.dart';
import '../utils/sizes.dart';

class InterestSelectionErrorState extends StatelessWidget {
  final InterestSelectionSizes sizes;
  final InterestSelectionController controller;
  const InterestSelectionErrorState({super.key, 
    required this.sizes,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sizes.errorPaddingHorizontal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: sizes.errorFontSize,
              ),
            ),
            SizedBox(height: sizes.errorSpacing),
            TextButton(
              onPressed: controller.skip,
              child: const Text('Şimdilik geç'),
            ),
          ],
        ),
      ),
    );
  }
}