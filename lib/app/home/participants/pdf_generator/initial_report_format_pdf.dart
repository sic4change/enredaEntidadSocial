import 'dart:async';
import 'dart:typed_data';

import 'package:enreda_empresas/app/home/participants/pdf_generator/common_widgets/text_formats.dart';
import 'package:enreda_empresas/app/home/participants/pdf_generator/cv_print/data.dart';
import 'package:enreda_empresas/app/home/participants/pdf_generator/follow_report_format_pdf.dart';
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
      build: (pw.Context context) => [
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
        CustomItemSameLine(title: 'Nombre y apellidos', content: '${user.firstName} ${user.lastName}'),
        SpaceH5(),
        CustomItemSameLine(title: 'Fecha de nacimiento', content: formatter.format(user.birthday!)),
        SpaceH5(),
        CustomItemSameLine(title: 'Edad', content: '${inYears(DateTime.now().difference(user.birthday!).inDays).toString()} años'),
        SpaceH5(),
        CustomItemSameLine(title: 'Nacionalidad', content: user.nationality!),
        SpaceH5(),
        CustomItemSameLine(title: 'Género', content: user.gender!),
        SpaceH5(),
        CustomItemSameLine(title: StringConst.DNI_PARTICIPANT, content: initialReport.dniParticipant ?? ''),
        SpaceH12(),
        ...customItemPageSafe(context, title: 'Subvención a la que el/la participante está imputado/a', content: initialReport.subsidy ?? ''),
        SpaceH12(),
        ...customItemPageSafe(context, title: 'Técnico/a de referencia', content: initialReport.techPersonName ?? ''),

        //Section 1
        SectionTitle(title: '1. Itinerario en España'),
        ...customItemPageSafe(context, title: 'Orientaciones:', content: initialReport.orientation1 ?? ''),
        SpaceH5(),
        CustomRow(title1: 'Fecha de llegada a España', title2: 'Recursos de acogida', content1: initialReport.arriveDate == null ? '' : formatter.format(initialReport.arriveDate!), content2: initialReport.receptionResources ?? ''),
        SpaceH5(),
        ...customItemPageSafe(context, title: StringConst.INITIAL_EXTERNAL_RESOURCES, content: initialReport.administrativeExternalResources ?? ''),

        //Subsection 1.1
        SubSectionTitle(title: StringConst.INITIAL_TITLE_1_1_ADMINISTRATIVE_SITUATION),
        ...customItemPageSafe(context, title: StringConst.INITIAL_STATE, content: initialReport.adminState ?? ''),
        SpaceH5(),
        if (initialReport.adminState == 'Sin tramitar')
          ...customItemPageSafe(context, title: 'Sin tramitar', content: initialReport.adminNoThrough ?? '')
        else if (initialReport.adminState == 'En trámite')
          CustomRow(title1: 'Fecha de solicitud', title2: 'Fecha de resolución', content1: initialReport.adminDateAsk == null ? '' : formatter.format(initialReport.adminDateAsk!), content2: initialReport.adminDateResolution == null ? '' : formatter.format(initialReport.adminDateResolution!))
        else
          ...customItemPageSafe(context, title: StringConst.INITIAL_DATE_CONCESSION, content: initialReport.adminDateConcession == null ? '' : formatter.format(initialReport.adminDateConcession!)),
        SpaceH5(),
        CustomRow(title1: StringConst.INITIAL_TEMP, title2: initialReport.adminTemp == 'Inicial' || initialReport.adminTemp == 'Temporal' ? 'Fecha de resolución' : '', content1: initialReport.adminTemp ?? '', content2: initialReport.adminTemp == 'Inicial' || initialReport.adminTemp == 'Temporal' ? initialReport.adminDateRenovation == null ? '' : formatter.format(initialReport.adminDateRenovation!) : ''),
        SpaceH5(),
        CustomRow(title1: 'Tipo de residencia', title2: StringConst.INITIAL_JURIDIC_FIGURE, content1: initialReport.adminResidenceType ?? '', content2: initialReport.adminJuridicFigure ?? ''),
        if (initialReport.adminJuridicFigure == 'Otros') ...[
          SpaceH5(),
          ...customItemPageSafe(context, title: StringConst.INITIAL_OTHERS, content: initialReport.adminOther ?? ''),
        ],

        //Section 2
        SectionTitle(title: '2. Situación Sanitaria'),
        ...customItemPageSafe(context, title: StringConst.INITIAL_OBSERVATIONS, content: initialReport.orientation2 ?? ''),
        SpaceH5(),
        CustomRow(title1: 'Tarjeta sanitaria', title2: 'Fecha de caducidad', content1: initialReport.healthCard ?? '', content2: initialReport.expirationDate == null ? '' : formatter.format(initialReport.expirationDate!)),
        SpaceH5(),
        ...customItemPageSafe(context, title: 'Medicación/Tratamiento', content: initialReport.medication ?? ''),

        //Subsection 2.1
        SubSectionTitle(title: '2.1 Salud Mental'),
        ...customItemPageSafe(context, title: StringConst.INITIAL_OBSERVATIONS, content: initialReport.orientation2_1 ?? ''),
        SpaceH5(),
        CustomRow(title1: 'Derivación interna al área psicosocial', title2: StringConst.INITIAL_DERIVATION_DATE, content1: initialReport.psychosocialDerivationLegal ?? '', content2: initialReport.psychosocialDerivationDate == null ? '' : formatter.format(initialReport.psychosocialDerivationDate!)),
        SpaceH5(),
        ...customItemPageSafe(context, title: StringConst.INITIAL_MOTIVE, content: initialReport.psychosocialDerivationMotive ?? ''),

        //Subsection 2.2
        SubSectionTitle(title: '2.2 Discapacidad'),
        ...customItemPageSafe(context, title: StringConst.INITIAL_OBSERVATIONS, content: initialReport.orientation2_2 ?? ''),
        SpaceH5(),
        ...customItemPageSafe(context, title: 'Estado', content: initialReport.disabilityState ?? ''),
        if (initialReport.disabilityState == 'Concedida') ...[
          CustomRow(title1: 'Concedida', title2: 'Fecha', content1: initialReport.granted ?? '', content2: initialReport.revisionDate == null ? '' : formatter.format(initialReport.revisionDate!)),
          SpaceH5(),
        ],
        SpaceH5(),
        ...customItemPageSafe(context, title: 'Profesional de referencia', content: initialReport.referenceProfessionalDisability ?? ''),
        SpaceH5(),
        CustomRow(title1: 'Grado de discapacidad', title2: 'Tipo de discapacidad', content1: initialReport.disabilityGrade ?? '', content2: initialReport.disabilityType ?? ''),

        //Subsection 2.3
        SubSectionTitle(title: '2.3 Dependencia'),
        ...customItemPageSafe(context, title: StringConst.INITIAL_OBSERVATIONS, content: initialReport.orientation2_3 ?? ''),
        SpaceH5(),
        CustomRow(title1: 'Estado', title2: 'Profesional de referencia', content1: initialReport.dependenceState ?? '', content2: initialReport.referenceProfessionalDependence ?? ''),
        SpaceH5(),
        ...customItemPageSafe(context, title: 'Grado de dependencia', content: initialReport.dependenceGrade ?? ''),

        //Subsection 2.4
        SubSectionTitle(title: '2.4 Adicciones'),
        ...customItemPageSafe(context, title: StringConst.INITIAL_OBSERVATIONS, content: initialReport.orientation2_4 ?? ''),
        SpaceH5(),
        CustomRow(title1: 'Derivación externa', title2: StringConst.INITIAL_MOTIVE, content1: initialReport.externalDerivation ?? '', content2: initialReport.motive ?? ''),

        //Section 3
        SectionTitle(title: '3. Situación legal'),
        ...customItemPageSafe(context, title: StringConst.INITIAL_OBSERVATIONS, content: initialReport.orientation3 ?? ''),
        SpaceH5(),
        CustomRow(title1: 'Derivación interma', title2: StringConst.INITIAL_DERIVATION_DATE, content1: initialReport.internalDerivationLegal ?? '', content2: initialReport.internalDerivationDate == null ? '' : formatter.format(initialReport.internalDerivationDate!)),
        SpaceH5(),
        ...customItemPageSafe(context, title: StringConst.INITIAL_MOTIVE, content: initialReport.internalDerivationMotive ?? ''),
        SpaceH5(),
        CustomRow(title1: 'Derivación externa', title2: StringConst.INITIAL_DERIVATION_DATE, content1: initialReport.externalDerivationLegal ?? '', content2: initialReport.externalDerivationDate == null ? '' : formatter.format(initialReport.externalDerivationDate!)),
        SpaceH5(),
        ...customItemPageSafe(context, title: StringConst.INITIAL_MOTIVE, content: initialReport.externalDerivationMotive ?? ''),
        SpaceH5(),
        ...customItemPageSafe(context, title: 'Representación legal', content: initialReport.legalRepresentation ?? ''),

        //Section 4
        SectionTitle(title: '4. Situación alojativa'),
        ...customItemPageSafe(context, title: StringConst.INITIAL_OBSERVATIONS, content: initialReport.orientation4 ?? ''),
        SpaceH5(),
        CustomRow(title1: 'Situación alojativa', title2: initialReport.ownershipType == 'Con hogar' ? 'Tipo de tenencia' : 'Situación sinhogarismo', content1: initialReport.ownershipType ?? '', content2: initialReport.ownershipType == 'Con hogar' ? (initialReport.ownershipTypeConcrete ?? '') : (initialReport.homelessnessSituation ?? '')),
        SpaceH5(),
        if (initialReport.ownershipTypeConcrete == 'Otros') ...[
          ...customItemPageSafe(context, title: StringConst.INITIAL_OTHERS, content: initialReport.ownershipTypeOpen ?? ''),
          SpaceH5(),
        ],
        if (initialReport.homelessnessSituation == 'Otros') ...[
          ...customItemPageSafe(context, title: StringConst.INITIAL_OTHERS, content: initialReport.homelessnessSituationOpen ?? ''),
          SpaceH5(),
        ],
        ...customItemPageSafe(context, title: 'Datos de contacto del recurso alojativo', content: initialReport.centerContact ?? ''),
        ...customItemPageSafe(context, title: StringConst.INITIAL_LOCATION, content: initialReport.location ?? ''),
        SubSectionTitle(title: StringConst.HABITABILITY_CONDITIONS),
        for (var data in initialReport.hostingObservations!)
          BlockSimpleList(title: data, color: grey),

        //Section 5
        SectionTitle(title: '5. Redes de apoyo'),
        ...customItemPageSafe(context, title: StringConst.INITIAL_OBSERVATIONS, content: initialReport.orientation5 ?? ''),
        SpaceH5(),
        ...customItemPageSafe(context, title: 'Redes de apoyo natural', content: initialReport.informationNetworks ?? ''),
        SpaceH5(),
        CustomRow(title1: 'Redes de apoyo institucional', title2: 'Conciliación familiar', content1: initialReport.institutionNetworks ?? '', content2: initialReport.familyConciliation ?? ''),

        //Section 6 — Idiomas
        SectionTitle(title: '6. Idiomas'),
        ...customItemPageSafe(context, title: StringConst.INITIAL_OBSERVATIONS, content: initialReport.orientation7 ?? ''),
        SpaceH5(),
        for (final LanguageReport language in initialReport.languages ?? []) ...[
          CustomRow(title1: StringConst.INITIAL_LANGUAGE, title2: StringConst.INITIAL_LANGUAGE_LEVEL, content1: language.name, content2: language.level),
          SpaceH5(),
          ...customItemPageSafe(context, title: StringConst.INITIAL_LANGUAGE_ACCREDITATION, content: language.accreditation),
          SpaceH5(),
        ],

        //Section 7 — Atención social integral
        SectionTitle(title: '7. Atención social integral'),
        ...customItemPageSafe(context, title: StringConst.INITIAL_OBSERVATIONS, content: initialReport.orientation9 ?? ''),
        SpaceH5(),
        ...customItemPageSafe(context, title: 'Centro y TS de referencia', content: initialReport.centerTSReference ?? ''),
        SpaceH5(),
        ...customItemPageSafe(context, title: 'Destinataria de subvención y/o programa de apoyo', content: initialReport.subsidyBeneficiary ?? ''),
        if (initialReport.subsidyBeneficiary == 'Si') ...[
          ...customItemPageSafe(context, title: 'Nombre/tipo', content: initialReport.subsidyName ?? ''),
          SpaceH5(),
        ],
        SpaceH5(),
        ...customItemPageSafe(context, title: 'Certificado de Exclusión Social', content: initialReport.socialExclusionCertificate ?? ''),
        if (initialReport.socialExclusionCertificate == 'Si') ...[
          CustomRow(title1: StringConst.INITIAL_DATE, title2: 'Observaciones sobre el certificado', content1: initialReport.socialExclusionCertificateDate == null ? '' : formatter.format(initialReport.socialExclusionCertificateDate!), content2: initialReport.socialExclusionCertificateObservations ?? ''),
          SpaceH5(),
        ],

        //Section 8 — Situación de Vulnerabilidad
        SectionTitle(title: '8. Situación de Vulnerabilidad'),
        ...customItemPageSafe(context, title: StringConst.INITIAL_OBSERVATIONS, content: initialReport.orientation12 ?? ''),
        SpaceH5(),
        for (var data in initialReport.vulnerabilityOptions!)
          BlockSimpleList(title: data, color: grey),

        //Section 9 — Itinerario formativo laboral
        SectionTitle(title: '9. Itinerario formativo laboral'),
        ...customItemPageSafe(context, title: StringConst.INITIAL_OBSERVATIONS, content: initialReport.orientation13 ?? ''),
        SpaceH5(),
        CustomRow(title1: 'Nivel educativo', title2: 'Situación laboral inicial', content1: initialReport.educationLevel ?? '', content2: initialReport.laborSituation ?? ''),
        SpaceH5(),
        ...customItemPageSafe(context, title: StringConst.HOMOLOGATION, content: initialReport.homologation ?? ''),
        SpaceH5(),
        if (initialReport.laborSituation == 'Ocupada cuenta propia' || initialReport.laborSituation == 'Ocupada cuenta ajena') ...[
          CustomRow(title1: StringConst.INITIAL_TEMP, title2: 'Tipo jornada', content1: initialReport.tempLabor ?? '', content2: initialReport.workingDayLabor ?? ''),
          SpaceH5(),
          ...customItemPageSafe(context, title: StringConst.LABOR_OTHER_CONSIDERATIONS, content: initialReport.laborOtherConsiderations ?? ''),
        ],

        SubSectionTitle(title: StringConst.INITIAL_TITLE_9_3_TRAJECTORY),
        ...customItemPageSafe(context, title: StringConst.INITIAL_OBSERVATIONS, content: initialReport.orientation13_2 ?? ''),
        SpaceH5(),
        ...customItemPageSafe(context, title: 'Competencias (competencias específicas, competencias prelaborales y competencias digitales)', content: initialReport.competencies ?? ''),
        SpaceH5(),
        ...customItemPageSafe(context, title: 'Contextualización del territorio', content: initialReport.contextualization ?? ''),
        SpaceH5(),
        ...customItemPageSafe(context, title: 'Conexión del entorno', content: initialReport.connexion ?? ''),

        SubSectionTitle(title: StringConst.INITIAL_TITLE_9_4_EXPECTATIONS),
        ...customItemPageSafe(context, title: 'Corto plazo', content: initialReport.shortTerm ?? ''),
        SpaceH5(),
        ...customItemPageSafe(context, title: 'Medio plazo', content: initialReport.mediumTerm ?? ''),
        SpaceH5(),
        ...customItemPageSafe(context, title: 'Largo plazo', content: initialReport.longTerm ?? ''),

        SpaceH5(),
        if (isReopening) ...[
          SectionTitle(title: StringConst.CLOSURE_TITLE_10),
          ...customItemPageSafe(context, title: StringConst.INITIAL_OBSERVATIONS, content: initialReport.orientation10 ?? ''),
          SpaceH5(),
          CustomRow(
            title1: StringConst.CLOSURE_CLOSE_MOTIVE,
            title2: StringConst.CLOSURE_CLOSE_MOTIVE_DETAIL,
            content1: initialReport.motiveClose ?? '',
            content2: initialReport.motiveCloseDetail ?? '',
          ),
          SpaceH5(),
          ...customItemPageSafe(context, title: 'Fecha de cierre anterior', content: initialReport.closeDate == null ? '' : formatter.format(initialReport.closeDate!)),
          SpaceH5(),
          SectionTitle(title: StringConst.REOPENING_TITLE_11),
          ...customItemPageSafe(context, title: 'Motivo de la reapertura', content: initialReport.reopeningMotive ?? ''),
          SpaceH5(),
        ],
        BottomSignatures(),
      ]
    )
  );
  return doc.save();
}

pw.Widget SpaceH5(){
  return pw.SizedBox(height: 5);
}







