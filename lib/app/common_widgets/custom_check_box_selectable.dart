import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../values/values.dart';

class CustomCheckBoxSelectable extends StatefulWidget {
   const CustomCheckBoxSelectable({super.key, required this.title, required this.onTapItem, required this.selectable, required this.isSelected});

  final String title;
  final Function(bool) onTapItem;
  final bool selectable;
  final bool isSelected;
  @override
  _CustomCheckBoxSelectableState createState() => _CustomCheckBoxSelectableState();
}

class _CustomCheckBoxSelectableState extends State<CustomCheckBoxSelectable> {
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        checkColor: Colors.white,
        side: MaterialStateBorderSide.resolveWith((states) => BorderSide(width: 1, color: AppColors.greyDropMenuBorder)),
        title: Text(
          widget.title,
          style: textTheme.bodySmall?.copyWith(
            height: 1.5,
            color: AppColors.greyDark,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        value: widget.isSelected,
        enabled: widget.selectable,
        onChanged: (bool? value) {
          widget.onTapItem(value!);
        },
      ),
    );
  }
}
