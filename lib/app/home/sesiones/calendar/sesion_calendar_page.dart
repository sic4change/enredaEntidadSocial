import 'package:enreda_empresas/app/home/sesiones/calendar/gcal_link.dart';
import 'package:enreda_empresas/app/home/sesiones/calendar/gcal_open.dart';
import 'package:enreda_empresas/app/home/sesiones/calendar/ics_download.dart';
import 'package:enreda_empresas/app/home/sesiones/calendar/ics_export.dart';
import 'package:enreda_empresas/app/home/sesiones/widgets/sesion_list_tile.dart';
import 'package:enreda_empresas/app/models/sesion.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:enreda_empresas/app/home/resources/global.dart' as globals;

/// Técnico's personal calendar: monthly grid showing only the sessions they
/// own (`sesion.tecnicoId == currentSocialEntityUser.userId`).
///
/// Desktop layout: calendar card (max-width 520px) on the left, sessions
/// panel filling the remaining row to the right. Mobile / tablet keep the
/// classic vertical stack so day-panel content has full width.
///
/// Filtering is server-side: `sesionesCalendarioStream(entityId, tecnicoId)`
/// uses `where('tecnicoId', isEqualTo: ...)` — no client-side scan needed.
///
/// Forward-looking: the per-session `isAllDay` flag + the time component of
/// `scheduledAt` are exactly the two fields Google Calendar's `events` API
/// uses (`start.date` vs `start.dateTime`), so the model is already wire-
/// compatible with a future gCal integration spanning all técnicos.
class SesionCalendarPage extends StatefulWidget {
  const SesionCalendarPage({
    super.key,
    required this.socialEntity,
    required this.onTapSesion,
    required this.onClose,
  });

  final SocialEntity socialEntity;
  final ValueChanged<Sesion> onTapSesion;
  final VoidCallback onClose;

  @override
  State<SesionCalendarPage> createState() => _SesionCalendarPageState();
}

/// Maximum width of the calendar card on desktop. Anything beyond ~520px and
/// the cells start to feel oversized for what is now a compact overview.
const double _kCalendarMaxWidth = 520;

/// Filter buttons above the calendar — pill bar mirroring the Próximas /
/// Pasadas tabs from `sesiones_page.dart`, plus an additional "Todas" view.
/// Defaults to [proximas] when the page opens so the user lands on upcoming
/// sessions first.
enum _CalendarFilter { proximas, pasadas, todas }

