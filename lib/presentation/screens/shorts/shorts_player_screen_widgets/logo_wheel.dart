// ═══════════════════════════════════════════════════════════
// ÜNİVERSİTE LOGO WHEEL (TEK WIDGET)
// ═══════════════════════════════════════════════════════════

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/shorts_model.dart';
import '../utils/shorts_player_sizes.dart';

class ShortsPlayerUniversityLogoWheel extends StatefulWidget {
  final ShortsPlayerSizes sizes;
  final List<ShortsModel> shorts;
  final int activeIndex;
  final ValueChanged<int> onChanged;

  const ShortsPlayerUniversityLogoWheel({
    super.key,
    required this.sizes,
    required this.shorts,
    required this.activeIndex,
    required this.onChanged,
  });

  @override
  State<ShortsPlayerUniversityLogoWheel> createState() =>
      _ShortsPlayerUniversityLogoWheelState();
}

class _ShortsPlayerUniversityLogoWheelState
    extends State<ShortsPlayerUniversityLogoWheel> {
  late final FixedExtentScrollController _sc;
  bool _isProgrammatic = false;

  @override
  void initState() {
    super.initState();
    _sc = FixedExtentScrollController(initialItem: widget.activeIndex);
  }

  @override
  void didUpdateWidget(covariant ShortsPlayerUniversityLogoWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeIndex != oldWidget.activeIndex &&
        _sc.hasClients &&
        _sc.selectedItem != widget.activeIndex) {
      _isProgrammatic = true;
      _sc
          .animateToItem(
            widget.activeIndex,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
          )
          .whenComplete(() => _isProgrammatic = false);
    }
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  void _select(int i) {
    if (_isProgrammatic) return;
    HapticFeedback.selectionClick();
    widget.onChanged(i);
  }

  @override
  Widget build(BuildContext context) {
    final sizes = widget.sizes;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: sizes.wheelHeight - sizes.wheelHintFontSize - sizes.wheelHintSpacing,
          child: RotatedBox(
            quarterTurns: 3,
            child: ListWheelScrollView.useDelegate(
              controller: _sc,
              itemExtent: sizes.wheelItemExtent,
              diameterRatio: sizes.wheelDiameterRatio,
              perspective: sizes.wheelPerspective,
              squeeze: 1.05,
              physics: const FixedExtentScrollPhysics(),
              useMagnifier: false,
              overAndUnderCenterOpacity: 1,
              onSelectedItemChanged: _select,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: widget.shorts.length,
                builder: (context, i) {
                  final short = widget.shorts[i];
                  final isActive = i == widget.activeIndex;
                  return RotatedBox(
                    quarterTurns: 1,
                    child: _WheelLogo(
                      sizes: sizes,
                      short: short,
                      isActive: isActive,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        SizedBox(height: sizes.wheelHintSpacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.swipe_rounded,
              size: sizes.wheelHintFontSize + 2,
              color: AppTheme.primaryColor,
            ),
            SizedBox(width: sizes.wheelHintSpacing),
            Flexible(
              child: Text(
                'Kaydırarak üniversite değiştir',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: sizes.wheelHintFontSize,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WheelLogo extends StatelessWidget {
  final ShortsPlayerSizes sizes;
  final ShortsModel short;
  final bool isActive;

  const _WheelLogo({
    required this.sizes,
    required this.short,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final size = isActive ? sizes.wheelActiveLogoSize : sizes.wheelInactiveLogoSize;
    final hasLogo = short.logoUrl != null && short.logoUrl!.isNotEmpty;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isActive ? 1 : 0.55,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxSize = constraints.biggest.shortestSide;
          final actualSize = size > maxSize ? maxSize : size;
          return Center(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: actualSize,
                  height: actualSize,
                  padding: EdgeInsets.all(isActive ? 2.5 : 0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isActive
                        ? SweepGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.secondaryColor,
                              AppTheme.darkPrimaryContainer,
                              AppTheme.primaryColor,
                            ],
                          )
                        : null,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(alpha: 0.45),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(sizes.wheelLogoPadding),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF0B1322),
                    ),
                    child: ClipOval(
                      child: hasLogo
                          ? CachedNetworkImage(
                              imageUrl: short.logoUrl!,
                              fit: BoxFit.contain,
                              fadeInDuration: Duration.zero,
                              fadeOutDuration: Duration.zero,
                              errorWidget: (_, _, _) => const Icon(
                                Icons.school_rounded,
                                color: Colors.white54,
                              ),
                              placeholder: (_, _) =>
                                  const ColoredBox(color: Color(0xFF2A2A2A)),
                            )
                          : const Icon(
                              Icons.school_rounded,
                              color: Colors.white54,
                            ),
                    ),
                  ),
                ),
                if (isActive)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryColor,
                        border: Border.all(color: const Color(0xFF0B1322), width: 2),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 10,
                        color: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
