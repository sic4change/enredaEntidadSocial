import 'dart:math' as math;
import 'dart:typed_data';

import 'ooxml.dart';
import 'report_document.dart';

// Índices de estilo (cellXfs de styles.xml)
const int _sDefault = 0;
const int _sTitle = 1;
const int _sSection = 2;
const int _sBold = 3;
const int _sNote = 4;
const int _sHeader = 5;
const int _sPercent = 6;

final RegExp _integer = RegExp(r'^(0|-?[1-9]\d{0,8})$');
final RegExp _percent = RegExp(r'^(-?\d+(?:[.,]\d+)?)%$');

/// Genera un libro Excel (.xlsx) con una sola hoja que contiene los bloques
/// del informe uno debajo de otro. Si el informe es una única tabla, se
/// inmoviliza la cabecera y se activa el autofiltro.
Uint8List buildXlsx(ReportDocument doc) {
  final rows = <String>[];
  final widths = <int, int>{};
  int rowIndex = 0;

  void track(int col, String text) {
    final len = text.split('\n').fold<int>(0, (m, l) => math.max(m, l.length));
    widths[col] = math.max(widths[col] ?? 0, len);
  }

  void addRow(List<String> values, int style,
      {bool detectNumbers = false, bool trackWidth = true}) {
    rowIndex++;
    final cells = StringBuffer();
    for (int c = 0; c < values.length; c++) {
      final v = values[c];
      if (v.isEmpty) continue;
      if (trackWidth) track(c, v);
      final ref = '${_columnName(c)}$rowIndex';
      if (detectNumbers && _integer.hasMatch(v)) {
        cells.write('<c r="$ref" s="$style"><v>$v</v></c>');
        continue;
      }
      final pct = detectNumbers ? _percent.firstMatch(v) : null;
      if (pct != null) {
        final n = double.parse(pct.group(1)!.replaceAll(',', '.')) / 100;
        cells.write('<c r="$ref" s="$_sPercent"><v>$n</v></c>');
        continue;
      }
      cells.write('<c r="$ref" s="$style" t="inlineStr"><is><t xml:space="preserve">'
          '${xmlEscape(v)}</t></is></c>');
    }
    rows.add('<row r="$rowIndex">$cells</row>');
  }

  void blankRow() => rowIndex++;

  addRow([doc.title], _sTitle, trackWidth: false);
  for (final line in doc.subtitleLines) {
    addRow([line], _sNote, trackWidth: false);
  }
  blankRow();

  final tables = doc.blocks.whereType<ReportTable>().toList();
  final singleTable = doc.blocks.length == 1 && tables.length == 1;
  int? headerRow;
  int maxCols = 1;

  ReportBlock? previous;
  for (final block in doc.blocks) {
    switch (block) {
      case ReportSectionTitle(:final text):
        if (previous != null) blankRow();
        addRow([text], _sSection, trackWidth: false);
      case ReportSubTitle(:final text):
        if (previous != null && previous is! ReportSectionTitle) blankRow();
        addRow([text], _sBold, trackWidth: false);
      case ReportNote(:final text):
        addRow([text], _sNote, trackWidth: false);
      case ReportKeyValue(:final label, :final value):
        addRow([label, value], _sDefault, detectNumbers: true);
      case ReportTable(:final headers, :final rows):
        if (previous is ReportTable) blankRow();
        addRow(headers, _sHeader);
        headerRow ??= rowIndex;
        maxCols = math.max(maxCols, headers.length);
        for (final r in rows) {
          addRow(r, _sDefault, detectNumbers: true);
        }
      case ReportImage():
        // Las gráficas solo van en PDF y Word; en Excel quedan los datos
        break;
      case ReportSource(:final text):
        addRow([text], _sNote, trackWidth: false);
    }
    previous = block;
  }

  final cols = StringBuffer('<cols>');
  final colCount = math.max(maxCols, widths.keys.fold<int>(0, math.max) + 1);
  for (int c = 0; c < colCount; c++) {
    final w = ((widths[c] ?? 8) + 2).clamp(8, 60);
    cols.write('<col min="${c + 1}" max="${c + 1}" width="$w" customWidth="1"/>');
  }
  cols.write('</cols>');

  final sheetViews = singleTable && headerRow != null
      ? '<sheetViews><sheetView workbookViewId="0"><pane ySplit="$headerRow" '
          'topLeftCell="A${headerRow + 1}" activePane="bottomLeft" state="frozen"/>'
          '</sheetView></sheetViews>'
      : '<sheetViews><sheetView workbookViewId="0"/></sheetViews>';
  final autoFilter = singleTable && headerRow != null
      ? '<autoFilter ref="A$headerRow:${_columnName(maxCols - 1)}$rowIndex"/>'
      : '';

  final sheet = '$xmlHeader'
      '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
      '$sheetViews$cols<sheetData>${rows.join()}</sheetData>$autoFilter'
      '</worksheet>';

  return zipOoxml({
    '[Content_Types].xml': '$xmlHeader'
        '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
        '<Default Extension="xml" ContentType="application/xml"/>'
        '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
        '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
        '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>'
        '</Types>',
    '_rels/.rels': '$xmlHeader'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
        '</Relationships>',
    'xl/workbook.xml': '$xmlHeader'
        '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
        'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
        '<sheets><sheet name="${xmlEscape(_sheetName(doc.title))}" sheetId="1" r:id="rId1"/></sheets>'
        '${autoFilter.isNotEmpty ? '<definedNames><definedName name="_xlnm._FilterDatabase" localSheetId="0" hidden="1">\'${xmlEscape(_sheetName(doc.title))}\'!\$A\$$headerRow:\$${_columnName(maxCols - 1)}\$$rowIndex</definedName></definedNames>' : ''}'
        '</workbook>',
    'xl/_rels/workbook.xml.rels': '$xmlHeader'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>'
        '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
        '</Relationships>',
    'xl/worksheets/sheet1.xml': sheet,
    'xl/styles.xml': _styles,
  });
}

