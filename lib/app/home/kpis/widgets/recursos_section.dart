import 'package:flutter/material.dart';
import 'section_header.dart';
import 'card_recursos_subidos.dart';
import 'card_linea_temporal_recursos.dart';
import 'card_recursos_categoria.dart';

class RecursosSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const RecursosSection({
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
          title: 'Recursos',
          cardCount: 3,
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
                  children: const [
                    CardRecursosSubidos(),
                    SizedBox(height: 20),
                    CardLineaTemporalRecursos(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(child: CardRecursosSubidos()),
                  SizedBox(width: 20),
                  Expanded(child: CardLineaTemporalRecursos()),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          const CardRecursosCategoria(),
        ],
      ],
    );
  }
}
