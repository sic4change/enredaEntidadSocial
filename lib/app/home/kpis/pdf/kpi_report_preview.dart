import 'dart:io';

import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../kpi_service.dart';
import '../report/docx_writer.dart';
import '../report/file_download.dart';
import '../report/report_document.dart';
import '../report/xlsx_writer.dart';
import 'kpi_report_pdf.dart';
import 'participantes_report_pdf.dart';

enum _ReportType { kpi, participantes }

enum _DownloadFormat {
  pdf('PDF', 'pdf', 'application/pdf', Icons.picture_as_pdf_outlined),
  word(
      'Word',
      'docx',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      Icons.description_outlined),
  excel(
      'Excel',
      'xlsx',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      Icons.table_chart_outlined);

  const _DownloadFormat(this.label, this.extension, this.mimeType, this.icon);

  final String label;
  final String extension;
  final String mimeType;
  final IconData icon;
}

extension on _ReportType {
  String get label => switch (this) {
        _ReportType.kpi => 'KPI',
        _ReportType.participantes => 'Participantes',
      };

  IconData get icon => switch (this) {
        _ReportType.kpi => Icons.bar_chart_outlined,
        _ReportType.participantes => Icons.people_outline,
      };

  String get baseName => switch (this) {
        _ReportType.kpi => 'informe_kpis',
        _ReportType.participantes => 'informe_participantes',
      };

  String get fileName => '$baseName.pdf';

  PdfPageFormat get pageFormat => switch (this) {
        _ReportType.kpi => PdfPageFormat.a4,
        _ReportType.participantes => PdfPageFormat.a3.landscape,
      };
}

/// Previsualización de los informes de la vista de KPIs, con las mismas
/// acciones (imprimir, compartir/descargar) que los informes de participantes.
/// Un panel lateral permite elegir entre el informe de indicadores y el
/// desglose de participantes.
class KpiReportPreview extends StatefulWidget {
  const KpiReportPreview({
    Key? key,
    required this.data,
    required this.loadParticipantes,
  }) : super(key: key);

  final KpiReportData data;

  /// Carga el listado de participantes de la vista; solo se llama al elegir
  /// el informe "Participantes".
  final Future<List<ParticipanteListadoRow>> Function() loadParticipantes;

  @override
  State<KpiReportPreview> createState() => _KpiReportPreviewState();
}

class _KpiReportPreviewState extends State<KpiReportPreview> {
  _ReportType _selected = _ReportType.kpi;
  Future<List<ParticipanteListadoRow>>? _participantes;

