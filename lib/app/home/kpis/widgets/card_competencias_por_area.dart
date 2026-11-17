import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../kpi_colors.dart';
import '../kpi_models.dart';

class CardCompetenciasPorArea extends StatelessWidget {
  final List<CompetenciaArea> areas;
  final List<DonutSegment> categories;
  final bool isLoading;

  const CardCompetenciasPorArea({
    Key? key,
    this.areas = const [],
    this.categories = const [],
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KpiColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: KpiColors.cardShadow,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Por área de competencia',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: KpiColors.primaryDark,
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(KpiColors.turquoise),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Reparto de las competencias reconocidas según el diccionario de competencias',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: KpiColors.secondaryText,
            ),
          ),
          const SizedBox(height: 16),

          // Group summary badges
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: categories
                .map((c) => _buildGroupBadge(
                    c.label, '${c.percentage.round()}%', c.color))
                .toList(),
          ),
          const SizedBox(height: 20),

          // Polar area chart with center text "N áreas"
          if (areas.isEmpty)
            Text(
              'Sin áreas de competencia disponibles.',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: KpiColors.secondaryText,
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) =>
                  _buildPolarChart(constraints.maxWidth),
            ),
          const SizedBox(height: 16),

          // Footnote
          Text(
            'Porcentajes redondeados: la suma puede no dar exactamente 100%.',
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: KpiColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolarChart(double width) {
    const double labelMargin = 48.0;
    final double outerRadius = math.min(width * 0.24, 130.0);
    final double labelRadius = outerRadius + 14;
    final double height = 2 * (outerRadius + labelMargin);
    final Offset center = Offset(width / 2, height / 2);
    final double sweep = 2 * math.pi / areas.length;

    final labels = <Widget>[];
    for (int i = 0; i < areas.length; i++) {
      final area = areas[i];
      final double angle = -math.pi / 2 + sweep * (i + 0.5);
      final double cos = math.cos(angle);
      final double sin = math.sin(angle);
      final Offset p = center + Offset(cos, sin) * labelRadius;

      // Horizontal: a la derecha se alinea a la izquierda y viceversa
      double left;
      double boxWidth;
      TextAlign textAlign;
      CrossAxisAlignment crossAlign;
      if (cos > 0.25) {
        left = p.dx;
        boxWidth = width - p.dx;
        textAlign = TextAlign.left;
        crossAlign = CrossAxisAlignment.start;
      } else if (cos < -0.25) {
        left = 0;
        boxWidth = p.dx;
        textAlign = TextAlign.right;
        crossAlign = CrossAxisAlignment.end;
      } else {
        boxWidth = 160;
        left = p.dx - boxWidth / 2;
        textAlign = TextAlign.center;
        crossAlign = CrossAxisAlignment.center;
      }

      // Vertical: por encima del punto arriba, por debajo abajo
      final double dy = sin < -0.3 ? -1.0 : (sin > 0.3 ? 0.0 : -0.5);

      labels.add(Positioned(
        left: left,
        top: p.dy,
        width: boxWidth,
        child: FractionalTranslation(
          translation: Offset(0, dy),
          child: Column(
            crossAxisAlignment: crossAlign,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                area.name,
                textAlign: textAlign,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: KpiColors.primaryDark,
                  height: 1.2,
                ),
              ),
              Text(
                '${area.percentage.round()}%',
                textAlign: textAlign,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: KpiColors.primaryDark,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ));
    }

    final double innerRadius = outerRadius * 0.3;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _PolarAreaPainter(
                areas: areas,
                center: center,
                innerRadius: innerRadius,
                outerRadius: outerRadius,
              ),
            ),
          ),
          Positioned(
            left: center.dx - innerRadius,
            top: center.dy - innerRadius,
            width: innerRadius * 2,
            height: innerRadius * 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${areas.length}',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: KpiColors.primaryDark,
                    height: 1.0,
                  ),
                ),
                Text(
                  areas.length == 1 ? 'área' : 'áreas',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: KpiColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          ...labels,
        ],
      ),
    );
  }

  Widget _buildGroupBadge(String label, String pct, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: KpiColors.secondaryText,
          ),
        ),
        Text(
          pct,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: KpiColors.primaryDark,
          ),
        ),
      ],
    );
  }
}

/// Gráfico de áreas polares: todas las áreas ocupan la misma porción y el
/// radio de la parte coloreada es proporcional a su porcentaje (el mayor
/// llega al borde exterior).
class _PolarAreaPainter extends CustomPainter {
  final List<CompetenciaArea> areas;
  final Offset center;
  final double innerRadius;
  final double outerRadius;

  _PolarAreaPainter({
    required this.areas,
    required this.center,
    required this.innerRadius,
    required this.outerRadius,
  });

  Path _sector(double startAngle, double sweepAngle, double rIn, double rOut) {
    return Path()
      ..arcTo(Rect.fromCircle(center: center, radius: rOut), startAngle,
          sweepAngle, true)
      ..arcTo(Rect.fromCircle(center: center, radius: rIn),
          startAngle + sweepAngle, -sweepAngle, false)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    const double gap = 0.035;
    final double sweep = 2 * math.pi / areas.length;
    final double maxPct =
        areas.fold<double>(0, (m, a) => a.percentage > m ? a.percentage : m);

    final trackPaint = Paint()..color = KpiColors.tileBackground;

    for (int i = 0; i < areas.length; i++) {
      final area = areas[i];
      final double start = -math.pi / 2 + sweep * i + gap / 2;
      final double sweepAngle = sweep - gap;

      canvas.drawPath(
          _sector(start, sweepAngle, innerRadius, outerRadius), trackPaint);

      if (maxPct > 0 && area.percentage > 0) {
        final double r = innerRadius +
            (outerRadius - innerRadius) * (area.percentage / maxPct);
        canvas.drawPath(_sector(start, sweepAngle, innerRadius, r),
            Paint()..color = area.color);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PolarAreaPainter oldDelegate) =>
      oldDelegate.areas != areas ||
      oldDelegate.center != center ||
      oldDelegate.outerRadius != outerRadius;
}
