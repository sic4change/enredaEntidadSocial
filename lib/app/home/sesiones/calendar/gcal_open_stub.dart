/// Mobile / desktop fallback — `dart:html` isn't available, so we surface
/// a clear error instead of silently no-oping. The caller catches this and
/// shows a Spanish-localised snackbar.
void openExternalUrl(String url) {
  throw UnsupportedError(
    'La integración con Google Calendar solo está disponible en la versión web.',
  );
}
