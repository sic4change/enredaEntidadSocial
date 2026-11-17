import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/userEnreda.dart';
import '../kpi_breakdown.dart';
import '../kpi_colors.dart';
import '../kpi_models.dart';

class CardGruposEdad extends StatefulWidget {
  final List<UserEnreda>? users;
  final bool isLoading;

  const CardGruposEdad({
    Key? key,
    this.users,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<CardGruposEdad> createState() => _CardGruposEdadState();
}

class _CardGruposEdadState extends State<CardGruposEdad> {
  KpiBreakdown _breakdown = KpiBreakdown.genero;

  @override
  Widget build(BuildContext context) => _CardGruposEdadView(
        users: widget.users,
        isLoading: widget.isLoading,
        breakdown: _breakdown,
        onBreakdownChanged: (value) => setState(() => _breakdown = value),
      );
}

class _CardGruposEdadView extends StatelessWidget {
  final List<UserEnreda>? users;
  final bool isLoading;
  final KpiBreakdown breakdown;
  final ValueChanged<KpiBreakdown> onBreakdownChanged;

  const _CardGruposEdadView({
    this.users,
    this.isLoading = false,
    required this.breakdown,
    required this.onBreakdownChanged,
  });

  static const List<String> _groupLabels = [
    'Menos de 18',
    '18 – 24',
    '25 – 29',
    '30 – 54',
    'Más de 54'
  ];

  int? _ageGroupOf(UserEnreda u) {
    final age = _calculateAge(u.birthday);
    if (age == null) return null;
    if (age < 18) return 0;
    if (age <= 24) return 1;
    if (age <= 29) return 2;
    if (age <= 54) return 3;
    return 4;
  }

  int? _calculateAge(DateTime? birthday) {
    if (birthday == null) return null;
    final now = DateTime.now();
    var age = now.year - birthday.year;
    if (now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }
    return (age >= 0 && age <= 120) ? age : null;
  }

  String _normalizeGender(String? raw) {
    final g = (raw ?? '').trim().toLowerCase();
    if (g == 'mujer' || g == 'femenino' || g == 'f') return 'mujer';
    if (g == 'hombre' || g == 'masculino' || g == 'm') return 'hombre';
    return 'no_binario';
  }

  bool _isExtranjero(String? raw) {
    final nat = (raw ?? '').trim().toLowerCase();
    if (nat.isEmpty) return false;
    return nat != 'españa' &&
        nat != 'espana' &&
        nat != 'española' &&
        nat != 'espanola';
  }

  @override
  Widget build(BuildContext context) {
    final userList = users ?? [];

    int menores18 = 0;
    int jovenes1829 = 0;
    int mayores54 = 0;
    int origenExtranjero = 0;

    int totalMujeres = 0;
    int totalHombres = 0;
    int totalNoBinario = 0;

    // Grupos:
    // 0: Menos de 18
    // 1: 18 – 24
    // 2: 25 – 29
    // 3: 30 – 54
    // 4: Más de 54
    final groupMujeres = List<int>.filled(5, 0);
    final groupHombres = List<int>.filled(5, 0);
    final groupNoBinario = List<int>.filled(5, 0);

    for (final u in userList) {
      if (_isExtranjero(u.nationality)) {
        origenExtranjero++;
      }

      final age = _calculateAge(u.birthday);
      if (age == null) continue;

      final gender = _normalizeGender(u.gender);
      if (gender == 'mujer') {
        totalMujeres++;
      } else if (gender == 'hombre') {
        totalHombres++;
      } else {
        totalNoBinario++;
      }

      int groupIdx = -1;
      if (age < 18) {
        groupIdx = 0;
        menores18++;
      } else if (age <= 24) {
        groupIdx = 1;
        jovenes1829++;
      } else if (age <= 29) {
        groupIdx = 2;
        jovenes1829++;
      } else if (age <= 54) {
        groupIdx = 3;
      } else {
        groupIdx = 4;
        mayores54++;
      }

      if (gender == 'mujer') {
        groupMujeres[groupIdx]++;
      } else if (gender == 'hombre') {
        groupHombres[groupIdx]++;
      } else {
        groupNoBinario[groupIdx]++;
      }
    }

    final rows = [
      AgePyramidRow(
        label: 'Menos de 18',
        mujeres: groupMujeres[0],
        hombres: groupHombres[0],
        total: groupMujeres[0] + groupHombres[0],
      ),
      AgePyramidRow(
        label: '18 – 24',
        mujeres: groupMujeres[1],
        hombres: groupHombres[1],
        total: groupMujeres[1] + groupHombres[1],
      ),
      AgePyramidRow(
        label: '25 – 29',
        mujeres: groupMujeres[2],
        hombres: groupHombres[2],
        total: groupMujeres[2] + groupHombres[2],
      ),
      AgePyramidRow(
        label: '30 – 54',
        mujeres: groupMujeres[3],
        hombres: groupHombres[3],
        total: groupMujeres[3] + groupHombres[3],
      ),
      AgePyramidRow(
        label: 'Más de 54',
        mujeres: groupMujeres[4],
        hombres: groupHombres[4],
        total: groupMujeres[4] + groupHombres[4],
      ),
    ];

    double maxVal = 1.0;
    for (final r in rows) {
      if (r.mujeres > maxVal) maxVal = r.mujeres.toDouble();
      if (r.hombres > maxVal) maxVal = r.hombres.toDouble();
    }

    // Footnote non-binary
    final nbDetails = <String>[];
    const groupLabels = [
      'menos de 18 años',
      '18 – 24 años',
      '25 – 29 años',
      '30 – 54 años',
      'más de 54 años'
    ];
    for (int i = 0; i < 5; i++) {
      if (groupNoBinario[i] > 0) {
        nbDetails.add('${groupNoBinario[i]} de ${groupLabels[i]}');
      }
    }

    String footnote;
    if (totalNoBinario == 0) {
      footnote = 'Sin participantes no binarios registrados en esta selección.';
    } else if (totalNoBinario == 1) {
      footnote = 'Además, 1 participante no binario: ${nbDetails.first}.';
    } else {
      if (nbDetails.length > 1) {
        final last = nbDetails.removeLast();
        footnote =
            'Además, $totalNoBinario participantes no binarios: ${nbDetails.join(", ")} y $last.';
      } else {
        footnote =
            'Además, $totalNoBinario participantes no binarios: ${nbDetails.first}.';
      }
    }

    final sumMujeresHombres = totalMujeres + totalHombres;

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
                      'Grupos de edad',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: KpiColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Distribución por grupo de edad y género',
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
                  if (isLoading) ...[
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
                  KpiBreakdownChip(
                    prefix: 'Comparar',
                    value: breakdown,
                    onChanged: onBreakdownChanged,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (breakdown == KpiBreakdown.nacionalidad)
            ..._buildNationalityBreakdown(userList)
          else ...[
            // Total column label
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: KpiColors.secondaryText,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Population Pyramid rows
            // Sin separación entre filas para que la línea central sea continua
            ...rows.map((row) => _buildPyramidRow(row, maxVal)),
            const SizedBox(height: 16),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Mujeres', KpiColors.yellow),
                const SizedBox(width: 24),
                _buildLegendItem('Hombres', KpiColors.primaryDark),
              ],
            ),
            const SizedBox(height: 16),

            // Summary row banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: KpiColors.tileBackground.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total mujeres y hombres',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: KpiColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '$totalMujeres mujeres · $totalHombres hombres · $sumMujeresHombres',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: KpiColors.primaryDark,
                      ),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Footnote non-binary
            Text(
              footnote,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: KpiColors.secondaryText,
              ),
            ),
            const SizedBox(height: 20),
          ],
          // 4 Tramos FSE Stat Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 460;
              if (isSmall) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSmallStat('$menores18', 'Menores de 18',
                        width: (constraints.maxWidth - 8) / 2),
                    _buildSmallStat('$jovenes1829', 'Jóvenes 18 – 29',
                        width: (constraints.maxWidth - 8) / 2),
                    _buildSmallStat('$mayores54', 'Mayores de 54',
                        width: (constraints.maxWidth - 8) / 2),
                    _buildSmallStat('$origenExtranjero', 'Origen extranjero',
                        width: (constraints.maxWidth - 8) / 2),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                      child: _buildSmallStat('$menores18', 'Menores de 18')),
                  const SizedBox(width: 8),
                  Expanded(
                      child:
                          _buildSmallStat('$jovenes1829', 'Jóvenes 18 – 29')),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildSmallStat('$mayores54', 'Mayores de 54')),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildSmallStat(
                          '$origenExtranjero', 'Origen extranjero')),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Barras apiladas por tramo de edad, un segmento por nacionalidad.
  List<Widget> _buildNationalityBreakdown(List<UserEnreda> userList) {
    final groups = KpiGroups.nationality(userList);
    final counts = groups.countByRow(userList, 5, _ageGroupOf);
    final totals = counts.map((c) => c.fold<int>(0, (a, b) => a + b)).toList();
    final int maxTotal = totals.fold<int>(1, (m, t) => t > m ? t : m);

    return [
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          'Total',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: KpiColors.secondaryText,
          ),
        ),
      ),
      const SizedBox(height: 8),
      for (int i = 0; i < 5; i++)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  _groupLabels[i],
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: KpiColors.secondaryText,
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => Align(
                    alignment: Alignment.centerLeft,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: SizedBox(
                        width: totals[i] / maxTotal * constraints.maxWidth,
                        height: 16,
                        child: Row(
                          children: [
                            for (int g = 0; g < groups.length; g++)
                              if (counts[i][g] > 0)
                                Expanded(
                                  flex: counts[i][g],
                                  child: Container(color: groups.colors[g]),
                                ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 42,
                child: Text(
                  '${totals[i]}',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: KpiColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 16),
      Center(child: KpiGroupsLegend(groups: groups)),
      const SizedBox(height: 20),
    ];
  }

  Widget _buildPyramidRow(AgePyramidRow row, double maxVal) {
    const double maxSideWidth = 95.0;
    final double safeMax = maxVal > 0 ? maxVal : 1.0;

    final double widthMujeres = (row.mujeres / safeMax) * maxSideWidth;
    final double widthHombres = (row.hombres / safeMax) * maxSideWidth;

    return Row(
      children: [
        // Left Label
        SizedBox(
          width: 80,
          child: Text(
            row.label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: KpiColors.secondaryText,
            ),
          ),
        ),

        // Pyramid Area (Mujeres left, axis, Hombres right)
        Expanded(
          child: Row(
            children: [
              // Mujeres bar going left towards axis
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${row.mujeres}',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: KpiColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Container(
                        width: row.mujeres > 0
                            ? widthMujeres.clamp(4.0, maxSideWidth)
                            : 0.0,
                        height: 16,
                        decoration: BoxDecoration(
                          color: KpiColors.yellow,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Center vertical axis line: ocupa toda la altura de la fila
              // (16 px de barra + 6 px arriba y abajo) para unirse con las
              // filas vecinas
              Container(
                width: 2,
                height: 28,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: KpiColors.borderLight,
              ),

              // Hombres bar going right away from axis
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Container(
                        width: row.hombres > 0
                            ? widthHombres.clamp(4.0, maxSideWidth)
                            : 0.0,
                        height: 16,
                        decoration: BoxDecoration(
                          color: KpiColors.primaryDark,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${row.hombres}',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: KpiColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Total Column
        SizedBox(
          width: 42,
          child: Text(
            '${row.total}',
            textAlign: TextAlign.right,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: KpiColors.primaryDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
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

  Widget _buildSmallStat(String val, String label, {double? width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: KpiColors.tileBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              val,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: KpiColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.normal,
              color: KpiColors.secondaryText,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
