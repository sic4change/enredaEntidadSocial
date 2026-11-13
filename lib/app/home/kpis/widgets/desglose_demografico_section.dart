import 'package:flutter/material.dart';
import '../../../models/userEnreda.dart';
import '../kpi_models.dart';
import '../kpi_capture.dart';
import '../kpi_search.dart';
import 'section_header.dart';
import 'card_grupos_edad.dart';
import 'card_niveles_formativos.dart';
import 'card_nacionalidades.dart';
import 'card_discapacidad.dart';

class DesgloseDemograficoSection extends StatelessWidget {
  static const String sectionTitle = 'Desglose demográfico';
  static const List<String> cardTitles = [
    'Grupos de edad',
    'Niveles formativos',
    'Nacionalidades',
    'Participantes con discapacidad',
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
  final List<NacionalidadItem> nacionalidades;
  final int nacionalidadSinEspecificar;
  final List<DonutSegment> discapacidad;
  final int totalConInformeInicialCompleto;
  final Map<String, int> discapacidadPorUsuario;
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
    this.nacionalidades = const [],
    this.nacionalidadSinEspecificar = 0,
    this.discapacidad = const [],
    this.totalConInformeInicialCompleto = 0,
    this.discapacidadPorUsuario = const {},
    this.isLoading = false,
    this.searchQuery = '',
  }) : super(key: key);

  Widget _buildGruposEdad() => KpiCapture(
        id: 'Grupos de edad',
        child: CardGruposEdad(users: users, isLoading: isLoading),
      );

  Widget _buildNivelesFormativos() => KpiCapture(
        id: 'Niveles formativos',
        child: CardNivelesFormativos(
          nivelesCine: nivelesCine,
          nivelesEstudios: nivelesEstudios,
          sinEspecificar: nivelesSinEspecificar,
          users: users ?? const [],
          cinePorUsuario: nivelCinePorUsuario,
          estudiosPorUsuario: nivelEstudiosPorUsuario,
          isLoading: isLoading,
        ),
      );

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

  /// Dos tarjetas lado a lado, o apiladas en pantallas estrechas.
  Widget _pair(Widget left, Widget right) => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 920) {
            return Column(
              children: [left, const SizedBox(height: 20), right],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              const SizedBox(width: 20),
              Expanded(child: right),
            ],
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    if (searchQuery.trim().isNotEmpty) {
      final builders = <String, Widget Function()>{
        'Grupos de edad': () => _buildGruposEdad(),
        'Niveles formativos': () => _buildNivelesFormativos(),
        'Nacionalidades': () => _buildNacionalidades(),
        'Participantes con discapacidad': () => _buildDiscapacidad(),
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
          title: 'Desglose demográfico',
          cardTitles: cardTitles,
          isExpanded: isExpanded,
          onToggle: onToggle,
        ),
        if (isExpanded) ...[
          const SizedBox(height: 16),
          _pair(_buildGruposEdad(), _buildNivelesFormativos()),
          const SizedBox(height: 20),
          _pair(_buildNacionalidades(), _buildDiscapacidad()),
        ],
      ],
    );
  }
}
