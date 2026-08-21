import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BoxSocialNetworkData {
  final FaIconData icon;
  final String title;

  BoxSocialNetworkData({
    required this.icon,
    required this.title,
  });
}

class BoxItemNetwork extends StatelessWidget {
  BoxItemNetwork({
    this.icon,
    this.title = "",
  });

  final FaIconData? icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return defaultChild(context);
  }

  Widget defaultChild(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      key: Key("network-$title"),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.greyBorder, width: 1.0),
              ),
              child: FaIcon(icon, color: AppColors.turquoiseBlue, size: 16),
            ),
            SizedBox(width: 5),
            Text(
              title,
              textAlign: TextAlign.start,
              style: textTheme.bodySmall?.copyWith(height: 1.4, fontWeight: FontWeight.w600, color: AppColors.turquoiseBlue),
            ),
          ],
        ),
      ),
    );
  }
}
