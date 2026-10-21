import 'package:flutter/material.dart';
import 'section_header.dart';
import 'card_participantes_inscritos.dart';
import 'card_evolucion_inscripciones.dart';
import 'card_situacion_empleo.dart';

class ResumenGeneralSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const ResumenGeneralSection({
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
                  children: const [
                    CardParticipantesInscritos(),
                    SizedBox(height: 20),
                    CardEvolucionInscripciones(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(
                    width: 360,
                    child: CardParticipantesInscritos(),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: CardEvolucionInscripciones(),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          const CardSituacionEmpleo(),
        ],
      ],
    );
  }
}