class _SesionCalendarPageState extends State<SesionCalendarPage> {
  DateTime _focusedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );
  DateTime? _selectedDay;
  _CalendarFilter _filter = _CalendarFilter.proximas;

  @override
  Widget build(BuildContext context) {
    final tecnicoId = globals.currentSocialEntityUser?.userId ?? '';
    final entityId = widget.socialEntity.socialEntityId ?? '';
    final database = Provider.of<Database>(context, listen: false);
    final isMobile = Responsive.isMobile(context);
    final isDesktop = Responsive.isDesktop(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? Sizes.PADDING_12 : Sizes.PADDING_30,
        vertical: isMobile ? Sizes.PADDING_16 : Sizes.PADDING_24,
      ),
      child: StreamBuilder<List<Sesion>>(
        stream: database.sesionesCalendarioStream(entityId, tecnicoId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _ErrorView(message: snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final allSesiones = snapshot.data ?? <Sesion>[];

          // Index sessions by calendar date (year-month-day key) for O(1) lookup.
          // Sort each day's bucket: all-day sessions first, then by time asc.
          final Map<String, List<Sesion>> byDay = {};
          for (final s in allSesiones) {
            final key = _dayKey(s.scheduledAt);
            byDay.putIfAbsent(key, () => []).add(s);
          }
          for (final list in byDay.values) {
            list.sort(_compareSessions);
          }

          final calendarCard = _CalendarCard(
            focusedMonth: _focusedMonth,
            sessionDays: byDay,
            selectedDay: _selectedDay,
            isMobile: isMobile,
            isTablet: Responsive.isTablet(context),
            onPrevMonth: () => setState(() => _focusedMonth = DateTime(
                _focusedMonth.year, _focusedMonth.month - 1)),
            onNextMonth: () => setState(() => _focusedMonth = DateTime(
                _focusedMonth.year, _focusedMonth.month + 1)),
            onDayTap: (day) => setState(() {
              _selectedDay = _selectedDay != null &&
                      _isSameDay(_selectedDay!, day)
                  ? null
                  : day;
            }),
          );

          final sessionsPanel = _SessionsPanel(
            focusedMonth: _focusedMonth,
            selectedDay: _selectedDay,
            allSesiones: allSesiones,
            sessionsByDay: byDay,
            isMobile: isMobile,
            filter: _filter,
            onTapSesion: widget.onTapSesion,
          );

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CalendarHeader(
                  isMobile: isMobile,
                  onClose: widget.onClose,
                ),
                SizedBox(height: isMobile ? Sizes.PADDING_8 : Sizes.PADDING_12),
                _ExportIcsButton(
                  isMobile: isMobile,
                  onPressed: () => _handleExportIcs(context, allSesiones),
                ),
                SizedBox(height: isMobile ? Sizes.PADDING_16 : Sizes.PADDING_20),
                // Filter pills — Próximas / Pasadas / Todas. Default = Próximas.
                // Mounted directly above the sessions panel (NOT above the
                // full-width content) so the pills visually scope to the
                // right rail they actually control. Tapping a filter also
                // clears any day selection so the panel re-renders from the
                // new filter rather than the previously selected day.
                if (isDesktop)
                  // Side-by-side: compact calendar (left) + filter pills +
                  // sessions panel (right). No `IntrinsicHeight` here —
                  // `SesionListTile` uses `Stack` + `Positioned` which can't
                  // report intrinsic size, and wrapping the Row in
                  // IntrinsicHeight crashes hit-testing with "render box
                  // with no size". Letting each side grow independently
                  // looks identical on screen because the calendar card is
                  // fixed-height anyway.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _kCalendarMaxWidth,
                        ),
                        child: calendarCard,
                      ),
                      const SizedBox(width: Sizes.PADDING_24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _CalendarFilterBar(
                              activeFilter: _filter,
                              onSelect: (f) => setState(() {
                                _filter = f;
                                _selectedDay = null;
                              }),
                            ),
                            const SizedBox(height: Sizes.PADDING_16),
                            sessionsPanel,
                          ],
                        ),
                      ),
                    ],
                  )
                else ...[
                  // Mobile / tablet: vertical stack — calendar full width on
                  // top, then filter pills, then sessions panel below.
                  // Avoids horizontal cramping.
                  calendarCard,
                  SizedBox(
                      height: isMobile ? Sizes.PADDING_16 : Sizes.PADDING_20),
                  _CalendarFilterBar(
                    activeFilter: _filter,
                    onSelect: (f) => setState(() {
                      _filter = f;
                      _selectedDay = null;
                    }),
                  ),
                  const SizedBox(height: Sizes.PADDING_12),
                  sessionsPanel,
                ],
                SizedBox(height: isMobile ? Sizes.PADDING_30 : Sizes.PADDING_20),
              ],
            ),
          );
        },
      ),
    );
  }

  String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// All-day sessions float to the top; specific-time sessions are sorted
  /// ascending by hour:minute within the day.
  int _compareSessions(Sesion a, Sesion b) {
    if (a.isAllDay != b.isAllDay) return a.isAllDay ? -1 : 1;
    if (a.isAllDay && b.isAllDay) return a.scheduledAt.compareTo(b.scheduledAt);
    final at = a.scheduledAt.hour * 60 + a.scheduledAt.minute;
    final bt = b.scheduledAt.hour * 60 + b.scheduledAt.minute;
    return at.compareTo(bt);
  }

  /// Filters [allSesiones] to the focused month, sorts chronologically, and
  /// triggers a browser download of the resulting `.ics` payload. Shows a
  /// snackbar on success / empty month / unsupported platform.
  void _handleExportIcs(BuildContext context, List<Sesion> allSesiones) {
    final monthSesiones = allSesiones
        .where((s) =>
            s.scheduledAt.year == _focusedMonth.year &&
            s.scheduledAt.month == _focusedMonth.month)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    final messenger = ScaffoldMessenger.of(context);

    if (monthSesiones.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(StringConst.CALENDARIO_EXPORT_ICS_EMPTY),
        ),
      );
      return;
    }

    try {
      // Collect every invited-participant id across the month and resolve
      // them once so each VEVENT's DESCRIPTION can list real names.
      final ids = <String>{
        for (final s in monthSesiones) ...s.invitedParticipants,
      };
      final names = resolveParticipantNames(ids);
      final content = buildIcsCalendar(monthSesiones, participantNames: names);
      final yyyymm =
          '${_focusedMonth.year}-${_focusedMonth.month.toString().padLeft(2, '0')}';
      downloadIcs(content, 'enreda-sesiones-$yyyymm.ics');
      messenger.showSnackBar(
        const SnackBar(
          content: Text(StringConst.CALENDARIO_EXPORT_ICS_SUCCESS),
        ),
      );
    } on UnsupportedError {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(StringConst.CALENDARIO_EXPORT_ICS_UNSUPPORTED),
        ),
      );
    }
  }
}

