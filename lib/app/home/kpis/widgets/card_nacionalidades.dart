import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../kpi_colors.dart';
import '../kpi_models.dart';

class CardNacionalidades extends StatelessWidget {
  const CardNacionalidades({Key? key}) : super(key: key);

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
                      'Nacionalidades',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: KpiColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ranking por número de participantes y distribución por género',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: KpiColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              _buildVerTodasButton(),
            ],
          ),
          const SizedBox(height: 16),

          // Legend
          Row(
            children: [
              _buildLegendDot('Mujeres', KpiColors.yellow),
              const SizedBox(width: 14),
              _buildLegendDot('Hombres', KpiColors.primaryDark),
              const SizedBox(width: 14),
              _buildLegendDot('No binario', KpiColors.slate),
            ],
          ),
          const SizedBox(height: 20),

          // Ranked List
          ...KpiFakeData.nacionalidades.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildNationalityRow(index, item),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildVerTodasButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: KpiColors.primaryDark),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ver todas',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: KpiColors.primaryDark,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.arrow_forward_rounded,
            size: 14,
            color: KpiColors.primaryDark,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(String label, Color color) {
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

  Widget _buildNationalityRow(int rank, RankedBarItem item) {
    const double maxVal = 74.0;
    const double maxBarWidth = 240.0;
    final double barWidth = (item.count / maxVal) * maxBarWidth;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rank & Country Name
        SizedBox(
          width: 95,
          child: Row(
            children: [
              SizedBox(
                width: 16,
                child: Text(
                  '$rank',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: KpiColors.mutedText,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  item.label,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: KpiColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),

        // Bar and Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: barWidth.clamp(14, maxBarWidth),
                    height: 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: _buildStackedSegments(item.label),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${item.count}',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: KpiColors.primaryDark,
                    ),
                  ),
                ],
              ),
              if (item.detail != null) ...[
                const SizedBox(height: 2),
                Text(
                  item.detail!,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: KpiColors.secondaryText,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStackedSegments(String country) {
    switch (country) {
      case 'España':
        return Row(
          children: [
            Expanded(flex: 42, child: Container(color: KpiColors.yellow)),
            Expanded(flex: 31, child: Container(color: KpiColors.primaryDark)),
            Expanded(flex: 1, child: Container(color: KpiColors.slate)),
          ],
        );
      case 'Marruecos':
        return Row(
          children: [
            Expanded(flex: 8, child: Container(color: KpiColors.yellow)),
            Expanded(flex: 10, child: Container(color: KpiColors.primaryDark)),
          ],
        );
      case 'Venezuela':
        return Row(
          children: [
            Expanded(flex: 9, child: Container(color: KpiColors.yellow)),
            Expanded(flex: 5, child: Container(color: KpiColors.primaryDark)),
          ],
        );
      case 'Colombia':
        return Row(
          children: [
            Expanded(flex: 7, child: Container(color: KpiColors.yellow)),
            Expanded(flex: 4, child: Container(color: KpiColors.primaryDark)),
          ],
        );
      case 'Senegal':
        return Row(
          children: [
            Expanded(flex: 2, child: Container(color: KpiColors.yellow)),
            Expanded(flex: 6, child: Container(color: KpiColors.primaryDark)),
          ],
        );
      case 'Argentina':
        return Row(
          children: [
            Expanded(flex: 4, child: Container(color: KpiColors.yellow)),
            Expanded(flex: 2, child: Container(color: KpiColors.primaryDark)),
          ],
        );
      case 'Rumanía':
        return Row(
          children: [
            Expanded(flex: 4, child: Container(color: KpiColors.yellow)),
            Expanded(flex: 1, child: Container(color: KpiColors.slate)),
          ],
        );
      case 'Otras (6)':
      default:
        return Row(
          children: [
            Expanded(flex: 5, child: Container(color: KpiColors.yellow)),
            Expanded(flex: 1, child: Container(color: KpiColors.slate)),
          ],
        );
    }
  }
}
