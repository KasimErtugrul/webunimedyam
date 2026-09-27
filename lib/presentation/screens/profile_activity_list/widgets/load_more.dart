// ─── Daha Fazla Yükle Göstergesi ───────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../utils/sizes.dart';

class ProfileActivityListLoadMore extends StatelessWidget {
  final ProfileActivityListSizes sizes;
  const ProfileActivityListLoadMore({super.key, required this.sizes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: sizes.loadMorePaddingVertical),
      child: Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
          strokeWidth: sizes.loadMoreStrokeWidth,
        ),
      ),
    );
  }
}