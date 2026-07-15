// lib/presentation/screens/profile/edit_profile_screen.dart
//
// Profili düzenleme ekranı. Yalnızca kendi profilimiz için erişilebilir
// (ProfileHeaderWidget'taki "Profili Düzenle" butonu üzerinden açılır).
// Ayrı bir binding'i yok: mevcut, zaten ProfileBinding tarafından kayıt
// edilmiş ProfileController örneğini aynı tag ile bulur.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../../data/datasources/remote/supabase_datasource.dart';
import '../../controllers/profile_controller.dart';
import 'widgets/profile_header/avatar_source_sheet.dart';
import 'widgets/profile_header/avatar_widget.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // AppBar
  static const double appBarTitleSize = 20;

  // Padding
  static const double paddingHorizontal = 20;
  static const double paddingTop = 24;
  static const double paddingBottom = 24;

  // Avatar
  static const double avatarSize = 104;
  static const double avatarSpacing = 10;
  static const double avatarChangeButtonFontSize = 13;

  // Form
  static const double formSpacing = 24;
  static const double labelSpacing = 8;
  static const double labelFontSize = 12;
  static const double labelLetterSpacing = 0.6;
  static const double fieldFontSize = 15;
  static const int fieldMaxLength = 30;
  static const int fieldMaxLengthFull = 60;
  static const double fieldIconSize = 20;
  static const double hintFontSize = 11.5;
  static const double hintLineHeight = 1.4;
  static const double buttonHeight = 50;
  static const double buttonFontSize = 16;
  static const double savingIndicatorSize = 20;
  static const double savingStrokeWidth = 2.4;
}

class _TabletSizes {
  // AppBar - tablet için daha büyük
  static const double appBarTitleSize = 24;

  // Padding - tablet için daha büyük
  static const double paddingHorizontal = 32;
  static const double paddingTop = 32;
  static const double paddingBottom = 32;

  // Avatar - tablet için daha büyük
  static const double avatarSize = 128;
  static const double avatarSpacing = 14;
  static const double avatarChangeButtonFontSize = 15;

  // Form - tablet için daha büyük
  static const double formSpacing = 32;
  static const double labelSpacing = 10;
  static const double labelFontSize = 14;
  static const double labelLetterSpacing = 0.7;
  static const double fieldFontSize = 17;
  static const int fieldMaxLength = 30;
  static const int fieldMaxLengthFull = 60;
  static const double fieldIconSize = 24;
  static const double hintFontSize = 13;
  static const double hintLineHeight = 1.5;
  static const double buttonHeight = 58;
  static const double buttonFontSize = 18;
  static const double savingIndicatorSize = 24;
  static const double savingStrokeWidth = 2.8;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateful)
