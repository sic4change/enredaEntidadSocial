import 'dart:async';

import 'package:enreda_empresas/app/home/participants/pdf_generator/cv_print/data.dart';
import 'package:enreda_empresas/app/models/certificationRequest.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/models/language.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:enreda_empresas/app/models/experience.dart';
import 'package:http/http.dart';

const PdfColor lilac =
    PdfColor.fromInt(0xFF7E57C2); // Deep Purple 400 (kept for accents)
const PdfColor lightLilac = PdfColor.fromInt(0xFFE8E4F3); // Lighter lavender
const PdfColor blue = PdfColor.fromInt(0xFF002185);
const PdfColor grey = PdfColor.fromInt(0xFF6B7280); // Medium gray for body text
const PdfColor greyDark = PdfColor.fromInt(0xFFD1C4E9); // Deep Purple 100
const PdfColor darkTeal =
    PdfColor.fromInt(0xFF2C5F6F); // Dark teal for headings
const PdfColor primary900 =
    PdfColor.fromInt(0xFF2C5F6F); // Dark teal (main heading color)
const PdfColor white = PdfColor.fromInt(0xFFFFFFFF);
const PdfColor lightPurple = PdfColor.fromInt(0xFFD6DAFB); // Sidebar background
const PdfColor greyLight = PdfColor.fromInt(0xFFADADAD);
const PdfColor timelineColor =
    PdfColor.fromInt(0xFF054D5E); // Timeline decoration color
const leftWidth = 200.0;
const rightWidth = 350.0;

