// lib/presentation/screens/settings/widgets/settings_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../settings_layout_spec.dart';

/// Section header + kart container + tile'lar arası ayraç.
class SettingsSection extends StatelessWidget {
  final SettingsLayoutSpec spec;
  final String title;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.spec,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section title
        Padding(
          padding: EdgeInsets.only(
            left: 4.w,
            bottom: spec.sectionHeaderSpacing.h,
          ),
          child: Row(
            children: [
              Container(
                width: 3.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: spec.sectionTitleFontSize.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: spec.sectionTitleLetterSpacing,
                ),
              ),
            ],
          ),
        ),

        // Card
        Container(
          decoration: BoxDecoration(
            color: AppTheme.card(context),
            borderRadius: BorderRadius.circular(spec.cardRadius.r),
            border: Border.all(
              color: AppTheme.textSec(context).withValues(alpha: 0.06),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: spec.tilePaddingH.w + spec.tileIconBoxSize.w + 12.w,
                    color:
                        AppTheme.textSec(context).withValues(alpha: 0.08),
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}