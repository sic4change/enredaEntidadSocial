import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../kpi_colors.dart';
import '../kpi_models.dart';

import '../kpi_service.dart';

class CardParticipantesInscritos extends StatelessWidget {
  final ParticipantesKpiData? data;
  final bool isLoading;

  const CardParticipantesInscritos({
    Key? key,
    this.data,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = data != null ? data!.total : KpiFakeData.totalParticipantes;
    final estadoItems =
        data != null ? data!.porEstado : KpiFakeData.estadoParticipantes;
    final generoItems =
        data != null ? data!.porGenero : KpiFakeData.generoParticipantes;
    final nacionalidadItems = data != null
        ? data!.porNacionalidad
        : KpiFakeData.nacionalidadParticipantes;

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
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Participantes inscritos',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: KpiColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total acumulado desde el inicio, en la vista seleccionada',
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
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(KpiColors.turquoise),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Big number
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$total',
                style: GoogleFonts.outfit(
                  fontSize: 54,
                  fontWeight: FontWeight.w600,
                  color: KpiColors.primaryDark,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'participantes',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: KpiColors.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Sub-block: Por estado
          _buildSegmentGroup(
            title: 'Por estado',
            items: estadoItems,
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: KpiColors.divider),
          const SizedBox(height: 20),

          // Sub-block: Por género
          _buildSegmentGroup(
            title: 'Por género',
            items: generoItems,
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: KpiColors.divider),
          const SizedBox(height: 20),

          // Sub-block: Por nacionalidad
          _buildSegmentGroup(
            title: 'Por nacionalidad',
            items: nacionalidadItems,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentGroup({
    required String title,
    required List<StackedBarRow> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: KpiColors.secondaryText,
          ),
        ),
        const SizedBox(height: 10),

        // Stacked horizontal bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 12,
            child: Row(
              children: items.map((item) {
                return Expanded(
                  flex: (item.percentage * 10).round(),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Legend rows
        ...items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
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
                        fontSize: 13,
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
                        fontWeight: FontWeight.w600,
                        color: KpiColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${item.percentage.round()}%',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: KpiColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