Future<Uint8List> generateResumePurple(
  PdfPageFormat format,
  CustomData data,
  UserEnreda? user,
  String? city,
  String? province,
  String? country,
  List<Experience>? myExperiences,
  List<Experience>? myPersonalExperiences,
  List<Experience>? myEducation,
  List<Experience>? mySecondaryEducation,
  List<String>? idSelectedDateEducation,
  List<String>? idSelectedDateSecondaryEducation,
  List<String>? idSelectedDateExperience,
  List<String>? idSelectedDatePersonalExperience,
  List<String>? competenciesNames,
  List<Language>? languagesNames,
  String? aboutMe,
  List<String>? myDataOfInterest,
  String myCustomEmail,
  String myCustomPhone,
  bool myPhoto,
  List<CertificationRequest>? myReferences,
  String myMaxEducation,
) async {
  final doc = pw.Document(title: 'Currículum');

  var url = user?.profilePic?.src ?? "";

  Future<Uint8List> imageFromUrl(String url) async {
    final uri = Uri.parse(url);
    final Response response = await get(uri);
    return response.bodyBytes;
  }

  Uint8List? myUint8List;
  if (url != "") {
    try {
      myUint8List = await imageFromUrl(url);
    } catch (_) {}
  }

  final profileImageWeb = url == "" || myUint8List == null
      ? pw.MemoryImage(
          (await rootBundle.load(ImagePath.USER_DEFAULT)).buffer.asUint8List(),
        )
      : pw.MemoryImage(myUint8List);

  PdfPageFormat format1 = format.applyMargin(
      left: 0,
      top: 0,
      right: 2.0 * PdfPageFormat.cm,
      bottom: 2.0 * PdfPageFormat.cm);

  final pageTheme = await _myPageTheme(format1, myPhoto, profileImageWeb);
  final DateFormat formatter = DateFormat('yyyy');
  List<String>? dataOfInterest = myDataOfInterest;

  doc.addPage(
    pw.MultiPage(
      pageTheme: pageTheme,
      footer: (pw.Context context) {
        return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: pw.Text(
                'Pág. ${context.pageNumber} de ${context.pagesCount}',
                style: pw.Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: PdfColors.grey)));
      },
      header: (pw.Context context) {
        return pw.Container(); // Empty header, we will move Name to Body
      },
      build: (pw.Context context) => <pw.Widget>[
        pw.Partitions(
          children: [
            pw.Partition(
              width: leftWidth,
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 30.0),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.SizedBox(height: 180), // Space for Photo
                    myCustomEmail != ""
                        ? _Category(
                            title: StringConst.PERSONAL_DATA, color: primary900)
                        : pw.Container(),
                    myCustomEmail != ""
                        ? pw.Row(
                            children: [
                              _SectionIcon(0xe0be),
                              pw.SizedBox(width: 4),
                              pw.Expanded(child: _UrlText(myCustomEmail, 'mailto: $myCustomEmail'))
                            ],
                          )
                        : pw.Container(),
                    pw.SizedBox(height: 4),
                    myCustomPhone != ""
                        ? pw.Row(children: [
                            _SectionIcon(0xe0b0),
                            pw.SizedBox(width: 4),
                            pw.Text(myCustomPhone,
                                textScaleFactor: 0.9,
                                style: pw.Theme.of(context)
                                    .defaultTextStyle
                                    .copyWith(
                                        fontWeight: pw.FontWeight.normal,
                                        color: grey)),
                          ])
                        : pw.Container(),
                    pw.SizedBox(height: 4),
                    city != "" || province != "" || country != ""
                        ? pw.Row(children: [
                            pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                children: [
                                  _SectionIcon(0xe8b4),
                                  pw.SizedBox(width: 4),
                                  pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text('${city ?? ''}',
                                            textScaleFactor: 0.8,
                                            style: pw.Theme.of(context)
                                                .defaultTextStyle
                                                .copyWith(
                                                    fontWeight:
                                                        pw.FontWeight.normal,
                                                    color: grey)),
                                        pw.Text('${province ?? ''}',
                                            textScaleFactor: 0.8,
                                            style: pw.Theme.of(context)
                                                .defaultTextStyle
                                                .copyWith(
                                                    fontWeight:
                                                        pw.FontWeight.normal,
                                                    color: grey)),
                                        pw.Text(
                                            '${country?.toUpperCase() ?? ''}',
                                            textScaleFactor: 0.8,
                                            style: pw.Theme.of(context)
                                                .defaultTextStyle
                                                .copyWith(
                                                    fontWeight:
                                                        pw.FontWeight.normal,
                                                    color: grey)),
                                      ])
                                ]),
                          ])
                        : pw.Container(),
                    pw.SizedBox(height: 10),

                    // References section - below personal data, no icons
                    if (myReferences != null && myReferences.isNotEmpty) ...(() {
                      final items = myReferences.map((reference) => _ReferenceBlock(
                        name: '${reference.certifierName}',
                        position: '${reference.certifierPosition}',
                        company: '${reference.certifierCompany}',
                        contact: [reference.phone, reference.email]
                            .whereType<String>()
                            .where((String s) => s.trim().isNotEmpty && s.trim() != '+34')
                            .join(' / '),
                      )).toList();
                      return [
                        pw.SizedBox(height: 10),
                        pw.Inseparable(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _Category(title: StringConst.REFERENCES, color: primary900),
                              items.first,
                            ],
                          ),
                        ),
                        ...items.skip(1),
                      ];
                    })(),

                    if (competenciesNames != null && competenciesNames.isNotEmpty) ...(() {
                      final items = competenciesNames.map((name) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 6),
                        child: _CompetencyChip(title: name),
                      )).toList();
                      return [
                        pw.SizedBox(height: 15),
                        pw.Inseparable(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _Category(title: StringConst.COMPETENCIES, color: primary900),
                              pw.SizedBox(height: 8),
                              items.first,
                            ],
                          ),
                        ),
                        ...items.skip(1),
                      ];
                    })(),

                    if (myDataOfInterest != null && myDataOfInterest.isNotEmpty) ...(() {
                      final items = dataOfInterest!.map((data) => _BlockSimpleList(
                        title: data,
                        color: grey,
                      )).toList();
                      return [
                        pw.SizedBox(height: 10),
                        pw.Inseparable(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _Category(title: StringConst.DATA_OF_INTEREST, color: primary900),
                              items.first,
                            ],
                          ),
                        ),
                        ...items.skip(1),
                      ];
                    })(),
                    if (languagesNames != null && languagesNames.isNotEmpty) ...(() {
                      final items = languagesNames.map((lang) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 2),
                        child: pw.Text(
                          '${lang.name.toUpperCase()} | ${lang.speakingLevel == 1 ? 'PRINCIPIANTE' : lang.speakingLevel == 2 ? 'MEDIO' : 'AVANZADO'}',
                          style: const pw.TextStyle(fontSize: 8, color: grey),
                        ),
                      )).toList();
                      return [
                        pw.SizedBox(height: 15),
                        pw.Inseparable(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _Category(title: StringConst.LANGUAGES, color: primary900),
                              items.first,
                            ],
                          ),
                        ),
                        ...items.skip(1),
                      ];
                    })(),
                  ],
                ),
              ),
            ),
            pw.Partition(
                width: rightWidth,
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 30.0),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: <pw.Widget>[
                      // Moved Name Here
                      pw.Text('${user?.firstName}'.toUpperCase(),
                          textScaleFactor: 2.5,
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(
                              fontWeight: pw.FontWeight.bold,
                              color: primary900)),
                      pw.Text('${user?.lastName}'.toUpperCase(),
                          textScaleFactor: 1.5,
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(
                              fontWeight: pw.FontWeight.bold,
                              color: primary900)),
                      pw.SizedBox(height: 20),

                      // Moved About Me Here
                      aboutMe != null && aboutMe != ""
                          ? _BlockSimple(
                              title: StringConst.ABOUT_ME,
                              description: aboutMe,
                            )
                          : pw.Container(),
                      pw.SizedBox(height: 15),

                      // Timeline decoration - full width
                      _TimelineShape(timelineColor),
                      pw.SizedBox(height: 20),

                      pw.Text(myMaxEducation.toUpperCase(),
                          textScaleFactor: 1.2,
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(
                              fontWeight: pw.FontWeight.normal, color: grey)),
                      if (myExperiences != null && myExperiences.isNotEmpty) ...(() {
                        final items = myExperiences.map((experience) => _Block(
                            title: (experience.activity != null) ? experience.activity : '',
                            organization: experience.organization != "" &&
                                    experience.organization != null &&
                                    experience.position != "" &&
                                    experience.position != null
                                ? '${experience.position} - ${experience.organization}'
                                : experience.organization != null || experience.organization != ""
                                    ? experience.organization
                                    : experience.position != null && experience.position != ""
                                        ? experience.position
                                        : "",
                            showDescriptionDate: idSelectedDateExperience?.contains(experience.id) ?? true,
                            descriptionDate: '${experience.startDate != null ? formatter.format(experience.startDate!.toDate()) : '-'} / ${experience.endDate != null ? formatter.format(experience.endDate!.toDate()) : 'Actualmente'}',
                            descriptionPlace: '${experience.location}',
                            descriptionActivities: experience.professionActivitiesText != null && experience.professionActivitiesText!.isNotEmpty
                                ? experience.professionActivitiesText!
                                    .split(' / ')
                                    .where((String item) => item.isNotEmpty)
                                    .map<String>((String item) => '• $item')
                                    .join('\n')
                                : experience.professionActivities
                                    .where((String item) => item.isNotEmpty)
                                    .map<String>((String item) => '• $item')
                                    .join('\n'))
                        ).toList();
                        return [
                          pw.SizedBox(height: 10),
                          pw.Inseparable(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _Category(title: StringConst.MY_PROFESIONAL_EXPERIENCES, color: primary900),
                                items.first,
                              ],
                            ),
                          ),
                          ...items.skip(1),
                        ];
                      })(),
                      if (myPersonalExperiences != null && myPersonalExperiences.isNotEmpty) ...(() {
                        final items = myPersonalExperiences.map((experience) => _Block(
                          title: experience.subtype == 'Responsabilidades familiares' || experience.subtype == "Compromiso social"
                              ? experience.subtype
                              : experience.activityRole != null && experience.activity != null && experience.subtype != null
                                  ? '${experience.subtype} - ${experience.activityRole} - ${experience.activity}'
                                  : experience.activityRole != null && experience.activity != null
                                      ? '${experience.activityRole} - ${experience.activity}'
                                      : experience.activity != null && experience.subtype != null
                                          ? '${experience.subtype} - ${experience.activity}'
                                          : experience.activity != null
                                              ? experience.activity
                                              : '',
                          organization: experience.organization != "" && experience.organization != null && experience.position != "" && experience.position != null
                              ? '${experience.position} - ${experience.organization}'
                              : experience.organization != null || experience.organization != ""
                                  ? experience.organization
                                  : experience.position != null && experience.position != ""
                                      ? experience.position
                                      : "",
                          showDescriptionDate: idSelectedDatePersonalExperience?.contains(experience.id) ?? true,
                          descriptionDate: '${experience.startDate != null ? formatter.format(experience.startDate!.toDate()) : '-'} / ${experience.endDate != null ? formatter.format(experience.endDate!.toDate()) : 'Actualmente'}',
                          descriptionPlace: '${experience.location}',
                        )).toList();
                        return [
                          pw.SizedBox(height: 10),
                          pw.Inseparable(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _Category(title: StringConst.MY_PERSONAL_EXPERIENCES, color: primary900),
                                items.first,
                              ],
                            ),
                          ),
                          ...items.skip(1),
                        ];
                      })(),
                      if (myEducation != null && myEducation.isNotEmpty) ...(() {
                        final items = myEducation.map((education) => _Block(
                          title: education.institution != null && education.nameFormation != null && education.nameFormation != ''
                              ? '${education.institution} - ${education.nameFormation}'
                              : education.institution == null
                                  ? education.nameFormation
                                  : education.institution,
                          organization: education.organization != "" && education.organization != null
                              ? education.organization
                              : '',
                          showDescriptionDate: idSelectedDateEducation?.contains(education.id) ?? true,
                          descriptionDate: '${education.startDate != null ? formatter.format(education.startDate!.toDate()) : '-'} / ${education.endDate != null ? formatter.format(education.endDate!.toDate()) : 'Actualmente'}',
                          descriptionPlace: '${education.location}',
                        )).toList();
                        return [
                          pw.SizedBox(height: 10),
                          pw.Inseparable(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _Category(title: StringConst.EDUCATION, color: primary900),
                                items.first,
                              ],
                            ),
                          ),
                          ...items.skip(1),
                        ];
                      })(),
                      if (mySecondaryEducation != null && mySecondaryEducation.isNotEmpty) ...(() {
                        final items = mySecondaryEducation.map((education) => _Block(
                          title: education.institution != null && education.nameFormation != null && education.nameFormation != ''
                              ? '${education.institution} - ${education.nameFormation}'
                              : education.institution == null
                                  ? education.nameFormation
                                  : education.institution,
                          organization: education.organization != "" && education.organization != null
                              ? education.organization
                              : '',
                          showDescriptionDate: idSelectedDateSecondaryEducation?.contains(education.id) ?? true,
                          descriptionDate: '${education.startDate != null ? formatter.format(education.startDate!.toDate()) : '-'} / ${education.endDate != null ? formatter.format(education.endDate!.toDate()) : 'Actualmente'}',
                          descriptionPlace: '${education.location}',
                        )).toList();
                        return [
                          pw.SizedBox(height: 10),
                          pw.Inseparable(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _Category(title: StringConst.SECONDARY_EDUCATION, color: primary900),
                                items.first,
                              ],
                            ),
                          ),
                          ...items.skip(1),
                        ];
                      })(),
                    ],
                  ),
                ))
          ],
        ),
      ],
    ),
  );
  return doc.save();
}

