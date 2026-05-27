// ignore_for_file: avoid_web_libraries_in_flutter
//
// Intentionally targets dart:html. This file is only imported on Flutter Web
// via the conditional `if (dart.library.html)` clause in `ics_download.dart`;
// on every other platform the stub in `ics_download_stub.dart` is used.

import 'dart:convert';
import 'dart:html' as html;

/// Triggers a browser download of [content] as `[filename]`, served as
/// `text/calendar;charset=utf-8` so Chrome / Safari / Firefox all hand it
/// off to the user's default calendar app (or save to Downloads).
///
/// Creates an in-memory Blob, an anchor with the `download` attribute, and
/// dispatches a synthetic click. The temporary object URL is revoked
/// immediately afterwards to free memory.
void downloadIcs(String content, String filename) {
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes], 'text/calendar;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}
