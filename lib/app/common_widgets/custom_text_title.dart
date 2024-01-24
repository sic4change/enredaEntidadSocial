import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

class CustomTextTitle extends StatelessWidget {

  const CustomTextTitle({super.key,  required this.title });
  final String title;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        title,
        style: textTheme.bodySmall?.copyWith(
          color: AppColors.penBlue,
          height: 1.5,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}


class CustomTextBody extends StatelessWidget {

  const CustomTextBody({super.key,  required this.text });
  final String text;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Text(
      text,
      style: textTheme.bodySmall?.copyWith(
        color: AppColors.greyDark,
        height: 1.5,
      ),
    );
  }
}

