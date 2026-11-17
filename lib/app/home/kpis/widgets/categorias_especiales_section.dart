import 'package:flutter/material.dart';
import '../../../models/userEnreda.dart';
import '../kpi_models.dart';
import '../kpi_capture.dart';
import '../kpi_search.dart';
import 'kpi_card_row.dart';
import 'section_header.dart';
import 'card_discapacidad.dart';
import 'card_nacionalidades.dart';
import 'card_condiciones_sobrevenidas.dart';
import 'card_situacion_administrativa.dart';
import 'card_competencias_reconocidas.dart';
import 'card_competencias_por_area.dart';

class CategoriasEspecialesSection extends StatelessWidget {
  static const String sectionTitle = 'Categorías especiales';
  static const List<String> cardTitles = [
    'Participantes con discapacidad',
    'Nacionalidades',
    'Condiciones sobrevenidas',
    'Situación administrativa',
    'Competencias más reconocidas',
    'Por área de competencia',
  ];

  /// Si alguna tarjeta de la sección coincide con [query].
  static bool hasMatches(String query) =>
      kpiMatchingCards(query, sectionTitle, cardTitles).isNotEmpty;

  final String searchQuery;
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<UserEnreda>? users;
  final List<NacionalidadItem> nacionalidades;
  final int nacionalidadSinEspecificar;
  final List<DonutSegment> discapacidad;
  final Map<String, int> discapacidadPorUsuario;
  final List<RankedBarItem> condicionesSobrevenidas;
  final List<DonutSegment> situacionAdministrativa;
  final int totalConInformeInicialCompleto;
  final List<RankedBarItem> competenciasReconocidas;
  final List<CompetenciaArea> competenciasPorArea;
  final List<DonutSegment> competenciasPorCategoria;
  final bool isLoading;

  const CategoriasEspecialesSection({
    Key? key,
    required this.isExpanded,
    required this.onToggle,
    this.users,
    this.nacionalidades = const [],
    this.nacionalidadSinEspecificar = 0,
    this.discapacidad = const [],
    this.discapacidadPorUsuario = const {},
    this.condicionesSobrevenidas = const [],
    this.situacionAdministrativa = const [],
    this.totalConInformeInicialCompleto = 0,
    this.competenciasReconocidas = const [],
    this.competenciasPorArea = const [],
    this.competenciasPorCategoria = const [],
    this.isLoading = false,
    this.searchQuery = '',
  }) : super(key: key);

  Widget _buildNacionalidades() => KpiCapture(
        id: 'Nacionalidades',
        child: CardNacionalidades(
          items: nacionalidades,
          sinEspecificar: nacionalidadSinEspecificar,
          isLoading: isLoading,
        ),
      );

  Widget _buildDiscapacidad() => KpiCapture(
        id: 'Participantes con discapacidad',
        child: CardDiscapacidad(
          segments: discapacidad,
          total: totalConInformeInicialCompleto,
          users: users ?? const [],
          discapacidadPorUsuario: discapacidadPorUsuario,
          isLoading: isLoading,
        ),
      );

  Widget _buildCondiciones() => KpiCapture(
        id: 'Condiciones sobrevenidas',
        child: CardCondicionesSobrevenidas(
          items: condicionesSobrevenidas,
          isLoading: isLoading,
        ),
      );

  Widget _buildCompetenciasReconocidas() => KpiCapture(
        id: 'Competencias más reconocidas',
        child: CardCompetenciasReconocidas(
          items: competenciasReconocidas,
          categories: competenciasPorCategoria,
          isLoading: isLoading,
        ),
      );

  Widget _buildCompetenciasPorArea() => KpiCapture(
        id: 'Por área de competencia',
        child: CardCompetenciasPorArea(
          areas: competenciasPorArea,
          categories: competenciasPorCategoria,
          isLoading: isLoading,
        ),
      );

  Widget _buildSituacionAdministrativa() => KpiCapture(
        id: 'Situación administrativa',
        child: CardSituacionAdministrativa(
          segments: situacionAdministrativa,
          total: totalConInformeInicialCompleto,
          isLoading: isLoading,
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (searchQuery.trim().isNotEmpty) {
      final builders = <String, Widget Function()>{
        'Participantes con discapacidad': () => _buildDiscapacidad(),
        'Nacionalidades': () => _buildNacionalidades(),
        'Condiciones sobrevenidas': () => _buildCondiciones(),
        'Situación administrativa': () => _buildSituacionAdministrativa(),
        'Competencias más reconocidas': () => _buildCompetenciasReconocidas(),
        'Por área de competencia': () => _buildCompetenciasPorArea(),
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
          title: 'Categorías especiales',
          cardTitles: cardTitles,
          isExpanded: isExpanded,
          onToggle: onToggle,
        ),
        if (isExpanded) ...[
          const SizedBox(height: 16),
          // Dos columnas con las tarjetas intercaladas (como en el diseño) y
          // la misma altura total; debajo, las competencias en una fila
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 920) {
                return Column(
                  children: [
                    _buildDiscapacidad(),
                    const SizedBox(height: 20),
                    _buildNacionalidades(),
                    const SizedBox(height: 20),
                    _buildCondiciones(),
                    const SizedBox(height: 20),
                    _buildSituacionAdministrativa(),
                    const SizedBox(height: 20),
                    _buildCompetenciasReconocidas(),
                    const SizedBox(height: 20),
                    _buildCompetenciasPorArea(),
                  ],
                );
              }
              return Column(
                children: [
                  KpiCardColumns(
                    left: [_buildDiscapacidad(), _buildCondiciones()],
                    right: [
                      _buildNacionalidades(),
                      _buildSituacionAdministrativa(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  KpiCardRow(
                    items: [
                      KpiCardRowItem(_buildCompetenciasReconocidas()),
                      KpiCardRowItem(_buildCompetenciasPorArea()),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}
