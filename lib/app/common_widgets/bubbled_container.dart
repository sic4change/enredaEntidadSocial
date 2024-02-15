import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

class BubbledContainer extends StatelessWidget {

  const BubbledContainer(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.greyUltraLight,
          boxShadow: [
            BoxShadow(
              color: AppColors.accentColor,
              offset: Offset(4.0, 4.0),
              blurRadius: 0.0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 8),
          child: CustomText(title: text),
        ));
  }
}
