import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../models/userEnreda.dart';
import '../kpi_models.dart';
import '../kpi_service.dart';

const PdfColor _primary900 = PdfColor.fromInt(0xFF054D5E);
const PdfColor _secondaryText = PdfColor.fromInt(0xFF3F6672);
const PdfColor _tileBackground = PdfColor.fromInt(0xFFE3ECEF);
const PdfColor _divider = PdfColor.fromInt(0xFFCDDBDF);

const List<String> _monthShort = [
  'Ene',
  'Feb',
  'Mar',
  'Abr',
  'May',
  'Jun',
  'Jul',
  'Ago',
  'Sep',
  'Oct',
  'Nov',
  'Dic',
];

/// Datos de la vista de KPIs en el momento de pulsar "Descargar informe".
class KpiReportData {
  final String filterId;
  final String filterLabel;
  final DateTime generatedAt;
  final ParticipantesKpiData? participantes;
  final RecursosKpiData? recursos;

  const KpiReportData({
    required this.filterId,
    required this.filterLabel,
    required this.generatedAt,
    this.participantes,
    this.recursos,
  });
}

/// Logos de cabecera según la subvención filtrada (mismos que en los informes);
/// `null` para la vista global o de entidad.
String? _logoAssetFor(String filterId) {
  if (filterId.contains('529760')) return 'assets/images/logos-mdm.png';
  if (filterId.contains('529775')) return 'assets/images/logos-fse.png';
  if (filterId == 'seimlab' || filterId.contains('0080'))
    return 'assets/images/logos-seimlab.png';
  return null;
}

Future<Uint8List> generateKpiReportPdf(
    PdfPageFormat format, KpiReportData data) async {
  final doc =
      pw.Document(title: 'Informe de indicadores - ${data.filterLabel}');

  final logoAsset = _logoAssetFor(data.filterId);
  final pw.MemoryImage? logo = logoAsset != null
      ? pw.MemoryImage((await rootBundle.load(logoAsset)).buffer.asUint8List())
      : null;

  format = format.applyMargin(
    left: 2.0 * PdfPageFormat.cm,
    top: (logo != null ? 3.0 : 2.0) * PdfPageFormat.cm,
    right: 2.0 * PdfPageFormat.cm,
    bottom: 2.0 * PdfPageFormat.cm,
  );

  final pageTheme = pw.PageTheme(
    pageFormat: format,
    margin: pw.EdgeInsets.fromLTRB(format.marginLeft, format.marginTop,
        format.marginRight, format.marginBottom),
    theme: pw.ThemeData.withFont(
      base: await PdfGoogleFonts.poppinsLight(),
      bold: await PdfGoogleFonts.poppinsMedium(),
    ),
    buildBackground: logo == null
        ? null
        : (pw.Context context) => pw.FullPage(
              ignoreMargins: true,
              child: pw.Stack(children: [
                pw.Positioned(
                  left: 10,
                  top: 30,
                  right: 10,
                  child: pw.Center(
                      child:
                          pw.Image(logo, width: 550, fit: pw.BoxFit.contain)),
                ),
              ]),
            ),
  );

  final p = data.participantes;
  final r = data.recursos;

  doc.addPage(
    pw.MultiPage(
      pageTheme: pageTheme,
      footer: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 0.5 * PdfPageFormat.cm),
        child: _small('Pág. ${context.pageNumber} de ${context.pagesCount}'),
      ),
      build: (context) => [
        pw.Text(
          'Informe de indicadores (KPIs)',
          style: pw.TextStyle(
              fontSize: 18, fontWeight: pw.FontWeight.bold, color: _primary900),
        ),
        pw.SizedBox(height: 4),
        _small('Vista: ${data.filterLabel}'),
        _small(
            'Generado el ${DateFormat('dd/MM/yyyy HH:mm').format(data.generatedAt)}'),
        pw.SizedBox(height: 12),
        if (p != null) ..._participantesSections(p, data.generatedAt),
        if (p == null)
          _note('No hay datos de participantes cargados para esta vista.'),
        _sectionTitle('Recursos'),
        _note(
            'Los recursos se cuentan siempre sobre el total, independientemente del filtro.'),
        if (r != null) ..._recursosSection(r, data.generatedAt),
        if (r == null) _note('No hay datos de recursos cargados.'),
      ],
    ),
  );

  return doc.save();
}

