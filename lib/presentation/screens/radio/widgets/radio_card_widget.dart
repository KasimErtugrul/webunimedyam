// lib/presentation/screens/radio/widgets/radio_card_widget.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✨ SIFIRDAN YENİDEN TASARLANMIŞ RADYO KARTI
// Konsept: "Modern Glassmorphism Radio Card"
// Özellikler korundu: logo, görselleştirici, oynatma kontrolleri, dalga
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radio_player/radio_player.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';
import '../../../../data/models/university_model.dart';
import '../../../controllers/radio_page_controller.dart';
import 'radio_control_button_widget.dart';
import 'radio_fallback_logo_widget.dart';
import 'radio_play_button_widget.dart';
//import 'radio_visualizer_wrapper.dart';
import 'radio_wave_row_widget.dart';

// ═══════════════════════════════════════════════════════════
// SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  static const double cardPaddingHorizontal = 16;
  static const double cardPaddingVertical = 12;
  static const double ringSize = 180;
  static const double ringBorderWidth = 2;
  static const double logoContainerSize = 150;
  static const double logoBorderWidth = 2;
  static const double shadowBlurRadius = 30;
  static const double shadowSpreadRadius = 8;
  static const double shadowAlpha = 0.2;
  static const double borderAlpha = 0.3;
/*   static const int visualizerBarCount = 16;
  static const double visualizerBarWidth = 3;
  static const double visualizerBarSpacing = 2;
  static const double visualizerBarMaxHeight = 80;
  static const double visualizerBarAlpha = 0.7;
  static const double visualizerBarBorderRadius = 3; */
  static const double logoTextSpacing = 24;
  static const double textMetaSpacing = 6;
  static const double metaControlsSpacing = 28;
  static const double controlSpacing = 24;
  static const double waveSpacing = 12;
  static const double uniNameFontSize = 20;
  static const double metaFontSize = 13;
  static const double playButtonSize = 68;
  static const double loadingStrokeWidth = 3;
  static const Duration animDuration = Duration(milliseconds: 600);
  static const Duration animDurationShort = Duration(milliseconds: 300);
}

