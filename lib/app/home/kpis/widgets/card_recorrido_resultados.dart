import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../kpi_colors.dart';
import '../kpi_models.dart';

class CardRecorridoResultados extends StatelessWidget {
  final List<FunnelStep> steps;
  final bool isLoading;

  const CardRecorridoResultados({
    Key? key,
    this.steps = const [],
    this.isLoading = false,
  }) : super(key: key);

  String get _calloutText {
    if (steps.isEmpty || steps.first.count == 0) {
      return 'Sin personas inscritas en esta selección.';
    }
    final last = steps.last;
    final per100 = (last.count / steps.first.count * 100).round();
    return 'De cada 100 personas inscritas, $per100 ${per100 == 1 ? 'mantiene' : 'mantienen'} el empleo a los 6 meses.';
  }

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
                  'Recorrido de resultados',
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
            'Cuántas personas inscritas llegan a cada resultado (acumulado)',
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
              _calloutText,
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
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      list.add(_buildStepItem(step));
      if (i < steps.length - 1) {
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
                    pct: (step.percentage / 100.0).clamp(0.0, 1.0),
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
  bool shouldRepaint(covariant _RingProgressPainter oldDelegate) =>
      oldDelegate.pct != pct || oldDelegate.activeColor != activeColor;
}
