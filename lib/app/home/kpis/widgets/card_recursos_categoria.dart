import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../kpi_colors.dart';
import '../kpi_models.dart';

class CardRecursosCategoria extends StatelessWidget {
  final List<RankedBarItem> items;
  final int conInteres;
  final int total;
  final bool isLoading;

  const CardRecursosCategoria({
    Key? key,
    this.items = const [],
    this.conInteres = 0,
    this.total = 0,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int pctConInteres =
        total > 0 ? (conInteres / total * 100).round() : 0;
    final double maxCount =
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
                  'Recursos por categoría',
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
            'Según el ámbito de actuación · $conInteres de $total recursos lo tienen informado ($pctConInteres%) · un recurso puede tener varios',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: KpiColors.secondaryText,
            ),
          ),
          const SizedBox(height: 24),

          // Scrollable bar chart, one bar per ámbito
          if (items.isEmpty)
            Text(
              'Sin recursos con ámbito de actuación informado.',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: KpiColors.secondaryText,
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: math.max(constraints.maxWidth, items.length * 72.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 210,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: items.map((item) {
                            const double maxBarHeight = 150.0;
                            final double barHeight =
                                (item.count / maxCount) * maxBarHeight;

                            return Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Count & percentage on top
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
                                      const SizedBox(width: 3),
                                      Text(
                                        '${(item.percentage ?? 0).round()}%',
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          color: KpiColors.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  // Bar
                                  Container(
                                    width: 36,
                                    height: barHeight.clamp(12, maxBarHeight),
                                    decoration: const BoxDecoration(
                                      color: KpiColors.turquoise,
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(4)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // Axis line
                      Container(
                        height: 1,
                        color: KpiColors.borderLight,
                      ),
                      const SizedBox(height: 10),

                      // Category labels
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: items.map((item) {
                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2.0),
                              child: Text(
                                item.label,
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  color: KpiColors.primaryDark,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
