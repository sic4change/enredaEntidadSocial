import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../kpi_colors.dart';
import '../kpi_models.dart';

class CardCondicionesSobrevenidas extends StatelessWidget {
  final List<RankedBarItem> items;
  final bool isLoading;

  const CardCondicionesSobrevenidas({
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
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Condiciones sobrevenidas',
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
            'Según se recoge en el informe inicial - Una persona puede presentar varias',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: KpiColors.secondaryText,
            ),
          ),
          const SizedBox(height: 20),

          // Ranked bars
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: _buildProgressRow(item, maxVal),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildProgressRow(RankedBarItem item, double maxVal) {
    final double pct = item.count / maxVal;

    return Row(
      children: [
        // Label
        Expanded(
          flex: 4,
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
          flex: 5,
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
                    width: item.count > 0 ? constraints.maxWidth * pct.clamp(0.05, 1.0) : 0,
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
