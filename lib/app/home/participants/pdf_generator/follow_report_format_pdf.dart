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
import 'common_widgets/text_formats.dart';

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
      bottom: 3.0 * PdfPageFormat.cm);

  final bool isMdm = followReport.subsidy == '529760_MEDICOS DEL MUNDO_EMPLEANDO_SUEÑOS' ? true : false;

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
              return pw.Container(
                  alignment: pw.Alignment.centerRight,
                  margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
                  child: pw.Text(
                      'Pág. ${context.pageNumber} de ${context.pagesCount}',
                      textScaleFactor: 0.8,
                      style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(color: PdfColors.grey)));
        },
      build: (pw.Context context) => [
        pw.Text(
          'Informe de seguimiento de ${user.firstName} ${user.lastName}',
            style: pw.Theme.of(context)
                .defaultTextStyle
                .copyWith(fontWeight: pw.FontWeight.bold, fontSize: 16, color: primary900)
        ),
        pw.SizedBox(
          height: 30,
        ),
        CustomItemSameLine(title: 'Nombre y apellidos', content: '${user.firstName} ${user.lastName}'),
        SpaceH5(),
        CustomItemSameLine(title: 'Fecha de nacimiento', content: formatter.format(user.birthday!)),
        SpaceH5(),
        CustomItemSameLine(title: 'Edad', content: '${inYears(DateTime.now().difference(user.birthday!).inDays).toString()} años'),
        SpaceH5(),
        CustomItemSameLine(title: 'Nacionalidad', content: user.nationality!),
        SpaceH5(),
        CustomItemSameLine(title: 'Género', content: user.gender!),
        SpaceH12(),
        CustomItem(title: 'Subvención a la que el/la participante está imputado/a', content: followReport.subsidy ?? ''),
        SpaceH12(),
        CustomItem(title: 'Técnico/a de referencia', content: followReport.techPersonName ?? ''),

        //Section 1
        SectionTitle(title: '1. Itinerario en España'),
        CustomItem(title: 'Orinetaciones', content: followReport.orientation1 ?? ''),
        SpaceH12(),
        CustomRow(title1: 'Fecha de llegada a España', title2: 'Recursos de acogida', content1:  followReport.arriveDate == null ? '' : formatter.format(followReport.arriveDate!), content2: followReport.receptionResources ?? ''),
        SpaceH12(),
        CustomItem(title: StringConst.INITIAL_EXTERNAL_RESOURCES, content: followReport.administrativeExternalResources ?? ''),

        //Subsection 1.1
        SubSectionTitle(title: StringConst.INITIAL_TITLE_1_1_ADMINISTRATIVE_SITUATION),
        CustomItem(title: StringConst.INITIAL_STATE, content: followReport.adminState ?? ''),
        SpaceH12(),
        followReport.adminState == 'Sin tramitar' ?
        CustomItem(title: 'Sin tramitar', content: followReport.adminNoThrough ?? '') :
        followReport.adminState == 'En trámite' ?
        CustomRow(title1: 'Fecha de solicitud', title2: 'Fecha de resolución', content1: followReport.adminDateAsk == null ? '' : formatter.format(followReport.adminDateAsk!), content2: followReport.adminDateResolution == null ? '' : formatter.format(followReport.adminDateResolution!)) :
        CustomItem(title: StringConst.INITIAL_DATE_CONCESSION, content: followReport.adminDateConcession == null ? '' : formatter.format(followReport.adminDateConcession!)),
        SpaceH12(),
        CustomRow(title1: StringConst.INITIAL_TEMP, title2: followReport.adminTemp == 'Inicial' || followReport.adminTemp == 'Temporal' ? 'Fecha de resolución' : '', content1: followReport.adminTemp ?? '', content2: followReport.adminTemp == 'Inicial' || followReport.adminTemp == 'Temporal' ?  followReport.adminDateRenovation == null ? '' : formatter.format(followReport.adminDateRenovation!) : ''),
        SpaceH12(),
        CustomRow(title1: 'Tipo de residencia', title2: StringConst.INITIAL_JURIDIC_FIGURE, content1: followReport.adminResidenceType ?? '', content2: followReport.adminJuridicFigure ?? ''),
        followReport.adminJuridicFigure == 'Otros' ?pw.Column(
            children: [
              SpaceH12(),
              CustomItem(title: StringConst.INITIAL_OTHERS, content: followReport.adminOther ?? '')
            ]
        ) : pw.Container(),

        //Section 2
        SectionTitle(title: '2. Situación Sanitaria'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: followReport.orientation2 ?? ''),
        SpaceH12(),
        CustomRow(title1: 'Tarjeta sanitaria', title2: 'Fecha de caducidad', content1: followReport.healthCard ?? '', content2: followReport.expirationDate == null ? '' : formatter.format(followReport.expirationDate!)),
        SpaceH12(),
        CustomItem(title: 'Medicación/Tratamiento', content: followReport.medication ?? ''),

        //Subsection 2.1
        SubSectionTitle(title: '2.1 Salud Mental'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: followReport.orientation2_1 ?? ''),
        SpaceH12(),
        CustomRow(title1: 'Sueño y descanso', title2: 'Diagnostico', content1: followReport.rest ?? '', content2: followReport.diagnosis ?? ''),
        SpaceH12(),
        CustomRow(title1: 'Tratamiento', title2: 'Seguimiento', content1: followReport.treatment ?? '', content2: followReport.tracking ?? ''),

        //Subsection 2.2
        SubSectionTitle(title: '2.2 Discapacidad'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: followReport.orientation2_2 ?? ''),
        SpaceH12(),
        CustomItem(title: 'Estado', content: followReport.disabilityState ?? ''),
        followReport.disabilityState == 'Concedida' ?
        CustomRow(title1: 'Concedida', title2: 'Fecha', content1: followReport.granted ?? '', content2: followReport.revisionDate == null ? '' : formatter.format(followReport.revisionDate!)) :
        pw.Container(),
        followReport.disabilityState == 'Concedida' ? SpaceH12() : pw.Container(),
        SpaceH12(),
        CustomItem(title: 'Profesional de referencia', content: followReport.referenceProfessionalDisability ?? ''),
        SpaceH12(),
        CustomRow(title1: 'Grado de discapacidad', title2: 'Tipo de discapacidad', content1: followReport.disabilityGrade ?? '', content2: followReport.disabilityType ?? ''),

        //Subsection 2.3
        SubSectionTitle(title: '2.3 Dependencia'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: followReport.orientation2_3 ?? ''),
        SpaceH12(),
        CustomRow(title1: 'Estado', title2: 'Profesional de referencia', content1: followReport.dependenceState ?? '', content2: followReport.referenceProfessionalDependence ?? ''),
        SpaceH12(),
        CustomItem(title: 'Grado de dependencia', content: followReport.dependenceGrade ?? ''),

        //Subsection 2.4
        SubSectionTitle(title: '2.4 Adicciones'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: followReport.orientation2_4 ?? ''),
        SpaceH12(),
        CustomRow(title1: 'Derivación externa', title2: StringConst.INITIAL_MOTIVE, content1: followReport.externalDerivation ?? '', content2: followReport.motive ?? ''),

        //Section 3
        SectionTitle(title: '3. Situación legal'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: followReport.orientation3 ?? ''),
        SpaceH12(),
        CustomRow(title1: 'Derivación interma', title2: StringConst.INITIAL_DERIVATION_DATE, content1: followReport.internalDerivationLegal ?? '', content2: followReport.internalDerivationDate == null ? '' : formatter.format(followReport.internalDerivationDate!)),
        SpaceH12(),
        CustomItem(title: StringConst.INITIAL_MOTIVE, content: followReport.internalDerivationMotive ?? ''),
        SpaceH12(),
        CustomRow(title1: 'Derivación externa', title2: StringConst.INITIAL_DERIVATION_DATE, content1: followReport.externalDerivationLegal ?? '', content2: followReport.externalDerivationDate == null ? '' : formatter.format(followReport.externalDerivationDate!)),
        SpaceH12(),
        CustomItem(title: StringConst.INITIAL_MOTIVE, content: followReport.externalDerivationMotive ?? ''),
        SpaceH12(),
        CustomRow(title1: 'Derivación interna al área psicosocial', title2: StringConst.INITIAL_DERIVATION_DATE, content1: followReport.psychosocialDerivationLegal ?? '', content2: followReport.psychosocialDerivationDate == null ? '' : formatter.format(followReport.psychosocialDerivationDate!)),
        SpaceH12(),
        CustomItem(title: StringConst.INITIAL_MOTIVE, content: followReport.psychosocialDerivationMotive ?? ''),
        SpaceH12(),
        CustomItem(title: 'Representación legal', content: followReport.legalRepresentation ?? ''),
        SpaceH12(),
        CustomRow(title1: 'Bolsa de tramitación', title2: StringConst.INITIAL_DATE, content1: followReport.processingBag ?? '', content2: followReport.processingBagDate == null ? '' : formatter.format(followReport.processingBagDate!)),
        SpaceH12(),
        CustomItem(title: 'Cuantia económica', content: followReport.economicAmount ?? ''),

        //Section 4
        SectionTitle(title: 'Situación alojativa'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: followReport.orientation4 ?? ''),
        SpaceH12(),
        CustomRow(title1: 'Situación alojativa', title2: followReport.ownershipType == 'Con hogar' ? 'Tipo de tenencia' : 'Situación sinhogarismo', content1: followReport.ownershipType ?? '', content2: followReport.ownershipType == 'Con hogar' ? (followReport.ownershipTypeConcrete ?? '') : (followReport.homelessnessSituation ?? '')),
        SpaceH12(),
        followReport.ownershipTypeConcrete == 'Otros' ? pw.Column(
            children: [
              CustomItem(title: StringConst.INITIAL_OTHERS, content: followReport.ownershipTypeOpen ?? ''),
              SpaceH12(),
            ]
        ) : pw.Container(),
        followReport.homelessnessSituation== 'Otros' ? pw.Column(
            children: [
              CustomItem(title: StringConst.INITIAL_OTHERS, content: followReport.homelessnessSituationOpen ?? ''),
              SpaceH12(),
            ]
        ) : pw.Container(),
        CustomItem(title: 'Datos de contacto del recurso alojativo', content: followReport.centerContact ?? ''),
        CustomItem(title: StringConst.INITIAL_LOCATION, content: followReport.location ?? ''),
        SpaceH12(),
        for (var data in followReport.hostingObservations!)
          BlockSimpleList(
            title: data,
            color: grey,
          ),

        //Section 5
        SectionTitle(title: '5. Redes de apoyo'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: followReport.orientation5 ?? ''),
        SpaceH12(),
        CustomItem(title: 'Redes de apoyo natural', content: followReport.informationNetworks ?? ''),
        SpaceH12(),
        CustomRow(title1: 'Redes de apoyo institucional', title2: 'Conciliación familiar', content1: followReport.institutionNetworks ?? '', content2: followReport.familyConciliation ?? ''),

        //Section7
        SectionTitle(title: '6. Idiomas'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: followReport.orientation7 ?? ''),
        SpaceH12(),
        pw.Column(
            children: [
              for(LanguageReport language in followReport.languages ?? [])
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
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: followReport.orientation9 ?? ''),
        SpaceH12(),
        CustomItem(title: 'Centro y TS de referencia', content: followReport.centerTSReference ?? ''),
        SpaceH12(),
        CustomItem(title: 'Destinataria de subvención y/o programa de apoyo', content: followReport.subsidyBeneficiary ?? ''),
        followReport.subsidyBeneficiary == 'Si' ? pw.Column(
            children: [
              CustomItem(title: 'Nombre/tipo', content: followReport.subsidyName ?? ''),
              SpaceH12(),
            ]
        ) : pw.Container(),
        SpaceH12(),
        CustomItem(title: 'Certificado de Exclusión Social', content: followReport.socialExclusionCertificate ?? ''),
        followReport.socialExclusionCertificate == 'Si' ? pw.Column(
            children: [
              CustomRow(title1: StringConst.INITIAL_DATE, title2: 'Observaciones sobre el certificado', content1: followReport.socialExclusionCertificateDate == null ? '' : formatter.format(followReport.socialExclusionCertificateDate!), content2: followReport.socialExclusionCertificateObservations ?? ''),
              SpaceH12(),
            ]
        ) : pw.Container(),

        //Section 12
        SectionTitle(title: '8. Situación de Vulnerabilidad'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: followReport.orientation12 ?? ''),
        SpaceH12(),
        for (var data in followReport.vulnerabilityOptions!)
          BlockSimpleList(
            title: data,
            color: grey,
          ),

        //Section 13
        SectionTitle(title: '9. Itinerario formativo laboral'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: followReport.orientation13 ?? ''),
        SubSectionTitle(title: StringConst.INITIAL_TITLE_9_3_TRAJECTORY),
        CustomItem(title: 'Competencias (competencias específicas, competencias prelaborales y competencias digitales)', content: followReport.competencies ?? ''),
        SpaceH12(),
        CustomItem(title: 'Contextualización del territorio', content: followReport.contextualization ?? ''),
        SpaceH12(),
        CustomItem(title: 'Conexión del entorno', content: followReport.connexion ?? ''),

        SubSectionTitle(title: StringConst.INITIAL_TITLE_9_4_EXPECTATIONS),
        CustomItem(title: 'Corto plazo', content: followReport.shortTerm ?? ''),
        SpaceH12(),
        CustomItem(title: 'Medio plazo', content: followReport.mediumTerm ?? ''),
        SpaceH12(),
        CustomItem(title: 'Largo plazo', content: followReport.longTerm ?? ''),

        //Subsection 9.5
        SubSectionTitle(title: StringConst.FOLLOW_TITLE_9_5_DEVELOP),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: followReport.orientation9_5 ?? ''),
        SubSectionTitle(title: StringConst.FOLLOW_FORMATIONS),
        pw.Column(
            children: [
              for(FormationReport formation in followReport.formations ?? [])
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
        CustomRow(title1: 'Bolsa de formación', title2: StringConst.INITIAL_DATE, content1: followReport.formationBag ?? '', content2: followReport.formationBagDate == null ? '' : formatter.format(followReport.formationBagDate!)),
        SpaceH12(),
        CustomRow(title1: StringConst.INITIAL_MOTIVE, title2: StringConst.FOLLOW_ECONOMIC_AMOUNT, content1: followReport.formationBagMotive ?? '', content2: followReport.formationBagEconomic ?? ''),

        SubSectionTitle(title: 'Empleo'),
        CustomRow(title1: 'Nivel educativo', title2: 'Situación laboral', content1: followReport.educationLevel ?? '', content2: followReport.laborSituation ?? ''),
        SpaceH12(),
        followReport.laborSituation == 'Ocupada cuenta propia' || followReport.laborSituation == 'Ocupada cuenta ajena' ?
        pw.Column(
            children: [
              CustomRow(title1: StringConst.INITIAL_TEMP, title2: 'Tipo jornada', content1: followReport.tempLabor ?? '', content2: followReport.workingDayLabor ?? ''),
              SpaceH12(),
            ]
        )
            : pw.Container(),
        CustomRow(title1: 'Fecha de obtención', title2: 'Fecha de finalización', content1: followReport.jobObtainDate == null ? '' : formatter.format(followReport.jobObtainDate!), content2: followReport.jobFinishDate == null ? '' : formatter.format(followReport.jobFinishDate!)),
        SpaceH12(),
        CustomRow(title1: 'Mejora laboral', title2: 'Motivo de mejora', content1: followReport.jobUpgrade ?? '', content2: followReport.upgradeMotive ?? ''),
        SpaceH12(),
        CustomItem(title: StringConst.INITIAL_DATE, content: followReport.upgradeDate == null ? '' : formatter.format(followReport.upgradeDate!)),

        SubSectionTitle(title: StringConst.FOLLOW_TITLE_9_6_POST_LABOR_ACCOMPANIMENT),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: followReport.orientation9_6 ?? ''),
        SpaceH12(),
        CustomItem(title: 'Acompañamiento post-laboral', content: followReport.postLaborAccompaniment ?? ''),
        followReport.postLaborAccompaniment == 'No' ?
            pw.Column(
              children: [
                SpaceH12(),
                CustomItem(title: StringConst.INITIAL_MOTIVE, content: followReport.postLaborAccompanimentMotive ?? ''),
              ]
            ): pw.Container(),
        SpaceH12(),
        CustomRow(title1: StringConst.FOLLOW_INIT_DATE, title2: StringConst.FOLLOW_END_DATE, content1: followReport.postLaborInitialDate == null ? '' : formatter.format(followReport.postLaborInitialDate!), content2: followReport.postLaborFinalDate == null ? '' : formatter.format(followReport.postLaborFinalDate!)),
        SpaceH12(),
        CustomItem(title: 'Total de días', content: followReport.postLaborTotalDays != null ? '' : followReport.postLaborTotalDays.toString()),
        SpaceH12(),
        CustomItem(title: 'Mantenimiento del empleo obtenido', content: followReport.jobMaintenance ?? ''),

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

pw.Widget SpaceH5(){
      return pw.SizedBox(height: 5);
}