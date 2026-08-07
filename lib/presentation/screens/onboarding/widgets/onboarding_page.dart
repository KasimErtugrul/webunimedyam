
// ═══════════════════════════════════════════════════════════
// ONBOARDING PAGE (TEK WIDGET)
// ═══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../utils/sizes.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingSizes sizes;
  final IconData icon;
  final String title;
  final String description;

  const OnboardingPage({super.key, 
    required this.sizes,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(sizes.pagePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: sizes.iconContainerSize,
            height: sizes.iconContainerSize,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: sizes.iconSize,
            ),
          ),
          SizedBox(height: sizes.iconSpacing),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textPri(context),
              fontSize: sizes.titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: sizes.titleSpacing),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: sizes.descriptionFontSize,
              height: sizes.descriptionLineHeight,
            ),
          ),
        ],
      ),
    );
  }
}