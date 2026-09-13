// lib/presentation/screens/home/widgets/tabs/home_tab/widgets/university_sections_config.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../core/utils/formatters.dart';
import '../../../../../../data/models/university_stats_model.dart';
import '../../../../../../data/repositories/university_stats_repository.dart';
import '../widgets/horizontal_section.dart';
import 'university_horizontal_card_widget.dart';

export '../../../../../../data/repositories/university_stats_repository.dart'
    show UniversityStatsSectionType;

class UniSectionConfig {
  final String title;
  final UniversityStatsSectionType type;
  final String? Function(UniversityStatsModel) imageUrlBuilder;
  final String Function(UniversityStatsModel) statLabelBuilder;
  final IconData statIcon;
  final bool showLogoLarge;
  final String description;

  const UniSectionConfig({
    required this.title,
    required this.type,
    required this.imageUrlBuilder,
    required this.statLabelBuilder,
    required this.statIcon,
    required this.description,
    this.showLogoLarge = false,
  });
}

final List<UniSectionConfig> uniSectionConfigs = [
  UniSectionConfig(
    title: '📺 En Çok İzlenen',
    type: UniversityStatsSectionType.mostWatched,
    imageUrlBuilder: (s) => s.mostViewedThumbnail,
    statLabelBuilder: (s) => '${s.totalYtViews.compact} izlenme',
    statIcon: Icons.play_circle_outline_rounded,
    description:
        'YouTube\'daki tüm videolarının toplam izlenme sayısına göre '
        'sıralanan kanallar. En fazla izlenen içeriklere sahip '
        'üniversiteler bu listede üstte yer alır.',
  ),
  UniSectionConfig(
    title: '👍 En Çok Beğenilen',
    type: UniversityStatsSectionType.mostLiked,
    imageUrlBuilder: (s) => s.mostViewedThumbnail,
    statLabelBuilder: (s) => '${s.totalYtLikes.compact} beğeni',
    statIcon: Icons.thumb_up_outlined,
    description:
        'YouTube\'daki videolarının toplam beğeni sayısına göre '
        'sıralanan kanallar. İzleyicilerin en çok beğeni bıraktığı '
        'içeriklere sahip üniversiteler üstte görünür.',
  ),
  UniSectionConfig(
    title: '🔥 Uygulamada Popüler',
    type: UniversityStatsSectionType.popularInApp,
    imageUrlBuilder: (s) => s.appTopVideoThumbnail,
    statLabelBuilder: (s) => '${s.appTotalViews.compact} izl.',
    statIcon: Icons.trending_up_rounded,
    description:
        'Bu uygulama içinde en fazla izlenme alan kanallar. '
        'Kullanıcıların uygulama üzerinden izlediği videolara '
        'göre hesaplanır; YouTube istatistiklerinden bağımsızdır.',
  ),
  UniSectionConfig(
    title: '⭐ En Çok Favorilenen',
    type: UniversityStatsSectionType.mostFavorited,
    imageUrlBuilder: (s) => s.appTopVideoThumbnail,
    statLabelBuilder: (s) => '${s.appTotalFavorites.compact} favori',
    statIcon: Icons.star_outline_rounded,
    description:
        'Kullanıcıların en fazla favorilere eklediği kanallar. '
        'Favori sayısı, bu kanala ait videoların uygulama içinde '
        'kaç kez favorilere eklendiğinin toplamından oluşur.',
  ),
  UniSectionConfig(
    title: '📅 Son 30 Günde Aktif',
    type: UniversityStatsSectionType.activeLast30,
    imageUrlBuilder: (s) => s.latestVideoThumbnail,
    statLabelBuilder: (s) => '${s.videosLast30Days} video',
    statIcon: Icons.calendar_today_outlined,
    description:
        'Son 30 gün içinde en fazla yeni video yayınlayan kanallar. '
        'Güncel ve aktif içerik üreten üniversiteleri keşfetmek için '
        'idealdir. Sıralama, son 30 gündeki video sayısına göre yapılır.',
  ),
  UniSectionConfig(
    title: '🏆 En Büyük Kanallar',
    type: UniversityStatsSectionType.biggestChannels,
    imageUrlBuilder: (s) => s.logoUrl,
    statLabelBuilder: (s) => '${s.subscriberCount.compact} abone',
    statIcon: Icons.people_outline_rounded,
    showLogoLarge: true,
    description:
        'YouTube\'daki abone sayısına göre sıralanan en büyük '
        'üniversite kanalları. En geniş izleyici kitlesine sahip '
        'kanalları bu listede bulabilirsin.',
  ),
  UniSectionConfig(
    title: '🗄️ En Zengin Arşiv',
    type: UniversityStatsSectionType.richestArchive,
    imageUrlBuilder: (s) => s.mostViewedThumbnail,
    statLabelBuilder: (s) => formatDurationShort(s.totalDurationSec),
    statIcon: Icons.access_time_rounded,
    description:
        'Toplam video süresi en uzun olan kanallar. Saatlerce, hatta '
        'günlerce izlenebilecek içeriklere sahip üniversiteler '
        'bu listede yer alır. Sıralama, tüm videoların toplam '
        'süresine göre yapılır.',
  ),
  UniSectionConfig(
    title: '✨ Yeni Keşfedilen',
    type: UniversityStatsSectionType.newlyDiscovered,
    imageUrlBuilder: (s) => s.latestVideoThumbnail,
    statLabelBuilder: (s) => '${s.appTotalViewers.compact} izleyici',
    statIcon: Icons.explore_outlined,
    description:
        'Uygulamada henüz az tanınan, yeni keşfedilen kanallar. '
        'Az sayıda izleyiciye sahip olmakla birlikte kaliteli '
        'içerik üreten üniversiteleri öne çıkarır. '
        'Gizli kalmış kanalları ilk sen keşfet!',
  ),
];

// ─── Build helper ────────────────────────────────────────────────────────────

List<Widget> buildUniversitySections({
  required List<UniSectionConfig> configs,
  required List<List<UniversityStatsModel>> allItems,
  required bool isLoading,
}) {
  return [
    for (var i = 0; i < configs.length; i++)
      Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: HorizontalSection<UniversityStatsModel>(
          title: configs[i].title,
          description: configs[i].description,
          items: allItems[i],
          isLoading: isLoading,
          animationIndex: i,
          onSeeAll: () => Get.toNamed(
            AppRoutes.universityStatsSectionDetail,
            arguments: {
              'type': configs[i].type,
              'title': configs[i].title,
              'initialItems': allItems[i],
            },
          ),
          itemBuilder: (ctx, s) => UniversityHorizontalCard(
            stats: s,
            imageUrl: configs[i].imageUrlBuilder(s),
            statLabel: configs[i].statLabelBuilder(s),
            statIcon: configs[i].statIcon,
            showLogoLarge: configs[i].showLogoLarge,
          ),
        ),
      ),
  ];
}