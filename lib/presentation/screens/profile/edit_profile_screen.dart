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
import '../../../data/datasources/remote/supabase_datasource.dart';
import '../../controllers/profile_controller.dart';
import 'widgets/profile_header/avatar_source_sheet.dart';
import 'widgets/profile_header/avatar_widget.dart';

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
    // Edit ekranı yalnızca kendi profilimiz için açıldığından, tag her
    // zaman mevcut kullanıcının id'si — profile_screen.dart / profile_binding.dart
    // ile aynı hesaplama (targetUserId ?? currentUserId, burada targetUserId
    // her zaman null).
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
      Get.snackbar('Başarılı', _controller.successMessage.value ?? 'Profil güncellendi.');
      _controller.successMessage.value = null;
      Get.back();
    } else {
      Get.snackbar('Hata', _controller.errorMessage.value ?? 'Profil güncellenemedi.');
      _controller.errorMessage.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profili Düzenle', style: TextStyle(fontSize: 20.sp)),
      ),
      body: Obx(() {
        final profile = _controller.profile.value;
        final isSaving = _controller.isSavingProfile.value;
        final isUploading = _controller.isUploadingAvatar.value;

        return Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
            children: [
              // ── Avatar ────────────────────────────────────────────────
              Center(
                child: ProfileAvatarWidget(
                  avatarUrl: profile?.avatarUrl,
                  username: profile?.username ?? 'U',
                  isOwnProfile: true,
                  isUploading: isUploading,
                  size: 104.w,
                  onTap: () => showAvatarSourceSheet(context, _controller),
                ),
              ),
              SizedBox(height: 10.h),
              Center(
                child: TextButton(
                  onPressed: isUploading
                      ? null
                      : () => showAvatarSourceSheet(context, _controller),
                  child: Text(
                    'Fotoğrafı Değiştir',
                    style: TextStyle(fontSize: 13.sp),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // ── Kullanıcı adı ─────────────────────────────────────────
              Text(
                'Kullanıcı Adı',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _usernameCtrl,
                style: TextStyle(color: AppTheme.textPri(context), fontSize: 15.sp),
                maxLength: 30,
                decoration: InputDecoration(
                  hintText: 'kullanici_adi',
                  prefixIcon: Icon(
                    Icons.alternate_email_rounded,
                    color: AppTheme.textSec(context),
                    size: 20.sp,
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

              SizedBox(height: 20.h),

              // ── Ad Soyad ──────────────────────────────────────────────
              Text(
                'Ad Soyad',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _fullNameCtrl,
                style: TextStyle(color: AppTheme.textPri(context), fontSize: 15.sp),
                maxLength: 60,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Ad Soyad',
                  prefixIcon: Icon(
                    Icons.badge_outlined,
                    color: AppTheme.textSec(context),
                    size: 20.sp,
                  ),
                  counterText: '',
                ),
              ),

              SizedBox(height: 8.h),
              Text(
                'Ad soyad boş bırakılabilir; boş bırakılırsa profilinde '
                'kullanıcı adın öne çıkar.',
                style: TextStyle(
                  color: AppTheme.textSec(context).withValues(alpha: 0.8),
                  fontSize: 11.5.sp,
                  height: 1.4,
                ),
              ),

              SizedBox(height: 32.h),

              // ── Kaydet ────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50.h),
                  ),
                  onPressed: isSaving ? null : _save,
                  child: isSaving
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text('Kaydet', style: TextStyle(fontSize: 16.sp)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
