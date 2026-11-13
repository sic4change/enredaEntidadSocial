import 'package:flutter/material.dart';
import '../kpi_capture.dart';
import '../kpi_search.dart';
import 'section_header.dart';
import 'card_participantes_inscritos.dart';
import 'card_evolucion_inscripciones.dart';
import 'card_situacion_empleo.dart';

import '../kpi_service.dart';

class ResumenGeneralSection extends StatelessWidget {
  static const String sectionTitle = 'Resumen general';
  static const List<String> cardTitles = [
    'Participantes inscritos',
    'Evolución de inscripciones',
    'Situación de empleo',
  ];

  /// Si alguna tarjeta de la sección coincide con [query].
  static bool hasMatches(String query) =>
      kpiMatchingCards(query, sectionTitle, cardTitles).isNotEmpty;

  final String searchQuery;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ParticipantesKpiData? participantesData;
  final bool isLoadingParticipantes;

  const ResumenGeneralSection({
    Key? key,
    required this.isExpanded,
    required this.onToggle,
    this.participantesData,
    this.isLoadingParticipantes = false,
    this.searchQuery = '',
  }) : super(key: key);

  Widget _buildInscritos() => KpiCapture(
        id: 'Participantes inscritos',
        child: CardParticipantesInscritos(
            data: participantesData, isLoading: isLoadingParticipantes),
      );

  Widget _buildEvolucion() => KpiCapture(
        id: 'Evolución de inscripciones',
        child: CardEvolucionInscripciones(
            users: participantesData?.users, isLoading: isLoadingParticipantes),
      );

  Widget _buildSituacionEmpleo() => KpiCapture(
        id: 'Situación de empleo',
        child: CardSituacionEmpleo(
            situacionInicialRows: participantesData?.situacionEmpleoInicial,
            situacionActualRows: participantesData?.situacionEmpleoActual,
            users: participantesData?.users ?? const [],
            situacionInicialPorUsuario:
                participantesData?.situacionInicialPorUsuario ?? const {},
            situacionActualPorUsuario:
                participantesData?.situacionActualPorUsuario ?? const {},
            isLoading: isLoadingParticipantes),
      );

  @override
  Widget build(BuildContext context) {
    if (searchQuery.trim().isNotEmpty) {
      final builders = <String, Widget Function()>{
        'Participantes inscritos': _buildInscritos,
        'Evolución de inscripciones': _buildEvolucion,
        'Situación de empleo': _buildSituacionEmpleo,
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
          title: 'Resumen general',
          cardTitles: cardTitles,
          isExpanded: isExpanded,
          onToggle: onToggle,
        ),
        if (isExpanded) ...[
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 980;
              if (isSmall) {
                return Column(
                  children: [
                    _buildInscritos(),
                    const SizedBox(height: 20),
                    _buildEvolucion(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 360,
                    child: _buildInscritos(),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildEvolucion(),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          _buildSituacionEmpleo(),
        ],
      ],
    );
  }
}
