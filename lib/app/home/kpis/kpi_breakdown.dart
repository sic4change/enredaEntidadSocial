import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/userEnreda.dart';
import 'kpi_colors.dart';
import 'kpi_search.dart';

/// Formas de desagregar una tarjeta de KPIs.
enum KpiBreakdown { ninguno, genero, nacionalidad }

extension KpiBreakdownLabel on KpiBreakdown {
  String get label {
    switch (this) {
      case KpiBreakdown.ninguno:
        return 'Ninguno';
      case KpiBreakdown.genero:
        return 'Género';
      case KpiBreakdown.nacionalidad:
        return 'Nacionalidad';
    }
  }
}

/// Grupos en los que se reparte a los participantes al desagregar.
class KpiGroups {
  final List<String> labels;
  final List<Color> colors;
  final int Function(UserEnreda user) indexOf;

  const KpiGroups(
      {required this.labels, required this.colors, required this.indexOf});

  int get length => labels.length;

  /// Mujeres / Hombres / No binario.
  static KpiGroups gender() => KpiGroups(
        labels: const ['Mujeres', 'Hombres', 'No binario'],
        colors: const [
          KpiColors.yellow,
          KpiColors.primaryDark,
          KpiColors.slate
        ],
        indexOf: (u) {
          final g = (u.gender ?? '').trim().toLowerCase();
          if (g == 'mujer' || g == 'femenino' || g == 'f') return 0;
          if (g == 'hombre' || g == 'masculino' || g == 'm') return 1;
          return 2;
        },
      );

  /// Las [top] nacionalidades más frecuentes entre [users] + "Otras" (resto y
  /// participantes sin nacionalidad).
  static KpiGroups nationality(List<UserEnreda> users, {int top = 3}) {
    const palette = [
      KpiColors.primaryDark,
      KpiColors.turquoise,
      KpiColors.yellow
    ];
    final Map<String, int> counts = {};
    final Map<String, String> labels = {};
    for (final u in users) {
      final raw = (u.nationality ?? '').trim();
      if (raw.isEmpty) continue;
      final key = normalizeKpiSearch(raw);
      counts[key] = (counts[key] ?? 0) + 1;
      labels.putIfAbsent(key, () => raw);
    }
    final topKeys = (counts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(top)
        .map((e) => e.key)
        .toList();
    final hasOthers = users.any((u) =>
        !topKeys.contains(normalizeKpiSearch((u.nationality ?? '').trim())));

    return KpiGroups(
      labels: [
        for (final k in topKeys) labels[k]!,
        if (hasOthers) 'Otras',
      ],
      colors: [
        for (int i = 0; i < topKeys.length; i++) palette[i % palette.length],
        if (hasOthers) KpiColors.slate,
      ],
      indexOf: (u) {
        final idx =
            topKeys.indexOf(normalizeKpiSearch((u.nationality ?? '').trim()));
        return idx >= 0 ? idx : topKeys.length;
      },
    );
  }

  static KpiGroups of(KpiBreakdown breakdown, List<UserEnreda> users) =>
      breakdown == KpiBreakdown.nacionalidad ? nationality(users) : gender();

  /// Cuenta, para cada fila (0..[rowCount)), cuántos participantes hay en cada
  /// grupo. [rowOf] devuelve la fila del participante o `null` si no computa.
  List<List<int>> countByRow(
    List<UserEnreda> users,
    int rowCount,
    int? Function(UserEnreda user) rowOf,
  ) {
    final counts = List.generate(rowCount, (_) => List<int>.filled(length, 0));
    for (final u in users) {
      final row = rowOf(u);
      if (row == null || row < 0 || row >= rowCount) continue;
      counts[row][indexOf(u)]++;
    }
    return counts;
  }

  /// "12 Mujeres · 8 Hombres" (solo los grupos con valor).
  String detail(List<int> values) => [
        for (int i = 0; i < values.length && i < length; i++)
          if (values[i] > 0) '${values[i]} ${labels[i]}',
      ].join(' · ');
}

/// Chip desplegable "Desagregar por: …" con el estilo de las tarjetas de KPIs.
class KpiBreakdownChip extends StatelessWidget {
  final String prefix;
  final KpiBreakdown value;
  final List<KpiBreakdown> options;
  final ValueChanged<KpiBreakdown> onChanged;

  const KpiBreakdownChip({
    Key? key,
    this.prefix = 'Desagregar por',
    required this.value,
    this.options = const [KpiBreakdown.genero, KpiBreakdown.nacionalidad],
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<KpiBreakdown>(
      tooltip: '',
      initialValue: value,
      onSelected: onChanged,
      position: PopupMenuPosition.under,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => options
          .map((o) => PopupMenuItem<KpiBreakdown>(
                value: o,
                height: 36,
                child: Text(
                  o.label,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight:
                        o == value ? FontWeight.w600 : FontWeight.normal,
                    color: KpiColors.primaryDark,
                  ),
                ),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: KpiColors.borderLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$prefix: ${value.label}',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: KpiColors.primaryDark,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: KpiColors.primaryDark,
            ),
          ],
        ),
      ),
    );
  }
}

/// Leyenda de los grupos de un desglose (punto de color + nombre).
class KpiGroupsLegend extends StatelessWidget {
  final KpiGroups groups;

  const KpiGroupsLegend({Key? key, required this.groups}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        for (int i = 0; i < groups.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    color: groups.colors[i], shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                groups.labels[i],
                style: GoogleFonts.outfit(
                    fontSize: 12, color: KpiColors.secondaryText),
              ),
            ],
          ),
      ],
    );
  }
}
