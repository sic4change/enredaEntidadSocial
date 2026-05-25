import 'package:enreda_empresas/app/models/program.dart';
import 'package:enreda_empresas/app/models/sesion.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Generates the single-page PDF summary for a Sesión export and triggers
/// the platform print/share dialog (`Printing.layoutPdf`) so the user can
/// save it locally, print, or attach to an email.
///
/// Inputs are pre-resolved (names + program labels) so this file is
/// completely synchronous-friendly and doesn't touch Firestore. All caches
/// are populated by the caller before invoking [generate].
///
/// PdfColor literals are exempt from the §6 hardcoded-hex rule — PDF
/// rendering can't consume Material theme tokens, so the colour values are
/// inlined here matching `AppColors.*`.
class SesionExportPdf {
  static const PdfColor _primary900 = PdfColor.fromInt(0xFF054D5E);
  static const PdfColor _grey = PdfColor.fromInt(0xFF535A5F);
  static const PdfColor _greyLight = PdfColor.fromInt(0xFFBABAC7);
  static const PdfColor _yellow = PdfColor.fromInt(0xFFFFCB77);
  static const PdfColor _white = PdfColor.fromInt(0xFFFFFFFF);
  static const PdfColor _altWhite = PdfColor.fromInt(0xFFFCFCFC);

  /// Builds and presents the PDF. Throws on PDF build failure; the caller
  /// is responsible for surfacing errors to the user.
  static Future<void> generate({
    required Sesion sesion,
    required SocialEntity socialEntity,
    required Map<String, UserEnreda> participantsById,
    required Map<String, Program> subvencionesById,
  }) async {
    final doc = pw.Document(
      title: 'Sesion ${sesion.title ?? ''}'.trim(),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 40, 40, 40),
        build: (context) => [
          _buildHeader(sesion, socialEntity),
          pw.SizedBox(height: 18),
          _buildSummaryCard(sesion),
          pw.SizedBox(height: 18),
          _buildBody(sesion),
          pw.SizedBox(height: 18),
          _buildParticipantsTable(sesion, participantsById, subvencionesById),
          pw.SizedBox(height: 30),
          _buildFooter(socialEntity),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => doc.save());
  }

  // ── Sections ────────────────────────────────────────────────────────────

