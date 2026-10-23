import 'package:flutter/material.dart';
import '../kpi_models.dart';
import 'section_header.dart';
import 'card_discapacidad.dart';
import 'card_condiciones_sobrevenidas.dart';
import 'card_nacionalidades.dart';
import 'card_situacion_administrativa.dart';
import 'card_competencias_reconocidas.dart';
import 'card_competencias_por_area.dart';

class CategoriasEspecialesSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<DonutSegment> discapacidad;
  final List<RankedBarItem> condicionesSobrevenidas;
  final List<DonutSegment> situacionAdministrativa;
  final int totalConInformeInicialCompleto;
  final List<RankedBarItem> competenciasReconocidas;
  final List<CompetenciaArea> competenciasPorArea;
  final List<DonutSegment> competenciasPorCategoria;
  final List<NacionalidadItem> nacionalidades;
  final int nacionalidadSinEspecificar;
  final bool isLoading;

  const CategoriasEspecialesSection({
    Key? key,
    required this.isExpanded,
    required this.onToggle,
    this.discapacidad = const [],
    this.condicionesSobrevenidas = const [],
    this.situacionAdministrativa = const [],
    this.totalConInformeInicialCompleto = 0,
    this.competenciasReconocidas = const [],
    this.competenciasPorArea = const [],
    this.competenciasPorCategoria = const [],
    this.nacionalidades = const [],
    this.nacionalidadSinEspecificar = 0,
    this.isLoading = false,
  }) : super(key: key);

  Widget _buildDiscapacidad() => CardDiscapacidad(
        segments: discapacidad,
        total: totalConInformeInicialCompleto,
        isLoading: isLoading,
      );

  Widget _buildCondiciones() => CardCondicionesSobrevenidas(
        items: condicionesSobrevenidas,
        isLoading: isLoading,
      );

  Widget _buildCompetenciasReconocidas() => CardCompetenciasReconocidas(
        items: competenciasReconocidas,
        categories: competenciasPorCategoria,
        isLoading: isLoading,
      );

  Widget _buildCompetenciasPorArea() => CardCompetenciasPorArea(
        areas: competenciasPorArea,
        categories: competenciasPorCategoria,
        isLoading: isLoading,
      );

  Widget _buildNacionalidades() => CardNacionalidades(
        items: nacionalidades,
        sinEspecificar: nacionalidadSinEspecificar,
        isLoading: isLoading,
      );

  Widget _buildSituacionAdministrativa() => CardSituacionAdministrativa(
        segments: situacionAdministrativa,
        total: totalConInformeInicialCompleto,
        isLoading: isLoading,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Categorías especiales',
          cardCount: 6,
          isExpanded: isExpanded,
          onToggle: onToggle,
        ),
        if (isExpanded) ...[
          const SizedBox(height: 16),
          // Top pair of columns (Discapacidad + Condiciones on left; Nacionalidades + Admin on right)
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 920;
              if (isSmall) {
                return Column(
                  children: [
                    _buildDiscapacidad(),
                    const SizedBox(height: 20),
                    _buildCondiciones(),
                    const SizedBox(height: 20),
                    _buildNacionalidades(),
                    const SizedBox(height: 20),
                    _buildSituacionAdministrativa(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildDiscapacidad(),
                        const SizedBox(height: 20),
                        _buildCondiciones(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        _buildNacionalidades(),
                        const SizedBox(height: 20),
                        _buildSituacionAdministrativa(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Bottom pair: Competencias reconocidas + Competencias por área
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 920;
              if (isSmall) {
                return Column(
                  children: [
                    _buildCompetenciasReconocidas(),
                    const SizedBox(height: 20),
                    _buildCompetenciasPorArea(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildCompetenciasReconocidas()),
                  const SizedBox(width: 20),
                  Expanded(child: _buildCompetenciasPorArea()),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}
