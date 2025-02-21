import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const PdfColor black = PdfColor.fromInt(0xF44494B);

class BottomSignatures extends pw.StatelessWidget {
  BottomSignatures(
    //   {
    // required this.title,
    // required this.content,}
  );
  // final String title;
  // final String content;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 50.0, left: 0.0, right: 50),
      child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text('Nombre del/a técnico/a de Enreda:\nEn ......................... a .................... de ....................\nFDO:',
                      textScaleFactor: 0.8,
                      style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(fontWeight: pw.FontWeight.bold, color: black)),
                ]
            ),
            /*pw.Column(
                children: [
                  pw.Text('FDO por participante',
                      textScaleFactor: 0.8,
                      style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(fontWeight: pw.FontWeight.bold, color: black)),
                  pw.Text('Observaciones',
                      textScaleFactor: 0.8,
                      style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(fontWeight: pw.FontWeight.bold, color: black)
                  ),
                ]
            )*/
          ]
      ),
    );
  }
}