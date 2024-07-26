import 'dart:async';
import 'dart:typed_data';

import 'package:enreda_empresas/app/models/followReport.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'cv_print/data.dart';

import 'package:enreda_empresas/app/home/participants/pdf_generator/follow_report_format_pdf.dart'
if (dart.library.html) 'package:enreda_empresas/app/home/participants/pdf_generator/follow_report_format_pdf.dart' as my_worker;

const examplesFollowReport = <Example>[
  !kIsWeb ? Example(StringConst.FOLLOW_REPORT, 'follow_report_format_pdf.dart', my_worker.generateFollowReportFile) : Example(StringConst.FOLLOW_REPORT, 'follow_report_format_pdf.dart', my_worker.generateFollowReportFile),
];

typedef LayoutCallbackWithData = Future<Uint8List> Function(
    PdfPageFormat pageFormat,
    CustomData data,
    UserEnreda user,
    FollowReport followReport,
    );

class Example {
  const Example(this.name, this.file, this.builder, [this.needsData = false]);

  final String name;

  final String file;

  final LayoutCallbackWithData builder;

  final bool needsData;
}
