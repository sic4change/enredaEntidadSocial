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
  const PdfColor primary900 = PdfColor.fromInt(0xFF054D5E);
  final pageTheme = await MyIpilPageTheme(format, false);

  doc.addPage(
    pw.MultiPage(
      pageTheme: pageTheme,
      footer: (pw.Context context) {
        return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: SmallText(text: 'Pág. ${context.pageNumber} de ${context.pagesCount}'),
        );
      },
      build: (pw.Context context) => [
        pw.Text(
          'IPILs de ${user.firstName} ${user.lastName}',
          textScaleFactor: 1.5,
          style: pw.Theme.of(context)
              .defaultTextStyle
              .copyWith(fontWeight: pw.FontWeight.bold, color: primary900)
        ),
        pw.SizedBox(height: 20),
        for(IpilEntry ipil in ipilEntries!)
          (ipil.content != null && ipil.content != '') ? _IpilEntry(ipil: ipil, techName: techName) : pw.Container(),
        pw.SizedBox(height: 10),
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
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.SizedBox(height: 10),
          pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    SmallText(text: 'Fecha',
                        fontWeight: pw.FontWeight.bold, color: primary900),
                    SmallText(text: formatter.format(ipil.date.toLocal()),),
                  ]
                ),
                pw.SizedBox(width: 50,),
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      SmallText(text: 'Nombre de la técnica',
                          fontWeight: pw.FontWeight.bold, color: primary900),
                      SmallText(text: '$techName'),
                    ]
                ),
              ]
          ),
          pw.SizedBox(height: 10),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              SmallText(text: 'Seguimiento',
                  fontWeight: pw.FontWeight.bold, color: primary900),
              SmallText(text: '${ipil.content}'),
            ]
          ),
          pw.SizedBox(height: 10),
          (ipil.reinforcement != null && ipil.reinforcement!.isNotEmpty ) ?
            SmallText(text: 'Fortalecimiento de las competencias',
                fontWeight: pw.FontWeight.bold, color: primary900) : pw.Container(),
          if (ipil.reinforcementsText != null && ipil.reinforcementsText!.isNotEmpty)
            SmallText(text: ipil.reinforcementsText!),
          pw.SizedBox(height: 5),
          (ipil.contextualization != null && ipil.contextualization!.isNotEmpty ) ?
          SmallText(text: 'Contextualización',
              fontWeight: pw.FontWeight.bold, color: primary900) : pw.Container(),
          if (ipil.contextualizationText != null && ipil.contextualizationText!.isNotEmpty)
            SmallText(text: ipil.contextualizationText!),
          pw.SizedBox(height: 5),
          (ipil.connectionTerritory != null && ipil.connectionTerritory!.isNotEmpty ) ?
          SmallText(text: 'Conexión con el territorio',
              fontWeight: pw.FontWeight.bold, color: primary900) : pw.Container(),
          if (ipil.connectionTerritoryText != null && ipil.connectionTerritoryText!.isNotEmpty)
            SmallText(text: ipil.connectionTerritoryText!),
          pw.SizedBox(height: 5),
          (ipil.interviews != null && ipil.interviews!.isNotEmpty ) ?
          SmallText(text: 'Entrevistas',
              fontWeight: pw.FontWeight.bold, color: primary900) : pw.Container(),
          if (ipil.interviewsText != null && ipil.interviewsText!.isNotEmpty)
            SmallText(text: ipil.interviewsText!),
          pw.SizedBox(height: 8),
          pw.Divider(color: grey, thickness: 0.5),
        ]);
  }
}

class SmallText extends pw.StatelessWidget {
  SmallText({
    required this.text,
    this.color = grey,
    this.fontWeight = pw.FontWeight.normal,
  });

  final String text;
  final PdfColor? color;
  final pw.FontWeight? fontWeight;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Text(
        text,
        textScaleFactor: 0.8,
        style: pw.Theme.of(context)
            .defaultTextStyle
            .copyWith(fontWeight: fontWeight, color: color)
    );
  }
}
