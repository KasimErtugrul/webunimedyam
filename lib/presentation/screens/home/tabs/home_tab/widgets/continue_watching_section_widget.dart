// lib/presentation/screens/home/tabs/home_tab/widgets/continue_watching_section_widget.dart
//
// Ana sayfada gösterilen "İzlemeye Devam Et" (yarım bırakılan videolar)
// yatay bölümü. Veri tamamen local'dir (WatchProgressRepository / Hive).

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../data/models/watch_progress_model.dart';
import 'continue_watching_card_widget.dart';

class ContinueWatchingSectionWidget extends StatelessWidget {
  final List<WatchProgressModel> items;

  const ContinueWatchingSectionWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
          child: Row(
            children: [
              Icon(
                Icons.history_rounded,
                size: 18.sp,
                color: AppTheme.primaryColor,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'İzlemeye Devam Et',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 190.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ContinueWatchingCardWidget(progress: items[index]);
            },
          ),
        ),
      ],
    );
  }
}
