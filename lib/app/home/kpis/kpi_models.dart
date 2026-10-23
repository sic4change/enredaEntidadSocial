import 'package:flutter/material.dart';
import 'kpi_colors.dart';

class FilterChipItem {
  final String id;
  final String label;
  final String? prefix;

  const FilterChipItem({
    required this.id,
    required this.label,
    this.prefix,
  });
}

class MonthDataPoint {
  final String month;
  final double? value;

  const MonthDataPoint(this.month, this.value);
}

class StackedBarRow {
  final String label;
  final int count;
  final double percentage;
  final Color color;

  const StackedBarRow({
    required this.label,
    required this.count,
    required this.percentage,
    required this.color,
  });
}

class SituacionEmpleoRow {
  final String label;
  final int mujeres;
  final int hombres;
  final int noBinario;
  final int total;
  final bool isIndented;
  final bool isTotal;

  const SituacionEmpleoRow({
    required this.label,
    required this.mujeres,
    required this.hombres,
    required this.noBinario,
    required this.total,
    this.isIndented = false,
    this.isTotal = false,
  });
}

class AgePyramidRow {
  final String label;
  final int mujeres;
  final int hombres;
  final int total;

  const AgePyramidRow({
    required this.label,
    required this.mujeres,
    required this.hombres,
    required this.total,
  });
}

class FormatLevelItem {
  final String cineLabel;
  final String title;
  final int total;
  final double percentage;
  final int mujeres;
  final int hombres;
  final int noBinario;
  final String description;

  const FormatLevelItem({
    required this.cineLabel,
    required this.title,
    required this.total,
    required this.percentage,
    required this.mujeres,
    required this.hombres,
    required this.noBinario,
    required this.description,
  });
}

class RankedBarItem {
  final String label;
  final String? category;
  final int count;
  final double? percentage;
  final Color? color;
  final String? detail;

  const RankedBarItem({
    required this.label,
    this.category,
    required this.count,
    this.percentage,
    this.color,
    this.detail,
  });
}

class NacionalidadItem {
  final String label;
  final int mujeres;
  final int hombres;
  final int noBinario;

  const NacionalidadItem({
    required this.label,
    required this.mujeres,
    required this.hombres,
    required this.noBinario,
  });

  int get total => mujeres + hombres + noBinario;
}

class DonutSegment {
  final String label;
  final int count;
  final double percentage;
  final Color color;

  const DonutSegment({
    required this.label,
    required this.count,
    required this.percentage,
    required this.color,
  });
}

class CompetenciaArea {
  final String name;
  final double percentage;
  final Color color;
  final String group;

  const CompetenciaArea({
    required this.name,
    required this.percentage,
    required this.color,
    required this.group,
  });
}

class KeyIndicatorMetric {
  final String title;
  final String mainValue;
  final String unit;
  final String? secondValue;
  final String? secondUnit;
  final String variation;
  final bool isPositive;
  final String previousYearText;
  final String source;
  final IconData icon;

  const KeyIndicatorMetric({
    required this.title,
    required this.mainValue,
    required this.unit,
    this.secondValue,
    this.secondUnit,
    required this.variation,
    required this.isPositive,
    required this.previousYearText,
    required this.source,
    required this.icon,
  });
}

class FunnelStep {
  final int percentage;
  final int count;
  final String label;
  final Color ringColor;

  const FunnelStep({
    required this.percentage,
    required this.count,
    required this.label,
    required this.ringColor,
  });
}

/// Fake data repository matching Figma node 11249:68 exactly
class KpiFakeData {
  static const List<FilterChipItem> filterOrganizations = [
    FilterChipItem(id: 'global', label: 'Global'),
    FilterChipItem(id: 'sic4change', label: 'SIC4Change'),
    FilterChipItem(
      id: '529775',
      label: 'Acompañamiento y tecnología',
      prefix: '529775_',
    ),
    FilterChipItem(
      id: 'seimlab',
      label: 'SEIMLAB',
      prefix: '1/MAC/4/7.2/0080_',
    ),
    FilterChipItem(
      id: '529760',
      label: 'Empleando sueños',
      prefix: '529760_',
    ),
  ];

  // Resumen General
  static const int totalParticipantes = 142;

  static const List<StackedBarRow> estadoParticipantes = [
    StackedBarRow(label: 'Activos', count: 95, percentage: 67, color: KpiColors.turquoise),
    StackedBarRow(label: 'En espera', count: 28, percentage: 20, color: KpiColors.lightTurquoise),
    StackedBarRow(label: 'Inactivos', count: 19, percentage: 13, color: KpiColors.borderLight),
  ];

