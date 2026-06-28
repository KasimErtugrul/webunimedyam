import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:radio_player/radio_player.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/university_model.dart';
import '../../../controllers/radio_page_controller.dart';
import 'radio_control_button_widget.dart';
import 'radio_fallback_logo_widget.dart';
import 'radio_play_button_widget.dart';
import 'radio_wave_row_widget.dart';

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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Obx(() {
                final playing =
                    ctrl.playbackState.value == PlaybackState.playing;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 160.r,
                  height: 160.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: playing
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                      width: 2.r,
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
                width: 140.r,
                height: 140.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.surface(context),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: .2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: .15),
                      blurRadius: 20.r,
                      spreadRadius: 5.r,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: uni.logoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: uni.logoUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              RadioFallbackLogoWidget(uni: uni),
                        )
                      : RadioFallbackLogoWidget(uni: uni),
                ),
              ),
              // ÖNEMLİ: RadioVisualizer artık `isActive`'e göre ağaçtan
              // tamamen kaldırılıp eklenmiyor (önceden if (isActive) ... idi).
              // PageView'da hızlı swipe yapıldığında bu widget sürekli
              // dispose/yeniden oluşturuluyordu; radio_player paketinin
              // native FFT stream callback'i tam o anda elinde tuttuğu
              // Element zaten "defunct" olmuş haldeyken setState çağırmaya
              // çalışınca framework "_lifecycleState != defunct" assertion
              // hatası fırlatıyordu.
              //
              // Çözüm: Visibility(maintainState: true) ile widget'ı HER
              // ZAMAN ağaçta canlı tutuyoruz, sadece görünürlüğünü
              // açıp/kapatıyoruz. Böylece native stream bağlantısı kesintiye
              // uğramıyor, dispose/recreate döngüsü oluşmuyor.
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
                            children: data.take(12).map((value) {
                              final height = (value / 255) * 60.r;
                              return Container(
                                width: 3.w,
                                height: height,
                                margin:
                                    EdgeInsets.symmetric(horizontal: 1.5.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .6),
                                  borderRadius: BorderRadius.circular(2.r),
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
          ),

          SizedBox(height: 28.h),

          Text(
            uni.name!,
            style: TextStyle(
              color: AppTheme.textPri(context),
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 8.h),

          Obx(() {
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
              duration: const Duration(milliseconds: 300),
              child: Text(
                text,
                key: ValueKey(text),
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: 13.sp,
                  fontStyle: text == 'Dinliyorsunuz'
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),

          SizedBox(height: 36.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RadioControlButtonWidget(
                icon: Icons.skip_previous_rounded,
                onTap: () {
                  if (isActive) ctrl.previousStation();
                },
                enabled: isActive,
              ),
              SizedBox(width: 20.w),
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
                    width: 64.r,
                    height: 64.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppTheme.primaryColor,
                    ),
                  );
                }
                return RadioPlayButtonWidget(
                  icon:
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
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
              SizedBox(width: 20.w),
              RadioControlButtonWidget(
                icon: Icons.skip_next_rounded,
                onTap: () {
                  if (isActive) ctrl.nextStation();
                },
                enabled: isActive,
              ),
            ],
          ),

          SizedBox(height: 16.h),

          Obx(() {
            final playing = ctrl.playbackState.value == PlaybackState.playing;
            return RadioWaveRowWidget(isActive: isActive && playing);
          }),
        ],
      ),
    );
  }
}