/// Resolves a set of participant user ids to `{id → "Firstname Lastname"}`
/// using [LocationCache.instance]. Falls back to the bulk `allParticipants`
/// list when an id misses the per-user cache. Unresolved ids are simply
/// omitted from the returned map — the consumers in `ics_export.dart` /
/// `gcal_link.dart` already handle that case (drop the missing entries,
/// fall back to a count when every id is unresolved).
///
/// Returns an empty map when [ids] is empty.
Map<String, String> resolveParticipantNames(Iterable<String> ids) {
  final cache = LocationCache.instance;
  final out = <String, String>{};
  final seen = <String>{};
  for (final id in ids) {
    if (id.isEmpty || seen.contains(id)) continue;
    seen.add(id);
    UserEnreda? user = cache.userCache[id];
    if (user == null) {
      for (final u in cache.allParticipants) {
        if (u.userId == id) {
          user = u;
          break;
        }
      }
    }
    if (user == null) continue;
    final name = '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
    if (name.isNotEmpty) out[id] = name;
  }
  return out;
}

/// Right-aligned "Descargar .ics" button shown beneath the page header.
/// Tap downloads the focused month's sessions as an iCalendar file.
class _ExportIcsButton extends StatelessWidget {
  const _ExportIcsButton({required this.isMobile, required this.onPressed});

  final bool isMobile;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.centerRight,
      child: Tooltip(
        message: StringConst.CALENDARIO_EXPORT_ICS_TOOLTIP,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: const Icon(
            Icons.file_download_outlined,
            size: Sizes.ICON_SIZE_20,
            color: AppColors.primary900,
          ),
          label: Text(
            StringConst.CALENDARIO_EXPORT_ICS_LABEL,
            style: (isMobile ? textTheme.bodySmall : textTheme.bodyMedium)
                ?.copyWith(
              color: AppColors.primary900,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.greyBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Sizes.RADIUS_25),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? Sizes.PADDING_12 : Sizes.PADDING_16,
              vertical: isMobile ? Sizes.PADDING_8 : Sizes.PADDING_12,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────

/// Page header: back-button (returns to list) + calendar title.
/// On mobile the title sits below the back-button so neither truncates.
class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({required this.isMobile, required this.onClose});

  final bool isMobile;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final backButton = TextButton.icon(
      onPressed: onClose,
      icon: const Icon(
        Icons.arrow_back,
        color: AppColors.primary900,
        size: Sizes.ICON_SIZE_20,
      ),
      label: Text(
        StringConst.SESIONES,
        style: (isMobile ? textTheme.titleMedium : textTheme.headlineSmall)
            ?.copyWith(color: AppColors.primary900),
      ),
    );

    final title = Text(
      StringConst.CALENDARIO_TITLE,
      style: (isMobile ? textTheme.bodyLarge : textTheme.titleMedium)?.copyWith(
        color: AppColors.greyTxtAlt,
        fontWeight: FontWeight.w400,
      ),
      overflow: TextOverflow.ellipsis,
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          backButton,
          Padding(
            padding: const EdgeInsets.only(left: Sizes.PADDING_8),
            child: title,
          ),
        ],
      );
    }
    return Row(
      children: [
        backButton,
        const Spacer(),
        Flexible(child: title),
      ],
    );
  }
}

// ── Calendar card ─────────────────────────────────────────────────────────

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.focusedMonth,
    required this.sessionDays,
    required this.selectedDay,
    required this.isMobile,
    required this.isTablet,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onDayTap,
  });

  final DateTime focusedMonth;
  final Map<String, List<Sesion>> sessionDays;
  final DateTime? selectedDay;
  final bool isMobile;
  final bool isTablet;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Sizes.RADIUS_16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary900.withOpacity(0.1),
            blurRadius: Sizes.PADDING_20,
          ),
        ],
      ),
      padding: EdgeInsets.all(
        isMobile ? Sizes.PADDING_12 : Sizes.PADDING_24,
      ),
      child: Column(
        children: [
          _MonthNavBar(
            focusedMonth: focusedMonth,
            isMobile: isMobile,
            onPrev: onPrevMonth,
            onNext: onNextMonth,
          ),
          SizedBox(height: isMobile ? Sizes.PADDING_8 : Sizes.PADDING_12),
          _CalendarLegend(isMobile: isMobile),
          SizedBox(height: isMobile ? Sizes.PADDING_8 : Sizes.PADDING_16),
          _CalendarGrid(
            focusedMonth: focusedMonth,
            sessionDays: sessionDays,
            selectedDay: selectedDay,
            isMobile: isMobile,
            isTablet: isTablet,
            onDayTap: onDayTap,
          ),
        ],
      ),
    );
  }
}

