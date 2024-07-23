import 'dart:async';
import 'dart:typed_data';

import 'package:enreda_empresas/app/home/participants/pdf_generator/common_widgets/text_formats.dart';
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

Future<Uint8List> generateInitialReportFile(
    PdfPageFormat format,
    CustomData data,
    UserEnreda user,
    InitialReport initialReport,
    ) async {
  final doc = pw.Document(title: 'Reporte inicial');

  format = format.applyMargin(
      left: 2.0 * PdfPageFormat.cm,
      top: 3.0 * PdfPageFormat.cm,
      right: 2.0 * PdfPageFormat.cm,
      bottom: 2.0 * PdfPageFormat.cm);

  final pageTheme = await MyPageTheme(format);
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

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
          'Reporte inicial de ${user.firstName} ${user.lastName}',
          textAlign: pw.TextAlign.center,
          style: pw.Theme.of(context)
              .defaultTextStyle
              .copyWith(fontWeight: pw.FontWeight.bold, fontSize: 16, color: primary900)
        ),
        pw.SizedBox(
          height: 30,
        ),
        CustomItem(title: 'Subvención a la que el/la participante está imputado/a', content: initialReport.subsidy ?? ''),

        //Section 1
        SectionTitle(title: '1. Itinerario en España'),
        CustomItem(title: 'Orientaciones:', content: initialReport.orientation1 ?? ''),
        SpaceH5(),
        CustomRow(title1: 'Fecha de llegada a España', title2: 'Recursos de acogida', content1: initialReport.arriveDate == null ? '' : formatter.format(initialReport.arriveDate!) , content2: initialReport.receptionResources ?? ''),
        SpaceH5(),
        CustomItem(title: 'Situación administrativa', content: initialReport.administrativeExternalResources ?? ''),

        //Subsection 1.1
        SubSectionTitle(title: StringConst.INITIAL_TITLE_1_1_ADMINISTRATIVE_SITUATION),
        CustomItem(title: StringConst.INITIAL_STATE, content: initialReport.adminState ?? ''),
        SpaceH5(),
        initialReport.adminState == 'Sin tramitar' ?
        CustomItem(title: 'Sin tramitar', content: initialReport.adminNoThrough ?? '') :
            initialReport.adminState == 'En trámite' ?
            CustomRow(title1: 'Fecha de solicitud', title2: 'Fecha de resolución', content1: initialReport.adminDateAsk == null ? '' : formatter.format(initialReport.adminDateAsk!), content2: initialReport.adminDateResolution == null ? '' : formatter.format(initialReport.adminDateResolution!)) :
            CustomItem(title: StringConst.INITIAL_DATE_CONCESSION, content: initialReport.adminDateConcession == null ? '' : formatter.format(initialReport.adminDateConcession!)),
        SpaceH5(),
        CustomRow(title1: StringConst.INITIAL_TEMP, title2: initialReport.adminTemp == 'Inicial' || initialReport.adminTemp == 'Temporal' ? 'Fecha de resolución' : '', content1: initialReport.adminTemp ?? '', content2: initialReport.adminTemp == 'Inicial' || initialReport.adminTemp == 'Temporal' ? initialReport.adminDateRenovation == null ? '' : formatter.format(initialReport.adminDateRenovation!) : ''),
        SpaceH5(),
        CustomRow(title1: 'Tipo de residencia', title2: StringConst.INITIAL_JURIDIC_FIGURE, content1: initialReport.adminResidenceType ?? '', content2: initialReport.adminJuridicFigure ?? ''),
        initialReport.adminJuridicFigure == 'Otros' ?pw.Column(
          children: [
            SpaceH5(),
            CustomItem(title: StringConst.INITIAL_OTHERS, content: initialReport.adminOther ?? '')
          ]
        ) : pw.Container(),

        //Section 2
        SectionTitle(title: '2. Situación Sanitaria'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: initialReport.orientation2 ?? ''),
        SpaceH5(),
        CustomRow(title1: 'Tarjeta sanitaria', title2: 'Fecha de caducidad', content1: initialReport.healthCard ?? '', content2: initialReport.expirationDate == null ? '' : formatter.format(initialReport.expirationDate!)),
        SpaceH5(),
        CustomItem(title: 'Medicación/Tratamiento', content: initialReport.medication ?? ''),

        //Subsection 2.1
        SubSectionTitle(title: '2.1 Salud Mental'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: initialReport.orientation2_1 ?? ''),
        SpaceH5(),
        CustomRow(title1: 'Sueño y descanso', title2: 'Diagnostico', content1: initialReport.rest ?? '', content2: initialReport.diagnosis ?? ''),
        SpaceH5(),
        CustomRow(title1: 'Tratamiento', title2: 'Seguimiento', content1: initialReport.treatment ?? '', content2: initialReport.tracking ?? ''),

        //Subsection 2.2
        SubSectionTitle(title: '2.2 Discapacidad'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: initialReport.orientation2_2 ?? ''),
        SpaceH5(),
        CustomItem(title: 'Estado', content: initialReport.disabilityState ?? ''),
        initialReport.dependenceState == 'Concedida' ?
          CustomRow(title1: 'Concedida', title2: 'Fecha', content1: initialReport.granted ?? '', content2: initialReport.revisionDate == null ? '' : formatter.format(initialReport.revisionDate!)) :
          pw.Container(),
        initialReport.dependenceState == 'Concedida' ? SpaceH5() : pw.Container(),
        SpaceH5(),
        CustomItem(title: 'Profesional de referencia', content: initialReport.referenceProfessionalDisability ?? ''),
        SpaceH5(),
        CustomRow(title1: 'Grado de discapacidad', title2: 'Tipo de discapacidad', content1: initialReport.disabilityGrade ?? '', content2: initialReport.disabilityType ?? ''),

        //Subsection 2.3
        SubSectionTitle(title: '2.3 Dependencia'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: initialReport.orientation2_3 ?? ''),
        SpaceH5(),
        CustomRow(title1: 'Estado', title2: 'Profesional de referencia', content1: initialReport.dependenceState ?? '', content2: initialReport.referenceProfessionalDependence ?? ''),
        SpaceH5(),
        CustomItem(title: 'Grado de dependencia', content: initialReport.dependenceGrade ?? ''),

        //Subsection 2.4
        SubSectionTitle(title: '2.4 Adicciones'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: initialReport.orientation2_4 ?? ''),
        SpaceH5(),
        CustomRow(title1: 'Derivación externa', title2: StringConst.INITIAL_MOTIVE, content1: initialReport.externalDerivation ?? '', content2: initialReport.motive ?? ''),

        //Section 3
        SectionTitle(title: '3. Situación legal'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: initialReport.orientation3 ?? ''),
        SpaceH5(),
        CustomRow(title1: 'Derivación interma', title2: StringConst.INITIAL_DERIVATION_DATE, content1: initialReport.internalDerivationLegal ?? '', content2: initialReport.internalDerivationDate == null ? '' : formatter.format(initialReport.internalDerivationDate!)),
        SpaceH5(),
        CustomItem(title: StringConst.INITIAL_MOTIVE, content: initialReport.internalDerivationMotive ?? ''),
        SpaceH5(),
        CustomRow(title1: 'Derivación externa', title2: StringConst.INITIAL_DERIVATION_DATE, content1: initialReport.externalDerivationLegal ?? '', content2: initialReport.externalDerivationDate == null ? '' : formatter.format(initialReport.externalDerivationDate!)),
        SpaceH5(),
        CustomItem(title: StringConst.INITIAL_MOTIVE, content: initialReport.externalDerivationMotive ?? ''),
        SpaceH5(),
        CustomRow(title1: 'Derivación interna al área psicosocial', title2: StringConst.INITIAL_DERIVATION_DATE, content1: initialReport.psychosocialDerivationLegal ?? '', content2: initialReport.psychosocialDerivationDate == null ? '' : formatter.format(initialReport.psychosocialDerivationDate!)),
        SpaceH5(),
        CustomItem(title: StringConst.INITIAL_MOTIVE, content: initialReport.psychosocialDerivationMotive ?? ''),
        SpaceH5(),
        CustomItem(title: 'Representación legal', content: initialReport.legalRepresentation ?? ''),

        //Section 4
        SectionTitle(title: '4. Situación alojativa'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: initialReport.orientation4 ?? ''),
        SpaceH5(),
        CustomRow(title1: 'Situación alojativa', title2: initialReport.ownershipType == 'Con hogar' ? 'Tipo de tenencia' : 'Situación sinhogarismo', content1: initialReport.ownershipType ?? '', content2: initialReport.ownershipType == 'Con hogar' ? (initialReport.ownershipTypeConcrete ?? '') : (initialReport.homelessnessSituation ?? '')),
        SpaceH5(),
        initialReport.ownershipTypeConcrete == 'Otros' ? pw.Column(
          children: [
            CustomItem(title: StringConst.INITIAL_OTHERS, content: initialReport.ownershipTypeOpen ?? ''),
            SpaceH5(),
          ]
        ) : pw.Container(),
        initialReport.homelessnessSituation== 'Otros' ? pw.Column(
            children: [
              CustomItem(title: StringConst.INITIAL_OTHERS, content: initialReport.homelessnessSituationOpen ?? ''),
              SpaceH5(),
            ]
        ) : pw.Container(),
        CustomItem(title: 'Datos de contacto del recurso alojativo', content: initialReport.centerContact ?? ''),
        CustomItem(title: StringConst.INITIAL_LOCATION, content: initialReport.location ?? ''),
        SpaceH5(),
        //_customEnumeration(enumeration: initialReport.hostingObservations ?? []),
        for (var data in initialReport.hostingObservations!)
          BlockSimpleList(
            title: data,
            color: grey,
          ),

        //Section 5
        SectionTitle(title: '5. Redes de apoyo'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: initialReport.orientation5 ?? ''),
        SpaceH5(),
        CustomItem(title: 'Redes de apoyo natural', content: initialReport.informationNetworks ?? ''),
        SpaceH5(),
        CustomRow(title1: 'Redes de apoyo institucional', title2: 'Conciliación familiar', content1: initialReport.institutionNetworks ?? '', content2: initialReport.familyConciliation ?? ''),

        //Section7
        SectionTitle(title: '6. Idiomas'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: initialReport.orientation7 ?? ''),
        SpaceH5(),
        pw.Column(
          children: [
            for(LanguageReport language in initialReport.languages ?? [])
              pw.Column(
                children: [
                  CustomRow(title1: 'Idioma', title2: 'Reconocimiento / acreditación - nivel', content1: language.name, content2: language.level),
                  SpaceH5(),
                ]
              )
          ]
        ),

        //Section 9
        SectionTitle(title: '7. Atención social integral'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: initialReport.orientation9 ?? ''),
        SpaceH5(),
        CustomItem(title: 'Centro y TS de referencia', content: initialReport.centerTSReference ?? ''),
        SpaceH5(),
        CustomItem(title: 'Destinataria de subvención y/o programa de apoyo', content: initialReport.subsidyBeneficiary ?? ''),
        initialReport.subsidyBeneficiary == 'Si' ? pw.Column(
          children: [
            CustomItem(title: 'Nombre/tipo', content: initialReport.subsidyName ?? ''),
            SpaceH5(),
          ]
        ) : pw.Container(),
        SpaceH5(),
        CustomItem(title: 'Certificado de Exclusión Social', content: initialReport.socialExclusionCertificate ?? ''),
        initialReport.socialExclusionCertificate == 'Si' ? pw.Column(
            children: [
              CustomRow(title1: StringConst.INITIAL_DATE, title2: 'Observaciones sobre el certificado', content1: initialReport.socialExclusionCertificateDate == null ? '' : formatter.format(initialReport.socialExclusionCertificateDate!), content2: initialReport.socialExclusionCertificateObservations ?? ''),
              SpaceH5(),
            ]
        ) : pw.Container(),

        //Section 12
        SectionTitle(title: '8. Situación de Vulnerabilidad'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: initialReport.orientation12 ?? ''),
        SpaceH5(),
        //_customEnumeration(enumeration: initialReport.vulnerabilityOptions!.isNotEmpty ? initialReport.vulnerabilityOptions ?? [] : []),
        for (var data in initialReport.vulnerabilityOptions!)
          BlockSimpleList(
            title: data,
            color: grey,
          ),


        //Section 13
        SectionTitle(title: '9. Itinerario formativo laboral'),
        CustomItem(title: StringConst.INITIAL_OBSERVATIONS, content: initialReport.orientation13 ?? ''),
        SpaceH5(),
        CustomRow(title1: 'Nivel educativo', title2: 'Situación laboral', content1: initialReport.educationLevel ?? '', content2: initialReport.laborSituation ?? ''),
        SpaceH5(),
        initialReport.laborSituation == 'Ocupada cuenta propia' || initialReport.laborSituation == 'Ocupada cuenta ajena' ?
            pw.Column(
              children: [
                CustomRow(title1: StringConst.INITIAL_TEMP, title2: 'Tipo jornada', content1: initialReport.tempLabor ?? '', content2: initialReport.workingDayLabor ?? ''),
                SpaceH5(),
              ]
            )
         : pw.Container(),
        SubSectionTitle(title: StringConst.INITIAL_TITLE_9_3_TRAJECTORY),
        CustomItem(title: 'Competencias (competencias específicas, competencias prelaborales y competencias digitales)', content: initialReport.competencies ?? ''),
        SpaceH5(),
        CustomItem(title: 'Contextualización del territorio', content: initialReport.contextualization ?? ''),
        SpaceH5(),
        CustomItem(title: 'Conexión del entorno', content: initialReport.connexion ?? ''),

        SubSectionTitle(title: StringConst.INITIAL_TITLE_9_4_EXPECTATIONS),
        CustomItem(title: 'Corto plazo', content: initialReport.shortTerm ?? ''),
        SpaceH5(),
        CustomItem(title: 'Medio plazo', content: initialReport.mediumTerm ?? ''),
        SpaceH5(),
        CustomItem(title: 'Largo plazo', content: initialReport.longTerm ?? ''),

        SpaceH5(),
        BottomSignatures(),
      ]
    )
  );
  return doc.save();
}

pw.Widget SpaceH5(){
  return pw.SizedBox(height: 5);
}







