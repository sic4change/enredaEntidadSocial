// ignore_for_file: avoid_web_libraries_in_flutter
//
// Intentionally targets dart:html. Only imported on Flutter Web via the
// conditional `if (dart.library.html)` clause in `gcal_open.dart`.

import 'dart:html' as html;

/// Opens [url] in a new browser tab. Sets `noopener,noreferrer` so the new
/// tab cannot access the opener (security hardening — same standard the
/// `<a target="_blank" rel="noopener">` pattern uses).
void openExternalUrl(String url) {
  html.window.open(url, '_blank', 'noopener,noreferrer');
}
