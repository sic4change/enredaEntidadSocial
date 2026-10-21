import 'package:flutter/material.dart';
import 'section_header.dart';
import 'card_grupos_edad.dart';
import 'card_niveles_formativos.dart';

class DesgloseDemograficoSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const DesgloseDemograficoSection({
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
                  children: const [
                    CardGruposEdad(),
                    SizedBox(height: 20),
                    CardNivelesFormativos(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(child: CardGruposEdad()),
                  SizedBox(width: 20),
                  Expanded(child: CardNivelesFormativos()),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}
