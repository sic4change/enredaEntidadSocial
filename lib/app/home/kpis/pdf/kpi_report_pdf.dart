import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../models/userEnreda.dart';
import '../kpi_models.dart';
import '../kpi_service.dart';
import '../report/report_document.dart';

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

  /// Capturas de las tarjetas de la página tal y como estaban (periodo,
  /// desagregación…), por título de tarjeta.
  final Map<String, ReportImage> charts;

  const KpiReportData({
    required this.filterId,
    required this.filterLabel,
    required this.generatedAt,
    this.participantes,
    this.recursos,
    this.charts = const {},
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

const double _logoTop = 30;
const double _logoWidth = 550;

Future<Uint8List> generateKpiReportPdf(
    PdfPageFormat format, KpiReportData data) async {
  final doc =
      pw.Document(title: 'Informe de indicadores - ${data.filterLabel}');

  final logoAsset = _logoAssetFor(data.filterId);
  final pw.MemoryImage? logo = logoAsset != null
      ? pw.MemoryImage((await rootBundle.load(logoAsset)).buffer.asUint8List())
      : null;

  // Los logos se dibujan a [_logoTop] del borde con [_logoWidth] de ancho; el
  // contenido empieza 1 cm por debajo de ellos
  double top = 2.0 * PdfPageFormat.cm;
  if (logo != null && logo.width != null && logo.height != null) {
    final logoHeight = _logoWidth * logo.height! / logo.width!;
    top = math.max(top, _logoTop + logoHeight + 1.0 * PdfPageFormat.cm);
  }

  format = format.applyMargin(
    left: 2.0 * PdfPageFormat.cm,
    top: top,
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
                  top: _logoTop,
                  right: 10,
                  child: pw.Center(
                      child: pw.Image(logo,
                          width: _logoWidth, fit: pw.BoxFit.contain)),
                ),
              ]),
            ),
  );

  final report = buildKpiReportDocument(data);

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
          report.title,
          style: pw.TextStyle(
              fontSize: 18, fontWeight: pw.FontWeight.bold, color: _primary900),
        ),
        pw.SizedBox(height: 4),
        ...report.subtitleLines.map(_small),
        pw.SizedBox(height: 12),
        ..._renderBlocks(report.blocks, format),
      ],
    ),
  );

  return doc.save();
}

/// Contenido del informe de KPIs, común a PDF, Word y Excel.
ReportDocument buildKpiReportDocument(KpiReportData data) {
  final p = data.participantes;
  final r = data.recursos;
  return ReportDocument(
    title: 'Informe de indicadores (KPIs)',
    subtitleLines: [
      'Vista: ${data.filterLabel}',
      'Generado el ${DateFormat('dd/MM/yyyy HH:mm').format(data.generatedAt)}',
    ],
    blocks: [
      if (p != null) ..._participantesSections(p, data.generatedAt, data.charts),
      if (p == null)
        const ReportNote(
            'No hay datos de participantes cargados para esta vista.'),
      const ReportSectionTitle('Recursos'),
      const ReportNote(
          'Los recursos se cuentan siempre sobre el total, independientemente del filtro.'),
      if (r != null) ..._recursosSection(r, data.generatedAt, data.charts),
      if (r == null) const ReportNote('No hay datos de recursos cargados.'),
    ],
  );
}

List<pw.Widget> _renderBlocks(List<ReportBlock> blocks, PdfPageFormat format) {
  final widgets = <pw.Widget>[];
  ReportBlock? previous;
  for (final block in blocks) {
    switch (block) {
      case ReportSectionTitle(:final text):
        widgets.add(_sectionTitle(text));
      case ReportSubTitle(:final text):
        widgets.add(_subTitle(text));
      case ReportNote(:final text):
        widgets.add(_note(text));
      case ReportKeyValue(:final label, :final value):
        widgets.add(_kv(label, value));
      case ReportTable(:final headers, :final rows):
        if (previous is ReportTable) widgets.add(pw.SizedBox(height: 6));
        widgets.add(_table(headers, rows));
      case ReportImage():
        final size = block.fit(format.availableWidth,
            format.availableHeight - 4 * PdfPageFormat.cm);
        widgets.add(pw.Padding(
          padding: const pw.EdgeInsets.only(top: 4),
          child: pw.Image(pw.MemoryImage(block.bytes),
              width: size.width, height: size.height),
        ));
      case ReportSource(:final text):
        widgets.add(pw.Padding(
          padding: const pw.EdgeInsets.only(top: 3, bottom: 6),
          child: pw.Text(text,
              style: const pw.TextStyle(fontSize: 7, color: _secondaryText)),
        ));
    }
    previous = block;
  }
  return widgets;
}

