import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    if (searchQuery.trim().isNotEmpty) {
      final builders = <String, Widget Function()>{
        'Participantes inscritos': () => CardParticipantesInscritos(
            data: participantesData, isLoading: isLoadingParticipantes),
        'Evolución de inscripciones': () => CardEvolucionInscripciones(
            users: participantesData?.users, isLoading: isLoadingParticipantes),
        'Situación de empleo': () => CardSituacionEmpleo(
            situacionInicialRows: participantesData?.situacionEmpleoInicial,
            situacionActualRows: participantesData?.situacionEmpleoActual,
            users: participantesData?.users ?? const [],
            situacionInicialPorUsuario:
                participantesData?.situacionInicialPorUsuario ?? const {},
            situacionActualPorUsuario:
                participantesData?.situacionActualPorUsuario ?? const {},
            isLoading: isLoadingParticipantes),
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
          title: 'Resumen general',
          cardCount: 3,
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
                    CardParticipantesInscritos(
                      data: participantesData,
                      isLoading: isLoadingParticipantes,
                    ),
                    const SizedBox(height: 20),
                    CardEvolucionInscripciones(
                      users: participantesData?.users,
                      isLoading: isLoadingParticipantes,
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 360,
                    child: CardParticipantesInscritos(
                      data: participantesData,
                      isLoading: isLoadingParticipantes,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: CardEvolucionInscripciones(
                      users: participantesData?.users,
                      isLoading: isLoadingParticipantes,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          CardSituacionEmpleo(
            situacionInicialRows: participantesData?.situacionEmpleoInicial,
            situacionActualRows: participantesData?.situacionEmpleoActual,
            users: participantesData?.users ?? const [],
            situacionInicialPorUsuario:
                participantesData?.situacionInicialPorUsuario ?? const {},
            situacionActualPorUsuario:
                participantesData?.situacionActualPorUsuario ?? const {},
            isLoading: isLoadingParticipantes,
          ),
        ],
      ],
    );
  }
}
