import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

class RoundedContainer extends StatelessWidget {
  const RoundedContainer({
    super.key,
    this.child,
    this.contentPadding = const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
    this.width,
    this.height,
  });

  final Widget? child;
  final EdgeInsets? contentPadding;
  final double? width, height;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: contentPadding,
        margin: EdgeInsets.all(Sizes.kDefaultPaddingDouble),
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Sizes.kDefaultPaddingDouble),
          border: Border.all(color: AppColors.greyLight, width: 2.0,),
        ),
        child: child);
  }
}
