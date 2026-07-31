// lib/presentation/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../controllers/auth_controller.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // AppBar
  static const double backIconSize = 20;

  // Padding
  static const double mainPaddingHorizontal = 24;
  static const double topSpacing = 20;
  static const double headerSpacing = 24;

  // Header icon
  static const double headerIconSize = 72;
  static const double headerIconBorderRadius = 20;
  static const double headerIconInnerSize = 36;
  static const double headerShadowBlur = 16;
  static const double headerShadowOffsetY = 6;

  // Header text
  static const double headerTitleSize = 26;
  static const double headerSubtitleSize = 15;
  static const double headerSubtitleSpacing = 8;

  // Form card
  static const double cardPadding = 20;
  static const double cardBorderRadius = 20;

  // TextField
  static const double fieldFontSize = 15;
  static const double fieldPaddingHorizontal = 16;
  static const double fieldPaddingVertical = 16;
  static const double fieldBorderRadius = 12;
  static const double fieldIconSize = 22;
  static const double fieldBorderWidth = 1.2;
  static const double fieldFocusedBorderWidth = 1.8;
  static const double fieldLabelFontSize = 14;
  static const double fieldFloatingLabelFontSize = 13;
  static const double fieldSpacing = 16;

  // Error
  static const double errorPadding = 14;
  static const double errorBorderRadius = 12;
  static const double errorIconSize = 20;
  static const double errorFontSize = 13;
  static const double errorSpacing = 10;
  static const double errorBottomMargin = 16;

  // Button
  static const double buttonHeight = 54;
  static const double buttonBorderRadius = 14;
  static const double buttonFontSize = 16;
  static const double loadingIndicatorSize = 24;
  static const double loadingStrokeWidth = 2.5;
  static const double buttonShadowBlur = 12;
  static const double buttonShadowOffsetY = 4;
}

class _TabletSizes {
  // AppBar - tablet için daha büyük
  static const double backIconSize = 24;

  // Padding - tablet için daha büyük
  static const double mainPaddingHorizontal = 40;
  static const double topSpacing = 30;
  static const double headerSpacing = 30;

  // Header icon - tablet için daha büyük
  static const double headerIconSize = 88;
  static const double headerIconBorderRadius = 24;
  static const double headerIconInnerSize = 44;
  static const double headerShadowBlur = 20;
  static const double headerShadowOffsetY = 8;

  // Header text - tablet için daha büyük
  static const double headerTitleSize = 32;
  static const double headerSubtitleSize = 18;
  static const double headerSubtitleSpacing = 10;

  // Form card - tablet için daha büyük
  static const double cardPadding = 28;
  static const double cardBorderRadius = 24;

  // TextField - tablet için daha büyük
  static const double fieldFontSize = 17;
  static const double fieldPaddingHorizontal = 20;
  static const double fieldPaddingVertical = 20;
  static const double fieldBorderRadius = 14;
  static const double fieldIconSize = 26;
  static const double fieldBorderWidth = 1.5;
  static const double fieldFocusedBorderWidth = 2;
  static const double fieldLabelFontSize = 16;
  static const double fieldFloatingLabelFontSize = 15;
  static const double fieldSpacing = 20;

  // Error - tablet için daha büyük
  static const double errorPadding = 18;
  static const double errorBorderRadius = 14;
  static const double errorIconSize = 24;
  static const double errorFontSize = 15;
  static const double errorSpacing = 12;
  static const double errorBottomMargin = 20;

  // Button - tablet için daha büyük
  static const double buttonHeight = 60;
  static const double buttonBorderRadius = 16;
  static const double buttonFontSize = 18;
  static const double loadingIndicatorSize = 28;
  static const double loadingStrokeWidth = 3;
  static const double buttonShadowBlur = 16;
  static const double buttonShadowOffsetY = 6;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateful)
