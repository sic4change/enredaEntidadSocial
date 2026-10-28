import 'package:flutter/material.dart';
import '../kpi_models.dart';
import 'section_header.dart';
import 'card_indicadores_clave.dart';
import 'card_recorrido_resultados.dart';
import 'card_resultados_sector.dart';

class IndicadoresResultadosSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<KeyIndicatorMetric> indicadoresClave;
  final List<FunnelStep> recorridoResultados;
  final List<RankedBarItem> resultadosPorSector;
  final bool isLoading;

  const IndicadoresResultadosSection({
    Key? key,
    required this.isExpanded,
    required this.onToggle,
    this.indicadoresClave = const [],
    this.recorridoResultados = const [],
    this.resultadosPorSector = const [],
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Indicadores de resultados',
          cardCount: 3,
          isExpanded: isExpanded,
          onToggle: onToggle,
        ),
        if (isExpanded) ...[
          const SizedBox(height: 16),
          CardIndicadoresClave(indicators: indicadoresClave, isLoading: isLoading),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 920;
              if (isSmall) {
                return Column(
                  children: [
                    CardRecorridoResultados(steps: recorridoResultados, isLoading: isLoading),
                    const SizedBox(height: 20),
                    CardResultadosSector(items: resultadosPorSector, isLoading: isLoading),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: CardRecorridoResultados(steps: recorridoResultados, isLoading: isLoading)),
                  const SizedBox(width: 20),
                  Expanded(child: CardResultadosSector(items: resultadosPorSector, isLoading: isLoading)),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}
