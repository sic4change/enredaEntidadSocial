import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

class BoxSocialNetworkData {
  final IconData icon;
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

  final IconData? icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return defaultChild(context);
  }

  Widget defaultChild(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      key: Key("network-$title"),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          children: [
            Icon(icon, color: AppColors.turquoiseBlue, size: 20),
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