Future<pw.PageTheme> _myPageTheme(
    PdfPageFormat format, bool myPhoto, profileImageWeb) async {
  format = format.applyMargin(
      left: 2.0 * PdfPageFormat.cm,
      top: 2.0 * PdfPageFormat.cm,
      right: 2.0 * PdfPageFormat.cm,
      bottom: 2.0 * PdfPageFormat.cm);
  return pw.PageTheme(
    pageFormat: format,
    margin: pw.EdgeInsets.only(top: 50, left: 0.0, right: 20, bottom: 10),
    theme: pw.ThemeData.withFont(
      base: await PdfGoogleFonts.poppinsLight(),
      bold: await PdfGoogleFonts.poppinsMedium(),
      icons: await PdfGoogleFonts.materialIcons(),
    ),
    buildBackground: (pw.Context context) {
      return pw.FullPage(
        ignoreMargins: true,
        child: pw.Stack(
          children: [
            // Left Sidebar Background with border radius on top-right
            pw.Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: pw.Container(
                width: leftWidth,
                decoration: pw.BoxDecoration(
                  color: lightPurple,
                  borderRadius: pw.BorderRadius.only(
                    topRight:
                        pw.Radius.circular(140), // Reduced by 30% from 200px
                  ),
                ),
              ),
            ),
            // Photo only on first page - white border only (126px = 63% of sidebar)
            context.pageNumber == 1 && myPhoto == true
                ? pw.Positioned(
                    left: (leftWidth - 126) / 2, // Center in sidebar
                    top: 40,
                    child: pw.Container(
                        padding:
                            const pw.EdgeInsets.all(5.0), // Proportional border
                        decoration: pw.BoxDecoration(
                            color: PdfColors.white,
                            shape: pw.BoxShape.circle,
                            border: pw.Border.all(
                              color: white,
                              width: 4,
                            )),
                        child: pw.ClipOval(
                          child: pw.Container(
                            width: 116, // Photo size to fit with border
                            height: 116,
                            child:
                                pw.Image(profileImageWeb, fit: pw.BoxFit.cover),
                          ),
                        )),
                  )
                : pw.Container(),
          ],
        ),
      );
    },
  );
}

