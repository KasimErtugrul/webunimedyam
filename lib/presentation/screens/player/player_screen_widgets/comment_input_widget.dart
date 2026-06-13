// ═══════════════════════════════════════════════════════════════════════════
// Yorum giriş alanı
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';

class CommentInputWidget extends StatefulWidget {
  final TextEditingController textController;
  final VoidCallback onSend;

  const CommentInputWidget({
    super.key,
    required this.textController,
    required this.onSend,
  });

  @override
  State<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends State<CommentInputWidget> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.textController.addListener(_updateTextState);
  }

  @override
  void dispose() {
    widget.textController.removeListener(_updateTextState);
    super.dispose();
  }

  void _updateTextState() {
    final hasText = widget.textController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _handleSend() {
    if (_hasText) {
      widget.onSend();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(28.r), // Yuvarlak "pill" görünümü
        border: Border.all(
          color: AppTheme.textSec(context).withOpacity(0.1), // İnce dış çerçeve
        ),
        boxShadow: [
          // Hafif bir alt gölge ile alanı ön plana çıkar
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 12.w),

          // ─── Metin Giriş Alanı ──────────────────────────────────
          Expanded(
            child: TextField(
              controller: widget.textController,
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: 14.sp,
              ),
              decoration: InputDecoration(
                hintText: 'Yorum ekle...',
                hintStyle: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: 14.sp,
                ),
                border: InputBorder.none, // Dış çerçeveyi container yönetiyor
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                isDense: true,
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSend(), // Klavyeden gönderme
            ),
          ),

          // ─── Gönder Butonu ──────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Material(
              color: _hasText
                  ? Theme.of(context).colorScheme.primary
                  : AppTheme.textSec(context).withOpacity(0.2), // Pasif hali
              borderRadius: BorderRadius.circular(20.r),
              child: InkWell(
                onTap: _handleSend,
                borderRadius: BorderRadius.circular(20.r),
                splashColor: Colors.white.withOpacity(0.2), // Ripple efekti
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Icon(
                    Icons.send_rounded,
                    color: _hasText
                        ? Theme.of(context).colorScheme.onPrimary
                        : AppTheme.textSec(context).withOpacity(0.5),
                    size: 18.sp,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: 4.w),
        ],
      ),
    );
  }
}
