import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../utils/university_detail_sizes.dart';

class UniversityDetailAboutTabLinkButton extends StatelessWidget {
  final UniversityDetailSizes sizes;
  final IconData icon;
  final String label;
  final String url;
  final Color? color;
  const UniversityDetailAboutTabLinkButton({super.key, 
    required this.sizes,
    required this.icon,
    required this.label,
    required this.url,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? AppTheme.primaryColor;
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(sizes.aboutCardBorderRadius),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: sizes.linkButtonPaddingHorizontal,
          vertical: sizes.linkButtonPaddingVertical,
        ),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(sizes.aboutCardBorderRadius),
          border: Border.all(
            color: AppTheme.isDark(context)
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: sizes.linkButtonIconSize,
              height: sizes.linkButtonIconSize,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(sizes.linkButtonIconRadius),
              ),
              child: Icon(
                icon,
                size: sizes.linkButtonIconInnerSize,
                color: iconColor,
              ),
            ),
            SizedBox(width: sizes.linkButtonIconSpacing),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: sizes.linkButtonLabelFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPri(context),
                ),
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              size: sizes.linkButtonTrailingIconSize,
              color: AppTheme.textSec(context),
            ),
          ],
        ),
      ),
    );
  }
}