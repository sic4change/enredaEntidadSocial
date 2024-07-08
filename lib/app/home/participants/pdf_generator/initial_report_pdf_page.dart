import 'dart:async';
import 'dart:typed_data';

import 'package:enreda_empresas/app/models/certificationRequest.dart';
import 'package:enreda_empresas/app/models/experience.dart';
import 'package:enreda_empresas/app/models/initialReport.dart';
import 'package:enreda_empresas/app/models/ipilEntry.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'cv_print/data.dart';

import 'package:enreda_empresas/app/home/participants/pdf_generator/initial_report_format_pdf.dart'
if (dart.library.html) 'package:enreda_empresas/app/home/participants/pdf_generator/initial_report_format_pdf.dart' as my_worker;

const examplesInitialReport = <Example>[
  !kIsWeb ? Example('Reporte inicial', 'initial_report_format_pdf.dart', my_worker.generateInitialReportFile) : Example('Reporte inicial', 'initial_report_format_pdf.dart', my_worker.generateInitialReportFile),
];

typedef LayoutCallbackWithData = Future<Uint8List> Function(
    PdfPageFormat pageFormat,
    CustomData data,
    UserEnreda user,
    InitialReport initialReport,
    );

class Example {
  const Example(this.name, this.file, this.builder, [this.needsData = false]);

  final String name;

  final String file;

  final LayoutCallbackWithData builder;

  final bool needsData;
}
