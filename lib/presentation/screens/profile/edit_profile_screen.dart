// lib/presentation/screens/profile/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../controllers/profile_controller.dart';
import 'widgets/profile_header/avatar_source_sheet.dart';
import 'widgets/profile_header/avatar_widget.dart';

class _Sizes {
  final bool isTablet;
  final double maxContentWidth;
  final double appBarTitleSize;
  final double paddingH;
  final double paddingTop;
  final double paddingBottom;
  final double avatarSize;
  final double avatarSpacing;
  final double avatarChangeButtonFontSize;
  final double formSpacing;
  final double labelSpacing;
  final double labelFontSize;
  final double labelLetterSpacing;
  final double fieldFontSize;
  final int fieldMaxLength;
  final int fieldMaxLengthFull;
  final double fieldIconSize;
  final double fieldRadius;
  final double fieldPaddingH;
  final double fieldPaddingV;
  final double hintFontSize;
  final double hintLineHeight;
  final double buttonHeight;
  final double buttonRadius;
  final double buttonFontSize;
  final double savingIndicatorSize;
  final double savingStrokeWidth;

  const _Sizes._({
    required this.isTablet,
    required this.maxContentWidth,
    required this.appBarTitleSize,
    required this.paddingH,
    required this.paddingTop,
    required this.paddingBottom,
    required this.avatarSize,
    required this.avatarSpacing,
    required this.avatarChangeButtonFontSize,
    required this.formSpacing,
    required this.labelSpacing,
    required this.labelFontSize,
    required this.labelLetterSpacing,
    required this.fieldFontSize,
    required this.fieldMaxLength,
    required this.fieldMaxLengthFull,
    required this.fieldIconSize,
    required this.fieldRadius,
    required this.fieldPaddingH,
    required this.fieldPaddingV,
    required this.hintFontSize,
    required this.hintLineHeight,
    required this.buttonHeight,
    required this.buttonRadius,
    required this.buttonFontSize,
    required this.savingIndicatorSize,
    required this.savingStrokeWidth,
  });