class _Block extends pw.StatelessWidget {
  _Block({
    this.title,
    this.organization,
    this.descriptionDate,
    this.descriptionPlace,
    this.showDescriptionDate,
    this.descriptionActivities,
  });

  final String? title;
  final String? organization;
  final String? descriptionDate;
  final String? descriptionPlace;
  final bool? showDescriptionDate;
  final String? descriptionActivities;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                title != null
                    ? pw.Expanded(
                        child: pw.Text(title!.toUpperCase(),
                            textScaleFactor: 0.8,
                            style: pw.Theme.of(context)
                                .defaultTextStyle
                                .copyWith(
                                    fontWeight: pw.FontWeight.bold,
                                    color: grey)),
                      )
                    : pw.Container()
              ]),
          organization != null
              ? pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                      pw.Expanded(
                        child: pw.Text(organization!,
                            textScaleFactor: 0.8,
                            style: pw.Theme.of(context)
                                .defaultTextStyle
                                .copyWith(
                                    fontWeight: pw.FontWeight.bold,
                                    color: grey)),
                      )
                    ])
              : pw.Container(),
          pw.Container(
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  (showDescriptionDate ?? true)
                      ? pw.Text(descriptionDate!,
                          textScaleFactor: 0.8,
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(
                              fontWeight: pw.FontWeight.normal, color: grey))
                      : pw.Container(),
                ]),
          ),
          pw.Container(
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Text(descriptionPlace!,
                      textScaleFactor: 0.8,
                      style: pw.Theme.of(context).defaultTextStyle.copyWith(
                          fontWeight: pw.FontWeight.normal, color: grey)),
                ]),
          ),
          descriptionActivities != null
              ? pw.Container(
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Text('Actividades realizadas:',
                            textScaleFactor: 0.8,
                            style: pw.Theme.of(context)
                                .defaultTextStyle
                                .copyWith(
                                    fontWeight: pw.FontWeight.bold,
                                    color: grey)),
                        pw.Text(descriptionActivities!,
                            textScaleFactor: 0.8,
                            style: pw.Theme.of(context)
                                .defaultTextStyle
                                .copyWith(
                                    fontWeight: pw.FontWeight.normal,
                                    color: grey)),
                      ]),
                )
              : pw.Container(),
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
      padding: const pw.EdgeInsets.only(bottom: 0),
      child: pw.Text(title.toUpperCase(),
          textScaleFactor: 1,
          style: pw.Theme.of(context)
              .defaultTextStyle
              .copyWith(fontWeight: pw.FontWeight.bold, color: color)),
    );
  }
}

