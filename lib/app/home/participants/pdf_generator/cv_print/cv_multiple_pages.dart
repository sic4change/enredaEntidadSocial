import 'dart:async';
import 'dart:typed_data';

import 'package:enreda_empresas/app/models/certificationRequest.dart';
import 'package:enreda_empresas/app/models/language.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/models/experience.dart';
import 'package:pdf/pdf.dart';
import 'data.dart';

import 'package:enreda_empresas/app/home/participants/pdf_generator/cv_print/resume2_web.dart' as my_cv;
import 'package:enreda_empresas/app/home/participants/pdf_generator/cv_print/resume_purple_web.dart' as my_cv_purple;
import 'package:enreda_empresas/app/home/participants/pdf_generator/cv_print/resume_teal_web.dart' as my_cv_teal;

const examplesMultiplePages = <Example>[
  Example('Plantilla 1', 'resume2_web.dart', my_cv.generateResume2),
  Example('Plantilla 2', 'resume_purple_web.dart', my_cv_purple.generateResumePurple),
  Example('Plantilla 3', 'resume_teal_web.dart', my_cv_teal.generateResumeTeal),
];

typedef LayoutCallbackWithData = Future<Uint8List> Function(
  PdfPageFormat pageFormat,
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
  List<CertificationRequest>? myCustomReferences,
  String myMaxEducation,
);

class Example {
  const Example(this.name, this.file, this.builder, [this.needsData = false]);

  final String name;
  final String file;
  final LayoutCallbackWithData builder;
  final bool needsData;
}
