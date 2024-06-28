import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../values/values.dart';

class CheckboxDropdown extends StatefulWidget {
  @override
  _CheckboxDropdownState createState() => _CheckboxDropdownState();
}

class _CheckboxDropdownState extends State<CheckboxDropdown> {
  List<DropdownItem> items = [
    DropdownItem(title: 'Item 1'),
    DropdownItem(title: 'Item 2'),
    DropdownItem(title: 'Item 3'),
    DropdownItem(title: 'Item 4'),
  ];

  bool _isDropdownOpened = false;
  String _textSelection = "Selecciona una o varias opciones";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Fortalecimiento de competencias",
          style: TextStyle(
            fontSize: 16,
            fontFamily: GoogleFonts.outfit().fontFamily,
            fontWeight: FontWeight.w500,
            color: AppColors.turquoiseBlue,
          ),
        ),
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
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _textSelection,
                  style: TextStyle(
                    color: _someElementSelected() ? AppColors.chatDarkGray : AppColors.greyDropMenuBorder,
                    fontWeight: _someElementSelected() ? FontWeight.w700 : FontWeight.w300,
                    fontSize: 14,
                    fontFamily: GoogleFonts.inter().fontFamily,
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
              children: items.map((item) {
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
                    setState(() {
                      item.isSelected = value!;
                      _textSelection = "";
                      for(var element in items){
                        if(element.isSelected){
                          _textSelection == '' ? _textSelection += '${element.title}' : _textSelection += ', ${element.title}';
                        }
                      }
                      _textSelection == '' ? _textSelection = 'Selecciona una o varias opciones' : _textSelection = _textSelection;
                    });
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  bool _someElementSelected(){
    bool atLeastOne = false;
    for(var element in items){
      if(element.isSelected){
        atLeastOne = true;
      }
    }
    return atLeastOne;
  }
}

class DropdownItem {
  final String title;
  bool isSelected;

  DropdownItem({required this.title, this.isSelected = false});
}