// ── Month navigation bar ──────────────────────────────────────────────────

class _MonthNavBar extends StatelessWidget {
  const _MonthNavBar({
    required this.focusedMonth,
    required this.isMobile,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime focusedMonth;
  final bool isMobile;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    String label;
    try {
      label = DateFormat('MMMM yyyy', 'es_ES').format(focusedMonth);
      label = label[0].toUpperCase() + label.substring(1);
    } catch (_) {
      label = DateFormat('MMMM yyyy').format(focusedMonth);
    }
    final iconSize = isMobile ? Sizes.ICON_SIZE_20 : Sizes.ICON_SIZE_24;
    final iconPadding = isMobile
        ? const EdgeInsets.all(Sizes.PADDING_4)
        : const EdgeInsets.all(Sizes.PADDING_8);
    return Row(
      children: [
        IconButton(
          onPressed: onPrev,
          padding: iconPadding,
          constraints: const BoxConstraints(),
          icon: Icon(
            Icons.chevron_left,
            color: AppColors.primary900,
            size: iconSize,
          ),
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: (isMobile ? textTheme.bodyLarge : textTheme.titleMedium)
                ?.copyWith(
              color: AppColors.primary900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          onPressed: onNext,
          padding: iconPadding,
          constraints: const BoxConstraints(),
          icon: Icon(
            Icons.chevron_right,
            color: AppColors.primary900,
            size: iconSize,
          ),
        ),
      ],
    );
  }
}

// ── Calendar legend ───────────────────────────────────────────────────────

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: isMobile ? Sizes.PADDING_12 : Sizes.PADDING_20,
      runSpacing: Sizes.PADDING_8,
      children: [
        _LegendChip(
          color: AppColors.primary050,
          borderColor: AppColors.primary100,
          label: StringConst.CALENDARIO_LEGEND_UPCOMING,
          isMobile: isMobile,
        ),
        _LegendChip(
          color: AppColors.altWhite,
          borderColor: AppColors.greyBorder,
          label: StringConst.CALENDARIO_LEGEND_PAST,
          isMobile: isMobile,
        ),
        _LegendChip(
          color: AppColors.primary100,
          borderColor: AppColors.primary500,
          label: StringConst.CALENDARIO_LEGEND_TODAY,
          isMobile: isMobile,
        ),
        _LegendChip(
          color: AppColors.yellow,
          borderColor: AppColors.yellow,
          label: StringConst.CALENDARIO_LEGEND_SELECTED,
          isMobile: isMobile,
        ),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.color,
    required this.borderColor,
    required this.label,
    required this.isMobile,
  });

