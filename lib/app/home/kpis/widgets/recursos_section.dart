import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../kpi_colors.dart';
import '../kpi_service.dart';
import '../kpi_capture.dart';
import '../kpi_search.dart';
import 'kpi_card_row.dart';
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

  Widget _buildRecursosSubidos() => KpiCapture(
        id: 'Recursos subidos',
        child: CardRecursosSubidos(
          total: data?.total ?? 0,
          esteMes: data?.esteMes ?? 0,
          porCategoria: data?.porCategoria ?? const [],
          isLoading: isLoading,
        ),
      );

  Widget _buildLineaTemporal() => KpiCapture(
        id: 'Línea temporal de recursos',
        child: CardLineaTemporalRecursos(
          fechas: data?.fechas ?? const [],
          isLoading: isLoading,
        ),
      );

  Widget _buildRecursosCategoria() => KpiCapture(
        id: 'Recursos por categoría',
        child: CardRecursosCategoria(
          items: data?.porInteres ?? const [],
          conInteres: data?.conInteres ?? 0,
          total: data?.total ?? 0,
          isLoading: isLoading,
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (searchQuery.trim().isNotEmpty) {
      final builders = <String, Widget Function()>{
        'Recursos subidos': () => _buildRecursosSubidos(),
        'Línea temporal de recursos': () => _buildLineaTemporal(),
        'Recursos por categoría': () => _buildRecursosCategoria(),
      };
      return KpiSearchResults(
        sectionTitle: sectionTitle,
        onToggle: onToggle,
        cardTitles: kpiMatchingCards(searchQuery, sectionTitle, cardTitles),
        buildCard: (t) => builders[t]!(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recursos',
          cardTitles: cardTitles,
          isExpanded: isExpanded,
          onToggle: onToggle,
        ),
        if (isExpanded) ...[
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                size: 16,
                color: KpiColors.secondaryText,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Los recursos no se categorizan por programa, de manera que estos datos son representativos del total de recursos de la plataforma.',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: KpiColors.secondaryText,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
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
              return KpiCardRow(
                items: [
                  KpiCardRowItem(_buildRecursosSubidos()),
                  KpiCardRowItem(_buildLineaTemporal()),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          _buildRecursosCategoria(),
        ],
      ],
    );
  }
}
