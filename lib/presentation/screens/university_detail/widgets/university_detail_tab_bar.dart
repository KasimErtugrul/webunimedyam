// lib/presentation/screens/university_detail/widgets/university_detail_tab_bar.dart
import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../university_detail_layout_spec.dart';

class UniversityDetailTabBar extends StatelessWidget {
  final UniversityDetailLayoutSpec spec;
  const UniversityDetailTabBar({super.key, required this.spec});

  static const _labels = ['Hakkında', 'Videolar', 'Shorts', 'Canlı'];

  @override
  Widget build(BuildContext context) {
    final primary = AppTheme.primaryColor;

    return SizedBox.expand(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spec.tabBarHPadding,
          vertical: 6,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.card(context),
            borderRadius: BorderRadius.circular(spec.tabBarRadius),
            border: Border.all(
              color: AppTheme.textSec(context).withValues(alpha: 0.06),
            ),
          ),
          child: TabBar(
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(spec.tabBarRadius - 4),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: EdgeInsets.all(4),
            labelColor: primary,
            unselectedLabelColor: AppTheme.textSec(context),
            labelStyle: TextStyle(
              fontSize: spec.tabBarFontSize,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: spec.tabBarFontSize,
              fontWeight: FontWeight.w500,
            ),
            splashFactory: NoSplash.splashFactory,
            labelPadding: EdgeInsets.zero,
            tabs: [
              for (final label in _labels)
                Tab(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
