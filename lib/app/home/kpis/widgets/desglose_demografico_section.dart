import 'package:flutter/material.dart';
import '../../../models/userEnreda.dart';
import '../kpi_models.dart';
import '../kpi_search.dart';
import 'section_header.dart';
import 'card_grupos_edad.dart';
import 'card_niveles_formativos.dart';

class DesgloseDemograficoSection extends StatelessWidget {
  static const String sectionTitle = 'Desglose demográfico';
  static const List<String> cardTitles = [
    'Grupos de edad',
    'Niveles formativos',
  ];

  /// Si alguna tarjeta de la sección coincide con [query].
  static bool hasMatches(String query) =>
      kpiMatchingCards(query, sectionTitle, cardTitles).isNotEmpty;

  final String searchQuery;
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<UserEnreda>? users;
  final List<FormatLevelItem> nivelesCine;
  final List<FormatLevelItem> nivelesEstudios;
  final int nivelesSinEspecificar;
  final Map<String, int> nivelCinePorUsuario;
  final Map<String, int> nivelEstudiosPorUsuario;
  final bool isLoading;

  const DesgloseDemograficoSection({
    Key? key,
    required this.isExpanded,
    required this.onToggle,
    this.users,
    this.nivelesCine = const [],
    this.nivelesEstudios = const [],
    this.nivelesSinEspecificar = 0,
    this.nivelCinePorUsuario = const {},
    this.nivelEstudiosPorUsuario = const {},
    this.isLoading = false,
    this.searchQuery = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (searchQuery.trim().isNotEmpty) {
      final builders = <String, Widget Function()>{
        'Grupos de edad': () =>
            CardGruposEdad(users: users, isLoading: isLoading),
        'Niveles formativos': () => _buildNivelesFormativos(),
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
          title: 'Desglose demográfico',
          cardCount: 2,
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
                    CardGruposEdad(users: users, isLoading: isLoading),
                    const SizedBox(height: 20),
                    _buildNivelesFormativos(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CardGruposEdad(users: users, isLoading: isLoading),
                  ),
                  const SizedBox(width: 20),
                  Expanded(child: _buildNivelesFormativos()),
                ],
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildNivelesFormativos() {
    return CardNivelesFormativos(
      nivelesCine: nivelesCine,
      nivelesEstudios: nivelesEstudios,
      sinEspecificar: nivelesSinEspecificar,
      users: users ?? const [],
      cinePorUsuario: nivelCinePorUsuario,
      estudiosPorUsuario: nivelEstudiosPorUsuario,
      isLoading: isLoading,
    );
  }
}
