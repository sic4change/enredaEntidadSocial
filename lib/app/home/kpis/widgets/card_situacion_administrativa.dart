import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../kpi_colors.dart';
import '../kpi_models.dart';

class CardSituacionAdministrativa extends StatelessWidget {
  const CardSituacionAdministrativa({Key? key}) : super(key: key);

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
            'Situación administrativa',
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: KpiColors.primaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Recogida en la inscripción y en el informe inicial',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: KpiColors.secondaryText,
            ),
          ),
          const SizedBox(height: 20),

          // Donut + Legend
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 460;
              if (isSmall) {
                return Column(
                  children: [
                    _buildDonutChart(),
                    const SizedBox(height: 16),
                    _buildLegend(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildDonutChart(),
                  const SizedBox(width: 20),
                  Expanded(child: _buildLegend()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDonutChart() {
    return SizedBox(
      width: 170,
      height: 170,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SfCircularChart(
            margin: EdgeInsets.zero,
            series: <CircularSeries<DonutSegment, String>>[
              DoughnutSeries<DonutSegment, String>(
                dataSource: KpiFakeData.situacionAdministrativa,
                xValueMapper: (DonutSegment data, _) => data.label,
                yValueMapper: (DonutSegment data, _) => data.count,
                pointColorMapper: (DonutSegment data, _) => data.color,
                innerRadius: '68%',
                radius: '100%',
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '142',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: KpiColors.primaryDark,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'participantes',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: KpiColors.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: KpiFakeData.situacionAdministrativa.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 9,
                    height: 9,
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
        );
      }).toList(),
    );
  }
}
