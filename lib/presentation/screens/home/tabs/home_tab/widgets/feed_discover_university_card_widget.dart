/* // lib/presentation/screens/home/tabs/home_tab/widgets/feed_discover_university_card_widget.dart
//
// "KEŞFET" KARTI — ana video akışına (Son Videolar) serpiştirilen,
// henüz takip edilmeyen bir üniversiteyi tanıtan yatay kart.
//
// PERFORMANS NOTU: Bu widget hiçbir yeni Supabase sorgusu yapmaz.
// `controller.universities` zaten `loadUniversitiesAndPlaylists()` ile
// bir kere yüklenmiş durumda (ana feed'in videolarıyla aynı anda çekiliyor).
// Bu kart sadece o listeden, henüz favoriteUniversityIds içinde olmayan
// bir üniversiteyi seçip gösteriyor — network maliyeti sıfır.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../data/models/university_model.dart';
import '../../../../../controllers/home_controller.dart';

class FeedDiscoverUniversityCardWidget extends StatelessWidget {
  final UniversityModel university;

  const FeedDiscoverUniversityCardWidget({
    super.key,
    required this.university,
  });

  void _follow(HomeController controller) {
    controller.toggleUniversityFavorite(university);
  }

  void _openDetail() {
    Get.toNamed(AppRoutes.universityDetail, arguments: university);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return GestureDetector(
      onTap: _openDetail,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.10),
              AppTheme.primaryColor.withOpacity(0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.18),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: university.logoUrl != null && university.logoUrl!.isNotEmpty
                  ? Image.network(
                      university.logoUrl!,
                      width: 52.w,
                      height: 52.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackLogo(),
                    )
                  : _fallbackLogo(),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.explore_outlined,
                        size: 14.sp,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'KEŞFET',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    university.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if ((university.city ?? '').isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      '${university.city} · ${university.videoCount ?? 0} video',
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            OutlinedButton(
              onPressed: () => _follow(controller),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: BorderSide(color: AppTheme.primaryColor),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Takip Et',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackLogo() {
    return Container(
      width: 52.w,
      height: 52.w,
      color: AppTheme.primaryColor.withOpacity(0.12),
      alignment: Alignment.center,
      child: Icon(
        Icons.school_outlined,
        color: AppTheme.primaryColor,
        size: 24.sp,
      ),
    );
  }
} */