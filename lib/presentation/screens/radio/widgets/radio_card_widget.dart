// lib/presentation/screens/radio/widgets/radio_card_widget.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:radio_player/radio_player.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';
import '../../../../data/models/university_model.dart';
import '../../../controllers/radio_page_controller.dart';
import 'radio_control_button_widget.dart';
import 'radio_fallback_logo_widget.dart';
import 'radio_play_button_widget.dart';
import 'radio_wave_row_widget.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // Card padding
  static const double cardPaddingHorizontal = 24;
  static const double cardPaddingVertical = 16;

  // Outer ring animation
  static const double ringSize = 160;
  static const double ringBorderWidth = 2;

  // Inner logo container
  static const double logoContainerSize = 140;
  static const double logoBorderWidth = 2;
  static const double shadowBlurRadius = 20;
  static const double shadowSpreadRadius = 5;
  static const double shadowAlpha = 0.15;
  static const double borderAlpha = 0.2;

  // Visualizer bars
  static const int visualizerBarCount = 12;
  static const double visualizerBarWidth = 3;
  static const double visualizerBarSpacing = 1.5;
  static const double visualizerBarMaxHeight = 60;
  static const double visualizerBarAlpha = 0.6;
  static const double visualizerBarBorderRadius = 2;

  // Spacing
  static const double logoTextSpacing = 28;
  static const double textMetaSpacing = 8;
  static const double metaControlsSpacing = 36;
  static const double controlSpacing = 20;
  static const double waveSpacing = 16;

  // Text styles
  static const double uniNameFontSize = 18;
  static const double metaFontSize = 13;

  // Play button
  static const double playButtonSize = 64;

  // Loading indicator
  static const double loadingStrokeWidth = 3;

  // Animasyon
  static const Duration animDuration = Duration(milliseconds: 500);
  static const Duration animDurationShort = Duration(milliseconds: 300);
}

class _TabletSizes {
  // Card padding - tablet için daha büyük
  static const double cardPaddingHorizontal = 32;
  static const double cardPaddingVertical = 24;

  // Outer ring animation - tablet için daha büyük
  static const double ringSize = 180;
  static const double ringBorderWidth = 2.5;

  // Inner logo container - tablet için daha büyük
  static const double logoContainerSize = 160;
  static const double logoBorderWidth = 2.5;
  static const double shadowBlurRadius = 24;
  static const double shadowSpreadRadius = 6;
  static const double shadowAlpha = 0.15;
  static const double borderAlpha = 0.2;

  // Visualizer bars - tablet için daha büyük
  static const int visualizerBarCount = 14;
  static const double visualizerBarWidth = 4;
  static const double visualizerBarSpacing = 2;
  static const double visualizerBarMaxHeight = 70;
  static const double visualizerBarAlpha = 0.6;
  static const double visualizerBarBorderRadius = 3;

  // Spacing - tablet için daha geniş
  static const double logoTextSpacing = 32;
  static const double textMetaSpacing = 10;
  static const double metaControlsSpacing = 40;
  static const double controlSpacing = 24;
  static const double waveSpacing = 20;

  // Text styles - tablet için daha büyük
  static const double uniNameFontSize = 22;
  static const double metaFontSize = 15;

  // Play button - tablet için daha büyük
  static const double playButtonSize = 72;

  // Loading indicator - tablet için daha büyük
  static const double loadingStrokeWidth = 3.5;

  // Animasyon
  static const Duration animDuration = Duration(milliseconds: 500);
  static const Duration animDurationShort = Duration(milliseconds: 300);
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateless)
// ═══════════════════════════════════════════════════════════

class RadioCardWidget extends StatelessWidget {
  final UniversityModel uni;
  final RadioPageController ctrl;
  final bool isActive;

