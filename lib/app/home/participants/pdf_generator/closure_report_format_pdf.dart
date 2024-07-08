import 'dart:async';
import 'dart:typed_data';

import 'package:enreda_empresas/app/home/participants/pdf_generator/cv_print/data.dart';
import 'package:enreda_empresas/app/models/certificationRequest.dart';
import 'package:enreda_empresas/app/models/closureReport.dart';
import 'package:enreda_empresas/app/models/experience.dart';
import 'package:enreda_empresas/app/models/closureReport.dart';
import 'package:enreda_empresas/app/models/closureReport.dart';
import 'package:enreda_empresas/app/models/formationReport.dart';
import 'package:enreda_empresas/app/models/ipilEntry.dart';
import 'package:enreda_empresas/app/models/languageReport.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show NetworkAssetBundle, rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';



const PdfColor lilac = PdfColor.fromInt(0xFF6768AB);
const PdfColor lightLilac = PdfColor.fromInt(0xFFF4F5FB);
const PdfColor blue = PdfColor.fromInt(0xFF002185);
const PdfColor grey = PdfColor.fromInt(0xFF535A5F);
const PdfColor greyDark = PdfColor.fromInt(0xFF44494B);
const PdfColor green = PdfColor.fromInt(0xF0DA1A0);
const PdfColor black = PdfColor.fromInt(0xF44494B);
const PdfColor white = PdfColor.fromInt(0xFFFFFFFF);
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

  var url = user?.profilePic?.src ?? "";


  PdfPageFormat format1 = format.applyMargin(
      left: 0,
      top: 0,
      right: 2.0 * PdfPageFormat.cm,
      bottom: 2.0 * PdfPageFormat.cm);
