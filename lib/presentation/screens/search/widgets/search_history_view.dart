// lib/presentation/screens/search/widgets/search_history_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../controllers/video_search_controller.dart';
import '../search_layout_spec.dart';

class SearchHistoryView extends StatelessWidget {
  final SearchLayoutSpec spec;
  final VideoSearchController controller;
  final void Function(String) onTap;

  const SearchHistoryView({
    super.key,
    required this.spec,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final history = controller.history;

      if (history.isEmpty) {
        return _EmptyHistory(spec: spec);
      }

      return ListView(
        padding: EdgeInsets.symmetric(horizontal: spec.sectionH.w),
        children: [
          SizedBox(height: spec.sectionTopPadding.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Son Aramalar',
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: spec.sectionTitleFontSize.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: controller.clearHistory,
                child: Text(
                  'Temizle',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: spec.sectionTitleFontSize.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spec.sectionTitleSpacing.h),
          Wrap(
            spacing: spec.chipSpacing.w,
            runSpacing: spec.chipRunSpacing.h,
            children: [
              for (int i = 0; i < history.length; i++)
                _HistoryChip(
                  text: history[i],
                  spec: spec,
                  onTap: () => onTap(history[i]),
                  onRemove: () => controller.removeHistory(history[i]),
                )
                    .animate(delay: (i * 40).ms)
                    .fadeIn(duration: 250.ms)
                    .slideY(begin: 0.15, end: 0, curve: Curves.easeOut),
            ],
          ),
        ],
      );
    });
  }
}

class _HistoryChip extends StatelessWidget {
  final String text;
  final SearchLayoutSpec spec;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _HistoryChip({
    required this.text,
    required this.spec,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.card(context),
      borderRadius: BorderRadius.circular(spec.chipRadius.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(spec.chipRadius.r),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spec.chipPaddingH.w,
            vertical: spec.chipPaddingV.h,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history_rounded,
                size: (spec.chipFontSize + 1).sp,
                color: AppTheme.textSec(context),
              ),
              SizedBox(width: 6.w),
              Text(
                text,
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: spec.chipFontSize.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 6.w),
              GestureDetector(
                onTap: onRemove,
                behavior: HitTestBehavior.opaque,
                child: Icon(
                  Icons.close_rounded,
                  size: (spec.chipFontSize - 1).sp,
                  color: AppTheme.textSec(context).withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  final SearchLayoutSpec spec;
  const _EmptyHistory({required this.spec});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(spec.sectionH.w * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.travel_explore_rounded,
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.4),
              size: spec.emptyIconSize.sp,
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scaleXY(begin: 0.7, end: 1, curve: Curves.easeOutBack),
            SizedBox(height: spec.emptySpacing.h),
            Text(
              'Aramaya başla',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: spec.emptyTitleFontSize.sp,
                fontWeight: FontWeight.w700,
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
            SizedBox(height: (spec.emptySpacing / 2).h),
            Text(
              'İzlemek istediğin videoyu, üniversiteyi veya kanalı ara.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: spec.emptySubtitleFontSize.sp,
                height: 1.4,
              ),
            ).animate().fadeIn(delay: 180.ms, duration: 300.ms),
          ],
        ),
      ),
    );
  }
}