  const RadioCardWidget({
    super.key,
    required this.uni,
    required this.ctrl,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    // KURAL 5 — TEK DALLANMA NOKTASI
    return Responsive.isTablet(context)
        ? _buildTablet(context)
        : _buildPhone(context);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI (BİREBİR AYNI)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPhone(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _PhoneSizes.cardPaddingHorizontal.w,
        vertical: _PhoneSizes.cardPaddingVertical.h,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLogoSectionPhone(context),
          SizedBox(height: _PhoneSizes.logoTextSpacing.h),
          _buildNameSectionPhone(context),
          SizedBox(height: _PhoneSizes.textMetaSpacing.h),
          _buildMetaSectionPhone(context),
          SizedBox(height: _PhoneSizes.metaControlsSpacing.h),
          _buildControlsSectionPhone(context),
          SizedBox(height: _PhoneSizes.waveSpacing.h),
          _buildWaveSectionPhone(context),
        ],
      ),
    );
  }

  Widget _buildLogoSectionPhone(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Obx(() {
          final playing = ctrl.playbackState.value == PlaybackState.playing;
          return AnimatedContainer(
            duration: _PhoneSizes.animDuration,
            width: _PhoneSizes.ringSize.r,
            height: _PhoneSizes.ringSize.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: playing ? AppTheme.primaryColor : Colors.transparent,
                width: _PhoneSizes.ringBorderWidth.r,
              ),
            ),
            child: playing
                ? const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  )
                : null,
          );
        }),
        Container(
          width: _PhoneSizes.logoContainerSize.r,
          height: _PhoneSizes.logoContainerSize.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.surface(context),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: _PhoneSizes.borderAlpha),
              width: _PhoneSizes.logoBorderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: _PhoneSizes.shadowAlpha),
                blurRadius: _PhoneSizes.shadowBlurRadius.r,
                spreadRadius: _PhoneSizes.shadowSpreadRadius.r,
              ),
            ],
          ),
          child: ClipOval(
            child: uni.logoUrl != null
                ? CachedNetworkImage(
                    imageUrl: uni.logoUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => RadioFallbackLogoWidget(uni: uni),
                  )
                : RadioFallbackLogoWidget(uni: uni),
          ),
        ),
        Positioned.fill(
          child: Visibility(
            visible: isActive,
            maintainState: true,
            maintainAnimation: true,
            maintainSize: true,
            child: RadioVisualizer(
              fallbackEnabledIOS: true,
              fallbackTimeout: const Duration(milliseconds: 500),
              builder: (context, data) {
                if (data.isNotEmpty) {
                  return IgnorePointer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: data.take(_PhoneSizes.visualizerBarCount).map((value) {
                        final height = (value / 255) * _PhoneSizes.visualizerBarMaxHeight.r;
                        return Container(
                          width: _PhoneSizes.visualizerBarWidth.w,
                          height: height,
                          margin: EdgeInsets.symmetric(
                            horizontal: _PhoneSizes.visualizerBarSpacing.w,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: _PhoneSizes.visualizerBarAlpha),
                            borderRadius: BorderRadius.circular(
                              _PhoneSizes.visualizerBarBorderRadius.r,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameSectionPhone(BuildContext context) {
    return Text(
      uni.name!,
      style: TextStyle(
        color: AppTheme.textPri(context),
        fontSize: _PhoneSizes.uniNameFontSize.sp,
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMetaSectionPhone(BuildContext context) {
    return Obx(() {
      final state = ctrl.playbackState.value;
      final meta = ctrl.metadata.value;

      String text;
      if (state == PlaybackState.buffering) {
        text = 'Açılıyor...';
      } else if (state == PlaybackState.playing) {
        if (isActive && meta?.title != null && meta!.title!.isNotEmpty) {
          text = meta.title!;
        } else {
          text = 'Dinliyorsunuz';
        }
      } else {
        text = 'Radyo yayını yok';
      }

      return AnimatedSwitcher(
        duration: _PhoneSizes.animDurationShort,
        child: Text(
          text,
          key: ValueKey(text),
          style: TextStyle(
            color: AppTheme.textSec(context),
            fontSize: _PhoneSizes.metaFontSize.sp,
            fontStyle: text == 'Dinliyorsunuz' ? FontStyle.italic : FontStyle.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    });
  }

  Widget _buildControlsSectionPhone(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RadioControlButtonWidget(
          icon: Icons.skip_previous_rounded,
          onTap: () {
            if (isActive) ctrl.previousStation();
          },
          enabled: isActive,
        ),
        SizedBox(width: _PhoneSizes.controlSpacing.w),
        Obx(() {
          final state = ctrl.playbackState.value;
          final buffering = state == PlaybackState.buffering;
          final playing = state == PlaybackState.playing;

          if (!isActive) {
            return RadioPlayButtonWidget(
              icon: Icons.play_arrow_rounded,
              onTap: () => ctrl.playStation(uni),
              active: false,
            );
          }
          if (buffering) {
            return SizedBox(
              width: _PhoneSizes.playButtonSize.r,
              height: _PhoneSizes.playButtonSize.r,
              child: CircularProgressIndicator(
                strokeWidth: _PhoneSizes.loadingStrokeWidth,
                color: AppTheme.primaryColor,
              ),
            );
          }
          return RadioPlayButtonWidget(
            icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
            onTap: () {
              if (playing) {
                RadioPlayer.pause();
              } else {
                RadioPlayer.play();
              }
            },
            active: true,
          );
        }),
        SizedBox(width: _PhoneSizes.controlSpacing.w),
        RadioControlButtonWidget(
          icon: Icons.skip_next_rounded,
          onTap: () {
            if (isActive) ctrl.nextStation();
          },
          enabled: isActive,
        ),
      ],
    );
  }

  Widget _buildWaveSectionPhone(BuildContext context) {
    return Obx(() {
      final playing = ctrl.playbackState.value == PlaybackState.playing;
      return RadioWaveRowWidget(isActive: isActive && playing);
    });
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _TabletSizes.cardPaddingHorizontal,
        vertical: _TabletSizes.cardPaddingVertical,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLogoSectionTablet(context),
          SizedBox(height: _TabletSizes.logoTextSpacing),
          _buildNameSectionTablet(context),
          SizedBox(height: _TabletSizes.textMetaSpacing),
          _buildMetaSectionTablet(context),
          SizedBox(height: _TabletSizes.metaControlsSpacing),
          _buildControlsSectionTablet(context),
          SizedBox(height: _TabletSizes.waveSpacing),
          _buildWaveSectionTablet(context),
        ],
      ),
    );
  }

  Widget _buildLogoSectionTablet(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Obx(() {
          final playing = ctrl.playbackState.value == PlaybackState.playing;
          return AnimatedContainer(
            duration: _TabletSizes.animDuration,
            width: _TabletSizes.ringSize,
            height: _TabletSizes.ringSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: playing ? AppTheme.primaryColor : Colors.transparent,
                width: _TabletSizes.ringBorderWidth,
              ),
            ),
            child: playing
                ? const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  )
                : null,
          );
        }),
        Container(
          width: _TabletSizes.logoContainerSize,
          height: _TabletSizes.logoContainerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.surface(context),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: _TabletSizes.borderAlpha),
              width: _TabletSizes.logoBorderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: _TabletSizes.shadowAlpha),
                blurRadius: _TabletSizes.shadowBlurRadius,
                spreadRadius: _TabletSizes.shadowSpreadRadius,
              ),
            ],
          ),
          child: ClipOval(
            child: uni.logoUrl != null
                ? CachedNetworkImage(
                    imageUrl: uni.logoUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => RadioFallbackLogoWidget(uni: uni),
                  )
                : RadioFallbackLogoWidget(uni: uni),
          ),
        ),
        Positioned.fill(
          child: Visibility(
            visible: isActive,
            maintainState: true,
            maintainAnimation: true,
            maintainSize: true,
            child: RadioVisualizer(
              fallbackEnabledIOS: true,
              fallbackTimeout: const Duration(milliseconds: 500),
              builder: (context, data) {
                if (data.isNotEmpty) {
                  return IgnorePointer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: data.take(_TabletSizes.visualizerBarCount).map((value) {
                        final height = (value / 255) * _TabletSizes.visualizerBarMaxHeight;
                        return Container(
                          width: _TabletSizes.visualizerBarWidth,
                          height: height,
                          margin: EdgeInsets.symmetric(
                            horizontal: _TabletSizes.visualizerBarSpacing,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: _TabletSizes.visualizerBarAlpha),
                            borderRadius: BorderRadius.circular(
                              _TabletSizes.visualizerBarBorderRadius,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameSectionTablet(BuildContext context) {
    return Text(
      uni.name!,
      style: TextStyle(
        color: AppTheme.textPri(context),
        fontSize: _TabletSizes.uniNameFontSize,
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMetaSectionTablet(BuildContext context) {
    return Obx(() {
      final state = ctrl.playbackState.value;
      final meta = ctrl.metadata.value;

      String text;
      if (state == PlaybackState.buffering) {
        text = 'Açılıyor...';
      } else if (state == PlaybackState.playing) {
        if (isActive && meta?.title != null && meta!.title!.isNotEmpty) {
          text = meta.title!;
        } else {
          text = 'Dinliyorsunuz';
        }
      } else {
        text = 'Radyo yayını yok';
      }

      return AnimatedSwitcher(
        duration: _TabletSizes.animDurationShort,
        child: Text(
          text,
          key: ValueKey(text),
          style: TextStyle(
            color: AppTheme.textSec(context),
            fontSize: _TabletSizes.metaFontSize,
            fontStyle: text == 'Dinliyorsunuz' ? FontStyle.italic : FontStyle.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    });
  }

  Widget _buildControlsSectionTablet(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RadioControlButtonWidget(
          icon: Icons.skip_previous_rounded,
          onTap: () {
            if (isActive) ctrl.previousStation();
          },
          enabled: isActive,
        ),
        SizedBox(width: _TabletSizes.controlSpacing),
        Obx(() {
          final state = ctrl.playbackState.value;
          final buffering = state == PlaybackState.buffering;
          final playing = state == PlaybackState.playing;

          if (!isActive) {
            return RadioPlayButtonWidget(
              icon: Icons.play_arrow_rounded,
              onTap: () => ctrl.playStation(uni),
              active: false,
            );
          }
          if (buffering) {
            return SizedBox(
              width: _TabletSizes.playButtonSize,
              height: _TabletSizes.playButtonSize,
              child: CircularProgressIndicator(
                strokeWidth: _TabletSizes.loadingStrokeWidth,
                color: AppTheme.primaryColor,
              ),
            );
          }
          return RadioPlayButtonWidget(
            icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
            onTap: () {
              if (playing) {
                RadioPlayer.pause();
              } else {
                RadioPlayer.play();
              }
            },
            active: true,
          );
        }),
        SizedBox(width: _TabletSizes.controlSpacing),
        RadioControlButtonWidget(
          icon: Icons.skip_next_rounded,
          onTap: () {
            if (isActive) ctrl.nextStation();
          },
          enabled: isActive,
        ),
      ],
    );
  }

  Widget _buildWaveSectionTablet(BuildContext context) {
    return Obx(() {
      final playing = ctrl.playbackState.value == PlaybackState.playing;
      return RadioWaveRowWidget(isActive: isActive && playing);
    });
  }
}