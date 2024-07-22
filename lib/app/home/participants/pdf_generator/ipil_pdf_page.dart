import 'dart:async';
import 'dart:typed_data';

import 'package:enreda_empresas/app/models/ipilEntry.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'cv_print/data.dart';

import 'package:enreda_empresas/app/home/participants/pdf_generator/ipil_format_pdf.dart'
if (dart.library.html) 'package:enreda_empresas/app/home/participants/pdf_generator/ipil_format_pdf.dart' as my_worker;

const examplesIpil = <Example>[
  !kIsWeb ? Example('IPIL', 'ipil_format_pdf.dart', my_worker.generateIpilFile) : Example('IPIL', 'ipil_format_pdf.dart', my_worker.generateIpilFile),
];

typedef LayoutCallbackWithData = Future<Uint8List> Function(
    PdfPageFormat pageFormat,
    CustomData data,
    UserEnreda user,
    List<IpilEntry> ipilEntries,
    String techName,
    );

class Example {
  const Example(this.name, this.file, this.builder, [this.needsData = false]);

  final String name;

  final String file;

  final LayoutCallbackWithData builder;

  final bool needsData;
}
