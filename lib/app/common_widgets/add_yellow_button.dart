import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

class AddYellowButton extends StatelessWidget {

  AddYellowButton({
    required this.text,
    this.width = 235,
    this.onPressed,
  });

  final String text;
  final double? width;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerRight,
        children: [
          Container(
            height: 50,
            width: width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(25),),
              color: AppColors.turquoiseButton2,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 15, left: 20, right: 12),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Positioned(
            right: -1,
            child: Container(
                height: 51,
                width: 51,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.yellow,
                ),
              child: Icon(
                Icons.add,
                size: 35,
                color: AppColors.penBlue,
                weight: 100,
              ),
            ),
          ),
        ],
      )
    );
  }
}