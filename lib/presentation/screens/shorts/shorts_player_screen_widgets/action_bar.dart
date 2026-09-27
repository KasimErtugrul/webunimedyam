// ─── Aksiyon Çubuğu (Beğen / Kaydet / Paylaş / Ses) ────────────────────────

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../utils/shorts_player_sizes.dart';

class ShortsPlayerActionBar extends StatelessWidget {
  final ShortsPlayerSizes sizes;
  final bool isLiked;
  final bool isSaved;
  final bool isMuted;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onToggleMute;

  const ShortsPlayerActionBar({
    super.key,
    required this.sizes,
    required this.isLiked,
    required this.isSaved,
    required this.isMuted,
    required this.onLike,
    required this.onSave,
    required this.onShare,
    required this.onToggleMute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(sizes.actionBarPadding),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(sizes.actionBarRadius),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ActionButton(
            sizes: sizes,
            icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            label: 'Beğen',
            color: isLiked ? AppTheme.darkError : Colors.white,
            onTap: onLike,
          ),
          _ActionButton(
            sizes: sizes,
            icon: isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            label: 'Kaydet',
            color: isSaved ? AppTheme.primaryColor : Colors.white,
            onTap: onSave,
          ),
          _ActionButton(
            sizes: sizes,
            icon: Icons.share_rounded,
            label: 'Paylaş',
            color: Colors.white,
            onTap: onShare,
          ),
          _ActionButton(
            sizes: sizes,
            icon: isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            label: isMuted ? 'Sessiz' : 'Ses',
            color: isMuted ? Colors.white : AppTheme.primaryColor,
            onTap: onToggleMute,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final ShortsPlayerSizes sizes;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.sizes,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(sizes.actionBarRadius),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: sizes.actionIconContainerSize,
            height: sizes.actionIconContainerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
            child: Icon(icon, color: color, size: sizes.actionIconSize),
          ),
          SizedBox(height: sizes.actionLabelSpacing),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: sizes.actionLabelFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