// ═══════════════════════════════════════════════════════════

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
    final supabase = Get.find<SupabaseDataSource>();
    final tag = supabase.currentUser?.id ?? 'anonymous';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profili Düzenle',
          style: TextStyle(fontSize: _PhoneSizes.appBarTitleSize.sp),
        ),
      ),
      body: Obx(() {
        final profile = _controller.profile.value;
        final isSaving = _controller.isSavingProfile.value;
        final isUploading = _controller.isUploadingAvatar.value;

        return Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              _PhoneSizes.paddingHorizontal.w,
              _PhoneSizes.paddingTop.h,
              _PhoneSizes.paddingHorizontal.w,
              _PhoneSizes.paddingBottom.h,
            ),
            children: [
              // ── Avatar ────────────────────────────────────────────────
              Center(
                child: ProfileAvatarWidget(
                  avatarUrl: profile?.avatarUrl,
                  username: profile?.username ?? 'U',
                  isOwnProfile: true,
                  isUploading: isUploading,
                  size: _PhoneSizes.avatarSize.w,
                  onTap: () => showAvatarSourceSheet(context, _controller),
                ),
              ),
              SizedBox(height: _PhoneSizes.avatarSpacing.h),
              Center(
                child: TextButton(
                  onPressed: isUploading
                      ? null
                      : () => showAvatarSourceSheet(context, _controller),
                  child: Text(
                    'Fotoğrafı Değiştir',
                    style: TextStyle(
                      fontSize: _PhoneSizes.avatarChangeButtonFontSize.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: _PhoneSizes.formSpacing.h),

              // ── Kullanıcı adı ─────────────────────────────────────────
              Text(
                'Kullanıcı Adı',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: _PhoneSizes.labelFontSize.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: _PhoneSizes.labelLetterSpacing,
                ),
              ),
              SizedBox(height: _PhoneSizes.labelSpacing.h),
              TextFormField(
                controller: _usernameCtrl,
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: _PhoneSizes.fieldFontSize.sp,
                ),
                maxLength: _PhoneSizes.fieldMaxLength,
                decoration: InputDecoration(
                  hintText: 'kullanici_adi',
                  prefixIcon: Icon(
                    Icons.alternate_email_rounded,
                    color: AppTheme.textSec(context),
                    size: _PhoneSizes.fieldIconSize.sp,
                  ),
                  counterText: '',
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Kullanıcı adı boş olamaz.';
                  if (v.length < 3) return 'En az 3 karakter olmalı.';
                  if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(v)) {
                    return 'Sadece harf, rakam, "_" ve "." kullanılabilir.';
                  }
                  return null;
                },
              ),
              SizedBox(height: _PhoneSizes.formSpacing.h),

              // ── Ad Soyad ──────────────────────────────────────────────
              Text(
                'Ad Soyad',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: _PhoneSizes.labelFontSize.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: _PhoneSizes.labelLetterSpacing,
                ),
              ),
              SizedBox(height: _PhoneSizes.labelSpacing.h),
              TextFormField(
                controller: _fullNameCtrl,
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: _PhoneSizes.fieldFontSize.sp,
                ),
                maxLength: _PhoneSizes.fieldMaxLengthFull,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Ad Soyad',
                  prefixIcon: Icon(
                    Icons.badge_outlined,
                    color: AppTheme.textSec(context),
                    size: _PhoneSizes.fieldIconSize.sp,
                  ),
                  counterText: '',
                ),
              ),
              SizedBox(height: _PhoneSizes.labelSpacing.h),
              Text(
                'Ad soyad boş bırakılabilir; boş bırakılırsa profilinde '
                'kullanıcı adın öne çıkar.',
                style: TextStyle(
                  color: AppTheme.textSec(context).withValues(alpha: 0.8),
                  fontSize: _PhoneSizes.hintFontSize.sp,
                  height: _PhoneSizes.hintLineHeight,
                ),
              ),
              SizedBox(height: _PhoneSizes.formSpacing.h),

              // ── Kaydet ────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(
                      double.infinity,
                      _PhoneSizes.buttonHeight.h,
                    ),
                  ),
                  onPressed: isSaving ? null : _save,
                  child: isSaving
                      ? SizedBox(
                          width: _PhoneSizes.savingIndicatorSize.w,
                          height: _PhoneSizes.savingIndicatorSize.w,
                          child: CircularProgressIndicator(
                            strokeWidth: _PhoneSizes.savingStrokeWidth,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Kaydet',
                          style: TextStyle(
                            fontSize: _PhoneSizes.buttonFontSize.sp,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profili Düzenle',
          style: TextStyle(fontSize: _TabletSizes.appBarTitleSize),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Obx(() {
            final profile = _controller.profile.value;
            final isSaving = _controller.isSavingProfile.value;
            final isUploading = _controller.isUploadingAvatar.value;

            return Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  _TabletSizes.paddingHorizontal,
                  _TabletSizes.paddingTop,
                  _TabletSizes.paddingHorizontal,
                  _TabletSizes.paddingBottom,
                ),
                children: [
                  // ── Avatar ────────────────────────────────────────────────
                  Center(
                    child: ProfileAvatarWidget(
                      avatarUrl: profile?.avatarUrl,
                      username: profile?.username ?? 'U',
                      isOwnProfile: true,
                      isUploading: isUploading,
                      size: _TabletSizes.avatarSize,
                      onTap: () => showAvatarSourceSheet(context, _controller),
                    ),
                  ),
                  SizedBox(height: _TabletSizes.avatarSpacing),
                  Center(
                    child: TextButton(
                      onPressed: isUploading
                          ? null
                          : () => showAvatarSourceSheet(context, _controller),
                      child: Text(
                        'Fotoğrafı Değiştir',
                        style: TextStyle(
                          fontSize: _TabletSizes.avatarChangeButtonFontSize,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: _TabletSizes.formSpacing),

                  // ── Kullanıcı adı ─────────────────────────────────────────
                  Text(
                    'Kullanıcı Adı',
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: _TabletSizes.labelFontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: _TabletSizes.labelLetterSpacing,
                    ),
                  ),
                  SizedBox(height: _TabletSizes.labelSpacing),
                  TextFormField(
                    controller: _usernameCtrl,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: _TabletSizes.fieldFontSize,
                    ),
                    maxLength: _TabletSizes.fieldMaxLength,
                    decoration: InputDecoration(
                      hintText: 'kullanici_adi',
                      prefixIcon: Icon(
                        Icons.alternate_email_rounded,
                        color: AppTheme.textSec(context),
                        size: _TabletSizes.fieldIconSize,
                      ),
                      counterText: '',
                    ),
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return 'Kullanıcı adı boş olamaz.';
                      if (v.length < 3) return 'En az 3 karakter olmalı.';
                      if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(v)) {
                        return 'Sadece harf, rakam, "_" ve "." kullanılabilir.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: _TabletSizes.formSpacing),

                  // ── Ad Soyad ──────────────────────────────────────────────
                  Text(
                    'Ad Soyad',
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: _TabletSizes.labelFontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: _TabletSizes.labelLetterSpacing,
                    ),
                  ),
                  SizedBox(height: _TabletSizes.labelSpacing),
                  TextFormField(
                    controller: _fullNameCtrl,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: _TabletSizes.fieldFontSize,
                    ),
                    maxLength: _TabletSizes.fieldMaxLengthFull,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'Ad Soyad',
                      prefixIcon: Icon(
                        Icons.badge_outlined,
                        color: AppTheme.textSec(context),
                        size: _TabletSizes.fieldIconSize,
                      ),
                      counterText: '',
                    ),
                  ),
                  SizedBox(height: _TabletSizes.labelSpacing),
                  Text(
                    'Ad soyad boş bırakılabilir; boş bırakılırsa profilinde '
                    'kullanıcı adın öne çıkar.',
                    style: TextStyle(
                      color: AppTheme.textSec(context).withValues(alpha: 0.8),
                      fontSize: _TabletSizes.hintFontSize,
                      height: _TabletSizes.hintLineHeight,
                    ),
                  ),
                  SizedBox(height: _TabletSizes.formSpacing),

                  // ── Kaydet ────────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(
                          double.infinity,
                          _TabletSizes.buttonHeight,
                        ),
                      ),
                      onPressed: isSaving ? null : _save,
                      child: isSaving
                          ? SizedBox(
                              width: _TabletSizes.savingIndicatorSize,
                              height: _TabletSizes.savingIndicatorSize,
                              child: CircularProgressIndicator(
                                strokeWidth: _TabletSizes.savingStrokeWidth,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Kaydet',
                              style: TextStyle(
                                fontSize: _TabletSizes.buttonFontSize,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
