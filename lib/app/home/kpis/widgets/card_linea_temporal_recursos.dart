import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../kpi_colors.dart';
import '../kpi_models.dart';

class CardLineaTemporalRecursos extends StatefulWidget {
  const CardLineaTemporalRecursos({Key? key}) : super(key: key);

  @override
  State<CardLineaTemporalRecursos> createState() => _CardLineaTemporalRecursosState();
}

class _CardLineaTemporalRecursosState extends State<CardLineaTemporalRecursos> {
  String _selectedPeriod = 'Año';
  int _selectedYear = 2026;
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      header: '',
      canShowMarker: true,
      format: 'point.x 2026\nRecursos : point.y',
      textStyle: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: KpiColors.primaryDark,
      ),
      color: Colors.white,
      borderColor: KpiColors.borderLight,
      borderWidth: 1,
      elevation: 4,
    );
  }

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
          // Header row with toggle
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 450;
              if (isSmall) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderTitles(),
                    const SizedBox(height: 12),
                    _buildPeriodToggle(),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildHeaderTitles()),
                  _buildPeriodToggle(),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Date stepper [<] 2026 [>]
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildArrowButton(
                icon: Icons.chevron_left,
                isEnabled: true,
                onTap: () {
                  setState(() {
                    _selectedYear--;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '$_selectedYear',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: KpiColors.primaryDark,
                  ),
                ),
              ),
              _buildArrowButton(
                icon: Icons.chevron_right,
                isEnabled: _selectedYear < 2026,
                onTap: () {
                  if (_selectedYear < 2026) {
                    setState(() {
                      _selectedYear++;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Syncfusion Spline Area Chart
          SizedBox(
            height: 220,
            child: SfCartesianChart(
              tooltipBehavior: _tooltipBehavior,
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(color: KpiColors.borderLight, width: 1),
                majorTickLines: const MajorTickLines(size: 6, color: KpiColors.borderLight),
                labelStyle: GoogleFonts.outfit(
                  fontSize: 12,
                  color: KpiColors.secondaryText,
                ),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: 28,
                interval: 7,
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                majorGridLines: const MajorGridLines(
                  width: 1,
                  color: KpiColors.divider,
                  dashArray: [4, 4],
                ),
                labelStyle: GoogleFonts.outfit(
                  fontSize: 12,
                  color: KpiColors.secondaryText,
                ),
              ),
              series: <CartesianSeries<MonthDataPoint, String>>[
                SplineAreaSeries<MonthDataPoint, String>(
                  dataSource: KpiFakeData.evolucionRecursos,
                  xValueMapper: (MonthDataPoint data, _) => data.month,
                  yValueMapper: (MonthDataPoint data, _) => data.value,
                  splineType: SplineType.natural,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      KpiColors.turquoise.withValues(alpha: 0.32),
                      KpiColors.turquoise.withValues(alpha: 0.02),
                    ],
                  ),
                  borderColor: KpiColors.turquoise,
                  borderWidth: 2.2,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    shape: DataMarkerType.circle,
                    color: Colors.white,
                    borderColor: KpiColors.turquoise,
                    borderWidth: 2,
                    width: 7,
                    height: 7,
                  ),
                  emptyPointSettings: EmptyPointSettings(
                    mode: EmptyPointMode.drop,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Bottom 3 stat cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 500;
              if (isSmall) {
                return Column(
                  children: [
                    _buildStatCard('191', 'recursos subidos $_selectedYear'),
                    const SizedBox(height: 8),
                    _buildStatCard('19,1', 'media mensual'),
                    const SizedBox(height: 8),
                    _buildStatCard('27', 'pico (septiembre)'),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: _buildStatCard('191', 'recursos subidos $_selectedYear')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('19,1', 'media mensual')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('27', 'pico (septiembre)')),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTitles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Línea temporal de recursos',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: KpiColors.primaryDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Recursos subidos por mes',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: KpiColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: KpiColors.tileBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['Semana', 'Mes', 'Año'].map((period) {
          final isSelected = _selectedPeriod == period;
          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () {
              setState(() {
                _selectedPeriod = period;
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
                period,
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

  Widget _buildArrowButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isEnabled ? KpiColors.primaryDark : KpiColors.borderLight,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 14,
          color: isEnabled ? KpiColors.primaryDark : KpiColors.borderLight,
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: KpiColors.tileBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
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
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: KpiColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
