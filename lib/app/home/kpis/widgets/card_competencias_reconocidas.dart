import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../kpi_colors.dart';
import '../kpi_models.dart';

class CardCompetenciasReconocidas extends StatelessWidget {
  final List<RankedBarItem> items;
  final List<DonutSegment> categories;
  final bool isLoading;

  const CardCompetenciasReconocidas({
    Key? key,
    this.items = const [],
    this.categories = const [],
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
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Competencias más reconocidas',
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
                    valueColor: AlwaysStoppedAnimation<Color>(KpiColors.turquoise),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Participantes con la competencia reconocida · top 10',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: KpiColors.secondaryText,
            ),
          ),
          const SizedBox(height: 16),

          // Legend for groups
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: categories.map((c) => _buildLegend(c.label, c.color)).toList(),
          ),
          const SizedBox(height: 20),

          // Top 10 Ranked Competencies
          if (items.isEmpty)
            Text(
              'Sin competencias reconocidas en esta selección.',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: KpiColors.secondaryText,
              ),
            ),
          ...items.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: _buildCompetencyRow(rank, item, maxVal),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
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
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: KpiColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildCompetencyRow(int rank, RankedBarItem item, double maxVal) {
    final double pct = item.count / maxVal;

    return Row(
      children: [
        // Rank & Competency title + subtitle
        SizedBox(
          width: 155,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$rank ${item.label}',
                textAlign: TextAlign.right,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: KpiColors.primaryDark,
                ),
              ),
              if (item.category != null)
                Text(
                  item.category!,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: KpiColors.secondaryText,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Progress bar with gray track
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
                      color: item.color ?? KpiColors.primaryDark,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 10),

        // Count + %
        SizedBox(
          width: 55,
          child: Row(
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
              const SizedBox(width: 4),
              Text(
                '${(item.percentage ?? 0).round()}%',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: KpiColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
