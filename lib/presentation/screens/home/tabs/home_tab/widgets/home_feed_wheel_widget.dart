// lib/presentation/screens/home/tabs/home_tab/widgets/home_feed_wheel_widget.dart
//
// Ana sayfadaki (HomeTabWidget) mevcut video listesini ("üniversitelerin
// son videoları") BOZMADAN, alternatif bir görünüm olarak sunar:
// SAĞDA üniversite logolarından oluşan bir wheel slider, SOLDA ise o anda
// ortada/aktif olan logonun videosu (wheel'e özel kompakt kart).
//
// ÖNEMLİ — NEDEN wheel_slider PAKETİ KULLANILMIYOR:
// `wheel_slider` paketi, dikey modda aslında `wheel_chooser` paketine
// sarmalanıyor ve o paket `ListWheelScrollView`'i HER ZAMAN
// `useMagnifier: true` ile (kapatma seçeneği olmadan) çağırıyor. Bu, tam
// ortadaki (aktif) öğeyi Flutter'ın "magnifier" katmanı üzerinden AYRICA
// bir kez daha çiziyor; bizim CachedNetworkImage'ımız bu ikinci/paralel
// çizim geçişinde düzgün render olmuyor ve aktif logonun görünmemesine yol
// açıyordu (küçük/pasif öğeler bu ikinci katmana girmediği için sorunsuz
// görünüyordu). Kaynağı inceleyip doğruladık:
// https://github.com/srinivasa-dev/wheel_slider
// https://github.com/Innim/Flutter-WheelChooser
//
// Çözüm: Flutter'ın kendi `ListWheelScrollView`'ini DOĞRUDAN, kendi
// `FixedExtentScrollController`'ımızla kullanıyoruz ve `useMagnifier`'ı
// KAPALI bırakıyoruz — böylece aktif öğe de diğerleri gibi tek bir
// normal çizim geçişinden geçiyor ve logo sorunsuz görünüyor. Ayrıca
// wheel artık daha DAR bir alanda (ekranın ~%22'si, öncesinde ~%32'ydi).
//
// PAGINATION: Wheel görünümü kendi sayfalamasını tetikler — kullanıcı
// wheel'i sona doğru çevirdikçe (son birkaç öğeye yaklaşınca) otomatik
// olarak HomeController.loadMoreVideos() çağrılır; tıpkı listview'daki
// scroll-tabanlı sayfalama gibi.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../data/models/university_model.dart';
import '../../../../../../data/models/video_model.dart';
import '../../../../../controllers/home_controller.dart';
import 'wheel_video_card_widget.dart';

class HomeFeedWheelWidget extends StatefulWidget {
  /// HomeController.videos içinden shorts hariç bırakılmış liste
  /// (her üniversitenin en son videosu).
  final List<VideoModel> videos;

  /// Logo eşleştirmesi için üniversite listesi.
  final List<UniversityModel> universities;

  const HomeFeedWheelWidget({
    super.key,
    required this.videos,
    required this.universities,
  });

  @override
  State<HomeFeedWheelWidget> createState() => _HomeFeedWheelWidgetState();
}

class _HomeFeedWheelWidgetState extends State<HomeFeedWheelWidget> {
  int _activeIndex = 0;
  final HomeController _controller = Get.find<HomeController>();

  /// Son N öğeye yaklaşınca bir sonraki sayfayı çekmeye başla
  /// (listview'daki 400px scroll-buffer mantığının wheel karşılığı).
  static const int _loadMoreThreshold = 3;