  void _showPrintedToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.penLightBlue,
        content: Text('Documento impreso con éxito'),
      ),
    );
  }

  void _showSharedToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.penLightBlue,
        content: Text('Documento compartido con éxito'),
      ),
    );
  }

  Future<void> _saveAsFile(
    BuildContext context,
    LayoutCallback build,
    PdfPageFormat pageFormat,
  ) async {
    final bytes = await build(pageFormat);
    final appDocDir = await getApplicationDocumentsDirectory();
    final file = File('${appDocDir.path}/${_selected.fileName}');
    await file.writeAsBytes(bytes);
    await OpenFile.open(file.path);
  }

  Future<List<ParticipanteListadoRow>> _participantesRows() async {
    _participantes ??= widget.loadParticipantes();
    try {
      return await _participantes!;
    } catch (_) {
      // Se reintenta la carga al volver a elegir "Participantes"
      _participantes = null;
      rethrow;
    }
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    switch (_selected) {
      case _ReportType.kpi:
        return generateKpiReportPdf(format, widget.data);
      case _ReportType.participantes:
        return generateParticipantesReportPdf(
          format,
          filterLabel: widget.data.filterLabel,
          generatedAt: widget.data.generatedAt,
          rows: await _participantesRows(),
        );
    }
  }

  Future<ReportDocument> _reportDocument() async {
    switch (_selected) {
      case _ReportType.kpi:
        return buildKpiReportDocument(widget.data);
      case _ReportType.participantes:
        return buildParticipantesReportDocument(
          filterLabel: widget.data.filterLabel,
          generatedAt: widget.data.generatedAt,
          rows: await _participantesRows(),
        );
    }
  }

  Future<void> _download(_DownloadFormat format) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final Uint8List bytes = switch (format) {
        _DownloadFormat.pdf => await _generatePdf(_selected.pageFormat),
        _DownloadFormat.word => buildDocx(await _reportDocument()),
        _DownloadFormat.excel => buildXlsx(await _reportDocument()),
      };
      await downloadFile(
        bytes,
        '${_selected.baseName}.${format.extension}',
        format.mimeType,
      );
    } catch (e, stack) {
      print('KPIs: error descargando informe (${format.label}): $e\n$stack');
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('No se pudo descargar el informe en ${format.label}'),
        ),
      );
    }
  }

  Widget _downloadButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: PopupMenuButton<_DownloadFormat>(
        tooltip: 'Descargar',
        onSelected: _download,
        itemBuilder: (context) => [
          for (final format in _DownloadFormat.values)
            PopupMenuItem(
              value: format,
              child: Row(
                children: [
                  Icon(format.icon, color: AppColors.turquoiseBlue),
                  const SizedBox(width: 10),
                  Text('${format.label} (.${format.extension})'),
                ],
              ),
            ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'DESCARGAR',
                style: TextStyle(
                  color: AppColors.turquoiseBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.download, color: AppColors.turquoiseBlue, size: 20),
              Icon(Icons.arrow_drop_down, color: AppColors.turquoiseBlue),
            ],
          ),
        ),
      ),
    );
  }

  void _select(_ReportType type) {
    if (_selected == type) return;
    setState(() => _selected = type);
  }

  Widget _option(_ReportType type, {required bool compact}) {
    final isSelected = _selected == type;
    return InkWell(
      onTap: () => _select(type),
      borderRadius: BorderRadius.circular(compact ? 20 : 25),
      child: Container(
        margin: compact
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: compact
            ? const EdgeInsets.symmetric(vertical: 8, horizontal: 6)
            : const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary100 : Colors.transparent,
          border: compact
              ? Border.all(color: AppColors.turquoiseBlue, width: 1.5)
              : null,
          borderRadius: BorderRadius.circular(compact ? 20 : 25),
        ),
        child: Row(
          mainAxisAlignment:
              compact ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(type.icon,
                color: AppColors.turquoiseBlue, size: compact ? 14 : 24),
            SizedBox(width: compact ? 4 : 10),
            Flexible(
              child: Text(
                type.label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.turquoiseBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: compact ? 12 : 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _preview() {
    final actions = <PdfPreviewAction>[
      if (!kIsWeb)
        PdfPreviewAction(
          icon: const Icon(Icons.save),
          onPressed: _saveAsFile,
        ),
    ];

    return PdfPreview(
      key: ValueKey(_selected),
      maxPageWidth: _selected == _ReportType.participantes ? 1100 : 700,
      build: _generatePdf,
      actions: actions,
      canDebug: false,
      canChangeOrientation: false,
      canChangePageFormat: false,
      initialPageFormat: _selected.pageFormat,
      pdfFileName: _selected.fileName,
      onPrinted: _showPrintedToast,
      onShared: _showSharedToast,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final title = _selected == _ReportType.kpi
        ? 'Informe de indicadores · ${widget.data.filterLabel}'
        : 'Participantes · ${widget.data.filterLabel}';

    final appBar = AppBar(
      backgroundColor: AppColors.primary100,
      iconTheme: const IconThemeData(color: AppColors.turquoiseBlue),
      actionsIconTheme: const IconThemeData(color: AppColors.white),
      foregroundColor: Colors.white,
      actions: [_downloadButton()],
      title: CustomTextBoldCenter(
        title: title,
        color: AppColors.turquoiseBlue,
      ),
      titleTextStyle: textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontSize: 22.0,
      ),
    );

    if (Responsive.isMobile(context)) {
      return Scaffold(
        appBar: appBar,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  for (final type in _ReportType.values)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _option(type, compact: true),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(child: _preview()),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: Row(
        children: [
          // Panel lateral con los tipos de informe
          Container(
            width: 250,
            color: Colors.white,
            child: ListView(
              padding: const EdgeInsets.only(top: 20),
              children: [
                for (final type in _ReportType.values)
                  _option(type, compact: false),
              ],
            ),
          ),
          Container(width: 1, color: Colors.grey[300]),
          Expanded(child: _preview()),
        ],
      ),
    );
  }
}
