import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../values/values.dart';

class CheckboxDropdown extends StatefulWidget {
  const CheckboxDropdown({super.key, required this.title, required this.options, required this.onTapItem});

  final String title;
  final List<DropdownItem> options;
  final Function(bool, String) onTapItem;
  @override
  _CheckboxDropdownState createState() => _CheckboxDropdownState();
}

class _CheckboxDropdownState extends State<CheckboxDropdown> {

  bool _isDropdownOpened = false;
  String _textSelection = "Selecciona una o varias opciones";
  
  @override
  void initState() {
    if(widget.options != []){
      _textSelection = "";
      for(var element in widget.options){
        if(element.isSelected){
          _textSelection == '' ? _textSelection += '${element.title}' : _textSelection += ', ${element.title}';
        }
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble / 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextBold(title: widget.title, color: AppColors.primary900,),
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
                    style: textTheme.bodySmall?.copyWith(
                      height: 1.5,
                      color: _someElementSelected() ? AppColors.greyDark : AppColors.greyDropMenuBorder,
                      fontWeight: _someElementSelected() ? FontWeight.w500 : FontWeight.w300,
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
                        _textSelection = "";
                        for(var element in widget.options){
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
      ),
    );
  }

  bool _someElementSelected(){
    bool atLeastOne = false;
    for(var element in widget.options){
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
