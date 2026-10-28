import 'dart:io';

import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'kpi_report_pdf.dart';

/// Previsualización del informe de KPIs, con las mismas acciones (imprimir,
/// compartir/descargar) que los informes de participantes.
class KpiReportPreview extends StatelessWidget {
  const KpiReportPreview({Key? key, required this.data}) : super(key: key);

  final KpiReportData data;

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
    final file = File('${appDocDir.path}/informe_kpis.pdf');
    await file.writeAsBytes(bytes);
    await OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final actions = <PdfPreviewAction>[
      if (!kIsWeb)
        PdfPreviewAction(
          icon: const Icon(Icons.save),
          onPressed: _saveAsFile,
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary100,
        iconTheme: const IconThemeData(color: AppColors.turquoiseBlue),
        actionsIconTheme: const IconThemeData(color: AppColors.white),
        foregroundColor: Colors.white,
        title: CustomTextBoldCenter(
          title: 'Informe de indicadores · ${data.filterLabel}',
          color: AppColors.turquoiseBlue,
        ),
        titleTextStyle: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 22.0,
        ),
      ),
      body: PdfPreview(
        maxPageWidth: 700,
        build: (format) => generateKpiReportPdf(format, data),
        actions: actions,
        canDebug: false,
        canChangeOrientation: false,
        initialPageFormat: PdfPageFormat.a4,
        pdfFileName: 'informe_kpis.pdf',
        onPrinted: _showPrintedToast,
        onShared: _showSharedToast,
      ),
    );
  }
}
