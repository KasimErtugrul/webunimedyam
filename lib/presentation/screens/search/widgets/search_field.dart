// lib/presentation/screens/search/widgets/search_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../controllers/video_search_controller.dart';
import '../search_layout_spec.dart';

class SearchField extends StatelessWidget {
  final SearchLayoutSpec spec;
  final TextEditingController textController;
  final FocusNode focusNode;
  final VideoSearchController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  const SearchField({
    super.key,
    required this.spec,
    required this.textController,
    required this.focusNode,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      style: TextStyle(
        color: AppTheme.textPri(context),
        fontSize: spec.fieldFontSize.sp,
      ),
      decoration: InputDecoration(
        hintText: 'Video, üniversite, kanal ara...',
        hintStyle: TextStyle(
          color: AppTheme.textSec(context).withValues(alpha: 0.7),
          fontSize: spec.fieldFontSize.sp,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: AppTheme.textSec(context),
          size: spec.fieldIconSize.sp,
        ),
        filled: true,
        fillColor: AppTheme.card(context),
        contentPadding: EdgeInsets.symmetric(
          horizontal: spec.fieldPaddingH.w,
          vertical: spec.fieldPaddingV.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spec.fieldRadius.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spec.fieldRadius.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spec.fieldRadius.r),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        suffixIcon: Obx(
          () => controller.query.value.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppTheme.textSec(context),
                    size: spec.fieldIconSize.sp,
                  ),
                  onPressed: () {
                    textController.clear();
                    controller.onQueryChanged('');
                    focusNode.requestFocus();
                  },
                ),
        ),
      ),
    );
  }
}