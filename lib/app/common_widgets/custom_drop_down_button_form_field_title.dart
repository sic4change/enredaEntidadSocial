import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

class CustomDropDownButtonFormFieldTittle extends StatelessWidget {
  const CustomDropDownButtonFormFieldTittle({
    super.key,
    required this.labelText,
    this.fontSize = 14.0,
    this.onChanged,
    required this.source,
    this.hintText,
    this.validator,
    this.value,

  });
  final String labelText;
  final double fontSize;
  final Function(String?)? onChanged;
  final List<DropdownMenuItem<String>> source;
  final String? hintText;
  final String ?Function(String?)? validator;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            labelText,
              style: textTheme.bodySmall?.copyWith(
              height: 1.5,
              color: AppColors.greyDark,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
              ),
          ),
        ),
        Container(
          height: 50,
          child: DropdownButtonFormField(
            isExpanded: true,
            isDense: true,
            value: value,
            items: source,
            onChanged: onChanged,
            validator: validator,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              errorStyle: TextStyle(height: 0.01),
              hintText: hintText,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: BorderSide(
                  color: AppColors.greyUltraLight,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: BorderSide(
                  color: AppColors.greyUltraLight,
                  width: 1.0,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: BorderSide(
                  color: AppColors.greyUltraLight,
                  width: 1.0,
                ),
              ),
            ),
            style: textTheme.bodySmall?.copyWith(
                height: 1.4,
                color: AppColors.greyDark,
                fontWeight: FontWeight.w400,
                fontSize: fontSize,
            ),
          ),
        ),
      ]
    );
  }
}
