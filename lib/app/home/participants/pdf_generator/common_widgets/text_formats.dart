import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const PdfColor grey = PdfColor.fromInt(0xFF535A5F);
const PdfColor black = PdfColor.fromInt(0xF44494B);
const PdfColor white = PdfColor.fromInt(0xFFFFFFFF);
const PdfColor primary900 = PdfColor.fromInt(0xFF054D5E);

/// Page-safe replacement for [CustomItem].
///
/// Returns a [List] of widgets that must be spread (`...`) into a
/// `MultiPage.build` list.  Splitting the title and content into separate
/// top-level children lets `MultiPage` place page breaks between them, and
/// chunking long content prevents [TooManyPagesException] when a single
/// [pw.Column] would be taller than one full page.
List<pw.Widget> customItemPageSafe(
  pw.Context context, {
  required String title,
  required String content,
}) {
  // Approximate character limit per chunk so the wrapped text never exceeds
  // a full A4 page at textScaleFactor 0.8 (~8 pt effective font size).
  // 600 chars ≈ 6-7 wrapped lines ≈ ~70 pt — well within any single page.
  const int _maxCharsPerChunk = 600;

  final pw.TextStyle titleStyle = pw.Theme.of(context)
      .defaultTextStyle
      .copyWith(fontWeight: pw.FontWeight.normal, color: black);
  final pw.TextStyle contentStyle = pw.Theme.of(context)
      .defaultTextStyle
      .copyWith(fontWeight: pw.FontWeight.bold, color: black);

  final List<pw.Widget> widgets = [
    pw.Text(title, textScaleFactor: 0.8, style: titleStyle),
  ];

  if (content.isEmpty) {
    widgets.add(pw.SizedBox(height: 2));
    return widgets;
  }

  // Split on newlines first so paragraph breaks are preserved.
  final rawParagraphs = content.split('\n');

  for (final paragraph in rawParagraphs) {
    if (paragraph.trim().isEmpty) continue;

    // Further split any single paragraph that is still too long.
    String remaining = paragraph.trim();
    while (remaining.isNotEmpty) {
      if (remaining.length <= _maxCharsPerChunk) {
        widgets.add(pw.Text(
          remaining,
          textScaleFactor: 0.8,
          textAlign: pw.TextAlign.justify,
          style: contentStyle,
        ));
        break;
      }
      // Break at the last word boundary within the limit.
      int breakPoint = remaining.lastIndexOf(' ', _maxCharsPerChunk);
      if (breakPoint <= 0) breakPoint = _maxCharsPerChunk;
      widgets.add(pw.Text(
        remaining.substring(0, breakPoint),
        textScaleFactor: 0.8,
        textAlign: pw.TextAlign.justify,
        style: contentStyle,
      ));
      remaining = remaining.substring(breakPoint).trimLeft();
    }
  }

  return widgets;
}

class CustomRow extends pw.StatelessWidget {
  CustomRow({
    required this.title1,
    required this.title2,
    required this.content1,
    required this.content2,
  });
  final String title1;
  final String content1;
  final String title2;
  final String content2;
  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: <pw.Widget>[
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.Text(title1,
                          textScaleFactor: 0.8,
                          overflow: pw.TextOverflow.span,
                          style: pw.Theme.of(context)
                              .defaultTextStyle
                              .copyWith(fontWeight: pw.FontWeight.normal, color: black)
                                ),
                      pw.SizedBox(width: 170),
                      pw.Container(
                        width: 220,
                        child: pw.Text(content1,
                          textAlign: pw.TextAlign.justify,
                          textScaleFactor: 0.8,
                          overflow: pw.TextOverflow.span,
                          style: pw.Theme.of(context)
                              .defaultTextStyle
                              .copyWith(fontWeight: pw.FontWeight.bold, color: black)
                        )
                      ), 
                    ]
                ),
                pw.SizedBox(
                  width: 50,
                ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.Text(title2,
                          textScaleFactor: 0.8,
                          style: pw.Theme.of(context)
                              .defaultTextStyle
                              .copyWith(fontWeight: pw.FontWeight.normal, color: black)),
                      pw.Container(
                        width: 220,
                        child: pw.Text(content2,
                          textAlign: pw.TextAlign.justify,
                          textScaleFactor: 0.8,
                          overflow: pw.TextOverflow.span,
                          style: pw.Theme.of(context)
                              .defaultTextStyle
                              .copyWith(fontWeight: pw.FontWeight.bold, color: black)
                        )
                      ), 
                    ]
                ),
              ]
          ),
        ]
    );
  }
}

class CustomItem extends pw.StatelessWidget {
  CustomItem({
    required this.title,
    required this.content,
  });
  final String title;
  final String content;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              textScaleFactor: 0.8,
              style: pw.Theme.of(context)
                  .defaultTextStyle
                  .copyWith(fontWeight: pw.FontWeight.normal, color: black)
          ),
          pw.Text(content,
              textScaleFactor: 0.8,
              textAlign: pw.TextAlign.justify,
              style: pw.Theme.of(context)
                  .defaultTextStyle
                  .copyWith(fontWeight: pw.FontWeight.bold, color: black)
          )
        ]
    );
  }
}

class CustomItemSameLine extends pw.StatelessWidget {
  CustomItemSameLine({
    required this.title,
    required this.content,
  });
  final String title;
  final String content;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('$title: ',
              textScaleFactor: 0.8,
              style: pw.Theme.of(context)
                  .defaultTextStyle
                  .copyWith(fontWeight: pw.FontWeight.normal, color: black)
          ),
          pw.Text(content,
              textScaleFactor: 0.8,
              textAlign: pw.TextAlign.justify,
              style: pw.Theme.of(context)
                  .defaultTextStyle
                  .copyWith(fontWeight: pw.FontWeight.bold, color: black)
          )
        ]
    );
  }
}

class SectionTitle extends pw.StatelessWidget {
  SectionTitle({
    required this.title,
  });
  final String title;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 30),
          pw.Text(title,
              textScaleFactor: 1,
              style: pw.Theme.of(context)
                  .defaultTextStyle
                  .copyWith(fontWeight: pw.FontWeight.bold, color: primary900)
          ),
          pw.SizedBox(height: 5),
        ]
    );
  }
}

class SubSectionTitle extends pw.StatelessWidget {
  SubSectionTitle({
    required this.title,
  });
  final String title;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 20),
          pw.Text(title,
              textScaleFactor: 0.8,
              style: pw.Theme.of(context)
                  .defaultTextStyle
                  .copyWith(fontWeight: pw.FontWeight.bold, color: primary900)
          ),
          pw.SizedBox(height: 5),
        ]
    );
  }
}

class BlockSimpleList extends pw.StatelessWidget {
  BlockSimpleList({
    this.title,
    this.color
  });

  final String? title;
  final PdfColor? color;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Container(
                  width: 3,
                  height: 3,
                  margin: const pw.EdgeInsets.only(top: 5.5, left: 2, right: 5),
                  decoration: const pw.BoxDecoration(
                    color: grey,
                    shape: pw.BoxShape.circle,
                  ),
                ),
                title != null ? pw.Expanded(
                  child:
                  pw.Text(
                      title!,
                      textScaleFactor: 0.8,
                      style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(fontWeight: pw.FontWeight.normal, color: color)),
                ) : pw.Container()
              ]),
          pw.SizedBox(height: 5),
        ]);
  }
}