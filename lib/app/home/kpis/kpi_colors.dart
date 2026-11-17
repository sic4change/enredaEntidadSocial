import 'package:flutter/material.dart';

/// Design tokens extracted directly from Figma node 11249:68
class KpiColors {
  // Primary brand navy / deep teal
  static const Color primaryDark = Color(0xFF054D5E);

  // Secondary text color for subtitles, notes, axis labels
  static const Color secondaryText = Color(0xFF3F6672);

  // Muted text / tertiary
  static const Color mutedText = Color(0xFF82A6AE);

  // Primary vibrant turquoise for active charts and highlights
  static const Color turquoise = Color(0xFF18C5C1);

  // Pale mint / light turquoise for highlights, badges, and accents
  static const Color lightTurquoise = Color(0xFFA7E4E1);

  // Amber / Warm Yellow (Mujeres in gender charts, Metodológicas, Irregular)
  static const Color yellow = Color(0xFFFFCB77);

  // Slate / Gray-blue (No binario in gender charts, etc.)
  static const Color slate = Color(0xFF82A6AE);

  // Borders, inactive segments, dividers
  static const Color borderLight = Color(0xFFCDDBDF);
  static const Color divider = Color(0xFFE3ECEF);

  // Pill and stat card background (soft grayish cyan)
  static const Color tileBackground = Color(0xFFE3ECEF);

  // Page background (soft cool canvas that makes white cards stand out)
  static const Color pageBackground = Color(0xFFEDF3F5);

  // White for cards and controls
  static const Color cardBackground = Colors.white;

  // Positive variation green / teal
  static const Color variationPositive = Color(0xFF054D5E);
  static const Color variationNegative = Color(0xFF054D5E);

  // Card drop shadow
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color.fromRGBO(5, 77, 94, 0.08),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> smallShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.08),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];
}
