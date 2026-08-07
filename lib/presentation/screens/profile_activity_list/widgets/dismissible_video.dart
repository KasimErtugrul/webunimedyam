// ─── Silinebilir Sarmalayıcı ────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/video_model.dart';
import '../../../controllers/profile_activity_list_controller.dart';
import '../utils/sizes.dart';

class ProfileActivityListDismissibleVideo extends StatelessWidget {
  final ProfileActivityListSizes sizes;
  final ProfileActivityListController controller;
  final VideoModel video;
  final Widget child;

  const ProfileActivityListDismissibleVideo({
    super.key,
    required this.sizes,
    required this.controller,
    required this.video,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(video.videoId),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.only(bottom: sizes.dismissibleMarginBottom),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(sizes.dismissibleBorderRadius),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: sizes.dismissiblePaddingRight),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: sizes.dismissibleIconSize,
            ),
            SizedBox(height: sizes.dismissibleSpacing),
            Text(
              'Sil',
              style: TextStyle(
                color: Colors.white,
                fontSize: sizes.dismissibleTextFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppTheme.card(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(sizes.dialogBorderRadius),
                ),
                title: Text(
                  'Kaydı Sil',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: sizes.dialogTitleFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                content: Text(
                  'Bu kayıt listenden kaldırılacak. Emin misin?',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: sizes.dialogContentFontSize,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(
                      'İptal',
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: sizes.dialogButtonFontSize,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      minimumSize: Size(
                        sizes.dialogButtonWidth,
                        sizes.dialogButtonHeight,
                      ),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text(
                      'Sil',
                      style: TextStyle(fontSize: sizes.dialogButtonFontSize),
                    ),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => controller.removeVideo(video.videoId),
      child: child,
    );
  }
}
