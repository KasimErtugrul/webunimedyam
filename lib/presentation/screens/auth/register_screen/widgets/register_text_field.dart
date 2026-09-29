// lib/presentation/screens/auth/widgets/register_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../register_layout_spec.dart';



/// Tasarımdaki alan satırının bire bir karşılığı:
/// üstte label-md (+ sağda opsiyonel hint widget'ı) → altta
/// rounded-lg bg-surface-container gövde; odakta bg-surface-container-high.
/// Kenarlık YOK — dolgu rengi değişimi (focus-within transition-colors).
class RegisterTextField extends StatefulWidget {
  const RegisterTextField({
    super.key,
    required this.sizes,
    required this.label,
    required this.icon,
    required this.controller,
    this.labelHint,
    this.focusNode,
    this.hint,
    this.obscure = false,
    this.suffix,
    this.formFieldKey,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.validator,
    this.onSubmitted,
  });

  final RegisterSizes sizes;
  final String label;
  final IconData icon;
  final TextEditingController controller;

  /// Etiket satırının sağında görünen widget ("Uygun" rozeti,
  /// ".edu.tr ile Rozet Kazan" vb.).
  final Widget? labelHint;
  final FocusNode? focusNode;
  final String? hint;
  final bool obscure;
  final Widget? suffix;

  /// Dışarıdan FormFieldState'e erişmek isteyenler için (ör. şifre
  /// tekrarı alanını canlı yeniden doğrulamak).
  final GlobalKey<FormFieldState<String>>? formFieldKey;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final bool enableSuggestions;
  final bool autocorrect;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  @override
  State<RegisterTextField> createState() => _RegisterTextFieldState();
}

class _RegisterTextFieldState extends State<RegisterTextField> {
  FocusNode? _ownFocus;
  bool _focused = false;

  FocusNode get _effectiveFocus =>
      widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _effectiveFocus.addListener(_handleFocus);
  }

  @override
  void dispose() {
    _effectiveFocus.removeListener(_handleFocus);
    _ownFocus?.dispose();
    super.dispose();
  }

  void _handleFocus() {
    if (mounted) setState(() => _focused = _effectiveFocus.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = widget.sizes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Etiket satırı — solda başlık, sağda opsiyonel hint
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: s.labelFontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.02 * s.labelFontSize,
                ),
              ),
            ),
            if (widget.labelHint != null) widget.labelHint!,
          ],
        ),
        SizedBox(height: s.fieldGroupGap),

        TextFormField(
          key: widget.formFieldKey,
          controller: widget.controller,
          focusNode: _effectiveFocus,
          obscureText: widget.obscure,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          inputFormatters: widget.inputFormatters,
          enableSuggestions: widget.enableSuggestions,
          autocorrect: widget.autocorrect,
          validator: widget.validator,
          onFieldSubmitted: widget.onSubmitted,
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: s.fieldFontSize,
            fontWeight: FontWeight.w400,
          ),
          cursorColor: scheme.primary,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: scheme.outline, // placeholder:text-outline
              fontSize: s.fieldFontSize,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            // focus-within:bg-surface-container-high
            fillColor: _focused
                ? scheme.surfaceContainerHigh
                : scheme.surfaceContainer,
            constraints: BoxConstraints(minHeight: s.fieldVPadding * 2 + s.fieldFontSize * 1.4),
            contentPadding: EdgeInsets.fromLTRB(
              0,
              s.fieldVPadding,
              widget.suffix != null
                  ? s.fieldPaddingRightPassword
                  : s.fieldPaddingRight,
              s.fieldVPadding,
            ),
            // Soldaki absolute ikon: left-3.5 + 16px ikon → metin pl-11 (44)
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: s.fieldIconLeft),
              child: Icon(
                widget.icon,
                size: s.fieldIconSize,
                color: scheme.outline,
              ),
            ),
            prefixIconConstraints: BoxConstraints(
              minWidth: s.fieldPaddingLeft,
              minHeight: s.fieldIconSize,
            ),
            suffixIcon: widget.suffix,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(s.fieldRadius),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(s.fieldRadius),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(s.fieldRadius),
              borderSide: BorderSide(color: scheme.error, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(s.fieldRadius),
              borderSide: BorderSide(color: scheme.error, width: 1.5),
            ),
            errorStyle: TextStyle(
              color: scheme.error,
              fontSize: s.labelHintFontSize + 1,
            ),
          ),
        ),
      ],
    );
  }
}