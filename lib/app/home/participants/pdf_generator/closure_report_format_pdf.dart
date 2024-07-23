import 'dart:async';
import 'dart:typed_data';

import 'package:enreda_empresas/app/home/participants/pdf_generator/common_widgets/bottom_signatures.dart';
import 'package:enreda_empresas/app/home/participants/pdf_generator/cv_print/data.dart';
import 'package:enreda_empresas/app/models/closureReport.dart';
import 'package:enreda_empresas/app/models/formationReport.dart';
import 'package:enreda_empresas/app/models/languageReport.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'common_widgets/doc_theme.dart';
import 'common_widgets/text_formats.dart';

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
final DateFormat formatter = DateFormat('dd/MM/yyyy');

Future<Uint8List> generateClosureReportFile(
    PdfPageFormat format,
    CustomData data,
    UserEnreda user,
    ClosureReport closureReport,
    ) async {
  final doc = pw.Document(title: 'Reporte de cierre');

  format = format.applyMargin(
      left: 2.0 * PdfPageFormat.cm,
      top: 3.0 * PdfPageFormat.cm,
      right: 2.0 * PdfPageFormat.cm,
      bottom: 3.0 * PdfPageFormat.cm);

  final pageTheme = await MyPageTheme(format);
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  doc.addPage(
    pw.MultiPage(
      pageTheme: pageTheme,
      build: (pw.Context context) => [
        pw.Text(
          'Reporte de cierre de ${user.firstName} ${user.lastName}',
            style: pw.Theme.of(context)
                .defaultTextStyle
                .copyWith(fontWeight: pw.FontWeight.bold, fontSize: 16, color: primary900)
        ),
        pw.SizedBox(
          height: 30,
        ),
        CustomItem(title: 'Subvención a la que el/la participante está imputado/a', content: closureReport.subsidy ?? ''),

        //Section 1
        SectionTitle(title: '1. Itinerario en España'),
        CustomItem(title: 'Orinetaciones', content: closureReport.orientation1 ?? ''),
        SpaceH12(),
        CustomRow(title1: 'Fecha de llegada a España', title2: 'Recursos de acogida', content1: closureReport.arriveDate == null ? '' : formatter.format(closureReport.arriveDate!), content2: closureReport.receptionResources ?? ''),
        SpaceH12(),
        CustomItem(title: 'Situación administrativa', content: closureReport.administrativeExternalResources ?? ''),

        //Subsection 1.1
        SubSectionTitle(title: StringConst.INITIAL_TITLE_1_1_ADMINISTRATIVE_SITUATION),
        CustomItem(title: StringConst.INITIAL_STATE, content: closureReport.adminState ?? ''),
        SpaceH12(),
        closureReport.adminState == 'Sin tramitar' ?
        CustomItem(title: 'Sin tramitar', content: closureReport.adminNoThrough ?? '') :
        closureReport.adminState == 'En trámite' ?
        CustomRow(title1: 'Fecha de solicitud', title2: 'Fecha de resolución', content1: closureReport.adminDateAsk == null ? '' : formatter.format(closureReport.adminDateAsk!), content2: closureReport.adminDateResolution == null ? '' : formatter.format(closureReport.adminDateResolution!)) :
        CustomItem(title: StringConst.INITIAL_DATE_CONCESSION, content: closureReport.adminDateConcession == null ? '' : formatter.format(closureReport.adminDateConcession!)),
        SpaceH12(),
        CustomRow(title1: StringConst.INITIAL_TEMP, title2: closureReport.adminTemp == 'Inicial' || closureReport.adminTemp == 'Temporal' ? 'Fecha de resolución' : '', content1: closureReport.adminTemp ?? '', content2: closureReport.adminTemp == 'Inicial' || closureReport.adminTemp == 'Temporal' ? closureReport.adminDateRenovation == null ? '' : formatter.format(closureReport.adminDateRenovation!) : ''),
        SpaceH12(),
        CustomRow(title1: 'Tipo de residencia', title2: StringConst.INITIAL_JURIDIC_FIGURE, content1: closureReport.adminResidenceType ?? '', content2: closureReport.adminJuridicFigure ?? ''),
        closureReport.adminJuridicFigure == 'Otros' ?pw.Column(
            children: [
              SpaceH12(),
              CustomItem(title: StringConst.INITIAL_OTHERS, content: closureReport.adminOther ?? '')
            ]
        ) : pw.Container(),

        //Section 2
        SectionTitle(title: '2. Situación Sanitaria'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation2 ?? ''),
        SpaceH12(),
        CustomRow(title1: 'Tarjeta sanitaria', title2: 'Fecha de caducidad', content1: closureReport.healthCard ?? '', content2: closureReport.expirationDate == null ? '' : formatter.format(closureReport.expirationDate!)),
        SpaceH12(),
        CustomItem(title: 'Medicación/Tratamiento', content: closureReport.medication ?? ''),

        //Subsection 2.1
        SubSectionTitle(title: '2.1 Salud Mental'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation2_1 ?? ''),
        SpaceH12(),
        CustomRow(title1: 'Sueño y descanso', title2: 'Diagnostico', content1: closureReport.rest ?? '', content2: closureReport.diagnosis ?? ''),
        SpaceH12(),
        CustomRow(title1: 'Tratamiento', title2: 'Seguimiento', content1: closureReport.treatment ?? '', content2: closureReport.tracking ?? ''),

        //Subsection 2.2
        SubSectionTitle(title: '2.2 Discapacidad'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation2_2 ?? ''),
        SpaceH12(),
        CustomItem(title: 'Estado', content: closureReport.disabilityState ?? ''),
        closureReport.dependenceState == 'Concedida' ?
        CustomRow(title1: 'Concedida', title2: 'Fecha', content1: closureReport.granted ?? '', content2: closureReport.revisionDate == null ? '' : formatter.format(closureReport.revisionDate!)) :
        pw.Container(),
        closureReport.dependenceState == 'Concedida' ? SpaceH12() : pw.Container(),
        SpaceH12(),
        CustomItem(title: 'Profesional de referencia', content: closureReport.referenceProfessionalDisability ?? ''),
        SpaceH12(),
        CustomRow(title1: 'Grado de discapacidad', title2: 'Tipo de discapacidad', content1: closureReport.disabilityGrade ?? '', content2: closureReport.disabilityType ?? ''),

        //Subsection 2.3
        SubSectionTitle(title: '2.3 Dependencia'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation2_3 ?? ''),
        SpaceH12(),
        CustomRow(title1: 'Estado', title2: 'Profesional de referencia', content1: closureReport.dependenceState ?? '', content2: closureReport.referenceProfessionalDependence ?? ''),
        SpaceH12(),
        CustomItem(title: 'Grado de dependencia', content: closureReport.dependenceGrade ?? ''),

        //Subsection 2.4
        SubSectionTitle(title: '2.4 Adicciones'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation2_4 ?? ''),
        SpaceH12(),
        CustomRow(title1: 'Derivación externa', title2: StringConst.INITIAL_MOTIVE, content1: closureReport.externalDerivation ?? '', content2: closureReport.motive ?? ''),

        //Section 3
        SectionTitle(title: '3. Situación legal'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation3 ?? ''),
        SpaceH12(),
        CustomRow(title1: 'Derivación interma', title2: StringConst.INITIAL_DERIVATION_DATE, content1: closureReport.internalDerivationLegal ?? '', content2: closureReport.internalDerivationDate == null ? '' :  formatter.format(closureReport.internalDerivationDate!)),
        SpaceH12(),
        CustomItem(title: StringConst.INITIAL_MOTIVE, content: closureReport.internalDerivationMotive ?? ''),
        SpaceH12(),
        CustomRow(title1: 'Derivación externa', title2: StringConst.INITIAL_DERIVATION_DATE, content1: closureReport.externalDerivationLegal ?? '', content2: closureReport.externalDerivationDate == null ? '' : formatter.format(closureReport.externalDerivationDate!)),
        SpaceH12(),
        CustomItem(title: StringConst.INITIAL_MOTIVE, content: closureReport.externalDerivationMotive ?? ''),
        SpaceH12(),
        CustomRow(title1: 'Derivación interna al área psicosocial', title2: StringConst.INITIAL_DERIVATION_DATE, content1: closureReport.psychosocialDerivationLegal ?? '', content2: closureReport.psychosocialDerivationDate == null ? '' : formatter.format(closureReport.psychosocialDerivationDate!)),
        SpaceH12(),
        CustomItem(title: StringConst.INITIAL_MOTIVE, content: closureReport.psychosocialDerivationMotive ?? ''),
        SpaceH12(),
        CustomItem(title: 'Representación legal', content: closureReport.legalRepresentation ?? ''),
        SpaceH12(),
        CustomRow(title1: 'Bolsa de tramitación', title2: StringConst.INITIAL_DATE, content1: closureReport.processingBag ?? '', content2: closureReport.processingBagDate == null ? '' : formatter.format(closureReport.processingBagDate!)),
        SpaceH12(),
        CustomItem(title: 'Cuantia económica', content: closureReport.economicAmount ?? ''),

        //Section 4
        SectionTitle(title: 'Situación alojativa'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation4 ?? ''),
        SpaceH12(),
        CustomRow(title1: 'Situación alojativa', title2: closureReport.ownershipType == 'Con hogar' ? 'Tipo de tenencia' : 'Situación sinhogarismo', content1: closureReport.ownershipType ?? '', content2: closureReport.ownershipType == 'Con hogar' ? (closureReport.ownershipTypeConcrete ?? '') : (closureReport.homelessnessSituation ?? '')),
        SpaceH12(),
        closureReport.ownershipTypeConcrete == 'Otros' ? pw.Column(
            children: [
              CustomItem(title: StringConst.INITIAL_OTHERS, content: closureReport.ownershipTypeOpen ?? ''),
              SpaceH12(),
            ]
        ) : pw.Container(),
        closureReport.homelessnessSituation== 'Otros' ? pw.Column(
            children: [
              CustomItem(title: StringConst.INITIAL_OTHERS, content: closureReport.homelessnessSituationOpen ?? ''),
              SpaceH12(),
            ]
        ) : pw.Container(),
        CustomItem(title: 'Datos de contacto del recurso alojativo', content: closureReport.centerContact ?? ''),
        CustomItem(title: StringConst.INITIAL_LOCATION, content: closureReport.location ?? ''),
        SpaceH12(),
        for (var data in closureReport.hostingObservations!)
          BlockSimpleList(
            title: data,
            color: grey,
          ),

        //Section 5
        SectionTitle(title: '5. Redes de apoyo'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation5 ?? ''),
        SpaceH12(),
        CustomItem(title: 'Redes de apoyo natural', content: closureReport.informationNetworks ?? ''),
        SpaceH12(),
        CustomRow(title1: 'Redes de apoyo institucional', title2: 'Conciliación familiar', content1: closureReport.institutionNetworks ?? '', content2: closureReport.familyConciliation ?? ''),

        //Section7
        SectionTitle(title: '6. Idiomas'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation7 ?? ''),
        SpaceH12(),
        pw.Column(
            children: [
              for(LanguageReport language in closureReport.languages ?? [])
                pw.Column(
                    children: [
                      CustomRow(title1: 'Idioma', title2: 'Reconocimiento / acreditación - nivel', content1: language.name, content2: language.level),
                      SpaceH12(),
                    ]
                )
            ]
        ),

        //Section 9
        SectionTitle(title: '7. Atención social integral'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation9 ?? ''),
        SpaceH12(),
        CustomItem(title: 'Centro y TS de referencia', content: closureReport.centerTSReference ?? ''),
        SpaceH12(),
        CustomItem(title: 'Destinataria de subvención y/o programa de apoyo', content: closureReport.subsidyBeneficiary ?? ''),
        closureReport.subsidyBeneficiary == 'Si' ? pw.Column(
            children: [
              CustomItem(title: 'Nombre/tipo', content: closureReport.subsidyName ?? ''),
              SpaceH12(),
            ]
        ) : pw.Container(),
        SpaceH12(),
        CustomItem(title: 'Certificado de Exclusión Social', content: closureReport.socialExclusionCertificate ?? ''),
        closureReport.socialExclusionCertificate == 'Si' ? pw.Column(
            children: [
              CustomRow(title1: StringConst.INITIAL_DATE, title2: 'Observaciones sobre el certificado', content1: closureReport.socialExclusionCertificateDate == null ? '' : formatter.format(closureReport.socialExclusionCertificateDate!), content2: closureReport.socialExclusionCertificateObservations ?? ''),
              SpaceH12(),
            ]
        ) : pw.Container(),

        //Section 12
        SectionTitle(title: '8. Situación de Vulnerabilidad'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation12 ?? ''),
        SpaceH12(),
        for (var data in closureReport.vulnerabilityOptions!)
          BlockSimpleList(
            title: data,
            color: grey,
          ),

        //Section 13
        SectionTitle(title: '9. Itinerario formativo laboral'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation13 ?? ''),
        SubSectionTitle(title: StringConst.INITIAL_TITLE_9_3_TRAJECTORY),
        CustomItem(title: 'Competencias (competencias específicas, competencias prelaborales y competencias digitales)', content: closureReport.competencies ?? ''),
        SpaceH12(),
        CustomItem(title: 'Contextualización del territorio', content: closureReport.contextualization ?? ''),
        SpaceH12(),
        CustomItem(title: 'Conexión del entorno', content: closureReport.connexion ?? ''),

        SubSectionTitle(title: StringConst.INITIAL_TITLE_9_4_EXPECTATIONS),
        CustomItem(title: 'Corto plazo', content: closureReport.shortTerm ?? ''),
        SpaceH12(),
        CustomItem(title: 'Medio plazo', content: closureReport.mediumTerm ?? ''),
        SpaceH12(),
        CustomItem(title: 'Largo plazo', content: closureReport.longTerm ?? ''),

        //Subsection 9.5
        SubSectionTitle(title: StringConst.FOLLOW_TITLE_9_5_DEVELOP),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation9_5 ?? ''),
        SubSectionTitle(title: StringConst.FOLLOW_FORMATIONS),
        pw.Column(
            children: [
              for(FormationReport formation in closureReport.formations ?? [])
                pw.Column(
                    children: [
                      CustomRow(title1: 'Nombre de la formación', title2: 'Tipo de formación', content1: formation.name, content2: formation.type),
                      SpaceH12(),
                      CustomItem(title: 'Certificación', content: formation.certification),
                      SpaceH12(),
                    ]
                )
            ]
        ),
        CustomRow(title1: 'Bolsa de formación', title2: StringConst.INITIAL_DATE, content1: closureReport.formationBag ?? '', content2: closureReport.formationBagDate == null ? '' : formatter.format(closureReport.formationBagDate!)),
        SpaceH12(),
        CustomRow(title1: StringConst.INITIAL_MOTIVE, title2: StringConst.FOLLOW_ECONOMIC_AMOUNT, content1: closureReport.formationBagMotive ?? '', content2: closureReport.formationBagEconomic ?? ''),

        SubSectionTitle(title: 'Empleo'),
        CustomRow(title1: 'Nivel educativo', title2: 'Situación laboral', content1: closureReport.educationLevel ?? '', content2: closureReport.laborSituation ?? ''),
        SpaceH12(),
        closureReport.laborSituation == 'Ocupada cuenta propia' || closureReport.laborSituation == 'Ocupada cuenta ajena' ?
        pw.Column(
            children: [
              CustomRow(title1: StringConst.INITIAL_TEMP, title2: 'Tipo jornada', content1: closureReport.tempLabor ?? '', content2: closureReport.workingDayLabor ?? ''),
              SpaceH12(),
            ]
        )
            : pw.Container(),
        CustomRow(title1: 'Fecha de obtención', title2: 'Fecha de finalización', content1: closureReport.jobObtainDate == null ? '' : formatter.format(closureReport.jobObtainDate!), content2: closureReport.jobFinishDate == null ? '' : formatter.format(closureReport.jobFinishDate!)),
        SpaceH12(),
        CustomRow(title1: 'Mejora laboral', title2: 'Motivo de mejora', content1: closureReport.jobUpgrade ?? '', content2: closureReport.upgradeMotive ?? ''),
        SpaceH12(),
        CustomItem(title: StringConst.INITIAL_DATE, content: closureReport.upgradeDate == null ? '' : formatter.format(closureReport.upgradeDate!)),

        SubSectionTitle(title: StringConst.FOLLOW_TITLE_9_6_POST_LABOR_ACCOMPANIMENT),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation9_6 ?? ''),
        SpaceH12(),
        CustomItem(title: 'Acompañamiento post-laboral', content: closureReport.postLaborAccompaniment ?? ''),
        closureReport.postLaborAccompaniment == 'No' ?
        pw.Column(
            children: [
              SpaceH12(),
              CustomItem(title: StringConst.INITIAL_MOTIVE, content: closureReport.postLaborAccompanimentMotive ?? ''),
            ]
        ): pw.Container(),
        SpaceH12(),
        CustomRow(title1: StringConst.FOLLOW_INIT_DATE, title2: StringConst.FOLLOW_END_DATE, content1: closureReport.postLaborInitialDate == null ? '' :  formatter.format(closureReport.postLaborInitialDate!), content2: closureReport.postLaborFinalDate == null ? '' : formatter.format(closureReport.postLaborFinalDate!)),
        SpaceH12(),
        CustomItem(title: 'Total de días', content: closureReport.postLaborTotalDays.toString() ?? ''),
        SpaceH12(),
        CustomItem(title: 'Mantenimiento del empleo obtenido', content: closureReport.jobMaintenance ?? ''),
        SectionTitle(title: StringConst.CLOSURE_TITLE_10),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation10 ?? ''),
        SpaceH12(),
        CustomItem(title: StringConst.CLOSURE_CLOSE_MOTIVE, content: closureReport.motiveClose ?? ''),
        SpaceH12(),
        CustomRow(title1: StringConst.CLOSURE_CLOSE_MOTIVE_DETAIL, title2: StringConst.INITIAL_DATE, content1: closureReport.motiveCloseDetail ?? '', content2: closureReport.closeDate == null ? '' : formatter.format(closureReport.closeDate!)),

        SpaceH12(),
        BottomSignatures(),
      ]
    )
  );
  return doc.save();
}

pw.Widget SpaceH12(){
  return pw.SizedBox(height: 12);
}


