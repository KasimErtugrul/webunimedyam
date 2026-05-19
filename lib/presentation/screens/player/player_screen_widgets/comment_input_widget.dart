// ═══════════════════════════════════════════════════════════════════════════
// Yorum giriş alanı
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';

class CommentInputWidget extends StatelessWidget {
  final TextEditingController textController;
  final VoidCallback onSend;
  const CommentInputWidget({
    super.key,
    required this.textController,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: textController,
            style: TextStyle(color: AppTheme.textPri(context), fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Yorum yaz...',
              hintStyle: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppTheme.surface(context),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onSend,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.send_rounded,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}