/*
  final pageTheme = await _myPageTheme(format1, myPhoto, profileImage);
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  List<String>? dataOfInterest = myDataOfInterest;
  List<String>? languages = languagesNames;*/

  doc.addPage(
    pw.MultiPage(
      //pageTheme: pageTheme,
      build: (pw.Context context) => [
        pw.Text(
          'Reporte de cierre de ${user.firstName} ${user.lastName}',
          style: pw.TextStyle(
            fontSize: 23,
          )
        ),
        pw.SizedBox(
          height: 30,
        ),
        _customItem(title: 'Subvención a la que el/la participante está imputado/a', content: closureReport.subsidy ?? ''),

        //Section 1
        _sectionTitle(title: '1. Itinerario en España'),
        _customItem(title: 'Orinetaciones', content: closureReport.orientation1 ?? ''),
        SpaceH12(),
        _customRow(title1: 'Fecha de llegada a España', title2: 'Recursos de acogida', content1: formatter.format(closureReport.arriveDate!) ?? '', content2: closureReport.receptionResources ?? ''),
        SpaceH12(),
        _customItem(title: 'Situación administrativa', content: closureReport.administrativeExternalResources ?? ''),

        //Subsection 1.1
        _subSectionTitle(title: StringConst.INITIAL_TITLE_1_1_ADMINISTRATIVE_SITUATION),
        _customItem(title: StringConst.INITIAL_STATE, content: closureReport.adminState ?? ''),
        SpaceH12(),
        closureReport.adminState == 'Sin tramitar' ?
        _customItem(title: 'Sin tramitar', content: closureReport.adminNoThrough ?? '') :
        closureReport.adminState == 'En trámite' ?
        _customRow(title1: 'Fecha de solicitud', title2: 'Fecha de resolución', content1: formatter.format(closureReport.adminDateAsk!) ?? '', content2: formatter.format(closureReport.adminDateResolution!) ?? '') :
        _customItem(title: StringConst.INITIAL_DATE_CONCESSION, content: formatter.format(closureReport.adminDateConcession!)),
        SpaceH12(),
        _customRow(title1: StringConst.INITIAL_TEMP, title2: closureReport.adminTemp == 'Inicial' || closureReport.adminTemp == 'Temporal' ? 'Fecha de resolución' : '', content1: closureReport.adminTemp ?? '', content2: closureReport.adminTemp == 'Inicial' || closureReport.adminTemp == 'Temporal' ? formatter.format(closureReport.adminDateRenovation!) ?? '' : ''),
        SpaceH12(),
        _customRow(title1: 'Tipo de residencia', title2: StringConst.INITIAL_JURIDIC_FIGURE, content1: closureReport.adminResidenceType ?? '', content2: closureReport.adminJuridicFigure ?? ''),
        closureReport.adminJuridicFigure == 'Otros' ?pw.Column(
            children: [
              SpaceH12(),
              _customItem(title: StringConst.INITIAL_OTHERS, content: closureReport.adminOther ?? '')
            ]
        ) : pw.Container(),

        //Section 2
        _sectionTitle(title: '2. Situación Sanitaria'),
        _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation2 ?? ''),
        SpaceH12(),
        _customRow(title1: 'Tarjeta sanitaria', title2: 'Fecha de caducidad', content1: closureReport.healthCard ?? '', content2: formatter.format(closureReport.expirationDate!) ?? ''),
        SpaceH12(),
        _customItem(title: 'Medicación/Tratamiento', content: closureReport.medication ?? ''),

        //Subsection 2.1
        _subSectionTitle(title: '2.1 Salud Mental'),
        _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation2_1 ?? ''),
        SpaceH12(),
        _customRow(title1: 'Sueño y descanso', title2: 'Diagnostico', content1: closureReport.rest ?? '', content2: closureReport.diagnosis ?? ''),
        SpaceH12(),
        _customRow(title1: 'Tratamiento', title2: 'Seguimiento', content1: closureReport.treatment ?? '', content2: closureReport.tracking ?? ''),

        //Subsection 2.2
        _subSectionTitle(title: '2.2 Discapacidad'),
        _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation2_2 ?? ''),
        SpaceH12(),
        _customItem(title: 'Estado', content: closureReport.disabilityState ?? ''),
        closureReport.dependenceState == 'Concedida' ?
        _customRow(title1: 'Concedida', title2: 'Fecha', content1: closureReport.granted ?? '', content2: formatter.format(closureReport.revisionDate!) ?? '') :
        pw.Container(),
        closureReport.dependenceState == 'Concedida' ? SpaceH12() : pw.Container(),
        SpaceH12(),
        _customItem(title: 'Profesional de referencia', content: closureReport.referenceProfessionalDisability ?? ''),
        SpaceH12(),
        _customRow(title1: 'Grado de discapacidad', title2: 'Tipo de discapacidad', content1: closureReport.disabilityGrade ?? '', content2: closureReport.disabilityType ?? ''),

        //Subsection 2.3
        _subSectionTitle(title: '2.3 Dependencia'),
        _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation2_3 ?? ''),
        SpaceH12(),
        _customRow(title1: 'Estado', title2: 'Profesional de referencia', content1: closureReport.dependenceState ?? '', content2: closureReport.referenceProfessionalDependence ?? ''),
        SpaceH12(),
        _customItem(title: 'Grado de dependencia', content: closureReport.dependenceGrade ?? ''),

        //Subsection 2.4
        _subSectionTitle(title: '2.4 Adicciones'),
        _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation2_4 ?? ''),
        SpaceH12(),
        _customRow(title1: 'Derivación externa', title2: StringConst.INITIAL_MOTIVE, content1: closureReport.externalDerivation ?? '', content2: closureReport.motive ?? ''),

        //Section 3
        _sectionTitle(title: '3. Situación legal'),
        _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation3 ?? ''),
        SpaceH12(),
        _customRow(title1: 'Derivación interma', title2: StringConst.INITIAL_DERIVATION_DATE, content1: closureReport.internalDerivationLegal ?? '', content2: formatter.format(closureReport.internalDerivationDate!) ?? ''),
        SpaceH12(),
        _customItem(title: StringConst.INITIAL_MOTIVE, content: closureReport.internalDerivationMotive ?? ''),
        SpaceH12(),
        _customRow(title1: 'Derivación externa', title2: StringConst.INITIAL_DERIVATION_DATE, content1: closureReport.externalDerivationLegal ?? '', content2: formatter.format(closureReport.externalDerivationDate!) ?? ''),
        SpaceH12(),
        _customItem(title: StringConst.INITIAL_MOTIVE, content: closureReport.externalDerivationMotive ?? ''),
        SpaceH12(),
        _customRow(title1: 'Derivación interna al área psicosocial', title2: StringConst.INITIAL_DERIVATION_DATE, content1: closureReport.psychosocialDerivationLegal ?? '', content2: formatter.format(closureReport.psychosocialDerivationDate!) ?? ''),
        SpaceH12(),
        _customItem(title: StringConst.INITIAL_MOTIVE, content: closureReport.psychosocialDerivationMotive ?? ''),
        SpaceH12(),
        _customItem(title: 'Representación legal', content: closureReport.legalRepresentation ?? ''),
        SpaceH12(),
        _customRow(title1: 'Bolsa de tramitación', title2: StringConst.INITIAL_DATE, content1: closureReport.processingBag ?? '', content2: formatter.format(closureReport.processingBagDate!) ?? ''),
        SpaceH12(),
        _customItem(title: 'Cuantia económica', content: closureReport.economicAmount ?? ''),

        //Section 4
        _sectionTitle(title: 'Situación alojativa'),
        _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation4 ?? ''),
        SpaceH12(),
        _customRow(title1: 'Situación alojativa', title2: closureReport.ownershipType == 'Con hogar' ? 'Tipo de tenencia' : 'Situación sinhogarismo', content1: closureReport.ownershipType ?? '', content2: closureReport.ownershipType == 'Con hogar' ? (closureReport.ownershipTypeConcrete ?? '') : (closureReport.homelessnessSituation ?? '')),
        SpaceH12(),
        closureReport.ownershipTypeConcrete == 'Otros' ? pw.Column(
            children: [
              _customItem(title: StringConst.INITIAL_OTHERS, content: closureReport.ownershipTypeOpen ?? ''),
              SpaceH12(),
            ]
        ) : pw.Container(),
        closureReport.homelessnessSituation== 'Otros' ? pw.Column(
            children: [
              _customItem(title: StringConst.INITIAL_OTHERS, content: closureReport.homelessnessSituationOpen ?? ''),
              SpaceH12(),
            ]
        ) : pw.Container(),
        _customItem(title: 'Datos de contacto del recurso alojativo', content: closureReport.centerContact ?? ''),
        _customItem(title: StringConst.INITIAL_LOCATION, content: closureReport.location ?? ''),
        SpaceH12(),
        _customEnumeration(enumeration: closureReport.hostingObservations ?? []),

        //Section 5
        _sectionTitle(title: '5. Redes de apoyo'),
        _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation5 ?? ''),
        SpaceH12(),
        _customItem(title: 'Redes de apoyo natural', content: closureReport.informationNetworks ?? ''),
        SpaceH12(),
        _customRow(title1: 'Redes de apoyo institucional', title2: 'Conciliación familiar', content1: closureReport.institutionNetworks ?? '', content2: closureReport.familyConciliation ?? ''),

        //Section7
        _sectionTitle(title: '6. Idiomas'),
        _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation7 ?? ''),
        SpaceH12(),
        pw.Column(
            children: [
              for(LanguageReport language in closureReport.languages ?? [])
                pw.Column(
                    children: [
                      _customRow(title1: 'Idioma', title2: 'Reconocimiento / acreditación - nivel', content1: language.name, content2: language.level),
                      SpaceH12(),
                    ]
                )
            ]
        ),

        //Section 9
        _sectionTitle(title: '7. Atención social integral'),
        _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation9 ?? ''),
        SpaceH12(),
        _customItem(title: 'Centro y TS de referencia', content: closureReport.centerTSReference ?? ''),
        SpaceH12(),
        _customItem(title: 'Destinataria de subvención y/o programa de apoyo', content: closureReport.subsidyBeneficiary ?? ''),
        closureReport.subsidyBeneficiary == 'Si' ? pw.Column(
            children: [
              _customItem(title: 'Nombre/tipo', content: closureReport.subsidyName ?? ''),
              SpaceH12(),
            ]
        ) : pw.Container(),
        SpaceH12(),
        _customItem(title: 'Certificado de Exclusión Social', content: closureReport.socialExclusionCertificate ?? ''),
        closureReport.socialExclusionCertificate == 'Si' ? pw.Column(
            children: [
              _customRow(title1: StringConst.INITIAL_DATE, title2: 'Observaciones sobre el certificado', content1: formatter.format(closureReport.socialExclusionCertificateDate!) ?? '', content2: closureReport.socialExclusionCertificateObservations ?? ''),
              SpaceH12(),
            ]
        ) : pw.Container(),

        //Section 12
        _sectionTitle(title: '8. Situación de Vulnerabilidad'),
        _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation12 ?? ''),
        SpaceH12(),
        _customEnumeration(enumeration: closureReport.vulnerabilityOptions ?? []),

        //Section 13
        _sectionTitle(title: '9. Itinerario formativo laboral'),
        _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation13 ?? ''),
        _subSectionTitle(title: StringConst.INITIAL_TITLE_9_3_TRAJECTORY),
        _customItem(title: 'Competencias (competencias específicas, competencias prelaborales y competencias digitales)', content: closureReport.competencies ?? ''),
        SpaceH12(),
        _customItem(title: 'Contextualización del territorio', content: closureReport.contextualization ?? ''),
        SpaceH12(),
        _customItem(title: 'Conexión del entorno', content: closureReport.connexion ?? ''),

        _subSectionTitle(title: StringConst.INITIAL_TITLE_9_4_EXPECTATIONS),
        _customItem(title: 'Corto plazo', content: closureReport.shortTerm ?? ''),
        SpaceH12(),
        _customItem(title: 'Medio plazo', content: closureReport.mediumTerm ?? ''),
        SpaceH12(),
        _customItem(title: 'Largo plazo', content: closureReport.longTerm ?? ''),

        //Subsection 9.5
        _subSectionTitle(title: StringConst.FOLLOW_TITLE_9_5_DEVELOP),
        _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation9_5 ?? ''),
        _subSectionTitle(title: StringConst.FOLLOW_FORMATIONS),
        pw.Column(
            children: [
              for(FormationReport formation in closureReport.formations ?? [])
                pw.Column(
                    children: [
                      _customRow(title1: 'Nombre de la formación', title2: 'Tipo de formación', content1: formation.name, content2: formation.type),
                      SpaceH12(),
                      _customItem(title: 'Certificación', content: formation.certification),
                      SpaceH12(),
                    ]
                )
            ]
        ),
        _customRow(title1: 'Bolsa de formación', title2: StringConst.INITIAL_DATE, content1: closureReport.formationBag ?? '', content2: formatter.format(closureReport.formationBagDate!) ?? ''),
        SpaceH12(),
        _customRow(title1: StringConst.INITIAL_MOTIVE, title2: StringConst.FOLLOW_ECONOMIC_AMOUNT, content1: closureReport.formationBagMotive ?? '', content2: closureReport.formationBagEconomic ?? ''),

        _subSectionTitle(title: 'Empleo'),
        _customRow(title1: 'Nivel educativo', title2: 'Situación laboral', content1: closureReport.educationLevel ?? '', content2: closureReport.laborSituation ?? ''),
        SpaceH12(),
        closureReport.laborSituation == 'Ocupada cuenta propia' || closureReport.laborSituation == 'Ocupada cuenta ajena' ?
        pw.Column(
            children: [
              _customRow(title1: StringConst.INITIAL_TEMP, title2: 'Tipo jornada', content1: closureReport.tempLabor ?? '', content2: closureReport.workingDayLabor ?? ''),
              SpaceH12(),
            ]
        )
            : pw.Container(),
        _customRow(title1: 'Fecha de obtención', title2: 'Fecha de finalización', content1: formatter.format(closureReport.jobObtainDate!) ?? '', content2: formatter.format(closureReport.jobFinishDate!) ?? ''),
        SpaceH12(),
        _customRow(title1: 'Mejora laboral', title2: 'Motivo de mejora', content1: closureReport.jobUpgrade ?? '', content2: closureReport.upgradeMotive ?? ''),
        SpaceH12(),
        _customItem(title: StringConst.INITIAL_DATE, content: formatter.format(closureReport.upgradeDate!) ?? '' ),

        _subSectionTitle(title: StringConst.FOLLOW_TITLE_9_6_POST_LABOR_ACCOMPANIMENT),
        _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation9_6 ?? ''),
        SpaceH12(),
        _customItem(title: 'Acompañamiento post-laboral', content: closureReport.postLaborAccompaniment ?? ''),
        closureReport.postLaborAccompaniment == 'No' ?
        pw.Column(
            children: [
              SpaceH12(),
              _customItem(title: StringConst.INITIAL_MOTIVE, content: closureReport.postLaborAccompanimentMotive ?? ''),
            ]
        ): pw.Container(),
        SpaceH12(),
        _customRow(title1: StringConst.FOLLOW_INIT_DATE, title2: StringConst.FOLLOW_END_DATE, content1: formatter.format(closureReport.postLaborInitialDate!) ?? '', content2: formatter.format(closureReport.postLaborFinalDate!) ?? ''),
        SpaceH12(),
        _customItem(title: 'Total de días', content: closureReport.postLaborTotalDays.toString() ?? ''),
        SpaceH12(),
        _customItem(title: 'Mantenimiento del empleo obtenido', content: closureReport.jobMaintenance ?? ''),
        _sectionTitle(title: StringConst.CLOSURE_TITLE_10),
        _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: closureReport.orientation10 ?? ''),
        SpaceH12(),
        _customItem(title: StringConst.CLOSURE_CLOSE_MOTIVE, content: closureReport.motiveClose ?? ''),
        SpaceH12(),
        _customRow(title1: StringConst.CLOSURE_CLOSE_MOTIVE_DETAIL, title2: StringConst.INITIAL_DATE, content1: closureReport.motiveCloseDetail ?? '', content2: formatter.format(closureReport.closeDate!) ?? ''),

        SpaceH12(),
        pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                  children: [
                    pw.Text('FDO por técnica'),
                  ]
              ),
              pw.Column(
                  children: [
                    pw.Text('FDO por participante'),
                    pw.Text('Observaciones'),
                  ]
              )
            ]
        ),
      ]
    )
  );
  return doc.save();
}

