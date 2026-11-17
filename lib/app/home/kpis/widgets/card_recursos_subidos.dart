import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../kpi_colors.dart';
import '../kpi_models.dart';

class CardRecursosSubidos extends StatelessWidget {
  final int total;
  final int esteMes;
  final List<DonutSegment> porCategoria;
  final bool isLoading;

  const CardRecursosSubidos({
    Key? key,
    this.total = 0,
    this.esteMes = 0,
    this.porCategoria = const [],
    this.isLoading = false,
  }) : super(key: key);

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
            children: [
              Expanded(
                child: Text(
                  'Recursos subidos',
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
                    valueColor:
                        AlwaysStoppedAnimation<Color>(KpiColors.turquoise),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Total acumulado desde el inicio',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: KpiColors.secondaryText,
            ),
          ),
          const SizedBox(height: 20),

          // Big number row + Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                total == 1 ? 'recurso' : 'recursos',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: KpiColors.secondaryText,
                ),
              ),
              const SizedBox(width: 14),
              if (esteMes > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: KpiColors.lightTurquoise,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '▲ $esteMes este mes',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: KpiColors.primaryDark,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: KpiColors.divider),
          const SizedBox(height: 20),

          // Por tipología
          Text(
            'Por categoría',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: KpiColors.primaryDark,
            ),
          ),
          const SizedBox(height: 16),

          // Donut + Legend
          if (porCategoria.isEmpty)
            Text(
              'Sin recursos registrados.',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: KpiColors.secondaryText,
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 460;
                if (isSmall) {
                  return Column(
                    children: [
                      _buildDonutChart(),
                      const SizedBox(height: 16),
                      _buildLegend(),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildDonutChart(),
                    const SizedBox(width: 20),
                    Expanded(child: _buildLegend()),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDonutChart() {
    final top = porCategoria.reduce((a, b) => b.count > a.count ? b : a);

    return SizedBox(
      width: 170,
      height: 170,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SfCircularChart(
            margin: EdgeInsets.zero,
            series: <CircularSeries<DonutSegment, String>>[
              DoughnutSeries<DonutSegment, String>(
                dataSource: porCategoria,
                xValueMapper: (DonutSegment data, _) => data.label,
                yValueMapper: (DonutSegment data, _) => data.count,
                pointColorMapper: (DonutSegment data, _) => data.color,
                innerRadius: '68%',
                radius: '100%',
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${top.percentage.round()}%',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: KpiColors.primaryDark,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: 100,
                child: Text(
                  top.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: KpiColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: porCategoria.map((item) {
        // Separador entre categorías (no tras la última)
        final isLast = identical(item, porCategoria.last);
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(color: KpiColors.divider),
                  ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: item.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        item.label,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: KpiColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
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
                  const SizedBox(width: 6),
                  Text(
                    '${item.percentage.round()}%',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: KpiColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
