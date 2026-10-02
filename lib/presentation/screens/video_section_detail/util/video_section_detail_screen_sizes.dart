/// Tek ortak sözleşme: phone ve tablet build/card/chip/placeholder/shimmer
/// widget'ları artık "phone mu tablet mi" diye dallanmak yerine bu arayüzü
/// implemente eden bir `VideoSectionDetailSizes` alır.
///
/// Böylece widget kodu TEK bir yerde yazılır (kod tekrarı kalkar),
/// sadece değerler (ve phone tarafındaki screenutil ölçeklemesi) platforma
/// göre değişir.
abstract class VideoSectionDetailSizes {
  const VideoSectionDetailSizes();

  /// WEB ölçeği bayrağı — yalnızca VideoSectionDetailWebSizes true döner.
  bool get isWeb => false;

  // AppBar
  double get appBarIconSize;
  double get appBarTitleSize;

  // Card
  double get cardMarginHorizontal;
  double get cardMarginVertical;
  double get cardPadding;
  double get cardBorderRadius;

  // Thumbnail
  double get thumbnailWidth;
  double get thumbnailHeight;
  double get thumbnailBorderRadius;
  double get thumbnailIconSize;
  double get thumbnailSpacing;

  // Duration badge
  double get durationBadgeBottom;
  double get durationBadgeRight;
  double get durationBadgePaddingHorizontal;
  double get durationBadgePaddingVertical;
  double get durationBadgeBorderRadius;
  double get durationBadgeFontSize;

  // Meta
  double get titleFontSize;
  double get titleLineHeight;
  double get titleSpacing;
  double get channelFontSize;
  double get statSpacing;
  double get statRunSpacing;
  double get statIconSize;
  double get statFontSize;
  double get statSpacingSmall;
  double get dateFontSize;
  double get metaSpacing;

  // Footer
  double get footerPaddingVertical;
  double get footerLoaderWidth;
  double get footerLoaderHeight;
  double get footerLoaderStrokeWidth;
  double get footerTextFontSize;

  // List
  double get listVerticalPadding;

  /// "Sona X piksel kala bir sonraki sayfayı yükle" eşiği.
  /// Eskiden build_phone/build_tablet içine gömülü sabitlerdi (200 / 300),
  /// artık tekilleştirilmiş build widget'ının parametresi.
  double get scrollLoadThreshold;
}

/// Eski `VideoSectionDetailScreenPhoneSizes` ile birebir aynı değerler,
/// aynı screenutil (///) ölçeklemesiyle — görsel çıktı değişmedi.
class VideoSectionDetailPhoneSizes extends VideoSectionDetailSizes {
  const VideoSectionDetailPhoneSizes();

  @override
  double get appBarIconSize => 24;
  @override
  double get appBarTitleSize => 17;

  @override
  double get cardMarginHorizontal => 14;
  @override
  double get cardMarginVertical => 5;
  @override
  double get cardPadding => 10;
  @override
  double get cardBorderRadius => 12;

  @override
  double get thumbnailWidth => 120;
  @override
  double get thumbnailHeight => 80;
  @override
  double get thumbnailBorderRadius => 8;
  @override
  double get thumbnailIconSize => 28;
  @override
  double get thumbnailSpacing => 10;

  @override
  double get durationBadgeBottom => 4;
  @override
  double get durationBadgeRight => 4;
  @override
  double get durationBadgePaddingHorizontal => 4;
  @override
  double get durationBadgePaddingVertical => 2;
  @override
  double get durationBadgeBorderRadius => 3;
  @override
  double get durationBadgeFontSize => 9;

  @override
  double get titleFontSize => 13;
  @override
  double get titleLineHeight => 1.35;
  @override
  double get titleSpacing => 4;
  @override
  double get channelFontSize => 11;
  @override
  double get statSpacing => 8;
  @override
  double get statRunSpacing => 2;
  @override
  double get statIconSize => 10;
  @override
  double get statFontSize => 10;
  @override
  double get statSpacingSmall => 2;
  @override
  double get dateFontSize => 10;
  @override
  double get metaSpacing => 6;

  @override
  double get footerPaddingVertical => 20;
  @override
  double get footerLoaderWidth => 24;
  @override
  double get footerLoaderHeight => 24;
  @override
  double get footerLoaderStrokeWidth => 2.5;
  @override
  double get footerTextFontSize => 13;

  @override
  double get listVerticalPadding => 8;

  @override
  double get scrollLoadThreshold => 200;
}

/// Eski `VideoSectionDetailScreenTabletSizes` ile birebir aynı ham (dp)
/// değerler — screenutil ölçeklemesi yok, aynen öncekindeki gibi.
class VideoSectionDetailTabletSizes extends VideoSectionDetailSizes {
  const VideoSectionDetailTabletSizes();

  @override
  double get appBarIconSize => 28;
  @override
  double get appBarTitleSize => 20;

  @override
  double get cardMarginHorizontal => 20;
  @override
  double get cardMarginVertical => 8;
  @override
  double get cardPadding => 14;
  @override
  double get cardBorderRadius => 14;

  @override
  double get thumbnailWidth => 160;
  @override
  double get thumbnailHeight => 100;
  @override
  double get thumbnailBorderRadius => 10;
  @override
  double get thumbnailIconSize => 34;
  @override
  double get thumbnailSpacing => 14;

  @override
  double get durationBadgeBottom => 6;
  @override
  double get durationBadgeRight => 6;
  @override
  double get durationBadgePaddingHorizontal => 6;
  @override
  double get durationBadgePaddingVertical => 3;
  @override
  double get durationBadgeBorderRadius => 4;
  @override
  double get durationBadgeFontSize => 11;

  @override
  double get titleFontSize => 16;
  @override
  double get titleLineHeight => 1.4;
  @override
  double get titleSpacing => 6;
  @override
  double get channelFontSize => 13;
  @override
  double get statSpacing => 10;
  @override
  double get statRunSpacing => 3;
  @override
  double get statIconSize => 12;
  @override
  double get statFontSize => 12;
  @override
  double get statSpacingSmall => 3;
  @override
  double get dateFontSize => 12;
  @override
  double get metaSpacing => 8;

  @override
  double get footerPaddingVertical => 24;
  @override
  double get footerLoaderWidth => 30;
  @override
  double get footerLoaderHeight => 30;
  @override
  double get footerLoaderStrokeWidth => 3;
  @override
  double get footerTextFontSize => 15;

  @override
  double get listVerticalPadding => 12;

  @override
  double get scrollLoadThreshold => 300;
}

/// WEB (masaüstü tarayıcı, ≥1024px) ölçek katmanı.
/// Tablet ölçülerini temel alır; kart genişliği ızgara zaten
/// max-w-[1140px] ile sınırlandığı için yalnızca kart tipografisi ve
/// thumbnail'i masaüstü yoğunluğuna göre büyütür.
class VideoSectionDetailWebSizes extends VideoSectionDetailTabletSizes {
  const VideoSectionDetailWebSizes();

  @override
  bool get isWeb => true;

  @override
  double get appBarTitleSize => 21;
  @override
  double get thumbnailWidth => 200;
  @override
  double get thumbnailHeight => 112;
}
