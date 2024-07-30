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

Future<pw.PageTheme> MyIpilPageTheme(PdfPageFormat format, bool isMdm) async {
  // final bgShape2 = isMdm ? await rootBundle.loadString('assets/images/logos-mdm.svg') :
  // await rootBundle.loadString('assets/images/logos-fse.svg');
  return pw.PageTheme(
    pageFormat: format,
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
                      //child: pw.SvgImage(svg: bgShape2),
                      child: pw.Container(),
                    ),
                  ],)
            ),
          ],
        ),
      );
    },
  );
}