// ---------------------------------------------------------------------------
// Participantes

List<pw.Widget> _participantesSections(ParticipantesKpiData p, DateTime now) {
  String pct(double v) => '${v.round()}%';
  List<String> barRow(StackedBarRow row) =>
      [row.label, '${row.count}', pct(row.percentage)];
  List<String> empleoRow(SituacionEmpleoRow row) => [
        row.label,
        '${row.mujeres}',
        '${row.hombres}',
        '${row.noBinario}',
        '${row.total}'
      ];
  List<String> levelRow(FormatLevelItem i) => [
        i.title,
        '${i.mujeres}',
        '${i.hombres}',
        '${i.noBinario}',
        '${i.total}',
        pct(i.percentage)
      ];

  // Inscripciones por mes del año en curso (misma fecha que la tarjeta de evolución)
  final inscripciones = List<int>.filled(12, 0);
  for (final u in p.users) {
    final d = u.createDate ?? u.startDateItinerary;
    if (d != null && d.year == now.year) inscripciones[d.month - 1]++;
  }

  return [
    // Resumen general
    _sectionTitle('Resumen general'),
    _kv('Participantes inscritos', '${p.total}'),
    _kv('Con informe inicial completo', '${p.totalConInformeInicialCompleto}'),
    _subTitle('Estado'),
    _table(['Estado', 'Personas', '%'], p.porEstado.map(barRow).toList()),
    _subTitle('Género'),
    _table(['Género', 'Personas', '%'], p.porGenero.map(barRow).toList()),
    _subTitle('Nacionalidad'),
    _table(['Nacionalidad', 'Personas', '%'],
        p.porNacionalidad.map(barRow).toList()),
    _subTitle('Inscripciones por mes (${now.year})'),
    _table(
      ['Mes', 'Inscripciones'],
      [
        for (int m = 0; m < 12; m++)
          if (m < now.month) [_monthShort[m], '${inscripciones[m]}'],
      ],
    ),
    _subTitle('Situación de empleo inicial'),
    _table(['Situación', 'Mujeres', 'Hombres', 'No binario', 'Total'],
        p.situacionEmpleoInicial.map(empleoRow).toList()),
    _subTitle('Situación de empleo actual'),
    _table(['Situación', 'Mujeres', 'Hombres', 'No binario', 'Total'],
        p.situacionEmpleoActual.map(empleoRow).toList()),

    // Desglose demográfico
    _sectionTitle('Desglose demográfico'),
    _subTitle('Grupos de edad'),
    _table(['Grupo', 'Mujeres', 'Hombres', 'No binario', 'Total'],
        _ageRows(p.users, now)),
    _subTitle('Niveles formativos · Nivel CINE'),
    _table(
        ['Nivel', 'Mujeres', 'Hombres', 'No binario', 'Total', '%'],
        p.nivelesCine
            .map((i) => levelRow(i)..[0] = '${i.cineLabel} · ${i.title}')
            .toList()),
    _subTitle('Niveles formativos · Nivel de estudios'),
    _table(
        ['Nivel de estudios', 'Mujeres', 'Hombres', 'No binario', 'Total', '%'],
        p.nivelesEstudios.map(levelRow).toList()),
    if (p.nivelesSinEspecificar > 0)
      _note(
          '${p.nivelesSinEspecificar} participantes sin nivel formativo registrado.'),

    // Categorías especiales
    _sectionTitle('Categorías especiales'),
    _note('Discapacidad, condiciones sobrevenidas y situación administrativa: '
        'sobre ${p.totalConInformeInicialCompleto} participantes con informe inicial completo.'),
    _subTitle('Participantes con discapacidad'),
    _table(
        ['Estado', 'Personas', '%'],
        p.discapacidad
            .map((s) => [s.label, '${s.count}', pct(s.percentage)])
            .toList()),
    _subTitle('Condiciones sobrevenidas'),
    _table(
        ['Condición', 'Personas', '%'],
        p.condicionesSobrevenidas
            .map((i) => [i.label, '${i.count}', pct(i.percentage ?? 0)])
            .toList()),
    _subTitle('Situación administrativa'),
    _table(
        ['Situación', 'Personas', '%'],
        p.situacionAdministrativa
            .map((s) => [s.label, '${s.count}', pct(s.percentage)])
            .toList()),
    _subTitle('Nacionalidades'),
    _table(
      ['Nacionalidad', 'Mujeres', 'Hombres', 'No binario', 'Total'],
      p.nacionalidades
          .map((n) => [
                n.label,
                '${n.mujeres}',
                '${n.hombres}',
                '${n.noBinario}',
                '${n.total}'
              ])
          .toList(),
    ),
    if (p.nacionalidadSinEspecificar > 0)
      _note(
          '${p.nacionalidadSinEspecificar} participantes sin nacionalidad registrada.'),
    _subTitle('Competencias más reconocidas (top 10)'),
    _table(
        ['Competencia', 'Categoría', 'Personas', '%'],
        p.competenciasReconocidas
            .map((i) => [
                  i.label,
                  i.category ?? '',
                  '${i.count}',
                  pct(i.percentage ?? 0)
                ])
            .toList()),
    _subTitle('Por área de competencia'),
    _table(
        ['Categoría', 'Reconocimientos', '%'],
        p.competenciasPorCategoria
            .map((c) => [c.label, '${c.count}', pct(c.percentage)])
            .toList()),
    pw.SizedBox(height: 6),
    _table(
        ['Área', 'Categoría', '%'],
        p.competenciasPorArea
            .map((a) => [a.name, a.group, pct(a.percentage)])
            .toList()),

    // Indicadores de resultados
    _sectionTitle('Indicadores de resultados'),
    _subTitle('Indicadores clave'),
    _table(
      ['Indicador', 'Valor', 'Variación', 'Año anterior'],
      p.indicadoresClave
          .map((k) => [
                k.title,
                k.secondValue != null
                    ? '${k.mainValue} ${k.unit}\n${k.secondValue} ${k.secondUnit}'
                    : '${k.mainValue} ${k.unit}',
                k.variation.isEmpty
                    ? '-'
                    : k.variation.replaceAll('▲', '+').replaceAll('▼', '-'),
                k.previousYearText,
              ])
          .toList(),
    ),
    _subTitle('Recorrido de resultados (acumulado)'),
    _table(
        ['Paso', 'Personas', '% sobre inscritos'],
        p.recorridoResultados
            .map((s) => [s.label, '${s.count}', '${s.percentage}%'])
            .toList()),
    _subTitle('Resultados por sector (empleos por tipo de empleo)'),
    _table(['Sector', 'Personas'],
        p.resultadosPorSector.map((i) => [i.label, '${i.count}']).toList()),
  ];
}

