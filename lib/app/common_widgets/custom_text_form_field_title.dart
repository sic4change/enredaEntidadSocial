import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

class CustomTextFormFieldTitle extends StatelessWidget {
  const CustomTextFormFieldTitle({
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
    this.height,
    this.controller,
    this.color = AppColors.greyDark,
  });

  final String labelText;
  final String? initialValue, hintText;
  final double fontSize;
  final Function(String)? onChanged;
  final Function(String?)? onSaved;
  final String ?Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool enabled;
  final double? height;
  final TextEditingController? controller;
  final Color color;

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
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
            ),
          ),
        ),
        height != null ? 
        Container(
          height: 45,
          child: textField(context)
        ) :
        textField(context),
      ],
    );
  }
  
  Widget textField(BuildContext context){
    final textTheme = Theme.of(context).textTheme;
    return TextFormField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.all(5),
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.greyDropMenuBorder,
        ),
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
      maxLines: null,
      controller: controller,
      initialValue: initialValue,
      validator: validator,
      onSaved: onSaved,
      keyboardType: keyboardType,
      onChanged: onChanged,
      enabled: enabled,
      style: textTheme.bodySmall?.copyWith(
        height: 1.5,
        color: AppColors.greyDark,
        fontWeight: FontWeight.w400,
        fontSize: fontSize,
      ),
    );
  }
}