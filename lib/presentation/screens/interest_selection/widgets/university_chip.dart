// ═══════════════════════════════════════════════════════════
// UNIVERSITY CHIP
// ═══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../utils/sizes.dart';

class InterestSelectionUniversityChip extends StatelessWidget {
  final InterestSelectionSizes sizes;
  final String name;
  final String? logoUrl;
  final bool selected;
  final VoidCallback? onTap;

  const InterestSelectionUniversityChip({super.key, 
    required this.sizes,
    required this.name,
    required this.logoUrl,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(sizes.chipBorderRadius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: sizes.chipPaddingHorizontal,
          vertical: sizes.chipPaddingVertical,
        ),
        decoration: BoxDecoration(
          color: selected
              ? primary.withValues(alpha: 0.15)
              : AppTheme.textSec(context).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(sizes.chipBorderRadius),
          border: Border.all(
            color: selected ? primary : Colors.transparent,
            width: sizes.chipBorderWidth,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: sizes.chipAvatarRadius,
              backgroundColor:
                  AppTheme.textSec(context).withValues(alpha: 0.15),
              backgroundImage: (logoUrl != null && logoUrl!.isNotEmpty)
                  ? NetworkImage(logoUrl!)
                  : null,
              child: (logoUrl == null || logoUrl!.isEmpty)
                  ? Icon(
                      Icons.school_rounded,
                      size: sizes.chipAvatarIconSize,
                      color: AppTheme.textSec(context),
                    )
                  : null,
            ),
            SizedBox(width: sizes.chipAvatarSpacing),
            Expanded(
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: sizes.chipTitleFontSize,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle_rounded,
                color: primary,
                size: sizes.chipCheckIconSize,
              ),
          ],
        ),
      ),
    );
  }
}
