// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui' as ui;

/// Lienzo reutilizado para todas las capturas. Crear dos lienzos grandes por
/// gráfica (y esperar a que el navegador los libere) agotaba la memoria de la
/// GPU y hacía que se perdiera el contexto WebGL de Flutter ("Shader
/// compilation error").
html.CanvasElement? _canvas;

/// Codifica [image] en JPEG con el canvas del navegador, sobre fondo blanco
/// (las esquinas redondeadas de las tarjetas son transparentes). Si el
/// navegador falla, se usa PNG.
Future<Uint8List?> encodeReportImage(ui.Image image) async {
  final w = image.width;
  final h = image.height;
  final canvas = _canvas ??= html.CanvasElement();
  try {
    final data =
        await image.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
    if (data == null) return null;

    // Fondo blanco premultiplicando cada píxel por su alfa a mano: así basta
    // un solo lienzo (putImageData no mezcla con lo que ya hay pintado)
    final px = Uint8ClampedList.view(
        data.buffer, data.offsetInBytes, data.lengthInBytes);
    for (int i = 0; i < px.length; i += 4) {
      final a = px[i + 3];
      if (a == 255) continue;
      final inv = 255 - a;
      px[i] = (px[i] * a + 255 * inv) ~/ 255;
      px[i + 1] = (px[i + 1] * a + 255 * inv) ~/ 255;
      px[i + 2] = (px[i + 2] * a + 255 * inv) ~/ 255;
      px[i + 3] = 255;
    }

    canvas
      ..width = w
      ..height = h;
    canvas.context2D.putImageData(html.ImageData(px, w, h), 0, 0);

    final blob = await canvas.toBlob('image/jpeg', 0.92);
    final reader = html.FileReader()..readAsArrayBuffer(blob);
    await reader.onLoadEnd.first;
    final result = reader.result;
    if (result is Uint8List) return result;
    if (result is ByteBuffer) return result.asUint8List();
  } catch (e) {
    print('KPIs: no se pudo generar el JPEG de la gráfica: $e');
  } finally {
    // Libera la memoria del lienzo hasta la siguiente captura
    canvas
      ..width = 0
      ..height = 0;
  }
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  return png?.buffer.asUint8List(png.offsetInBytes, png.lengthInBytes);
}
