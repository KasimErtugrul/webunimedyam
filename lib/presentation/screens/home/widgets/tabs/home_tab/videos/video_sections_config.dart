// lib/presentation/screens/home/widgets/tabs/home_tab/videos/video_sections_config.dart

import 'package:flutter/material.dart';

import '../../../../../../../data/models/video_engagement_model.dart';
import '../../../../../../../data/repositories/video_repository.dart';
import 'video_horizontal_section_widget.dart';

// VideoSectionType enum video_repository.dart'tan re-export edilir;
// bu dosyadan da erişilebilir.
export '../../../../../../../data/repositories/video_repository.dart'
    show VideoSectionType;

class VideoSectionConfig {
  final String title;
  final VideoSectionType type;
  final String Function(VideoEngagementModel) statLabelBuilder;
  final IconData statIcon;

  const VideoSectionConfig({
    required this.title,
    required this.type,
    required this.statLabelBuilder,
    required this.statIcon,
  });
}

// ─── Zaman formatlama yardımcısı ─────────────────────────────────────────────

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inDays >= 365) {
    final y = diff.inDays ~/ 365;
    return '$y yıl önce';
  }
  if (diff.inDays >= 30) {
    final m = diff.inDays ~/ 30;
    return '$m ay önce';
  }
  if (diff.inDays >= 1) return '${diff.inDays} gün önce';
  if (diff.inHours >= 1) return '${diff.inHours} saat önce';
  return '${diff.inMinutes} dakika önce';
}

// Sayı formatlama (university_horizontal_card_widget.dart'takinin kopyası)
String formatVideoStatNumber(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}B';
  return n.toString();
}

// ─── 6 Seksiyon Konfigürasyonu ───────────────────────────────────────────────

final List<VideoSectionConfig> videoSectionConfigs = [
  VideoSectionConfig(
    title: '🔥 Trend Videolar',
    type: VideoSectionType.trending,
    statLabelBuilder: (v) => '${v.engagementScore} puan',
    statIcon: Icons.trending_up_rounded,
  ),
  VideoSectionConfig(
    title: '👁️ En Çok İzlenenler',
    type: VideoSectionType.mostWatched,
    statLabelBuilder: (v) =>
        '${formatVideoStatNumber(v.ytViewCount)} izlenme',
    statIcon: Icons.play_circle_outline_rounded,
  ),
  VideoSectionConfig(
    title: '❤️ En Beğenilen Videolar',
    type: VideoSectionType.mostLiked,
    statLabelBuilder: (v) => '${v.appLikeCount} beğeni',
    statIcon: Icons.favorite_outline_rounded,
  ),
  VideoSectionConfig(
    title: '⭐ En Favorilenler',
    type: VideoSectionType.mostFavorited,
    statLabelBuilder: (v) => '${v.appFavoriteCount} favori',
    statIcon: Icons.star_outline_rounded,
  ),
  VideoSectionConfig(
    title: '💬 En Çok Yorumlananlar',
    type: VideoSectionType.mostCommented,
    statLabelBuilder: (v) => '${v.appCommentCount} yorum',
    statIcon: Icons.chat_bubble_outline_rounded,
  ),
  VideoSectionConfig(
    title: '🆕 Yeni & Keşfedilmemiş',
    type: VideoSectionType.newUndiscovered,
    statLabelBuilder: (v) => _timeAgo(v.publishedAt),
    statIcon: Icons.explore_outlined,
  ),
];

// ─── home_tab_widget.dart içinde kullanılacak helper ────────────────────────

List<Widget> buildVideoSections({
  required List<VideoSectionConfig> configs,
  required List<List<VideoEngagementModel>> allVideoItems,
  required bool isLoading,
}) {
  final widgets = <Widget>[];
  for (var i = 0; i < configs.length; i++) {
    final cfg = configs[i];
    widgets.add(
      VideoHorizontalSection(
        config: cfg,
        items: allVideoItems[i],
        isLoading: isLoading,
      ),
    );
    widgets.add(const SizedBox(height: 24));
  }
  return widgets;
}
