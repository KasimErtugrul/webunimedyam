import 'package:flutter/material.dart';

import '../../../../../app/themes/app_theme.dart';
import '../util/video_section_detail_screen_sizes.dart';

/// Video kartındaki küçük istatistik rozeti (izlenme / etkileşim puanı).
/// Phone/tablet için ayrı sınıf yerine tek widget + `sizes` parametresi.
///
/// NOT: Orijinal kodda `highlight` `bool?` idi ve `highlight!` ile
/// unwrap ediliyordu; `highlight` verilmediği ilk chip çağrısında (izlenme
/// sayısı chip'i) bu satır çalışma anında "Null check operator used on a
/// null value" hatasıyla çökme riski taşıyordu. Görünüm ve davranış aynen
/// korunarak (highlight verilmezse = vurgusuz renk/kalınlık) `bool`
/// + `= false` varsayılanına çevrildi, artık çökme riski yok.
class VideoSectionDetailScreenStatChip extends StatelessWidget {
  const VideoSectionDetailScreenStatChip({
    super.key,
    required this.sizes,
    required this.icon,
    required this.label,
    this.highlight = false,
  });

  final VideoSectionDetailSizes sizes;
  final IconData icon;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color =
        highlight ? AppTheme.primaryColor : AppTheme.textSec(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: sizes.statIconSize, color: color),
        SizedBox(width: sizes.statSpacingSmall),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: sizes.statFontSize,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
