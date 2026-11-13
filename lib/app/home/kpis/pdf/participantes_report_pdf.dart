import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../kpi_service.dart';
import '../report/report_document.dart';

const PdfColor _primary900 = PdfColor.fromInt(0xFF054D5E);
const PdfColor _secondaryText = PdfColor.fromInt(0xFF3F6672);
const PdfColor _tileBackground = PdfColor.fromInt(0xFFE3ECEF);
const PdfColor _divider = PdfColor.fromInt(0xFFCDDBDF);

/// Columnas del informe, en el mismo orden que la exportación de participantes.
const List<String> participantesColumns = [
  'ID',
  'Programa',
  'Nº Part.',
  'IPFSE.1',
  'Técnica de referencia',
  'Fecha Inicio Prog.',
  'Nº Identificación',
  'Nombre y apellidos',
  'Fecha Nac.',
  'Edad Inicial',
  'Rango de edad',
  'Género',
  'Nacional TPUE',
  'Nacionalidad',
  'País de origen',
  'Nivel Educativo Inicial',
  'CINE FSE',
  'Situación Laboral',
  'Condición Laboral',
  'Estado Laboral',
  'Hogar FSE',
  'Alojamiento',
  'Discapacidad',
  'Grado',
  'Minorías',
  '¿Qué minoría?',
  'Ruralidad',
  'Municipio',
  'ID Informe Inicial',
  'Estado programa',
  'Fecha Salida Op.',
  'Motivo de cierre',
  'Resultado Corto Plazo (RCP) Enero-Junio',
  'Fecha de resultado (RCP) (Enero-Junio)',
  'Resultado Corto Plazo (RCP) Julio-Diciembre',
  'Fecha de resultado (RCP) (Julio-Diciembre)',
];

final DateFormat _date = DateFormat('dd/MM/yyyy');

String _d(DateTime? value) => value != null ? _date.format(value) : '';

/// Nombre corto del programa para que la columna no ocupe varias líneas.
String _programa(String? subsidy) {
  final s = (subsidy ?? '').trim();
  final upper = s.toUpperCase();
  if (s.contains('529760') || upper.contains('MEDICOS DEL MUNDO')) {
    return '529760 · Empleando sueños';
  }
  if (s.contains('529775') || upper.contains('SICFCH')) {
    return '529775 · Acompañamiento y tecnología';
  }
  if (upper.contains('SEIMLAB') || s.contains('0080')) {
    return '1/MAC/4/7.2/0080 · SEIMLAB';
  }
  return s;
}

List<String> _cells(ParticipanteListadoRow r) => [
      r.userId,
      _programa(r.programa),
      '',
      r.ipfse1 ?? '',
      r.tecnicaReferencia ?? '',
      _d(r.fechaInicioPrograma),
      r.numIdentificacion ?? '',
      r.nombreApellidos,
      _d(r.fechaNacimiento),
      r.edadInicial?.toString() ?? '',
      r.rangoEdad ?? '',
      r.genero ?? '',
      r.nacionalTpue ?? '',
      r.nacionalidad ?? '',
      '',
      r.nivelEducativoInicial ?? '',
      r.cineFse ?? '',
      r.situacionLaboral ?? '',
      r.condicionLaboral ?? '',
      r.estadoLaboral ?? '',
      r.hogarFse ?? '',
      r.alojamiento ?? '',
      r.discapacidad ?? '',
      r.grado ?? '',
      r.minorias ?? '',
      '',
      r.ruralidad ?? '',
      r.municipio ?? '',
      r.idInformeInicial ?? '',
      r.estadoPrograma,
      _d(r.fechaSalidaOperacion),
      r.motivoCierre ?? '',
      '',
      '',
      '',
      '',
    ];

/// Contenido del informe "Participantes", común a PDF, Word y Excel.
ReportDocument buildParticipantesReportDocument({
  required String filterLabel,
  required DateTime generatedAt,
  required List<ParticipanteListadoRow> rows,
}) =>
    ReportDocument(
      title: 'Participantes',
      subtitleLines: [
        'Vista: $filterLabel · ${rows.length} participantes',
        'Generado el ${DateFormat('dd/MM/yyyy HH:mm').format(generatedAt)}',
      ],
      blocks: [
        if (rows.isEmpty)
          const ReportNote('No hay participantes para esta vista.')
        else
          ReportTable(participantesColumns, rows.map(_cells).toList()),
      ],
      landscape: true,
    );

/// Informe con el desglose de participantes de la vista seleccionada. Se
/// maqueta en A3 apaisado para que quepan las 36 columnas.
Future<Uint8List> generateParticipantesReportPdf(
  PdfPageFormat format, {
  required String filterLabel,
  required DateTime generatedAt,
  required List<ParticipanteListadoRow> rows,
}) async {
  final doc = pw.Document(title: 'Participantes - $filterLabel');

  format = format.applyMargin(
    left: 1.0 * PdfPageFormat.cm,
    top: 1.0 * PdfPageFormat.cm,
    right: 1.0 * PdfPageFormat.cm,
    bottom: 1.0 * PdfPageFormat.cm,
  );

  final pageTheme = pw.PageTheme(
    pageFormat: format,
    margin: pw.EdgeInsets.fromLTRB(format.marginLeft, format.marginTop,
        format.marginRight, format.marginBottom),
    theme: pw.ThemeData.withFont(
      base: await PdfGoogleFonts.poppinsLight(),
      bold: await PdfGoogleFonts.poppinsMedium(),
    ),
  );

  final report = buildParticipantesReportDocument(
    filterLabel: filterLabel,
    generatedAt: generatedAt,
    rows: rows,
  );
  final table = report.blocks.whereType<ReportTable>().firstOrNull;

  doc.addPage(
    pw.MultiPage(
      pageTheme: pageTheme,
      footer: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 0.3 * PdfPageFormat.cm),
        child: _small('Pág. ${context.pageNumber} de ${context.pagesCount}'),
      ),
      build: (context) => [
        pw.Text(
          report.title,
          style: pw.TextStyle(
              fontSize: 16, fontWeight: pw.FontWeight.bold, color: _primary900),
        ),
        pw.SizedBox(height: 4),
        ...report.subtitleLines.map(_small),
        pw.SizedBox(height: 10),
        if (table == null)
          _small('No hay participantes para esta vista.')
        else
          pw.TableHelper.fromTextArray(
            headers: table.headers,
            data: table.rows,
            border: const pw.TableBorder(
              horizontalInside: pw.BorderSide(color: _divider, width: 0.5),
              bottom: pw.BorderSide(color: _divider, width: 0.5),
            ),
            headerStyle: pw.TextStyle(
                fontSize: 5, fontWeight: pw.FontWeight.bold, color: _primary900),
            headerDecoration: const pw.BoxDecoration(color: _tileBackground),
            headerAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 5),
            cellPadding:
                const pw.EdgeInsets.symmetric(horizontal: 1.5, vertical: 2),
            cellAlignment: pw.Alignment.centerLeft,
          ),
      ],
    ),
  );

  return doc.save();
}

pw.Widget _small(String text) => pw.Text(text,
    style: const pw.TextStyle(fontSize: 9, color: _secondaryText));