  final Color color;
  final Color borderColor;
  final String label;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final swatchSize = isMobile ? 12.0 : 14.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: swatchSize,
          height: swatchSize,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(Sizes.RADIUS_4),
            border: Border.all(color: borderColor, width: 1),
          ),
        ),
        const SizedBox(width: Sizes.PADDING_6),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.greyTxtAlt,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Calendar grid ─────────────────────────────────────────────────────────

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.focusedMonth,
    required this.sessionDays,
    required this.selectedDay,
    required this.isMobile,
    required this.isTablet,
    required this.onDayTap,
  });

  final DateTime focusedMonth;
  final Map<String, List<Sesion>> sessionDays;
  final DateTime? selectedDay;
  final bool isMobile;
  final bool isTablet;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final firstOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final startOffset = (firstOfMonth.weekday - 1) % 7;
    final daysInMonth =
        DateUtils.getDaysInMonth(focusedMonth.year, focusedMonth.month);
    final today = DateTime.now();

    // Aspect ratio tuned for the compact 520-max desktop card (cells stay
    // square-ish) and the larger mobile card (cells slightly taller).
    final cellAspectRatio = isMobile
        ? 0.9
        : isTablet
            ? 1.0
            : 1.0;
    final cellSpacing = isMobile ? Sizes.PADDING_2 : Sizes.PADDING_4;

    return Column(
      children: [
        Row(
          children: StringConst.CALENDARIO_WEEKDAYS
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.seaBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: Sizes.PADDING_8),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: cellSpacing,
            crossAxisSpacing: cellSpacing,
            childAspectRatio: cellAspectRatio,
          ),
          itemCount: startOffset + daysInMonth,
          itemBuilder: (context, index) {
            if (index < startOffset) return const SizedBox.shrink();
            final day = index - startOffset + 1;
            final date = DateTime(focusedMonth.year, focusedMonth.month, day);
            final key = '${date.year}-${date.month}-${date.day}';
            final daySessions = sessionDays[key] ?? const <Sesion>[];
            final hasSessions = daySessions.isNotEmpty;
            final isSelected = selectedDay != null &&
                selectedDay!.year == date.year &&
                selectedDay!.month == date.month &&
                selectedDay!.day == date.day;
            final isToday = date.year == today.year &&
                date.month == today.month &&
                date.day == today.day;
            final isPast = date.isBefore(
                DateTime(today.year, today.month, today.day));

            return _DayCell(
              day: day,
              date: date,
              sessions: daySessions,
              isSelected: isSelected,
              isToday: isToday,
              isPast: isPast,
              isMobile: isMobile,
              onTap: () => onDayTap(date),
            );
          },
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.date,
    required this.sessions,
    required this.isSelected,
    required this.isToday,
    required this.isPast,
    required this.isMobile,
    required this.onTap,
  });

  final int day;
  final DateTime date;
  final List<Sesion> sessions;
  final bool isSelected;
  final bool isToday;
  final bool isPast;
  final bool isMobile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasSessions = sessions.isNotEmpty;
    final sessionCount = sessions.length;

    Color bgColor = Colors.transparent;
    Color textColor = isPast ? AppColors.greyTxtAlt : AppColors.primary900;
    bool boldText = false;

    if (isSelected) {
      bgColor = AppColors.yellow;
      textColor = AppColors.primary900;
      boldText = true;
    } else if (isToday) {
      bgColor = AppColors.primary100;
      textColor = AppColors.primary900;
      boldText = true;
    } else if (hasSessions) {
      bgColor = isPast ? AppColors.altWhite : AppColors.primary050;
      boldText = true;
    }

    Border? border;
    if (isToday && !isSelected) {
      border = Border.all(color: AppColors.primary500, width: 1.5);
    } else if (hasSessions && !isSelected && !isToday) {
      border = Border.all(
        color: isPast ? AppColors.greyBorder : AppColors.primary100,
        width: 1,
      );
    }

    final indicatorColor =
        isPast ? AppColors.greyTxtAlt : AppColors.primary500;

    final dayTextStyle =
        (isMobile ? textTheme.bodySmall : textTheme.bodyMedium)?.copyWith(
      color: textColor,
      fontWeight: boldText ? FontWeight.w700 : FontWeight.w400,
    );
    final badgeMinSize = isMobile ? 14.0 : 16.0;
    final badgeFontSize = isMobile ? 9.0 : 10.0;
    final badgePadding = isMobile
        ? const EdgeInsets.symmetric(horizontal: 3, vertical: 1)
        : const EdgeInsets.symmetric(horizontal: 4, vertical: 1);

    final cellInterior = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Sizes.RADIUS_8),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(Sizes.RADIUS_8),
          border: border,
        ),
        child: Stack(
          children: [
            Center(child: Text('$day', style: dayTextStyle)),
            // Always show count badge for any day with sessions. Single-
            // session days previously got a bottom indicator bar — replaced
            // by the consistent top-right number so the user can scan the
            // month at a glance and see exactly how many sessions per day.
            if (hasSessions)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: badgeMinSize,
                    minHeight: badgeMinSize,
                  ),
                  padding: badgePadding,
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    borderRadius: BorderRadius.circular(Sizes.RADIUS_10),
                  ),
                  child: Center(
                    child: Text(
                      '$sessionCount',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: badgeFontSize,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    // Tooltip-driven hover details — only meaningful when the day has
    // sessions. Mobile users tap to select; desktop users see the rich list
    // on hover via Flutter's built-in Tooltip.
    if (!hasSessions) return cellInterior;

    return Tooltip(
      waitDuration: const Duration(milliseconds: 250),
      preferBelow: false,
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.PADDING_12,
        vertical: Sizes.PADDING_8,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary900,
        borderRadius: BorderRadius.circular(Sizes.RADIUS_8),
      ),
      textStyle: textTheme.bodySmall!.copyWith(color: AppColors.white),
      richMessage: _buildTooltipMessage(textTheme),
      child: cellInterior,
    );
  }

  /// Builds a multi-line rich tooltip:
  ///   line 1: bold day header ("Lunes 24 nov · 3 sesiones")
  ///   then up to 3 sessions formatted as "10:30 — Sesión grupal"
  ///   then "y N más" if there are more sessions on that day
  InlineSpan _buildTooltipMessage(TextTheme textTheme) {
    final headerStyle = textTheme.bodySmall!.copyWith(
      color: AppColors.white,
      fontWeight: FontWeight.w700,
    );
    final lineStyle = textTheme.bodySmall!.copyWith(
      color: AppColors.white,
    );

    String header;
    try {
      header = DateFormat("EEEE d 'de' MMM", 'es_ES').format(date);
      header = header[0].toUpperCase() + header.substring(1);
    } catch (_) {
      header = DateFormat('EEE d MMM').format(date);
    }
    final countLabel = sessions.length == 1
        ? '1 ${StringConst.CALENDARIO_HOVER_SESION_SINGULAR}'
        : '${sessions.length} ${StringConst.CALENDARIO_HOVER_SESION_PLURAL}';

    final preview = sessions.take(3).toList();
    final more = sessions.length - preview.length;

    final spans = <InlineSpan>[
      TextSpan(text: '$header · $countLabel\n', style: headerStyle),
    ];
    for (final s in preview) {
      spans.add(TextSpan(
        text: '${_formatSessionTimePrefix(s)} — ${_titleFor(s)}\n',
        style: lineStyle,
      ));
    }
    if (more > 0) {
      spans.add(TextSpan(
        text: StringConst.CALENDARIO_HOVER_AND_MORE
            .replaceAll('%COUNT%', more.toString()),
        style: lineStyle.copyWith(fontStyle: FontStyle.italic),
      ));
    }
    return TextSpan(children: spans);
  }
}