// ---------------------------------------------------------------------------
// Participantes

/// Origen de los datos de cada tarjeta, para la nota bajo su gráfica.
const Map<String, String> _cardSources = {
  'Participantes inscritos':
      'Perfiles de los participantes de la vista seleccionada. El estado sale de los informes inicial, de derivación y de cierre.',
  'Evolución de inscripciones':
      'Fecha de alta del participante en Enreda (o, si falta, fecha de inicio del itinerario).',
  'Situación de empleo':
      'Informe inicial › Situación laboral (inicial) y último informe de seguimiento o de cierre (actual).',
  'Grupos de edad': 'Fecha de nacimiento del perfil del participante.',
  'Niveles formativos':
      'Nivel educativo indicado en el alta del participante, agrupado por niveles CINE.',
  'Nacionalidades': 'Nacionalidad del perfil del participante.',
  'Participantes con discapacidad':
      'Informe inicial › Discapacidad (participantes con informe inicial completo).',
  'Condiciones sobrevenidas':
      'Informe inicial › Situaciones de vulnerabilidad (participantes con informe inicial completo).',
  'Situación administrativa':
      'Nacionalidad del perfil e informe inicial › Situación administrativa (participantes con informe inicial completo).',
  'Competencias más reconocidas':
      'Competencias reconocidas en el perfil de Enreda de cada participante.',
  'Por área de competencia':
      'Competencias reconocidas en el perfil de Enreda, agrupadas por área y categoría.',
  'Indicadores clave':
      'IPIL (inscripción y certificación de formación, seguimiento a 4 semanas y 6 meses), informe de cierre (consecución de empleo) y currículum de Enreda.',
  'Recorrido de resultados':
      'Participantes inscritos, IPIL e informe de cierre (acumulado desde el inicio).',
  'Resultados por sector':
      'IPIL › Seguimiento a las 4 semanas y 6 meses › "Obtienen empleo" › Tipo de empleo.',
  'Recursos subidos': 'Recursos publicados en la plataforma y su categoría.',
  'Línea temporal de recursos': 'Fecha de creación de cada recurso.',
  'Recursos por categoría':
      'Ámbitos de actuación asignados a cada recurso (un recurso puede tener varios).',
};

/// Cabecera de una tarjeta: título, su gráfica capturada (si estaba en
/// pantalla) y la fuente de los datos en letra pequeña.
List<ReportBlock> _card(String title, Map<String, ReportImage> charts) => [
      ReportSubTitle(title),
      if (charts[title] != null) charts[title]!,
      if (_cardSources[title] != null)
        ReportSource('Fuente: ${_cardSources[title]}'),
    ];