pw.Widget SpaceH12(){
  return pw.SizedBox(height: 12);
}

Future<pw.PageTheme> _myPageTheme(PdfPageFormat format, bool myPhoto, profileImageWeb) async {
  format = format.applyMargin(
      left: 2.0 * PdfPageFormat.cm,
      top: 3.0 * PdfPageFormat.cm,
      right: 2.0 * PdfPageFormat.cm,
      bottom: 2.0 * PdfPageFormat.cm);
  return pw.PageTheme(
    pageFormat: format,
    margin: pw.EdgeInsets.only(top: 70, left: 0.0, right: 20, bottom: 10),
    theme: pw.ThemeData.withFont(
      base: await PdfGoogleFonts.latoRegular(),
      bold: await PdfGoogleFonts.alataRegular(),
      icons: await PdfGoogleFonts.materialIcons(),
    ),
    buildBackground: (pw.Context context) {
      return pw.FullPage(
        ignoreMargins: true,
        child: pw.Stack(
          children: [
            pw.Container(
              margin: const pw.EdgeInsets.only(left: 30.0, right: 30, top: 60, bottom: 60),
              width: 200,
              decoration: pw.BoxDecoration(
                color: green,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(20)),
                shape: pw.BoxShape.rectangle,
              ),
              child: pw.Positioned(
                child: pw.Container(),
                left: 0,
                top: 0,
                bottom: 0,
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _customRow extends pw.StatelessWidget {
  _customRow({
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
        children: <pw.Widget>[
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: <pw.Widget>[
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(title1, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(width: 170),
                    pw.Text(content1)
                  ]
              ),
              pw.SizedBox(
                width: 50,
              ),
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(title2, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(content2)
                  ]
              ),
            ]
          ),
      ]
    );
  }
}

class _customItem extends pw.StatelessWidget {
  _customItem({
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
        pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(content)
      ]
    );
  }
}

class _customEnumeration extends pw.StatelessWidget {
  _customEnumeration({
    required this.enumeration,
  });
  final List<String> enumeration;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for(String element in enumeration)
            if(enumeration.last != element) pw.Text(element),
            pw.Text(enumeration.last),
        ]
    );
  }
}

