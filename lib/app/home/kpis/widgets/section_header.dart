import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../kpi_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final int cardCount;
  final bool isExpanded;
  final VoidCallback onToggle;

  const SectionHeader({
    Key? key,
    required this.title,
    required this.cardCount,
    required this.isExpanded,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: KpiColors.cardBackground,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                    color: KpiColors.borderLight.withValues(alpha: 0.5)),
              ),
              child: Text(
                '$cardCount ${cardCount == 1 ? "tarjeta" : "tarjetas"}',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: KpiColors.secondaryText,
                ),
              ),
            ),
          ],
        ),
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
