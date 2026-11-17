import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../models/userEnreda.dart';
import '../kpi_colors.dart';
import '../kpi_models.dart';
import 'kpi_chart_trackball.dart';

class CardEvolucionInscripciones extends StatefulWidget {
  final List<UserEnreda>? users;
  final bool isLoading;

  const CardEvolucionInscripciones({
    Key? key,
    this.users,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<CardEvolucionInscripciones> createState() =>
      _CardEvolucionInscripcionesState();
}

/// Un 0 junto a otro 0 forma un tramo plano: su marcador no se muestra.
bool _isFlatZero(List<MonthDataPoint> points, int index) {
  if (points[index].value != 0) return false;
  final prev = index > 0 ? points[index - 1].value : null;
  final next = index < points.length - 1 ? points[index + 1].value : null;
  return prev == 0 || next == 0;
}

class _CardEvolucionInscripcionesState
    extends State<CardEvolucionInscripciones> {
  String _selectedPeriod = 'Año'; // 'Semana', 'Mes', 'Año'
  late int _selectedYear;
  late int _selectedMonth;
  late DateTime _selectedWeekStart;

  static const List<String> _monthNames = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre'
  ];

  static const List<String> _monthAbbr = [
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
    'Dic'
  ];

  static const List<String> _weekDays = [
    'Lun',
    'Mar',
    'Mié',
    'Jue',
    'Vie',
    'Sáb',
    'Dom'
  ];

  static const List<String> _weekDayFullNames = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];

