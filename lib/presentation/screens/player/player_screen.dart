import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
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
        return Scaffold(
          backgroundColor: AppTheme.bg(context),
          body: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      }

      // youtube_player_iframe fullscreen'ı kendi yönetir:
      // • Tam ekran butonuna basılırsa → otomatik geçiş
      // • Cihaz yatay dönerse → autoFullScreen ile geçiş
      // • Geri tuşu / sistem jesti → fullscreenden çıkış
      // Bu yüzden PopScope'a gerek yok; varsayılan geri navigasyonu yeterli.

      return YoutubePlayerControllerProvider(
        controller: controller.youtubeController,
        child: Scaffold(
          backgroundColor: AppTheme.bg(context),
          appBar: AppBar(
            title: Text(
              controller.currentVideo?.channelTitle ?? '',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SafeArea(
            child: Column(
              children: [
                // ── Video oynatıcı
                Stack(
                  children: [
                    YoutubePlayer(
                      controller: controller.youtubeController,
                      aspectRatio: 16 / 9,
                      autoFullScreen: true,
                    ),
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
                              color: Colors.black.withValues(alpha: 0.45),
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

                // ── İçerik
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Başlık
                        Text(
                          controller.currentVideo?.title ?? '',
                          style: TextStyle(
                            color: AppTheme.textPri(context),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // ── YouTube meta (görüntülenme · tarih · süre)
                        if (controller.currentVideo != null)
                          _YoutubeMeta(video: controller.currentVideo!),

                        const SizedBox(height: 14),

                        // ── Aksiyon + Uygulama istatistikleri tek satır
                        _EngagementBar(controller: controller),

                        const SizedBox(height: 16),

                        // ── Açıklama
                        if (controller.currentVideo?.description.isNotEmpty ==
                            true)
                          _ExpandableDescription(
                            text: controller.currentVideo!.description,
                          ),

                        // ── Etiketler
                        if (controller.currentVideo?.tags.isNotEmpty ==
                            true) ...[
                          const SizedBox(height: 14),
                          _TagsRow(tags: controller.currentVideo!.tags),
                        ],

                        const SizedBox(height: 20),
                        Divider(color: AppTheme.surface(context), height: 1),
                        const SizedBox(height: 16),

                        // ── Yorumlar başlık
                        Obx(
                          () => _CommentsHeader(
                            count: controller.appCommentCount.value,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Yorum giriş
                        _CommentInput(
                          textController: commentController,
                          onSend: () {
                            controller.addComment(commentController.text);
                            commentController.clear();
                          },
                        ),

                        const SizedBox(height: 16),

                        // ── Yorum listesi
                        Obx(() {
                          if (controller.isCommentsLoading.value) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }
                          if (controller.comments.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text(
                                  'Henüz yorum yok. İlk yorumu sen yap!',
                                  style: TextStyle(
                                    color: AppTheme.textSec(context),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.comments.length,
                            separatorBuilder: (_, __) => Divider(
                              color: AppTheme.surface(context),
                              height: 1,
                            ),
                            itemBuilder: (context, index) => _CommentTile(
                              comment: controller.comments[index],
                              onDelete: () => controller.deleteComment(
                                controller.comments[index].id,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// YouTube meta satırı  (görüntülenme · tarih · süre · HD)
// ═══════════════════════════════════════════════════════════════════════════

class _YoutubeMeta extends StatelessWidget {
  final VideoModel video;
  const _YoutubeMeta({required this.video});

  String _fmtCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}B';
    return '$n';
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (video.viewCount > 0)
      parts.add('${_fmtCount(video.viewCount)} görüntülenme');
    if (video.formattedDuration.isNotEmpty) parts.add(video.formattedDuration);
    parts.add(_fmtDate(video.publishedAt));

    return Row(
      children: [
        Expanded(
          child: Text(
            parts.join('  ·  '),
            style: TextStyle(color: AppTheme.textSec(context), fontSize: 12),
          ),
        ),
        if (video.isHd)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.textSec(context).withValues(alpha: 0.4),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'HD',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Engagement bar — aksiyonlar + uygulama istatistikleri TEK SATIRDA
// ═══════════════════════════════════════════════════════════════════════════

class _EngagementBar extends StatelessWidget {
  final PlayerController controller;
  const _EngagementBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          // Beğen
          Obx(
            () => _EngagementAction(
              icon: controller.isLiked.value
                  ? Icons.thumb_up_rounded
                  : Icons.thumb_up_alt_outlined,
              count: controller.appLikeCount.value,
              active: controller.isLiked.value,
              loading: controller.isLikeLoading.value,
              onTap: controller.toggleLike,
            ),
          ),

          const SizedBox(width: 4),

          // Paylaş
          Obx(
            () => _EngagementAction(
              icon: Icons.share_outlined,
              count: controller.appShareCount.value,
              active: false,
              loading: controller.isShareLoading.value,
              onTap: controller.shareVideo,
            ),
          ),

          const SizedBox(width: 4),

          // Favori
          Obx(
            () => _EngagementAction(
              icon: controller.isFavorite.value
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_outline_rounded,
              count: controller.appFavoriteCount.value,
              active: controller.isFavorite.value,
              loading: controller.isFavoriteLoading.value,
              onTap: controller.toggleFavorite,
            ),
          ),

          const Spacer(),

          // İzlenme (sadece gösterim, tıklanamaz)
          Obx(
            () => _StatBadge(
              icon: Icons.visibility_outlined,
              count: controller.appViewCount.value,
              loading: controller.isInitialStatsLoading.value,
            ),
          ),

          const SizedBox(width: 10),

          // Yorum sayısı
          Obx(
            () => _StatBadge(
              icon: Icons.chat_bubble_outline_rounded,
              count: controller.appCommentCount.value,
              loading: controller.isInitialStatsLoading.value,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tıklanabilir aksiyon butonu — ikon + sayı
class _EngagementAction extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool active;
  final bool loading;
  final VoidCallback onTap;

  const _EngagementAction({
    required this.icon,
    required this.count,
    required this.active,
    required this.loading,
    required this.onTap,
  });

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}B';
    if (n == 0) return '';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final color = active
        ? Theme.of(context).colorScheme.primary
        : AppTheme.textSec(context);
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: color,
                ),
              )
            else
              Icon(icon, color: color, size: 20),
            if (_fmt(count).isNotEmpty) ...[
              const SizedBox(width: 5),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Text(
                  _fmt(count),
                  key: ValueKey(count),
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Sadece gösterim — izlenme & yorum sayısı
class _StatBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool loading;

  const _StatBadge({
    required this.icon,
    required this.count,
    required this.loading,
  });

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}B';
    if (n == 0) return '0';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.textSec(context), size: 15),
        const SizedBox(width: 4),
        loading
            ? SizedBox(
                width: 28,
                height: 10,
                child: LinearProgressIndicator(
                  backgroundColor: AppTheme.surface(context),
                  color: AppTheme.textSec(context).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              )
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Text(
                  _fmt(count),
                  key: ValueKey(count),
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: 12,
                  ),
                ),
              ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Yorum başlığı
// ═══════════════════════════════════════════════════════════════════════════

class _CommentsHeader extends StatelessWidget {
  final int count;
  const _CommentsHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Yorumlar',
          style: TextStyle(
            color: AppTheme.textPri(context),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (count > 0) ...[
          const SizedBox(width: 8),
          Text(
            '$count',
            style: TextStyle(color: AppTheme.textSec(context), fontSize: 13),
          ),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Yorum giriş alanı
// ═══════════════════════════════════════════════════════════════════════════

class _CommentInput extends StatelessWidget {
  final TextEditingController textController;
  final VoidCallback onSend;
  const _CommentInput({required this.textController, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: textController,
            style: TextStyle(color: AppTheme.textPri(context), fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Yorum yaz...',
              hintStyle: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppTheme.surface(context),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onSend,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.send_rounded,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 18,
            ),
          ),
        ),
      ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: 13,
              height: 1.55,
            ),
            maxLines: _expanded ? null : 3,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _expanded ? 'Daha az göster' : 'Devamını gör',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Etiketler
// ═══════════════════════════════════════════════════════════════════════════

class _TagsRow extends StatelessWidget {
  final List<String> tags;
  const _TagsRow({required this.tags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tags
          .take(8)
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '#$tag',
                style: TextStyle(
                  color: AppTheme.textSec(context),
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
// Yorum kartı
// ═══════════════════════════════════════════════════════════════════════════

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  final VoidCallback onDelete;

  const _CommentTile({required this.comment, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.surface(context),
            child: Text(
              (comment.profile?.username ?? 'U')[0].toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.profile?.username ?? 'Kullanıcı',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  comment.content,
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppTheme.textSec(context),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
