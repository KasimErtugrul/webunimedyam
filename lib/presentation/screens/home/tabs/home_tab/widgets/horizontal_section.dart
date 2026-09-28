// lib/presentation/screens/home/widgets/tabs/home_tab/widgets/horizontal_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
          height: spec.sectionListViewHeight,
          child: isLoading
              ? _SkeletonList(spec: spec)
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: spec.sectionListPaddingH,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => SizedBox(
                    width: spec.sectionCardSpacing,
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
        spec.sectionTitlePaddingLeft,
        0,
        8,
        spec.sectionTitlePaddingBottom,
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
                fontSize: spec.sectionTitleFontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _showInfoDialog(context),
            icon: Icon(
              Icons.info_outline_rounded,
              size: spec.sectionInfoIconSize,
              color: AppTheme.textSec(context).withValues(alpha: 0.7),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            constraints: const BoxConstraints(),
            splashRadius: spec.sectionInfoIconSplash,
            tooltip: 'Bu liste hakkında',
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      fontSize: spec.sectionViewAllFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: spec.sectionViewAllFontSize + 4,
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
          borderRadius: BorderRadius.circular(spec.dialogRadius),
        ),
        icon: const Icon(
          Icons.info_outline_rounded,
          color: AppTheme.primaryColor,
          size: 28,
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: spec.dialogTitleFontSize,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPri(context),
          ),
        ),
        content: Text(
          description,
          style: TextStyle(
            fontSize: spec.dialogContentFontSize,
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
              minimumSize: const Size(120, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
        padding: EdgeInsets.symmetric(horizontal: spec.sectionListPaddingH),
        itemCount: spec.shimmerItemCount,
        separatorBuilder: (_, _) => SizedBox(
          width: spec.sectionCardSpacing,
        ),
        itemBuilder: (_, _) => Container(
          width: spec.shimmerCardWidth,
          decoration: BoxDecoration(
            color: AppTheme.surface(context),
            borderRadius: BorderRadius.circular(spec.shimmerCardRadius),
          ),
        ),
      ),
    );
  }
}