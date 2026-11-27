import 'dart:async';
import 'dart:typed_data';

import 'package:enreda_empresas/app/home/participants/pdf_generator/cv_print/data.dart';
import 'package:enreda_empresas/app/models/followReport.dart';
import 'package:enreda_empresas/app/models/formationReport.dart';
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

Future<Uint8List> generateFollowReportFile(
    PdfPageFormat format,
    CustomData data,
    UserEnreda user,
    FollowReport followReport,
    ) async {
  final doc = pw.Document(title: StringConst.FOLLOW_REPORT);

  format = format.applyMargin(
      left: 2.0 * PdfPageFormat.cm,
      top: 3.0 * PdfPageFormat.cm,
      right: 2.0 * PdfPageFormat.cm,
      bottom: 0.0 * PdfPageFormat.cm);

  final int isMdm = StringConst.getSubsidyIndex(followReport.subsidy);
    print('isMdm: $isMdm');


  final pageTheme = await MyPageTheme(format, isMdm);
  final DateFormat formatter = DateFormat('yyyy-MM-dd');


  int inYears(int days) {
        if (days < 1) return 0;

        return days~/365;
  }

  final String? techLocation = await resolveTechLocation(followReport.techPerson);

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
        final r = followReport;
        String d(DateTime? date) => formatDate(formatter, date);
        const double gap = 12;
        List<pw.Widget> f(String title, String? content) =>
            reportField(context, title: title, content: content, spaceAfter: gap);
        List<pw.Widget> row(String title1, String? content1, String title2, String? content2) =>
            reportRow(context, title1: title1, content1: content1, title2: title2, content2: content2, spaceAfter: gap);
        final bool tempWithDate = r.adminTemp == 'Inicial' || r.adminTemp == 'Temporal';
        final bool withHome = r.ownershipType == 'Con hogar';

        return [
        pw.Text(
          'Informe de seguimiento de ${user.firstName} ${user.lastName}',
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
        ...f('Subvención a la que el/la participante está imputado/a', r.subsidy),
        ...f('Técnico/a de referencia', r.techPersonName),

        ...buildNumberedSections([
          ReportSection(
            title: 'Itinerario en España',
            content: [
              ...f('Orientaciones', r.orientation1),
              ...row('Fecha de llegada a España', d(r.arriveDate), 'Recursos de acogida', r.receptionResources),
              ...f(StringConst.INITIAL_EXTERNAL_RESOURCES, r.administrativeExternalResources),
            ],
            subsections: [
              ReportSection(
                title: StringConst.INITIAL_TITLE_1_1_ADMINISTRATIVE_SITUATION,
                content: [
                  ...f(StringConst.INITIAL_STATE, r.adminState),
                  if (r.adminState == 'Sin tramitar')
                    ...f('Sin tramitar', r.adminNoThrough)
                  else if (r.adminState == 'En trámite')
                    ...row('Fecha de solicitud', d(r.adminDateAsk), 'Fecha de resolución', d(r.adminDateResolution))
                  else
                    ...f(StringConst.INITIAL_DATE_CONCESSION, d(r.adminDateConcession)),
                  ...row(StringConst.INITIAL_TEMP, r.adminTemp, 'Fecha de resolución', tempWithDate ? d(r.adminDateRenovation) : ''),
                  ...row('Tipo de residencia', r.adminResidenceType, StringConst.INITIAL_JURIDIC_FIGURE, r.adminJuridicFigure),
                  if (r.adminJuridicFigure == 'Otros')
                    ...f(StringConst.INITIAL_OTHERS, r.adminOther),
                ],
              ),
            ],
          ),
          ReportSection(
            title: 'Situación Sanitaria',
            content: [
              ...f(StringConst.INITIAL_OBSERVATIONS, r.orientation2),
              ...row('Tarjeta sanitaria', r.healthCard, 'Fecha de caducidad', d(r.expirationDate)),
              ...f('Medicación/Tratamiento', r.medication),
            ],
            subsections: [
              ReportSection(
                title: 'Salud Mental',
                content: [
                  ...f(StringConst.INITIAL_OBSERVATIONS, r.orientation2_1),
                  ...row('Derivación interna al área psicosocial', r.psychosocialDerivationLegal, StringConst.INITIAL_DERIVATION_DATE, d(r.psychosocialDerivationDate)),
                  ...f(StringConst.INITIAL_MOTIVE, r.psychosocialDerivationMotive),
                ],
              ),
              ReportSection(
                title: 'Discapacidad',
                content: [
                  ...f(StringConst.INITIAL_OBSERVATIONS, r.orientation2_2),
                  ...f('Estado', r.disabilityState),
                  if (r.disabilityState == 'Concedida')
                    ...row('Concedida', r.granted, 'Fecha', d(r.revisionDate)),
                  ...f('Profesional de referencia', r.referenceProfessionalDisability),
                  ...row('Grado de discapacidad', r.disabilityGrade, 'Tipo de discapacidad', r.disabilityType),
                ],
              ),
              ReportSection(
                title: 'Dependencia',
                content: [
                  ...f(StringConst.INITIAL_OBSERVATIONS, r.orientation2_3),
                  ...row('Estado', r.dependenceState, 'Profesional de referencia', r.referenceProfessionalDependence),
                  ...f('Grado de dependencia', r.dependenceGrade),
                ],
              ),
              ReportSection(
                title: 'Adicciones',
                content: [
                  ...f(StringConst.INITIAL_OBSERVATIONS, r.orientation2_4),
                  ...row('Derivación externa', r.externalDerivation, StringConst.INITIAL_MOTIVE, r.motive),
                ],
              ),
            ],
          ),
          ReportSection(
            title: 'Situación legal',
            content: [
              ...f(StringConst.INITIAL_OBSERVATIONS, r.orientation3),
              ...row('Derivación interna', r.internalDerivationLegal, StringConst.INITIAL_DERIVATION_DATE, d(r.internalDerivationDate)),
              ...f(StringConst.INITIAL_MOTIVE, r.internalDerivationMotive),
              ...row('Derivación externa', r.externalDerivationLegal, StringConst.INITIAL_DERIVATION_DATE, d(r.externalDerivationDate)),
              ...f(StringConst.INITIAL_MOTIVE, r.externalDerivationMotive),
              ...f('Representación legal', r.legalRepresentation),
              ...row('Bolsa de tramitación', r.processingBag, StringConst.INITIAL_DATE, d(r.processingBagDate)),
              ...f('Cuantía económica', r.economicAmount),
            ],
          ),
          ReportSection(
            title: 'Situación alojativa',
            content: [
              ...f(StringConst.INITIAL_OBSERVATIONS, r.orientation4),
              ...row('Situación alojativa', r.ownershipType, withHome ? 'Tipo de tenencia' : 'Situación sinhogarismo', withHome ? r.ownershipTypeConcrete : r.homelessnessSituation),
              if (r.ownershipTypeConcrete == 'Otros')
                ...f(StringConst.INITIAL_OTHERS, r.ownershipTypeOpen),
              if (r.homelessnessSituation == 'Otros')
                ...f(StringConst.INITIAL_OTHERS, r.homelessnessSituationOpen),
              ...f('Datos de contacto del recurso alojativo', r.centerContact),
              ...f(StringConst.INITIAL_LOCATION, r.location),
              ...reportHeading(StringConst.HABITABILITY_CONDITIONS, reportBulletList(r.hostingObservations, color: grey)),
            ],
          ),
          ReportSection(
            title: 'Redes de apoyo',
            content: [
              ...f(StringConst.INITIAL_OBSERVATIONS, r.orientation5),
              ...f('Redes de apoyo natural', r.informationNetworks),
              ...row('Redes de apoyo institucional', r.institutionNetworks, 'Conciliación familiar', r.familyConciliation),
            ],
          ),
          ReportSection(
            title: 'Idiomas',
            content: [
              ...f(StringConst.INITIAL_OBSERVATIONS, r.orientation7),
              for (final LanguageReport language in r.languages ?? []) ...[
                ...reportRow(context, title1: StringConst.INITIAL_LANGUAGE, content1: language.name, title2: StringConst.INITIAL_LANGUAGE_LEVEL, content2: language.level),
                ...reportField(context, title: StringConst.INITIAL_LANGUAGE_ACCREDITATION, content: language.accreditation),
              ],
            ],
          ),
          ReportSection(
            title: 'Atención social integral',
            content: [
              ...f(StringConst.INITIAL_OBSERVATIONS, r.orientation9),
              ...f('Centro y TS de referencia', r.centerTSReference),
              ...f('Destinataria de subvención y/o programa de apoyo', r.subsidyBeneficiary),
              if (r.subsidyBeneficiary == 'Si')
                ...f('Nombre/tipo', r.subsidyName),
              ...f('Certificado de Exclusión Social', r.socialExclusionCertificate),
              if (r.socialExclusionCertificate == 'Si')
                ...row(StringConst.INITIAL_DATE, d(r.socialExclusionCertificateDate), 'Observaciones sobre el certificado', r.socialExclusionCertificateObservations),
            ],
          ),
          ReportSection(
            title: 'Situación de Vulnerabilidad',
            content: [
              ...f(StringConst.INITIAL_OBSERVATIONS, r.orientation12),
              ...reportBulletList(r.vulnerabilityOptions, color: grey),
            ],
          ),
          ReportSection(
            title: 'Itinerario formativo laboral',
            content: [
              ...f(StringConst.INITIAL_OBSERVATIONS, r.orientation13),
              ...row('Nivel educativo', r.educationLevel, 'Situación laboral inicial', r.laborSituation),
              ...f(StringConst.HOMOLOGATION, r.homologation),
              if (r.laborSituation == 'Ocupada cuenta propia' || r.laborSituation == 'Ocupada cuenta ajena') ...[
                ...row(StringConst.INITIAL_TEMP, r.tempLabor, 'Tipo jornada', r.workingDayLabor),
                ...f(StringConst.LABOR_OTHER_CONSIDERATIONS, r.laborOtherConsiderations),
              ],
            ],
            subsections: [
              ReportSection(
                title: StringConst.INITIAL_TITLE_9_3_TRAJECTORY,
                content: [
                  ...f(StringConst.INITIAL_OBSERVATIONS, r.orientation13_2),
                  ...f('Competencias (competencias específicas, competencias prelaborales y competencias digitales)', r.competencies),
                  ...f('Contextualización del territorio', r.contextualization),
                  ...f('Conexión del entorno', r.connexion),
                ],
              ),
              ReportSection(
                title: StringConst.INITIAL_TITLE_9_4_EXPECTATIONS,
                content: [
                  ...f('Corto plazo', r.shortTerm),
                  ...f('Medio plazo', r.mediumTerm),
                  ...f('Largo plazo', r.longTerm),
                ],
              ),
              ReportSection(
                title: StringConst.FOLLOW_TITLE_9_5_DEVELOP,
                content: [
                  ...f(StringConst.INITIAL_OBSERVATIONS, r.orientation9_5),
                  ...reportHeading(StringConst.FOLLOW_FORMATIONS, [
                    for (final FormationReport formation in r.formations ?? []) ...[
                      ...row('Nombre de la formación', formation.name, 'Tipo de formación', formation.type),
                      ...f('Certificación', formation.certification),
                    ],
                    ...row('Bolsa de formación', r.formationBag, StringConst.INITIAL_DATE, d(r.formationBagDate)),
                    ...row(StringConst.INITIAL_MOTIVE, r.formationBagMotive, StringConst.FOLLOW_ECONOMIC_AMOUNT, r.formationBagEconomic),
                  ]),
                  ...reportHeading('Empleo', [
                    ...f(StringConst.FOLLOW_JOB_ACHIEVEMENT, r.jobObtaining),
                    ...row('Fecha de obtención', d(r.jobObtainDate), 'Fecha de finalización', d(r.jobFinishDate)),
                    ...row('Mejora laboral', r.jobUpgrade, 'Motivo de mejora', r.upgradeMotive),
                    ...f(StringConst.INITIAL_DATE, d(r.upgradeDate)),
                  ]),
                ],
              ),
              ReportSection(
                title: StringConst.FOLLOW_TITLE_9_6_POST_LABOR_ACCOMPANIMENT,
                content: [
                  ...f(StringConst.INITIAL_OBSERVATIONS, r.orientation9_6),
                  ...f('Acompañamiento intra-laboral', r.postLaborAccompaniment),
                  if (r.postLaborAccompaniment == 'No')
                    ...f(StringConst.INITIAL_MOTIVE, r.postLaborAccompanimentMotive),
                  ...row(StringConst.FOLLOW_INIT_DATE, d(r.postLaborInitialDate), StringConst.FOLLOW_END_DATE, d(r.postLaborFinalDate)),
                  ...f('Total de días', r.postLaborTotalDays?.toString()),
                  ...f('Mantenimiento del empleo obtenido', r.jobMaintenance),
                ],
              ),
            ],
          ),
        ]),
        SpaceH12(),
        BottomSignatures(location: techLocation),
        ];
      }
    )
  );
  return doc.save();
}

pw.Widget SpaceH12(){
  return pw.SizedBox(height: 12);
}

pw.Widget SpaceH5(){
      return pw.SizedBox(height: 5);
}