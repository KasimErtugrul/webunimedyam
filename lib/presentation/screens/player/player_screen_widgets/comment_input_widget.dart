// lib/presentation/screens/player/player_screen_widgets/comment_input_widget.dart
import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';

class _Sizes {
  final double containerPaddingH;
  final double containerPaddingV;
  final double containerRadius;
  final double containerBorderOpacity;
  final double containerShadowBlur;
  final double containerShadowOpacity;
  final double textFieldFontSize;
  final double textFieldVerticalPadding;
  final double textFieldLeftSpacing;
  final double sendButtonRadius;
  final double sendButtonPadding;
  final double sendButtonIconSize;
  final double sendButtonDisabledAlpha;
  final double sendButtonSplashAlpha;
  final double rightSpacing;

  const _Sizes._({
    required this.containerPaddingH,
    required this.containerPaddingV,
    required this.containerRadius,
    required this.containerBorderOpacity,
    required this.containerShadowBlur,
    required this.containerShadowOpacity,
    required this.textFieldFontSize,
    required this.textFieldVerticalPadding,
    required this.textFieldLeftSpacing,
    required this.sendButtonRadius,
    required this.sendButtonPadding,
    required this.sendButtonIconSize,
    required this.sendButtonDisabledAlpha,
    required this.sendButtonSplashAlpha,
    required this.rightSpacing,
  });

  factory _Sizes.of(BuildContext context) {
    // WEB (masaüstü tarayıcı, >=1024px): tablet ölçekleri + web ince ayarları.
    if (Responsive.isWeb(context)) {
      return const _Sizes._(
        containerPaddingH: 12,
        containerPaddingV: 8,
        containerRadius: 32,
        containerBorderOpacity: 0.1,
        containerShadowBlur: 14,
        containerShadowOpacity: 0.06,
        textFieldFontSize: 16,
        textFieldVerticalPadding: 12,
        textFieldLeftSpacing: 16,
        sendButtonRadius: 24,
        sendButtonPadding: 10,
        sendButtonIconSize: 22,
        sendButtonDisabledAlpha: 0.2,
        sendButtonSplashAlpha: 0.2,
        rightSpacing: 6,
      );
    }
    if (Responsive.isTablet(context)) {
      return const _Sizes._(
        containerPaddingH: 12,
        containerPaddingV: 8,
        containerRadius: 32,
        containerBorderOpacity: 0.1,
        containerShadowBlur: 14,
        containerShadowOpacity: 0.06,
        textFieldFontSize: 16,
        textFieldVerticalPadding: 12,
        textFieldLeftSpacing: 16,
        sendButtonRadius: 24,
        sendButtonPadding: 10,
        sendButtonIconSize: 22,
        sendButtonDisabledAlpha: 0.2,
        sendButtonSplashAlpha: 0.2,
        rightSpacing: 6,
      );
    }
    return const _Sizes._(
      containerPaddingH: 8,
      containerPaddingV: 6,
      containerRadius: 28,
      containerBorderOpacity: 0.1,
      containerShadowBlur: 10,
      containerShadowOpacity: 0.05,
      textFieldFontSize: 14,
      textFieldVerticalPadding: 10,
      textFieldLeftSpacing: 12,
      sendButtonRadius: 20,
      sendButtonPadding: 8,
      sendButtonIconSize: 18,
      sendButtonDisabledAlpha: 0.2,
      sendButtonSplashAlpha: 0.2,
      rightSpacing: 4,
    );
  }
}

const Duration _kAnimDuration = Duration(milliseconds: 200);

class CommentInputWidget extends StatefulWidget {
  final void Function(String text) onSend;
  final FocusNode? focusNode;

  const CommentInputWidget({super.key, required this.onSend, this.focusNode});

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
      setState(() => _hasText = hasText);
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
    final s = _Sizes.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: s.containerPaddingH,
        vertical: s.containerPaddingV,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(s.containerRadius),
      ),
      child: Row(
        children: [
          SizedBox(width: s.textFieldLeftSpacing),
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: widget.focusNode,
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: s.textFieldFontSize,
              ),
              decoration: InputDecoration(
                hintText: 'Yorum ekle...',
                hintStyle: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: s.textFieldFontSize,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: s.textFieldVerticalPadding,
                ),
                isDense: true,
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          AnimatedContainer(
            duration: _kAnimDuration,
            curve: Curves.easeInOut,
            child: Material(
              color: _hasText
                  ? primary
                  : AppTheme.textSec(
                      context,
                    ).withValues(alpha: s.sendButtonDisabledAlpha),
              borderRadius: BorderRadius.circular(s.sendButtonRadius),
              child: InkWell(
                onTap: _handleSend,
                borderRadius: BorderRadius.circular(s.sendButtonRadius),
                splashColor: Colors.white.withValues(
                  alpha: s.sendButtonSplashAlpha,
                ),
                child: Padding(
                  padding: EdgeInsets.all(s.sendButtonPadding),
                  child: Icon(
                    Icons.send_rounded,
                    color: _hasText
                        ? onPrimary
                        : AppTheme.textSec(context).withValues(alpha: 0.5),
                    size: s.sendButtonIconSize,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: s.rightSpacing),
        ],
      ),
    );
  }
}
