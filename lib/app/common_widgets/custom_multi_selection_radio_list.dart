import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

class CustomMultiSelectionCheckBoxList extends StatefulWidget {
  const CustomMultiSelectionCheckBoxList({
    super.key,
    required this.options,
    required this.selections,
    this.enabled,
  });

  final List<String> options;
  final List<String> selections;
  final bool? enabled;

  @override
  State<CustomMultiSelectionCheckBoxList> createState() => _CustomMultiSelectionCheckBoxListState();
}

class _CustomMultiSelectionCheckBoxListState extends State<CustomMultiSelectionCheckBoxList> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Wrap(
      alignment: WrapAlignment.start,
      direction: Axis.horizontal,
      children: <Widget>[
        for(var option in widget.options)
          SizedBox(
            width: 280,
            child: CheckboxListTile(
              title: Text(
                option,
                style: textTheme.bodySmall?.copyWith(
                  height: 1.4,
                  color: AppColors.greyDark,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                )
              ),
              controlAffinity: ListTileControlAffinity.leading,
              selected: widget.selections.contains(option),
              checkColor: Colors.white,
              value: widget.selections.contains(option) ? true : false,
              onChanged: (value){
                setState(() {
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
    );
  }
}
