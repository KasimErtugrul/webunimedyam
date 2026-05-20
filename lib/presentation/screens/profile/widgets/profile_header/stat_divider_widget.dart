import 'package:flutter/material.dart';

import '../../../../../app/themes/app_theme.dart';

class StatDividerWidget extends StatelessWidget {
  const StatDividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, color: AppTheme.surface(context));
  }
}
