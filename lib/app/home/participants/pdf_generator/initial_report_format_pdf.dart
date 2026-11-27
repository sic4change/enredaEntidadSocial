import 'dart:async';
import 'dart:typed_data';

import 'package:enreda_empresas/app/home/participants/pdf_generator/cv_print/data.dart';
import 'package:enreda_empresas/app/models/initialReport.dart';
import 'package:enreda_empresas/app/models/languageReport.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'common_widgets/bottom_signatures.dart';
import 'common_widgets/doc_theme.dart';
import 'common_widgets/report_sections.dart';

const PdfColor grey = PdfColor.fromInt(0xFF535A5F);
const PdfColor black = PdfColor.fromInt(0xF44494B);
const PdfColor white = PdfColor.fromInt(0xFFFFFFFF);
const PdfColor primary900 = PdfColor.fromInt(0xFF054D5E);
final DateFormat formatter = DateFormat('dd/MM/yyyy');


Future<Uint8List> generateInitialReportFile(
    PdfPageFormat format,
    CustomData data,
    UserEnreda user,
    InitialReport initialReport,
    ) async {
  final bool isReopening = initialReport.reopeningMotive != null && initialReport.reopeningMotive!.trim().isNotEmpty;
  final doc = pw.Document(title: isReopening ? 'Informe de reapertura' : StringConst.INITIAL_REPORT);

  format = format.applyMargin(
      left: 2.0 * PdfPageFormat.cm,
      top: 3.0 * PdfPageFormat.cm,
      right: 2.0 * PdfPageFormat.cm,
      bottom: 0.0 * PdfPageFormat.cm);

  final int isMdm = StringConst.getSubsidyIndex(initialReport.subsidy);
  print('isMdm: $isMdm');

  final pageTheme = await MyPageTheme(format, isMdm);
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  int inYears(int days) {
    if (days < 1) return 0;

    return days~/365;
  }

  doc.addPage(
    pw.MultiPage(
      pageTheme: pageTheme,
      footer: (pw.Context context) {
        return pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 2),
              child: pw.Text(
                  StringConst.INFORMS_CONDITIONS,
                  textScaleFactor: 0.6,
                  style: pw.Theme.of(context)
                      .defaultTextStyle
                      .copyWith(color: PdfColors.grey))),
            pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 2),
              child: pw.Text(
                  'Pág. ${context.pageNumber} de ${context.pagesCount}',
                  textScaleFactor: 0.8,
                  style: pw.Theme.of(context)
                      .defaultTextStyle
                      .copyWith(color: PdfColors.grey)))
          ]
        ); 
      },
      build: (pw.Context context) {
        final r = initialReport;
        String d(DateTime? date) => formatDate(formatter, date);
        final bool tempWithDate = r.adminTemp == 'Inicial' || r.adminTemp == 'Temporal';
        final bool withHome = r.ownershipType == 'Con hogar';

        return [
        pw.Text(
          isReopening
              ? 'Informe de reapertura de ${user.firstName} ${user.lastName}'
              : 'Informe inicial de ${user.firstName} ${user.lastName}',
          textAlign: pw.TextAlign.center,
          style: pw.Theme.of(context)
              .defaultTextStyle
              .copyWith(fontWeight: pw.FontWeight.bold, fontSize: 16, color: primary900)
        ),
        pw.SizedBox(height: 30),
        ...reportSameLine(title: 'Nombre y apellidos', content: '${user.firstName ?? ''} ${user.lastName ?? ''}'),
        ...reportSameLine(title: 'Fecha de nacimiento', content: d(user.birthday)),
        ...reportSameLine(title: 'Edad', content: user.birthday == null ? '' : '${inYears(DateTime.now().difference(user.birthday!).inDays).toString()} años'),
        ...reportSameLine(title: 'Nacionalidad', content: user.nationality),
        ...reportSameLine(title: 'Género', content: user.gender),
        ...reportSameLine(title: StringConst.DNI_PARTICIPANT, content: r.dniParticipant),
        pw.SizedBox(height: 7),
        ...reportField(context, title: 'Subvención a la que el/la participante está imputado/a', content: r.subsidy, spaceAfter: 12),
        ...reportField(context, title: 'Técnico/a de referencia', content: r.techPersonName),

        ...buildNumberedSections([
          ReportSection(
            title: 'Itinerario en España',
            content: [
              ...reportField(context, title: 'Orientaciones:', content: r.orientation1),
              ...reportRow(context, title1: 'Fecha de llegada a España', content1: d(r.arriveDate), title2: 'Recursos de acogida', content2: r.receptionResources),
              ...reportField(context, title: StringConst.INITIAL_EXTERNAL_RESOURCES, content: r.administrativeExternalResources),
            ],
            subsections: [
              ReportSection(
                title: StringConst.INITIAL_TITLE_1_1_ADMINISTRATIVE_SITUATION,
                content: [
                  ...reportField(context, title: StringConst.INITIAL_STATE, content: r.adminState),
                  if (r.adminState == 'Sin tramitar')
                    ...reportField(context, title: 'Sin tramitar', content: r.adminNoThrough)
                  else if (r.adminState == 'En trámite')
                    ...reportRow(context, title1: 'Fecha de solicitud', content1: d(r.adminDateAsk), title2: 'Fecha de resolución', content2: d(r.adminDateResolution))
                  else
                    ...reportField(context, title: StringConst.INITIAL_DATE_CONCESSION, content: d(r.adminDateConcession)),
                  ...reportRow(context, title1: StringConst.INITIAL_TEMP, content1: r.adminTemp, title2: 'Fecha de resolución', content2: tempWithDate ? d(r.adminDateRenovation) : ''),
                  ...reportRow(context, title1: 'Tipo de residencia', content1: r.adminResidenceType, title2: StringConst.INITIAL_JURIDIC_FIGURE, content2: r.adminJuridicFigure),
                  if (r.adminJuridicFigure == 'Otros')
                    ...reportField(context, title: StringConst.INITIAL_OTHERS, content: r.adminOther),
                ],
              ),
            ],
          ),
          ReportSection(
            title: 'Situación Sanitaria',
            content: [
              ...reportField(context, title: StringConst.INITIAL_OBSERVATIONS, content: r.orientation2),
              ...reportRow(context, title1: 'Tarjeta sanitaria', content1: r.healthCard, title2: 'Fecha de caducidad', content2: d(r.expirationDate)),
              ...reportField(context, title: 'Medicación/Tratamiento', content: r.medication),
            ],
            subsections: [
              ReportSection(
                title: 'Salud Mental',
                content: [
                  ...reportField(context, title: StringConst.INITIAL_OBSERVATIONS, content: r.orientation2_1),
                  ...reportRow(context, title1: 'Derivación interna al área psicosocial', content1: r.psychosocialDerivationLegal, title2: StringConst.INITIAL_DERIVATION_DATE, content2: d(r.psychosocialDerivationDate)),
                  ...reportField(context, title: StringConst.INITIAL_MOTIVE, content: r.psychosocialDerivationMotive),
                ],
              ),
              ReportSection(
                title: 'Discapacidad',
                content: [
                  ...reportField(context, title: StringConst.INITIAL_OBSERVATIONS, content: r.orientation2_2),
                  ...reportField(context, title: 'Estado', content: r.disabilityState),
                  if (r.disabilityState == 'Concedida')
                    ...reportRow(context, title1: 'Concedida', content1: r.granted, title2: 'Fecha', content2: d(r.revisionDate)),
                  ...reportField(context, title: 'Profesional de referencia', content: r.referenceProfessionalDisability),
                  ...reportRow(context, title1: 'Grado de discapacidad', content1: r.disabilityGrade, title2: 'Tipo de discapacidad', content2: r.disabilityType),
                ],
              ),
              ReportSection(
                title: 'Dependencia',
                content: [
                  ...reportField(context, title: StringConst.INITIAL_OBSERVATIONS, content: r.orientation2_3),
                  ...reportRow(context, title1: 'Estado', content1: r.dependenceState, title2: 'Profesional de referencia', content2: r.referenceProfessionalDependence),
                  ...reportField(context, title: 'Grado de dependencia', content: r.dependenceGrade),
                ],
              ),
              ReportSection(
                title: 'Adicciones',
                content: [
                  ...reportField(context, title: StringConst.INITIAL_OBSERVATIONS, content: r.orientation2_4),
                  ...reportRow(context, title1: 'Derivación externa', content1: r.externalDerivation, title2: StringConst.INITIAL_MOTIVE, content2: r.motive),
                ],
              ),
            ],
          ),
          ReportSection(
            title: 'Situación legal',
            content: [
              ...reportField(context, title: StringConst.INITIAL_OBSERVATIONS, content: r.orientation3),
              ...reportRow(context, title1: 'Derivación interna', content1: r.internalDerivationLegal, title2: StringConst.INITIAL_DERIVATION_DATE, content2: d(r.internalDerivationDate)),
              ...reportField(context, title: StringConst.INITIAL_MOTIVE, content: r.internalDerivationMotive),
              ...reportRow(context, title1: 'Derivación externa', content1: r.externalDerivationLegal, title2: StringConst.INITIAL_DERIVATION_DATE, content2: d(r.externalDerivationDate)),
              ...reportField(context, title: StringConst.INITIAL_MOTIVE, content: r.externalDerivationMotive),
              ...reportField(context, title: 'Representación legal', content: r.legalRepresentation),
            ],
          ),
          ReportSection(
            title: 'Situación alojativa',
            content: [
              ...reportField(context, title: StringConst.INITIAL_OBSERVATIONS, content: r.orientation4),
              ...reportRow(context, title1: 'Situación alojativa', content1: r.ownershipType, title2: withHome ? 'Tipo de tenencia' : 'Situación sinhogarismo', content2: withHome ? r.ownershipTypeConcrete : r.homelessnessSituation),
              if (r.ownershipTypeConcrete == 'Otros')
                ...reportField(context, title: StringConst.INITIAL_OTHERS, content: r.ownershipTypeOpen),
              if (r.homelessnessSituation == 'Otros')
                ...reportField(context, title: StringConst.INITIAL_OTHERS, content: r.homelessnessSituationOpen),
              ...reportField(context, title: 'Datos de contacto del recurso alojativo', content: r.centerContact),
              ...reportField(context, title: StringConst.INITIAL_LOCATION, content: r.location),
              ...reportHeading(StringConst.HABITABILITY_CONDITIONS, reportBulletList(r.hostingObservations, color: grey)),
            ],
          ),
          ReportSection(
            title: 'Redes de apoyo',
            content: [
              ...reportField(context, title: StringConst.INITIAL_OBSERVATIONS, content: r.orientation5),
              ...reportField(context, title: 'Redes de apoyo natural', content: r.informationNetworks),
              ...reportRow(context, title1: 'Redes de apoyo institucional', content1: r.institutionNetworks, title2: 'Conciliación familiar', content2: r.familyConciliation),
            ],
          ),
          ReportSection(
            title: 'Idiomas',
            content: [
              ...reportField(context, title: StringConst.INITIAL_OBSERVATIONS, content: r.orientation7),
              for (final LanguageReport language in r.languages ?? []) ...[
                ...reportRow(context, title1: StringConst.INITIAL_LANGUAGE, content1: language.name, title2: StringConst.INITIAL_LANGUAGE_LEVEL, content2: language.level),
                ...reportField(context, title: StringConst.INITIAL_LANGUAGE_ACCREDITATION, content: language.accreditation),
              ],
            ],
          ),
          ReportSection(
            title: 'Atención social integral',
            content: [
              ...reportField(context, title: StringConst.INITIAL_OBSERVATIONS, content: r.orientation9),
              ...reportField(context, title: 'Centro y TS de referencia', content: r.centerTSReference),
              ...reportField(context, title: 'Destinataria de subvención y/o programa de apoyo', content: r.subsidyBeneficiary),
              if (r.subsidyBeneficiary == 'Si')
                ...reportField(context, title: 'Nombre/tipo', content: r.subsidyName),
              ...reportField(context, title: 'Certificado de Exclusión Social', content: r.socialExclusionCertificate),
              if (r.socialExclusionCertificate == 'Si')
                ...reportRow(context, title1: StringConst.INITIAL_DATE, content1: d(r.socialExclusionCertificateDate), title2: 'Observaciones sobre el certificado', content2: r.socialExclusionCertificateObservations),
            ],
          ),
          ReportSection(
            title: 'Situación de Vulnerabilidad',
            content: [
              ...reportField(context, title: StringConst.INITIAL_OBSERVATIONS, content: r.orientation12),
              ...reportBulletList(r.vulnerabilityOptions, color: grey),
            ],
          ),
          ReportSection(
            title: 'Itinerario formativo laboral',
            content: [
              ...reportField(context, title: StringConst.INITIAL_OBSERVATIONS, content: r.orientation13),
              ...reportRow(context, title1: 'Nivel educativo', content1: r.educationLevel, title2: 'Situación laboral inicial', content2: r.laborSituation),
              ...reportField(context, title: StringConst.HOMOLOGATION, content: r.homologation),
              if (r.laborSituation == 'Ocupada cuenta propia' || r.laborSituation == 'Ocupada cuenta ajena') ...[
                ...reportRow(context, title1: StringConst.INITIAL_TEMP, content1: r.tempLabor, title2: 'Tipo jornada', content2: r.workingDayLabor),
                ...reportField(context, title: StringConst.LABOR_OTHER_CONSIDERATIONS, content: r.laborOtherConsiderations),
              ],
            ],
            subsections: [
              ReportSection(
                title: StringConst.INITIAL_TITLE_9_3_TRAJECTORY,
                content: [
                  ...reportField(context, title: StringConst.INITIAL_OBSERVATIONS, content: r.orientation13_2),
                  ...reportField(context, title: 'Competencias (competencias específicas, competencias prelaborales y competencias digitales)', content: r.competencies),
                  ...reportField(context, title: 'Contextualización del territorio', content: r.contextualization),
                  ...reportField(context, title: 'Conexión del entorno', content: r.connexion),
                ],
              ),
              ReportSection(
                title: StringConst.INITIAL_TITLE_9_4_EXPECTATIONS,
                content: [
                  ...reportField(context, title: 'Corto plazo', content: r.shortTerm),
                  ...reportField(context, title: 'Medio plazo', content: r.mediumTerm),
                  ...reportField(context, title: 'Largo plazo', content: r.longTerm),
                ],
              ),
            ],
          ),
          ReportSection(
            title: StringConst.CLOSURE_TITLE_10,
            enabled: isReopening,
            content: [
              ...reportField(context, title: StringConst.INITIAL_OBSERVATIONS, content: r.orientation10),
              ...reportRow(context, title1: StringConst.CLOSURE_CLOSE_MOTIVE, content1: r.motiveClose, title2: StringConst.CLOSURE_CLOSE_MOTIVE_DETAIL, content2: r.motiveCloseDetail),
              ...reportField(context, title: 'Fecha de cierre anterior', content: d(r.closeDate)),
            ],
          ),
          ReportSection(
            title: StringConst.REOPENING_TITLE_11,
            enabled: isReopening,
            content: [
              ...reportField(context, title: 'Motivo de la reapertura', content: r.reopeningMotive),
            ],
          ),
        ]),
        pw.SizedBox(height: 12),
        BottomSignatures(),
        ];
      }
    )
  );
  return doc.save();
}

pw.Widget SpaceH5(){
  return pw.SizedBox(height: 5);
}