// ── Sessions panel (right side on desktop) ────────────────────────────────

/// Right-rail panel. Two modes:
///   * **Selected day** → that day's sessions; header says "Próxima sesión"
///     or "Sesión pasada" depending on whether the day is in the future or
///     in the past relative to today.
///   * **No day selected** → driven by [filter]:
///       - `proximas` → upcoming sessions (asc by scheduledAt)
///       - `pasadas`  → past sessions (desc by scheduledAt)
///       - `todas`    → Próximas section first, Pasadas section below
class _SessionsPanel extends StatelessWidget {
  const _SessionsPanel({
    required this.focusedMonth,
    required this.selectedDay,
    required this.allSesiones,
    required this.sessionsByDay,
    required this.isMobile,
    required this.filter,
    required this.onTapSesion,
  });

  final DateTime focusedMonth;
  final DateTime? selectedDay;
  final List<Sesion> allSesiones;
  final Map<String, List<Sesion>> sessionsByDay;
  final bool isMobile;
  final _CalendarFilter filter;
  final ValueChanged<Sesion> onTapSesion;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Sizes.RADIUS_16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary900.withOpacity(0.06),
            blurRadius: Sizes.PADDING_16,
          ),
        ],
      ),
      padding: EdgeInsets.all(
        isMobile ? Sizes.PADDING_16 : Sizes.PADDING_24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _resolveHeader(),
            style: (isMobile ? textTheme.titleMedium : textTheme.headlineSmall)
                ?.copyWith(color: AppColors.primary900),
          ),
          SizedBox(height: isMobile ? Sizes.PADDING_8 : Sizes.PADDING_12),
          ..._buildBody(context, textTheme),
        ],
      ),
    );
  }

  // ── Body ────────────────────────────────────────────────────────────────

  List<Widget> _buildBody(BuildContext context, TextTheme textTheme) {
    if (selectedDay != null) {
      return _renderDayBody(textTheme);
    }
    switch (filter) {
      case _CalendarFilter.proximas:
        return _renderFlatBody(
          textTheme,
          _futureSessions(),
          emptyLabel: StringConst.SESION_EMPTY_PROXIMAS,
        );
      case _CalendarFilter.pasadas:
        return _renderFlatBody(
          textTheme,
          _pastSessions(),
          emptyLabel: StringConst.SESION_EMPTY_PASADAS,
        );
      case _CalendarFilter.todas:
        return _renderTodasBody(textTheme);
    }
  }

  List<Widget> _renderDayBody(TextTheme textTheme) {
    final key = _dayKey(selectedDay!);
    final daySessions = List<Sesion>.from(sessionsByDay[key] ?? const <Sesion>[]);
    if (daySessions.isEmpty) {
      return [_emptyText(textTheme, StringConst.CALENDARIO_EMPTY_DAY)];
    }
    return daySessions.map(_row).toList();
  }

  List<Widget> _renderFlatBody(
    TextTheme textTheme,
    List<Sesion> sessions, {
    required String emptyLabel,
  }) {
    if (sessions.isEmpty) {
      return [
        _emptyText(
          textTheme,
          allSesiones.isEmpty ? StringConst.CALENDARIO_EMPTY : emptyLabel,
        ),
      ];
    }
    return sessions.map(_row).toList();
  }

  /// "Todas las sesiones" view — Próximas section first, then Pasadas. Each
  /// section has its own subheader; sections are skipped when empty.
  List<Widget> _renderTodasBody(TextTheme textTheme) {
    final proximas = _futureSessions();
    final pasadas = _pastSessions();
    if (proximas.isEmpty && pasadas.isEmpty) {
      return [_emptyText(textTheme, StringConst.CALENDARIO_EMPTY)];
    }
    return [
      if (proximas.isNotEmpty) ...[
        _SectionHeader(
            label: StringConst.SESIONES_PROXIMAS, isMobile: isMobile),
        ...proximas.map(_row),
      ],
      if (pasadas.isNotEmpty) ...[
        if (proximas.isNotEmpty) const SizedBox(height: Sizes.PADDING_20),
        _SectionHeader(
            label: StringConst.SESIONES_PASADAS, isMobile: isMobile),
        ...pasadas.map(_row),
      ],
    ];
  }

  Widget _row(Sesion s) => _ScheduledSessionRow(
        sesion: s,
        onTap: () => onTapSesion(s),
      );

  Widget _emptyText(TextTheme textTheme, String label) => Padding(
        padding: const EdgeInsets.symmetric(vertical: Sizes.PADDING_16),
        child: Text(
          label,
          style:
              textTheme.bodyMedium?.copyWith(color: AppColors.greyTxtAlt),
        ),
      );

  // ── Header ──────────────────────────────────────────────────────────────

  String _resolveHeader() {
    if (selectedDay != null) {
      return _isPastDay(selectedDay!)
          ? StringConst.CALENDARIO_PANEL_SESION_PASADA
          : StringConst.CALENDARIO_PANEL_PROXIMA_SESION;
    }
    switch (filter) {
      case _CalendarFilter.proximas:
        return StringConst.SESIONES_PROXIMAS;
      case _CalendarFilter.pasadas:
        return StringConst.SESIONES_PASADAS;
      case _CalendarFilter.todas:
        return StringConst.CALENDARIO_FILTER_TODAS;
    }
  }

  // ── Session bucketing ───────────────────────────────────────────────────

  /// Upcoming relative to "today" (today counts as upcoming). Sorted asc by
  /// scheduledAt — same order as `sesionesProximasStream`.
  List<Sesion> _futureSessions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return allSesiones
        .where((s) => !s.scheduledAt.isBefore(today))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  /// Past (strictly before today). Sorted desc — most-recent-past first,
  /// matching `sesionesPasadasStream`.
  List<Sesion> _pastSessions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return allSesiones
        .where((s) => s.scheduledAt.isBefore(today))
        .toList()
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  }

  bool _isPastDay(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dm = DateTime(day.year, day.month, day.day);
    return dm.isBefore(today);
  }

  String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
}

