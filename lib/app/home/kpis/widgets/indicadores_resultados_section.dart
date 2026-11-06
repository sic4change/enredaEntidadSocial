import 'package:flutter/material.dart';
import '../kpi_models.dart';
import '../kpi_search.dart';
import 'section_header.dart';
import 'card_indicadores_clave.dart';
import 'card_recorrido_resultados.dart';
import 'card_resultados_sector.dart';

class IndicadoresResultadosSection extends StatelessWidget {
  static const String sectionTitle = 'Indicadores de resultados';
  static const List<String> cardTitles = [
    'Indicadores clave',
    'Recorrido de resultados',
    'Resultados por sector',
  ];

  static const Map<String, List<String>> searchAliases = {
    'Indicadores clave': [
      'Ingreso a formación',
      'Cualificaciones obtenidas',
      'Empleos conseguidos',
      'Mantenimiento del empleo',
      'CV realizado en Enreda'
    ],
  };

  /// Si alguna tarjeta de la sección coincide con [query].
  static bool hasMatches(String query) =>
      kpiMatchingCards(query, sectionTitle, cardTitles, aliases: searchAliases)
          .isNotEmpty;

  final String searchQuery;
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
    this.searchQuery = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (searchQuery.trim().isNotEmpty) {
      final builders = <String, Widget Function()>{
        'Indicadores clave': () => CardIndicadoresClave(
            indicators: indicadoresClave, isLoading: isLoading),
        'Recorrido de resultados': () => CardRecorridoResultados(
            steps: recorridoResultados, isLoading: isLoading),
        'Resultados por sector': () => CardResultadosSector(
            items: resultadosPorSector, isLoading: isLoading),
      };
      return KpiSearchResults(
        sectionTitle: sectionTitle,
        onToggle: onToggle,
        cardTitles: kpiMatchingCards(searchQuery, sectionTitle, cardTitles,
            aliases: searchAliases),
        buildCard: (t) => builders[t]!(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Indicadores de resultados',
          cardTitles: cardTitles,
          isExpanded: isExpanded,
          onToggle: onToggle,
        ),
        if (isExpanded) ...[
          const SizedBox(height: 16),
          CardIndicadoresClave(
              indicators: indicadoresClave, isLoading: isLoading),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 920;
              if (isSmall) {
                return Column(
                  children: [
                    CardRecorridoResultados(
                        steps: recorridoResultados, isLoading: isLoading),
                    const SizedBox(height: 20),
                    CardResultadosSector(
                        items: resultadosPorSector, isLoading: isLoading),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: CardRecorridoResultados(
                          steps: recorridoResultados, isLoading: isLoading)),
                  const SizedBox(width: 20),
                  Expanded(
                      child: CardResultadosSector(
                          items: resultadosPorSector, isLoading: isLoading)),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}
