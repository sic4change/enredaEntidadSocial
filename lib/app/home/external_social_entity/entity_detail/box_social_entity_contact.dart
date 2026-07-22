import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
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
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
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
                // CSV values can be long (multiple numbers + name); wrap instead
                // of ellipsizing so the whole block is visible in the detail view.
                Flexible(
                  child: Text(
                    title,
                    softWrap: true,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.turquoiseBlue,
                      height: 1.3,
                      fontSize: responsiveSize(context, 10, 12, md: 11),
                    ),
                  ),
                ),
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
