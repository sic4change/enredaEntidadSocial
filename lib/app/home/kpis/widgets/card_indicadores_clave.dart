import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../kpi_colors.dart';
import '../kpi_models.dart';

class CardIndicadoresClave extends StatelessWidget {
  const CardIndicadoresClave({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KpiColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: KpiColors.cardShadow,
      ),
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 900;
          if (isNarrow) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: KpiFakeData.keyIndicators.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Row(
                    children: [
                      SizedBox(
                        width: 200,
                        child: _buildIndicatorColumn(item),
                      ),
                      if (index < KpiFakeData.keyIndicators.length - 1)
                        Container(
                          height: 240,
                          width: 1,
                          color: KpiColors.divider,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                    ],
                  );
                }).toList(),
              ),
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: KpiFakeData.keyIndicators.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildIndicatorColumn(item)),
                    if (index < KpiFakeData.keyIndicators.length - 1)
                      Container(
                        height: 240,
                        width: 1,
                        color: KpiColors.divider,
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildIndicatorColumn(KeyIndicatorMetric item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Circular Icon Avatar
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: KpiColors.tileBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(
            item.icon,
            color: KpiColors.primaryDark,
            size: 22,
          ),
        ),
        const SizedBox(height: 12),

        // Title
        SizedBox(
          height: 38,
          child: Text(
            item.title,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: KpiColors.primaryDark,
              height: 1.25,
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Big value(s)
        if (item.secondValue != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.mainValue,
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: KpiColors.primaryDark,
                      ),
                    ),
                    Text(
                      item.unit,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: KpiColors.secondaryText,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.secondValue!,
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: KpiColors.primaryDark,
                      ),
                    ),
                    Text(
                      item.secondUnit!,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: KpiColors.secondaryText,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ] else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                item.mainValue,
                style: GoogleFonts.outfit(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: KpiColors.primaryDark,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                item.unit,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: KpiColors.secondaryText,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),

        // Variation badge
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: KpiColors.lightTurquoise,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                item.variation,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: KpiColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'vs. año anterior',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: KpiColors.secondaryText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Previous year info
        Text(
          item.previousYearText,
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: KpiColors.secondaryText,
          ),
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, color: KpiColors.divider),
        const SizedBox(height: 10),

        // Source footnote
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.article_outlined,
              size: 14,
              color: KpiColors.secondaryText,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                item.source,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: KpiColors.secondaryText,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