class _UrlText extends pw.StatelessWidget {
  _UrlText(this.text, this.url);

  final String text;
  final String url;

  @override
  pw.Widget build(pw.Context context) {
    return pw.FittedBox(
      fit: pw.BoxFit.scaleDown,
      alignment: pw.Alignment.centerLeft,
      child: pw.UrlLink(
          destination: url,
          child: pw.Text(text,
              textScaleFactor: 0.8,
              style: pw.Theme.of(context)
                  .defaultTextStyle
                  .copyWith(fontWeight: pw.FontWeight.normal, color: grey))),
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
                title != null
                    ? pw.Expanded(
                        child: pw.Text(title!.toUpperCase(),
                            textScaleFactor: 1,
                            style: pw.Theme.of(context)
                                .defaultTextStyle
                                .copyWith(
                                    fontWeight: pw.FontWeight.bold,
                                    color: primary900)),
                      )
                    : pw.Container()
              ]),
          pw.Container(
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  description != null
                      ? pw.Text(description!,
                          textScaleFactor: 0.8,
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(
                              fontWeight: pw.FontWeight.normal, color: grey))
                      : pw.Container(),
                ]),
          ),
          pw.SizedBox(height: 5),
        ]);
  }
}

class _BlockSimpleList extends pw.StatelessWidget {
  _BlockSimpleList({
    this.title,
    this.color,
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
                    color: primary900,
                    shape: pw.BoxShape.circle,
                  ),
                ),
                title != null
                    ? pw.Expanded(
                        child: pw.Text(title!,
                            textScaleFactor: 0.8,
                            style: pw.Theme.of(context)
                                .defaultTextStyle
                                .copyWith(
                                    fontWeight: pw.FontWeight.normal,
                                    color: color)),
                      )
                    : pw.Container()
              ]),
          pw.SizedBox(height: 2),
        ]);
  }
}

