import 'dart:io';
import 'dart:typed_data';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

/// Guarda [bytes] en la carpeta de documentos de la app como [filename] y lo
/// abre con la aplicación predeterminada.
Future<void> downloadFile(
    Uint8List bytes, String filename, String mimeType) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes);
  await OpenFile.open(file.path, type: mimeType);
}
