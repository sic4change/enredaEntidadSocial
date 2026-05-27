/// Public surface for triggering an `.ics` file download.
///
/// Conditional import: on Flutter Web (where `dart:html` is available) this
/// resolves to [ics_download_web.dart] which builds a Blob + anchor + click;
/// on every other platform it resolves to [ics_download_stub.dart] which
/// throws [UnsupportedError] so the caller can surface a localised message.
export 'ics_download_stub.dart'
    if (dart.library.html) 'ics_download_web.dart';
