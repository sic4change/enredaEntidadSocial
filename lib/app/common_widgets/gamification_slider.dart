import 'package:enreda_empresas/app/models/gamificationFlags.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GamificationSlider extends StatelessWidget {
  const GamificationSlider({
    super.key,
    this.height = 6.0,
    required this.value,
  });

  final double height;
  final int value;

  @override
  Widget build(BuildContext context) {
    int maxValue = LocationCache.instance.gamificationFlagsCount;
    if (maxValue == 0) maxValue = 1;
    double sliderValue = value / maxValue;
    
    // Clamp
    if (sliderValue > 1.0) sliderValue = 1.0;
    if (sliderValue < 0.0) sliderValue = 0.0;

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        disabledActiveTrackColor: AppColors.turquoise,
        disabledInactiveTrackColor: AppColors.lightTurquoise,
        trackShape: RoundedRectSliderTrackShape(),
        trackHeight: height,
        disabledThumbColor: AppColors.yellow,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: height),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 0.0),),
      child: Slider(
        value: sliderValue,
        onChanged: null,
      ),
    );
  }
}