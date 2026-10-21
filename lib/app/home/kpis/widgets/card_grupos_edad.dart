import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../kpi_colors.dart';
import '../kpi_models.dart';

class CardGruposEdad extends StatelessWidget {
  const CardGruposEdad({Key? key}) : super(key: key);

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
                      'Grupos de edad',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: KpiColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Distribución por grupo de edad y género',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: KpiColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              _buildCompareChip(),
            ],
          ),
          const SizedBox(height: 24),

          // Total column label
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Total',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: KpiColors.secondaryText,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Population Pyramid rows
          ...KpiFakeData.agePyramid.map((row) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: _buildPyramidRow(row),
            );
          }).toList(),
          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Mujeres', KpiColors.yellow),
              const SizedBox(width: 24),
              _buildLegendItem('Hombres', KpiColors.primaryDark),
            ],
          ),
          const SizedBox(height: 16),

          // Summary row banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: KpiColors.tileBackground.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total mujeres y hombres',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: KpiColors.primaryDark,
                  ),
                ),
                Text(
                  '81 mujeres · 58 hombres · 139',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: KpiColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Footnote non-binary
          Text(
            'Además, 3 participantes no binarios: 2 de 18 – 24 años y 1 de 25 – 29 años.',
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: KpiColors.secondaryText,
            ),
          ),
          const SizedBox(height: 20),

          // 4 Tramos FSE Stat Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 420;
              if (isSmall) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSmallStat('11', 'Menores de 18', width: (constraints.maxWidth - 8) / 2),
                    _buildSmallStat('87', 'Jóvenes 18 – 29', width: (constraints.maxWidth - 8) / 2),
                    _buildSmallStat('8', 'Mayores de 54', width: (constraints.maxWidth - 8) / 2),
                    _buildSmallStat('68', 'Origen extranjero', width: (constraints.maxWidth - 8) / 2),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: _buildSmallStat('11', 'Menores de 18')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSmallStat('87', 'Jóvenes 18 – 29')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSmallStat('8', 'Mayores de 54')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSmallStat('68', 'Origen extranjero')),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompareChip() {
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
            'Comparar: Género',
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

  Widget _buildPyramidRow(AgePyramidRow row) {
    const double maxSideWidth = 110.0;
    const double maxVal = 32.0;

    final double widthMujeres = (row.mujeres / maxVal) * maxSideWidth;
    final double widthHombres = (row.hombres / maxVal) * maxSideWidth;

    return Row(
      children: [
        // Left Label
        SizedBox(
          width: 85,
          child: Text(
            row.label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: KpiColors.secondaryText,
            ),
          ),
        ),

        // Pyramid Area (Mujeres left, axis, Hombres right)
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mujeres bar going left
              SizedBox(
                width: maxSideWidth + 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${row.mujeres}',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: KpiColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: widthMujeres.clamp(4, maxSideWidth),
                      height: 16,
                      decoration: BoxDecoration(
                        color: KpiColors.yellow,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),

              // Center vertical axis line
              Container(
                width: 2,
                height: 24,
                color: KpiColors.borderLight,
              ),

              // Hombres bar going right
              SizedBox(
                width: maxSideWidth + 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: widthHombres.clamp(4, maxSideWidth),
                      height: 16,
                      decoration: BoxDecoration(
                        color: KpiColors.primaryDark,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${row.hombres}',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: KpiColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Total Column
        SizedBox(
          width: 35,
          child: Text(
            '${row.total}',
            textAlign: TextAlign.right,
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

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
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

  Widget _buildSmallStat(String val, String label, {double? width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: KpiColors.tileBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            val,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: KpiColors.primaryDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.normal,
              color: KpiColors.secondaryText,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
