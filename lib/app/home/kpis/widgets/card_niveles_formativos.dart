import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/userEnreda.dart';
import '../kpi_breakdown.dart';
import '../kpi_colors.dart';
import '../kpi_models.dart';

class CardNivelesFormativos extends StatefulWidget {
  final List<FormatLevelItem> nivelesCine;
  final List<FormatLevelItem> nivelesEstudios;
  final int sinEspecificar;
  final List<UserEnreda> users;

  /// Índice en [nivelesCine] / [nivelesEstudios] de cada participante (por userId).
  final Map<String, int> cinePorUsuario;
  final Map<String, int> estudiosPorUsuario;
  final bool isLoading;

  const CardNivelesFormativos({
    Key? key,
    this.nivelesCine = const [],
    this.nivelesEstudios = const [],
    this.sinEspecificar = 0,
    this.users = const [],
    this.cinePorUsuario = const {},
    this.estudiosPorUsuario = const {},
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<CardNivelesFormativos> createState() => _CardNivelesFormativosState();
}

class _CardNivelesFormativosState extends State<CardNivelesFormativos> {
  String _selectedMode = 'Nivel CINE';

  bool get _isCineMode => _selectedMode == 'Nivel CINE';
  KpiBreakdown _breakdown = KpiBreakdown.genero;

  KpiGroups get _groups => KpiGroups.of(_breakdown, widget.users);

  /// Valores por grupo (género o nacionalidad) de cada nivel.
  List<List<int>> _segments(
      List<FormatLevelItem> levels, Map<String, int> porUsuario) {
    if (_breakdown == KpiBreakdown.genero) {
      return levels.map((l) => [l.mujeres, l.hombres, l.noBinario]).toList();
    }
    return _groups.countByRow(
        widget.users, levels.length, (u) => porUsuario[u.userId]);
  }

  @override
  Widget build(BuildContext context) {
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
          // Header with toggle
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 500;
              if (isSmall) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderTitles(),
                    const SizedBox(height: 12),
                    _buildHeaderActions(),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildHeaderTitles()),
                  _buildHeaderActions(),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Controls row: Dropdown + Gender legend
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 450;
              if (isSmall) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDisaggregateChip(),
                    const SizedBox(height: 10),
                    _buildLegend(),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDisaggregateChip(),
                  _buildLegend(),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          if (_isCineMode) ...[
            // Vertical stacked bar chart
            _buildVerticalStackedBars(),
            const SizedBox(height: 24),

            // Descriptions for each CINE level
            ..._buildCineDescriptions(),
          ] else
            _buildHorizontalStackedBars(),

          if (widget.sinEspecificar > 0) ...[
            const SizedBox(height: 8),
            Text(
              widget.sinEspecificar == 1
                  ? '1 participante sin nivel formativo registrado.'
                  : '${widget.sinEspecificar} participantes sin nivel formativo registrado.',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: KpiColors.secondaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildCineDescriptions() {
    final groups = _groups;
    final segments = _segments(widget.nivelesCine, widget.cinePorUsuario);
    return widget.nivelesCine.asMap().entries.map((entry) {
      final lvl = entry.value;
      // La descripción trae el detalle por género tras el último ". "
      final cut = lvl.description.lastIndexOf('. ');
      final base =
          cut >= 0 ? lvl.description.substring(0, cut) : lvl.description;
      // Desglose de participantes en una línea propia bajo la descripción
      final String detail = switch (_breakdown) {
        KpiBreakdown.genero =>
          cut >= 0 ? lvl.description.substring(cut + 2) : '',
        KpiBreakdown.ninguno =>
          '${lvl.total} ${lvl.total == 1 ? 'participante' : 'participantes'}',
        _ => groups.detail(segments[entry.key]),
      };
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: RichText(
          text: TextSpan(
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              height: 1.35,
            ),
            children: [
              TextSpan(
                text: '${lvl.cineLabel}: ',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  color: KpiColors.primaryDark,
                ),
              ),
              TextSpan(
                text: '$base.',
                style: const TextStyle(color: KpiColors.secondaryText),
              ),
              if (detail.isNotEmpty)
                TextSpan(
                  text: '\n$detail',
                  style: const TextStyle(color: KpiColors.mutedText),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildHeaderActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.isLoading) ...[
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(KpiColors.turquoise),
            ),
          ),
          const SizedBox(width: 12),
        ],
        _buildModeToggle(),
      ],
    );
  }

  Widget _buildHeaderTitles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Niveles formativos',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: KpiColors.primaryDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Nivel máximo de estudios completado',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: KpiColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: KpiColors.tileBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['Nivel CINE', 'Nivel de estudios'].map((mode) {
          final isSelected = _selectedMode == mode;
          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () {
              setState(() {
                _selectedMode = mode;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                boxShadow: isSelected ? KpiColors.smallShadow : null,
              ),
              child: Text(
                mode,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? KpiColors.primaryDark
                      : KpiColors.secondaryText,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDisaggregateChip() {
    return KpiBreakdownChip(
      value: _breakdown,
      onChanged: (value) => setState(() => _breakdown = value),
    );
  }

  Widget _buildLegend() => KpiGroupsLegend(groups: _groups);

  Widget _buildVerticalStackedBars() {
    const double maxBarHeight = 160.0;
    final levels = widget.nivelesCine;
    final double maxCount =
        levels.fold<int>(1, (m, l) => l.total > m ? l.total : m).toDouble();
    final groups = _groups;
    final segments = _segments(levels, widget.cinePorUsuario);

    return Column(
      children: [
        SizedBox(
          height: maxBarHeight + 35,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: levels.asMap().entries.map((entry) {
              final item = entry.value;
              final values = segments[entry.key];
              final barTotalHeight = (item.total / maxCount) * maxBarHeight;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Label on top
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${item.total}',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: KpiColors.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.percentage.round()}%',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: KpiColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Stacked column
                  SizedBox(
                    width: 54,
                    height: barTotalHeight,
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(4)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // El primer grupo queda abajo
                          for (int g = values.length - 1; g >= 0; g--)
                            if (values[g] > 0)
                              Expanded(
                                flex: values[g],
                                child: Container(color: groups.colors[g]),
                              ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),

        // X-Axis Line
        Container(
          height: 1,
          color: KpiColors.borderLight,
        ),
        const SizedBox(height: 8),

        // X-Axis labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: levels.map((item) {
            return SizedBox(
              width: 80,
              child: Text(
                item.cineLabel,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: KpiColors.primaryDark,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHorizontalStackedBars() {
    final levels = widget.nivelesEstudios;
    if (levels.isEmpty) {
      return Text(
        'Sin datos de nivel de estudios.',
        style: GoogleFonts.outfit(
          fontSize: 12,
          color: KpiColors.secondaryText,
        ),
      );
    }
    final int maxCount =
        levels.fold<int>(1, (m, l) => l.total > m ? l.total : m);
    final groups = _groups;
    final segments = _segments(levels, widget.estudiosPorUsuario);

    return Column(
      children: levels.asMap().entries.map((entry) {
        final item = entry.value;
        final values = segments[entry.key];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              SizedBox(
                width: 150,
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: KpiColors.secondaryText,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final barWidth =
                        (item.total / maxCount) * constraints.maxWidth;
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: SizedBox(
                          width: barWidth,
                          height: 16,
                          child: Row(
                            children: [
                              for (int g = 0; g < values.length; g++)
                                if (values[g] > 0)
                                  Expanded(
                                    flex: values[g],
                                    child: Container(color: groups.colors[g]),
                                  ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 64,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${item.total}',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: KpiColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.percentage.round()}%',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: KpiColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
