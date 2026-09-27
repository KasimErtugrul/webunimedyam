// ─── "Bu Üniversitenin Diğer Shorts Videoları" Rafı ────────────────────────
//
// Model-agnostik (generic <T>): hem ShortsPlayerScreen (ShortsModel) hem de
// tek üniversite oynatıcısı (VideoModel) aynı rafı, kendi alanlarını
// extractor fonksiyonlarıyla vererek kullanır. İki ekran da BİREBİR aynı
// tasarımı paylaşır.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../utils/shorts_player_sizes.dart';

class ShortsPlayerRelatedShelf<T> extends StatelessWidget {
  final ShortsPlayerSizes sizes;
  final String universityName;
  final List<T> items;
  final String Function(T item) thumbnailOf;
  final String Function(T item) titleOf;
  final String Function(T item) durationOf;
  final ValueChanged<T> onSelect;

  const ShortsPlayerRelatedShelf({
    super.key,
    required this.sizes,
    required this.universityName,
    required this.items,
    required this.thumbnailOf,
    required this.titleOf,
    required this.durationOf,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.bolt_rounded, color: AppTheme.primaryColor, size: sizes.relatedTitleFontSize),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '$universityName\'nin Diğer Shorts Videoları',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: sizes.relatedTitleFontSize,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: sizes.sectionSpacing * 0.6),
        SizedBox(
          height: sizes.relatedItemWidth / sizes.relatedThumbAspectRatio + 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => SizedBox(width: sizes.relatedItemSpacing),
            itemBuilder: (context, index) {
              final item = items[index];
              return _RelatedCard(
                sizes: sizes,
                thumbnailUrl: thumbnailOf(item),
                title: titleOf(item),
                duration: durationOf(item),
                onTap: () => onSelect(item),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RelatedCard extends StatelessWidget {
  final ShortsPlayerSizes sizes;
  final String thumbnailUrl;
  final String title;
  final String duration;
  final VoidCallback onTap;

  const _RelatedCard({
    required this.sizes,
    required this.thumbnailUrl,
    required this.title,
    required this.duration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: sizes.relatedItemWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: sizes.relatedThumbAspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(sizes.relatedItemRadius),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const ColoredBox(color: Color(0xFF18202F)),
                      errorWidget: (_, _, _) => const ColoredBox(
                        color: Color(0xFF18202F),
                        child: Icon(Icons.play_circle_outline_rounded, color: Colors.white38),
                      ),
                    ),
                    if (duration.isNotEmpty)
                      Positioned(
                        right: 6,
                        bottom: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            duration,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: sizes.relatedDurationFontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.5)],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title.isNotEmpty ? title : 'Shorts',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: sizes.relatedCardTitleFontSize,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
