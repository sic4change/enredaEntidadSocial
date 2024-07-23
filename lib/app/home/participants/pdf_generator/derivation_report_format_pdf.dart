import 'dart:async';
import 'dart:typed_data';

import 'package:enreda_empresas/app/home/participants/pdf_generator/common_widgets/bottom_signatures.dart';
import 'package:enreda_empresas/app/home/participants/pdf_generator/cv_print/data.dart';
import 'package:enreda_empresas/app/models/derivationReport.dart';
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

Future<Uint8List> generateDerivationReportFile(
    PdfPageFormat format,
    CustomData data,
    UserEnreda user,
    DerivationReport derivationReport,
    ) async {
  final doc = pw.Document(title: 'Reporte de seguimiento');

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
          'Reporte de derivación de ${user.firstName} ${user.lastName}',
            style: pw.Theme.of(context)
                .defaultTextStyle
                .copyWith(fontWeight: pw.FontWeight.bold, fontSize: 16, color: primary900)
        ),
        pw.SizedBox(
          height: 30,
        ),
        CustomItem(title: 'Subvención a la que el/la participante está imputado/a', content: derivationReport.subsidy ?? ''),
        SpaceH12(),
        CustomItem(title: 'Dirigido a:', content: derivationReport.addressedTo ?? ''),
        SpaceH12(),
        CustomItem(title: 'Con el objetivo de:', content: derivationReport.objectiveDerivation ?? ''),

        //Section 1
        derivationReport.allow1 ?? true ? pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            SectionTitle(title: '1. Itinerario en España'),
            CustomItem(title: 'Orinetaciones', content: derivationReport.orientation1 ?? ''),
            SpaceH12(),
            CustomRow(title1: 'Fecha de llegada a España', title2: 'Recursos de acogida', content1: derivationReport.arriveDate == null ? '' : formatter.format(derivationReport.arriveDate!), content2: derivationReport.receptionResources ?? ''),
            SpaceH12(),
            CustomItem(title: 'Situación administrativa', content: derivationReport.administrativeExternalResources ?? ''),

            //Subsection 1.1
            derivationReport.allow1_1 ?? true ? pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  SubSectionTitle(title: StringConst.INITIAL_TITLE_1_1_ADMINISTRATIVE_SITUATION),
                  CustomItem(title: StringConst.INITIAL_STATE, content: derivationReport.adminState ?? ''),
                  SpaceH12(),
                  derivationReport.adminState == 'Sin tramitar' ?
                  CustomItem(title: 'Sin tramitar', content: derivationReport.adminNoThrough ?? '') :
                  derivationReport.adminState == 'En trámite' ?
                  CustomRow(title1: 'Fecha de solicitud', title2: 'Fecha de resolución', content1: derivationReport.adminDateAsk == null ? '' : formatter.format(derivationReport.adminDateAsk!), content2: derivationReport.adminDateResolution == null ? '' : formatter.format(derivationReport.adminDateResolution!)) :
                  CustomItem(title: StringConst.INITIAL_DATE_CONCESSION, content: derivationReport.adminDateConcession == null ? '' : formatter.format(derivationReport.adminDateConcession!)),
                  SpaceH12(),
                  CustomRow(title1: StringConst.INITIAL_TEMP, title2: derivationReport.adminTemp == 'Inicial' || derivationReport.adminTemp == 'Temporal' ? 'Fecha de resolución' : '', content1: derivationReport.adminTemp ?? '', content2: derivationReport.adminTemp == 'Inicial' || derivationReport.adminTemp == 'Temporal' ?  derivationReport.adminDateRenovation == null ? '' : formatter.format(derivationReport.adminDateRenovation!) : ''),
                  SpaceH12(),
                  CustomRow(title1: 'Tipo de residencia', title2: StringConst.INITIAL_JURIDIC_FIGURE, content1: derivationReport.adminResidenceType ?? '', content2: derivationReport.adminJuridicFigure ?? ''),
                  derivationReport.adminJuridicFigure == 'Otros' ?pw.Column(
                      children: [
                        SpaceH12(),
                        CustomItem(title: StringConst.INITIAL_OTHERS, content: derivationReport.adminOther ?? '')
                      ]
                  ) : pw.Container(),
                ]
            ) : pw.Container(),
          ]
        ) : pw.Container(),



        //Section 2
        derivationReport.allow2 ?? true ? pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              SectionTitle(title: '2. Situación Sanitaria'),
              CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation2 ?? ''),
              SpaceH12(),
              CustomRow(title1: 'Tarjeta sanitaria', title2: 'Fecha de caducidad', content1: derivationReport.healthCard ?? '', content2: derivationReport.expirationDate == null ? '' : formatter.format(derivationReport.expirationDate!)),
              SpaceH12(),
              CustomItem(title: 'Medicación/Tratamiento', content: derivationReport.medication ?? ''),

              //Subsection 2.1
              derivationReport.allow2_1 ?? true ? pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    SubSectionTitle(title: '2.1 Salud Mental'),
                    CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation2_1 ?? ''),
                    SpaceH12(),
                    CustomRow(title1: 'Sueño y descanso', title2: 'Diagnostico', content1: derivationReport.rest ?? '', content2: derivationReport.diagnosis ?? ''),
                    SpaceH12(),
                    CustomRow(title1: 'Tratamiento', title2: 'Seguimiento', content1: derivationReport.treatment ?? '', content2: derivationReport.tracking ?? ''),
                  ]
              ) : pw.Container(),


              //Subsection 2.2
              derivationReport.allow2_2 ?? true ? pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    SubSectionTitle(title: '2.2 Discapacidad'),
                    CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation2_2 ?? ''),
                    SpaceH12(),
                    CustomItem(title: 'Estado', content: derivationReport.disabilityState ?? ''),
                    derivationReport.dependenceState == 'Concedida' ?
                    CustomRow(title1: 'Concedida', title2: 'Fecha', content1: derivationReport.granted ?? '', content2: derivationReport.revisionDate == null ? '' : formatter.format(derivationReport.revisionDate!)) :
                    pw.Container(),
                    derivationReport.dependenceState == 'Concedida' ? SpaceH12() : pw.Container(),
                    SpaceH12(),
                    CustomItem(title: 'Profesional de referencia', content: derivationReport.referenceProfessionalDisability ?? ''),
                    SpaceH12(),
                    CustomRow(title1: 'Grado de discapacidad', title2: 'Tipo de discapacidad', content1: derivationReport.disabilityGrade ?? '', content2: derivationReport.disabilityType ?? ''),
                  ]
              ) : pw.Container(),


              //Subsection 2.3
              derivationReport.allow2_3 ?? true ? pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    SubSectionTitle(title: '2.3 Dependencia'),
                    CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation2_3 ?? ''),
                    SpaceH12(),
                    CustomRow(title1: 'Estado', title2: 'Profesional de referencia', content1: derivationReport.dependenceState ?? '', content2: derivationReport.referenceProfessionalDependence ?? ''),
                    SpaceH12(),
                    CustomItem(title: 'Grado de dependencia', content: derivationReport.dependenceGrade ?? ''),
                  ]
              ) : pw.Container(),



              //Subsection 2.4
              derivationReport.allow2_4 ?? true ? pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    SubSectionTitle(title: '2.4 Adicciones'),
                    CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation2_4 ?? ''),
                    SpaceH12(),
                    CustomRow(title1: 'Derivación externa', title2: StringConst.INITIAL_MOTIVE, content1: derivationReport.externalDerivation ?? '', content2: derivationReport.motive ?? ''),
                  ]
              ) : pw.Container(),


            ]
        ) : pw.Container(),


        //Section 3
        derivationReport.allow3 ?? true ? pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              SectionTitle(title: '3. Situación legal'),
              CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation3 ?? ''),
              SpaceH12(),
              CustomRow(title1: 'Derivación interma', title2: StringConst.INITIAL_DERIVATION_DATE, content1: derivationReport.internalDerivationLegal ?? '', content2: derivationReport.internalDerivationDate == null ? '' : formatter.format(derivationReport.internalDerivationDate!)),
              SpaceH12(),
              CustomItem(title: StringConst.INITIAL_MOTIVE, content: derivationReport.internalDerivationMotive ?? ''),
              SpaceH12(),
              CustomRow(title1: 'Derivación externa', title2: StringConst.INITIAL_DERIVATION_DATE, content1: derivationReport.externalDerivationLegal ?? '', content2: derivationReport.externalDerivationDate == null ? '' : formatter.format(derivationReport.externalDerivationDate!)),
              SpaceH12(),
              CustomItem(title: StringConst.INITIAL_MOTIVE, content: derivationReport.externalDerivationMotive ?? ''),
              SpaceH12(),
              CustomRow(title1: 'Derivación interna al área psicosocial', title2: StringConst.INITIAL_DERIVATION_DATE, content1: derivationReport.psychosocialDerivationLegal ?? '', content2: derivationReport.psychosocialDerivationDate == null ? '' : formatter.format(derivationReport.psychosocialDerivationDate!)),
              SpaceH12(),
              CustomItem(title: StringConst.INITIAL_MOTIVE, content: derivationReport.psychosocialDerivationMotive ?? ''),
              SpaceH12(),
              CustomItem(title: 'Representación legal', content: derivationReport.legalRepresentation ?? ''),
              SpaceH12(),
              CustomRow(title1: 'Bolsa de tramitación', title2: StringConst.INITIAL_DATE, content1: derivationReport.processingBag ?? '', content2: derivationReport.processingBagDate == null ? '' : formatter.format(derivationReport.processingBagDate!)),
              SpaceH12(),
              CustomItem(title: 'Cuantia económica', content: derivationReport.economicAmount ?? ''),
            ]
        ) : pw.Container(),


        //Section 4
        derivationReport.allow4 ?? true ? pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              SectionTitle(title: 'Situación alojativa'),
              CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation4 ?? ''),
              SpaceH12(),
              CustomRow(title1: 'Situación alojativa', title2: derivationReport.ownershipType == 'Con hogar' ? 'Tipo de tenencia' : 'Situación sinhogarismo', content1: derivationReport.ownershipType ?? '', content2: derivationReport.ownershipType == 'Con hogar' ? (derivationReport.ownershipTypeConcrete ?? '') : (derivationReport.homelessnessSituation ?? '')),
              SpaceH12(),
              derivationReport.ownershipTypeConcrete == 'Otros' ? pw.Column(
                  children: [
                    CustomItem(title: StringConst.INITIAL_OTHERS, content: derivationReport.ownershipTypeOpen ?? ''),
                    SpaceH12(),
                  ]
              ) : pw.Container(),
              derivationReport.homelessnessSituation== 'Otros' ? pw.Column(
                  children: [
                    CustomItem(title: StringConst.INITIAL_OTHERS, content: derivationReport.homelessnessSituationOpen ?? ''),
                    SpaceH12(),
                  ]
              ) : pw.Container(),
              CustomItem(title: 'Datos de contacto del recurso alojativo', content: derivationReport.centerContact ?? ''),
              CustomItem(title: StringConst.INITIAL_LOCATION, content: derivationReport.location ?? ''),
              SpaceH12(),
              for (var data in derivationReport.hostingObservations!)
                BlockSimpleList(
                  title: data,
                  color: grey,
                ),
            ]
        ) : pw.Container(),



        //Section 5
        derivationReport.allow5 ?? true ? pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              SectionTitle(title: '5. Redes de apoyo'),
              CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation5 ?? ''),
              SpaceH12(),
              CustomItem(title: 'Redes de apoyo natural', content: derivationReport.informationNetworks ?? ''),
              SpaceH12(),
              CustomRow(title1: 'Redes de apoyo institucional', title2: 'Conciliación familiar', content1: derivationReport.institutionNetworks ?? '', content2: derivationReport.familyConciliation ?? ''),
            ]
        ) : pw.Container(),


        //Section7
        derivationReport.allow6 ?? true ? pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              SectionTitle(title: '6. Idiomas'),
              CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation7 ?? ''),
              SpaceH12(),
              pw.Column(
                  children: [
                    for(LanguageReport language in derivationReport.languages ?? [])
                      pw.Column(
                          children: [
                            CustomRow(title1: 'Idioma', title2: 'Reconocimiento / acreditación - nivel', content1: language.name, content2: language.level),
                            SpaceH12(),
                          ]
                      )
                  ]
              ),
            ]
        ) : pw.Container(),



        //Section 9
        derivationReport.allow7 ?? true ? pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              SectionTitle(title: '7. Atención social integral'),
              CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation9 ?? ''),
              SpaceH12(),
              CustomItem(title: 'Centro y TS de referencia', content: derivationReport.centerTSReference ?? ''),
              SpaceH12(),
              CustomItem(title: 'Destinataria de subvención y/o programa de apoyo', content: derivationReport.subsidyBeneficiary ?? ''),
              derivationReport.subsidyBeneficiary == 'Si' ? pw.Column(
                  children: [
                    CustomItem(title: 'Nombre/tipo', content: derivationReport.subsidyName ?? ''),
                    SpaceH12(),
                  ]
              ) : pw.Container(),
              SpaceH12(),
              CustomItem(title: 'Certificado de Exclusión Social', content: derivationReport.socialExclusionCertificate ?? ''),
              derivationReport.socialExclusionCertificate == 'Si' ? pw.Column(
                  children: [
                    CustomRow(title1: StringConst.INITIAL_DATE, title2: 'Observaciones sobre el certificado', content1: derivationReport.socialExclusionCertificateDate == null ? '' : formatter.format(derivationReport.socialExclusionCertificateDate!), content2: derivationReport.socialExclusionCertificateObservations ?? ''),
                    SpaceH12(),
                  ]
              ) : pw.Container(),
            ]
        ) : pw.Container(),



        //Section 12
        derivationReport.allow8 ?? true ? pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              SectionTitle(title: '8. Situación de Vulnerabilidad'),
              CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation12 ?? ''),
              SpaceH12(),
              for (var data in derivationReport.vulnerabilityOptions!)
                BlockSimpleList(
                  title: data,
                  color: grey,
                ),
            ]
        ) : pw.Container(),


        //Section 13
        derivationReport.allow9 ?? true ? pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              SectionTitle(title: '9. Itinerario formativo laboral'),
              CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation13 ?? ''),
              SubSectionTitle(title: StringConst.INITIAL_TITLE_9_3_TRAJECTORY),
              CustomItem(title: 'Competencias (competencias específicas, competencias prelaborales y competencias digitales)', content: derivationReport.competencies ?? ''),
              SpaceH12(),
              CustomItem(title: 'Contextualización del territorio', content: derivationReport.contextualization ?? ''),
              SpaceH12(),
              CustomItem(title: 'Conexión del entorno', content: derivationReport.connexion ?? ''),

              SubSectionTitle(title: StringConst.INITIAL_TITLE_9_4_EXPECTATIONS),
              CustomItem(title: 'Corto plazo', content: derivationReport.shortTerm ?? ''),
              SpaceH12(),
              CustomItem(title: 'Medio plazo', content: derivationReport.mediumTerm ?? ''),
              SpaceH12(),
              CustomItem(title: 'Largo plazo', content: derivationReport.longTerm ?? ''),

              //Subsection 9.5
              SubSectionTitle(title: StringConst.FOLLOW_TITLE_9_5_DEVELOP),
              CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation9_5 ?? ''),
              SubSectionTitle(title: StringConst.FOLLOW_FORMATIONS),
              pw.Column(
                  children: [
                    for(FormationReport formation in derivationReport.formations ?? [])
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
              CustomRow(title1: 'Bolsa de formación', title2: StringConst.INITIAL_DATE, content1: derivationReport.formationBag ?? '', content2: derivationReport.formationBagDate == null ? '' : formatter.format(derivationReport.formationBagDate!)),
              SpaceH12(),
              CustomRow(title1: StringConst.INITIAL_MOTIVE, title2: StringConst.FOLLOW_ECONOMIC_AMOUNT, content1: derivationReport.formationBagMotive ?? '', content2: derivationReport.formationBagEconomic ?? ''),

              SubSectionTitle(title: 'Empleo'),
              CustomRow(title1: 'Nivel educativo', title2: 'Situación laboral', content1: derivationReport.educationLevel ?? '', content2: derivationReport.laborSituation ?? ''),
              SpaceH12(),
              derivationReport.laborSituation == 'Ocupada cuenta propia' || derivationReport.laborSituation == 'Ocupada cuenta ajena' ?
              pw.Column(
                  children: [
                    CustomRow(title1: StringConst.INITIAL_TEMP, title2: 'Tipo jornada', content1: derivationReport.tempLabor ?? '', content2: derivationReport.workingDayLabor ?? ''),
                    SpaceH12(),
                  ]
              )
                  : pw.Container(),
              CustomRow(title1: 'Fecha de obtención', title2: 'Fecha de finalización', content1: derivationReport.jobObtainDate == null ? '' : formatter.format(derivationReport.jobObtainDate!), content2: derivationReport.jobFinishDate == null ? '' : formatter.format(derivationReport.jobFinishDate!)),
              SpaceH12(),
              CustomRow(title1: 'Mejora laboral', title2: 'Motivo de mejora', content1: derivationReport.jobUpgrade ?? '', content2: derivationReport.upgradeMotive ?? ''),
              SpaceH12(),
              CustomItem(title: StringConst.INITIAL_DATE, content: derivationReport.upgradeDate == null ? '' : formatter.format(derivationReport.upgradeDate!)),

              SubSectionTitle(title: StringConst.FOLLOW_TITLE_9_6_POST_LABOR_ACCOMPANIMENT),
              CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation9_6 ?? ''),
              SpaceH12(),
              CustomItem(title: 'Acompañamiento post-laboral', content: derivationReport.postLaborAccompaniment ?? ''),
              derivationReport.postLaborAccompaniment == 'No' ?
              pw.Column(
                  children: [
                    SpaceH12(),
                    CustomItem(title: StringConst.INITIAL_MOTIVE, content: derivationReport.postLaborAccompanimentMotive ?? ''),
                  ]
              ): pw.Container(),
              SpaceH12(),
              CustomRow(title1: StringConst.FOLLOW_INIT_DATE, title2: StringConst.FOLLOW_END_DATE, content1: derivationReport.postLaborInitialDate == null ? '' : formatter.format(derivationReport.postLaborInitialDate!), content2: derivationReport.postLaborFinalDate == null ? '' : formatter.format(derivationReport.postLaborFinalDate!)),
              SpaceH12(),
              CustomItem(title: 'Total de días', content: derivationReport.postLaborTotalDays == null ? '' : derivationReport.postLaborTotalDays.toString()),
              SpaceH12(),
              CustomItem(title: 'Mantenimiento del empleo obtenido', content: derivationReport.jobMaintenance ?? ''),
            ]
        ) : pw.Container(),

        SpaceH12(),
        BottomSignatures()
        
      ]
    )
  );
  return doc.save();
}

pw.Widget SpaceH12(){
  return pw.SizedBox(height: 12);
}



