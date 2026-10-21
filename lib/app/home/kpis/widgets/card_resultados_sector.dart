import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../kpi_colors.dart';
import '../kpi_models.dart';

class CardResultadosSector extends StatefulWidget {
  const CardResultadosSector({Key? key}) : super(key: key);

  @override
  State<CardResultadosSector> createState() => _CardResultadosSectorState();
}

class _CardResultadosSectorState extends State<CardResultadosSector> {
  String _selectedIndicator = 'Cualificaciones';

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
                      'Cualificaciones obtenidas por familia profesional',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: KpiColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              _buildIndicatorDropdown(),
            ],
          ),
          const SizedBox(height: 20),

          // Horizontal Bars
          ...KpiFakeData.resultadosPorSector.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: _buildSectorRow(item),
            );
          }).toList(),
          const SizedBox(height: 20),

          // Informational note
          Text(
            'Cambia el indicador para ver el reparto por sector del ingreso a formación o de los empleos conseguidos.',
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

  Widget _buildIndicatorDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: KpiColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Indicador: $_selectedIndicator',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: KpiColors.primaryDark,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: KpiColors.primaryDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSectorRow(RankedBarItem item) {
    const double maxVal = 10.0;
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
