import 'dart:async';
import 'dart:typed_data';


import 'package:enreda_empresas/app/models/derivationReport.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'cv_print/data.dart';

import 'package:enreda_empresas/app/home/participants/pdf_generator/derivation_report_format_pdf.dart'
if (dart.library.html) 'package:enreda_empresas/app/home/participants/pdf_generator/derivation_report_format_pdf.dart' as my_worker;

const examplesDerivationReport = <Example>[
  !kIsWeb ? Example('Reporte de derivación', 'derivation_report_format_pdf.dart', my_worker.generateDerivationReportFile) : Example('Reporte de seguimiento', 'follow_report_format_pdf.dart', my_worker.generateDerivationReportFile),
];

typedef LayoutCallbackWithData = Future<Uint8List> Function(
    PdfPageFormat pageFormat,
    CustomData data,
    UserEnreda user,
    DerivationReport derivationReport,
    );

class Example {
  const Example(this.name, this.file, this.builder, [this.needsData = false]);

  final String name;

  final String file;

  final LayoutCallbackWithData builder;

  final bool needsData;
}
