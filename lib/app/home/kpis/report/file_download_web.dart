// ignore_for_file: avoid_web_libraries_in_flutter
//
// Solo se importa en Flutter Web mediante el import condicional de
// `file_download.dart`.

import 'dart:html' as html;
import 'dart:typed_data';

/// Lanza la descarga de [bytes] en el navegador como [filename].
Future<void> downloadFile(
    Uint8List bytes, String filename, String mimeType) async {
  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}
