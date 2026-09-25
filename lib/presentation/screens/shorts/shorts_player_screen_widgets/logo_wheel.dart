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
    return RotatedBox(
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
            final size = isActive
                ? sizes.wheelActiveLogoSize
                : sizes.wheelInactiveLogoSize;
            final hasLogo = short.logoUrl != null && short.logoUrl!.isNotEmpty;

            return RotatedBox(
              quarterTurns: 1,
              child: AnimatedOpacity(
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
                      color: const Color(0xFF2A2A2A),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: sizes.isTablet ? 10 : 10,
                                spreadRadius: sizes.isTablet ? 1 : 1,
                              ),
                            ]
                          : null,
                    ),
                    padding: EdgeInsets.all(sizes.wheelLogoPadding),
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
              ),
            );
          },
        ),
      ),
    );
  }
}
