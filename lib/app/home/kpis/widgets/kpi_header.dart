import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../kpi_colors.dart';
import '../kpi_models.dart';

class KpiHeader extends StatelessWidget {
  final String selectedFilterId;
  final ValueChanged<String> onFilterChanged;
  final TextEditingController searchController;
  final VoidCallback onDownloadReport;
  final List<FilterChipItem>? filterItems;

  const KpiHeader({
    Key? key,
    required this.selectedFilterId,
    required this.onFilterChanged,
    required this.searchController,
    required this.onDownloadReport,
    this.filterItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 650;
            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(),
                  const SizedBox(height: 12),
                  _buildActionsRow(),
                ],
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTitle(),
                _buildActionsRow(),
              ],
            );
          },
        ),
        const SizedBox(height: 20),

        // Search bar
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: KpiColors.cardBackground,
            borderRadius: BorderRadius.circular(999),
            boxShadow: KpiColors.smallShadow,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                size: 18,
                color: KpiColors.secondaryText,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: searchController,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: KpiColors.primaryDark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Buscar un indicador…',
                    hintStyle: GoogleFonts.outfit(
                      fontSize: 13,
                      color: KpiColors.secondaryText,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close, size: 16, color: KpiColors.secondaryText),
                  onPressed: () {
                    searchController.clear();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Filter Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: KpiColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: KpiColors.cardShadow,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  Text(
                    'Ver datos de',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: KpiColors.primaryDark,
                    ),
                  ),
                  ...(filterItems ?? KpiFakeData.filterOrganizations).map((item) {
                    final isSelected = item.id == selectedFilterId;
                    return InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => onFilterChanged(item.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? KpiColors.primaryDark
                              : KpiColors.cardBackground,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isSelected
                                ? KpiColors.primaryDark
                                : KpiColors.primaryDark,
                            width: 1,
                          ),
                        ),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              if (item.prefix != null)
                                TextSpan(
                                  text: item.prefix,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.8)
                                        : KpiColors.primaryDark.withValues(alpha: 0.7),
                                  ),
                                ),
                              TextSpan(
                                text: item.label,
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : KpiColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: KpiColors.secondaryText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'La vista de SIC4Change incluye el sumatorio de todos los proyectos de la organización. “Global” reúne los datos de todas las entidades y de otras organizaciones que colaboran o participan en Enreda.',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: KpiColors.secondaryText,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KPI',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: KpiColors.primaryDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Indicadores de participación y resultados de Enreda',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: KpiColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildActionsRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Actualizado el 06/10/2026',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: KpiColors.secondaryText,
          ),
        ),
        const SizedBox(width: 16),
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onDownloadReport,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: KpiColors.cardBackground,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: KpiColors.primaryDark,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.file_download_outlined,
                  size: 16,
                  color: KpiColors.primaryDark,
                ),
                const SizedBox(width: 6),
                Text(
                  'Descargar informe',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: KpiColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
