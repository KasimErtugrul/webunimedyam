// lib/presentation/screens/player/player_screen_widgets/university_row_widget.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';

class _Sizes {
  final double borderRadius;
  final double verticalPadding;
  final double fontSize;
  final double lineHeight;
  final double chevronSize;
  final double avatarSize;
  final double avatarSpacing;
  final double avatarIconSize;

  const _Sizes._({
    required this.borderRadius,
    required this.verticalPadding,
    required this.fontSize,
    required this.lineHeight,
    required this.chevronSize,
    required this.avatarSize,
    required this.avatarSpacing,
    required this.avatarIconSize,
  });

  factory _Sizes.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const _Sizes._(
        borderRadius: 12,
        verticalPadding: 6,
        fontSize: 16,
        lineHeight: 1.35,
        chevronSize: 22,
        avatarSize: 44,
        avatarSpacing: 12,
        avatarIconSize: 22,
      );
    }
    return const _Sizes._(
      borderRadius: 10,
      verticalPadding: 4,
      fontSize: 13,
      lineHeight: 1.3,
      chevronSize: 18,
      avatarSize: 36,
      avatarSpacing: 10,
      avatarIconSize: 18,
    );
  }
}

class UniversityRowWidget extends StatelessWidget {
  final String universityName;
  final String? logoUrl;
  final VoidCallback? onTap;

  const UniversityRowWidget({
    super.key,
    required this.universityName,
    this.logoUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = _Sizes.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(s.borderRadius),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: s.verticalPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Tasarımdaki kanal satırı: yuvarlak üniversite logosu/avatarı.
            // `logoUrl` parametresi önceden alınıp hiç çizilmiyordu; artık
            // gerçekten kullanılıyor (uydurma bir görsel eklenmedi).
            Container(
              width: s.avatarSize,
              height: s.avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
              ),
              clipBehavior: Clip.antiAlias,
              child: (logoUrl != null && logoUrl!.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: logoUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Icon(
                        Icons.school_rounded,
                        color: AppTheme.textSec(context),
                        size: s.avatarIconSize,
                      ),
                    )
                  : Icon(
                      Icons.school_rounded,
                      color: AppTheme.textSec(context),
                      size: s.avatarIconSize,
                    ),
            ),
            SizedBox(width: s.avatarSpacing),
            Expanded(
              child: Text(
                universityName,
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: s.fontSize,
                  fontWeight: FontWeight.w600,
                  height: s.lineHeight,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSec(context),
                size: s.chevronSize,
              ),
          ],
        ),
      ),
    );
  }
}