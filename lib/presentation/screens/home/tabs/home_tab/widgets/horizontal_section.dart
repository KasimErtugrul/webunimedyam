// lib/presentation/screens/home/widgets/tabs/home_tab/widgets/horizontal_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../discovery_tab/discover_layout_spec.dart';

/// Tüm "horizontal section" yapıları için ortak renderer.
/// Video ve üniversite section'ları birebir aynı görsel dili kullandığı
/// için tek generic widget'a indirildi.
class HorizontalSection<T> extends StatelessWidget {
  final String title;
  final String description;
  final List<T> items;
  final bool isLoading;
  final VoidCallback? onSeeAll;
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// Animasyon gecikmesi — her section biraz daha geç gelsin.
  final int animationIndex;

  const HorizontalSection({
    super.key,
    required this.title,
    required this.description,
    required this.items,
    required this.isLoading,
    required this.itemBuilder,
    this.onSeeAll,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final spec = DiscoverLayoutSpec.of(context);

    if (!isLoading && items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          spec: spec,
          title: title,
          description: description,
          onSeeAll: onSeeAll,
          animationIndex: animationIndex,
        ),
        SizedBox(
          height: spec.sectionListViewHeight.h,
          child: isLoading
              ? _SkeletonList(spec: spec)
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: spec.sectionListPaddingH.w,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => SizedBox(
                    width: spec.sectionCardSpacing.w,
                  ),
                  itemBuilder: (ctx, i) {
                    return itemBuilder(ctx, items[i])
                        .animate(delay: (i * 40).ms)
                        .fadeIn(duration: 300.ms)
                        .slideX(
                          begin: 0.08,
                          end: 0,
                          duration: 350.ms,
                          curve: Curves.easeOut,
                        );
                  },
                ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final DiscoverLayoutSpec spec;
  final String title;
  final String description;
  final VoidCallback? onSeeAll;
  final int animationIndex;

  const _SectionHeader({
    required this.spec,
    required this.title,
    required this.description,
    required this.onSeeAll,
    required this.animationIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        spec.sectionTitlePaddingLeft.w,
        0,
        8.w,
        spec.sectionTitlePaddingBottom.h,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: spec.sectionTitleFontSize.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _showInfoDialog(context),
            icon: Icon(
              Icons.info_outline_rounded,
              size: spec.sectionInfoIconSize.sp,
              color: AppTheme.textSec(context).withValues(alpha: 0.7),
            ),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
            constraints: const BoxConstraints(),
            splashRadius: spec.sectionInfoIconSplash,
            tooltip: 'Bu liste hakkında',
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: AppTheme.primaryColor,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tümü',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: spec.sectionViewAllFontSize.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: spec.sectionViewAllFontSize.sp + 4,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
        ],
      ),
    ).animate(delay: (animationIndex * 80).ms).fadeIn(duration: 300.ms);
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(spec.dialogRadius.r),
        ),
        icon: Icon(
          Icons.info_outline_rounded,
          color: AppTheme.primaryColor,
          size: 28.sp,
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: spec.dialogTitleFontSize.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPri(context),
          ),
        ),
        content: Text(
          description,
          style: TextStyle(
            fontSize: spec.dialogContentFontSize.sp,
            color: AppTheme.textSec(context),
            height: spec.dialogContentLineHeight,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: Size(120.w, 44.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: const Text('Anladım'),
          ),
        ],
      ),
    );
  }
}

class _SkeletonList extends StatelessWidget {
  final DiscoverLayoutSpec spec;
  const _SkeletonList({required this.spec});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: spec.sectionListPaddingH.w),
        itemCount: spec.shimmerItemCount,
        separatorBuilder: (_, _) => SizedBox(
          width: spec.sectionCardSpacing.w,
        ),
        itemBuilder: (_, _) => Container(
          width: spec.shimmerCardWidth.w,
          decoration: BoxDecoration(
            color: AppTheme.surface(context),
            borderRadius: BorderRadius.circular(spec.shimmerCardRadius.r),
          ),
        ),
      ),
    );
  }
}