// lib/presentation/screens/player/player_screen_widgets/comments_sheet_widget.dart
//
// Player ekranındaki yorumlar için:
//  - CommentsSeeAllButton : son 3 yorumun altındaki "Tümünü Gör" butonu
//  - showCommentsSheet    : tüm yorumları temaya uygun bir alt pencerede
//                           (modal bottom sheet) gösterir.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';
import '../../../controllers/player/player_controller.dart';
import 'comment_input_widget.dart';
import 'comment_tile_widget.dart';

class _Sizes {
  final double buttonRadius;
  final double buttonPaddingV;
  final double buttonFontSize;
  final double buttonIconSize;
  final double buttonTopSpacing;

  final double sheetRadius;
  final double sheetHeightFactor;
  final double sheetMaxWidth;
  final double handleWidth;
  final double handleHeight;
  final double headerPaddingH;
  final double titleFontSize;
  final double badgeFontSize;
  final double badgePaddingH;
  final double badgePaddingV;
  final double badgeRadius;
  final double listPaddingH;
  final double itemSpacing;
  final double inputPaddingH;
  final double inputPaddingV;
  final double emptyFontSize;

  const _Sizes._({
    required this.buttonRadius,
    required this.buttonPaddingV,
    required this.buttonFontSize,
    required this.buttonIconSize,
    required this.buttonTopSpacing,
    required this.sheetRadius,
    required this.sheetHeightFactor,
    required this.sheetMaxWidth,
    required this.handleWidth,
    required this.handleHeight,
    required this.headerPaddingH,
    required this.titleFontSize,
    required this.badgeFontSize,
    required this.badgePaddingH,
    required this.badgePaddingV,
    required this.badgeRadius,
    required this.listPaddingH,
    required this.itemSpacing,
    required this.inputPaddingH,
    required this.inputPaddingV,
    required this.emptyFontSize,
  });

  factory _Sizes.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const _Sizes._(
        buttonRadius: 14,
        buttonPaddingV: 14,
        buttonFontSize: 15,
        buttonIconSize: 20,
        buttonTopSpacing: 14,
        sheetRadius: 28,
        sheetHeightFactor: 0.8,
        sheetMaxWidth: 640,
        handleWidth: 44,
        handleHeight: 5,
        headerPaddingH: 24,
        titleFontSize: 20,
        badgeFontSize: 14,
        badgePaddingH: 10,
        badgePaddingV: 4,
        badgeRadius: 14,
        listPaddingH: 20,
        itemSpacing: 10,
        inputPaddingH: 20,
        inputPaddingV: 12,
        emptyFontSize: 15,
      );
    }
    return const _Sizes._(
      buttonRadius: 12,
      buttonPaddingV: 12,
      buttonFontSize: 13,
      buttonIconSize: 18,
      buttonTopSpacing: 12,
      sheetRadius: 24,
      sheetHeightFactor: 0.85,
      sheetMaxWidth: double.infinity,
      handleWidth: 40,
      handleHeight: 4,
      headerPaddingH: 16,
      titleFontSize: 16,
      badgeFontSize: 12,
      badgePaddingH: 8,
      badgePaddingV: 3,
      badgeRadius: 12,
      listPaddingH: 12,
      itemSpacing: 8,
      inputPaddingH: 12,
      inputPaddingV: 10,
      emptyFontSize: 13,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// "Tümünü Gör" butonu
// ═══════════════════════════════════════════════════════════════════════

class CommentsSeeAllButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const CommentsSeeAllButton({
    super.key,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = _Sizes.of(context);
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: EdgeInsets.only(top: s.buttonTopSpacing),
      child: Material(
        color: primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(s.buttonRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(s.buttonRadius),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: s.buttonPaddingV),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tümünü Gör ($count)',
                  style: TextStyle(
                    color: primary,
                    fontSize: s.buttonFontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: primary,
                  size: s.buttonIconSize,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Tüm yorumlar alt penceresi
// ═══════════════════════════════════════════════════════════════════════

Future<void> showCommentsSheet(
  BuildContext context,
  PlayerController controller,
) {
  final s = _Sizes.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    constraints: BoxConstraints(maxWidth: s.sheetMaxWidth),
    builder: (_) => _CommentsSheet(controller: controller),
  );
}

class _CommentsSheet extends StatelessWidget {
  final PlayerController controller;
  const _CommentsSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    final s = _Sizes.of(context);
    final scheme = Theme.of(context).colorScheme;
    final mq = MediaQuery.of(context);

    // Klavye açılınca sheet klavyenin üstüne oturur ve ekrana sığacak
    // şekilde küçülür.
    final available = mq.size.height - mq.viewInsets.bottom - mq.padding.top;
    final height = math.min(mq.size.height * s.sheetHeightFactor, available);

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.bg(context),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(s.sheetRadius),
          ),
          border: Border(
            top: BorderSide(
              color: AppTheme.textSec(context).withValues(alpha: 0.12),
            ),
          ),
        ),
        child: Column(
          children: [
            // ── Tutamaç ──
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6),
              child: Container(
                width: s.handleWidth,
                height: s.handleHeight,
                decoration: BoxDecoration(
                  color: AppTheme.textSec(context).withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(s.handleHeight),
                ),
              ),
            ),

            // ── Başlık ──
            Padding(
              padding: EdgeInsets.fromLTRB(
                s.headerPaddingH,
                4,
                s.headerPaddingH - 8,
                8,
              ),
              child: Row(
                children: [
                  Text(
                    'Yorumlar',
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: s.titleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() {
                    final count = math.max(
                      controller.appCommentCount.value,
                      controller.comments.length,
                    );
                    if (count <= 0) return const SizedBox.shrink();
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: s.badgePaddingH,
                        vertical: s.badgePaddingV,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(s.badgeRadius),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: s.badgeFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppTheme.textSec(context),
                    ),
                    tooltip: 'Kapat',
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: AppTheme.textSec(context).withValues(alpha: 0.08),
            ),

            // ── Liste (en yeni en üstte) ──
            Expanded(
              child: Obx(() {
                if (controller.isCommentsLoading.value &&
                    controller.comments.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: scheme.primary,
                      strokeWidth: 2.5,
                    ),
                  );
                }
                final list = controller.commentsNewestFirst;
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      'Henüz yorum yok. İlk yorumu sen yap!',
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: s.emptyFontSize,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: s.listPaddingH,
                    vertical: 12,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => SizedBox(height: s.itemSpacing),
                  itemBuilder: (ctx, i) => CommentTileWidget(
                    comment: list[i],
                    canDelete: list[i].userId == controller.currentUserId,
                    onDelete: () => controller.deleteComment(list[i].id),
                  ),
                );
              }),
            ),

            // ── Yorum ekle ──
            Container(
              padding: EdgeInsets.fromLTRB(
                s.inputPaddingH,
                s.inputPaddingV,
                s.inputPaddingH,
                s.inputPaddingV + (mq.viewInsets.bottom > 0 ? 0 : mq.padding.bottom),
              ),
              decoration: BoxDecoration(
                color: AppTheme.bg(context),
                border: Border(
                  top: BorderSide(
                    color: AppTheme.textSec(context).withValues(alpha: 0.08),
                  ),
                ),
              ),
              child: CommentInputWidget(
                onSend: (text) => controller.addComment(text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}