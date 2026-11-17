import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/userEnreda.dart';
import '../kpi_breakdown.dart';
import '../kpi_colors.dart';
import '../kpi_models.dart';

class CardDiscapacidad extends StatefulWidget {
  final List<DonutSegment> segments;
  final int total;
  final List<UserEnreda> users;

  /// Índice en [segments] de cada participante con informe inicial completo.
  final Map<String, int> discapacidadPorUsuario;
  final bool isLoading;

  const CardDiscapacidad({
    Key? key,
    this.segments = const [],
    this.total = 0,
    this.users = const [],
    this.discapacidadPorUsuario = const {},
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<CardDiscapacidad> createState() => _CardDiscapacidadState();
}

class _CardDiscapacidadState extends State<CardDiscapacidad> {
  KpiBreakdown _breakdown = KpiBreakdown.ninguno;

  List<DonutSegment> get segments => widget.segments;
  int get total => widget.total;
  bool get isLoading => widget.isLoading;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Participantes con discapacidad',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: KpiColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Según el certificado declarado en la inscripción',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: KpiColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading) ...[
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(KpiColors.turquoise),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  _buildDropdown(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Gauge + Legend
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 420;
              if (isSmall) {
                return Column(
                  children: [
                    _buildSemiCircleGauge(),
                    const SizedBox(height: 16),
                    _buildLegend(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildSemiCircleGauge(),
                  const SizedBox(width: 24),
                  Expanded(child: _buildLegend()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return KpiBreakdownChip(
      prefix: 'Desagregar',
      value: _breakdown,
      options: const [
        KpiBreakdown.ninguno,
        KpiBreakdown.genero,
        KpiBreakdown.nacionalidad
      ],
      onChanged: (value) => setState(() => _breakdown = value),
    );
  }

  Widget _buildSemiCircleGauge() {
    final declared = segments
        .where((s) => s.label != 'Sin discapacidad declarada')
        .fold<int>(0, (sum, s) => sum + s.count);
    final declaredPct = total > 0 ? (declared / total * 100).round() : 0;

    return SizedBox(
      width: 190,
      height: 125,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(190, 110),
            painter: _SemiCircleGaugePainter(
              segments: total > 0
                  ? segments
                      .map((s) => _GaugeSlice(
                            color: s.label == 'Sin discapacidad declarada'
                                ? KpiColors.borderLight.withValues(alpha: 0.4)
                                : s.color,
                            percentage: s.count / total,
                          ))
                      .toList()
                  : [
                      _GaugeSlice(
                        color: KpiColors.borderLight.withValues(alpha: 0.4),
                        percentage: 1.0,
                      ),
                    ],
            ),
          ),
          Positioned(
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$declaredPct%',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: KpiColors.primaryDark,
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: Text(
                    'con discapacidad reconocida o en trámite',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                      color: KpiColors.secondaryText,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    KpiGroups? groups;
    List<List<int>> counts = const [];
    if (_breakdown != KpiBreakdown.ninguno) {
      groups = KpiGroups.of(_breakdown, widget.users);
      final withReport = widget.users
          .where((u) => widget.discapacidadPorUsuario.containsKey(u.userId))
          .toList();
      counts = groups.countByRow(withReport, segments.length,
          (u) => widget.discapacidadPorUsuario[u.userId]);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: segments.asMap().entries.map((entry) {
        final item = entry.value;
        final detail = groups != null ? groups.detail(counts[entry.key]) : '';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.label,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: KpiColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${item.count}',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: KpiColors.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${item.percentage.round()}%',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: KpiColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (detail.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 18, top: 2),
                  child: Text(
                    detail,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: KpiColors.secondaryText,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _GaugeSlice {
  final Color color;
  final double percentage;

  _GaugeSlice({required this.color, required this.percentage});
}

class _SemiCircleGaugePainter extends CustomPainter {
  final List<_GaugeSlice> segments;

  _SemiCircleGaugePainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 12;
    const strokeWidth = 22.0;

    double startAngle = math.pi;

    for (final seg in segments) {
      final sweepAngle = seg.percentage * math.pi;
      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _SemiCircleGaugePainter oldDelegate) =>
      oldDelegate.segments != segments;
}