  static const List<StackedBarRow> generoParticipantes = [
    StackedBarRow(label: 'Mujeres', count: 81, percentage: 57, color: KpiColors.yellow),
    StackedBarRow(label: 'Hombres', count: 58, percentage: 41, color: KpiColors.primaryDark),
    StackedBarRow(label: 'No binario', count: 3, percentage: 2, color: KpiColors.slate),
  ];

  static const List<StackedBarRow> nacionalidadParticipantes = [
    StackedBarRow(label: 'Nacional', count: 74, percentage: 52, color: KpiColors.primaryDark),
    StackedBarRow(label: 'Extranjera', count: 68, percentage: 48, color: KpiColors.turquoise),
  ];

  // Evolución de inscripciones
  static const List<MonthDataPoint> evolucionInscripciones = [
    MonthDataPoint('Ene', 9),
    MonthDataPoint('Feb', 12),
    MonthDataPoint('Mar', 8),
    MonthDataPoint('Abr', 14),
    MonthDataPoint('May', 11),
    MonthDataPoint('Jun', 16),
    MonthDataPoint('Jul', 10),
    MonthDataPoint('Ago', 13),
    MonthDataPoint('Sep', 18),
    MonthDataPoint('Oct', 15),
    MonthDataPoint('Nov', null),
    MonthDataPoint('Dic', null),
  ];

  // Situación de empleo
  static const List<SituacionEmpleoRow> situacionEmpleoRows = [
    SituacionEmpleoRow(
      label: 'Desempleadas/os',
      mujeres: 58,
      hombres: 40,
      noBinario: 2,
      total: 100,
    ),
    SituacionEmpleoRow(
      label: '↳ Corta duración',
      mujeres: 28,
      hombres: 23,
      noBinario: 1,
      total: 52,
      isIndented: true,
    ),
    SituacionEmpleoRow(
      label: '↳ Larga duración',
      mujeres: 30,
      hombres: 17,
      noBinario: 1,
      total: 48,
      isIndented: true,
    ),
    SituacionEmpleoRow(
      label: 'Inactivas/os',
      mujeres: 14,
      hombres: 9,
      noBinario: 1,
      total: 24,
    ),
    SituacionEmpleoRow(
      label: 'Empleadas/os',
      mujeres: 9,
      hombres: 9,
      noBinario: 0,
      total: 18,
    ),
    SituacionEmpleoRow(
      label: 'Total',
      mujeres: 81,
      hombres: 58,
      noBinario: 3,
      total: 142,
      isTotal: true,
    ),
  ];

  // Desglose Demográfico: Grupos de edad
  static const List<AgePyramidRow> agePyramid = [
    AgePyramidRow(label: 'Menos de 18', mujeres: 6, hombres: 5, total: 11),
    AgePyramidRow(label: '18 – 24', mujeres: 28, hombres: 22, total: 50),
    AgePyramidRow(label: '25 – 29', mujeres: 20, hombres: 14, total: 34),
    AgePyramidRow(label: '30 – 54', mujeres: 22, hombres: 14, total: 36),
    AgePyramidRow(label: 'Más de 54', mujeres: 5, hombres: 3, total: 8),
  ];

  // Indicadores Clave
  static const List<KeyIndicatorMetric> keyIndicators = [
    KeyIndicatorMetric(
      title: 'Ingreso a formación',
      mainValue: '64',
      unit: 'personas',
      variation: '▲ 33%',
      isPositive: true,
      previousYearText: 'En 2025: 48 personas',
      source: 'Fuente: IPIL › Inscripción formación',
      icon: Icons.school_outlined,
    ),
    KeyIndicatorMetric(
      title: 'Cualificaciones obtenidas',
      mainValue: '32',
      unit: 'personas',
      variation: '▼ 26%',
      isPositive: false,
      previousYearText: 'En 2025: 43 personas',
      source: 'Fuente: IPIL › Certificación formación',
      icon: Icons.star_outline_rounded,
    ),
    KeyIndicatorMetric(
      title: 'Empleos conseguidos',
      mainValue: '21',
      unit: 'personas',
      variation: '▲ 31%',
      isPositive: true,
      previousYearText: 'En 2025: 16 personas',
      source: 'Fuente: Informe de cierre',
      icon: Icons.work_outline,
    ),
    KeyIndicatorMetric(
      title: 'Mantenimiento del empleo',
      mainValue: '17',
      unit: 'personas a las 4 semanas',
      secondValue: '12',
      secondUnit: 'personas a los 6 meses',
      variation: '▲ 9%',
      isPositive: true,
      previousYearText: 'A los 6 meses en 2025: 11 personas',
      source: 'Fuente: IPIL › Seguimiento',
      icon: Icons.shield_outlined,
    ),
    KeyIndicatorMetric(
      title: 'CV realizado en Enreda',
      mainValue: '58',
      unit: 'personas',
      variation: '▲ 21%',
      isPositive: true,
      previousYearText: 'En 2025: 48 personas',
      source: 'Fuente: Enreda › Currículum',
      icon: Icons.description_outlined,
    ),
  ];

