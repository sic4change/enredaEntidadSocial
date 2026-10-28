import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../kpi_colors.dart';
import '../kpi_models.dart';

class CardLineaTemporalRecursos extends StatefulWidget {
  /// Fechas de creación de todos los recursos.
  final List<DateTime> fechas;
  final bool isLoading;

  const CardLineaTemporalRecursos({
    Key? key,
    this.fechas = const [],
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<CardLineaTemporalRecursos> createState() =>
      _CardLineaTemporalRecursosState();
}

class _CardLineaTemporalRecursosState extends State<CardLineaTemporalRecursos> {
  static const List<String> _monthShort = [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ];
  static const List<String> _monthLong = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];
  static const List<String> _weekdayShort = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  static const List<String> _weekdayLong = [
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo',
  ];

  String _selectedPeriod = 'Año';

  /// Fecha de referencia dentro del periodo mostrado.
  DateTime _anchor = DateTime.now();
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      header: '',
      canShowMarker: true,
      format: 'point.x\nRecursos : point.y',
      textStyle: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: KpiColors.primaryDark,
      ),
      color: Colors.white,
      borderColor: KpiColors.borderLight,
      borderWidth: 1,
      elevation: 4,
    );
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime get _weekStart {
    final d = _dateOnly(_anchor);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  /// Inicio del periodo siguiente al mostrado.
  DateTime get _nextPeriodStart {
    switch (_selectedPeriod) {
      case 'Semana':
        return _weekStart.add(const Duration(days: 7));
      case 'Mes':
        return DateTime(_anchor.year, _anchor.month + 1, 1);
      default:
        return DateTime(_anchor.year + 1, 1, 1);
    }
  }

  bool get _canGoNext => !_nextPeriodStart.isAfter(DateTime.now());

  void _move(int direction) {
    setState(() {
      switch (_selectedPeriod) {
        case 'Semana':
          _anchor = _weekStart.add(Duration(days: 7 * direction));
          break;
        case 'Mes':
          _anchor = DateTime(_anchor.year, _anchor.month + direction, 1);
          break;
        default:
          _anchor = DateTime(_anchor.year + direction, 1, 1);
      }
    });
  }

  String get _periodLabel {
    switch (_selectedPeriod) {
      case 'Semana':
        final start = _weekStart;
        final end = start.add(const Duration(days: 6));
        final startMonth = _monthShort[start.month - 1].toLowerCase();
        final endMonth = _monthShort[end.month - 1].toLowerCase();
        return start.month == end.month
            ? '${start.day} – ${end.day} $endMonth ${end.year}'
            : '${start.day} $startMonth – ${end.day} $endMonth ${end.year}';
      case 'Mes':
        return '${_monthLong[_anchor.month - 1]} ${_anchor.year}';
      default:
        return '${_anchor.year}';
    }
  }

  /// Puntos del periodo seleccionado. Los tramos futuros quedan a `null`
  /// para que no se dibujen. Devuelve también la etiqueta larga de cada punto
  /// para el texto del pico.
  ({List<MonthDataPoint> points, List<String> longLabels}) _buildPoints() {
    final today = _dateOnly(DateTime.now());
    final points = <MonthDataPoint>[];
    final longLabels = <String>[];

    switch (_selectedPeriod) {
      case 'Semana':
        final start = _weekStart;
        for (int i = 0; i < 7; i++) {
          final day = start.add(Duration(days: i));
          final count = widget.fechas.where((f) => _dateOnly(f) == day).length;
          points.add(MonthDataPoint(
            '${_weekdayShort[i]} ${day.day}',
            day.isAfter(today) ? null : count.toDouble(),
          ));
          longLabels.add('${_weekdayLong[i]} ${day.day}');
        }
        break;
      case 'Mes':
        final year = _anchor.year;
        final month = _anchor.month;
        final daysInMonth = DateTime(year, month + 1, 0).day;
        final counts = List<int>.filled(daysInMonth, 0);
        for (final f in widget.fechas) {
          if (f.year == year && f.month == month) counts[f.day - 1]++;
        }
        for (int d = 1; d <= daysInMonth; d++) {
          final day = DateTime(year, month, d);
          points.add(MonthDataPoint(
            '$d',
            day.isAfter(today) ? null : counts[d - 1].toDouble(),
          ));
          longLabels.add('día $d');
        }
        break;
      default:
        final year = _anchor.year;
        final counts = List<int>.filled(12, 0);
        for (final f in widget.fechas) {
          if (f.year == year) counts[f.month - 1]++;
        }
        for (int m = 1; m <= 12; m++) {
          final isFuture =
              year > today.year || (year == today.year && m > today.month);
          points.add(MonthDataPoint(
            _monthShort[m - 1],
            isFuture ? null : counts[m - 1].toDouble(),
          ));
          longLabels.add(_monthLong[m - 1]);
        }
    }
    return (points: points, longLabels: longLabels);
  }

  String _formatAverage(double value) {
    final rounded = (value * 10).round() / 10;
    return rounded == rounded.roundToDouble()
        ? rounded.toInt().toString()
        : rounded.toStringAsFixed(1).replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    final data = _buildPoints();
    final points = data.points;
    final elapsed = points.where((p) => p.value != null).toList();
    final int total = elapsed.fold<int>(0, (sum, p) => sum + p.value!.toInt());
    final double average = elapsed.isNotEmpty ? total / elapsed.length : 0;

    int peakIdx = -1;
    for (int i = 0; i < points.length; i++) {
      final v = points[i].value;
      if (v != null && v > 0 && (peakIdx < 0 || v > points[peakIdx].value!))
        peakIdx = i;
    }
    final String peakValue =
        peakIdx >= 0 ? '${points[peakIdx].value!.toInt()}' : '0';
    final String peakLabel =
        peakIdx >= 0 ? 'pico (${data.longLabels[peakIdx]})' : 'pico';

    final String averageLabel =
        _selectedPeriod == 'Año' ? 'media mensual' : 'media diaria';
    final String totalLabel =
        'recursos subidos ${_selectedPeriod == 'Año' ? _periodLabel : 'en el periodo'}';

    final double maxVal =
        points.fold<double>(1, (m, p) => (p.value ?? 0) > m ? p.value! : m);
    final double interval = (maxVal / 4).ceilToDouble();

    final statCards = [
      _buildStatCard('$total', totalLabel),
      _buildStatCard(_formatAverage(average), averageLabel),
      _buildStatCard(peakValue, peakLabel),
    ];

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
          // Header row with toggle
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 450;
              if (isSmall) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderTitles(),
                    const SizedBox(height: 12),
                    _buildPeriodToggle(),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildHeaderTitles()),
                  _buildPeriodToggle(),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Period stepper [<] periodo [>]
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildArrowButton(
                icon: Icons.chevron_left,
                isEnabled: true,
                onTap: () => _move(-1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  _periodLabel,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: KpiColors.primaryDark,
                  ),
                ),
              ),
              _buildArrowButton(
                icon: Icons.chevron_right,
                isEnabled: _canGoNext,
                onTap: () => _move(1),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Syncfusion Spline Area Chart
          SizedBox(
            height: 220,
            child: SfCartesianChart(
              tooltipBehavior: _tooltipBehavior,
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine:
                    const AxisLine(color: KpiColors.borderLight, width: 1),
                majorTickLines:
                    const MajorTickLines(size: 6, color: KpiColors.borderLight),
                labelIntersectAction: AxisLabelIntersectAction.hide,
                labelStyle: GoogleFonts.outfit(
                  fontSize: 12,
                  color: KpiColors.secondaryText,
                ),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: interval * 4,
                interval: interval,
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                majorGridLines: const MajorGridLines(
                  width: 1,
                  color: KpiColors.divider,
                  dashArray: [4, 4],
                ),
                labelStyle: GoogleFonts.outfit(
                  fontSize: 12,
                  color: KpiColors.secondaryText,
                ),
              ),
              series: <CartesianSeries<MonthDataPoint, String>>[
                SplineAreaSeries<MonthDataPoint, String>(
                  dataSource: points,
                  xValueMapper: (MonthDataPoint data, _) => data.month,
                  yValueMapper: (MonthDataPoint data, _) => data.value,
                  splineType: SplineType.monotonic,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      KpiColors.turquoise.withValues(alpha: 0.32),
                      KpiColors.turquoise.withValues(alpha: 0.02),
                    ],
                  ),
                  borderColor: KpiColors.turquoise,
                  borderWidth: 2.2,
                  markerSettings: MarkerSettings(
                    isVisible: _selectedPeriod != 'Mes',
                    shape: DataMarkerType.circle,
                    color: Colors.white,
                    borderColor: KpiColors.turquoise,
                    borderWidth: 2,
                    width: 7,
                    height: 7,
                  ),
                  emptyPointSettings: EmptyPointSettings(
                    mode: EmptyPointMode.drop,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Bottom 3 stat cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 500;
              if (isSmall) {
                return Column(
                  children: [
                    statCards[0],
                    const SizedBox(height: 8),
                    statCards[1],
                    const SizedBox(height: 8),
                    statCards[2],
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: statCards[0]),
                  const SizedBox(width: 12),
                  Expanded(child: statCards[1]),
                  const SizedBox(width: 12),
                  Expanded(child: statCards[2]),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTitles() {
    final subtitle = _selectedPeriod == 'Año'
        ? 'Recursos subidos por mes'
        : 'Recursos subidos por día';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                'Línea temporal de recursos',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: KpiColors.primaryDark,
                ),
              ),
            ),
            if (widget.isLoading) ...[
              const SizedBox(width: 12),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(KpiColors.turquoise),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: KpiColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: KpiColors.tileBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['Semana', 'Mes', 'Año'].map((period) {
          final isSelected = _selectedPeriod == period;
          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () {
              setState(() {
                _selectedPeriod = period;
                _anchor = DateTime.now();
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
                period,
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

  Widget _buildArrowButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isEnabled ? KpiColors.primaryDark : KpiColors.borderLight,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 14,
          color: isEnabled ? KpiColors.primaryDark : KpiColors.borderLight,
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: KpiColors.tileBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: KpiColors.primaryDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: KpiColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
