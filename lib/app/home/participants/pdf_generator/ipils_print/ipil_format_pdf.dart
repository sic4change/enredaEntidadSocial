import 'dart:async';
import 'dart:typed_data';

import 'package:enreda_empresas/app/home/participants/pdf_generator/cv_print/data.dart';
import 'package:enreda_empresas/app/models/ipilEntry.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/values/strings.dart';
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
        pw.SizedBox(height: 10),
        for(IpilEntry ipil in ipilEntries!)
          (ipil.content != null && ipil.content != '') ?
          _IpilEntry(ipil: ipil, techName: techName) : pw.Container(),
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
                BlockText(title: StringConst.DATE, text: formatter.format(ipil.date.toLocal())),
                pw.SizedBox(width: 50,),
                BlockText(title: StringConst.TECHNICAL_NAME, text: '$techName'),
              ]
          ),
          pw.SizedBox(height: 10),

          BlockText(title: StringConst.IPIL_FOLLOW, text: ipil.content!),

          if (ipil.reinforcementsText != null && ipil.reinforcementsText!.isNotEmpty)
            BlockText(title: StringConst.IPIL_REINFORCEMENT, text: ipil.reinforcementsText!),

          if (ipil.contextualizationText != null && ipil.contextualizationText!.isNotEmpty)
            BlockText(title: StringConst.IPIL_CONTEXTUALIZATION, text: ipil.contextualizationText!),

          if (ipil.connectionTerritoryText != null && ipil.connectionTerritoryText!.isNotEmpty)
            BlockText(title: StringConst.IPIL_CONNECTION_TERRITORY, text: ipil.connectionTerritoryText!),

          if (ipil.interviewsText != null && ipil.interviewsText!.isNotEmpty)
            BlockText(title: StringConst.IPIL_INTERVIEWS, text: ipil.interviewsText!),

          if (ipil.obtainingEmploymentText != null && ipil.obtainingEmploymentText!.isNotEmpty)
            BlockText(title: StringConst.IPIL_OBTAINING_EMPLOYMENT, text: ipil.obtainingEmploymentText!),

          if (ipil.improvingEmploymentText != null && ipil.improvingEmploymentText!.isNotEmpty)
            BlockText(title: StringConst.IPIL_IMPROVING_EMPLOYMENT, text: ipil.improvingEmploymentText!),

          if (ipil.coordinationText != null && ipil.coordinationText!.isNotEmpty )
            BlockText(title: StringConst.IPIL_COORDINATION, text: ipil.coordinationText!),

          if (ipil.postWorkSupportText != null && ipil.postWorkSupportText!.isNotEmpty)
            BlockText(title: StringConst.IPIL_POST_WORK_SUPPORT, text: ipil.postWorkSupportText!),

          pw.SizedBox(height: 8),
          pw.Divider(color: grey, thickness: 0.5),
        ]);
  }
}

class BlockText extends pw.StatelessWidget {
  BlockText({
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 5),
        SmallText(text: title,
            fontWeight: pw.FontWeight.bold, color: primary900),
        SmallText(text: text,
            fontWeight: pw.FontWeight.normal, color: grey),
      ]
    );
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