class _sectionTitle extends pw.StatelessWidget {
  _sectionTitle({
    required this.title,
  });
  final String title;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 30),
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
          pw.SizedBox(height: 15),
        ]
    );
  }
}

class _subSectionTitle extends pw.StatelessWidget {
  _subSectionTitle({
    required this.title,
  });
  final String title;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 20),
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.SizedBox(height: 12),
        ]
    );
  }
}


class _Block extends pw.StatelessWidget {
  _Block({
    this.title,
    this.descriptionDate,
    this.descriptionPlace,
  });

  final String? title;
  final String? descriptionDate;
  final String? descriptionPlace;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                title != null ? pw.Expanded(
                  child: pw.Text(
                      title!.toUpperCase(),
                      textScaleFactor: 0.8,
                      style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(
                          fontWeight: pw.FontWeight.bold,
                          color: grey)),
                ) : pw.Container()
              ]),
          pw.Container(
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Text(descriptionDate!,
                      textScaleFactor: 0.8,
                      style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(
                          fontWeight: pw.FontWeight.normal,
                          color: grey)),
                ]),
          ),
          pw.Container(
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Text(descriptionPlace!,
                      textScaleFactor: 0.8,
                      style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(
                          fontWeight: pw.FontWeight.normal,
                          color: grey)),
                ]),
          ),
          pw.SizedBox(height: 8),
        ]);
  }
}

