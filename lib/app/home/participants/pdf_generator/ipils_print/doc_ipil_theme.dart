import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

const PdfColor lilac = PdfColor.fromInt(0xFF6768AB);
const PdfColor lightLilac = PdfColor.fromInt(0xFFF4F5FB);
const PdfColor blue = PdfColor.fromInt(0xFF002185);
const PdfColor grey = PdfColor.fromInt(0xFF535A5F);
const PdfColor greyDark = PdfColor.fromInt(0xFF44494B);
const PdfColor green = PdfColor.fromInt(0xF0DA1A0);
const PdfColor black = PdfColor.fromInt(0xF44494B);
const PdfColor white = PdfColor.fromInt(0xFFFFFFFF);
const PdfColor primary900 = PdfColor.fromInt(0xFF054D5E);
const leftWidth = 230.0;
const rightWidth = 350.0;

Future<pw.PageTheme> MyIpilPageTheme(PdfPageFormat format, int isMdm) async {
final bgBytes = isMdm == 0
    ? await rootBundle.load('assets/images/logos-mdm.png')
    : isMdm == 2
        ? await rootBundle.load('assets/images/logos-seimlab.png')
        : await rootBundle.load('assets/images/logos-fse.png');
        final bgImage = pw.MemoryImage(bgBytes.buffer.asUint8List());

  return pw.PageTheme(
    pageFormat: format,
    margin: pw.EdgeInsets.fromLTRB(
      format.marginLeft, format.marginTop, format.marginRight, format.marginBottom),
    theme: pw.ThemeData.withFont(
      base: await PdfGoogleFonts.poppinsLight(),
      bold: await PdfGoogleFonts.poppinsMedium(),
      icons: await PdfGoogleFonts.materialIcons(),
    ),
    buildBackground: (pw.Context context) {
      // if (context.pageNumber > 1) {
      //   return pw.FullPage(
      //     ignoreMargins: true,
      //     child: pw.Stack(
      //       children: [
      //         pw.Positioned(
      //           child: pw.SvgImage(svg: bgShape2),
      //           left: 0,
      //           top: 10,
      //         ),
      //       ],
      //     ),
      //   );
      // }
      return pw.FullPage(
        ignoreMargins: true,
        child: pw.Stack(
          children: [
            pw.Positioned(
                left: 10,
                top: 30,
                right: 10,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(
                      width: 550,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.rectangle,
                      ),
                      child: /*pw.SvgImage(svg: bgShape2),*/pw.Image(
                      bgImage,
                      width: 550,
                      fit: pw.BoxFit.contain,
                    )
                      //child: pw.Container(),
                    ),
                  ],)
            ),
          ],
        ),
      );
    },
  );
}