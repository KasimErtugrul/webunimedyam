// lib/presentation/screens/home/widgets/tabs/universities_tab/widgets/universities_hero_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../../../controllers/university_sort_controller.dart';
import '../universities_tab_layout_spec.dart';

class UniversitiesHeroHeader extends StatelessWidget {
  final UniversitiesTabLayoutSpec spec;
  final UniversitySortController sortController;
  final VoidCallback onSortTap;
  final int activeSortCount;

  const UniversitiesHeroHeader({
    super.key,
    required this.spec,
    required this.sortController,
    required this.onSortTap,
    required this.activeSortCount,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, Color(0xFF0F5C2A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // ── Ambient blobs (arka plan) ──
            const Positioned(
              right: -50,
              top: -40,
              child: _Blob(size: 160, opacity: 0.10),
            ),
            const Positioned(
              left: -40,
              bottom: -60,
              child: _Blob(size: 130, opacity: 0.08),
            ),

            // ── İçerik ──
            Padding(
              padding: EdgeInsets.fromLTRB(
                spec.heroHPadding,
                topInset + spec.heroTopPadding,
                spec.heroHPadding,
                spec.heroBottomPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Üst satır: icon + başlık + sıralama
                  Row(
                    children: [
                      Container(
                            width: spec.heroIconSize,
                            height: spec.heroIconSize,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(
                                spec.heroIconRadius,
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 1.4,
                              ),
                            ),
                            child: Icon(
                              Icons.school_rounded,
                              color: Colors.white,
                              size: spec.heroIconInner,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .scaleXY(
                            begin: 0.8,
                            end: 1,
                            curve: Curves.easeOutBack,
                          ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child:
                                  Text(
                                    'Üniversiteler',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: spec.heroTitleFontSize,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.2,
                                    ),
                                  ).animate().fadeIn(
                                    delay: 100.ms,
                                    duration: 350.ms,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Keşfet, sırala, takip et',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: spec.heroSubtitleFontSize,
                              ),
                            ).animate().fadeIn(delay: 180.ms, duration: 350.ms),
                          ],
                        ),
                      ),
                      _HeroSortButton(
                        activeCount: activeSortCount,
                        onTap: onSortTap,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Arama çubuğu — hero'nun İÇİNDE, alt kısımda
                  _SearchBar(
                        spec: spec,
                        controller: sortController.searchController,
                        searchQuery: sortController.searchQuery,
                        onChanged: sortController.updateSearchQuery,
                        onClear: sortController.clearSearch,
                      )
                      .animate()
                      .fadeIn(delay: 250.ms, duration: 350.ms)
                      .slideY(begin: 0.15, end: 0, curve: Curves.easeOut),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero sort button ───────────────────────────────────────────────────────

class _HeroSortButton extends StatelessWidget {
  final int activeCount;
  final VoidCallback onTap;

  const _HeroSortButton({required this.activeCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
              if (activeCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$activeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Search bar — hero gradient'inin üstünde, yarı saydam ───────────────────

class _SearchBar extends StatelessWidget {
  final UniversitiesTabLayoutSpec spec;
  final TextEditingController controller;
  final RxString searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.spec,
    required this.controller,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: spec.searchHeight,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(spec.searchRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: spec.searchFontSize,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.white.withValues(alpha: 0.8),
            size: spec.searchIconSize,
          ),
          suffixIcon: Obx(
            () => searchQuery.value.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: spec.searchIconSize,
                    ),
                    onPressed: onClear,
                  ),
          ),
          hintText: 'Üniversite veya şehir ara...',
          hintStyle: TextStyle(
            fontSize: spec.searchFontSize,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(spec.searchRadius),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1.5,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: spec.searchHPadding,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final double opacity;
  const _Blob({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