class _Category extends pw.StatelessWidget {
  _Category({required this.title, required this.color});

  final String title;
  final PdfColor color;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerLeft,
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(
          title.toUpperCase(),
          textScaleFactor: 1,
          style: pw.Theme.of(context)
              .defaultTextStyle
              .copyWith(
              fontWeight: pw.FontWeight.bold,
              color: color)),
    );
  }
}

class _Percent extends pw.StatelessWidget {
  _Percent({
    required this.size,
    required this.value,
    required this.title,
  });

  final double size;

  final double value;

  final pw.Widget title;

  static const fontSize = 1.2;

  PdfColor get color => lilac;

  static const backgroundColor = PdfColors.grey300;

  static const strokeWidth = 5.0;

  @override
  pw.Widget build(pw.Context context) {
    final widgets = <pw.Widget>[
      pw.Container(
        width: size,
        height: size,
        child: pw.Stack(
          alignment: pw.Alignment.center,
          fit: pw.StackFit.expand,
          children: <pw.Widget>[
            pw.Center(
              child: pw.Text(
                '${(value * 100).round().toInt()}%',
                textScaleFactor: fontSize,
              ),
            ),
            pw.CircularProgressIndicator(
              value: value,
              backgroundColor: backgroundColor,
              color: color,
              strokeWidth: strokeWidth,
            ),
          ],
        ),
      )
    ];

    widgets.add(title);

    return pw.Column(children: widgets);
  }
}

