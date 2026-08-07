import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../utils/stats_sizes.dart';

class VertDivider extends StatelessWidget {
  final StatsSizes sizes;
  const VertDivider({super.key, required this.sizes});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sizes.heroDividerWidth,
      height: sizes.heroDividerHeightVert,
      color: AppTheme.primaryColor.withValues(alpha: 0.2),
    );
  }
}
