import 'dart:async';
import 'dart:typed_data';

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
import 'package:printing/printing.dart';



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

  final pageTheme = await _myPageTheme(format);
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
        _customItem(title: 'Subvención a la que el/la participante está imputado/a', content: derivationReport.subsidy ?? ''),
        SpaceH12(),
        _customItem(title: 'Dirigido a:', content: derivationReport.addressedTo ?? ''),
        SpaceH12(),
        _customItem(title: 'Con el objetivo de:', content: derivationReport.objectiveDerivation ?? ''),

        //Section 1
        derivationReport.allow1 ?? true ? pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _sectionTitle(title: '1. Itinerario en España'),
            _customItem(title: 'Orinetaciones', content: derivationReport.orientation1 ?? ''),
            SpaceH12(),
            _customRow(title1: 'Fecha de llegada a España', title2: 'Recursos de acogida', content1: derivationReport.arriveDate == null ? '' : formatter.format(derivationReport.arriveDate!), content2: derivationReport.receptionResources ?? ''),
            SpaceH12(),
            _customItem(title: 'Situación administrativa', content: derivationReport.administrativeExternalResources ?? ''),

            //Subsection 1.1
            derivationReport.allow1_1 ?? true ? pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _subSectionTitle(title: StringConst.INITIAL_TITLE_1_1_ADMINISTRATIVE_SITUATION),
                  _customItem(title: StringConst.INITIAL_STATE, content: derivationReport.adminState ?? ''),
                  SpaceH12(),
                  derivationReport.adminState == 'Sin tramitar' ?
                  _customItem(title: 'Sin tramitar', content: derivationReport.adminNoThrough ?? '') :
                  derivationReport.adminState == 'En trámite' ?
                  _customRow(title1: 'Fecha de solicitud', title2: 'Fecha de resolución', content1: derivationReport.adminDateAsk == null ? '' : formatter.format(derivationReport.adminDateAsk!), content2: derivationReport.adminDateResolution == null ? '' : formatter.format(derivationReport.adminDateResolution!)) :
                  _customItem(title: StringConst.INITIAL_DATE_CONCESSION, content: derivationReport.adminDateConcession == null ? '' : formatter.format(derivationReport.adminDateConcession!)),
                  SpaceH12(),
                  _customRow(title1: StringConst.INITIAL_TEMP, title2: derivationReport.adminTemp == 'Inicial' || derivationReport.adminTemp == 'Temporal' ? 'Fecha de resolución' : '', content1: derivationReport.adminTemp ?? '', content2: derivationReport.adminTemp == 'Inicial' || derivationReport.adminTemp == 'Temporal' ?  derivationReport.adminDateRenovation == null ? '' : formatter.format(derivationReport.adminDateRenovation!) : ''),
                  SpaceH12(),
                  _customRow(title1: 'Tipo de residencia', title2: StringConst.INITIAL_JURIDIC_FIGURE, content1: derivationReport.adminResidenceType ?? '', content2: derivationReport.adminJuridicFigure ?? ''),
                  derivationReport.adminJuridicFigure == 'Otros' ?pw.Column(
                      children: [
                        SpaceH12(),
                        _customItem(title: StringConst.INITIAL_OTHERS, content: derivationReport.adminOther ?? '')
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
              _sectionTitle(title: '2. Situación Sanitaria'),
              _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation2 ?? ''),
              SpaceH12(),
              _customRow(title1: 'Tarjeta sanitaria', title2: 'Fecha de caducidad', content1: derivationReport.healthCard ?? '', content2: derivationReport.expirationDate == null ? '' : formatter.format(derivationReport.expirationDate!)),
              SpaceH12(),
              _customItem(title: 'Medicación/Tratamiento', content: derivationReport.medication ?? ''),

              //Subsection 2.1
              derivationReport.allow2_1 ?? true ? pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _subSectionTitle(title: '2.1 Salud Mental'),
                    _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation2_1 ?? ''),
                    SpaceH12(),
                    _customRow(title1: 'Sueño y descanso', title2: 'Diagnostico', content1: derivationReport.rest ?? '', content2: derivationReport.diagnosis ?? ''),
                    SpaceH12(),
                    _customRow(title1: 'Tratamiento', title2: 'Seguimiento', content1: derivationReport.treatment ?? '', content2: derivationReport.tracking ?? ''),
                  ]
              ) : pw.Container(),


              //Subsection 2.2
              derivationReport.allow2_2 ?? true ? pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _subSectionTitle(title: '2.2 Discapacidad'),
                    _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation2_2 ?? ''),
                    SpaceH12(),
                    _customItem(title: 'Estado', content: derivationReport.disabilityState ?? ''),
                    derivationReport.dependenceState == 'Concedida' ?
                    _customRow(title1: 'Concedida', title2: 'Fecha', content1: derivationReport.granted ?? '', content2: derivationReport.revisionDate == null ? '' : formatter.format(derivationReport.revisionDate!)) :
                    pw.Container(),
                    derivationReport.dependenceState == 'Concedida' ? SpaceH12() : pw.Container(),
                    SpaceH12(),
                    _customItem(title: 'Profesional de referencia', content: derivationReport.referenceProfessionalDisability ?? ''),
                    SpaceH12(),
                    _customRow(title1: 'Grado de discapacidad', title2: 'Tipo de discapacidad', content1: derivationReport.disabilityGrade ?? '', content2: derivationReport.disabilityType ?? ''),
                  ]
              ) : pw.Container(),


              //Subsection 2.3
              derivationReport.allow2_3 ?? true ? pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _subSectionTitle(title: '2.3 Dependencia'),
                    _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation2_3 ?? ''),
                    SpaceH12(),
                    _customRow(title1: 'Estado', title2: 'Profesional de referencia', content1: derivationReport.dependenceState ?? '', content2: derivationReport.referenceProfessionalDependence ?? ''),
                    SpaceH12(),
                    _customItem(title: 'Grado de dependencia', content: derivationReport.dependenceGrade ?? ''),
                  ]
              ) : pw.Container(),



              //Subsection 2.4
              derivationReport.allow2_4 ?? true ? pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _subSectionTitle(title: '2.4 Adicciones'),
                    _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation2_4 ?? ''),
                    SpaceH12(),
                    _customRow(title1: 'Derivación externa', title2: StringConst.INITIAL_MOTIVE, content1: derivationReport.externalDerivation ?? '', content2: derivationReport.motive ?? ''),
                  ]
              ) : pw.Container(),


            ]
        ) : pw.Container(),


        //Section 3
        derivationReport.allow3 ?? true ? pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _sectionTitle(title: '3. Situación legal'),
              _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation3 ?? ''),
              SpaceH12(),
              _customRow(title1: 'Derivación interma', title2: StringConst.INITIAL_DERIVATION_DATE, content1: derivationReport.internalDerivationLegal ?? '', content2: derivationReport.internalDerivationDate == null ? '' : formatter.format(derivationReport.internalDerivationDate!)),
              SpaceH12(),
              _customItem(title: StringConst.INITIAL_MOTIVE, content: derivationReport.internalDerivationMotive ?? ''),
              SpaceH12(),
              _customRow(title1: 'Derivación externa', title2: StringConst.INITIAL_DERIVATION_DATE, content1: derivationReport.externalDerivationLegal ?? '', content2: derivationReport.externalDerivationDate == null ? '' : formatter.format(derivationReport.externalDerivationDate!)),
              SpaceH12(),
              _customItem(title: StringConst.INITIAL_MOTIVE, content: derivationReport.externalDerivationMotive ?? ''),
              SpaceH12(),
              _customRow(title1: 'Derivación interna al área psicosocial', title2: StringConst.INITIAL_DERIVATION_DATE, content1: derivationReport.psychosocialDerivationLegal ?? '', content2: derivationReport.psychosocialDerivationDate == null ? '' : formatter.format(derivationReport.psychosocialDerivationDate!)),
              SpaceH12(),
              _customItem(title: StringConst.INITIAL_MOTIVE, content: derivationReport.psychosocialDerivationMotive ?? ''),
              SpaceH12(),
              _customItem(title: 'Representación legal', content: derivationReport.legalRepresentation ?? ''),
              SpaceH12(),
              _customRow(title1: 'Bolsa de tramitación', title2: StringConst.INITIAL_DATE, content1: derivationReport.processingBag ?? '', content2: derivationReport.processingBagDate == null ? '' : formatter.format(derivationReport.processingBagDate!)),
              SpaceH12(),
              _customItem(title: 'Cuantia económica', content: derivationReport.economicAmount ?? ''),
            ]
        ) : pw.Container(),


        //Section 4
        derivationReport.allow4 ?? true ? pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _sectionTitle(title: 'Situación alojativa'),
              _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation4 ?? ''),
              SpaceH12(),
              _customRow(title1: 'Situación alojativa', title2: derivationReport.ownershipType == 'Con hogar' ? 'Tipo de tenencia' : 'Situación sinhogarismo', content1: derivationReport.ownershipType ?? '', content2: derivationReport.ownershipType == 'Con hogar' ? (derivationReport.ownershipTypeConcrete ?? '') : (derivationReport.homelessnessSituation ?? '')),
              SpaceH12(),
              derivationReport.ownershipTypeConcrete == 'Otros' ? pw.Column(
                  children: [
                    _customItem(title: StringConst.INITIAL_OTHERS, content: derivationReport.ownershipTypeOpen ?? ''),
                    SpaceH12(),
                  ]
              ) : pw.Container(),
              derivationReport.homelessnessSituation== 'Otros' ? pw.Column(
                  children: [
                    _customItem(title: StringConst.INITIAL_OTHERS, content: derivationReport.homelessnessSituationOpen ?? ''),
                    SpaceH12(),
                  ]
              ) : pw.Container(),
              _customItem(title: 'Datos de contacto del recurso alojativo', content: derivationReport.centerContact ?? ''),
              _customItem(title: StringConst.INITIAL_LOCATION, content: derivationReport.location ?? ''),
              SpaceH12(),
              for (var data in derivationReport.hostingObservations!)
                _BlockSimpleList(
                  title: data,
                  color: grey,
                ),
            ]
        ) : pw.Container(),



        //Section 5
        derivationReport.allow5 ?? true ? pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _sectionTitle(title: '5. Redes de apoyo'),
              _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation5 ?? ''),
              SpaceH12(),
              _customItem(title: 'Redes de apoyo natural', content: derivationReport.informationNetworks ?? ''),
              SpaceH12(),
              _customRow(title1: 'Redes de apoyo institucional', title2: 'Conciliación familiar', content1: derivationReport.institutionNetworks ?? '', content2: derivationReport.familyConciliation ?? ''),
            ]
        ) : pw.Container(),


        //Section7
        derivationReport.allow6 ?? true ? pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _sectionTitle(title: '6. Idiomas'),
              _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation7 ?? ''),
              SpaceH12(),
              pw.Column(
                  children: [
                    for(LanguageReport language in derivationReport.languages ?? [])
                      pw.Column(
                          children: [
                            _customRow(title1: 'Idioma', title2: 'Reconocimiento / acreditación - nivel', content1: language.name, content2: language.level),
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
              _sectionTitle(title: '7. Atención social integral'),
              _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation9 ?? ''),
              SpaceH12(),
              _customItem(title: 'Centro y TS de referencia', content: derivationReport.centerTSReference ?? ''),
              SpaceH12(),
              _customItem(title: 'Destinataria de subvención y/o programa de apoyo', content: derivationReport.subsidyBeneficiary ?? ''),
              derivationReport.subsidyBeneficiary == 'Si' ? pw.Column(
                  children: [
                    _customItem(title: 'Nombre/tipo', content: derivationReport.subsidyName ?? ''),
                    SpaceH12(),
                  ]
              ) : pw.Container(),
              SpaceH12(),
              _customItem(title: 'Certificado de Exclusión Social', content: derivationReport.socialExclusionCertificate ?? ''),
              derivationReport.socialExclusionCertificate == 'Si' ? pw.Column(
                  children: [
                    _customRow(title1: StringConst.INITIAL_DATE, title2: 'Observaciones sobre el certificado', content1: derivationReport.socialExclusionCertificateDate == null ? '' : formatter.format(derivationReport.socialExclusionCertificateDate!), content2: derivationReport.socialExclusionCertificateObservations ?? ''),
                    SpaceH12(),
                  ]
              ) : pw.Container(),
            ]
        ) : pw.Container(),



        //Section 12
        derivationReport.allow8 ?? true ? pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _sectionTitle(title: '8. Situación de Vulnerabilidad'),
              _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation12 ?? ''),
              SpaceH12(),
              for (var data in derivationReport.vulnerabilityOptions!)
                _BlockSimpleList(
                  title: data,
                  color: grey,
                ),
            ]
        ) : pw.Container(),


        //Section 13
        derivationReport.allow9 ?? true ? pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _sectionTitle(title: '9. Itinerario formativo laboral'),
              _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation13 ?? ''),
              _subSectionTitle(title: StringConst.INITIAL_TITLE_9_3_TRAJECTORY),
              _customItem(title: 'Competencias (competencias específicas, competencias prelaborales y competencias digitales)', content: derivationReport.competencies ?? ''),
              SpaceH12(),
              _customItem(title: 'Contextualización del territorio', content: derivationReport.contextualization ?? ''),
              SpaceH12(),
              _customItem(title: 'Conexión del entorno', content: derivationReport.connexion ?? ''),

              _subSectionTitle(title: StringConst.INITIAL_TITLE_9_4_EXPECTATIONS),
              _customItem(title: 'Corto plazo', content: derivationReport.shortTerm ?? ''),
              SpaceH12(),
              _customItem(title: 'Medio plazo', content: derivationReport.mediumTerm ?? ''),
              SpaceH12(),
              _customItem(title: 'Largo plazo', content: derivationReport.longTerm ?? ''),

              //Subsection 9.5
              _subSectionTitle(title: StringConst.FOLLOW_TITLE_9_5_DEVELOP),
              _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation9_5 ?? ''),
              _subSectionTitle(title: StringConst.FOLLOW_FORMATIONS),
              pw.Column(
                  children: [
                    for(FormationReport formation in derivationReport.formations ?? [])
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
              _customRow(title1: 'Bolsa de formación', title2: StringConst.INITIAL_DATE, content1: derivationReport.formationBag ?? '', content2: derivationReport.formationBagDate == null ? '' : formatter.format(derivationReport.formationBagDate!)),
              SpaceH12(),
              _customRow(title1: StringConst.INITIAL_MOTIVE, title2: StringConst.FOLLOW_ECONOMIC_AMOUNT, content1: derivationReport.formationBagMotive ?? '', content2: derivationReport.formationBagEconomic ?? ''),

              _subSectionTitle(title: 'Empleo'),
              _customRow(title1: 'Nivel educativo', title2: 'Situación laboral', content1: derivationReport.educationLevel ?? '', content2: derivationReport.laborSituation ?? ''),
              SpaceH12(),
              derivationReport.laborSituation == 'Ocupada cuenta propia' || derivationReport.laborSituation == 'Ocupada cuenta ajena' ?
              pw.Column(
                  children: [
                    _customRow(title1: StringConst.INITIAL_TEMP, title2: 'Tipo jornada', content1: derivationReport.tempLabor ?? '', content2: derivationReport.workingDayLabor ?? ''),
                    SpaceH12(),
                  ]
              )
                  : pw.Container(),
              _customRow(title1: 'Fecha de obtención', title2: 'Fecha de finalización', content1: derivationReport.jobObtainDate == null ? '' : formatter.format(derivationReport.jobObtainDate!), content2: derivationReport.jobFinishDate == null ? '' : formatter.format(derivationReport.jobFinishDate!)),
              SpaceH12(),
              _customRow(title1: 'Mejora laboral', title2: 'Motivo de mejora', content1: derivationReport.jobUpgrade ?? '', content2: derivationReport.upgradeMotive ?? ''),
              SpaceH12(),
              _customItem(title: StringConst.INITIAL_DATE, content: derivationReport.upgradeDate == null ? '' : formatter.format(derivationReport.upgradeDate!)),

              _subSectionTitle(title: StringConst.FOLLOW_TITLE_9_6_POST_LABOR_ACCOMPANIMENT),
              _customItem(title: StringConst.INITIAL_OBSERVATIONS, content: derivationReport.orientation9_6 ?? ''),
              SpaceH12(),
              _customItem(title: 'Acompañamiento post-laboral', content: derivationReport.postLaborAccompaniment ?? ''),
              derivationReport.postLaborAccompaniment == 'No' ?
              pw.Column(
                  children: [
                    SpaceH12(),
                    _customItem(title: StringConst.INITIAL_MOTIVE, content: derivationReport.postLaborAccompanimentMotive ?? ''),
                  ]
              ): pw.Container(),
              SpaceH12(),
              _customRow(title1: StringConst.FOLLOW_INIT_DATE, title2: StringConst.FOLLOW_END_DATE, content1: derivationReport.postLaborInitialDate == null ? '' : formatter.format(derivationReport.postLaborInitialDate!), content2: derivationReport.postLaborFinalDate == null ? '' : formatter.format(derivationReport.postLaborFinalDate!)),
              SpaceH12(),
              _customItem(title: 'Total de días', content: derivationReport.postLaborTotalDays == null ? '' : derivationReport.postLaborTotalDays.toString()),
              SpaceH12(),
              _customItem(title: 'Mantenimiento del empleo obtenido', content: derivationReport.jobMaintenance ?? ''),
            ]
        ) : pw.Container(),

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

