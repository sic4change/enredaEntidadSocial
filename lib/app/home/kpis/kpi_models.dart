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

  // Niveles formativos
  static const List<FormatLevelItem> formatLevels = [
    FormatLevelItem(
      cineLabel: 'CINE 0 – 2',
      title: 'Educación básica o sin estudios',
      total: 68,
      percentage: 48,
      mujeres: 39,
      hombres: 28,
      noBinario: 1,
      description: 'Sin formación, Educación Primaria, ESO, Competencias clave y Certificados profesionales (niveles 1 – 3). 39 mujeres · 28 hombres · 1 no binario',
    ),
    FormatLevelItem(
      cineLabel: 'CINE 3 – 4',
      title: 'Educación secundaria postobligatoria',
      total: 46,
      percentage: 32,
      mujeres: 26,
      hombres: 19,
      noBinario: 1,
      description: 'FP básica, FP de grado medio y Bachillerato. 26 mujeres · 19 hombres · 1 no binario',
    ),
    FormatLevelItem(
      cineLabel: 'CINE 5 – 8',
      title: 'Educación superior',
      total: 28,
      percentage: 20,
      mujeres: 16,
      hombres: 11,
      noBinario: 1,
      description: 'FP de grado superior, formación universitaria y postgrado. 16 mujeres · 11 hombres · 1 no binario',
    ),
  ];

  // Discapacidad
  static const List<DonutSegment> discapacidadSegments = [
    DonutSegment(label: 'Reconocida', count: 21, percentage: 15, color: KpiColors.turquoise),
    DonutSegment(label: 'En trámite', count: 7, percentage: 5, color: KpiColors.lightTurquoise),
    DonutSegment(label: 'Sin discapacidad declarada', count: 114, percentage: 80, color: KpiColors.borderLight),
  ];

  // Condiciones sobrevenidas
  static const List<RankedBarItem> condicionesSobrevenidas = [
    RankedBarItem(label: 'Barrera idiomática', count: 31, percentage: 22),
    RankedBarItem(label: 'Falta de red de apoyo', count: 27, percentage: 19),
    RankedBarItem(label: 'Responsabilidades familiares', count: 22, percentage: 15),
    RankedBarItem(label: 'Ruralidad', count: 18, percentage: 13),
    RankedBarItem(label: 'Joven tutelado/a o ex tutelado/a', count: 14, percentage: 10),
    RankedBarItem(label: 'Familia monoparental-monomarental', count: 11, percentage: 8),
    RankedBarItem(label: 'Minoría', count: 9, percentage: 6),
    RankedBarItem(label: 'Colectivo LGBTI', count: 7, percentage: 5),
    RankedBarItem(label: 'Situación de sinhogarismo', count: 6, percentage: 4),
    RankedBarItem(label: 'Salud mental grave', count: 5, percentage: 4),
    RankedBarItem(label: 'Violencia de género', count: 4, percentage: 3),
    RankedBarItem(label: 'Adicciones', count: 3, percentage: 2),
  ];

  // Nacionalidades
  static const List<RankedBarItem> nacionalidades = [
    RankedBarItem(
      label: 'España',
      count: 74,
      detail: '42 mujeres · 31 hombres · 1 no binario',
    ),
    RankedBarItem(
      label: 'Marruecos',
      count: 18,
      detail: '8 mujeres · 10 hombres',
    ),
    RankedBarItem(
      label: 'Venezuela',
      count: 14,
      detail: '9 mujeres · 5 hombres',
    ),
    RankedBarItem(
      label: 'Colombia',
      count: 11,
      detail: '7 mujeres · 4 hombres',
    ),
    RankedBarItem(
      label: 'Senegal',
      count: 8,
      detail: '2 mujeres · 6 hombres',
    ),
    RankedBarItem(
      label: 'Argentina',
      count: 6,
      detail: '4 mujeres · 2 hombres',
    ),
    RankedBarItem(
      label: 'Rumanía',
      count: 5,
      detail: '4 mujeres · 1 no binario',
    ),
    RankedBarItem(
      label: 'Otras (6)',
      count: 6,
      detail: '5 mujeres · 1 no binario',
    ),
  ];

  // Situación administrativa
  static const List<DonutSegment> situacionAdministrativa = [
    DonutSegment(label: 'Nacional', count: 74, percentage: 52, color: KpiColors.primaryDark),
    DonutSegment(label: 'Regular', count: 38, percentage: 27, color: KpiColors.turquoise),
    DonutSegment(label: 'Irregular', count: 14, percentage: 10, color: KpiColors.yellow),
    DonutSegment(label: 'Protección internacional', count: 9, percentage: 6, color: KpiColors.lightTurquoise),
    DonutSegment(label: 'En trámite', count: 5, percentage: 4, color: KpiColors.slate),
    DonutSegment(label: 'No lo tengo claro', count: 2, percentage: 1, color: KpiColors.borderLight),
  ];

  // Competencias más reconocidas
  static const List<RankedBarItem> competenciasReconocidas = [
    RankedBarItem(
      label: 'Empatía',
      category: 'Trabajo en equipo',
      count: 64,
      percentage: 45,
      color: KpiColors.primaryDark,
    ),
    RankedBarItem(
      label: 'Responsabilidad',
      category: 'Liderazgo positivo',
      count: 58,
      percentage: 41,
      color: KpiColors.turquoise,
    ),
    RankedBarItem(
      label: 'Comunicación oral',
      category: 'Comunicación',
      count: 55,
      percentage: 39,
      color: KpiColors.primaryDark,
    ),
    RankedBarItem(
      label: 'Integración en el grupo',
      category: 'Trabajo en equipo',
      count: 51,
      percentage: 36,
      color: KpiColors.primaryDark,
    ),
    RankedBarItem(
      label: 'Escucha activa',
      category: 'Gestión de conflictos',
      count: 47,
      percentage: 33,
      color: KpiColors.primaryDark,
    ),
    RankedBarItem(
      label: 'Comunicación digital',
      category: 'Comunicación',
      count: 44,
      percentage: 31,
      color: KpiColors.primaryDark,
    ),
    RankedBarItem(
      label: 'Autonomía',
      category: 'Liderazgo positivo',
      count: 41,
      percentage: 29,
      color: KpiColors.turquoise,
    ),
    RankedBarItem(
      label: 'Perseverancia',
      category: 'Negociación',
      count: 39,
      percentage: 27,
      color: KpiColors.primaryDark,
    ),
    RankedBarItem(
      label: 'Gestión del tiempo',
      category: 'Resolución de problemas',
      count: 36,
      percentage: 25,
      color: KpiColors.yellow,
    ),
    RankedBarItem(
      label: 'Apertura sociocultural',
      category: 'Aprender a aprender',
      count: 33,
      percentage: 23,
      color: KpiColors.yellow,
    ),
  ];

  // Áreas de competencia
  static const List<CompetenciaArea> areasCompetencia = [
    CompetenciaArea(name: 'Comunicación', percentage: 14, color: KpiColors.primaryDark, group: 'Sociales'),
    CompetenciaArea(name: 'Trabajo en equipo', percentage: 16, color: KpiColors.primaryDark, group: 'Sociales'),
    CompetenciaArea(name: 'Gestión de conflictos', percentage: 6, color: KpiColors.primaryDark, group: 'Sociales'),
    CompetenciaArea(name: 'Negociación', percentage: 5, color: KpiColors.primaryDark, group: 'Sociales'),
    CompetenciaArea(name: 'Liderazgo positivo', percentage: 16, color: KpiColors.turquoise, group: 'Personales'),
    CompetenciaArea(name: 'Autoevaluación', percentage: 8, color: KpiColors.turquoise, group: 'Personales'),
    CompetenciaArea(name: 'Adaptabilidad', percentage: 5, color: KpiColors.turquoise, group: 'Personales'),
    CompetenciaArea(name: 'Aprender a aprender', percentage: 9, color: KpiColors.yellow, group: 'Metodológicas'),
    CompetenciaArea(name: 'Competencias analíticas', percentage: 5, color: KpiColors.yellow, group: 'Metodológicas'),
    CompetenciaArea(name: 'Creatividad', percentage: 7, color: KpiColors.yellow, group: 'Metodológicas'),
    CompetenciaArea(name: 'Resolución de problemas', percentage: 10, color: KpiColors.yellow, group: 'Metodológicas'),
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
