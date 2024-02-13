import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

class BoxSocialEntityContactData {
  final IconData icon;
  final String title;
  final VoidCallback? onPressed;

  BoxSocialEntityContactData({
    required this.icon,
    required this.title,
    this.onPressed,
  });
}

class BoxItemSocialEntityContact extends StatelessWidget {
  BoxItemSocialEntityContact({
    this.icon,
    this.title = "",
    this.onPressed,
  });

  final IconData? icon;
  final String title;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return defaultChild(context);
  }

  Widget defaultChild(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
            onPressed: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.turquoiseBlue, size: 20),
                SizedBox(width: 5),
                CustomTextXSmall(text: title, color: AppColors.turquoiseBlue, height: 0,)
              ],
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(width: 1, color: AppColors.greyBorder),
            )
        ),
      ],
    );
  }
}