  factory _Sizes.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const _Sizes._(
        isTablet: true,
        maxContentWidth: 560,
        appBarTitleSize: 24,
        paddingH: 32,
        paddingTop: 32,
        paddingBottom: 32,
        avatarSize: 128,
        avatarSpacing: 14,
        avatarChangeButtonFontSize: 15,
        formSpacing: 28,
        labelSpacing: 10,
        labelFontSize: 13,
        labelLetterSpacing: 0.7,
        fieldFontSize: 17,
        fieldMaxLength: 30,
        fieldMaxLengthFull: 60,
        fieldIconSize: 24,
        fieldRadius: 14,
        fieldPaddingH: 18,
        fieldPaddingV: 18,
        hintFontSize: 13,
        hintLineHeight: 1.5,
        buttonHeight: 58,
        buttonRadius: 16,
        buttonFontSize: 18,
        savingIndicatorSize: 24,
        savingStrokeWidth: 2.8,
      );
    }
    return const _Sizes._(
      isTablet: false,
      maxContentWidth: double.infinity,
      appBarTitleSize: 20,
      paddingH: 20,
      paddingTop: 24,
      paddingBottom: 24,
      avatarSize: 104,
      avatarSpacing: 10,
      avatarChangeButtonFontSize: 13,
      formSpacing: 22,
      labelSpacing: 8,
      labelFontSize: 11.5,
      labelLetterSpacing: 0.6,
      fieldFontSize: 15,
      fieldMaxLength: 30,
      fieldMaxLengthFull: 60,
      fieldIconSize: 20,
      fieldRadius: 12,
      fieldPaddingH: 14,
      fieldPaddingV: 16,
      hintFontSize: 11.5,
      hintLineHeight: 1.4,
      buttonHeight: 52,
      buttonRadius: 14,
      buttonFontSize: 16,
      savingIndicatorSize: 20,
      savingStrokeWidth: 2.4,
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final ProfileController _controller;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _fullNameCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final tag = Get.find<AuthRepository>().currentUserId ?? 'anonymous';
    _controller = Get.find<ProfileController>(tag: tag);

    final profile = _controller.profile.value;
    _usernameCtrl = TextEditingController(text: profile?.username ?? '');
    _fullNameCtrl = TextEditingController(text: profile?.fullName ?? '');
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _fullNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final ok = await _controller.updateProfile(
      username: _usernameCtrl.text.trim(),
      fullName: _fullNameCtrl.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      Get.snackbar(
        'Başarılı',
        _controller.successMessage.value ?? 'Profil güncellendi.',
      );
      _controller.successMessage.value = null;
      Get.back();
    } else {
      Get.snackbar(
        'Hata',
        _controller.errorMessage.value ?? 'Profil güncellenemedi.',
      );
      _controller.errorMessage.value = null;
    }
  }

  String? _validateUsername(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Kullanıcı adı boş olamaz.';
    if (v.length < 3) return 'En az 3 karakter olmalı.';
    if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(v)) {
      return 'Sadece harf, rakam, "_" ve "." kullanılabilir.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final spec = _Sizes.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profili Düzenle',
          style: TextStyle(fontSize: spec.appBarTitleSize),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: spec.maxContentWidth),
          child: Obx(() {
            final profile = _controller.profile.value;
            final isSaving = _controller.isSavingProfile.value;
            final isUploading = _controller.isUploadingAvatar.value;

            return Form(
              key: _formKey,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  spec.paddingH,
                  spec.paddingTop,
                  spec.paddingH,
                  spec.paddingBottom,
                ),
                children: [
                  // ── Avatar ──
                  Center(
                    child: ProfileAvatarWidget(
                      avatarUrl: profile?.avatarUrl,
                      username: profile?.username ?? 'U',
                      isOwnProfile: true,
                      isUploading: isUploading,
                      size: spec.avatarSize,
                      onTap: () => showAvatarSourceSheet(context, _controller),
                    ),
                  ).animate().fadeIn(duration: 400.ms).scaleXY(
                        begin: 0.8,
                        end: 1,
                        duration: 500.ms,
                        curve: Curves.easeOutBack,
                      ),
                  SizedBox(height: spec.avatarSpacing),
                  Center(
                    child: TextButton(
                      onPressed: isUploading
                          ? null
                          : () => showAvatarSourceSheet(context, _controller),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                      ),
                      child: Text(
                        'Fotoğrafı Değiştir',
                        style: TextStyle(
                          fontSize: spec.avatarChangeButtonFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 150.ms, duration: 300.ms),
                  SizedBox(height: spec.formSpacing),

                  // ── Kullanıcı adı ──
                  _FieldLabel(text: 'Kullanıcı Adı', spec: spec),
                  SizedBox(height: spec.labelSpacing),
                  TextFormField(
                    controller: _usernameCtrl,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: spec.fieldFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLength: spec.fieldMaxLength,
                    decoration: _fieldDecoration(
                      context,
                      spec: spec,
                      hint: 'kullanici_adi',
                      icon: Icons.alternate_email_rounded,
                    ),
                    validator: _validateUsername,
                  ).animate().fadeIn(delay: 250.ms, duration: 300.ms),
                  SizedBox(height: spec.formSpacing),

                  // ── Ad Soyad ──
                  _FieldLabel(text: 'Ad Soyad', spec: spec),
                  SizedBox(height: spec.labelSpacing),
                  TextFormField(
                    controller: _fullNameCtrl,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: spec.fieldFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLength: spec.fieldMaxLengthFull,
                    textCapitalization: TextCapitalization.words,
                    decoration: _fieldDecoration(
                      context,
                      spec: spec,
                      hint: 'Ad Soyad',
                      icon: Icons.badge_outlined,
                    ),
                  ).animate().fadeIn(delay: 350.ms, duration: 300.ms),
                  SizedBox(height: spec.labelSpacing),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: spec.hintFontSize + 2,
                        color: AppTheme.textSec(context).withValues(alpha: 0.6),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Boş bırakılırsa profilinde kullanıcı adın öne çıkar.',
                          style: TextStyle(
                            color: AppTheme.textSec(context)
                                .withValues(alpha: 0.75),
                            fontSize: spec.hintFontSize,
                            height: spec.hintLineHeight,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 400.ms, duration: 300.ms),
                  SizedBox(height: spec.formSpacing),

                  // ── Kaydet ──
                  SizedBox(
                    width: double.infinity,
                    height: spec.buttonHeight,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            spec.buttonRadius,
                          ),
                        ),
                      ),
                      onPressed: isSaving ? null : _save,
                      icon: isSaving
                          ? SizedBox(
                              width: spec.savingIndicatorSize,
                              height: spec.savingIndicatorSize,
                              child: CircularProgressIndicator(
                                strokeWidth: spec.savingStrokeWidth,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_rounded, size: 20),
                      label: Text(
                        'Kaydet',
                        style: TextStyle(
                          fontSize: spec.buttonFontSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms, duration: 300.ms),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(
    BuildContext context, {
    required _Sizes spec,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppTheme.textSec(context).withValues(alpha: 0.5),
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(
        icon,
        color: AppTheme.textSec(context),
        size: spec.fieldIconSize,
      ),
      counterText: '',
      filled: true,
      fillColor: AppTheme.card(context),
      contentPadding: EdgeInsets.symmetric(
        horizontal: spec.fieldPaddingH,
        vertical: spec.fieldPaddingV,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(spec.fieldRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(spec.fieldRadius),
        borderSide: BorderSide(
          color: AppTheme.textSec(context).withValues(alpha: 0.08),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(spec.fieldRadius),
        borderSide: BorderSide(
          color: AppTheme.primaryColor.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(spec.fieldRadius),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(spec.fieldRadius),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final _Sizes spec;
  const _FieldLabel({required this.text, required this.spec});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          color: AppTheme.textSec(context),
          fontSize: spec.labelFontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: spec.labelLetterSpacing,
        ),
      ),
    );
  }
}