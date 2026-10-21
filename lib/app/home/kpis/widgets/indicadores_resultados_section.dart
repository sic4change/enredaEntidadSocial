import 'package:flutter/material.dart';
import 'section_header.dart';
import 'card_indicadores_clave.dart';
import 'card_recorrido_resultados.dart';
import 'card_resultados_sector.dart';

class IndicadoresResultadosSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const IndicadoresResultadosSection({
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
          title: 'Indicadores de resultados',
          cardCount: 3,
          isExpanded: isExpanded,
          onToggle: onToggle,
        ),
        if (isExpanded) ...[
          const SizedBox(height: 16),
          const CardIndicadoresClave(),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 920;
              if (isSmall) {
                return Column(
                  children: const [
                    CardRecorridoResultados(),
                    SizedBox(height: 20),
                    CardResultadosSector(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(child: CardRecorridoResultados()),
                  SizedBox(width: 20),
                  Expanded(child: CardResultadosSector()),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}
