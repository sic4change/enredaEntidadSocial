import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

class CustomTextFormFieldLong extends StatelessWidget {
  const CustomTextFormFieldLong({
    super.key,
    required this.labelText,
    this.initialValue,
    this.hintText,
    this.fontSize = 14.0,
    this.onSaved,
    this.onChanged,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
  });

  final String labelText;
  final String? initialValue, hintText;
  final double fontSize;
  final Function(String)? onChanged;
  final Function(String?)? onSaved;
  final String ?Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool enabled;

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
            style: textTheme.button?.copyWith(
              height: 1.5,
              color: AppColors.greyDark,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
            ),
          ),
        ),
        textField(context),
      ],
    );
  }

  Widget textField(BuildContext context){
    final textTheme = Theme.of(context).textTheme;
    return TextFormField(
      maxLines: 12,
      minLines: 1,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(5),
        hintText: hintText,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(
            color: Colors.transparent,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(
            color: Colors.transparent,
            width: 1.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(
            color: Colors.transparent,
            width: 1.0,
          ),
        ),
      ),
      initialValue: initialValue,
      validator: validator,
      onSaved: onSaved,
      keyboardType: keyboardType,
      onChanged: onChanged,
      enabled: enabled,
      style: textTheme.button?.copyWith(
        height: 1.5,
        color: AppColors.greyDark,
        fontWeight: FontWeight.w400,
        fontSize: fontSize,
      ),
    );
  }
}


InputDecoration customTextFormFieldDialog(BuildContext context, String label) {
  TextTheme textTheme = Theme.of(context).textTheme;
  return InputDecoration(
    labelText: label,
    focusColor: AppColors.primaryColor,
    labelStyle: textTheme.bodyLarge?.copyWith(
      color: AppColors.greyTxtAlt,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: const BorderSide(
          color: AppColors.greyLight
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: const BorderSide(
        color: AppColors.greyLight,
        width: 1.0,
      ),
    ),
  );
}