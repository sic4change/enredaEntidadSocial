import 'package:flutter/material.dart';
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

  const CategoriasEspecialesSection({
    Key? key,
    required this.isExpanded,
    required this.onToggle,
  }) : super(key: key);

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
                  children: const [
                    CardDiscapacidad(),
                    SizedBox(height: 20),
                    CardCondicionesSobrevenidas(),
                    SizedBox(height: 20),
                    CardNacionalidades(),
                    SizedBox(height: 20),
                    CardSituacionAdministrativa(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: const [
                        CardDiscapacidad(),
                        SizedBox(height: 20),
                        CardCondicionesSobrevenidas(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: const [
                        CardNacionalidades(),
                        SizedBox(height: 20),
                        CardSituacionAdministrativa(),
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
                  children: const [
                    CardCompetenciasReconocidas(),
                    SizedBox(height: 20),
                    CardCompetenciasPorArea(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(child: CardCompetenciasReconocidas()),
                  SizedBox(width: 20),
                  Expanded(child: CardCompetenciasPorArea()),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}
