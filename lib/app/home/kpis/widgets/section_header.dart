import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../kpi_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;

  /// Títulos de las tarjetas de la sección, para saber qué contiene aunque
  /// esté plegada.
  final List<String> cardTitles;
  final bool isExpanded;
  final VoidCallback onToggle;

  const SectionHeader({
    Key? key,
    required this.title,
    required this.cardTitles,
    required this.isExpanded,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: KpiColors.primaryDark,
                  letterSpacing: -0.3,
                ),
              ),
              if (cardTitles.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  cardTitles.join(' / '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: KpiColors.secondaryText,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onToggle,
          child: Container(
            padding:
                const EdgeInsets.only(left: 12, right: 10, top: 5, bottom: 5),
            decoration: BoxDecoration(
              color: KpiColors.cardBackground,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                  color: KpiColors.borderLight.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isExpanded ? 'Ocultar' : 'Mostrar',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: KpiColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: KpiColors.primaryDark,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
