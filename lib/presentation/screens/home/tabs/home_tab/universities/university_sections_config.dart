// lib/presentation/screens/home/widgets/tabs/home_tab/widgets/university_sections_config.dart
//
// 8 liste için merkezi config: başlık, imageUrlBuilder, statLabelBuilder, ikon, açıklama.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../data/models/university_stats_model.dart';
import '../../../../../../data/repositories/university_stats_repository.dart';
import 'university_horizontal_section_widget.dart';

// UniversityStatsSectionType, university_stats_repository.dart'tan
// re-export edilir; VideoSectionType'ın video_sections_config.dart'taki
// export deseniyle aynı.
export '../../../../../../data/repositories/university_stats_repository.dart'
    show UniversityStatsSectionType;

// ═══════════════════════════════════════════════════════════
// SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  static const double sectionSpacing = 24;
}

// ═══════════════════════════════════════════════════════════
// CONFIG SINIFI
// ═══════════════════════════════════════════════════════════

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

// ═══════════════════════════════════════════════════════════
// FORMATLAMA FONKSİYONLARI
// ═══════════════════════════════════════════════════════════

String formatStatNumber(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}B';
  return n.toString();
}

String formatDuration(int totalSec) {
  final h = totalSec ~/ 3600;
  if (h >= 1000) return '${(h / 1000).toStringAsFixed(1)}k s';
  return '$h s';
}

// ═══════════════════════════════════════════════════════════
// CONFIG LİSTESİ
// ═══════════════════════════════════════════════════════════

final List<UniSectionConfig> uniSectionConfigs = [
  // 1. En Çok İzlenen
  UniSectionConfig(
    title: '📺 En Çok İzlenen',
    type: UniversityStatsSectionType.mostWatched,
    imageUrlBuilder: (s) => s.mostViewedThumbnail,
    statLabelBuilder: (s) => '${formatStatNumber(s.totalYtViews)} izlenme',
    statIcon: Icons.play_circle_outline_rounded,
    description:
        'YouTube\'daki tüm videolarının toplam izlenme sayısına göre '
        'sıralanan kanallar. En fazla izlenen içeriklere sahip '
        'üniversiteler bu listede üstte yer alır.',
  ),
  // 2. En Çok Beğenilen
  UniSectionConfig(
    title: '👍 En Çok Beğenilen',
    type: UniversityStatsSectionType.mostLiked,
    imageUrlBuilder: (s) => s.mostViewedThumbnail,
    statLabelBuilder: (s) => '${formatStatNumber(s.totalYtLikes)} beğeni',
    statIcon: Icons.thumb_up_outlined,
    description:
        'YouTube\'daki videolarının toplam beğeni sayısına göre '
        'sıralanan kanallar. İzleyicilerin en çok beğeni bıraktığı '
        'içeriklere sahip üniversiteler üstte görünür.',
  ),
  // 3. Uygulamada Popüler
  UniSectionConfig(
    title: '🔥 Uygulamada Popüler',
    type: UniversityStatsSectionType.popularInApp,
    imageUrlBuilder: (s) => s.appTopVideoThumbnail,
    statLabelBuilder: (s) => '${formatStatNumber(s.appTotalViews)} izl.',
    statIcon: Icons.trending_up_rounded,
    description:
        'Bu uygulama içinde en fazla izlenme alan kanallar. '
        'Kullanıcıların uygulama üzerinden izlediği videolara '
        'göre hesaplanır; YouTube istatistiklerinden bağımsızdır.',
  ),
  // 4. En Çok Favorilenen
  UniSectionConfig(
    title: '⭐ En Çok Favorilenen',
    type: UniversityStatsSectionType.mostFavorited,
    imageUrlBuilder: (s) => s.appTopVideoThumbnail,
    statLabelBuilder: (s) => '${formatStatNumber(s.appTotalFavorites)} favori',
    statIcon: Icons.star_outline_rounded,
    description:
        'Kullanıcıların en fazla favorilere eklediği kanallar. '
        'Favori sayısı, bu kanala ait videoların uygulama içinde '
        'kaç kez favorilere eklendiğinin toplamından oluşur.',
  ),
  // 5. Son 30 Günde Aktif
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
  // 6. En Büyük Kanallar
  UniSectionConfig(
    title: '🏆 En Büyük Kanallar',
    type: UniversityStatsSectionType.biggestChannels,
    imageUrlBuilder: (s) => s.logoUrl,
    statLabelBuilder: (s) => '${formatStatNumber(s.subscriberCount)} abone',
    statIcon: Icons.people_outline_rounded,
    showLogoLarge: true,
    description:
        'YouTube\'daki abone sayısına göre sıralanan en büyük '
        'üniversite kanalları. En geniş izleyici kitlesine sahip '
        'kanalları bu listede bulabilirsin.',
  ),
  // 7. En Zengin Arşiv
  UniSectionConfig(
    title: '🗄️ En Zengin Arşiv',
    type: UniversityStatsSectionType.richestArchive,
    imageUrlBuilder: (s) => s.mostViewedThumbnail,
    statLabelBuilder: (s) => formatDuration(s.totalDurationSec),
    statIcon: Icons.access_time_rounded,
    description:
        'Toplam video süresi en uzun olan kanallar. Saatlerce, hatta '
        'günlerce izlenebilecek içeriklere sahip üniversiteler '
        'bu listede yer alır. Sıralama, tüm videoların toplam '
        'süresine göre yapılır.',
  ),
  // 8. Yeni Keşfedilen
  UniSectionConfig(
    title: '✨ Yeni Keşfedilen',
    type: UniversityStatsSectionType.newlyDiscovered,
    imageUrlBuilder: (s) => s.latestVideoThumbnail,
    statLabelBuilder: (s) => '${formatStatNumber(s.appTotalViewers)} izleyici',
    statIcon: Icons.explore_outlined,
    description:
        'Uygulamada henüz az tanınan, yeni keşfedilen kanallar. '
        'Az sayıda izleyiciye sahip olmakla birlikte kaliteli '
        'içerik üreten üniversiteleri öne çıkarır. '
        'Gizli kalmış kanalları ilk sen keşfet!',
  ),
];

// ═══════════════════════════════════════════════════════════
// BUILD HELPER
// ═══════════════════════════════════════════════════════════

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
        description: cfg.description,
        items: allItems[i],
        isLoading: isLoading,
        imageUrlBuilder: cfg.imageUrlBuilder,
        statLabelBuilder: cfg.statLabelBuilder,
        statIcon: cfg.statIcon,
        showLogoLarge: cfg.showLogoLarge,
        // BUG FIX: onSeeAll hiç iletilmiyordu, bu yüzden widget'ın zaten
        // desteklediği "Tümünü Gör" butonu Kanal tab'ında hiç görünmüyordu.
        onSeeAll: () => Get.toNamed(
          AppRoutes.universityStatsSectionDetail,
          arguments: {
            'type': cfg.type,
            'title': cfg.title,
            'initialItems': allItems[i],
          },
        ),
      ),
    );
    widgets.add(SizedBox(height: _PhoneSizes.sectionSpacing));
  }
  return widgets;
}