// lib/presentation/screens/home/tabs/home_tab/widgets/home_campus_radio_panel_widget.dart
//
// Tasarımdaki sağdaki zengin "Kampüs FM" radyo kartının tablet/geniş
// ekran karşılığı. Ana sayfadaki mevcut küçük "Kampüs FM Canlı" pili
// (bkz. home_tab_widget.dart -> _buildUtilityBar) KALDIRILMADI — telefon
// düzeninde ve tablette de aynı şekilde durmaya devam ediyor. Bu panel
// ona bir alternatif/ikame değil, tasarımda görülüp Flutter'da hiç
// karşılığı olmayan EK bir parça.
//
// Gerçek radyo state'i: RadioPageController örneği oluşturmadan,
// RadioPlayer paketinin STATİK stream'lerini (playbackStateStream,
// metadataStream) doğrudan dinliyoruz. Böylece:
//   - RadioPage'in kendi Binding/lifecycle'ıyla çakışma (iki ayrı
//     controller aynı anda register edilmeye çalışılması) YOK.
//   - Kullanıcı zaten bir yayın dinliyorsa (başka bir ekrandan başlatmış
//     olsa bile) bu panel onu olduğu gibi yansıtır.
//   - Kullanıcı bu panelden oynat/duraklat/istasyon değiştir yapabilir;
//     RadioPlayer native tarafta zaten global/singleton olduğu için bu
//     etkileşim tam Radyo sayfasını (/radio) hiç açmadan çalışır.
//
// BİLİNÇLİ SADELEŞTİRME: Tasarımdaki istasyon <select> dropdown'u
// birebir kopyalanmadı. Tüm istasyon listesini burada da (arama,
// vurgulama, "şu an çalıyor" göstergesi vb. ile) yeniden inşa etmek,
// zaten var olan RadioPage'deki (radio_page.dart) aynı mantığı ikinci
// kez yazmak anlamına gelirdi. Onun yerine "Tüm Radyoları Keşfet"
// butonuyla doğrudan o sayfaya yönlendiriyoruz.
//
// YÜKSEKLİK UYARLANIRLIĞI: Tablet hero satırında panel, SOL kolonla
// (carousel + noktalar; varsa canlı banner) aynı yüksekliğe yayılır.
//   - Yer varsa (>= 430px): ZENGİN düzen — kapak alanı kalan yeri doldurur.
//   - Yer azsa: KOMPAKT mini-player düzeni — kapak yok, öğeler dikeyde
//     yayılır. Böylece panel asla satırdan uzun kalmaz, carousel'in
//     altında boşluk kalmaz.
//   - Yükseklik kısıtsızsa: eski davranış (kare AspectRatio kapak).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radio_player/radio_player.dart';

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../data/models/university_model.dart';
import '../../../../../controllers/home/home_controller.dart';

class HomeCampusRadioPanelWidget extends StatefulWidget {
  const HomeCampusRadioPanelWidget({super.key});

  @override
  State<HomeCampusRadioPanelWidget> createState() =>
      _HomeCampusRadioPanelWidgetState();
}

