import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'text_formats.dart';

/// Helpers for the social reports PDFs (initial, follow, closure, derivation).
///
/// Rules:
///  * A field (title + content) is only printed when its content is filled.
///  * A numbered section / subsection is only printed when at least one of
///    its fields is filled. When a section is skipped, the following ones are
///    renumbered so the numbering stays consecutive.
///
/// Every helper returns a `List<pw.Widget>` (empty when there is nothing to
/// print) that must be spread (`...`) into the `MultiPage.build` list.

bool isFilled(String? value) => value != null && value.trim().isNotEmpty;

String formatDate(DateFormat formatter, DateTime? date) =>
    date == null ? '' : formatter.format(date);

/// Single field: title on one line, content below. Empty -> nothing.
List<pw.Widget> reportField(
  pw.Context context, {
  required String title,
  required String? content,
  double spaceAfter = 5,
}) {
  if (!isFilled(content)) return const [];
  return [
    ...customItemPageSafe(context, title: title, content: content!.trim()),
    pw.SizedBox(height: spaceAfter),
  ];
}

/// Two fields side by side. Only the filled ones are printed; if none is
/// filled nothing is printed.
List<pw.Widget> reportRow(
  pw.Context context, {
  required String title1,
  required String? content1,
  required String title2,
  required String? content2,
  double spaceAfter = 5,
}) {
  final bool has1 = isFilled(content1);
  final bool has2 = isFilled(content2) && title2.trim().isNotEmpty;
  if (!has1 && !has2) return const [];
  if (has1 && has2) {
    return [
      CustomRow(
        title1: title1,
        content1: content1!.trim(),
        title2: title2,
        content2: content2!.trim(),
      ),
      pw.SizedBox(height: spaceAfter),
    ];
  }
  return has1
      ? reportField(context, title: title1, content: content1, spaceAfter: spaceAfter)
      : reportField(context, title: title2, content: content2, spaceAfter: spaceAfter);
}

/// "Title: content" on the same line. Empty -> nothing.
List<pw.Widget> reportSameLine({
  required String title,
  required String? content,
  double spaceAfter = 5,
}) {
  if (!isFilled(content)) return const [];
  return [
    CustomItemSameLine(title: title, content: content!.trim()),
    pw.SizedBox(height: spaceAfter),
  ];
}

/// Bullet list. Empty values are skipped.
List<pw.Widget> reportBulletList(List<String>? items, {required PdfColor color}) {
  return [
    for (final item in items ?? const <String>[])
      if (isFilled(item)) BlockSimpleList(title: item, color: color),
  ];
}

/// Unnumbered heading (e.g. "Formaciones", "Empleo") followed by its fields.
/// If none of the fields is filled, neither the heading nor the fields are
/// printed.
List<pw.Widget> reportHeading(String title, List<pw.Widget> content) {
  if (content.isEmpty) return const [];
  return [SubSectionTitle(title: title), ...content];
}

/// A numbered section of a report. [title] may include a hard-coded number
/// prefix ("2.1 Salud Mental"); it is stripped and replaced by the computed
/// number.
class ReportSection {
  ReportSection({
    required String title,
    this.content = const [],
    this.subsections = const [],
    this.enabled = true,
  }) : title = _stripNumber(title);

  final String title;
  final List<pw.Widget> content;
  final List<ReportSection> subsections;

  /// When false the section is not printed at all (e.g. derivation "allow"
  /// switches).
  final bool enabled;

  List<ReportSection> get _visibleSubsections =>
      subsections.where((s) => s.enabled && s.content.isNotEmpty).toList();

  bool get isVisible =>
      enabled && (content.isNotEmpty || _visibleSubsections.isNotEmpty);

  static String _stripNumber(String title) =>
      title.replaceFirst(RegExp(r'^\s*\d+(\.\d+)*\.?\s+'), '').trim();
}

/// Builds the numbered sections, skipping the empty ones and keeping the
/// numbering consecutive (sections and subsections).
List<pw.Widget> buildNumberedSections(List<ReportSection> sections) {
  final List<pw.Widget> widgets = [];
  int sectionNumber = 0;
  for (final section in sections) {
    if (!section.isVisible) continue;
    sectionNumber++;
    widgets.add(SectionTitle(title: '$sectionNumber. ${section.title}'));
    widgets.addAll(section.content);
    int subNumber = 0;
    for (final sub in section._visibleSubsections) {
      subNumber++;
      widgets.add(SubSectionTitle(title: '$sectionNumber.$subNumber ${sub.title}'));
      widgets.addAll(sub.content);
    }
  }
  return widgets;
}
