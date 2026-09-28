// lib/presentation/screens/player/player_screen_widgets/engagement_bar/view_count_meta_widget.dart
//
// Tarih • süre satırının sonunda duran, dokununca görüntüleyenler sayfasını
// açan küçük izlenme sayacı. (Eski StatBadgeWidget'ın yerine geçer.)
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/responsive.dart';
import '../../../../controllers/player/player_controller.dart';

class ViewCountMetaWidget extends StatelessWidget {
  final PlayerController controller;
  const ViewCountMetaWidget({super.key, required this.controller});

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}B';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final tablet = Responsive.isTablet(context);
    final iconSize = tablet ? 17.0 : 15.0;
    final fontSize = tablet ? 14.0 : 12.0;
    final primary = Theme.of(context).colorScheme.primary;
    final radius = BorderRadius.circular(10);

    return Obx(() {
      final loading = controller.isInitialStatsLoading.value;
      final count = controller.appViewCount.value;

      return Semantics(
        button: true,
        label: 'Görüntüleyenler',
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            splashColor: primary.withValues(alpha: 0.12),
            onTap: loading
                ? null
                : () => Get.toNamed(
                      AppRoutes.videoViewers,
                      arguments: {
                        'videoId':
                            controller.currentVideo.value?.videoId ?? '',
                        'totalViewCount': count,
                      },
                    ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: iconSize,
                    color: primary.withValues(alpha: 0.85),
                  ),
                  const SizedBox(width: 5),
                  if (loading)
                    Container(
                      width: 18,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.textSec(context)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )
                  else
                    Text(
                      _fmt(count),
                      style: TextStyle(
                        color: primary,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: iconSize,
                    color: primary.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}