/// Grupos de edad por género, con la misma lógica que la tarjeta "Grupos de edad".
List<List<String>> _ageRows(List<UserEnreda> users, DateTime now) {
  const labels = ['Menos de 18', '18 – 24', '25 – 29', '30 – 54', 'Más de 54'];
  final m = List<int>.filled(5, 0),
      h = List<int>.filled(5, 0),
      nb = List<int>.filled(5, 0);
  for (final u in users) {
    final b = u.birthday;
    if (b == null) continue;
    var age = now.year - b.year;
    if (now.month < b.month || (now.month == b.month && now.day < b.day)) age--;
    if (age < 0 || age > 120) continue;
    final idx = age < 18
        ? 0
        : age <= 24
            ? 1
            : age <= 29
                ? 2
                : age <= 54
                    ? 3
                    : 4;
    final g = (u.gender ?? '').trim().toLowerCase();
    if (g == 'mujer' || g == 'femenino' || g == 'f') {
      m[idx]++;
    } else if (g == 'hombre' || g == 'masculino' || g == 'm') {
      h[idx]++;
    } else {
      nb[idx]++;
    }
  }
  return [
    for (int i = 0; i < 5; i++)
      [labels[i], '${m[i]}', '${h[i]}', '${nb[i]}', '${m[i] + h[i] + nb[i]}'],
  ];
}