  // Recorrido de resultados (Funnel)
  static const List<FunnelStep> funnelSteps = [
    FunnelStep(percentage: 100, count: 142, label: 'Participantes inscritos', ringColor: KpiColors.primaryDark),
    FunnelStep(percentage: 45, count: 64, label: 'Ingreso a formación', ringColor: KpiColors.turquoise),
    FunnelStep(percentage: 23, count: 32, label: 'Cualificaciones obtenidas', ringColor: KpiColors.turquoise),
    FunnelStep(percentage: 15, count: 21, label: 'Empleos conseguidos', ringColor: KpiColors.turquoise),
    FunnelStep(percentage: 8, count: 12, label: 'Empleo mantenido a 6 meses', ringColor: KpiColors.turquoise),
  ];

  // Resultados por sector
  static const List<RankedBarItem> resultadosPorSector = [
    RankedBarItem(label: 'Hostelería y turismo', count: 9),
    RankedBarItem(label: 'Comercio y marketing', count: 7),
    RankedBarItem(label: 'Servicios socioculturales', count: 6),
    RankedBarItem(label: 'Informática y comunicaciones', count: 5),
    RankedBarItem(label: 'Administración y gestión', count: 3),
    RankedBarItem(label: 'Otros sectores', count: 2),
  ];

  // Recursos: Por tipología
  static const List<DonutSegment> recursosTipologia = [
    DonutSegment(label: 'Empleo', count: 64, percentage: 30, color: KpiColors.primaryDark),
    DonutSegment(label: 'Prácticas', count: 38, percentage: 18, color: KpiColors.turquoise),
    DonutSegment(label: 'Formación', count: 52, percentage: 25, color: KpiColors.lightTurquoise),
    DonutSegment(label: 'Voluntariado', count: 24, percentage: 11, color: KpiColors.yellow),
    DonutSegment(label: 'Ocio y tiempo libre', count: 21, percentage: 10, color: KpiColors.slate),
    DonutSegment(label: 'Otros', count: 13, percentage: 6, color: KpiColors.borderLight),
  ];

  // Recursos: Línea temporal mensual
  static const List<MonthDataPoint> evolucionRecursos = [
    MonthDataPoint('Ene', 14),
    MonthDataPoint('Feb', 18),
    MonthDataPoint('Mar', 12),
    MonthDataPoint('Abr', 21),
    MonthDataPoint('May', 17),
    MonthDataPoint('Jun', 24),
    MonthDataPoint('Jul', 15),
    MonthDataPoint('Ago', 20),
    MonthDataPoint('Sep', 27),
    MonthDataPoint('Oct', 23),
    MonthDataPoint('Nov', null),
    MonthDataPoint('Dic', null),
  ];

  // Recursos: Por categoría
  static const List<RankedBarItem> recursosPorCategoria = [
    RankedBarItem(label: 'Social', count: 34, percentage: 16),
    RankedBarItem(label: 'Hostelería', count: 29, percentage: 14),
    RankedBarItem(label: 'Tecnológico', count: 26, percentage: 12),
    RankedBarItem(label: 'Servicios de salud', count: 22, percentage: 10),
    RankedBarItem(label: 'Oficios y artesanías', count: 19, percentage: 9),
    RankedBarItem(label: 'Turismo', count: 17, percentage: 8),
    RankedBarItem(label: 'Industria', count: 15, percentage: 7),
    RankedBarItem(label: 'Agricultura, silvicultura, pesca y ganadería', count: 12, percentage: 6),
    RankedBarItem(label: 'Artístico', count: 11, percentage: 5),
    RankedBarItem(label: 'Físico deportivo', count: 9, percentage: 4),
    RankedBarItem(label: 'Científico', count: 7, percentage: 3),
    RankedBarItem(label: 'Militar y FFCCS', count: 4, percentage: 2),
    RankedBarItem(label: 'Otros', count: 7, percentage: 3),
  ];
}