// ── Filter pill bar ─────────────────────────────────────────────────────────

/// Three-pill filter bar shown above the calendar. Visual mirror of the
/// `_SesionTabPill` from `sesiones_page.dart` (yellow fill + bold primary900
/// text when active; white fill + violet border + greyTxtAlt text when not),
/// kept private to the calendar so other usages of CustomChip aren't affected.
class _CalendarFilterBar extends StatelessWidget {
  const _CalendarFilterBar({
    required this.activeFilter,
    required this.onSelect,
  });

  final _CalendarFilter activeFilter;
  final ValueChanged<_CalendarFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Sizes.PADDING_12,
      runSpacing: Sizes.PADDING_8,
      children: [
        _FilterPill(
          label: StringConst.CALENDARIO_FILTER_PROXIMAS,
          isActive: activeFilter == _CalendarFilter.proximas,
          onTap: () => onSelect(_CalendarFilter.proximas),
        ),
        _FilterPill(
          label: StringConst.CALENDARIO_FILTER_PASADAS,
          isActive: activeFilter == _CalendarFilter.pasadas,
          onTap: () => onSelect(_CalendarFilter.pasadas),
        ),
        _FilterPill(
          label: StringConst.CALENDARIO_FILTER_TODAS,
          isActive: activeFilter == _CalendarFilter.todas,
          onTap: () => onSelect(_CalendarFilter.todas),
        ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(Sizes.RADIUS_25),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.PADDING_30,
          vertical: Sizes.PADDING_12,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.yellow : AppColors.white,
          borderRadius: BorderRadius.circular(Sizes.RADIUS_25),
          border: Border.all(
            color: isActive ? AppColors.yellow : AppColors.violet,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: textTheme.bodyLarge?.copyWith(
            color:
                isActive ? AppColors.primary900 : AppColors.greyTxtAlt,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// Section subheader used in the "Todas las sesiones" view to label the
/// Próximas / Pasadas groupings.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.isMobile});

  final String label;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(
        top: Sizes.PADDING_4,
        bottom: Sizes.PADDING_8,
      ),
      child: Text(
        label,
        style: (isMobile ? textTheme.bodyLarge : textTheme.titleMedium)
            ?.copyWith(
          color: AppColors.primary900,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Single row in the right panel — wraps a `SesionListTile` with the
/// per-session "Añadir a Google Calendar" icon. The time-range label (start
/// — end) is rendered INSIDE the card via `SesionListTile.timeRangeLabel`,
/// so the calendar row stays one visually unified container.
class _ScheduledSessionRow extends StatelessWidget {
  const _ScheduledSessionRow({required this.sesion, required this.onTap});

  final Sesion sesion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Sizes.PADDING_4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // gCal action sits above the card. The time range that used to
          // share this row moved INSIDE the card via [timeRangeLabel].
          Padding(
            padding: const EdgeInsets.only(
              left: Sizes.PADDING_8,
              right: Sizes.PADDING_4,
              bottom: Sizes.PADDING_4,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: _GcalAddIconButton(sesion: sesion),
            ),
          ),
          SesionListTile(
            sesion: sesion,
            onTap: onTap,
            timeRangeLabel: _formatSessionTimeRange(sesion),
          ),
        ],
      ),
    );
  }
}

/// Compact icon button rendered next to the time prefix on each session row.
/// Tap opens a Google Calendar TEMPLATE URL in a new browser tab pre-filled
/// with the session's title, dates, description and location. The user
/// clicks Save in their own calendar — no backend involvement.
///
/// On non-web platforms the underlying `openExternalUrl` throws
/// [UnsupportedError]; we catch it and surface a Spanish snackbar.
class _GcalAddIconButton extends StatelessWidget {
  const _GcalAddIconButton({required this.sesion});

  final Sesion sesion;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: StringConst.SESION_BUTTON_GCAL,
      onPressed: () => _handleAdd(context),
      padding: const EdgeInsets.all(Sizes.PADDING_4),
      constraints: const BoxConstraints(),
      visualDensity: VisualDensity.compact,
      icon: const Icon(
        Icons.event_available_outlined,
        color: AppColors.primary400,
        size: Sizes.ICON_SIZE_20,
      ),
    );
  }

  void _handleAdd(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    try {
      // Resolve the invited participants' names on-demand so the gCal
      // compose form's description shows the actual attendee list rather
      // than just a "{N} participantes" count.
      final names = resolveParticipantNames(sesion.invitedParticipants);
      openExternalUrl(
        buildGoogleCalendarUrl(sesion, participantNames: names),
      );
    } on UnsupportedError {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(StringConst.SESION_GCAL_UNSUPPORTED),
        ),
      );
    }
  }
}

