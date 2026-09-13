// lib/presentation/screens/home/widgets/tabs/universities_tab/widgets/universities_alphabet_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../data/models/university_model.dart';
import '../../../../../controllers/university_alphabet_controller.dart';
import '../universities_tab_layout_spec.dart';
import 'university_list_card_widget.dart';

class UniversitiesAlphabetList extends StatefulWidget {
  final UniversitiesTabLayoutSpec spec;
  final List<UniversityModel> universities;
  final double itemExtent;

  const UniversitiesAlphabetList({
    super.key,
    required this.spec,
    required this.universities,
    required this.itemExtent,
  });

  @override
  State<UniversitiesAlphabetList> createState() =>
      _UniversitiesAlphabetListState();
}

class _UniversitiesAlphabetListState
    extends State<UniversitiesAlphabetList> {
  static const _tag = 'uni_alpha_list';
  late final UniversityAlphabetController _controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<UniversityAlphabetController>(tag: _tag)) {
      Get.put(UniversityAlphabetController(), tag: _tag);
    }
    _controller = Get.find<UniversityAlphabetController>(tag: _tag);
    _controller.setData(widget.universities, widget.itemExtent);
  }

  @override
  void didUpdateWidget(covariant UniversitiesAlphabetList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.universities, widget.universities)) {
      _controller.setData(widget.universities, widget.itemExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView.builder(
            controller: _controller.scrollController,
            padding: EdgeInsets.zero,
            itemExtent: widget.itemExtent,
            itemCount: widget.universities.length,
            itemBuilder: (_, i) => Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.spec.contentHPadding.w,
              ),
              child: UniversityListCardWidget(
                spec: widget.spec,
                university: widget.universities[i],
              ),
            ),
          ),
        ),
        Obx(() {
          final letters = _controller.availableLetters;
          if (letters.isEmpty) return const SizedBox.shrink();
          return _AlphabetSidebar(
            spec: widget.spec,
            letters: letters,
            currentLetter: _controller.currentLetter.value,
            onTapLetter: _controller.jumpToLetter,
            onDragLetter: _controller.dragToLetter,
          );
        }),
      ],
    );
  }
}

class _AlphabetSidebar extends StatelessWidget {
  final UniversitiesTabLayoutSpec spec;
  final List<String> letters;
  final String currentLetter;
  final ValueChanged<String> onTapLetter;
  final ValueChanged<String> onDragLetter;

  const _AlphabetSidebar({
    required this.spec,
    required this.letters,
    required this.currentLetter,
    required this.onTapLetter,
    required this.onDragLetter,
  });

  void _handlePosition(
    Offset local,
    double height,
    ValueChanged<String> cb,
  ) {
    if (letters.isEmpty || height <= 0) return;
    final itemHeight = height / letters.length;
    final index =
        (local.dy / itemHeight).floor().clamp(0, letters.length - 1);
    cb(letters[index]);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final height = c.maxHeight;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) =>
              _handlePosition(d.localPosition, height, onTapLetter),
          onVerticalDragUpdate: (d) =>
              _handlePosition(d.localPosition, height, onDragLetter),
          child: Container(
            width: spec.sidebarWidth.w,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: letters.map((letter) {
                final isActive = letter == currentLetter;
                return Expanded(
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isActive ? spec.sidebarPillWidth.w : 0,
                      height: spec.sidebarPillWidth.w,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppTheme.primaryColor
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontSize: isActive
                              ? spec.sidebarActiveFontSize.sp
                              : spec.sidebarInactiveFontSize.sp,
                          fontWeight:
                              isActive ? FontWeight.w800 : FontWeight.w500,
                          color: isActive
                              ? Colors.white
                              : AppTheme.textSec(context)
                                  .withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}