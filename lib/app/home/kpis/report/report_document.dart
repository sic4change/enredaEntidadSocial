import 'dart:typed_data';

/// Contenido de un informe independiente del formato de salida (PDF, Word o
/// Excel). Cada formato recorre los mismos bloques en orden.
class ReportDocument {
  final String title;

  /// Líneas bajo el título (vista, fecha de generación…).
  final List<String> subtitleLines;
  final List<ReportBlock> blocks;

  /// Maquetar en horizontal (tablas muy anchas).
  final bool landscape;

  const ReportDocument({
    required this.title,
    this.subtitleLines = const [],
    required this.blocks,
    this.landscape = false,
  });
}

sealed class ReportBlock {
  const ReportBlock();
}

class ReportSectionTitle extends ReportBlock {
  final String text;
  const ReportSectionTitle(this.text);
}

class ReportSubTitle extends ReportBlock {
  final String text;
  const ReportSubTitle(this.text);
}

class ReportNote extends ReportBlock {
  final String text;
  const ReportNote(this.text);
}

class ReportKeyValue extends ReportBlock {
  final String label;
  final String value;
  const ReportKeyValue(this.label, this.value);
}

class ReportTable extends ReportBlock {
  final List<String> headers;
  final List<List<String>> rows;
  const ReportTable(this.headers, this.rows);
}

/// Captura de una gráfica de la página (PNG). [width] y [height] son su
/// tamaño lógico en pantalla, para mantener la proporción al maquetarla.
class ReportImage extends ReportBlock {
  /// Imagen codificada en PNG o JPEG.
  final Uint8List bytes;
  final double width;
  final double height;
  const ReportImage(this.bytes, {required this.width, required this.height});

  /// Si [bytes] es un JPEG (cabecera FF D8).
  bool get isJpeg => bytes.length > 2 && bytes[0] == 0xFF && bytes[1] == 0xD8;

  String get extension => isJpeg ? 'jpeg' : 'png';

  /// Tamaño en puntos para el documento: al 70 % de su tamaño en pantalla
  /// (legible y sin ocupar páginas enteras), sin pasar de [maxWidth] ni de
  /// [maxHeight] y manteniendo la proporción.
  ({double width, double height}) fit(double maxWidth, double maxHeight) {
    var w = width * 0.7;
    var h = height * 0.7;
    if (w > maxWidth) {
      h *= maxWidth / w;
      w = maxWidth;
    }
    if (h > maxHeight) {
      w *= maxHeight / h;
      h = maxHeight;
    }
    return (width: w, height: h);
  }
}

/// Origen de los datos de una gráfica, en letra pequeña bajo ella.
class ReportSource extends ReportBlock {
  final String text;
  const ReportSource(this.text);
}