  @override
  void initState() {
    super.initState();
    // İlk açılışta videolar zaten kısaysa (ör. tek sayfa henüz doldurmadıysa)
    // sayfalamayı hemen tetikle.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeLoadMore(_activeIndex);
    });
  }

  @override
  void didUpdateWidget(covariant HomeFeedWheelWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Video listesi yenilenip küçüldüyse index'i sınırlar içinde tut.
    if (_activeIndex >= widget.videos.length) {
      _activeIndex = widget.videos.isEmpty ? 0 : widget.videos.length - 1;
    }
  }

  void _maybeLoadMore(int index) {
    final videos = widget.videos;
    if (videos.isEmpty) return;
    if (!_controller.hasMoreVideos.value || _controller.isLoadingMore.value) {
      return;
    }
    final threshold = videos.length - _loadMoreThreshold;
    if (index >= threshold) {
      _controller.loadMoreVideos();
    }
  }

  void _onWheelChanged(int index) {
    setState(() => _activeIndex = index);
    _maybeLoadMore(index);
  }

  UniversityModel? _universityFor(VideoModel video) {
    return widget.universities.firstWhereOrNull(
      (u) => u.id == video.universityId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final videos = widget.videos;
    if (videos.isEmpty) return const SizedBox.shrink();

    final safeIndex = _activeIndex.clamp(0, videos.length - 1);
    final activeVideo = videos[safeIndex];

    return Obx(() {
      final hasMore = _controller.hasMoreVideos.value;
      final isLoadingMore = _controller.isLoadingMore.value;
      final showLoadingTail = hasMore || isLoadingMore;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── SOL: Aktif üniversitenin son videosu (wheel'e özel kart) ──
            Expanded(
              child: SizedBox(
                height: 0.62.sh,
                child: WheelVideoCardWidget(
                  key: ValueKey(activeVideo.videoId),
                  video: activeVideo,
                  university: _universityFor(activeVideo),
                ),
              ),
            ),
            SizedBox(width: 10.w),

            // ── SAĞ: Üniversite logoları wheel'i (dar) ────────────────────
            SizedBox(
              // Daha önce %32 idi — kullanıcı isteğiyle daraltıldı.
              width: 0.22.sw,
              height: 0.62.sh,
              child: _LogoWheel(
                key: ValueKey('logo_wheel_${videos.length}'),
                videos: videos,
                universities: widget.universities,
                activeIndex: safeIndex,
                showLoadingTail: showLoadingTail,
                isLoadingMore: isLoadingMore,
                onChanged: _onWheelChanged,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _LogoWheel extends StatefulWidget {
  final List<VideoModel> videos;
  final List<UniversityModel> universities;
  final int activeIndex;
  final bool showLoadingTail;
  final bool isLoadingMore;
  final ValueChanged<int> onChanged;

  const _LogoWheel({
    super.key,
    required this.videos,
    required this.universities,
    required this.activeIndex,
    required this.showLoadingTail,
    required this.isLoadingMore,
    required this.onChanged,
  });

  @override
  State<_LogoWheel> createState() => _LogoWheelState();
}

class _LogoWheelState extends State<_LogoWheel> {
  // Küçültülmüş wheel için ölçüler (öncesinde 96.h / 72.w / 48.w idi).
  static double get _itemExtent => 68.h;
  static double get _activeSize => 54.w;
  static double get _inactiveSize => 34.w;

  late final FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController(
      initialItem: widget.activeIndex,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  UniversityModel? _universityFor(VideoModel video) {
    return widget.universities.firstWhereOrNull(
      (u) => u.id == video.universityId,
    );
  }

  void _handleSelected(int index) {
    HapticFeedback.selectionClick();
    final videosLength = widget.videos.length;
    widget.onChanged(index >= videosLength ? videosLength - 1 : index);
  }

  @override
  Widget build(BuildContext context) {
    final videos = widget.videos;
    final totalCount = videos.length + (widget.showLoadingTail ? 1 : 0);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Aktif slotu vurgulayan sabit arka plan çerçevesi.
        IgnorePointer(
          child: Container(
            height: _itemExtent,
            margin: EdgeInsets.symmetric(horizontal: 6.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
                width: 1.2,
              ),
            ),
          ),
        ),
        // NOT: useMagnifier BİLİNÇLİ OLARAK false — bkz. dosya başındaki not.
        ListWheelScrollView.useDelegate(
          controller: _scrollController,
          itemExtent: _itemExtent,
          diameterRatio: 1.6,
          perspective: 0.0025,
          squeeze: 1.05,
          physics: const FixedExtentScrollPhysics(),
          useMagnifier: false,
          overAndUnderCenterOpacity: 1,
          onSelectedItemChanged: _handleSelected,
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: totalCount,
            builder: (context, index) {
              if (index >= videos.length) {
                return _LoadingTailItem(isLoadingMore: widget.isLoadingMore);
              }
              final uni = _universityFor(videos[index]);
              return _LogoItem(
                key: ValueKey(uni?.id ?? videos[index].videoId),
                logoUrl: uni?.logoUrl,
                isActive: index == widget.activeIndex,
                activeSize: _activeSize,
                inactiveSize: _inactiveSize,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LoadingTailItem extends StatelessWidget {
  final bool isLoadingMore;

  const _LoadingTailItem({required this.isLoadingMore});

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return Center(
        child: SizedBox(
          width: 22.w,
          height: 22.w,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: AppTheme.primaryColor.withValues(alpha: 0.7),
          ),
        ),
      );
    }
    // Henüz istek atılmadı ama devamı var: sessiz bir ipucu göster.
    return Center(
      child: Icon(
        Icons.more_horiz_rounded,
        color: AppTheme.textSec(context).withValues(alpha: 0.4),
        size: 20.sp,
      ),
    );
  }
}

class _LogoItem extends StatelessWidget {
  final String? logoUrl;
  final bool isActive;
  final double activeSize;
  final double inactiveSize;

  const _LogoItem({
    super.key,
    required this.logoUrl,
    required this.isActive,
    required this.activeSize,
    required this.inactiveSize,
  });

  @override
  Widget build(BuildContext context) {
    final size = isActive ? activeSize : inactiveSize;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isActive ? 1 : 0.45,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.isDark(context)
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFF0F0F0),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
            border: Border.all(
              color: isActive ? AppTheme.primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          padding: EdgeInsets.all(6.w),
          child: ClipOval(
            child: (logoUrl == null || logoUrl!.isEmpty)
                ? Icon(
                    Icons.school_rounded,
                    color: AppTheme.textSec(context),
                    size: (isActive ? activeSize : inactiveSize) * 0.5,
                  )
                : CachedNetworkImage(
                    imageUrl: logoUrl!,
                    fit: BoxFit.contain,
                    fadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                    errorWidget: (_, _, _) => Icon(
                      Icons.school_rounded,
                      color: AppTheme.textSec(context),
                    ),
                    // NOT: SizedBox.shrink() yerine, resim yüklenene kadar
                    // arka planla aynı renkte dolu bir daire gösteriyoruz.
                    // Önceki "şeffaf" placeholder, arkadaki vurgu kutusunun
                    // (özellikle aktif slotta) sızmasına ve logonun "boş/
                    // yeşilimsi kare" gibi görünmesine sebep oluyordu.
                    placeholder: (_, _) => Container(
                      color: AppTheme.isDark(context)
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFF0F0F0),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
