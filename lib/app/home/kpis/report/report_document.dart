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
