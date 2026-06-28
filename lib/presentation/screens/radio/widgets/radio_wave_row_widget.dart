import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';

class RadioWaveRowWidget extends StatefulWidget {
  final bool isActive;
  const RadioWaveRowWidget({super.key, required this.isActive});

  @override
  State<RadioWaveRowWidget> createState() => _RadioWaveRowWidgetState();
}

class _RadioWaveRowWidgetState extends State<RadioWaveRowWidget>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 5; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + i * 80),
      );
      final anim = Tween<double>(
        begin: 4,
        end: 22,
      ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeInOut));
      _controllers.add(ctrl);
      _animations.add(anim);
      if (widget.isActive) ctrl.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(RadioWaveRowWidget old) {
    super.didUpdateWidget(old);
    if (widget.isActive != old.isActive) {
      for (final c in _controllers) {
        if (widget.isActive) {
          c.repeat(reverse: true);
        } else {
          c.stop();
          c.animateTo(0);
        }
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28.h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(_controllers.length, (i) {
          return AnimatedBuilder(
            animation: _animations[i],
            builder: (_, __) => Container(
              width: 4.w,
              height: _animations[i].value.h,
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(
                  alpha: widget.isActive ? .8 : .2,
                ),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          );
        }),
      ),
    );
  }
}