Future<pw.PageTheme> _myPageTheme(PdfPageFormat format) async {
  return pw.PageTheme(
    pageFormat: format,
    theme: pw.ThemeData.withFont(
      base: await PdfGoogleFonts.interLight(),
      bold: await PdfGoogleFonts.interMedium(),
      icons: await PdfGoogleFonts.materialIcons(),
    ),
    buildBackground: (pw.Context context) {
      return pw.FullPage(
        ignoreMargins: true,
        child: pw.Stack(
          children: [
            pw.Container(
              margin: const pw.EdgeInsets.only(left: 30.0, right: 30, top: 60, bottom: 60),
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
                      pw.Text(title1, style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(fontWeight: pw.FontWeight.normal, color: black)),
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
                      pw.Text(title2, style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(fontWeight: pw.FontWeight.normal, color: black)),
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
          pw.Text(title,
              style: pw.Theme.of(context)
                  .defaultTextStyle
                  .copyWith(fontWeight: pw.FontWeight.normal, color: black)
          ),
          pw.Text(content)
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
          pw.Text(title,
              style: pw.Theme.of(context)
                  .defaultTextStyle
                  .copyWith(fontWeight: pw.FontWeight.bold, fontSize: 16, color: primary900)
          ),
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
          pw.Text(title,
              style: pw.Theme.of(context)
                  .defaultTextStyle
                  .copyWith(fontWeight: pw.FontWeight.normal, fontSize: 14, color: primary900)
          ),
          pw.SizedBox(height: 12),
        ]
    );
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


