import 'dart:async';
import 'dart:typed_data';

import 'package:enreda_empresas/app/home/participants/pdf_generator/data.dart';
import 'package:enreda_empresas/app/models/certificationRequest.dart';
import 'package:enreda_empresas/app/models/experience.dart';
import 'package:enreda_empresas/app/models/initialReport.dart';
import 'package:enreda_empresas/app/models/ipilEntry.dart';
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

Future<Uint8List> generateInitialReportFile(
    PdfPageFormat format,
    CustomData data,
    UserEnreda user,
    InitialReport initialReport,
    ) async {
  final doc = pw.Document(title: 'Reporte inicial');

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
          'Reporte inicial de ${user.firstName} ${user.lastName}',
          style: pw.TextStyle(
            fontSize: 23,
          )
        ),
        pw.SizedBox(
          height: 30,
        ),
        _customItem(title: 'Subvención a la que el/la participante está imputado/a', content: initialReport.subsidy ?? ''),

        //Section 1
        _sectionTitle(title: '1. Itinerario en España'),
        _customItem(title: 'Orinetaciones', content: initialReport.orientation1 ?? ''),
        SpaceH12(),
        _customRow(title1: 'Fecha de llegada a España', title2: 'Recursos de acogida', content1: formatter.format(initialReport.arriveDate!) ?? '', content2: initialReport.receptionResources ?? ''),
        SpaceH12(),
        _customRow(title1: 'Recursos externos de apoyo', title2: 'Situación administrativa', content1: initialReport.externalResources ?? '', content2: initialReport.administrativeSituation ?? ''),

        //Section 2
        _sectionTitle(title: '2. Situación Sanitaria'),
        _customItem(title: 'Orientaciones', content: initialReport.orientation2 ?? ''),
        SpaceH12(),
        _customRow(title1: 'Tarjeta sanitaria', title2: 'Fecha de caducidad', content1: initialReport.healthCard ?? '', content2: formatter.format(initialReport.expirationDate!) ?? ''),
        SpaceH12(),
        _customRow(title1: 'Enfermedad', title2: 'Medicación/Tratamiento', content1: initialReport.disease ?? '', content2: initialReport.medication ?? ''),

        //Subsection 2.1
        _subSectionTitle(title: '2.1 Salud Mental'),
        _customItem(title: 'Orientaciones', content: initialReport.orientation2_1 ?? ''),
        SpaceH12(),
        _customRow(title1: 'Sueño y descanso', title2: 'Diagnostico', content1: initialReport.rest ?? '', content2: initialReport.diagnosis ?? ''),
        SpaceH12(),
        _customRow(title1: 'Tratamiento', title2: 'Seguimiento', content1: initialReport.treatment ?? '', content2: initialReport.tracking ?? ''),
        SpaceH12(),
        _customItem(title: 'Derivación interna al área psicosocial', content: initialReport.psychosocial ?? ''),

        //Subsection 2.2
        _subSectionTitle(title: '2.2 Discapacidad'),
        _customItem(title: 'Orientaciones', content: initialReport.orientation2_2 ?? ''),
        SpaceH12(),
        _customRow(title1: 'Estado', title2: 'Profesional de referencia', content1: initialReport.disabilityState ?? '', content2: initialReport.referenceProfessionalDisability ?? ''),
        SpaceH12(),
        _customItem(title: 'Grado de discapacidad', content: initialReport.disabilityGrade ?? ''),

        //Subsection 2.3
        _subSectionTitle(title: '2.3 Dependencia'),
        _customItem(title: 'Orientaciones', content: initialReport.orientation2_3 ?? ''),
        SpaceH12(),
        _customRow(title1: 'Estado', title2: 'Profesional de referencia', content1: initialReport.dependenceState ?? '', content2: initialReport.referenceProfessionalDependence ?? ''),
        SpaceH12(),
        _customRow(title1: 'Servicio de ayuda a domicilio', title2: 'Teleasistencia', content1: initialReport.homeAssistance ?? '', content2: initialReport.teleassistance ?? ''),
        SpaceH12(),
        _customItem(title: 'Grado de dependencia', content: initialReport.dependenceGrade ?? ''),

        //Subsection 2.4
        _subSectionTitle(title: '2.4 Adicciones'),
        _customItem(title: 'Orientaciones', content: initialReport.orientation2_4 ?? ''),
        SpaceH12(),
        _customRow(title1: 'Derivación externa', title2: 'Nivel de consumo', content1: initialReport.externalDerivation ?? '', content2: initialReport.consumptionLevel ?? ''),
        SpaceH12(),
        _customItem(title: 'Tratamiento', content: initialReport.addictionTreatment ?? ''),

        //Section 3
        _sectionTitle(title: '3. Situación legal'),
        _customItem(title: 'Orientaciones', content: initialReport.orientation3 ?? ''),
        SpaceH12(),
        _customRow(title1: 'Procesos legales abiertos', title2: 'Procesos legales cerrados', content1: initialReport.openLegalProcess ?? '', content2: initialReport.closeLegalProcess ?? ''),
        SpaceH12(),
        _customItem(title: 'Representación legal', content: initialReport.legalRepresentation ?? ''),

        //Section 4
        _sectionTitle(title: 'Situación alojativa'),
        _customItem(title: 'Orientaciones', content: initialReport.orientation4 ?? ''),
        SpaceH12(),
        _customRow(title1: 'Tipo de tenencia', title2: 'Ubicación', content1: initialReport.ownershipType ?? '', content2: initialReport.location ?? ''),
        SpaceH12(),
        _customRow(title1: 'Unidad de convicencia', title2: 'Datos de contacto del centro y persona de referencia', content1: initialReport.livingUnit ?? '', content2: initialReport.centerContact ?? ''),
        SpaceH12(),
        _customEnumeration(enumeration: initialReport.hostingObservations ?? []),

        //Section 5
        _sectionTitle(title: '5. Redes de apoyo'),
        _customItem(title: 'Orientaciones', content: initialReport.orientation5 ?? ''),
        SpaceH12(),
        _customItem(title: 'Redes informales', content: initialReport.informationNetworks ?? ''),

        //Section 6
        _sectionTitle(title: '6. Situación social integral'),
        _customItem(title: 'Orientaciones', content: initialReport.orientation6 ?? ''),
        SpaceH12(),
        _customItem(title: 'Conocimiento de la estructura social', content: initialReport.socialStructureKnowledge ?? ''),
        SpaceH12(),
        _customRow(title1: 'Nivel de autonomía física y psicológica', title2: 'Habilidades sociales', content1: initialReport.autonomyPhysicMental ?? '', content2: initialReport.socialSkills ?? ''),

        //Section7
        _sectionTitle(title: '7. Idiomas'),
        _customItem(title: 'Orientaciones', content: initialReport.orientation7 ?? ''),
        SpaceH12(),
        _customRow(title1: 'Idioma', title2: 'Reconocimiento / Acreditación - nivel', content1: initialReport.language ?? '', content2: initialReport.languageLevel ?? ''),

        //Section 8
        _sectionTitle(title: '8. Economía'),
        _customItem(title: 'Orientaciones', content: initialReport.orientation8 ?? ''),
        SpaceH12(),
        _customRow(title1: 'Acogida a algún programa de ayuda económica', title2: 'Apoyo familiar', content1: initialReport.economicProgramHelp ?? '', content2: initialReport.familySupport ?? ''),
        SpaceH12(),
        _customItem(title: 'Responsabilidades familiares', content: initialReport.familyResponsibilities ?? ''),

        //Section 9
        _sectionTitle(title: '9. Servicios sociales'),
        _customItem(title: 'Orientaciones', content: initialReport.orientation9 ?? ''),
        SpaceH12(),
        _customRow(title1: 'Acceso a Servicios Sociales', title2: 'Centro y TS de referencia', content1: initialReport.socialServiceAccess ?? '', content2: initialReport.centerTSReference ?? ''),
        SpaceH12(),
        _customRow(title1: 'Beneficiario de subvención y/o programa de apoyo', title2: 'Usuaria', content1: initialReport.subsidyBeneficiary ?? '', content2: initialReport.socialServicesUser ?? ''),
        SpaceH12(),
        _customItem(title: 'Certificado de Exclusión Social', content: initialReport.socialExclusionCertificate ?? ''),

        //Section 10
        _sectionTitle(title: '10. Tecnología'),
        _customItem(title: 'Orientaciones', content: initialReport.orientation10 ?? ''),
        SpaceH12(),
        _customItem(title: 'Nivel de competencias digitales', content: initialReport.digitalSkillsLevel ?? ''),

        //Section 11
        _sectionTitle(title: '11. Objetivos de vida y laborales'),
        _customItem(title: 'Orientaciones', content: initialReport.orientation11 ?? ''),
        SpaceH12(),
        _customRow(title1: 'Intereses en el mercado laboral', title2: 'Expectativas laborares', content1: initialReport.laborMarkerInterest ?? '', content2: initialReport.laborExpectations ?? ''),

        //Section 12
        _sectionTitle(title: '12. Situación de Vulnerabilidad'),
        _customItem(title: 'Orientaciones', content: initialReport.orientation12 ?? ''),
        SpaceH12(),
        _customEnumeration(enumeration: initialReport.vulnerabilityOptions ?? []),

        //Section 13
        _sectionTitle(title: '13. Itinerario formativo laboral'),
        _customItem(title: 'Orientaciones', content: initialReport.orientation13 ?? ''),
        SpaceH12(),
        _customRow(title1: 'Nivel educativo', title2: 'Situación laboral', content1: initialReport.educationLevel ?? '', content2: initialReport.laborSituation ?? ''),
        SpaceH12(),
        _customItem(title: 'Recursos externos', content: initialReport.laborExternalResources ?? ''),
        SpaceH12(),
        _customItem(title: 'Valoración educativa', content: initialReport.educationalEvaluation ?? ''),
        SpaceH12(),
        _customItem(title: 'Itinerario formativo', content: initialReport.formativeItinerary ?? ''),
        SpaceH12(),
        _customRow(title1: 'Inserción laboral', title2: 'Acompañamiento post laboral', content1: initialReport.laborInsertion ?? '', content2: initialReport.accompanimentPostLabor ?? ''),
        SpaceH12(),
        _customItem(title: 'Mejora laboral', content: initialReport.laborUpgrade ?? ''),


        
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

