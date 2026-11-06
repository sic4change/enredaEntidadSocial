import 'dart:typed_data';

import 'ooxml.dart';
import 'report_document.dart';

const String _primary900 = '054D5E';
const String _secondaryText = '3F6672';
const String _tileBackground = 'E3ECEF';
const String _divider = 'CDDBDF';

final RegExp _numeric = RegExp(r'^-?\d+(?:[.,]\d+)?%?$');

/// Genera un documento Word (.docx) con los bloques del informe. Los informes
/// apaisados (tablas muy anchas) se maquetan en A3 horizontal.
Uint8List buildDocx(ReportDocument doc) {
  // Medidas en twips (1 cm = 567): A4 vertical o A3 horizontal, que comparten
  // la misma altura
  final pageW = doc.landscape ? 23811 : 11906;
  const pageH = 16838;
  final margin = doc.landscape ? 567 : 1134;
  final contentW = pageW - 2 * margin;

  final body = StringBuffer()
    ..write(_paragraph(doc.title, size: 36, bold: true, color: _primary900));
  for (final line in doc.subtitleLines) {
    body.write(_paragraph(line, size: 18, color: _secondaryText));
  }
  body.write(_paragraph(''));

  ReportBlock? previous;
  for (final block in doc.blocks) {
    switch (block) {
      case ReportSectionTitle(:final text):
        body.write(_paragraph(text,
            size: 28,
            bold: true,
            color: _primary900,
            spaceBefore: 320,
            bottomBorder: true));
      case ReportSubTitle(:final text):
        body.write(_paragraph(text,
            size: 22, bold: true, color: _primary900, spaceBefore: 200));
      case ReportNote(:final text):
        body.write(_paragraph(text, size: 18, color: _secondaryText));
      case ReportKeyValue(:final label, :final value):
        body.write('<w:p><w:pPr><w:spacing w:after="40"/>'
            '<w:tabs><w:tab w:val="right" w:pos="$contentW"/></w:tabs></w:pPr>'
            '${_run(label, size: 20)}<w:r><w:tab/></w:r>'
            '${_run(value, size: 20, bold: true, color: _primary900)}</w:p>');
      case ReportTable(:final headers, :final rows):
        if (previous is ReportTable) body.write(_paragraph(''));
        body.write(_table(headers, rows, contentW));
    }
    previous = block;
  }

  final orient = doc.landscape ? ' w:orient="landscape"' : '';
  body.write('<w:sectPr><w:pgSz w:w="$pageW" w:h="$pageH"$orient/>'
      '<w:pgMar w:top="$margin" w:right="$margin" w:bottom="$margin" '
      'w:left="$margin" w:header="0" w:footer="0" w:gutter="0"/></w:sectPr>');

  return zipOoxml({
    '[Content_Types].xml': '$xmlHeader'
        '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
        '<Default Extension="xml" ContentType="application/xml"/>'
        '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
        '<Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>'
        '</Types>',
    '_rels/.rels': '$xmlHeader'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>'
        '</Relationships>',
    'word/_rels/document.xml.rels': '$xmlHeader'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
        '</Relationships>',
    'word/document.xml': '$xmlHeader'
        '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
        '<w:body>$body</w:body></w:document>',
    'word/styles.xml': _styles,
  });
}

String _run(String text,
    {int? size, bool bold = false, String? color}) {
  final props = StringBuffer();
  if (bold) props.write('<w:b/>');
  if (color != null) props.write('<w:color w:val="$color"/>');
  if (size != null) props.write('<w:sz w:val="$size"/><w:szCs w:val="$size"/>');
  final rPr = props.isEmpty ? '' : '<w:rPr>$props</w:rPr>';
  // Los saltos de línea dentro de una celda se mantienen como <w:br/>
  final parts = text.split('\n').map(
      (p) => '<w:t xml:space="preserve">${xmlEscape(p)}</w:t>');
  return '<w:r>$rPr${parts.join('<w:br/>')}</w:r>';
}

String _paragraph(
  String text, {
  int? size,
  bool bold = false,
  String? color,
  int spaceBefore = 0,
  bool bottomBorder = false,
}) {
  final border = bottomBorder
      ? '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="2" w:color="$_primary900"/></w:pBdr>'
      : '';
  return '<w:p><w:pPr>$border<w:spacing w:before="$spaceBefore" w:after="80"/></w:pPr>'
      '${text.isEmpty ? '' : _run(text, size: size, bold: bold, color: color)}</w:p>';
}

String _table(List<String> headers, List<List<String>> rows, int contentW) {
  // Letra más pequeña cuanto más columnas tenga la tabla
  final size = headers.length > 20
      ? 10
      : headers.length > 8
          ? 14
          : 18;
  final colW = contentW ~/ headers.length;

  String cell(String text, int col, {bool header = false}) {
    final shading = header
        ? '<w:shd w:val="clear" w:color="auto" w:fill="$_tileBackground"/>'
        : '';
    final align =
        !header && col > 0 && _numeric.hasMatch(text.trim()) ? 'right' : 'left';
    return '<w:tc><w:tcPr><w:tcW w:w="$colW" w:type="dxa"/>$shading</w:tcPr>'
        '<w:p><w:pPr><w:spacing w:before="20" w:after="20"/><w:jc w:val="$align"/></w:pPr>'
        '${text.isEmpty ? '' : _run(text, size: size, bold: header, color: header ? _primary900 : null)}'
        '</w:p></w:tc>';
  }

  final buffer = StringBuffer()
    ..write('<w:tbl><w:tblPr><w:tblW w:w="$contentW" w:type="dxa"/>'
        '<w:tblBorders>'
        '<w:bottom w:val="single" w:sz="4" w:color="$_divider"/>'
        '<w:insideH w:val="single" w:sz="4" w:color="$_divider"/>'
        '</w:tblBorders>'
        '<w:tblCellMar><w:left w:w="57" w:type="dxa"/><w:right w:w="57" w:type="dxa"/></w:tblCellMar>'
        '</w:tblPr><w:tblGrid>');
  for (int i = 0; i < headers.length; i++) {
    buffer.write('<w:gridCol w:w="$colW"/>');
  }
  buffer.write('</w:tblGrid>');

  // La cabecera se repite en cada página
  buffer.write('<w:tr><w:trPr><w:tblHeader/></w:trPr>');
  for (int c = 0; c < headers.length; c++) {
    buffer.write(cell(headers[c], c, header: true));
  }
  buffer.write('</w:tr>');

  for (final row in rows) {
    buffer.write('<w:tr><w:trPr><w:cantSplit/></w:trPr>');
    for (int c = 0; c < headers.length; c++) {
      buffer.write(cell(c < row.length ? row[c] : '', c));
    }
    buffer.write('</w:tr>');
  }
  buffer.write('</w:tbl>');
  return buffer.toString();
}

const String _styles = '$xmlHeader'
    '<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
    '<w:docDefaults>'
    '<w:rPrDefault><w:rPr><w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:eastAsia="Calibri" w:cs="Calibri"/>'
    '<w:sz w:val="20"/><w:szCs w:val="20"/><w:lang w:val="es-ES"/></w:rPr></w:rPrDefault>'
    '<w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault>'
    '</w:docDefaults>'
    '<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/></w:style>'
    '</w:styles>';
