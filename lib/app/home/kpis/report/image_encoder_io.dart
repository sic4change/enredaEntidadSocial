import 'dart:typed_data';
import 'dart:ui' as ui;

/// Codifica [image] en PNG.
Future<Uint8List?> encodeReportImage(ui.Image image) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data?.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}
