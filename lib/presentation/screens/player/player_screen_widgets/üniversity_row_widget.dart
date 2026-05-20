// ═══════════════════════════════════════════════════════════════════════════
// Üniversite Satırı  (logo · üniversite adı)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';

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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildLogo(context),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                universityName,
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSec(context),
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    final hasLogo = logoUrl != null && logoUrl!.isNotEmpty;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        color: AppTheme.surface(context),
        border: Border.all(
          color: AppTheme.surface(context),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasLogo
          ? Image.network(
              logoUrl!,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _fallbackIcon(context),
            )
          : _fallbackIcon(context),
    );
  }

  Widget _fallbackIcon(BuildContext context) {
    return Icon(
      Icons.account_balance_rounded,
      size: 18,
      color: AppTheme.textSec(context),
    );
  }
}