// ── Module-level helpers ──────────────────────────────────────────────────

/// Either "10:30" (specific hour) or the localised "Todo el día" badge.
String _formatSessionTimePrefix(Sesion s) {
  if (s.isAllDay) return StringConst.SESION_TODO_EL_DIA_BADGE;
  return _hhmm(s.scheduledAt);
}

/// "HH:mm — HH:mm" when [Sesion.fechaFin] is set; falls back to the start
/// only when no explicit end is recorded. Returns the "Todo el día" badge
/// for all-day sessions. Rendered inside the session card on the Mi
/// calendario view; the hover tooltip still uses the shorter
/// [_formatSessionTimePrefix] to keep its preview compact.
String _formatSessionTimeRange(Sesion s) {
  if (s.isAllDay) return StringConst.SESION_TODO_EL_DIA_BADGE;
  final start = _hhmm(s.scheduledAt);
  final end = s.fechaFin;
  return end == null ? start : '$start — ${_hhmm(end)}';
}

String _hhmm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Falls back to the default per-`sessionType` label when no title is set
/// — mirrors the same rule used inside `SesionListTile`.
String _titleFor(Sesion s) {
  if (s.title != null && s.title!.trim().isNotEmpty) return s.title!;
  return s.sessionType == SesionType.grupal
      ? StringConst.SESION_GRUPAL
      : StringConst.SESION_INDIVIDUAL;
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.PADDING_30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.deleteRed, size: Sizes.ICON_SIZE_60),
            const SizedBox(height: Sizes.PADDING_16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.greyTxtAlt),
            ),
          ],
        ),
      ),
    );
  }
}
