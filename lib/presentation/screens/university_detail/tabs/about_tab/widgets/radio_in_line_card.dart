import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../../../controllers/university_radio_controller.dart';
import '../../../utils/university_detail_sizes.dart';
import 'radio_wave_animation.dart';

class UniversityDetailAboutTabRadioInlineCard extends StatelessWidget {
  final UniversityDetailSizes sizes;
  final dynamic university;
  final UniversityRadioController radioController;
  const UniversityDetailAboutTabRadioInlineCard({super.key, 
    required this.sizes,
    required this.university,
    required this.radioController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isThisPlaying =
          radioController.currentPlayingUrl.value == university.radioLink;
      final bool buffering = isThisPlaying && radioController.isBuffering;
      final bool playing = isThisPlaying && radioController.isPlaying;

      return Container(
        padding: EdgeInsets.all(sizes.radioCardPadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isThisPlaying
                ? [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                    AppTheme.card(context),
                  ]
                : [AppTheme.card(context), AppTheme.card(context)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(sizes.radioCardBorderRadius),
          border: Border.all(
            color: isThisPlaying
                ? const Color(0xFF8B5CF6).withValues(alpha: 0.4)
                : AppTheme.isDark(context)
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: sizes.radioIconContainerSize,
              height: sizes.radioIconContainerSize,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(
                  sizes.radioIconContainerRadius,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (playing || buffering)
                    UniversityDetailAboutTabRadioWaveAnimation(sizes: sizes, isActive: playing),
                  Icon(
                    buffering
                        ? Icons.hdr_weak_rounded
                        : (playing
                              ? Icons.equalizer_rounded
                              : Icons.radio_rounded),
                    color: const Color(0xFF8B5CF6),
                    size: sizes.radioIconSize,
                  ),
                ],
              ),
            ),
            SizedBox(width: sizes.radioIconSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Üniversite Radyosu',
                    style: TextStyle(
                      fontSize: sizes.radioTitleFontSize,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPri(context),
                    ),
                  ),
                  SizedBox(height: sizes.isTablet ? 3 : 2),
                  Text(
                    isThisPlaying
                        ? (playing
                              ? 'Canlı Yayın Dinleniyor...'
                              : (buffering
                                    ? 'Yayına Bağlanılıyor...'
                                    : 'Yayın Duraklatıldı'))
                        : 'Canlı yayını dinlemek için tıklayın',
                    style: TextStyle(
                      fontSize: sizes.radioSubtitleFontSize,
                      color: isThisPlaying
                          ? const Color(0xFF8B5CF6)
                          : AppTheme.textSec(context),
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(
                  sizes.radioPlayButtonRadius,
                ),
                onTap: () {
                  radioController.togglePlayPause(
                    url: university.radioLink,
                    name: university.name,
                    logoUrl: university.logoUrl,
                  );
                },
                child: Container(
                  width: sizes.radioPlayButtonSize,
                  height: sizes.radioPlayButtonSize,
                  decoration: BoxDecoration(
                    color: isThisPlaying
                        ? const Color(0xFF8B5CF6)
                        : const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    boxShadow: isThisPlaying
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFF8B5CF6,
                              ).withValues(alpha: 0.3),
                              blurRadius: sizes.isTablet ? 14 : 12,
                              offset: Offset(0, sizes.isTablet ? 5 : 4),
                            ),
                          ]
                        : null,
                  ),
                  child: buffering
                      ? SizedBox(
                          width: sizes.radioPlayButtonSize * 0.45,
                          height: sizes.radioPlayButtonSize * 0.45,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Icon(
                          playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: isThisPlaying
                              ? Colors.white
                              : const Color(0xFF8B5CF6),
                          size: sizes.radioPlayIconSize,
                        ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}