// lib/presentation/screens/followed_universities_list/followed_universities_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/models/university_model.dart';
import '../../controllers/followed_universities_list_controller.dart';

class FollowedUniversitiesListScreen extends StatelessWidget {
  const FollowedUniversitiesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FollowedUniversitiesListController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Takip Edilen Üniversiteler',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
              strokeWidth: 3.w,
            ),
          );
        }

        if (controller.universities.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_outlined,
                    color: AppTheme.textSec(context),
                    size: 56.sp,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    controller.isOwnProfile
                        ? 'Henüz üniversite takip etmedin'
                        : 'Takip edilen üniversite bulunamadı',
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    controller.isOwnProfile
                        ? 'Takip ettiğin üniversiteler burada görünür'
                        : 'Bu kullanıcının takip listesi gizli olabilir',
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: 13.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: controller.load,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            itemCount: controller.universities.length,
            itemBuilder: (context, index) =>
                _UniversityCard(university: controller.universities[index]),
          ),
        );
      }),
    );
  }
}

class _UniversityCard extends StatelessWidget {
  final UniversityModel university;
  const _UniversityCard({required this.university});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.universityDetail, arguments: university),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: university.logoUrl != null
                  ? Image.network(
                      university.logoUrl!,
                      width: 52.w,
                      height: 52.h,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _logoPlaceholder(context),
                    )
                  : _logoPlaceholder(context),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    university.name ?? '',
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (university.city != null) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 13.sp,
                          color: AppTheme.textSec(context),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          university.city!,
                          style: TextStyle(
                            color: AppTheme.textSec(context),
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSec(context),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoPlaceholder(BuildContext context) {
    return Container(
      width: 52.w,
      height: 52.h,
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        Icons.account_balance_rounded,
        color: AppTheme.textSec(context),
        size: 28.sp,
      ),
    );
  }
}