// ---------------------------------------------------------------------------
// Recursos

List<pw.Widget> _recursosSection(RecursosKpiData r, DateTime now) {
  final porMes = List<int>.filled(12, 0);
  for (final f in r.fechas) {
    if (f.year == now.year) porMes[f.month - 1]++;
  }
  final pctConInteres =
      r.total > 0 ? (r.conInteres / r.total * 100).round() : 0;

  return [
    _kv('Recursos subidos (total)', '${r.total}'),
    _kv('Subidos este mes', '${r.esteMes}'),
    _subTitle('Por categoría'),
    _table(
        ['Categoría', 'Recursos', '%'],
        r.porCategoria
            .map((s) => [s.label, '${s.count}', '${s.percentage.round()}%'])
            .toList()),
    _subTitle('Recursos subidos por mes (${now.year})'),
    _table(
      ['Mes', 'Recursos'],
      [
        for (int m = 0; m < 12; m++)
          if (m < now.month) [_monthShort[m], '${porMes[m]}'],
      ],
    ),
    _subTitle('Recursos por ámbito de actuación'),
    _note(
        '${r.conInteres} de ${r.total} recursos tienen ámbito informado ($pctConInteres%). '
        'Un recurso puede tener varios.'),
    _table(
        ['Ámbito', 'Recursos', '%'],
        r.porInteres
            .map((i) =>
                [i.label, '${i.count}', '${(i.percentage ?? 0).round()}%'])
            .toList()),
  ];
}

// ---------------------------------------------------------------------------
// Helpers de maquetación

pw.Widget _sectionTitle(String text) => pw.Container(
      margin: const pw.EdgeInsets.only(top: 16, bottom: 6),
      padding: const pw.EdgeInsets.only(bottom: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _primary900, width: 1)),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
            fontSize: 14, fontWeight: pw.FontWeight.bold, color: _primary900),
      ),
    );

pw.Widget _subTitle(String text) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 10, bottom: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
            fontSize: 11, fontWeight: pw.FontWeight.bold, color: _primary900),
      ),
    );

pw.Widget _small(String text) => pw.Text(text,
    style: const pw.TextStyle(fontSize: 9, color: _secondaryText));

pw.Widget _note(String text) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 2, bottom: 2),
      child: _small(text),
    );

pw.Widget _kv(String label, String value) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(children: [
        pw.Expanded(
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 10))),
        pw.Text(value,
            style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: _primary900)),
      ]),
    );

pw.Widget _table(List<String> headers, List<List<String>> rows) {
  if (rows.isEmpty) return _note('Sin datos.');
  return pw.TableHelper.fromTextArray(
    headers: headers,
    data: rows,
    border: const pw.TableBorder(
      horizontalInside: pw.BorderSide(color: _divider, width: 0.5),
      bottom: pw.BorderSide(color: _divider, width: 0.5),
    ),
    headerStyle: pw.TextStyle(
        fontSize: 9, fontWeight: pw.FontWeight.bold, color: _primary900),
    headerDecoration: const pw.BoxDecoration(color: _tileBackground),
    cellStyle: const pw.TextStyle(fontSize: 9),
    cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
    cellAlignment: pw.Alignment.centerRight,
    cellAlignments: {0: pw.Alignment.centerLeft},
    headerAlignments: {0: pw.Alignment.centerLeft},
    headerAlignment: pw.Alignment.centerRight,
  );
}
