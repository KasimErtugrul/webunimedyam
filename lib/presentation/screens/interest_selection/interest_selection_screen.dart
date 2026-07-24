// lib/presentation/screens/interest_selection/interest_selection_screen.dart
//
// Yeni kayıt olan kullanıcıya, OTP doğrulamasından hemen sonra gösterilen
// "ilgilendiğin üniversiteleri seç" ekranı. Zorunlu değildir, sınırsız
// sayıda üniversite seçilebilir, "Atla" ile geçilebilir.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../controllers/interest_selection_controller.dart';

class InterestSelectionScreen extends StatelessWidget {
  const InterestSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InterestSelectionController>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            _Header(controller: controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.errorMessage.value.isNotEmpty) {
                  return _ErrorState(controller: controller);
                }
                final list = controller.filteredUniversities;
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      'Sonuç bulunamadı',
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: 14.sp,
                      ),
                    ),
                  );
                }
                return GridView.builder(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 12.w,
                    childAspectRatio: 2.6,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final uni = list[index];
                    return Obx(() {
                      final selected = uni.id != null &&
                          controller.isSelected(uni.id!);
                      return _UniversityChip(
                        name: uni.name ?? '',
                        logoUrl: uni.logoUrl,
                        selected: selected,
                        onTap: uni.id == null
                            ? null
                            : () => controller.toggleUniversity(uni.id!),
                      );
                    });
                  },
                );
              }),
            ),
            _BottomBar(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final InterestSelectionController controller;
  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'İlgilendiğin üniversiteleri seç',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: controller.skip,
                child: Text(
                  'Atla',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            'Seni biraz tanıyalım. İstediğin kadar üniversite seçebilir, '
            'hiç seçmeden de devam edebilirsin. Bu bir zorunluluk değil.',
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: 13.sp,
              height: 1.4,
            ),
          ),
          SizedBox(height: 14.h),
          TextField(
            onChanged: controller.updateSearch,
            style: TextStyle(color: AppTheme.textPri(context), fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: 'Üniversite ara...',
              hintStyle: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: 14.sp,
              ),
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UniversityChip extends StatelessWidget {
  final String name;
  final String? logoUrl;
  final bool selected;
  final VoidCallback? onTap;

  const _UniversityChip({
    required this.name,
    required this.logoUrl,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected
              ? primary.withValues(alpha: 0.15)
              : AppTheme.textSec(context).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16.r,
              backgroundColor: AppTheme.textSec(context).withValues(alpha: 0.15),
              backgroundImage:
                  (logoUrl != null && logoUrl!.isNotEmpty)
                      ? NetworkImage(logoUrl!)
                      : null,
              child: (logoUrl == null || logoUrl!.isEmpty)
                  ? Icon(
                      Icons.school_rounded,
                      size: 16.sp,
                      color: AppTheme.textSec(context),
                    )
                  : null,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: 12.5.sp,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: primary, size: 18.sp),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final InterestSelectionController controller;
  const _BottomBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
      child: Obx(
        () => SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            onPressed:
                controller.isSaving.value ? null : controller.confirmAndContinue,
            child: controller.isSaving.value
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    controller.selectedCount > 0
                        ? 'Devam Et (${controller.selectedCount})'
                        : 'Devam Et',
                    style: TextStyle(fontSize: 16.sp),
                  ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final InterestSelectionController controller;
  const _ErrorState({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSec(context), fontSize: 14.sp),
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: controller.skip,
              child: const Text('Şimdilik geç'),
            ),
          ],
        ),
      ),
    );
  }
}