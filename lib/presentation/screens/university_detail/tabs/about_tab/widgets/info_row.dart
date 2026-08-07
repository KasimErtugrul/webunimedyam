import 'package:flutter/material.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../utils/university_detail_sizes.dart';

class UniversityDetailAboutTabInfoRow extends StatelessWidget {
  final UniversityDetailSizes sizes;
  final IconData icon;
  final String label;
  final String value;
  final bool isFirst;
  final bool isLast;
  const UniversityDetailAboutTabInfoRow({super.key, 
    required this.sizes,
    required this.icon,
    required this.label,
    required this.value,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sizes.infoRowPaddingHorizontal,
            vertical: sizes.infoRowPaddingVertical,
          ),
          child: Row(
            children: [
              Container(
                width: sizes.infoRowIconSize,
                height: sizes.infoRowIconSize,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(sizes.infoRowIconRadius),
                ),
                child: Icon(
                  icon,
                  size: sizes.infoRowIconInnerSize,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(width: sizes.infoRowIconSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: sizes.infoRowLabelFontSize,
                        color: AppTheme.textSec(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: sizes.infoRowValueSpacing),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: sizes.infoRowValueFontSize,
                        color: AppTheme.textPri(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            indent: sizes.infoRowPaddingHorizontal,
            endIndent: sizes.infoRowPaddingHorizontal,
            color: AppTheme.isDark(context)
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
          ),
      ],
    );
  }
}