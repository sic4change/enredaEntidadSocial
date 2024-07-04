import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomMultiSelectionRadioListTitle extends StatefulWidget {
  const CustomMultiSelectionRadioListTitle({
    super.key,
    required this.options,
    required this.selections,
    this.enabled,
    required this.onTapItem,
    required this.title,
  });

  final List<String> options;
  final List<String> selections;
  final bool? enabled;
  final Function(String?) onTapItem;
  final String title;

  @override
  State<CustomMultiSelectionRadioListTitle> createState() => _CustomMultiSelectionRadioListTitleState();
}

class _CustomMultiSelectionRadioListTitleState extends State<CustomMultiSelectionRadioListTitle> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title,
          style: TextStyle(
            fontSize: 16,
            fontFamily: GoogleFonts.outfit().fontFamily,
            fontWeight: FontWeight.w500,
            color: AppColors.turquoiseBlue,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for(var option in widget.options)
              SizedBox(
                child: RadioListTile<String>(
                  title: Text(
                    option,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: GoogleFonts.inter().fontFamily,
                      fontWeight: FontWeight.w500,
                      color: AppColors.greyAlt,
                    ),
                  ),
                  selected: widget.selections.contains(option),
                  value: option,
                  groupValue: widget.selections.contains(option) ? option : '',
                  toggleable: true,
                  onChanged: (value){
                    setState(() {
                      widget.onTapItem(option);
                      if(!(widget.enabled ?? true)) return;
                      if(widget.selections.contains(option)){
                        widget.selections.remove(option);
                      }else{
                        widget.selections.add(option);
                      }
                    });
                  },
                  dense: true,

                ),
              )
          ],
        ),
      ],
    );
  }
}
