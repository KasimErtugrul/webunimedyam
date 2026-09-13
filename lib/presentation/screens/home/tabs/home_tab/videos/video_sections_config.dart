// lib/presentation/screens/home/widgets/tabs/home_tab/videos/video_sections_config.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../core/utils/formatters.dart';
import '../../../../../../data/models/video_engagement_model.dart';
import '../../../../../../data/repositories/video_repository.dart';
import '../widgets/horizontal_section.dart';
import 'video_horizontal_card_widget.dart';

export '../../../../../../data/repositories/video_repository.dart'
    show VideoSectionType;

class VideoSectionConfig {
  final String title;
  final VideoSectionType type;
  final String Function(VideoEngagementModel) statLabelBuilder;
  final IconData statIcon;
  final String description;

  const VideoSectionConfig({
    required this.title,
    required this.type,
    required this.statLabelBuilder,
    required this.statIcon,
    required this.description,
  });
}

// ─── 6 Seksiyon Konfigürasyonu ───────────────────────────────────────────────

final List<VideoSectionConfig> videoSectionConfigs = [
  VideoSectionConfig(
    title: '🔥 Trend Videolar',
    type: VideoSectionType.trending,
    statLabelBuilder: (v) => '${v.engagementScore} etkileşim puanı',
    statIcon: Icons.trending_up_rounded,
    description:
        'Bu videolar; izlenme, beğeni, favori, paylaşım ve yorum '
        'sayıları toplanarak sıralanır (her biri farklı ağırlıkta '
        'sayılır — örneğin bir yorum, bir izlenmeden daha değerlidir). '
        '"Etkileşim puanı" bu toplamı ifade eder; kullanıcının kendi '
        'puanı ya da rütbesiyle ilgisi yoktur, yalnızca videonun ne '
        'kadar ilgi gördüğünü gösterir.',
  ),
  VideoSectionConfig(
    title: '👁️ En Çok İzlenenler',
    type: VideoSectionType.mostWatched,
    statLabelBuilder: (v) => '${v.ytViewCount.compact} izlenme',
    statIcon: Icons.play_circle_outline_rounded,
    description:
        'YouTube üzerindeki toplam izlenme sayısına göre sıralanan '
        'videolar. En fazla izlenen videolar üstte yer alır. '
        'Bu veri YouTube\'un resmi istatistiklerinden alınır.',
  ),
  VideoSectionConfig(
    title: '❤️ En Beğenilen Videolar',
    type: VideoSectionType.mostLiked,
    statLabelBuilder: (v) => '${v.appLikeCount.compact} beğeni',
    statIcon: Icons.favorite_outline_rounded,
    description:
        'Uygulama içinde en çok beğeni alan videolar. '
        'Beğeni sayısı, kullanıcıların video detay sayfasında '
        'kalp ikonuna dokunmasıyla oluşur. '
        'Bu liste yalnızca uygulama içi beğenileri yansıtır.',
  ),
  VideoSectionConfig(
    title: '⭐ En Favorilenler',
    type: VideoSectionType.mostFavorited,
    statLabelBuilder: (v) => '${v.appFavoriteCount.compact} favori',
    statIcon: Icons.star_outline_rounded,
    description:
        'Uygulama içinde en çok favorilere eklenen videolar. '
        'Kullanıcılar bir videoyu yıldız simgesiyle favorilerine ekleyebilir; '
        'bu liste en fazla favorileme sayısına sahip videoları gösterir.',
  ),
  VideoSectionConfig(
    title: '💬 En Çok Yorumlananlar',
    type: VideoSectionType.mostCommented,
    statLabelBuilder: (v) => '${v.appCommentCount.compact} yorum',
    statIcon: Icons.chat_bubble_outline_rounded,
    description:
        'Uygulama içinde en fazla yorum yapılan videolar. '
        'Yorumlar, kullanıcıların video sayfasında bıraktığı '
        'uygulama içi mesajlardır. YouTube yorumlarından bağımsızdır. '
        'En aktif tartışmaları bu listede bulabilirsin.',
  ),
  VideoSectionConfig(
    title: '🆕 Yeni & Keşfedilmemiş',
    type: VideoSectionType.newUndiscovered,
    statLabelBuilder: (v) => timeAgoTr(v.publishedAt),
    statIcon: Icons.explore_outlined,
    description:
        'Son dönemde yayınlanan ve henüz çok fazla etkileşim almamış '
        'videolar. Az izlenme ve etkileşim sayısına sahip, '
        'üzerine az yorum yapılmış "gizli kalmış" içerikler buradadır. '
        'Keşfetmeyi sevenler için!',
  ),
];

// ─── Build helper ────────────────────────────────────────────────────────────

List<Widget> buildVideoSections({
  required List<VideoSectionConfig> configs,
  required List<List<VideoEngagementModel>> allVideoItems,
  required bool isLoading,
}) {
  return [
    for (var i = 0; i < configs.length; i++)
      Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: HorizontalSection<VideoEngagementModel>(
          title: configs[i].title,
          description: configs[i].description,
          items: allVideoItems[i],
          isLoading: isLoading,
          animationIndex: i,
          onSeeAll: () => Get.toNamed(
            AppRoutes.videoSectionDetail,
            arguments: {
              'type': configs[i].type,
              'title': configs[i].title,
              'initialItems': allVideoItems[i],
            },
          ),
          itemBuilder: (ctx, v) => VideoHorizontalCard(
            video: v,
            statLabelBuilder: configs[i].statLabelBuilder,
            statIcon: configs[i].statIcon,
          ),
        ),
      ),
  ];
}