String _columnName(int index) {
  var n = index + 1;
  var name = '';
  while (n > 0) {
    final rem = (n - 1) % 26;
    name = String.fromCharCode(65 + rem) + name;
    n = (n - 1) ~/ 26;
  }
  return name;
}

String _sheetName(String title) {
  final clean = title.replaceAll(RegExp(r"[\[\]:*?/\\']"), ' ').trim();
  if (clean.isEmpty) return 'Informe';
  return clean.length > 31 ? clean.substring(0, 31) : clean;
}

const String _styles = '$xmlHeader'
    '<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
    '<fonts count="5">'
    '<font><sz val="11"/><name val="Calibri"/></font>'
    '<font><b/><sz val="16"/><color rgb="FF054D5E"/><name val="Calibri"/></font>'
    '<font><b/><sz val="13"/><color rgb="FF054D5E"/><name val="Calibri"/></font>'
    '<font><b/><sz val="11"/><color rgb="FF054D5E"/><name val="Calibri"/></font>'
    '<font><i/><sz val="10"/><color rgb="FF3F6672"/><name val="Calibri"/></font>'
    '</fonts>'
    '<fills count="3">'
    '<fill><patternFill patternType="none"/></fill>'
    '<fill><patternFill patternType="gray125"/></fill>'
    '<fill><patternFill patternType="solid"><fgColor rgb="FFE3ECEF"/><bgColor indexed="64"/></patternFill></fill>'
    '</fills>'
    '<borders count="2">'
    '<border><left/><right/><top/><bottom/><diagonal/></border>'
    '<border><left/><right/><top/><bottom style="thin"><color rgb="FFCDDBDF"/></bottom><diagonal/></border>'
    '</borders>'
    '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>'
    '<cellXfs count="7">'
    '<xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>'
    '<xf numFmtId="0" fontId="1" fillId="0" borderId="0" xfId="0" applyFont="1"/>'
    '<xf numFmtId="0" fontId="2" fillId="0" borderId="1" xfId="0" applyFont="1" applyBorder="1"/>'
    '<xf numFmtId="0" fontId="3" fillId="0" borderId="0" xfId="0" applyFont="1"/>'
    '<xf numFmtId="0" fontId="4" fillId="0" borderId="0" xfId="0" applyFont="1"/>'
    '<xf numFmtId="0" fontId="3" fillId="2" borderId="1" xfId="0" applyFont="1" applyFill="1" applyBorder="1" applyAlignment="1"><alignment wrapText="1" vertical="center"/></xf>'
    '<xf numFmtId="9" fontId="0" fillId="0" borderId="0" xfId="0" applyNumberFormat="1"/>'
    '</cellXfs>'
    '<cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>'
    '</styleSheet>';