class _HomeCampusRadioPanelWidgetState
    extends State<HomeCampusRadioPanelWidget>
    with SingleTickerProviderStateMixin {
  // Kapak alanının "zengin" düzene geçmesi için gereken asgari yükseklik:
  // sabit parçalar (~267px) + makul bir kapak (~160px).
  static const double _richModeMinHeight = 430;

  PlaybackState _state = PlaybackState.unknown;
  Metadata? _metadata;
  UniversityModel? _station;

  StreamSubscription<PlaybackState>? _stateSub;
  StreamSubscription<Metadata>? _metaSub;

  late final AnimationController _barsController;

  @override
  void initState() {
    super.initState();
    _barsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();

    _stateSub = RadioPlayer.playbackStateStream.listen((s) {
      if (mounted) setState(() => _state = s);
    });
    _metaSub = RadioPlayer.metadataStream.listen((m) {
      if (mounted) setState(() => _metadata = m);
    });
  }

  @override
  void dispose() {
    // NOT: RadioPlayer.pause()/stop() kasıtlı olarak ÇAĞRILMIYOR — bu
    // panel yalnızca bir "önizleme" widget'ı. Ana sayfa IndexedStack
    // içinde canlı tutulduğu için bu dispose zaten sadece uygulama
    // kapanışında tetiklenir; ama yine de dinlerken yayının kesilmemesi
    // ilkesine burada da sadık kalıyoruz.
    _stateSub?.cancel();
    _metaSub?.cancel();
    _barsController.dispose();
    super.dispose();
  }

  List<UniversityModel> _stationsFrom(HomeController controller) {
    return controller.universities
        .where((u) => u.radioLink != null && u.radioLink!.isNotEmpty)
        .toList();
  }

  void _playStation(UniversityModel uni) {
    setState(() => _station = uni);
    RadioPlayer.setStation(
      title: uni.name ?? 'Kampüs Radyosu',
      url: uni.radioLink!,
      logoNetworkUrl: uni.logoUrl,
      parseStreamMetadata: true,
    );
    RadioPlayer.play();
  }

  void _togglePlayPause(List<UniversityModel> stations) {
    final active =
        _state == PlaybackState.playing || _state == PlaybackState.buffering;
    if (active) {
      RadioPlayer.pause();
      return;
    }
    if (_station != null) {
      RadioPlayer.play();
    } else if (stations.isNotEmpty) {
      _playStation(stations.first);
    }
  }

  void _shiftStation(List<UniversityModel> stations, int delta) {
    if (stations.isEmpty) return;
    final currentIdx = _station == null
        ? -1
        : stations.indexWhere((u) => u.id == _station!.id);
    var nextIdx = (currentIdx + delta) % stations.length;
    if (nextIdx < 0) nextIdx += stations.length;
    _playStation(stations[nextIdx]);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    // LayoutBuilder, hero satırının panel'e ayırdığı gerçek yüksekliği
    // verir; Obx ise radyo state'ine tepki verir.
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxH = constraints.maxHeight;
        final bool bounded = maxH.isFinite;
        final bool rich = bounded && maxH >= _richModeMinHeight;
        final double pad = rich ? 20 : 14;

        return Obx(() {
          final scheme = Theme.of(context).colorScheme;
          final stations = _stationsFrom(controller);
          final playing = _state == PlaybackState.playing;
          final buffering = _state == PlaybackState.buffering;
          final active = playing || buffering;

          final title = active
              ? (_metadata?.title?.isNotEmpty == true
                    ? _metadata!.title!
                    : (_station?.name ?? 'Kampüs Radyosu'))
              : (_station?.name ?? 'Kampüs Radyosu');
          final subtitle = active
              ? (_metadata?.artist?.isNotEmpty == true
                    ? _metadata!.artist!
                    : 'Canlı Yayın')
              : (stations.isEmpty
                    ? 'Şu an yayında radyo yok'
                    : 'Dinlemek için oynat\'a bas');

          return Container(
            padding: EdgeInsets.all(pad),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
              // Kompakt düzende öğeler dikeyde yayılır; zengin düzende
              // kalan yeri kapak alanı (Expanded) doldurur.
              mainAxisAlignment: bounded && !rich
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.start,
              children: [
                _headerRow(scheme, playing, compact: !rich || !bounded),
                if (rich) ...[
                  const SizedBox(height: 16),
                  // ── "Kapak" + görselleştirici (kalan yeri doldurur) ────
                  Expanded(
                    child: _albumArtBlock(
                      scheme,
                      playing,
                      clipBorderRadius: 16,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _trackInfoBlock(scheme, title, subtitle),
                  const SizedBox(height: 14),
                  _controlsRow(scheme, stations, playing, buffering),
                  const SizedBox(height: 10),
                  _exploreButton(scheme),
                ] else if (bounded) ...[
                  // ── KOMPAKT mini-player: kapak yok, dikeyde yayılır ────
                  _trackInfoBlock(scheme, title, subtitle),
                  _controlsRow(
                    scheme,
                    stations,
                    playing,
                    buffering,
                    compact: true,
                  ),
                  _exploreButton(scheme, compact: true),
                ] else ...[
                  // ── Yükseklik kısıtsız (güvenli yol): eski kare kapak ──
                  const SizedBox(height: 16),
                  AspectRatio(
                    aspectRatio: 1,
                    child: _albumArtBlock(
                      scheme,
                      playing,
                      clipBorderRadius: 16,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _trackInfoBlock(scheme, title, subtitle),
                  const SizedBox(height: 14),
                  _controlsRow(scheme, stations, playing, buffering),
                  const SizedBox(height: 10),
                  _exploreButton(scheme),
                ],
              ],
            ),
          );
        });
      },
    );
  }

  // ─── Bölüm parçaları ────────────────────────────────────────────────────

  Widget _headerRow(ColorScheme scheme, bool playing, {required bool compact}) {
    final double iconBox = compact ? 32 : 36;
    final double iconSize = compact ? 18 : 20;
    final double titleFont = compact ? 15 : 17;

    return Row(
      children: [
        Container(
          width: iconBox,
          height: iconBox,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.radio_rounded,
            color: scheme.primary,
            size: iconSize,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kampüs FM',
                style: TextStyle(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w800,
                  fontSize: titleFont,
                ),
              ),
              Text(
                'Canlı Frekans Yayını',
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
        if (playing)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'YAYINDA',
              style: TextStyle(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }

  // Kapak alanı: Expanded (zengin) ya da AspectRatio (kısıtsız) içinde
  // kullanılır; içi aynı — ikon + canlı görselleştirici çubukları.
  Widget _albumArtBlock(
    ColorScheme scheme,
    bool playing, {
    required double clipBorderRadius,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(clipBorderRadius),
      child: Container(
        color: scheme.surfaceContainerLowest,
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.graphic_eq_rounded,
                color: scheme.primary.withValues(alpha: 0.30),
                size: 72,
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AnimatedBuilder(
                  animation: _barsController,
                  builder: (context, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(10, (i) {
                        final seed = (i * 37 + 13) % 100 / 100.0;
                        final t = playing
                            ? (0.25 +
                                  0.75 *
                                      ((_barsController.value + seed) % 1.0))
                            : 0.15;
                        return Container(
                          width: 3,
                          height: 20 * t,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _trackInfoBlock(
    ColorScheme scheme,
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: scheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12.5),
        ),
      ],
    );
  }

  Widget _controlsRow(
    ColorScheme scheme,
    List<UniversityModel> stations,
    bool playing,
    bool buffering, {
    bool compact = false,
  }) {
    final double playSize = compact ? 44 : 52;
    final double playIcon = compact ? 24 : 28;
    final double skipIcon = compact ? 22 : 26;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: stations.isEmpty
              ? null
              : () => _shiftStation(stations, -1),
          icon: const Icon(Icons.skip_previous_rounded),
          color: scheme.onSurfaceVariant,
          iconSize: skipIcon,
        ),
        const SizedBox(width: 6),
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: stations.isEmpty
              ? null
              : () => _togglePlayPause(stations),
          child: Container(
            width: playSize,
            height: playSize,
            decoration: BoxDecoration(
              color: stations.isEmpty
                  ? scheme.primary.withValues(alpha: 0.4)
                  : scheme.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: buffering
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: scheme.onPrimary,
                    ),
                  )
                : Icon(
                    playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: scheme.onPrimary,
                    size: playIcon,
                  ),
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          onPressed: stations.isEmpty
              ? null
              : () => _shiftStation(stations, 1),
          icon: const Icon(Icons.skip_next_rounded),
          color: scheme.onSurfaceVariant,
          iconSize: skipIcon,
        ),
      ],
    );
  }

  Widget _exploreButton(ColorScheme scheme, {bool compact = false}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => Get.toNamed(AppRoutes.radio),
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.4)),
          padding: EdgeInsets.symmetric(vertical: compact ? 9 : 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: const Icon(Icons.queue_music_rounded, size: 18),
        label: const Text(
          'Tüm Radyoları Keşfet',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }
}
