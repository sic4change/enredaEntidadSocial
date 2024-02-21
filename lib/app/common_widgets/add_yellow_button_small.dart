import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/plus_rounded_shape.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

class AddYellowButtonSmall extends StatelessWidget {

  AddYellowButtonSmall({
    required this.text,
    this.width = 235,
    this.onPressed,
    this.padding = const EdgeInsets.only(top: 8, bottom: 0, left: 20, right: 10),
    this.height = 50,
    this.circleHeight = 51,
    this.circleWidth = 51,
  });

  final String text;
  final double? width;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? circleHeight;
  final double? circleWidth;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onPressed,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.centerRight,
          children: [
            Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(25),),
                color: AppColors.turquoiseButton2,
              ),
              child: Padding(
                padding: padding!,
                child: CustomTextButton(text: text),
              ),
            ),
            Positioned(
              right: -1,
              child: Container(
                height: circleHeight,
                width: circleHeight,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.yellow,
                ),
                child: RoundedPlusShape(padding: const EdgeInsets.all(8.0), strokeWidth: 4,),
              ),
            ),
          ],
        )
    );
  }
}