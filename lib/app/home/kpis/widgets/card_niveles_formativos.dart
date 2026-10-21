import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../kpi_colors.dart';
import '../kpi_models.dart';

class CardNivelesFormativos extends StatefulWidget {
  const CardNivelesFormativos({Key? key}) : super(key: key);

  @override
  State<CardNivelesFormativos> createState() => _CardNivelesFormativosState();
}

class _CardNivelesFormativosState extends State<CardNivelesFormativos> {
  String _selectedMode = 'Nivel CINE';

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
          // Header with toggle
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 500;
              if (isSmall) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderTitles(),
                    const SizedBox(height: 12),
                    _buildModeToggle(),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildHeaderTitles()),
                  _buildModeToggle(),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Controls row: Dropdown + Gender legend
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 450;
              if (isSmall) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDisaggregateChip(),
                    const SizedBox(height: 10),
                    _buildLegend(),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDisaggregateChip(),
                  _buildLegend(),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Vertical stacked bar chart
          _buildVerticalStackedBars(),
          const SizedBox(height: 24),

          // Descriptions for each CINE level
          ...KpiFakeData.formatLevels.map((lvl) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${lvl.cineLabel}: ',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: KpiColors.primaryDark,
                      ),
                    ),
                    TextSpan(
                      text: '${lvl.description}\n',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: KpiColors.secondaryText,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildHeaderTitles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Niveles formativos',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: KpiColors.primaryDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Nivel máximo de estudios completado',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: KpiColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: KpiColors.tileBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['Nivel CINE', 'Nivel de estudios'].map((mode) {
          final isSelected = _selectedMode == mode;
          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () {
              setState(() {
                _selectedMode = mode;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                boxShadow: isSelected ? KpiColors.smallShadow : null,
              ),
              child: Text(
                mode,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? KpiColors.primaryDark : KpiColors.secondaryText,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDisaggregateChip() {
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
            'Desagregar por: Género',
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

  Widget _buildLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLegendItem('Mujeres', KpiColors.yellow),
        const SizedBox(width: 12),
        _buildLegendItem('Hombres', KpiColors.primaryDark),
        const SizedBox(width: 12),
        _buildLegendItem('No binario', KpiColors.slate),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
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

  Widget _buildVerticalStackedBars() {
    const double maxBarHeight = 160.0;
    const double maxCount = 75.0;

    return Column(
      children: [
        SizedBox(
          height: maxBarHeight + 35,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: KpiFakeData.formatLevels.map((item) {
              final barTotalHeight = (item.total / maxCount) * maxBarHeight;
              final hMujeres = (item.mujeres / item.total) * barTotalHeight;
              final hHombres = (item.hombres / item.total) * barTotalHeight;
              final hNoBinario = (item.noBinario / item.total) * barTotalHeight;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Label on top
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${item.total}',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: KpiColors.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.percentage.round()}%',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: KpiColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Stacked column
                  SizedBox(
                    width: 54,
                    height: barTotalHeight,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (item.noBinario > 0)
                            Container(
                              height: hNoBinario.clamp(2, maxBarHeight),
                              color: KpiColors.slate,
                            ),
                          if (item.hombres > 0)
                            Container(
                              height: hHombres.clamp(4, maxBarHeight),
                              color: KpiColors.primaryDark,
                            ),
                          if (item.mujeres > 0)
                            Container(
                              height: hMujeres.clamp(4, maxBarHeight),
                              color: KpiColors.yellow,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),

        // X-Axis Line
        Container(
          height: 1,
          color: KpiColors.borderLight,
        ),
        const SizedBox(height: 8),

        // X-Axis labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: KpiFakeData.formatLevels.map((item) {
            return SizedBox(
              width: 80,
              child: Text(
                item.cineLabel,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: KpiColors.primaryDark,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
