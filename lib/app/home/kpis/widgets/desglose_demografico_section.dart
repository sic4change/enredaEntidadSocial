import 'package:flutter/material.dart';
import '../../../models/userEnreda.dart';
import 'section_header.dart';
import 'card_grupos_edad.dart';
import 'card_niveles_formativos.dart';

class DesgloseDemograficoSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<UserEnreda>? users;
  final bool isLoading;

  const DesgloseDemograficoSection({
    Key? key,
    required this.isExpanded,
    required this.onToggle,
    this.users,
    this.isLoading = false,
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
                  children: [
                    CardGruposEdad(users: users, isLoading: isLoading),
                    const SizedBox(height: 20),
                    const CardNivelesFormativos(),
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
                  const Expanded(child: CardNivelesFormativos()),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}
