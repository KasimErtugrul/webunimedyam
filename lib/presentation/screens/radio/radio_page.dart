// lib/presentation/screens/radio/radio_page.dart

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:radio_player/radio_player.dart';
import 'package:radio_player/widgets/radio_visualizer.dart';

import '../../../app/themes/app_theme.dart';
import '../../../data/models/university_model.dart';
import '../../../data/datasources/remote/supabase_datasource.dart';

// ─── Controller ──────────────────────────────────────────────────────────────

class RadioPageController extends GetxController {
  final universities = <UniversityModel>[].obs;
  final isLoading = true.obs;

  final Rx<PlaybackState> playbackState = PlaybackState.unknown.obs;
  final Rx<Metadata?> metadata = Rx<Metadata?>(null);
  final Rx<String?> currentUrl = Rx<String?>(null);

  StreamSubscription? _stateSub;
  StreamSubscription? _metaSub;
  StreamSubscription? _remoteCommandSub;

  PageController? pageController;
  int currentIndex = 0;

  @override
  void onInit() {
    super.onInit();
    _stateSub = RadioPlayer.playbackStateStream.listen((s) {
      playbackState.value = s;
    });
    _metaSub = RadioPlayer.metadataStream.listen((m) {
      metadata.value = m;
    });
    _setupRemoteControls();
    _loadRadios();
  }

