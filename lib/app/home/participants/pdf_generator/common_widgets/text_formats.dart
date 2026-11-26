import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:enreda_empresas/app/utils/markup_text.dart';
import 'doc_theme.dart' show markupStrongFont, markupStrongItalicFont;

const PdfColor grey = PdfColor.fromInt(0xFF535A5F);
const PdfColor black = PdfColor.fromInt(0xF44494B);
const PdfColor white = PdfColor.fromInt(0xFFFFFFFF);
const PdfColor primary900 = PdfColor.fromInt(0xFF054D5E);

// ---------------------------------------------------------------------------
// Inline formatting (**bold**, *italic*) support
// ---------------------------------------------------------------------------

pw.TextStyle _markupRunStyle(pw.TextStyle base, MarkupStyle m) {
  pw.TextStyle s = base;
  if (m.italic) s = s.copyWith(fontStyle: pw.FontStyle.italic);
  if (m.bold) {
    if (base.fontWeight == pw.FontWeight.bold && markupStrongFont != null) {
      // Content is already drawn with the theme's bold font: use a heavier one.
      s = s.copyWith(
        fontBold: markupStrongFont,
        fontBoldItalic: markupStrongItalicFont ?? markupStrongFont,
      );
    } else {
      s = s.copyWith(fontWeight: pw.FontWeight.bold);
    }
  }
  return s;
}

pw.Widget _markupRichText(
  List<StyledChar> chars, {
  required pw.TextStyle style,
  pw.TextAlign? textAlign,
  double textScaleFactor = 0.8,
  pw.TextOverflow? overflow,
}) {
  return pw.RichText(
    textAlign: textAlign,
    textScaleFactor: textScaleFactor,
    overflow: overflow,
    text: pw.TextSpan(
      style: style,
      children: [
        for (final run in buildRuns(chars))
          pw.TextSpan(text: run.text, style: _markupRunStyle(style, run.style)),
      ],
    ),
  );
}

/// Drop-in replacement for `pw.Text(content, ...)` that renders inline
/// formatting. Texts without formatting (all reports written before this
/// feature) take exactly the same `pw.Text` path as before.
pw.Widget markupText(
  String content, {
  required pw.TextStyle style,
  pw.TextAlign? textAlign,
  double textScaleFactor = 0.8,
  pw.TextOverflow? overflow,
}) {
  if (mightContainMarkup(content)) {
    final parsed = parseMarkup(content);
    if (parsed.hasFormatting) {
      return _markupRichText(parsed.chars,
          style: style,
          textAlign: textAlign,
          textScaleFactor: textScaleFactor,
          overflow: overflow);
    }
    content = parsed.visibleText;
  }
  return pw.Text(content,
      textScaleFactor: textScaleFactor,
      textAlign: textAlign,
      overflow: overflow,
      style: style);
}

/// Formatted counterpart of the chunking done in [customItemPageSafe].
List<pw.Widget> _markupChunks(
  ParsedMarkup parsed, {
  required pw.TextStyle style,
  required int maxChars,
}) {
  final List<pw.Widget> widgets = [];
  final List<List<StyledChar>> lines = [[]];
  for (final c in parsed.chars) {
    if (c.char == '\n') {
      lines.add([]);
    } else {
      lines.last.add(c);
    }
  }
  for (var line in lines) {
    int a = 0, b = line.length;
    while (a < b && line[a].isWhitespace) a++;
    while (b > a && line[b - 1].isWhitespace) b--;
    var remaining = line.sublist(a, b);
    while (remaining.isNotEmpty) {
      if (remaining.length <= maxChars) {
        widgets.add(_markupRichText(remaining,
            style: style, textAlign: pw.TextAlign.justify));
        break;
      }
      int breakPoint = -1;
      for (int i = maxChars; i > 0; i--) {
        if (remaining[i].char == ' ') {
          breakPoint = i;
          break;
        }
      }
      if (breakPoint <= 0) breakPoint = maxChars;
      widgets.add(_markupRichText(remaining.sublist(0, breakPoint),
          style: style, textAlign: pw.TextAlign.justify));
      remaining = remaining.sublist(breakPoint);
      int k = 0;
      while (k < remaining.length && remaining[k].isWhitespace) k++;
      remaining = remaining.sublist(k);
    }
  }
  return widgets;
}

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

  if (mightContainMarkup(content)) {
    final parsed = parseMarkup(content);
    if (parsed.hasFormatting) {
      widgets.addAll(_markupChunks(parsed,
          style: contentStyle, maxChars: _maxCharsPerChunk));
      return widgets;
    }
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
                        child: markupText(content1,
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
                        child: markupText(content2,
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
          markupText(content,
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
          markupText(content,
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