class _ReferenceBlock extends pw.StatelessWidget {
  _ReferenceBlock({
    this.name,
    this.position,
    this.company,
    this.contact,
  });

  final String? name;
  final String? position;
  final String? company;
  final String? contact;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          name != null
              ? pw.Text(name!,
                  textScaleFactor: 0.8,
                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                      fontWeight: pw.FontWeight.bold, color: primary900))
              : pw.Container(),
          position != null || company != null
              ? pw.Text(
                  [position, company]
                      .whereType<String>()
                      .where((String s) => s.isNotEmpty)
                      .join(' - '),
                  textScaleFactor: 0.8,
                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                      fontWeight: pw.FontWeight.normal, color: grey))
              : pw.Container(),
          contact != null && contact!.isNotEmpty
              ? pw.Text(contact!,
                  textScaleFactor: 0.8,
                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                      fontWeight: pw.FontWeight.normal, color: grey))
              : pw.Container(),
          pw.SizedBox(height: 6),
        ]);
  }
}

class _CompetencyChip extends pw.StatelessWidget {
  _CompetencyChip({required this.title});

  final String title;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: pw.BoxDecoration(
        color: lightPurple,
        borderRadius: pw.BorderRadius.circular(15),
      ),
      child: pw.Text(
        title,
        textScaleFactor: 0.75,
        style: pw.Theme.of(context).defaultTextStyle.copyWith(
              fontWeight: pw.FontWeight.normal,
              color: primary900,
            ),
      ),
    );
  }
}

class _TimelineShape extends pw.StatelessWidget {
  _TimelineShape(this.color);

  final PdfColor color;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      height: 15,
      child: pw.Stack(
        alignment: pw.Alignment.centerLeft,
        children: [
          pw.Container(
            height: 1,
            color: color,
          ),
          pw.Container(
            width: 8,
            height: 8,
            decoration: pw.BoxDecoration(
              color: white,
              shape: pw.BoxShape.circle,
              border: pw.Border.all(color: color, width: 2),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionIcon extends pw.StatelessWidget {
  _SectionIcon(this.code);

  final int code;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Icon(
      pw.IconData(code),
      color: primary900,
      size: 10,
    );
  }
}
