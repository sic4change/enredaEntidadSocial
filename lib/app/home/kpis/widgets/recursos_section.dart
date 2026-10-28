import 'package:flutter/material.dart';
import '../kpi_service.dart';
import '../kpi_search.dart';
import 'section_header.dart';
import 'card_recursos_subidos.dart';
import 'card_linea_temporal_recursos.dart';
import 'card_recursos_categoria.dart';

class RecursosSection extends StatelessWidget {
  static const String sectionTitle = 'Recursos';
  static const List<String> cardTitles = [
    'Recursos subidos',
    'Línea temporal de recursos',
    'Recursos por categoría',
  ];

  /// Si alguna tarjeta de la sección coincide con [query].
  static bool hasMatches(String query) =>
      kpiMatchingCards(query, sectionTitle, cardTitles).isNotEmpty;

  final String searchQuery;
  final bool isExpanded;
  final VoidCallback onToggle;
  final RecursosKpiData? data;
  final bool isLoading;

  const RecursosSection({
    Key? key,
    required this.isExpanded,
    required this.onToggle,
    this.data,
    this.isLoading = false,
    this.searchQuery = '',
  }) : super(key: key);

  Widget _buildRecursosSubidos() => CardRecursosSubidos(
        total: data?.total ?? 0,
        esteMes: data?.esteMes ?? 0,
        porCategoria: data?.porCategoria ?? const [],
        isLoading: isLoading,
      );

  Widget _buildLineaTemporal() => CardLineaTemporalRecursos(
        fechas: data?.fechas ?? const [],
        isLoading: isLoading,
      );

  @override
  Widget build(BuildContext context) {
    if (searchQuery.trim().isNotEmpty) {
      final builders = <String, Widget Function()>{
        'Recursos subidos': () => _buildRecursosSubidos(),
        'Línea temporal de recursos': () => _buildLineaTemporal(),
        'Recursos por categoría': () => CardRecursosCategoria(
            items: data?.porInteres ?? const [],
            conInteres: data?.conInteres ?? 0,
            total: data?.total ?? 0,
            isLoading: isLoading),
      };
      return KpiSearchResults(
        sectionTitle: sectionTitle,
        onToggle: onToggle,
        cards: kpiMatchingCards(searchQuery, sectionTitle, cardTitles)
            .map((t) => builders[t]!())
            .toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recursos',
          cardCount: 3,
          isExpanded: isExpanded,
          onToggle: onToggle,
        ),
        if (isExpanded) ...[
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 920;
              if (isSmall) {
                return Column(
                  children: [
                    _buildRecursosSubidos(),
                    const SizedBox(height: 20),
                    _buildLineaTemporal(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildRecursosSubidos()),
                  const SizedBox(width: 20),
                  Expanded(child: _buildLineaTemporal()),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          CardRecursosCategoria(
            items: data?.porInteres ?? const [],
            conInteres: data?.conInteres ?? 0,
            total: data?.total ?? 0,
            isLoading: isLoading,
          ),
        ],
      ],
    );
  }
}
