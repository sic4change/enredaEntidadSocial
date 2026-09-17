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

Future<pw.PageTheme> MyPageTheme(PdfPageFormat format, int isMdm) async {
  pw.MemoryImage? bgImage;
  try {
    final assetPath = isMdm == 0
        ? 'assets/images/logos-mdm.png'
        : isMdm == 2
            ? 'assets/images/logos-seimlab.png'
            : 'assets/images/logos-fse.png';
    final bgBytes = await rootBundle.load(assetPath);
    bgImage = pw.MemoryImage(bgBytes.buffer.asUint8List());
  } catch (e) {
    print('Error loading logo asset for PDF theme: $e');
  }

  pw.ThemeData themeData;
  try {
    themeData = pw.ThemeData.withFont(
      base: await PdfGoogleFonts.poppinsLight(),
      bold: await PdfGoogleFonts.poppinsMedium(),
      icons: await PdfGoogleFonts.materialIcons(),
    );
  } catch (e) {
    print('Error loading PdfGoogleFonts, falling back to standard Helvetica: $e');
    themeData = pw.ThemeData.withFont(
      base: pw.Font.helvetica(),
      bold: pw.Font.helveticaBold(),
    );
  }

  return pw.PageTheme(
    pageFormat: format,
    margin: pw.EdgeInsets.fromLTRB(
      format.marginLeft, format.marginTop, format.marginRight, format.marginBottom),
    theme: themeData,
    buildBackground: (pw.Context context) {
      if (bgImage == null) return pw.SizedBox();
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
                    decoration: const pw.BoxDecoration(
                      shape: pw.BoxShape.rectangle,
                    ),
                    child: pw.Image(
                      bgImage,
                      width: 550,
                      fit: pw.BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}