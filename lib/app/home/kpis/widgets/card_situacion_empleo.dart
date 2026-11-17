import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/userEnreda.dart';
import '../kpi_breakdown.dart';
import '../kpi_colors.dart';
import '../kpi_models.dart';

/// Fila de la tabla ya desagregada: un valor por grupo.
class _BreakdownRow {
  final String label;
  final List<int> values;
  final bool isIndented;
  final bool isTotal;

  const _BreakdownRow(this.label, this.values,
      {this.isIndented = false, this.isTotal = false});

  int get total => values.fold(0, (a, b) => a + b);
}

class CardSituacionEmpleo extends StatefulWidget {
  final List<SituacionEmpleoRow>? situacionInicialRows;
  final List<SituacionEmpleoRow>? situacionActualRows;
  final List<UserEnreda> users;

  /// Categoría (ver `KpiService.situacionEmpleoCategories`) por userId.
  final Map<String, int> situacionInicialPorUsuario;
  final Map<String, int> situacionActualPorUsuario;
  final bool isLoading;

  const CardSituacionEmpleo({
    Key? key,
    this.situacionInicialRows,
    this.situacionActualRows,
    this.users = const [],
    this.situacionInicialPorUsuario = const {},
    this.situacionActualPorUsuario = const {},
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<CardSituacionEmpleo> createState() => _CardSituacionEmpleoState();
}

class _CardSituacionEmpleoState extends State<CardSituacionEmpleo> {
  String _selectedTab = 'Situación inicial';
  KpiBreakdown _breakdown = KpiBreakdown.genero;

  KpiGroups get _groups => KpiGroups.of(_breakdown, widget.users);

  /// Filas de la tabla según el desglose elegido.
  List<_BreakdownRow> get _rows {
    if (_breakdown == KpiBreakdown.genero) {
      return _currentRows
          .map((r) => _BreakdownRow(
              r.label, [r.mujeres, r.hombres, r.noBinario],
              isIndented: r.isIndented, isTotal: r.isTotal))
          .toList();
    }

    final categories = _selectedTab == 'Situación inicial'
        ? widget.situacionInicialPorUsuario
        : widget.situacionActualPorUsuario;
    // Categorías: 0 corta, 1 larga, 2 otro desempleo, 3 inactiva, 4 empleada, 5 sin especificar
    final c = _groups.countByRow(widget.users, 6, (u) => categories[u.userId]);
    List<int> sum(List<int> idx) => List.generate(
        _groups.length, (g) => idx.fold(0, (a, i) => a + c[i][g]));

    final rows = [
      _BreakdownRow('Desempleadas/os', sum([0, 1, 2])),
      _BreakdownRow('Corta duración', c[0], isIndented: true),
      _BreakdownRow('Larga duración', c[1], isIndented: true),
      _BreakdownRow('Inactivas/os', c[3]),
      _BreakdownRow('Empleadas/os', c[4]),
      if (c[5].any((v) => v > 0)) _BreakdownRow('Sin especificar', c[5]),
    ];
    return [
      ...rows,
      _BreakdownRow('Total', sum([0, 1, 2, 3, 4, 5]), isTotal: true)
    ];
  }

  List<SituacionEmpleoRow> get _currentRows {
    if (_selectedTab == 'Situación inicial') {
      return widget.situacionInicialRows ?? KpiFakeData.situacionEmpleoRows;
    } else {
      return widget.situacionActualRows ??
          widget.situacionInicialRows ??
          KpiFakeData.situacionEmpleoRows;
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groups;
    final currentRows = _rows;
    final totalRow = currentRows.where((r) => r.isTotal && r.total > 0);
    final double maxVal =
        totalRow.isNotEmpty ? totalRow.first.total.toDouble() : 1.0;

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
              width: 900,
              child: Column(
                children: [
                  // Table Legend Header
                  Row(
                    children: [
                      const SizedBox(width: 180), // Label space
                      const Expanded(child: SizedBox()), // Bars space
                      for (int g = 0; g < groups.length; g++)
                        _buildHeaderCol(groups.labels[g], groups.colors[g]),
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
                          _buildRow(row, maxVal, groups),
                        ],
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _buildRow(row, maxVal, groups),
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
                  color: isSelected
                      ? KpiColors.primaryDark
                      : KpiColors.secondaryText,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDisaggregateChip() {
    return KpiBreakdownChip(
      value: _breakdown,
      onChanged: (value) => setState(() => _breakdown = value),
    );
  }

  Widget _buildHeaderCol(String label, Color? dotColor) {
    return SizedBox(
      width: 90,
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
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: KpiColors.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(_BreakdownRow row, double maxVal, KpiGroups groups) {
    const double maxBarWidth = 280;
    final double safeMax = maxVal > 0 ? maxVal : 1.0;
    final double barWidth =
        safeMax > 0 ? (row.total / safeMax) * maxBarWidth : 0.0;

    return Row(
      children: [
        // Label
        Container(
          width: 180,
          padding: EdgeInsets.only(left: row.isIndented ? 16 : 0),
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
                          for (int g = 0; g < row.values.length; g++)
                            if (row.values[g] > 0)
                              Expanded(
                                flex: row.values[g],
                                child: Container(color: groups.colors[g]),
                              ),
                        ],
                      ),
                    )
                  : const SizedBox(),
            ),
          ),
        ),

        // Una columna por grupo + Total
        for (final v in row.values)
          _buildValueCol(v.toString(), isTotal: row.isTotal),
        _buildValueCol(row.total.toString(), isTotal: true),
      ],
    );
  }

  Widget _buildValueCol(String val, {bool isTotal = false}) {
    return SizedBox(
      width: 90,
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
