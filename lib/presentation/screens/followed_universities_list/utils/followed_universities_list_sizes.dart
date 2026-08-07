// ═══════════════════════════════════════════════════════════
// ABSTRACT SIZES CONTRACT (TEK ORTAK SÖZLEŞME)
// ═══════════════════════════════════════════════════════════

import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class FollowedUniversitiesListSizes {
  const FollowedUniversitiesListSizes();

  bool get isTablet;

  // Loading
  double get loadingStrokeWidth;

  // Empty
  double get emptyPaddingHorizontal;
  double get emptyIconSize;
  double get emptySpacingLarge;
  double get emptySpacingSmall;
  double get emptyTitleFontSize;
  double get emptySubtitleFontSize;

  // List
  double get listPaddingHorizontal;
  double get listPaddingVertical;
  double get listCardBottomMargin;
  double get listCardPaddingHorizontal;
  double get listCardPaddingVertical;
  double get listCardBorderRadius;
  double get listLogoSize;
  double get listLogoBorderRadius;
  double get listLogoSpacing;
  double get listTitleFontSize;
  double get listCityIconSize;
  double get listCityFontSize;
  double get listCitySpacing;
  double get listCityTopSpacing;
  double get listChevronSize;
  double get listPlaceholderIconSize;
}

// ═══════════════════════════════════════════════════════════
// PHONE SIZES (ScreenUtil ile ölçekli)
// ═══════════════════════════════════════════════════════════

class FollowedUniversitiesListPhoneSizes extends FollowedUniversitiesListSizes {
  const FollowedUniversitiesListPhoneSizes();

  @override bool get isTablet => false;

  @override double get loadingStrokeWidth => 3.w;

  @override double get emptyPaddingHorizontal => 32.w;
  @override double get emptyIconSize => 56.sp;
  @override double get emptySpacingLarge => 16.h;
  @override double get emptySpacingSmall => 6.h;
  @override double get emptyTitleFontSize => 16.sp;
  @override double get emptySubtitleFontSize => 13.sp;

  @override double get listPaddingHorizontal => 14.w;
  @override double get listPaddingVertical => 12.h;
  @override double get listCardBottomMargin => 10.h;
  @override double get listCardPaddingHorizontal => 12.w;
  @override double get listCardPaddingVertical => 10.h;
  @override double get listCardBorderRadius => 12.r;
  @override double get listLogoSize => 52.w;
  @override double get listLogoBorderRadius => 8.r;
  @override double get listLogoSpacing => 12.w;
  @override double get listTitleFontSize => 14.sp;
  @override double get listCityIconSize => 13.sp;
  @override double get listCityFontSize => 12.sp;
  @override double get listCitySpacing => 3.w;
  @override double get listCityTopSpacing => 4.h;
  @override double get listChevronSize => 20.sp;
  @override double get listPlaceholderIconSize => 28.sp;
}

// ═══════════════════════════════════════════════════════════
// TABLET SIZES (ham dp)
// ═══════════════════════════════════════════════════════════

class FollowedUniversitiesListTabletSizes extends FollowedUniversitiesListSizes {
  const FollowedUniversitiesListTabletSizes();

  @override bool get isTablet => true;

  @override double get loadingStrokeWidth => 3.5;

  @override double get emptyPaddingHorizontal => 40;
  @override double get emptyIconSize => 64;
  @override double get emptySpacingLarge => 20;
  @override double get emptySpacingSmall => 8;
  @override double get emptyTitleFontSize => 20;
  @override double get emptySubtitleFontSize => 15;

  @override double get listPaddingHorizontal => 20;
  @override double get listPaddingVertical => 16;
  @override double get listCardBottomMargin => 12;
  @override double get listCardPaddingHorizontal => 16;
  @override double get listCardPaddingVertical => 14;
  @override double get listCardBorderRadius => 14;
  @override double get listLogoSize => 60;
  @override double get listLogoBorderRadius => 10;
  @override double get listLogoSpacing => 14;
  @override double get listTitleFontSize => 16;
  @override double get listCityIconSize => 15;
  @override double get listCityFontSize => 14;
  @override double get listCitySpacing => 4;
  @override double get listCityTopSpacing => 5;
  @override double get listChevronSize => 24;
  @override double get listPlaceholderIconSize => 32;
}
