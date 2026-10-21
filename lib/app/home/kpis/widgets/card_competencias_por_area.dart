import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../kpi_colors.dart';
import '../kpi_models.dart';

class CardCompetenciasPorArea extends StatelessWidget {
  const CardCompetenciasPorArea({Key? key}) : super(key: key);

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
            'Por área de competencia',
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: KpiColors.primaryDark,
            ),
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
            children: [
              _buildGroupBadge('Sociales / interpersonales', '41%', KpiColors.primaryDark),
              _buildGroupBadge('Personales / intrapersonales', '29%', KpiColors.turquoise),
              _buildGroupBadge('Metodológicas', '30%', KpiColors.yellow),
            ],
          ),
          const SizedBox(height: 20),

          // Chart with center text "11 áreas"
          SizedBox(
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SfCircularChart(
                  margin: EdgeInsets.zero,
                  series: <CircularSeries<CompetenciaArea, String>>[
                    DoughnutSeries<CompetenciaArea, String>(
                      dataSource: KpiFakeData.areasCompetencia,
                      xValueMapper: (CompetenciaArea data, _) => data.name,
                      yValueMapper: (CompetenciaArea data, _) => data.percentage,
                      pointColorMapper: (CompetenciaArea data, _) => data.color,
                      innerRadius: '56%',
                      radius: '88%',
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                      dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        labelPosition: ChartDataLabelPosition.outside,
                        builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                          final item = data as CompetenciaArea;
                          return Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              '${item.name} ${item.percentage.round()}%',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: KpiColors.primaryDark,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '11',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: KpiColors.primaryDark,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        'áreas',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: KpiColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
