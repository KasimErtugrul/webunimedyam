// lib/presentation/screens/home/widgets/tabs/home_tab/widgets/university_sections_config.dart
//
// 8 liste için merkezi config: başlık, imageUrlBuilder, statLabelBuilder, ikon.
// home_tab_widget.dart içinden import edilir.

import 'package:flutter/material.dart';

import '../../../../../../data/models/university_stats_model.dart';
import 'university_horizontal_card_widget.dart';
import 'university_horizontal_section_widget.dart';

class UniSectionConfig {
  final String title;
  final String? Function(UniversityStatsModel) imageUrlBuilder;
  final String Function(UniversityStatsModel) statLabelBuilder;
  final IconData statIcon;
  final bool showLogoLarge;

  const UniSectionConfig({
    required this.title,
    required this.imageUrlBuilder,
    required this.statLabelBuilder,
    required this.statIcon,
    this.showLogoLarge = false,
  });
}

final List<UniSectionConfig> uniSectionConfigs = [
  // 1. En Çok İzlenen
  UniSectionConfig(
    title: '📺 En Çok İzlenen',
    imageUrlBuilder: (s) => s.mostViewedThumbnail,
    statLabelBuilder: (s) => '${formatStatNumber(s.totalYtViews)} izlenme',
    statIcon: Icons.play_circle_outline_rounded,
  ),
  // 2. En Çok Beğenilen
  UniSectionConfig(
    title: '👍 En Çok Beğenilen',
    imageUrlBuilder: (s) => s.mostViewedThumbnail,
    statLabelBuilder: (s) => '${formatStatNumber(s.totalYtLikes)} beğeni',
    statIcon: Icons.thumb_up_outlined,
  ),
  // 3. Uygulamada Popüler
  UniSectionConfig(
    title: '🔥 Uygulamada Popüler',
    imageUrlBuilder: (s) => s.appTopVideoThumbnail,
    statLabelBuilder: (s) => '${formatStatNumber(s.appTotalViews)} izl.',
    statIcon: Icons.trending_up_rounded,
  ),
  // 4. En Çok Favorilenen
  UniSectionConfig(
    title: '⭐ En Çok Favorilenen',
    imageUrlBuilder: (s) => s.appTopVideoThumbnail,
    statLabelBuilder: (s) => '${formatStatNumber(s.appTotalFavorites)} favori',
    statIcon: Icons.star_outline_rounded,
  ),
  // 5. Son 30 Günde Aktif
  UniSectionConfig(
    title: '📅 Son 30 Günde Aktif',
    imageUrlBuilder: (s) => s.latestVideoThumbnail,
    statLabelBuilder: (s) => '${s.videosLast30Days} video',
    statIcon: Icons.calendar_today_outlined,
  ),
  // 6. En Büyük Kanallar
  UniSectionConfig(
    title: '🏆 En Büyük Kanallar',
    imageUrlBuilder: (s) => s.logoUrl,
    statLabelBuilder: (s) => '${formatStatNumber(s.subscriberCount)} abone',
    statIcon: Icons.people_outline_rounded,
    showLogoLarge: true,
  ),
  // 7. En Zengin Arşiv
  UniSectionConfig(
    title: '🗄️ En Zengin Arşiv',
    imageUrlBuilder: (s) => s.mostViewedThumbnail,
    statLabelBuilder: (s) => formatDuration(s.totalDurationSec),
    statIcon: Icons.access_time_rounded,
  ),
  // 8. Yeni Keşfedilen
  UniSectionConfig(
    title: '✨ Yeni Keşfedilen',
    imageUrlBuilder: (s) => s.latestVideoThumbnail,
    statLabelBuilder: (s) => '${formatStatNumber(s.appTotalViewers)} izleyici',
    statIcon: Icons.explore_outlined,
  ),
];

/// Controller'daki 8 RxList ile config'i eşleştirir.
/// Her eleman: (config, items, isLoading)
List<_SectionBundle> buildSectionBundles({
  required List<UniSectionConfig> configs,
  required List<List<UniversityStatsModel>> allItems,
  required bool isLoading,
}) {
  return List.generate(
    configs.length,
    (i) => _SectionBundle(
      config: configs[i],
      items: allItems[i],
      isLoading: isLoading,
    ),
  );
}

class _SectionBundle {
  final UniSectionConfig config;
  final List<UniversityStatsModel> items;
  final bool isLoading;
  const _SectionBundle({
    required this.config,
    required this.items,
    required this.isLoading,
  });
}

/// home_tab_widget.dart'ta çağrılacak helper — 8 seksiyon widget listesi döner.
List<Widget> buildUniversitySections({
  required List<UniSectionConfig> configs,
  required List<List<UniversityStatsModel>> allItems,
  required bool isLoading,
}) {
  final widgets = <Widget>[];
  for (var i = 0; i < configs.length; i++) {
    final cfg = configs[i];
    widgets.add(
      UniversityHorizontalSection(
        title: cfg.title,
        items: allItems[i],
        isLoading: isLoading,
        imageUrlBuilder: cfg.imageUrlBuilder,
        statLabelBuilder: cfg.statLabelBuilder,
        statIcon: cfg.statIcon,
        showLogoLarge: cfg.showLogoLarge,
      ),
    );
    widgets.add(SizedBox(height: 24));
  }
  return widgets;
}