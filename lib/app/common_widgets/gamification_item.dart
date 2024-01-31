import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
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
            height: size,
            width: size,
            child: DashedCircularProgressBar.aspectRatio(
                aspectRatio: 1, // width ÷ height
                progress: progress,
                startAngle: 225,
                sweepAngle: 270,
                foregroundColor: AppColors.darkYellow,
                backgroundColor: AppColors.lightYellow,
                foregroundStrokeWidth: 10,
                backgroundStrokeWidth: 9,
                seekColor: AppColors.darkYellow,
                seekSize: 10,
                animation: true,
                child: Padding(
                  padding: const EdgeInsets.only(top:8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        imagePath,
                        width: imageSize,
                        height: imageSize,
                      ),
                      if (progressText != null)
                        Text(
                          progressText!,
                          style: textTheme.titleLarge?.copyWith(
                              color: AppColors.turquoiseBlue
                          ),
                        ),
                    ],
                  ),
                )
            )
        ),
        Text(
          title,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.turquoiseBlue
          ),
        ),
      ],
    );
  }
}