class _UrlText extends pw.StatelessWidget {
  _UrlText(this.text, this.url);

  final String text;
  final String url;

  @override
  pw.Widget build(pw.Context context) {
    return pw.UrlLink(
        destination: url,
        child: pw.Text(text,
            textScaleFactor: 0.8,
            style: pw.Theme.of(context)
                .defaultTextStyle
                .copyWith(
                fontWeight: pw.FontWeight.normal,
                color: white))
    );
  }
}

class _BlockSimple extends pw.StatelessWidget {
  _BlockSimple({
    this.title,
    this.description,
  });

  final String? title;
  final String? description;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                title != null ? pw.Expanded(
                  child:
                  pw.Text(
                      title!.toUpperCase(),
                      textScaleFactor: 1,
                      style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(
                          fontWeight: pw.FontWeight.bold,
                          color: green)),
                ) : pw.Container()
              ]),
          pw.Container(
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  description != null ? pw.Text(description!,
                      textScaleFactor: 0.8,
                      style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(
                          fontWeight: pw.FontWeight.normal,
                          color: grey)) : pw.Container(),
                ]),
          ),
          pw.SizedBox(height: 5),
        ]);
  }
}

class _BlockSimpleList extends pw.StatelessWidget {
  _BlockSimpleList({
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

class _BlockSimpleListLabel extends pw.StatelessWidget {
  _BlockSimpleListLabel({
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
                title != null ? pw.Expanded(
                  child:
                  pw.Text(
                      title!.toUpperCase(),
                      textScaleFactor: 0.7,
                      textAlign: pw.TextAlign.center,
                      style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(fontWeight: pw.FontWeight.normal, color: color)),
                ) : pw.Container()
              ]),
          pw.SizedBox(height: 5),
        ]);
  }
}

