// ═══════════════════════════════════════════════════════════════════════════
// Yorum giriş alanı - KENDİ CONTROLLER'INI YÖNETİR
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // Container
  static const double containerPaddingHorizontal = 8;
  static const double containerPaddingVertical = 6;
  static const double containerBorderRadius = 28;
  static const double containerBorderOpacity = 0.1;
  static const double containerShadowBlur = 10;
  static const double containerShadowOpacity = 0.05;

  // Text field
  static const double textFieldFontSize = 14;
  static const double textFieldVerticalPadding = 10;
  static const double textFieldLeftSpacing = 12;

  // Send button
  static const double sendButtonRadius = 20;
  static const double sendButtonPadding = 8;
  static const double sendButtonIconSize = 18;
  static const double sendButtonDisabledAlpha = 0.2;
  static const double sendButtonSplashAlpha = 0.2;

  // Spacing
  static const double rightSpacing = 4;

  // Animasyon
  static const Duration animDuration = Duration(milliseconds: 200);
}

class _TabletSizes {
  // Container - tablet için daha büyük
  static const double containerPaddingHorizontal = 12;
  static const double containerPaddingVertical = 8;
  static const double containerBorderRadius = 32;
  static const double containerBorderOpacity = 0.1;
  static const double containerShadowBlur = 14;
  static const double containerShadowOpacity = 0.06;

  // Text field - tablet için daha büyük
  static const double textFieldFontSize = 16;
  static const double textFieldVerticalPadding = 12;
  static const double textFieldLeftSpacing = 16;

  // Send button - tablet için daha büyük
  static const double sendButtonRadius = 24;
  static const double sendButtonPadding = 10;
  static const double sendButtonIconSize = 22;
  static const double sendButtonDisabledAlpha = 0.2;
  static const double sendButtonSplashAlpha = 0.2;

  // Spacing - tablet için daha geniş
  static const double rightSpacing = 6;

  // Animasyon
  static const Duration animDuration = Duration(milliseconds: 200);
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateful)
// ═══════════════════════════════════════════════════════════

class CommentInputWidget extends StatefulWidget {
  final void Function(String text) onSend;
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
  late final TextEditingController _textController;
  bool _hasText = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textController.addListener(_updateTextState);
    widget.focusNode?.requestFocus();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _textController.removeListener(_updateTextState);
    _textController.dispose();
    super.dispose();
  }

  void _updateTextState() {
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
      widget.onSend(_textController.text.trim());
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // KURAL 5 — TEK DALLANMA NOKTASI
    return Responsive.isTablet(context)
        ? _buildTablet(context)
        : _buildPhone(context);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI (BİREBİR AYNI)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPhone(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _PhoneSizes.containerPaddingHorizontal.w,
        vertical: _PhoneSizes.containerPaddingVertical.h,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(_PhoneSizes.containerBorderRadius.r),
        border: Border.all(
          color: AppTheme.textSec(context).withValues(alpha:_PhoneSizes.containerBorderOpacity),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:_PhoneSizes.containerShadowOpacity),
            blurRadius: _PhoneSizes.containerShadowBlur.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: _PhoneSizes.textFieldLeftSpacing.w),
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: widget.focusNode,
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: _PhoneSizes.textFieldFontSize.sp,
              ),
              decoration: InputDecoration(
                hintText: 'Yorum ekle...',
                hintStyle: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: _PhoneSizes.textFieldFontSize.sp,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: _PhoneSizes.textFieldVerticalPadding.h,
                ),
                isDense: true,
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          AnimatedContainer(
            duration: _PhoneSizes.animDuration,
            curve: Curves.easeInOut,
            child: Material(
              color: _hasText
                  ? Theme.of(context).colorScheme.primary
                  : AppTheme.textSec(context).withValues(alpha:_PhoneSizes.sendButtonDisabledAlpha),
              borderRadius: BorderRadius.circular(_PhoneSizes.sendButtonRadius.r),
              child: InkWell(
                onTap: _handleSend,
                borderRadius: BorderRadius.circular(_PhoneSizes.sendButtonRadius.r),
                splashColor: Colors.white.withValues(alpha:_PhoneSizes.sendButtonSplashAlpha),
                child: Padding(
                  padding: EdgeInsets.all(_PhoneSizes.sendButtonPadding.w),
                  child: Icon(
                    Icons.send_rounded,
                    color: _hasText
                        ? Theme.of(context).colorScheme.onPrimary
                        : AppTheme.textSec(context).withValues(alpha:0.5),
                    size: _PhoneSizes.sendButtonIconSize.sp,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: _PhoneSizes.rightSpacing.w),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _TabletSizes.containerPaddingHorizontal,
        vertical: _TabletSizes.containerPaddingVertical,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(_TabletSizes.containerBorderRadius),
        border: Border.all(
          color: AppTheme.textSec(context).withValues(alpha:_TabletSizes.containerBorderOpacity),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:_TabletSizes.containerShadowOpacity),
            blurRadius: _TabletSizes.containerShadowBlur,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: _TabletSizes.textFieldLeftSpacing),
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: widget.focusNode,
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: _TabletSizes.textFieldFontSize,
              ),
              decoration: InputDecoration(
                hintText: 'Yorum ekle...',
                hintStyle: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: _TabletSizes.textFieldFontSize,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: _TabletSizes.textFieldVerticalPadding,
                ),
                isDense: true,
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          AnimatedContainer(
            duration: _TabletSizes.animDuration,
            curve: Curves.easeInOut,
            child: Material(
              color: _hasText
                  ? Theme.of(context).colorScheme.primary
                  : AppTheme.textSec(context).withValues(alpha:_TabletSizes.sendButtonDisabledAlpha),
              borderRadius: BorderRadius.circular(_TabletSizes.sendButtonRadius),
              child: InkWell(
                onTap: _handleSend,
                borderRadius: BorderRadius.circular(_TabletSizes.sendButtonRadius),
                splashColor: Colors.white.withValues(alpha:_TabletSizes.sendButtonSplashAlpha),
                child: Padding(
                  padding: EdgeInsets.all(_TabletSizes.sendButtonPadding),
                  child: Icon(
                    Icons.send_rounded,
                    color: _hasText
                        ? Theme.of(context).colorScheme.onPrimary
                        : AppTheme.textSec(context).withValues(alpha:0.5),
                    size: _TabletSizes.sendButtonIconSize,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: _TabletSizes.rightSpacing),
        ],
      ),
    );
  }
}