class _TabletSizes {
  static const double cardPaddingHorizontal = 24;
  static const double cardPaddingVertical = 16;
  static const double ringSize = 220;
  static const double ringBorderWidth = 2.5;
  static const double logoContainerSize = 180;
  static const double logoBorderWidth = 2.5;
  static const double shadowBlurRadius = 36;
  static const double shadowSpreadRadius = 10;
  static const double shadowAlpha = 0.2;
  static const double borderAlpha = 0.3;
/*   static const int visualizerBarCount = 18;
  static const double visualizerBarWidth = 4;
  static const double visualizerBarSpacing = 2.5;
  static const double visualizerBarMaxHeight = 100;
  static const double visualizerBarAlpha = 0.7;
  static const double visualizerBarBorderRadius = 4; */
  static const double logoTextSpacing = 28;
  static const double textMetaSpacing = 8;
  static const double metaControlsSpacing = 32;
  static const double controlSpacing = 28;
  static const double waveSpacing = 16;
  static const double uniNameFontSize = 24;
  static const double metaFontSize = 15;
  static const double playButtonSize = 80;
  static const double loadingStrokeWidth = 3.5;
  static const Duration animDuration = Duration(milliseconds: 600);
  static const Duration animDurationShort = Duration(milliseconds: 300);
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
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
    return Responsive.isTablet(context)
        ? _buildTablet(context)
        : _buildPhone(context);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PHONE TASARIMI - ✨ YENİ ✨
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPhone(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _PhoneSizes.cardPaddingHorizontal,
        vertical: _PhoneSizes.cardPaddingVertical,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ✨ Logo + Görselleştirici
          _buildLogoSectionPhone(context),
          const SizedBox(height: _PhoneSizes.logoTextSpacing),

          // ✨ İsim
          _buildNameSectionPhone(context),
          const SizedBox(height: _PhoneSizes.textMetaSpacing),

          // ✨ Metadata
          _buildMetaSectionPhone(context),
          const SizedBox(height: _PhoneSizes.metaControlsSpacing),

          // ✨ Kontroller
          _buildControlsSectionPhone(context),
          const SizedBox(height: _PhoneSizes.waveSpacing),

          // ✨ Dalga
          _buildWaveSectionPhone(context),
        ],
      ),
    );
  }

  Widget _buildLogoSectionPhone(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // ✨ Dönen halka animasyonu
        Obx(() {
          final playing = ctrl.playbackState.value == PlaybackState.playing;
          return AnimatedContainer(
            duration: _PhoneSizes.animDuration,
            width: _PhoneSizes.ringSize,
            height: _PhoneSizes.ringSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: playing
                    ? AppTheme.primaryColor.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.1),
                width: _PhoneSizes.ringBorderWidth,
              ),
              boxShadow: playing
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.15),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: playing
                ? _buildRotatingRing()
                : null,
          );
        }),

        // ✨ Logo
        Container(
          width: _PhoneSizes.logoContainerSize,
          height: _PhoneSizes.logoContainerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.surface(context),
                AppTheme.surface(context).withValues(alpha: 0.8),
              ],
            ),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: _PhoneSizes.borderAlpha),
              width: _PhoneSizes.logoBorderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: _PhoneSizes.shadowAlpha),
                blurRadius: _PhoneSizes.shadowBlurRadius,
                spreadRadius: _PhoneSizes.shadowSpreadRadius,
              ),
            ],
          ),
          child: ClipOval(
            child: uni.logoUrl != null
                ? CachedNetworkImage(
                    imageUrl: uni.logoUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => RadioFallbackLogoWidget(uni: uni),
                  )
                : RadioFallbackLogoWidget(uni: uni),
          ),
        ),

       /*  // ✨ RadioVisualizer (FFT görselleştirici) - dispose-safe wrapper
        Positioned.fill(
          child: RadioVisualizerWrapper(
            isActive: isActive,
            barCount: _PhoneSizes.visualizerBarCount,
            barWidth: _PhoneSizes.visualizerBarWidth,
            barSpacing: _PhoneSizes.visualizerBarSpacing,
            barMaxHeight: _PhoneSizes.visualizerBarMaxHeight,
            barBorderRadius: _PhoneSizes.visualizerBarBorderRadius,
            barAlpha: _PhoneSizes.visualizerBarAlpha,
          ),
        ), */
      ],
    );
  }

  Widget _buildRotatingRing() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 360),
      duration: const Duration(seconds: 4),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 3.14159 / 180,
          child: CustomPaint(
            painter: _RingPainter(
              color: AppTheme.primaryColor,
              progress: value / 360,
            ),
          ),
        );
      },
      onEnd: () {},
    );
  }

  Widget _buildNameSectionPhone(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
      ).createShader(bounds),
      child: Text(
        uni.name!,
        style: const TextStyle(
          color: Colors.white,
          fontSize: _PhoneSizes.uniNameFontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
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
        child: Container(
          key: ValueKey(text),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state == PlaybackState.playing)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.6),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              if (state == PlaybackState.playing) const SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                    color: state == PlaybackState.playing
                        ? Colors.white.withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.5),
                    fontSize: _PhoneSizes.metaFontSize,
                    fontStyle: text == 'Dinliyorsunuz' ? FontStyle.italic : FontStyle.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
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
        const SizedBox(width: _PhoneSizes.controlSpacing),
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
            return const SizedBox(
              width: _PhoneSizes.playButtonSize,
              height: _PhoneSizes.playButtonSize,
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
        const SizedBox(width: _PhoneSizes.controlSpacing),
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
  // TABLET TASARIMI - ✨ YENİ ✨
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _TabletSizes.cardPaddingHorizontal,
        vertical: _TabletSizes.cardPaddingVertical,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLogoSectionTablet(context),
          const SizedBox(height: _TabletSizes.logoTextSpacing),
          _buildNameSectionTablet(context),
          const SizedBox(height: _TabletSizes.textMetaSpacing),
          _buildMetaSectionTablet(context),
          const SizedBox(height: _TabletSizes.metaControlsSpacing),
          _buildControlsSectionTablet(context),
          const SizedBox(height: _TabletSizes.waveSpacing),
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
                color: playing
                    ? AppTheme.primaryColor.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.1),
                width: _TabletSizes.ringBorderWidth,
              ),
              boxShadow: playing
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.15),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: playing
                ? _buildRotatingRing()
                : null,
          );
        }),
        Container(
          width: _TabletSizes.logoContainerSize,
          height: _TabletSizes.logoContainerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.surface(context),
                AppTheme.surface(context).withValues(alpha: 0.8),
              ],
            ),
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
                    errorWidget: (_, _, _) => RadioFallbackLogoWidget(uni: uni),
                  )
                : RadioFallbackLogoWidget(uni: uni),
          ),
        ),
        // ✨ RadioVisualizer (FFT görselleştirici) - dispose-safe wrapper
      /*   Positioned.fill(
          child: RadioVisualizerWrapper(
            isActive: isActive,
            barCount: _TabletSizes.visualizerBarCount,
            barWidth: _TabletSizes.visualizerBarWidth,
            barSpacing: _TabletSizes.visualizerBarSpacing,
            barMaxHeight: _TabletSizes.visualizerBarMaxHeight,
            barBorderRadius: _TabletSizes.visualizerBarBorderRadius,
            barAlpha: _TabletSizes.visualizerBarAlpha,
          ),
        ), */
      ],
    );
  }

  Widget _buildNameSectionTablet(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
      ).createShader(bounds),
      child: Text(
        uni.name!,
        style: const TextStyle(
          color: Colors.white,
          fontSize: _TabletSizes.uniNameFontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
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
        child: Container(
          key: ValueKey(text),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state == PlaybackState.playing)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.6),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              if (state == PlaybackState.playing) const SizedBox(width: 10),
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                    color: state == PlaybackState.playing
                        ? Colors.white.withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.5),
                    fontSize: _TabletSizes.metaFontSize,
                    fontStyle: text == 'Dinliyorsunuz' ? FontStyle.italic : FontStyle.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
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
        const SizedBox(width: _TabletSizes.controlSpacing),
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
            return const SizedBox(
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
        const SizedBox(width: _TabletSizes.controlSpacing),
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

// ═══════════════════════════════════════════════════════════
// ÖZEL PAINTER - Dönen halka efekti
// ═══════════════════════════════════════════════════════════

class _RingPainter extends CustomPainter {
  final Color color;
  final double progress;

  _RingPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final dashPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Tam daire
    canvas.drawCircle(
      size.center(Offset.zero),
      size.width / 2 - 1,
      paint,
    );

    // İlerleme çizgisi
    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2 - 1),
      -3.14159 / 2,
      2 * 3.14159 * progress,
      false,
      dashPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}