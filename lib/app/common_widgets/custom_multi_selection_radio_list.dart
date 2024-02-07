import 'package:flutter/material.dart';

class CustomMultiSelectionRadioList extends StatefulWidget {
  const CustomMultiSelectionRadioList({
    super.key,
    required this.options,
    required this.selections,
    this.enabled,
  });

  final List<String> options;
  final List<String> selections;
  final bool? enabled;

  @override
  State<CustomMultiSelectionRadioList> createState() => _CustomMultiSelectionRadioListState();
}

class _CustomMultiSelectionRadioListState extends State<CustomMultiSelectionRadioList> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      direction: Axis.horizontal,
      children: <Widget>[
        for(var option in widget.options)
          SizedBox(
            width: 280,
            child: RadioListTile<String>(
              title: Text(option),
              selected: widget.selections.contains(option),
              value: option,
              groupValue: widget.selections.contains(option) ? option : '',
              toggleable: true,
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
