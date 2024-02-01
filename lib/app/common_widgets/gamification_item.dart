import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

class GamificationItem extends StatelessWidget {
  const GamificationItem({
    super.key,
    this.size = 160,
    this.progress = 0,
    this.progressText,
    this.imageSize = 100,
    required this.imagePath,
    required this.title,
  });

  final double size, imageSize, progress;
  final String imagePath, title;
  final String? progressText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
            height: !Responsive.isDesktop(context)? size/2:size,
            width: !Responsive.isDesktop(context)? size/2:size,
            child: DashedCircularProgressBar.aspectRatio(
                aspectRatio: 1, // width ÷ height
                progress: progress,
                startAngle: 225,
                sweepAngle: 270,
                foregroundColor: AppColors.darkYellow,
                backgroundColor: AppColors.lightYellow,
                foregroundStrokeWidth: !Responsive.isDesktop(context)?5: 10,
                backgroundStrokeWidth: !Responsive.isDesktop(context)?5: 10,
                seekColor: AppColors.darkYellow,
                seekSize: !Responsive.isDesktop(context)?5: 10,
                animation: true,
                child: Padding(
                  padding: EdgeInsets.only(top: !Responsive.isDesktop(context)?4.0: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        imagePath,
                        width: !Responsive.isDesktop(context)? imageSize/2.8:imageSize,
                        height: !Responsive.isDesktop(context)? imageSize/2.8:imageSize,
                      ),
                      if (!Responsive.isDesktop(context))
                        SpaceH4(),
                      if (progressText != null)
                        Text(
                          progressText!,
                          style: textTheme.titleLarge?.copyWith(
                              color: AppColors.turquoiseBlue,
                              fontSize: !Responsive.isDesktop(context)? textTheme.titleLarge!.fontSize!/1.8:textTheme.titleLarge!.fontSize!,
                          ),
                        ),
                      if (progressText == null)
                        SpaceH8(),
                    ],
                  ),
                )
            )
        ),
        Container(
          width: !Responsive.isDesktop(context)? (size/2) + 20:size + 40,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.turquoiseBlue,
              fontSize: !Responsive.isDesktop(context)? textTheme.bodySmall!.fontSize!/1.2:textTheme.bodySmall!.fontSize!,
            ),
          ),
        ),
      ],
    );
  }
}