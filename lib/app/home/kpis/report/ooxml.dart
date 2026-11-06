import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// Utilidades comunes para generar documentos Office Open XML (.docx/.xlsx).

final RegExp _invalidXmlChars =
    RegExp(r'[\u0000-\u0008\u000B\u000C\u000E-\u001F]');

/// Escapa [text] para usarlo como contenido o atributo XML.
String xmlEscape(String text) => text
    .replaceAll(_invalidXmlChars, '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

/// Empaqueta los ficheros ([ruta] → contenido XML) en un zip.
Uint8List zipOoxml(Map<String, String> files) {
  final archive = Archive();
  files.forEach((path, content) {
    final bytes = utf8.encode(content);
    archive.addFile(ArchiveFile(path, bytes.length, bytes));
  });
  return Uint8List.fromList(ZipEncoder().encode(archive)!);
}

const String xmlHeader =
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n';
