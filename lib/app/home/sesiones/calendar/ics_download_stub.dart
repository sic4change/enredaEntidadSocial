/// Non-web platforms reach this stub because `dart:html` isn't available.
/// The Sesiones calendar is desktop / web-first, so we surface a clear error
/// instead of silently no-oping — the caller (calendar page) catches this
/// and shows a Spanish-localised snackbar.
void downloadIcs(String content, String filename) {
  throw UnsupportedError(
    'La descarga .ics solo está disponible en la versión web.',
  );
}
