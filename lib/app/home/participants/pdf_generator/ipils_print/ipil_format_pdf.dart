import 'dart:async';
import 'dart:typed_data';

import 'package:enreda_empresas/app/home/participants/pdf_generator/cv_print/data.dart';
import 'package:enreda_empresas/app/models/ipilEntry.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'doc_ipil_theme.dart';

Future<Uint8List> generateIpilFile(
    PdfPageFormat format,
    CustomData data,
    UserEnreda user,
    List<IpilEntry>? ipilEntries,
    String techName,
    ) async {
  final doc = pw.Document(title: 'Mis IPILs');
  const PdfColor grey = PdfColor.fromInt(0xFF535A5F);
  const PdfColor black = PdfColor.fromInt(0xF44494B);
  const PdfColor white = PdfColor.fromInt(0xFFFFFFFF);
  const PdfColor primary900 = PdfColor.fromInt(0xFF054D5E);
  final DateFormat formatter = DateFormat('dd/MM/yyyy');

  final pageTheme = await MyIpilPageTheme(format, false);

  doc.addPage(
    pw.MultiPage(
      pageTheme: pageTheme,
      footer: (pw.Context context) {
        return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: pw.Text(
                'Pág. ${context.pageNumber} de ${context.pagesCount}',
                textScaleFactor: 0.8,
                style: pw.Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: grey)));
      },
      build: (pw.Context context) => [
        pw.Text(
          'IPILs de ${user.firstName} ${user.lastName}',
          textScaleFactor: 1.5,
          style: pw.Theme.of(context)
              .defaultTextStyle
              .copyWith(fontWeight: pw.FontWeight.bold, color: primary900)
        ),
        pw.SizedBox(
          height: 30,
        ),
        for(IpilEntry ipil in ipilEntries!)
          (ipil.content != null && ipil.content != '') ? _IpilEntry(ipil: ipil, techName: techName) : pw.Container(),
      ]
    )
  );
  return doc.save();
}


class _IpilEntry extends pw.StatelessWidget {
  _IpilEntry({
    required this.ipil,
    required this.techName
  });

  final IpilEntry ipil;
  final String techName;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                  pw.Text('Fecha',
                      textScaleFactor: 0.8,
                      style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(fontWeight: pw.FontWeight.bold, color: primary900)),
                  pw.Text('${ipil.date.day}/${ipil.date.month}/${ipil.date.year}',
                      textScaleFactor: 0.8,
                      style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(fontWeight: pw.FontWeight.normal, color: grey)
                  )
                  ]
                ),
                pw.SizedBox(
                  width: 50,
                ),
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Nombre de la técnica',
                          textScaleFactor: 0.8,
                          style: pw.Theme.of(context)
                              .defaultTextStyle
                              .copyWith(fontWeight: pw.FontWeight.bold, color: primary900)),
                      pw.Text('$techName',
                          textScaleFactor: 0.8,
                          style: pw.Theme.of(context)
                              .defaultTextStyle
                              .copyWith(fontWeight: pw.FontWeight.normal, color: grey)
                      )
                    ]
                ),
              ]
          ),
          pw.SizedBox(height: 15),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Seguimiento:',
                  textScaleFactor: 0.8,
                  style: pw.Theme.of(context)
                      .defaultTextStyle
                      .copyWith(fontWeight: pw.FontWeight.bold, color: primary900)),
              pw.Text(
                  '${ipil.content}',
                  textScaleFactor: 0.8,
                  style: pw.Theme.of(context)
                      .defaultTextStyle
                      .copyWith(fontWeight: pw.FontWeight.normal, color: grey)
              ),
            ]
          ),
          pw.SizedBox(height: 20),
          pw.Divider(color: grey, thickness: 0.5),
          pw.SizedBox(height: 20)
        ]);
  }
}

