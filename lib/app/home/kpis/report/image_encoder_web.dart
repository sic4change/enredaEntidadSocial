// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui' as ui;

/// Codifica [image] en JPEG con el canvas del navegador, sobre fondo blanco
/// (las esquinas redondeadas de las tarjetas son transparentes). Si el
/// navegador falla, se usa PNG.
Future<Uint8List?> encodeReportImage(ui.Image image) async {
  try {
    final data =
        await image.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
    if (data == null) return null;
    final w = image.width;
    final h = image.height;

    final source = html.CanvasElement(width: w, height: h);
    source.context2D.putImageData(
      html.ImageData(
        Uint8ClampedList.view(data.buffer, data.offsetInBytes, data.lengthInBytes),
        w,
        h,
      ),
      0,
      0,
    );

    final canvas = html.CanvasElement(width: w, height: h);
    canvas.context2D
      ..fillStyle = '#ffffff'
      ..fillRect(0, 0, w, h)
      ..drawImage(source, 0, 0);

    final blob = await canvas.toBlob('image/jpeg', 0.92);
    final reader = html.FileReader()..readAsArrayBuffer(blob);
    await reader.onLoadEnd.first;
    final result = reader.result;
    if (result is Uint8List) return result;
    if (result is ByteBuffer) return result.asUint8List();
  } catch (e) {
    print('KPIs: no se pudo generar el JPEG de la gráfica: $e');
  }
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  return png?.buffer.asUint8List(png.offsetInBytes, png.lengthInBytes);
}
