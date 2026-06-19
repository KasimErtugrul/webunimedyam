// ═══════════════════════════════════════════════════════════════════════════
// Yorum giriş alanı - KENDİ CONTROLLER'INI YÖNETİR
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';

class CommentInputWidget extends StatefulWidget {
  final void Function(String text) onSend;  // ← String parametre eklendi
  final FocusNode? focusNode;

  const CommentInputWidget({
    super.key,
    required this.onSend,
    this.focusNode,
  });

  @override
  State<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends State<CommentInputWidget> {
  // ✅ KENDİ CONTROLLER'INI OLUŞTURUYOR - DIŞARIDAN GELEN DEĞİL
  late final TextEditingController _textController;
  bool _hasText = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textController.addListener(_updateTextState);
    
    // İsteğe bağlı otomatik odaklanma
    widget.focusNode?.requestFocus();
  }

  @override
  void dispose() {
    _isDisposed = true;  // ✅ ÖNCE BAYRAĞI KALDIR
    _textController.removeListener(_updateTextState);  // ✅ SONRA LISTENER'I KALDIR
    _textController.dispose();  // ✅ EN SON DISPOSE ET
    super.dispose();
  }

  void _updateTextState() {
    // ✅ DISPOSE EDİLDİKTEN SONRA setState ÇAĞRILMASINI ÖNLE
    if (_isDisposed) return;
    
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _handleSend() {
    if (_hasText) {
      widget.onSend(_textController.text.trim());  // ✅ TEXT'İ PARAMETRE OLARAK GÖNDER
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(
          color: AppTheme.textSec(context).withOpacity(0.1),
        ),
        boxShadow: [
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
              controller: _textController,  // ✅ KENDİ CONTROLLER'INI KULLAN
              focusNode: widget.focusNode,
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
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                isDense: true,
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSend(),
            ),
          ),

          // ─── Gönder Butonu ──────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Material(
              color: _hasText
                  ? Theme.of(context).colorScheme.primary
                  : AppTheme.textSec(context).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
              child: InkWell(
                onTap: _handleSend,
                borderRadius: BorderRadius.circular(20.r),
                splashColor: Colors.white.withOpacity(0.2),
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