import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../app/themes/app_theme.dart';
import '../../controllers/player_controller.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/models/video_model.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlayerController>();
    final commentController = TextEditingController();

    return Obx(() {
      if (!controller.isPlayerReady.value) {
        return const Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          ),
        );
      }

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (controller.youtubeController.value.isFullScreen) {
            controller.youtubeController.toggleFullScreenMode();
          } else {
            Get.back();
          }
        },
        child: YoutubePlayerBuilder(
          player: YoutubePlayer(
            controller: controller.youtubeController,
            showVideoProgressIndicator: true,
            progressIndicatorColor: AppTheme.primaryColor,
          ),
          builder: (context, player) {
            return Scaffold(
              backgroundColor: AppTheme.backgroundColor,
              body: SafeArea(
                child: Column(
                  children: [
                    // ── Video oynatıcı ─────────────────────────────────
                    Stack(
                      children: [
                        player,
                        Positioned(
                          top: 8,
                          left: 4,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => Get.back(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.45),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ── İçerik ────────────────────────────────────────
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Başlık + Favori ──────────────────────
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    controller.currentVideo?.title ?? '',
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Obx(
                                  () => GestureDetector(
                                    onTap: controller.toggleFavorite,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.cardColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        controller.isFavorite.value
                                            ? Icons.favorite_rounded
                                            : Icons.favorite_outline_rounded,
                                        color: controller.isFavorite.value
                                            ? AppTheme.primaryColor
                                            : AppTheme.textSecondary,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // ── İstatistik Satırı ────────────────────
                            if (controller.currentVideo != null)
                              _StatsRow(video: controller.currentVideo!),

                            const SizedBox(height: 16),

                            // ── Açıklama ─────────────────────────────
                            if (controller
                                    .currentVideo
                                    ?.description
                                    .isNotEmpty ==
                                true)
                              _ExpandableDescription(
                                text: controller.currentVideo!.description,
                              ),

                            // ── Etiketler ────────────────────────────
                            if (controller.currentVideo?.tags != null &&
                                controller.currentVideo?.tags.isNotEmpty ==
                                    true) ...[
                              const SizedBox(height: 16),
                              _TagsRow(tags: controller.currentVideo!.tags),
                            ],

                            const Divider(
                              color: AppTheme.surfaceColor,
                              height: 32,
                            ),

                            // ── Yorumlar Başlığı ─────────────────────
                            Row(
                              children: [
                                const Text(
                                  'Yorumlar',
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if ((controller.currentVideo?.commentCount ??
                                        0) >
                                    0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${controller.currentVideo!.commentCount}',
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // ── Yorum Giriş Alanı ────────────────────
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: commentController,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Yorum yaz...',
                                      hintStyle: TextStyle(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.send_rounded,
                                    color: AppTheme.primaryColor,
                                  ),
                                  onPressed: () {
                                    controller.addComment(
                                      commentController.text,
                                    );
                                    commentController.clear();
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // ── Yorum Listesi ────────────────────────
                            Obx(() {
                              if (controller.isCommentsLoading.value) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: AppTheme.primaryColor,
                                  ),
                                );
                              }
                              if (controller.comments.isEmpty) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Text(
                                      'Henüz yorum yok. İlk yorumu sen yap!',
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: controller.comments.length,
                                itemBuilder: (context, index) {
                                  return _CommentTile(
                                    comment: controller.comments[index],
                                    onDelete: () => controller.deleteComment(
                                      controller.comments[index].id,
                                    ),
                                  );
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// İstatistik Satırı
// ═══════════════════════════════════════════════════════════════════════════

class _StatsRow extends StatelessWidget {
  final VideoModel video;
  const _StatsRow({required this.video});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Görüntülenme
        _StatChip(
          icon: Icons.play_circle_outline_rounded,
          label: video.formattedViewCount,
        ),
        // Beğeni
        if (video.likeCount > 0)
          _StatChip(
            icon: Icons.thumb_up_alt_outlined,
            label: _formatCount(video.likeCount),
          ),
        // Süre
        if (video.formattedDuration.isNotEmpty)
          _StatChip(
            icon: Icons.access_time_rounded,
            label: video.formattedDuration,
          ),
        // HD rozeti
        if (video.isHd)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.4)),
            ),
            child: const Text(
              'HD',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        // Tarih
        _StatChip(
          icon: Icons.calendar_today_outlined,
          label: _formatDate(video.publishedAt),
        ),
      ],
    );
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}B';
    return '$n';
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Genişletilebilir Açıklama
// ═══════════════════════════════════════════════════════════════════════════

class _ExpandableDescription extends StatefulWidget {
  final String text;
  const _ExpandableDescription({required this.text});

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
              maxLines: _expanded ? null : 3,
              overflow: _expanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _expanded ? 'Daha az göster' : 'Devamını gör',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Etiket Satırı
// ═══════════════════════════════════════════════════════════════════════════

class _TagsRow extends StatelessWidget {
  final List<String> tags;
  const _TagsRow({required this.tags});

  @override
  Widget build(BuildContext context) {
    // Maksimum 8 etiket göster
    final visible = tags.take(8).toList();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: visible
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.surfaceColor, width: 1),
              ),
              child: Text(
                '#$tag',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Yorum Kartı
// ═══════════════════════════════════════════════════════════════════════════

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  final VoidCallback onDelete;

  const _CommentTile({required this.comment, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.cardColor,
            child: Text(
              (comment.profile?.username ?? 'U')[0].toUpperCase(),
              style: const TextStyle(color: AppTheme.primaryColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.profile?.username ?? 'Kullanıcı',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppTheme.textSecondary,
              size: 18,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