class _CategoryLabel extends pw.StatelessWidget {
  _CategoryLabel({
    required this.title,
    required this.color,
  });

  final String title;
  final PdfColor color;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      margin: const pw.EdgeInsets.only(bottom: 10, top: 10),
      padding: const pw.EdgeInsets.fromLTRB(20, 4, 20, 5),
      child: pw.Text(
          title.toUpperCase(),
          textScaleFactor: 1,
          style: pw.Theme.of(context)
              .defaultTextStyle
              .copyWith(fontWeight: pw.FontWeight.normal, color: color)
      ),
    );
  }
}

class _BlockIcon extends pw.StatelessWidget {
  _BlockIcon({
    this.title,
    this.description1,
    this.description2,
    this.description3,
  });

  final String? title;
  final String? description1;
  final String? description2;
  final String? description3;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              title != null ? pw.Expanded(
                child: pw.Text(
                    title!,
                    textScaleFactor: 0.9,
                    style: pw.Theme.of(context)
                        .defaultTextStyle
                        .copyWith(
                        fontWeight: pw.FontWeight.bold,
                        color: white)),
              ) : pw.Container()
            ]),
        pw.SizedBox(height: 2),
        pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              description1 != null ? pw.Expanded(
                child: pw.Text(
                    description1!.toUpperCase(),
                    textScaleFactor: 0.8,
                    style: pw.Theme.of(context)
                        .defaultTextStyle
                        .copyWith(
                        fontWeight: pw.FontWeight.bold,
                        color: white)),
              ) : pw.Container()
            ]),
        pw.SizedBox(height: 2),
        description2 != "" ?
        pw.Row(
          children: [
            pw.Icon(pw.IconData(0xe0be), size: 10.0, color:white),
            pw.SizedBox(width: 4),
            _UrlText(description2!, 'mailto: $description1')
          ],
        ) : pw.Container(),
        pw.SizedBox(height: 4),
        description3 != "" ?
        pw.Row(
            children: [
              pw.Icon(pw.IconData(0xe0b0), size: 10.0, color:white),
              pw.SizedBox(width: 4),
              pw.Text(description3!,
                  textScaleFactor: 0.8,
                  style: pw.Theme.of(context)
                      .defaultTextStyle
                      .copyWith(
                      fontWeight: pw.FontWeight.normal,
                      color: white)) ,
            ]
        ) : pw.Container(),
        pw.SizedBox(height: 7),
      ],
    );
  }
}

