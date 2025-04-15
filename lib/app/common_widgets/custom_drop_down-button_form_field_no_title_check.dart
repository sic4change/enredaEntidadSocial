import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../values/values.dart';

class CheckboxDropdownNoTitle extends StatefulWidget {
  const CheckboxDropdownNoTitle({super.key, required this.title, required this.options, required this.onTapItem, required this.cornerBottom, required this.cornerTop});

  final String title;
  final List<DropdownItem> options;
  final Function(bool, String) onTapItem;
  final bool cornerTop;
  final bool cornerBottom;
  @override
  _CheckboxDropdownNoTitleState createState() => _CheckboxDropdownNoTitleState();
}

class _CheckboxDropdownNoTitleState extends State<CheckboxDropdownNoTitle> {

  bool _isDropdownOpened = false;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.kDefaultPaddingDouble / 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isDropdownOpened = !_isDropdownOpened;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyDropMenuBorder),
                borderRadius: BorderRadius.only(
                  bottomLeft: widget.cornerBottom ? Radius.circular(6) : Radius.zero,
                  bottomRight:  widget.cornerBottom ? Radius.circular(6) : Radius.zero,
                  topLeft: widget.cornerTop ? Radius.circular(6) : Radius.zero,
                  topRight:  widget.cornerTop ? Radius.circular(6) : Radius.zero,
                  ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: textTheme.bodySmall?.copyWith(
                      height: 1.5,
                      color: AppColors.greyDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Icon(
                    _isDropdownOpened ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: AppColors.turquoise,
                  ),
                ],
              ),
            ),
          ),
          if (_isDropdownOpened)
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyDropMenuBorder),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: widget.options.map((item) {
                  return CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    checkColor: Colors.white,
                    side: MaterialStateBorderSide.resolveWith((states) => BorderSide(width: 1, color: AppColors.greyDropMenuBorder)),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        color: AppColors.chatDarkGray,
                        fontWeight: item.isSelected ? FontWeight.w700 : FontWeight.w300,
                        fontSize: 14,
                        fontFamily: GoogleFonts.inter().fontFamily,
                      ),
                    ),
                    value: item.isSelected,
                    onChanged: (bool? value) {
                      widget.onTapItem(value!, item.title);
                      setState(() {
                        item.isSelected = value;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class DropdownItem {
  final String title;
  bool isSelected;

  DropdownItem({required this.title, this.isSelected = false});
}
