/* // ─── Text Button (TEK WIDGET) ─────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../utils/shorts_player_sizes.dart';

class ShortsPlayerTextButton extends StatelessWidget {
  final ShortsPlayerSizes sizes;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ShortsPlayerTextButton({super.key, 
    required this.sizes,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: sizes.textBtnPaddingVertical,
        ),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(sizes.textBtnBorderRadius),
          border: Border.all(
            color: Colors.white12,
            width: sizes.textBtnBorderWidth,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white70,
              size: sizes.textBtnIconSize,
            ),
            SizedBox(width: sizes.textBtnSpacing),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: sizes.textBtnLabelFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} */