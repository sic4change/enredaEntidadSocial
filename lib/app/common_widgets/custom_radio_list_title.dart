import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../values/values.dart';

class RadioListTitle extends StatefulWidget {
  const RadioListTitle({super.key, required this.title});

  final String title;
  @override
  _RadioListTitleState createState() => _RadioListTitleState();
}

class _RadioListTitleState extends State<RadioListTitle> {

  final List<String> _options = ['Option 1', 'Option 2', 'Option 3', 'Option 4', ''];
  // Variable para almacenar el valor seleccionado
  String? _selectedOption = "Option 1";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
          children: [
            RadioListTile<String>(
              title: Text(_options[0]),
              value: _options[0],
              groupValue: _selectedOption,
              onChanged: (String? value) {
                setState(() {
                  if (_selectedOption == value) {
                    _selectedOption = null;
                  } else {
                    _selectedOption = value;
                  }
                });
              },

            ),
            RadioListTile<String>(
              title: Text(_options[1]),
              value: _options[1],
              groupValue: _selectedOption,
              onChanged: (String? value) {
                setState(() {
                  if (_selectedOption == value) {
                    _selectedOption = null;
                  } else {
                    _selectedOption = value;
                  }
                });
              },
            ),
          ],
        ),
      ],
    );
  }

}
