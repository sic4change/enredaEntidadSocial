import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../kpi_colors.dart';
import '../kpi_models.dart';

class CardNacionalidades extends StatefulWidget {
  final List<NacionalidadItem> items;
  final int sinEspecificar;
  final bool isLoading;

  const CardNacionalidades({
    Key? key,
    this.items = const [],
    this.sinEspecificar = 0,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<CardNacionalidades> createState() => _CardNacionalidadesState();
}

class _CardNacionalidadesState extends State<CardNacionalidades> {
  static const int _topCount = 7;

  bool _showAll = false;

  /// Top 7 + "Otras (N)" agrupando el resto, o la lista completa si se ha
  /// pulsado "Ver todas".
  List<NacionalidadItem> get _visibleItems {
    final items = widget.items;
    if (_showAll || items.length <= _topCount + 1) return items;

    final rest = items.sublist(_topCount);
    return [
      ...items.take(_topCount),
      NacionalidadItem(
        label: 'Otras (${rest.length})',
        mujeres: rest.fold(0, (sum, i) => sum + i.mujeres),
        hombres: rest.fold(0, (sum, i) => sum + i.hombres),
        noBinario: rest.fold(0, (sum, i) => sum + i.noBinario),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = _visibleItems;
    final int maxVal =
        visibleItems.fold<int>(1, (m, i) => i.total > m ? i.total : m);

    return Container(
      decoration: BoxDecoration(
        color: KpiColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: KpiColors.cardShadow,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nacionalidades',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: KpiColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ranking por número de participantes y distribución por género',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: KpiColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isLoading) ...[
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(KpiColors.turquoise),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (widget.items.length > _topCount + 1)
                    _buildVerTodasButton(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Legend
          Row(
            children: [
              _buildLegendDot('Mujeres', KpiColors.yellow),
              const SizedBox(width: 14),
              _buildLegendDot('Hombres', KpiColors.primaryDark),
              const SizedBox(width: 14),
              _buildLegendDot('No binario', KpiColors.slate),
            ],
          ),
          const SizedBox(height: 20),

          // Ranked List
          if (visibleItems.isEmpty)
            Text(
              'Sin nacionalidades registradas en esta selección.',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: KpiColors.secondaryText,
              ),
            ),
          ...visibleItems.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildNationalityRow(index, item, maxVal),
            );
          }).toList(),

          if (widget.sinEspecificar > 0)
            Text(
              widget.sinEspecificar == 1
                  ? '1 participante sin nacionalidad registrada.'
                  : '${widget.sinEspecificar} participantes sin nacionalidad registrada.',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: KpiColors.secondaryText,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVerTodasButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => setState(() => _showAll = !_showAll),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: KpiColors.primaryDark),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _showAll ? 'Ver menos' : 'Ver todas',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: KpiColors.primaryDark,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              _showAll
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.arrow_forward_rounded,
              size: 14,
              color: KpiColors.primaryDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: KpiColors.secondaryText,
          ),
        ),
      ],
    );
  }

  String _genderDetail(NacionalidadItem item) {
    final parts = <String>[
      if (item.mujeres > 0)
        '${item.mujeres} ${item.mujeres == 1 ? 'mujer' : 'mujeres'}',
      if (item.hombres > 0)
        '${item.hombres} ${item.hombres == 1 ? 'hombre' : 'hombres'}',
      if (item.noBinario > 0) '${item.noBinario} no binario',
    ];
    return parts.join(' · ');
  }

  Widget _buildNationalityRow(int rank, NacionalidadItem item, int maxVal) {
    const double maxBarWidth = 240.0;
    final double barWidth = (item.total / maxVal) * maxBarWidth;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rank & Country Name
        SizedBox(
          width: 95,
          child: Row(
            children: [
              SizedBox(
                width: 16,
                child: Text(
                  '$rank',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: KpiColors.mutedText,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  item.label,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: KpiColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),

        // Bar and Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: SizedBox(
                      width: barWidth.clamp(14, maxBarWidth),
                      height: 16,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: _buildStackedSegments(item),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${item.total}',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: KpiColors.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                _genderDetail(item),
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: KpiColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStackedSegments(NacionalidadItem item) {
    return Row(
      children: [
        if (item.mujeres > 0)
          Expanded(flex: item.mujeres, child: Container(color: KpiColors.yellow)),
        if (item.hombres > 0)
          Expanded(
              flex: item.hombres, child: Container(color: KpiColors.primaryDark)),
        if (item.noBinario > 0)
          Expanded(flex: item.noBinario, child: Container(color: KpiColors.slate)),
      ],
    );
  }
}
