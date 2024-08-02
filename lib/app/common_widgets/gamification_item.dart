import 'package:circular_seek_bar/circular_seek_bar.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

class GamificationItem extends StatelessWidget {
  const GamificationItem({
    super.key,
    this.size = 100,
    this.progress = 0,
    this.progressText,
    this.imageSize = 90,
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
        CircularSeekBar(
          height: Responsive.isMobile(context) || Responsive.isDesktopS(context) ? size * 0.7 : size * 1.5,
          width: Responsive.isMobile(context) || Responsive.isDesktopS(context) ? size * 0.7 : size * 1.5,
          startAngle: 45,
          sweepAngle: 270,
          progress: progress,
          barWidth: !Responsive.isDesktop(context)?5: 10,
          progressColor: AppColors.darkYellow,
          innerThumbStrokeWidth: !Responsive.isDesktop(context)?5: 10,
          innerThumbColor: AppColors.darkYellow,
          outerThumbColor: Colors.transparent,
          trackColor: AppColors.lightYellow,
          strokeCap: StrokeCap.round,
          animation: true,
          animDurationMillis: 1500,
          interactive: false,
          child: Padding(
            padding: EdgeInsets.only(top: !Responsive.isDesktop(context)? 4.0 : 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (progressText != null) SizedBox(height: 10,),
                Image.asset(
                  imagePath,
                  width: Responsive.isMobile(context) || Responsive.isDesktopS(context) ? imageSize/2.8 : imageSize,
                  height: Responsive.isMobile(context) || Responsive.isDesktopS(context) ? imageSize/2.8 : imageSize,
                ),
                if (!Responsive.isDesktop(context)) SpaceH4(),
                if (progressText != null)
                  Text(
                    progressText!,
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.turquoiseBlue,
                      fontSize: Responsive.isMobile(context) || Responsive.isDesktopS(context) ? textTheme.titleLarge!.fontSize!/1.8:textTheme.titleLarge!.fontSize!,
                    ),
                  ),
                // if (progressText == null)
                //   SpaceH8(),
              ],
            ),
          ),
        ),
        Container(
          width: Responsive.isMobile(context) || Responsive.isDesktopS(context) ? (size * 0.7) + 20 : size + 40,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.turquoiseBlue,
              fontSize: Responsive.isMobile(context) || Responsive.isDesktopS(context) ? textTheme.bodySmall!.fontSize!/1.2:textTheme.bodySmall!.fontSize!,
            ),
          ),
        ),
      ],
    );
  }
}