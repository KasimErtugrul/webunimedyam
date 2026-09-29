// lib/presentation/screens/auth/terms_screen/terms_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';

/// Metin ekranı tipi: kullanım koşulları ya da gizlilik politikası.
enum TermsScreenType { terms, privacy }

// ═══════════════════════════════════════════════════════════
// LEGAL DOCUMENT SCREEN — Kayıt akışındaki onay kutusundan
// açılan Kullanım Koşulları / Gizlilik Politikası sayfası.
// "Okudum, Anladım" true sonucuyla geri döner (kayıt ekranı onay
// kutusunu otomatik işaretler); "İptal" ya da geri ok false/null
// döner ve onay kutusu işaretsiz kalır.
//
// NOT: Metinler bilgilendirme amaçlı hazırlanmış yer tutuculardır;
// yayına almadan önce hukuki olarak gözden geçirilmelidir.
// ═══════════════════════════════════════════════════════════

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key, required this.type});

  final TermsScreenType type;

  bool get _isTerms => type == TermsScreenType.terms;

  String get _title => _isTerms ? 'Kullanım Koşulları' : 'Gizlilik Politikası';

  String get _intro => _isTerms
      ? 'ÜniTV\'yi kullandığın için teşekkürler! Aşağıdaki koşullar, '
          'uygulamamızı kullanımını ve hesabını yöneten temel kuralları '
          'özetler. Kayıt olarak bu koşulları kabul etmiş olursun.'
      : 'Gizliliğin bizim için önemli. Bu politika, ÜniTV\'yi kullanırken '
          'hangi verileri işlediğimizi, ne için işlediğimizi ve haklarının '
          'neler olduğunu açıklar.';

  static const List<({String title, String body})> _termsSections = [
    (
      title: '1. Hizmetin Kapsamı',
      body:
          'ÜniTV; Türkiye\'deki üniversitelerin resmî YouTube kanallarında '
          'yayımlanan videoları, canlı yayınları ve Shorts içeriklerini '
          'toplayıp tek bir uygulamada sunan bir içerik keşif hizmetidir. '
          'İçeriklerin kaynağı ilgili üniversitelerin kanallarıdır.',
    ),
    (
      title: '2. Hesap ve Güvenlik',
      body:
          'Kayıt sırasında verdiğin bilgilerin doğru ve güncel olmasından '
          'sorumlusun. Şifreni üçüncü kişilerle paylaşma; hesabın üzerinden '
          'yapılan işlemlerden sorumlu tutulursun. Hesabının ele geçirildiğini '
          'düşünüyorsan hemen şifreni değiştir.',
    ),
    (
      title: '3. Kullanıcı Adı Kuralları',
      body:
          'Kullanıcı adın yalnızca küçük İngilizce harfler, rakamlar ve alt '
          'çizgi (_) içerebilir; boşluk ve özel karakter kullanılamaz. '
          'Başkalarını taklit eden, hakaret veya müstehcen içerik barındıran '
          'kullanıcı adları uyarı yapılmadan askıya alınabilir.',
    ),
    (
      title: '4. İçerik ve Telif Hakları',
      body:
          'Uygulamada görünen tüm videolar ilgili üniversitelere ve içerik '
          'sahiplerine aittir. ÜniTV bu içeriklerin sahibi değildir; içerikler '
          'kaynak kanallardan görüntülenir. Telif hakkı taleplerinde ilgili '
          'içerik sahibiyle iletişime geçilmesi esastır.',
    ),
    (
      title: '5. Kullanım Kuralları',
      body:
          'Hizmeti kötüye kullanma: otomatik veri toplama (scraping), '
          'hizmetin çalışmasını aksatma, diğer kullanıcıların deneyimini '
          'bozma, yasak içerik paylaşma ve uygulamanın tersine mühendisliği '
          'girişimleri yasaktır. Bu kurallara uymayan hesaplar askıya alınabilir.',
    ),
    (
      title: '6. Yorumlar ve Topluluk',
      body:
          'Yorumlarında ve etkileşimlerinde diğer kullanıcılara saygılı ol. '
          'Nefret söylemi, taciz, kişisel veri paylaşımı veya yasa dışı '
          'içerik, önceden uyarı yapılmadan kaldırılabilir ve hesabın '
          'kısıtlanabilir.',
    ),
    (
      title: '7. Hizmette Değişiklikler',
      body:
          'ÜniTV\'yi sürekli geliştiriyoruz; özellikler zaman içinde '
          'değişebilir veya bazıları durdurulabilir. Bu koşullar da '
          'güncellenebilir; önemli değişikliklerde uygulama içinde seni '
          'bilgilendiririz.',
    ),
    (
      title: '8. Sorumluluğun Sınırlanması',
      body:
          'Hizmet "olduğu gibi" sunulur. Üçüncü taraf platformlardaki '
          '(YouTube vb.) içerik değişiklikleri, kaldırılmalar veya erişim '
          'kesintilerinden ÜniTV sorumlu tutulamaz.',
    ),
  ];

  static const List<({String title, String body})> _privacySections = [
    (
      title: '1. Topladığımız Veriler',
      body:
          'Hesap oluştururken e-posta adresin, kullanıcı adın ve şifrenin '
          'şifrelenmiş hâli saklanır. Ayrıca deneyimini kişiselleştirmek için '
          'uygulama içi etkileşimlerin (favoriler, takipler, yorumlar, izleme '
          'geçmişi) işlenir.',
    ),
    (
      title: '2. Verileri Kullanma Amacımız',
      body:
          'Verilerin yalnızca hesabının işletilmesi, sana özel içerik '
          'önerileri sunulması, bildirimlerin gönderilmesi ve hizmetin '
          'güvenliğinin sağlanması için kullanılır. Bu amaçlar dışında '
          'üçüncü taraflara satılmaz.',
    ),
    (
      title: '3. Üçüncü Taraflar',
      body:
          'Video içerikleri üniversitelerin YouTube kanallarından sağlanır; '
          'kimlik doğrulama ve veritabanı gibi altyapı hizmetleri için '
          'güvenlik önlemlerine sahip üçüncü taraf sağlayıcılarla çalışılır. '
          'Bu paylaşımlar yalnızca hizmetin çalışması için gerektiği kadardır.',
    ),
    (
      title: '4. Anonim Kullanım İstatistikleri',
      body:
          'Uygulamayı geliştirmek için anonim kullanım istatistikleri '
          'toplanabilir. Bu veriler seni kişi olarak tanımlamaz.',
    ),
    (
      title: '5. Veri Güvenliği',
      body:
          'Verilerin endüstri standardı güvenlik önlemleriyle korunur. Yine '
          'de internet üzerinden hiçbir veri aktarımının yüzde yüz güvenli '
          'olmadığını unutma.',
    ),
    (
      title: '6. Hakların',
      body:
          'Kayıtlı verilerine erişme, düzeltme ve silinmesini talep etme '
          'hakkın vardır. Hesabını sildiğinde kişisel verilerin mevzuata '
          'uygun şekilde silinir veya anonimleştirilir.',
    ),
    (
      title: '7. Politika Güncellemeleri',
      body:
          'Bu politika zaman zaman güncellenebilir. Önemli değişikliklerde '
          'uygulama içinde seni bilgilendiririz; güncel sürüm her zaman '
          'uygulama içinden erişilebilirdir.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isTablet = Responsive.isTablet(context);
    final double hPad = isTablet ? 32 : 20;
    final double titleFontSize = isTablet ? 26 : 22;
    final double sectionTitleFontSize = isTablet ? 16 : 14.5;
    final double bodyFontSize = isTablet ? 15 : 13.5;
    final sections = _isTerms ? _termsSections : _privacySections;

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            // ── Üst bar: geri + başlık ─────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 4),
              child: Row(
                children: [
                  Material(
                    color: scheme.surfaceContainer,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: Get.back,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 18,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.02 * titleFontSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Metin içeriği ──────────────────────────────
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _intro,
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: bodyFontSize,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 16),
                        for (final section in sections) ...[
                          _SectionCard(
                            title: section.title,
                            body: section.body,
                            titleFontSize: sectionTitleFontSize,
                            bodyFontSize: bodyFontSize,
                          ),
                          const SizedBox(height: 12),
                        ],
                        Text(
                          'Son güncelleme: Eylül 2026',
                          style: TextStyle(
                            color: scheme.outline,
                            fontSize: bodyFontSize - 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Alt butonlar: İptal + Okudum, Anladım ───────
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Row(
                    children: [
                      // İptal — onaysız geri döner, tik atanmaz.
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () => Get.back(result: false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scheme.surfaceContainer,
                              foregroundColor: scheme.onSurface,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'İptal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Okudum, Anladım — true sonucuyla geri döner →
                      // kayıt ekranında onay kutusu otomatik işaretlenir.
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () => Get.back(result: true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scheme.primary,
                              foregroundColor: scheme.onPrimary,
                              elevation: 4,
                              shadowColor:
                                  scheme.primary.withValues(alpha: 0.20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Okudum, Anladım',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.body,
    required this.titleFontSize,
    required this.bodyFontSize,
  });

  final String title;
  final String body;
  final double titleFontSize;
  final double bodyFontSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: titleFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: bodyFontSize,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
