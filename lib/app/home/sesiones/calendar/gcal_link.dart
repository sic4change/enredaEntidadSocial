import 'package:enreda_empresas/app/models/sesion.dart';
import 'package:enreda_empresas/app/values/strings.dart';

/// Builds a Google Calendar "TEMPLATE" URL pre-filled with [s]'s data.
///
/// When opened in a browser tab, Google Calendar shows its event-creation form
/// with title, dates, description and location populated. The user clicks
/// "Save" and the event lands on **their own** Google Calendar — no OAuth, no
/// service account, no backend involvement.
///
/// Reference: undocumented but stable since ~2010, used by every
/// "add to calendar" link generator on the web (eventbrite, tito, etc.).
///
/// Date encoding rules:
///   * **All-day events** (`isAllDay == true`): `dates=YYYYMMDD/YYYYMMDD`
///     where the end date is exclusive (matches gCal's own behaviour and
///     RFC 5545).
///   * **Timed events**: `dates=YYYYMMDDTHHmmssZ/YYYYMMDDTHHmmssZ` in UTC.
///     gCal converts to the viewer's local timezone automatically; no `ctz`
///     param needed.
///
/// All text params are URL-encoded with `Uri.encodeQueryComponent` which
/// handles `&`, `=`, `?`, `+`, `#`, accented Spanish chars, line breaks, etc.
String buildGoogleCalendarUrl(Sesion s, {Duration? fallbackDuration}) {
  final params = <String, String>{
    'action': 'TEMPLATE',
    'text': _summaryFor(s),
    'dates': _datesParam(s, fallbackDuration ?? const Duration(hours: 1)),
  };

  final details = _descriptionFor(s);
  if (details.isNotEmpty) params['details'] = details;

  final lugar = s.lugar?.trim();
  if (lugar != null && lugar.isNotEmpty) params['location'] = lugar;

  final query = params.entries
      .map((e) =>
          '${e.key}=${Uri.encodeQueryComponent(e.value)}')
      .join('&');

  return 'https://calendar.google.com/calendar/render?$query';
}

// ── Field mappers ─────────────────────────────────────────────────────────

String _summaryFor(Sesion s) {
  final title = s.title?.trim();
  if (title != null && title.isNotEmpty) return title;
  return s.sessionType == SesionType.grupal
      ? StringConst.SESION_GRUPAL
      : StringConst.SESION_INDIVIDUAL;
}

/// Mirrors the description format used by the iCalendar export so a user who
/// adopts both flows sees identical bodies in gCal and in their imported ICS.
String _descriptionFor(Sesion s) {
  final parts = <String>[];
  final desc = s.description?.trim() ?? '';
  if (desc.isNotEmpty) {
    parts.add('${StringConst.SESION_DETAIL_DESARROLLO}\n$desc');
  }
  final obs = s.observations?.trim() ?? '';
  if (obs.isNotEmpty) {
    parts.add('${StringConst.SESION_DETAIL_OBSERVACIONES}\n$obs');
  }
  return parts.join('\n\n');
}

String _datesParam(Sesion s, Duration fallbackDuration) {
  if (s.isAllDay) {
    // gCal expects exclusive end: a one-day all-day event is `D/D+1`.
    final start = s.scheduledAt;
    final end = start.add(const Duration(days: 1));
    return '${_date(start)}/${_date(end)}';
  }
  final start = s.scheduledAt.toUtc();
  final end = start.add(_parseDuration(s.duracion) ?? fallbackDuration);
  return '${_utc(start)}/${_utc(end)}';
}

// ── Duration parsing (kept private; mirrors ics_export.dart) ──────────────

/// Heuristic parser for the free-form `duracion` field. Returns null when
/// nothing can be inferred so the caller can apply its own fallback.
/// Recognises `"2 horas"`, `"90 min"`, `"1h 30m"`, `"1 hora 30 min"`, etc.
/// Clamped to [1 min, 24 h].
Duration? _parseDuration(String? raw) {
  if (raw == null) return null;
  final text = raw.toLowerCase();

  final combo = RegExp(r'(\d+)\s*h\D*?(\d+)\s*m').firstMatch(text);
  if (combo != null) {
    final h = int.tryParse(combo.group(1) ?? '') ?? 0;
    final m = int.tryParse(combo.group(2) ?? '') ?? 0;
    return _clamp(Duration(hours: h, minutes: m));
  }
  final hours = RegExp(r'(\d+)\s*h(ora)?s?').firstMatch(text);
  if (hours != null) {
    final h = int.tryParse(hours.group(1) ?? '') ?? 0;
    return _clamp(Duration(hours: h));
  }
  final minutes = RegExp(r'(\d+)\s*m(in(uto)?s?)?').firstMatch(text);
  if (minutes != null) {
    final m = int.tryParse(minutes.group(1) ?? '') ?? 0;
    return _clamp(Duration(minutes: m));
  }
  return null;
}

Duration _clamp(Duration d) {
  if (d.inMinutes <= 0) return const Duration(minutes: 60);
  if (d.inMinutes > 24 * 60) return const Duration(hours: 24);
  return d;
}

// ── Formatters ────────────────────────────────────────────────────────────

String _utc(DateTime dt) {
  final d = dt.toUtc();
  return '${_pad(d.year, 4)}${_pad(d.month, 2)}${_pad(d.day, 2)}'
      'T${_pad(d.hour, 2)}${_pad(d.minute, 2)}${_pad(d.second, 2)}Z';
}

String _date(DateTime dt) =>
    '${_pad(dt.year, 4)}${_pad(dt.month, 2)}${_pad(dt.day, 2)}';

String _pad(int value, int width) => value.toString().padLeft(width, '0');
