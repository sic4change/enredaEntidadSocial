import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../kpi_colors.dart';
import '../kpi_models.dart';

class CardSituacionEmpleo extends StatefulWidget {
  final List<SituacionEmpleoRow>? situacionInicialRows;
  final List<SituacionEmpleoRow>? situacionActualRows;
  final bool isLoading;

  const CardSituacionEmpleo({
    Key? key,
    this.situacionInicialRows,
    this.situacionActualRows,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<CardSituacionEmpleo> createState() => _CardSituacionEmpleoState();
}

class _CardSituacionEmpleoState extends State<CardSituacionEmpleo> {
  String _selectedTab = 'Situación inicial';

  List<SituacionEmpleoRow> get _currentRows {
    if (_selectedTab == 'Situación inicial') {
      return widget.situacionInicialRows ?? KpiFakeData.situacionEmpleoRows;
    } else {
      return widget.situacionActualRows ?? widget.situacionInicialRows ?? KpiFakeData.situacionEmpleoRows;
    }
  }

  double get _maxVal {
    final rows = _currentRows;
    for (final r in rows) {
      if (r.isTotal && r.total > 0) {
        return r.total.toDouble();
      }
    }
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final currentRows = _currentRows;
    final maxVal = _maxVal;

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
          // Header with tabs and dropdown
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 620;
              if (isSmall) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderTitles(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSituacionTabs(),
                        _buildDisaggregateChip(),
                      ],
                    ),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildHeaderTitles()),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.isLoading) ...[
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                KpiColors.turquoise),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      _buildSituacionTabs(),
                      const SizedBox(width: 12),
                      _buildDisaggregateChip(),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Horizontal scrollable table with bars
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 820,
              child: Column(
                children: [
                  // Table Legend Header
                  Row(
                    children: [
                      const SizedBox(width: 180), // Label space
                      const Expanded(child: SizedBox()), // Bars space
                      _buildHeaderCol('Mujeres', KpiColors.yellow),
                      _buildHeaderCol('Hombres', KpiColors.primaryDark),
                      _buildHeaderCol('No binario', KpiColors.slate),
                      _buildHeaderCol('Total', null),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Data rows
                  ...currentRows.map((row) {
                    if (row.isTotal) {
                      return Column(
                        children: [
                          const Divider(height: 24, color: KpiColors.divider),
                          _buildRow(row, maxVal),
                        ],
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _buildRow(row, maxVal),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTitles() {
    final subtitle = _selectedTab == 'Situación inicial'
        ? 'Cómo empiezan las personas · Fuente: informe inicial'
        : 'Situación en el último informe registrado · Fuente: informe de seguimiento / cierre';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Situación de empleo',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: KpiColors.primaryDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: KpiColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildSituacionTabs() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: KpiColors.tileBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['Situación inicial', 'Situación actual'].map((tab) {
          final isSelected = _selectedTab == tab;
          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () {
              setState(() {
                _selectedTab = tab;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                boxShadow: isSelected ? KpiColors.smallShadow : null,
              ),
              child: Text(
                tab,
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

  Widget _buildHeaderCol(String label, Color? dotColor) {
    return SizedBox(
      width: 75,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (dotColor != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: KpiColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(SituacionEmpleoRow row, double maxVal) {
    const double maxBarWidth = 280;
    final double safeMax = maxVal > 0 ? maxVal : 1.0;
    final double barWidth = safeMax > 0 ? (row.total / safeMax) * maxBarWidth : 0.0;

    return Row(
      children: [
        // Label
        SizedBox(
          width: 180,
          child: Text(
            row.label,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: row.isTotal ? FontWeight.bold : FontWeight.w500,
              color: KpiColors.primaryDark,
            ),
          ),
        ),

        // Stacked horizontal bar
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: row.total > 0 ? barWidth.clamp(6.0, maxBarWidth) : 0.0,
              height: 16,
              child: row.total > 0
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Row(
                        children: [
                          if (row.mujeres > 0)
                            Expanded(
                              flex: row.mujeres,
                              child: Container(color: KpiColors.yellow),
                            ),
                          if (row.hombres > 0)
                            Expanded(
                              flex: row.hombres,
                              child: Container(color: KpiColors.primaryDark),
                            ),
                          if (row.noBinario > 0)
                            Expanded(
                              flex: row.noBinario,
                              child: Container(color: KpiColors.slate),
                            ),
                        ],
                      ),
                    )
                  : const SizedBox(),
            ),
          ),
        ),

        // 4 Columns: Mujeres, Hombres, No binario, Total
        _buildValueCol(row.mujeres.toString(), isTotal: row.isTotal),
        _buildValueCol(row.hombres.toString(), isTotal: row.isTotal),
        _buildValueCol(row.noBinario.toString(), isTotal: row.isTotal),
        _buildValueCol(row.total.toString(), isTotal: true),
      ],
    );
  }

  Widget _buildValueCol(String val, {bool isTotal = false}) {
    return SizedBox(
      width: 75,
      child: Text(
        val,
        textAlign: TextAlign.right,
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          color: KpiColors.primaryDark,
        ),
      ),
    );
  }
}
