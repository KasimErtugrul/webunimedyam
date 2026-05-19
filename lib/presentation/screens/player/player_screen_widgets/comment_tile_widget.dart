// ═══════════════════════════════════════════════════════════════════════════
// Yorum kartı
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/comment_model.dart';

class CommentTileWidget extends StatelessWidget {
  final CommentModel comment;
  final VoidCallback onDelete;

  const CommentTileWidget({
    super.key,
    required this.comment,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.surface(context),
            child: Text(
              (comment.profile?.username ?? 'U')[0].toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.profile?.username ?? 'Kullanıcı',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  comment.content,
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppTheme.textSec(context),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}