  DateTime _getMonday(DateTime date) {
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: date.weekday - 1));
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _selectedWeekStart = _getMonday(now);
  }

  List<DateTime> _getValidDates() {
    if (widget.users == null) return [];
    return widget.users!
        .map((u) => u.createDate ?? u.startDateItinerary)
        .where((d) => d != null)
        .cast<DateTime>()
        .toList();
  }

  int _getMinYear(List<DateTime> dates) {
    if (dates.isEmpty) return 2020;
    final earliest = dates.map((d) => d.year).reduce(min);
    return min(earliest, 2020);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dates = _getValidDates();
    final minYear = _getMinYear(dates);

    // Compute chart data, totals, average, peak based on _selectedPeriod
    List<MonthDataPoint> points = [];
    int totalCount = 0;
    String totalLabel = '';
    String avgValue = '0,0';
    String avgLabel = '';
    String peakValue = '0';
    String peakLabel = 'sin inscripciones';
    String subtitle = 'Inscripciones nuevas por mes';
    String Function(String x) tooltipTitle = (x) => x;

    if (_selectedPeriod == 'Año') {
      subtitle = 'Inscripciones nuevas por mes en $_selectedYear';
      tooltipTitle = (x) {
        final i = _monthAbbr.indexOf(x);
        return '${i >= 0 ? _monthNames[i] : x} $_selectedYear';
      };
      totalLabel = 'inscripciones en $_selectedYear';
      avgLabel = 'media mensual';

      int peakMonth = 1;
      int peakMonthCount = 0;

      for (int m = 1; m <= 12; m++) {
        final count =
            dates.where((d) => d.year == _selectedYear && d.month == m).length;
        final bool isFuture = _selectedYear == now.year && m > now.month;

        if (isFuture) {
          points.add(MonthDataPoint(_monthAbbr[m - 1], null));
        } else {
          points.add(MonthDataPoint(_monthAbbr[m - 1], count.toDouble()));
          totalCount += count;
          if (count > peakMonthCount) {
            peakMonthCount = count;
            peakMonth = m;
          }
        }
      }

      final int monthsElapsed = _selectedYear == now.year
          ? now.month
          : (_selectedYear < now.year ? 12 : 1);
      final double avg = monthsElapsed > 0 ? totalCount / monthsElapsed : 0.0;
      // Media mensual redondeada a participantes enteros
      avgValue = '${avg.round()}';

      if (totalCount > 0) {
        peakValue = '$peakMonthCount';
        peakLabel = 'pico (${_monthNames[peakMonth - 1].toLowerCase()})';
      }
    } else if (_selectedPeriod == 'Mes') {
      final monthName = _monthNames[_selectedMonth - 1];
      subtitle = 'Inscripciones nuevas por día en $monthName $_selectedYear';
      tooltipTitle = (x) => 'Día $x de $monthName';
      totalLabel = 'inscripciones en $monthName';
      avgLabel = 'media diaria';

      final totalDaysInMonth =
          DateTime(_selectedYear, _selectedMonth + 1, 0).day;
      int peakDay = 1;
      int peakDayCount = 0;

      for (int day = 1; day <= totalDaysInMonth; day++) {
        final count = dates
            .where((d) =>
                d.year == _selectedYear &&
                d.month == _selectedMonth &&
                d.day == day)
            .length;
        final bool isFuture = _selectedYear == now.year &&
            _selectedMonth == now.month &&
            day > now.day;

        if (isFuture) {
          points.add(MonthDataPoint('$day', null));
        } else {
          points.add(MonthDataPoint('$day', count.toDouble()));
          totalCount += count;
          if (count > peakDayCount) {
            peakDayCount = count;
            peakDay = day;
          }
        }
      }

      final int daysElapsed =
          (_selectedYear == now.year && _selectedMonth == now.month)
              ? now.day
              : (_selectedYear < now.year ||
                      (_selectedYear == now.year && _selectedMonth < now.month)
                  ? totalDaysInMonth
                  : 1);
      final double avg = daysElapsed > 0 ? totalCount / daysElapsed : 0.0;
      avgValue = avg.toStringAsFixed(1).replaceAll('.', ',');

      if (totalCount > 0) {
        peakValue = '$peakDayCount';
        peakLabel = 'pico (día $peakDay)';
      }
    } else {
      // Semana
      subtitle = 'Inscripciones diarias de la semana';
      totalLabel = 'inscripciones en la semana';
      avgLabel = 'media diaria';

      int peakWd = 1;
      int peakWdCount = 0;
      int elapsedDays = 0;

      for (int i = 0; i < 7; i++) {
        final dayDate = _selectedWeekStart.add(Duration(days: i));
        final bool isFuture =
            dayDate.isAfter(DateTime(now.year, now.month, now.day));
        final count = dates
            .where((d) =>
                d.year == dayDate.year &&
                d.month == dayDate.month &&
                d.day == dayDate.day)
            .length;

        if (isFuture) {
          points.add(MonthDataPoint(_weekDays[i], null));
        } else {
          elapsedDays++;
          points.add(MonthDataPoint(_weekDays[i], count.toDouble()));
          totalCount += count;
          if (count > peakWdCount) {
            peakWdCount = count;
            peakWd = i + 1;
          }
        }
      }

      final double avg = elapsedDays > 0 ? totalCount / elapsedDays : 0.0;
      avgValue = avg.toStringAsFixed(1).replaceAll('.', ',');

      if (totalCount > 0) {
        peakValue = '$peakWdCount';
        peakLabel = 'pico (${_weekDayFullNames[peakWd - 1].toLowerCase()})';
      }
    }

    // Dynamic Y-axis scale
    final double maxVal = points
        .where((p) => p.value != null)
        .fold(0.0, (prev, p) => p.value! > prev ? p.value! : prev);

    double maxY;
    double interval;
    if (maxVal <= 5) {
      maxY = 5;
      interval = 1;
    } else if (maxVal <= 10) {
      maxY = 10;
      interval = 2;
    } else if (maxVal <= 25) {
      maxY = ((maxVal / 5).ceil() * 5).toDouble();
      interval = 5;
    } else if (maxVal <= 60) {
      maxY = ((maxVal / 10).ceil() * 10).toDouble();
      interval = (maxY / 5).ceilToDouble();
    } else {
      maxY = ((maxVal / 50).ceil() * 50).toDouble();
      interval = (maxY / 5).ceilToDouble();
    }

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
                    _buildHeaderTitles(subtitle),
                    const SizedBox(height: 12),
                    _buildPeriodToggle(),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildHeaderTitles(subtitle)),
                  _buildPeriodToggle(),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Date stepper [<] label [>]
          _buildDateStepper(now, minYear),
          const SizedBox(height: 16),

          // Syncfusion Area Spline Chart
          SizedBox(
            height: 320,
            child: widget.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(KpiColors.turquoise),
                    ),
                  )
                : SfCartesianChart(
                    trackballBehavior: kpiTrackball(
                      title: tooltipTitle,
                      label: 'Inscripciones',
                    ),
                    plotAreaBorderWidth: 0,
                    margin: EdgeInsets.zero,
                    primaryXAxis: CategoryAxis(
                      majorGridLines: const MajorGridLines(width: 0),
                      axisLine: const AxisLine(
                          color: KpiColors.borderLight, width: 1),
                      majorTickLines: const MajorTickLines(
                          size: 6, color: KpiColors.borderLight),
                      labelStyle: GoogleFonts.outfit(
                        fontSize: 12,
                        color: KpiColors.secondaryText,
                      ),
                    ),
                    primaryYAxis: NumericAxis(
                      minimum: 0,
                      maximum: maxY,
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
                    // Sin inscripciones en el periodo no se dibuja la serie:
                    // la línea en 0 solo cubriría los días ya transcurridos
                    series: <CartesianSeries<MonthDataPoint, String>>[
                      if (maxVal > 0)
                        SplineAreaSeries<MonthDataPoint, String>(
                          dataSource: points,
                          xValueMapper: (MonthDataPoint data, _) => data.month,
                          yValueMapper: (MonthDataPoint data, _) => data.value,
                          splineType: SplineType.natural,
                          color: KpiColors.turquoise.withValues(alpha: 0.2),
                          borderColor: KpiColors.turquoise,
                          borderWidth: 2,
                          emptyPointSettings: EmptyPointSettings(
                            mode: EmptyPointMode.drop,
                          ),
                        ),
                      // Marcadores en una serie aparte para poder ocultar los
                      // ceros que están junto a otro cero (tramos planos)
                      if (maxVal > 0)
                        LineSeries<MonthDataPoint, String>(
                          dataSource: points,
                          color: Colors.transparent,
                          width: 0,
                          xValueMapper: (MonthDataPoint data, _) => data.month,
                          yValueMapper: (MonthDataPoint data, int index) =>
                              _isFlatZero(points, index) ? null : data.value,
                          enableTooltip: false,
                          markerSettings: const MarkerSettings(
                            isVisible: true,
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
                    _buildStatCard('$totalCount', totalLabel),
                    const SizedBox(height: 8),
                    _buildStatCard(avgValue, avgLabel),
                    const SizedBox(height: 8),
                    _buildStatCard(peakValue, peakLabel),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: _buildStatCard('$totalCount', totalLabel)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(avgValue, avgLabel)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(peakValue, peakLabel)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTitles(String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evolución de inscripciones',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: KpiColors.primaryDark,
          ),
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

  Widget _buildDateStepper(DateTime now, int minYear) {
    String label = '';
    bool canPrev = false;
    bool canNext = false;
    VoidCallback onPrev = () {};
    VoidCallback onNext = () {};

    if (_selectedPeriod == 'Año') {
      label = '$_selectedYear';
      canPrev = _selectedYear > minYear;
      canNext = _selectedYear < now.year;
      onPrev = () => setState(() => _selectedYear--);
      onNext = () => setState(() => _selectedYear++);
    } else if (_selectedPeriod == 'Mes') {
      label = '${_monthNames[_selectedMonth - 1]} $_selectedYear';
      canPrev = _selectedYear > minYear ||
          (_selectedYear == minYear && _selectedMonth > 1);
      canNext = _selectedYear < now.year ||
          (_selectedYear == now.year && _selectedMonth < now.month);
      onPrev = () {
        setState(() {
          if (_selectedMonth == 1) {
            _selectedYear--;
            _selectedMonth = 12;
          } else {
            _selectedMonth--;
          }
        });
      };
      onNext = () {
        setState(() {
          if (_selectedMonth == 12) {
            _selectedYear++;
            _selectedMonth = 1;
          } else {
            _selectedMonth++;
          }
        });
      };
    } else {
      // Semana
      final weekEnd = _selectedWeekStart.add(const Duration(days: 6));
      final startMonth = _monthAbbr[_selectedWeekStart.month - 1];
      final endMonth = _monthAbbr[weekEnd.month - 1];
      if (_selectedWeekStart.month == weekEnd.month) {
        label =
            '${_selectedWeekStart.day} - ${weekEnd.day} $endMonth ${weekEnd.year}';
      } else {
        label =
            '${_selectedWeekStart.day} $startMonth - ${weekEnd.day} $endMonth ${weekEnd.year}';
      }

      canPrev = _selectedWeekStart.year >= minYear - 1;
      canNext = _selectedWeekStart.isBefore(_getMonday(now));
      onPrev = () {
        setState(() {
          _selectedWeekStart =
              _selectedWeekStart.subtract(const Duration(days: 7));
        });
      };
      onNext = () {
        setState(() {
          _selectedWeekStart = _selectedWeekStart.add(const Duration(days: 7));
        });
      };
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildArrowButton(
          icon: Icons.chevron_left,
          isEnabled: canPrev,
          onTap: onPrev,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: KpiColors.primaryDark,
            ),
          ),
        ),
        _buildArrowButton(
          icon: Icons.chevron_right,
          isEnabled: canNext,
          onTap: onNext,
        ),
      ],
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
