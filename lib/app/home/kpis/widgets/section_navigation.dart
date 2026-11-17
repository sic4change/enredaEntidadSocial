import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../kpi_colors.dart';

class SectionNavigation extends StatelessWidget {
  final bool allExpanded;
  final VoidCallback onExpandAll;
  final VoidCallback onCollapseAll;

  const SectionNavigation({
    Key? key,
    required this.allExpanded,
    required this.onExpandAll,
    required this.onCollapseAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Secciones:',
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.normal,
            color: KpiColors.secondaryText,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: KpiColors.cardBackground,
            borderRadius: BorderRadius.circular(999),
            border:
                Border.all(color: KpiColors.borderLight.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPill(
                title: 'Desplegar todo',
                isSelected: allExpanded,
                onTap: onExpandAll,
              ),
              const SizedBox(width: 2),
              _buildPill(
                title: 'Plegar todo',
                isSelected: !allExpanded,
                onTap: onCollapseAll,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPill({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? KpiColors.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            color: isSelected ? Colors.white : KpiColors.secondaryText,
          ),
        ),
      ),
    );
  }
}
