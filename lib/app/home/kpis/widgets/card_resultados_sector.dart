import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../kpi_colors.dart';
import '../kpi_models.dart';

class CardResultadosSector extends StatelessWidget {
  final List<RankedBarItem> items;
  final bool isLoading;

  const CardResultadosSector({
    Key? key,
    this.items = const [],
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double maxVal =
        items.fold<int>(1, (m, i) => i.count > m ? i.count : m).toDouble();

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
          // Header with dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resultados por sector',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: KpiColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Empleos conseguidos por tipo de empleo',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: KpiColors.secondaryText,
                      ),
                    ),
                  ],
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
          const SizedBox(height: 20),

          // Horizontal Bars
          if (items.isEmpty)
            Text(
              'Sin empleos con tipo de empleo registrado en esta selección.',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: KpiColors.secondaryText,
              ),
            ),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: _buildSectorRow(item, maxVal),
            );
          }).toList(),
          const SizedBox(height: 20),

          // Informational note
          Text(
            'Fuente: IPIL › Seguimiento a las 4 semanas y 6 meses › "Obtienen empleo" › Tipo de empleo. Participantes distintos; una persona puede contar en varios sectores.',
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: KpiColors.secondaryText,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectorRow(RankedBarItem item, double maxVal) {
    final double pct = item.count / maxVal;

    return Row(
      children: [
        // Label
        SizedBox(
          width: 175,
          child: Text(
            item.label,
            textAlign: TextAlign.right,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: KpiColors.secondaryText,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Bar with gray track
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 12,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: KpiColors.tileBackground,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Container(
                    height: 12,
                    width: constraints.maxWidth * pct.clamp(0.05, 1.0),
                    decoration: BoxDecoration(
                      color: KpiColors.turquoise,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 12),

        // Count
        SizedBox(
          width: 25,
          child: Text(
            '${item.count}',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: KpiColors.primaryDark,
            ),
          ),
        ),
      ],
    );
  }
}
