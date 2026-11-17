import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../kpi_colors.dart';

/// Gris de la línea vertical que sigue al ratón en las gráficas de evolución.
const Color _cursorColor = Color(0xFFCCCCCC);

/// Línea vertical gris que sigue al ratón (o al dedo) con el punto activo y
/// el cuadro de información, para las gráficas de área de los KPIs.
///
/// [title] recibe la etiqueta del eje X del punto (p. ej. "Sep") y devuelve
/// la cabecera del cuadro; [label] es el nombre del valor ("Inscripciones").
TrackballBehavior kpiTrackball({
  required String Function(String x) title,
  required String label,
}) {
  return TrackballBehavior(
    enable: true,
    activationMode: ActivationMode.singleTap,
    lineType: TrackballLineType.vertical,
    lineColor: _cursorColor,
    lineWidth: 1,
    tooltipDisplayMode: TrackballDisplayMode.nearestPoint,
    markerSettings: const TrackballMarkerSettings(
      markerVisibility: TrackballVisibilityMode.visible,
      shape: DataMarkerType.circle,
      color: KpiColors.turquoise,
      borderColor: Colors.white,
      borderWidth: 2,
      width: 12,
      height: 12,
    ),
    builder: (context, details) {
      final point = details.point;
      if (point == null || point.y == null) return const SizedBox.shrink();
      final y = point.y!;
      final value = y == y.roundToDouble() ? '${y.toInt()}' : '$y';
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _cursorColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title('${point.x}'),
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: KpiColors.primaryDark,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: KpiColors.turquoise,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$label : $value',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: KpiColors.secondaryText,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