  Future<void> _loadRadios() async {
    try {
      final ds = Get.find<SupabaseDataSource>();
      final all = await ds.getUniversities(limit: 500);
      universities.value = all
          .where((u) => u.radioLink != null && u.radioLink!.isNotEmpty)
          .toList();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void _setupRemoteControls() {
    RadioPlayer.setNavigationControls(
      showNextButton: true,
      showPreviousButton: true,
    );
    _remoteCommandSub = RadioPlayer.remoteCommandStream.listen((command) {
      if (command == RemoteCommand.nextTrack) {
        nextStation();
      } else if (command == RemoteCommand.previousTrack) {
        previousStation();
      }
    });
  }

  void nextStation() {
    if (universities.isEmpty || pageController == null) return;
    final next = (currentIndex + 1) % universities.length;
    pageController!.animateToPage(
      next,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void previousStation() {
    if (universities.isEmpty || pageController == null) return;
    final prev = (currentIndex - 1) % universities.length;
    pageController!.animateToPage(
      prev,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void playStation(UniversityModel uni) {
    final url = uni.radioLink!;
    if (currentUrl.value == url) return;
    currentUrl.value = url;
    metadata.value = null;
    RadioPlayer.setStation(
      title: uni.name!,
      url: url,
      logoNetworkUrl: uni.logoUrl,
      parseStreamMetadata: true,
    );
    RadioPlayer.play();
  }

  /// Tüm stream'leri iptal et, radyoyu durdur ve state'i sıfırla.
  Future<void> stopEverything() async {
    await _stateSub?.cancel();
    await _metaSub?.cancel();
    await _remoteCommandSub?.cancel();
    _stateSub = null;
    _metaSub = null;
    _remoteCommandSub = null;

    try {
      await RadioPlayer.pause();
    } catch (_) {}
    try {
      RadioPlayer.reset();
    } catch (_) {}

    currentUrl.value = null;
    metadata.value = null;
    playbackState.value = PlaybackState.unknown;
  }

  @override
  void onClose() {
    // onClose senkron çalışır; fire-and-forget yeterli
    stopEverything();
    super.onClose();
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class RadioPage extends StatefulWidget {
  const RadioPage({super.key});

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  late final RadioPageController _ctrl;
  late final PageController _pageCtrl;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(RadioPageController());
    _pageCtrl = PageController();
    _ctrl.pageController = _pageCtrl;

    ever(_ctrl.universities, (list) {
      if (list.isNotEmpty && _ctrl.currentUrl.value == null) {
        _ctrl.playStation(list[0]);
      }
    });
  }

  @override
  void dispose() {
    // Önce radyoyu durdur, sonra controller'ı sil, en son PageController'ı dispose et.
    _ctrl.stopEverything().then((_) {
      // Controller zaten silinmiş olsa da hata vermemesi için force: true
      if (Get.isRegistered<RadioPageController>()) {
        Get.delete<RadioPageController>(force: true);
      }
    });
    // Hemen sil (sync path) — stopEverything async ama radyo zaten susturuldu
    if (Get.isRegistered<RadioPageController>()) {
      Get.delete<RadioPageController>(force: true);
    }
    _pageCtrl.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    _ctrl.currentIndex = index;
    final unis = _ctrl.universities;
    if (index < unis.length) {
      _ctrl.playStation(unis[index]);
    }
  }

  void _showUniversityList() {
    final unis = _ctrl.universities;
    if (unis.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Text(
                    'Tüm Radyolar',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPri(context),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: unis.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1.h,
                      color: AppTheme.isDark(context)
                          ? Colors.grey[800]
                          : Colors.grey[300],
                    ),
                    itemBuilder: (ctx, index) {
                      final uni = unis[index];
                      final isSelected = index == _currentIndex;
                      return ListTile(
                        leading: ClipOval(
                          child: Container(
                            width: 40.r,
                            height: 40.r,
                            color: AppTheme.surface(context),
                            child: uni.logoUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: uni.logoUrl!,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => Icon(
                                      Icons.radio,
                                      color: AppTheme.primaryColor,
                                      size: 20.sp,
                                    ),
                                  )
                                : Icon(
                                    Icons.radio,
                                    color: AppTheme.primaryColor,
                                    size: 20.sp,
                                  ),
                          ),
                        ),
                        title: Text(
                          uni.name!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: isSelected ? FontWeight.w600 : null,
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.textPri(context),
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: AppTheme.primaryColor,
                                size: 20.sp,
                              )
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          _pageCtrl.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Geri tuşuna/gesture'a basılınca önce radyoyu durdur
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _ctrl.stopEverything();
        if (context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: AppTheme.bg(context),
        appBar: AppBar(
          title: Text('Üniversite Radyoları', style: TextStyle(fontSize: 18.sp)),
          centerTitle: true,
          // Geri butonu override — radyoyu durdurarak çık
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await _ctrl.stopEverything();
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.list_rounded, size: 22.sp),
              tooltip: 'Radyo Listesi',
              onPressed: _showUniversityList,
            ),
          ],
        ),
        body: Obx(() {
          if (_ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_ctrl.universities.isEmpty) {
            return Center(
              child: Text(
                'Radyo yayını bulunamadı.',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: 15.sp,
                ),
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  onPageChanged: _onPageChanged,
                  itemCount: _ctrl.universities.length,
                  itemBuilder: (_, i) {
                    final uni = _ctrl.universities[i];
                    return _RadioCard(
                      uni: uni,
                      ctrl: _ctrl,
                      isActive: i == _currentIndex,
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: _DotIndicator(
                  count: _ctrl.universities.length,
                  current: _currentIndex,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chevron_left, size: 18.sp, color: AppTheme.textSec(context)),
                    Text(
                      'kaydırarak radyo değiştir',
                      style: TextStyle(color: AppTheme.textSec(context), fontSize: 12.sp),
                    ),
                    Icon(Icons.chevron_right, size: 18.sp, color: AppTheme.textSec(context)),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ─── Radyo Kartı ─────────────────────────────────────────────────────────────

class _RadioCard extends StatelessWidget {
  final UniversityModel uni;
  final RadioPageController ctrl;
  final bool isActive;

  const _RadioCard({
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
                final playing = ctrl.playbackState.value == PlaybackState.playing;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 160.r,
                  height: 160.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: playing ? AppTheme.primaryColor : Colors.transparent,
                      width: 2.r,
                    ),
                  ),
                  child: playing
                      ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
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
                          errorWidget: (_, __, ___) => _FallbackLogo(uni: uni),
                        )
                      : _FallbackLogo(uni: uni),
                ),
              ),
              if (isActive)
                Positioned.fill(
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
                                margin: EdgeInsets.symmetric(horizontal: 1.5.w),
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
                  fontStyle: text == 'Dinliyorsunuz' ? FontStyle.italic : FontStyle.normal,
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
              _ControlButton(
                icon: Icons.skip_previous_rounded,
                onTap: () { if (isActive) ctrl.previousStation(); },
                enabled: isActive,
              ),
              SizedBox(width: 20.w),
              Obx(() {
                final state = ctrl.playbackState.value;
                final buffering = state == PlaybackState.buffering;
                final playing = state == PlaybackState.playing;

                if (!isActive) {
                  return _PlayButton(
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
                return _PlayButton(
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
              SizedBox(width: 20.w),
              _ControlButton(
                icon: Icons.skip_next_rounded,
                onTap: () { if (isActive) ctrl.nextStation(); },
                enabled: isActive,
              ),
            ],
          ),

          SizedBox(height: 16.h),

          Obx(() {
            final playing = ctrl.playbackState.value == PlaybackState.playing;
            return _WaveRow(isActive: isActive && playing);
          }),
        ],
      ),
    );
  }
}

// ─── Play Butonu ─────────────────────────────────────────────────────────────

class _PlayButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const _PlayButton({required this.icon, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72.r,
        height: 72.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active
              ? AppTheme.primaryColor
              : AppTheme.primaryColor.withValues(alpha: .15),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: .3),
                    blurRadius: 20.r,
                    spreadRadius: 5.r,
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 36.sp,
          color: active ? Colors.white : AppTheme.primaryColor,
        ),
      ),
    );
  }
}

// ─── Önceki / Sonraki Kontrol Butonu ────────────────────────────────────────

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _ControlButton({required this.icon, required this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 48.r,
        height: 48.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? AppTheme.primaryColor.withValues(alpha: .1)
              : AppTheme.primaryColor.withValues(alpha: .05),
        ),
        child: Icon(
          icon,
          size: 28.sp,
          color: enabled ? AppTheme.primaryColor : Colors.grey.shade500,
        ),
      ),
    );
  }
}

// ─── Dalga Animasyonu ────────────────────────────────────────────────────────

class _WaveRow extends StatefulWidget {
  final bool isActive;
  const _WaveRow({required this.isActive});

  @override
  State<_WaveRow> createState() => _WaveRowState();
}

class _WaveRowState extends State<_WaveRow> with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 5; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + i * 80),
      );
      final anim = Tween<double>(begin: 4, end: 22)
          .animate(CurvedAnimation(parent: ctrl, curve: Curves.easeInOut));
      _controllers.add(ctrl);
      _animations.add(anim);
      if (widget.isActive) ctrl.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_WaveRow old) {
    super.didUpdateWidget(old);
    if (widget.isActive != old.isActive) {
      for (final c in _controllers) {
        if (widget.isActive) {
          c.repeat(reverse: true);
        } else {
          c.stop();
          c.animateTo(0);
        }
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28.h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(_controllers.length, (i) {
          return AnimatedBuilder(
            animation: _animations[i],
            builder: (_, __) => Container(
              width: 4.w,
              height: _animations[i].value.h,
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(
                  alpha: widget.isActive ? .8 : .2,
                ),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Dot İndikatör ───────────────────────────────────────────────────────────

class _DotIndicator extends StatelessWidget {
  final int count;
  final int current;
  const _DotIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    final start = (current - 3).clamp(0, (count - 7).clamp(0, count));
    final end = (start + 7).clamp(0, count);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(end - start, (i) {
        final idx = start + i;
        final isActive = idx == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isActive ? 18.w : 6.w,
          height: 6.h,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primaryColor
                : AppTheme.primaryColor.withValues(alpha: .25),
            borderRadius: BorderRadius.circular(3.r),
          ),
        );
      }),
    );
  }
}

// ─── Fallback Logo ────────────────────────────────────────────────────────────

class _FallbackLogo extends StatelessWidget {
  final UniversityModel uni;
  const _FallbackLogo({required this.uni});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryColor.withValues(alpha: .1),
      child: Center(
        child: Text(
          uni.name!.isNotEmpty ? uni.name![0] : '?',
          style: TextStyle(
            fontSize: 40.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}