import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../kpi_colors.dart';
import '../kpi_models.dart';

class CardRecorridoResultados extends StatelessWidget {
  const CardRecorridoResultados({Key? key}) : super(key: key);

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
          Text(
            'Recorrido de resultados',
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: KpiColors.primaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cuántas personas inscritas llegan a cada resultado',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: KpiColors.secondaryText,
            ),
          ),
          const SizedBox(height: 24),

          // 5 Funnel Steps Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 560;
              if (isSmall) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _buildStepList(),
                  ),
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildStepList(),
              );
            },
          ),
          const SizedBox(height: 20),

          // Note
          Text(
            '% sobre el total de personas inscritas',
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: KpiColors.secondaryText,
            ),
          ),
          const SizedBox(height: 16),

          // Highlight Callout card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: KpiColors.tileBackground.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'De cada 100 personas inscritas, 8 mantienen el empleo a los 6 meses.',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: KpiColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStepList() {
    final list = <Widget>[];
    for (int i = 0; i < KpiFakeData.funnelSteps.length; i++) {
      final step = KpiFakeData.funnelSteps[i];
      list.add(_buildStepItem(step));
      if (i < KpiFakeData.funnelSteps.length - 1) {
        list.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 20),
            child: Text(
              '›',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                color: KpiColors.borderLight,
              ),
            ),
          ),
        );
      }
    }
    return list;
  }

  Widget _buildStepItem(FunnelStep step) {
    return SizedBox(
      width: 82,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular Progress Ring
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(64, 64),
                  painter: _RingProgressPainter(
                    pct: step.percentage / 100.0,
                    activeColor: step.ringColor,
                    trackColor: KpiColors.tileBackground,
                  ),
                ),
                Text(
                  '${step.percentage}%',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: KpiColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Count
          Text(
            '${step.count}',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: KpiColors.primaryDark,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),

          // Label
          Text(
            step.label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.normal,
              color: KpiColors.secondaryText,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingProgressPainter extends CustomPainter {
  final double pct;
  final Color activeColor;
  final Color trackColor;

  _RingProgressPainter({
    required this.pct,
    required this.activeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 5.5;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = pct * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