  static pw.Widget _buildHeader(Sesion s, SocialEntity entity) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          entity.name,
          style: pw.TextStyle(color: _grey, fontSize: 10),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          _titleFor(s),
          style: pw.TextStyle(
            color: _primary900,
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '${_modalityLabel(s.modality)}  ·  ${_dateLabel(s.scheduledAt)}',
          style: pw.TextStyle(color: _primary900, fontSize: 12),
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryCard(Sesion s) {
    final rows = <pw.Widget>[];
    void row(String label, String value) {
      rows.add(
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          child: pw.RichText(
            text: pw.TextSpan(
              style: pw.TextStyle(color: _primary900, fontSize: 11),
              children: [
                pw.TextSpan(
                  text: '$label: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.TextSpan(text: value),
              ],
            ),
          ),
        ),
      );
    }

    row(StringConst.SESION_FIELD_TIPO_LABEL, _modalityLabel(s.modality));
    row(StringConst.SESION_FIELD_SESION_SUBLABEL, _sessionTypeLabel(s.sessionType));
    if (s.lugar != null && s.lugar!.trim().isNotEmpty) {
      row(StringConst.SESION_FIELD_LUGAR_LABEL, s.lugar!);
    }
    if (s.duracion != null && s.duracion!.trim().isNotEmpty) {
      row(StringConst.SESION_FIELD_DURACION_LABEL, s.duracion!);
    }
    row(
      StringConst.SESION_EXPORT_CONVOCADOS,
      '${s.invitedParticipants.length}',
    );

    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _altWhite,
        border: pw.Border.all(color: _greyLight),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }

  static pw.Widget _buildBody(Sesion s) {
    pw.Widget section(String header, String? body, String fallback) {
      final value = (body == null || body.trim().isEmpty) ? fallback : body;
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 12),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              header,
              style: pw.TextStyle(
                color: _primary900,
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(color: _grey, fontSize: 11, lineSpacing: 2),
            ),
          ],
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        section(
          StringConst.SESION_DETAIL_DESARROLLO,
          s.description,
          StringConst.SESION_EXPORT_NO_DESARROLLO,
        ),
        section(
          StringConst.SESION_DETAIL_OBSERVACIONES,
          s.observations,
          StringConst.SESION_EXPORT_NO_OBSERVACIONES,
        ),
      ],
    );
  }

  static pw.Widget _buildParticipantsTable(
    Sesion s,
    Map<String, UserEnreda> participantsById,
    Map<String, Program> subvencionesById,
  ) {
    final attended = s.attendedParticipants.toSet();
    final absent = s.absentParticipants.toSet();

    String statusFor(String id) {
      if (attended.contains(id)) return StringConst.SESION_EXPORT_ATTENDED;
      if (absent.contains(id)) return StringConst.SESION_EXPORT_ABSENT;
      return StringConst.SESION_EXPORT_UNCONFIRMED;
    }

    String nameFor(String id) {
      final u = participantsById[id];
      if (u == null) return id;
      final n = '${u.firstName ?? ''} ${u.lastName ?? ''}'.trim();
      return n.isEmpty ? id : n;
    }

    String subvencionFor(String id) {
      final pid = s.participantSubvenciones[id];
      if (pid == null) return StringConst.SESION_EXPORT_SIN_ASIGNAR;
      final program = subvencionesById[pid];
      return program?.name ?? pid;
    }

    final headerStyle = pw.TextStyle(
      color: _primary900,
      fontSize: 11,
      fontWeight: pw.FontWeight.bold,
    );
    final cellStyle = pw.TextStyle(color: _grey, fontSize: 10);

    pw.Widget headerCell(String text) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          color: _yellow,
          child: pw.Text(text, style: headerStyle),
        );
    pw.Widget bodyCell(String text) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: pw.Text(text, style: cellStyle),
        );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          StringConst.SESION_EXPORT_LISTADO_PARTICIPANTES,
          style: pw.TextStyle(
            color: _primary900,
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: _greyLight, width: 0.5),
          columnWidths: const {
            0: pw.FlexColumnWidth(3),
            1: pw.FlexColumnWidth(2),
            2: pw.FlexColumnWidth(3),
          },
          children: [
            pw.TableRow(children: [
              headerCell(StringConst.SESION_REVISION_PARTICIPANTES
                  .replaceAll(':', '')),
              headerCell(StringConst.SESION_EXPORT_ASISTENCIA),
              headerCell(StringConst.SESION_EXPORT_SUBVENCION),
            ]),
            for (final id in s.invitedParticipants)
              pw.TableRow(children: [
                bodyCell(nameFor(id)),
                bodyCell(statusFor(id)),
                bodyCell(subvencionFor(id)),
              ]),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(SocialEntity entity) {
    final now = DateTime.now();
    String stamp;
    try {
      stamp = DateFormat("d 'de' MMMM yyyy 'a las' HH:mm", 'es_ES').format(now);
    } catch (_) {
      stamp = DateFormat('yyyy-MM-dd HH:mm').format(now);
    }
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _greyLight, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '${StringConst.SESION_EXPORT_GENERADO_POR} · ${entity.name}',
            style: pw.TextStyle(color: _grey, fontSize: 9),
          ),
          pw.Text(
            stamp,
            style: pw.TextStyle(color: _grey, fontSize: 9),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  static String _titleFor(Sesion s) {
    if (s.title != null && s.title!.trim().isNotEmpty) return s.title!;
    return s.sessionType == SesionType.grupal
        ? StringConst.SESION_GRUPAL
        : StringConst.SESION_INDIVIDUAL;
  }

  static String _modalityLabel(String m) {
    switch (m) {
      case SesionModality.online:
        return StringConst.SESION_ONLINE_LABEL;
      case SesionModality.blended:
        return StringConst.SESION_BLENDED_LABEL;
      case SesionModality.presencial:
      default:
        return StringConst.SESION_PRESENCIAL_LABEL;
    }
  }

  static String _sessionTypeLabel(String t) {
    return t == SesionType.grupal
        ? StringConst.SESION_GRUPAL
        : StringConst.SESION_INDIVIDUAL;
  }

  static String _dateLabel(DateTime d) {
    try {
      return DateFormat("d 'de' MMMM yyyy", 'es_ES').format(d);
    } catch (_) {
      return DateFormat('d MMMM yyyy').format(d);
    }
  }
}