List<ReportBlock> _participantesSections(
    ParticipantesKpiData p, DateTime now, Map<String, ReportImage> charts) {
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
    ReportSectionTitle('Resumen general'),
    ..._card('Participantes inscritos', charts),
    ReportKeyValue('Participantes inscritos', '${p.total}'),
    ReportKeyValue(
        'Con informe inicial completo', '${p.totalConInformeInicialCompleto}'),
    ReportNote('Estado'),
    ReportTable(['Estado', 'Personas', '%'], p.porEstado.map(barRow).toList()),
    ReportNote('Género'),
    ReportTable(['Género', 'Personas', '%'], p.porGenero.map(barRow).toList()),
    ReportNote('Nacionalidad'),
    ReportTable(['Nacionalidad', 'Personas', '%'],
        p.porNacionalidad.map(barRow).toList()),
    ..._card('Evolución de inscripciones', charts),
    ReportNote('Inscripciones por mes (${now.year})'),
    ReportTable(
      ['Mes', 'Inscripciones'],
      [
        for (int m = 0; m < 12; m++)
          if (m < now.month) [_monthShort[m], '${inscripciones[m]}'],
      ],
    ),
    ..._card('Situación de empleo', charts),
    ReportNote('Situación inicial'),
    ReportTable(['Situación', 'Mujeres', 'Hombres', 'No binario', 'Total'],
        p.situacionEmpleoInicial.map(empleoRow).toList()),
    ReportNote('Situación actual'),
    ReportTable(['Situación', 'Mujeres', 'Hombres', 'No binario', 'Total'],
        p.situacionEmpleoActual.map(empleoRow).toList()),

    // Desglose demográfico
    ReportSectionTitle('Desglose demográfico'),
    ..._card('Grupos de edad', charts),
    ReportTable(['Grupo', 'Mujeres', 'Hombres', 'No binario', 'Total'],
        _ageRows(p.users, now)),
    ..._card('Niveles formativos', charts),
    ReportNote('Nivel CINE'),
    ReportTable(
        ['Nivel', 'Mujeres', 'Hombres', 'No binario', 'Total', '%'],
        p.nivelesCine
            .map((i) => levelRow(i)..[0] = '${i.cineLabel} · ${i.title}')
            .toList()),
    ReportNote('Nivel de estudios'),
    ReportTable(
        ['Nivel de estudios', 'Mujeres', 'Hombres', 'No binario', 'Total', '%'],
        p.nivelesEstudios.map(levelRow).toList()),
    if (p.nivelesSinEspecificar > 0)
      ReportNote(
          '${p.nivelesSinEspecificar} participantes sin nivel formativo registrado.'),
    ..._card('Nacionalidades', charts),
    ReportTable(
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
      ReportNote(
          '${p.nacionalidadSinEspecificar} participantes sin nacionalidad registrada.'),
    ..._card('Participantes con discapacidad', charts),
    ReportNote(
        'Sobre ${p.totalConInformeInicialCompleto} participantes con informe inicial completo.'),
    ReportTable(
        ['Estado', 'Personas', '%'],
        p.discapacidad
            .map((s) => [s.label, '${s.count}', pct(s.percentage)])
            .toList()),

    // Categorías especiales
    ReportSectionTitle('Categorías especiales'),
    ..._card('Condiciones sobrevenidas', charts),
    ReportTable(
        ['Condición', 'Personas', '%'],
        p.condicionesSobrevenidas
            .map((i) => [i.label, '${i.count}', pct(i.percentage ?? 0)])
            .toList()),
    ..._card('Situación administrativa', charts),
    ReportTable(
        ['Situación', 'Personas', '%'],
        p.situacionAdministrativa
            .map((s) => [s.label, '${s.count}', pct(s.percentage)])
            .toList()),
    ..._card('Competencias más reconocidas', charts),
    ReportNote('Top 10'),
    ReportTable(
        ['Competencia', 'Categoría', 'Personas', '%'],
        p.competenciasReconocidas
            .map((i) => [
                  i.label,
                  i.category ?? '',
                  '${i.count}',
                  pct(i.percentage ?? 0)
                ])
            .toList()),
    ..._card('Por área de competencia', charts),
    ReportTable(
        ['Categoría', 'Reconocimientos', '%'],
        p.competenciasPorCategoria
            .map((c) => [c.label, '${c.count}', pct(c.percentage)])
            .toList()),
    ReportTable(
        ['Área', 'Categoría', '%'],
        p.competenciasPorArea
            .map((a) => [a.name, a.group, pct(a.percentage)])
            .toList()),

    // Indicadores de resultados
    ReportSectionTitle('Indicadores de resultados'),
    ..._card('Indicadores clave', charts),
    ReportTable(
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
    ..._card('Recorrido de resultados', charts),
    ReportTable(
        ['Paso', 'Personas', '% sobre inscritos'],
        p.recorridoResultados
            .map((s) => [s.label, '${s.count}', '${s.percentage}%'])
            .toList()),
    ..._card('Resultados por sector', charts),
    ReportTable(['Sector', 'Personas'],
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

List<ReportBlock> _recursosSection(
    RecursosKpiData r, DateTime now, Map<String, ReportImage> charts) {
  final porMes = List<int>.filled(12, 0);
  for (final f in r.fechas) {
    if (f.year == now.year) porMes[f.month - 1]++;
  }
  final pctConInteres =
      r.total > 0 ? (r.conInteres / r.total * 100).round() : 0;

  return [
    ..._card('Recursos subidos', charts),
    ReportKeyValue('Recursos subidos (total)', '${r.total}'),
    ReportKeyValue('Subidos este mes', '${r.esteMes}'),
    ReportTable(
        ['Categoría', 'Recursos', '%'],
        r.porCategoria
            .map((s) => [s.label, '${s.count}', '${s.percentage.round()}%'])
            .toList()),
    ..._card('Línea temporal de recursos', charts),
    ReportNote('Recursos subidos por mes (${now.year})'),
    ReportTable(
      ['Mes', 'Recursos'],
      [
        for (int m = 0; m < 12; m++)
          if (m < now.month) [_monthShort[m], '${porMes[m]}'],
      ],
    ),
    ..._card('Recursos por categoría', charts),
    ReportNote(
        '${r.conInteres} de ${r.total} recursos tienen ámbito informado ($pctConInteres%). '
        'Un recurso puede tener varios.'),
    ReportTable(
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