// ═══════════════════════════════════════════════════════════

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  InputDecoration _inputDecoration({
    required String labelText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    final isDark = AppTheme.isDark(context);
    final isTablet = Responsive.isTablet(context);
    // final sizes = isTablet ? _TabletSizes() : _PhoneSizes();

    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        color: AppTheme.textSec(context),
        fontSize: isTablet
            ? _TabletSizes.fieldLabelFontSize
            : _PhoneSizes.fieldLabelFontSize.sp,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: TextStyle(
        color: AppTheme.primaryColor,
        fontSize: isTablet
            ? _TabletSizes.fieldFloatingLabelFontSize
            : _PhoneSizes.fieldFloatingLabelFontSize.sp,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: AppTheme.primaryColor,
        size: isTablet
            ? _TabletSizes.fieldIconSize
            : _PhoneSizes.fieldIconSize.sp,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark
          ? AppTheme.darkBackground.withValues(alpha: 0.6)
          : AppTheme.lightBackground,
      contentPadding: EdgeInsets.symmetric(
        horizontal: isTablet
            ? _TabletSizes.fieldPaddingHorizontal
            : _PhoneSizes.fieldPaddingHorizontal.w,
        vertical: isTablet
            ? _TabletSizes.fieldPaddingVertical
            : _PhoneSizes.fieldPaddingVertical.h,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          isTablet
              ? _TabletSizes.fieldBorderRadius
              : _PhoneSizes.fieldBorderRadius.r,
        ),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.12),
          width: isTablet
              ? _TabletSizes.fieldBorderWidth
              : _PhoneSizes.fieldBorderWidth,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          isTablet
              ? _TabletSizes.fieldBorderRadius
              : _PhoneSizes.fieldBorderRadius.r,
        ),
        borderSide: BorderSide(
          color: AppTheme.primaryColor,
          width: isTablet
              ? _TabletSizes.fieldFocusedBorderWidth
              : _PhoneSizes.fieldFocusedBorderWidth,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          isTablet
              ? _TabletSizes.fieldBorderRadius
              : _PhoneSizes.fieldBorderRadius.r,
        ),
        borderSide: BorderSide(
          color: Colors.red.shade400,
          width: isTablet
              ? _TabletSizes.fieldBorderWidth
              : _PhoneSizes.fieldBorderWidth,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          isTablet
              ? _TabletSizes.fieldBorderRadius
              : _PhoneSizes.fieldBorderRadius.r,
        ),
        borderSide: BorderSide(
          color: Colors.red.shade400,
          width: isTablet
              ? _TabletSizes.fieldFocusedBorderWidth
              : _PhoneSizes.fieldFocusedBorderWidth,
        ),
      ),
    );
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
    final controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        backgroundColor: AppTheme.bg(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPri(context),
            size: _PhoneSizes.backIconSize.sp,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text('Kayıt Ol'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: _PhoneSizes.mainPaddingHorizontal.w,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: _PhoneSizes.topSpacing.h),
              Center(
                child: Container(
                  width: _PhoneSizes.headerIconSize.w,
                  height: _PhoneSizes.headerIconSize.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(
                      _PhoneSizes.headerIconBorderRadius.r,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: _PhoneSizes.headerShadowBlur.r,
                        offset: Offset(0, _PhoneSizes.headerShadowOffsetY.h),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person_add_rounded,
                    color: Colors.white,
                    size: _PhoneSizes.headerIconInnerSize.sp,
                  ),
                ),
              ),
              SizedBox(height: _PhoneSizes.headerSpacing.h),
              Center(
                child: Text(
                  'Hesap Oluştur',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: _PhoneSizes.headerTitleSize.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: _PhoneSizes.headerSubtitleSpacing.h),
              Center(
                child: Text(
                  'UniTV\'ye ücretsiz katılın',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: _PhoneSizes.headerSubtitleSize.sp,
                  ),
                ),
              ),
              SizedBox(height: _PhoneSizes.headerSpacing.h),
              Container(
                padding: EdgeInsets.all(_PhoneSizes.cardPadding.w),
                decoration: BoxDecoration(
                  color: AppTheme.card(context),
                  borderRadius: BorderRadius.circular(
                    _PhoneSizes.cardBorderRadius.r,
                  ),
                  border: Border.all(
                    color: AppTheme.isDark(context)
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: _PhoneSizes.fieldFontSize.sp,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Kullanıcı adı gerekli' : null,
                      decoration: _inputDecoration(
                        labelText: 'Kullanıcı Adı',
                        prefixIcon: Icons.person_outlined,
                      ),
                    ),
                    SizedBox(height: _PhoneSizes.fieldSpacing.h),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: _PhoneSizes.fieldFontSize.sp,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Email adresi gerekli' : null,
                      decoration: _inputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icons.email_outlined,
                      ),
                    ),
                    SizedBox(height: _PhoneSizes.fieldSpacing.h),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: _PhoneSizes.fieldFontSize.sp,
                      ),
                      validator: (value) => value!.length < 6
                          ? 'Şifre en az 6 karakter olmalı'
                          : null,
                      decoration: _inputDecoration(
                        labelText: 'Şifre',
                        prefixIcon: Icons.lock_outlined,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppTheme.textSec(context),
                            size: _PhoneSizes.fieldIconSize.sp,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: _PhoneSizes.fieldSpacing.h),
              Obx(
                () => controller.errorMessage.isNotEmpty
                    ? Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(_PhoneSizes.errorPadding.w),
                        margin: EdgeInsets.only(
                          bottom: _PhoneSizes.errorBottomMargin.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            _PhoneSizes.errorBorderRadius.r,
                          ),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: Colors.red.shade400,
                              size: _PhoneSizes.errorIconSize.sp,
                            ),
                            SizedBox(width: _PhoneSizes.errorSpacing.w),
                            Expanded(
                              child: Text(
                                controller.errorMessage.value,
                                style: TextStyle(
                                  color: Colors.red.shade400,
                                  fontSize: _PhoneSizes.errorFontSize.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Obx(
                () => DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: controller.isLoading.value
                        ? null
                        : const LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.secondaryColor,
                            ],
                          ),
                    borderRadius: BorderRadius.circular(
                      _PhoneSizes.buttonBorderRadius.r,
                    ),
                    boxShadow: controller.isLoading.value
                        ? []
                        : [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: _PhoneSizes.buttonShadowBlur.r,
                              offset: Offset(
                                0,
                                _PhoneSizes.buttonShadowOffsetY.h,
                              ),
                            ),
                          ],
                  ),
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              controller.signUp(
                                email: _emailController.text,
                                password: _passwordController.text,
                                username: _usernameController.text,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.isLoading.value
                          ? AppTheme.surface(context)
                          : Colors.transparent,
                      shadowColor: Colors.transparent,
                      disabledBackgroundColor: AppTheme.surface(context),
                      minimumSize: Size(
                        double.infinity,
                        _PhoneSizes.buttonHeight.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          _PhoneSizes.buttonBorderRadius.r,
                        ),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? SizedBox(
                            width: _PhoneSizes.loadingIndicatorSize.w,
                            height: _PhoneSizes.loadingIndicatorSize.w,
                            child: CircularProgressIndicator(
                              color: AppTheme.textSec(context),
                              strokeWidth: _PhoneSizes.loadingStrokeWidth.w,
                            ),
                          )
                        : Text(
                            'Kayıt Ol',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: _PhoneSizes.buttonFontSize.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: _PhoneSizes.headerSpacing.h),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        backgroundColor: AppTheme.bg(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPri(context),
            size: _TabletSizes.backIconSize,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text('Kayıt Ol'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: _TabletSizes.mainPaddingHorizontal,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: _TabletSizes.topSpacing),
                  Center(
                    child: Container(
                      width: _TabletSizes.headerIconSize,
                      height: _TabletSizes.headerIconSize,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.secondaryColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(
                          _TabletSizes.headerIconBorderRadius,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: _TabletSizes.headerShadowBlur,
                            offset: Offset(0, _TabletSizes.headerShadowOffsetY),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person_add_rounded,
                        color: Colors.white,
                        size: _TabletSizes.headerIconInnerSize,
                      ),
                    ),
                  ),
                  SizedBox(height: _TabletSizes.headerSpacing),
                  Center(
                    child: Text(
                      'Hesap Oluştur',
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: _TabletSizes.headerTitleSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: _TabletSizes.headerSubtitleSpacing),
                  Center(
                    child: Text(
                      'ÇOMÜ TV\'ye ücretsiz katılın',
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: _TabletSizes.headerSubtitleSize,
                      ),
                    ),
                  ),
                  SizedBox(height: _TabletSizes.headerSpacing),
                  Container(
                    padding: EdgeInsets.all(_TabletSizes.cardPadding),
                    decoration: BoxDecoration(
                      color: AppTheme.card(context),
                      borderRadius: BorderRadius.circular(
                        _TabletSizes.cardBorderRadius,
                      ),
                      border: Border.all(
                        color: AppTheme.isDark(context)
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          style: TextStyle(
                            color: AppTheme.textPri(context),
                            fontSize: _TabletSizes.fieldFontSize,
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Kullanıcı adı gerekli' : null,
                          decoration: _inputDecoration(
                            labelText: 'Kullanıcı Adı',
                            prefixIcon: Icons.person_outlined,
                          ),
                        ),
                        SizedBox(height: _TabletSizes.fieldSpacing),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                            color: AppTheme.textPri(context),
                            fontSize: _TabletSizes.fieldFontSize,
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Email adresi gerekli' : null,
                          decoration: _inputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icons.email_outlined,
                          ),
                        ),
                        SizedBox(height: _TabletSizes.fieldSpacing),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: TextStyle(
                            color: AppTheme.textPri(context),
                            fontSize: _TabletSizes.fieldFontSize,
                          ),
                          validator: (value) => value!.length < 6
                              ? 'Şifre en az 6 karakter olmalı'
                              : null,
                          decoration: _inputDecoration(
                            labelText: 'Şifre',
                            prefixIcon: Icons.lock_outlined,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppTheme.textSec(context),
                                size: _TabletSizes.fieldIconSize,
                              ),
                              onPressed: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: _TabletSizes.fieldSpacing),
                  Obx(
                    () => controller.errorMessage.isNotEmpty
                        ? Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(_TabletSizes.errorPadding),
                            margin: EdgeInsets.only(
                              bottom: _TabletSizes.errorBottomMargin,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                _TabletSizes.errorBorderRadius,
                              ),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  color: Colors.red.shade400,
                                  size: _TabletSizes.errorIconSize,
                                ),
                                SizedBox(width: _TabletSizes.errorSpacing),
                                Expanded(
                                  child: Text(
                                    controller.errorMessage.value,
                                    style: TextStyle(
                                      color: Colors.red.shade400,
                                      fontSize: _TabletSizes.errorFontSize,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Obx(
                    () => DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: controller.isLoading.value
                            ? null
                            : const LinearGradient(
                                colors: [
                                  AppTheme.primaryColor,
                                  AppTheme.secondaryColor,
                                ],
                              ),
                        borderRadius: BorderRadius.circular(
                          _TabletSizes.buttonBorderRadius,
                        ),
                        boxShadow: controller.isLoading.value
                            ? []
                            : [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: _TabletSizes.buttonShadowBlur,
                                  offset: Offset(
                                    0,
                                    _TabletSizes.buttonShadowOffsetY,
                                  ),
                                ),
                              ],
                      ),
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  controller.signUp(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    username: _usernameController.text,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.isLoading.value
                              ? AppTheme.surface(context)
                              : Colors.transparent,
                          shadowColor: Colors.transparent,
                          disabledBackgroundColor: AppTheme.surface(context),
                          minimumSize: Size(
                            double.infinity,
                            _TabletSizes.buttonHeight,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              _TabletSizes.buttonBorderRadius,
                            ),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? SizedBox(
                                width: _TabletSizes.loadingIndicatorSize,
                                height: _TabletSizes.loadingIndicatorSize,
                                child: CircularProgressIndicator(
                                  color: AppTheme.textSec(context),
                                  strokeWidth: _TabletSizes.loadingStrokeWidth,
                                ),
                              )
                            : Text(
                                'Kayıt Ol',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: _TabletSizes.buttonFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: _TabletSizes.headerSpacing),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
