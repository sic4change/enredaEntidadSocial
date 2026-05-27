/// Public surface for opening a URL in a new browser tab.
///
/// Conditional import:
///   * Flutter Web → [gcal_open_web.dart] (uses `dart:html`'s `window.open`).
///   * Everything else → [gcal_open_stub.dart] (throws `UnsupportedError`).
export 'gcal_open_stub.dart'
    if (dart.library.html) 'gcal_open_web.dart';
