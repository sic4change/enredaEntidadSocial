import 'dart:async';
import 'dart:io';

import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/models/companionData.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/utils/functions.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

const PdfColor pdfGrey = PdfColor.fromInt(0xFF535A5F);
const PdfColor pdfBlack = PdfColor.fromInt(0xFF44494B);
const PdfColor pdfPrimary900 = PdfColor.fromInt(0xFF054D5E);

Future<Uint8List> generateInitialFormDataPdf(
  PdfPageFormat format, {
  required UserEnreda user,
  CompanionData? companion,
  String resolvedEducation = '',
  String interests = '',
  String specificInterests = '',
  String keepLearning = '',
  int subsidyIndex = -1,
  bool? checkAgreePrivacy,
  bool? checkAgreeCV,
}) async {
  final doc = pw.Document(title: 'Datos del Formulario de Inscripción');

  int? age;
  if (user.birthday != null) {
    final DateTime today = DateTime.now();
    age = today.year - user.birthday!.year;
    if (today.month < user.birthday!.month ||
        (today.month == user.birthday!.month &&
            today.day < user.birthday!.day)) {
      age--;
    }
  }

  // Try to load subsidy banner logo (only if not web, or gracefully skip)
  pw.MemoryImage? logoImage;
  if (subsidyIndex >= 0) {
    final assetPath = subsidyIndex == 0
        ? 'assets/images/logos-mdm.png'
        : subsidyIndex == 2
            ? 'assets/images/logos-seimlab.png'
            : 'assets/images/logos-fse.png';
    try {
      final bytes = await rootBundle.load(assetPath);
      logoImage = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {
      // Asset unavailable in this environment — skip logo
    }
  }

  // Load TrueType fonts with full Unicode/Spanish support (same as MyPageTheme).
  pw.Font baseFont;
  pw.Font boldFont;
  try {
    baseFont = await PdfGoogleFonts.poppinsLight();
    boldFont = await PdfGoogleFonts.poppinsMedium();
  } catch (_) {
    // Network unavailable — fall back to built-in Type1 fonts (no accent support).
    baseFont = pw.Font.helvetica();
    boldFont = pw.Font.helveticaBold();
  }

  final PdfPageFormat adjustedFormat = format.applyMargin(
    left: 2.0 * PdfPageFormat.cm,
    top: logoImage != null ? 3.0 * PdfPageFormat.cm : 2.0 * PdfPageFormat.cm,
    right: 2.0 * PdfPageFormat.cm,
    bottom: 3.0 * PdfPageFormat.cm,
  );

  final List<pw.Widget> items = [];

  // Title
  items.add(
    pw.Center(
      child: pw.Text(
        'DATOS DEL FORMULARIO DE INSCRIPCIÓN',
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          color: pdfPrimary900,
        ),
      ),
    ),
  );
  items.add(pw.SizedBox(height: 8));

  items.add(
    pw.Center(
      child: pw.Text(
        'Participante: ${user.firstName ?? ''} ${user.lastName ?? ''}',
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: pdfGrey,
        ),
      ),
    ),
  );
  items.add(pw.SizedBox(height: 20));

  void addField(String label, String? value) {
    if (value != null &&
        value.trim().isNotEmpty &&
        value.trim() != 'No indicado') {
      items.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8.0),
          child: pw.RichText(
            text: pw.TextSpan(
              text: '$label: ',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
                color: pdfPrimary900,
              ),
              children: [
                pw.TextSpan(
                  text: value.trim(),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.normal,
                    fontSize: 10,
                    color: pdfBlack,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  if (age != null) addField('Edad', '$age años');
  if (resolvedEducation.isNotEmpty && resolvedEducation != 'No indicado') {
    addField('Nivel educativo', resolvedEducation);
  }
  if (interests.isNotEmpty && interests != 'No indicado') {
    addField('Intereses', interests);
  }
  if (specificInterests.isNotEmpty && specificInterests != 'No indicado') {
    addField('Intereses específicos', specificInterests);
  }
  if (keepLearning.isNotEmpty && keepLearning != 'No indicado') {
    addField('Opciones para seguir aprendiendo', keepLearning);
  }

  if (companion != null) {
    addField('Situación familiar', companion.companionFamilyStatus);
    addField('Fecha de llegada a España', companion.companionArrivalDateInSpain);
    addField('Situación administrativa', companion.companionAdministrativeStatus);

    if (companion.companionWorkPermit != null) {
      addField('Permiso de trabajo', companion.companionWorkPermit! ? 'Sí' : 'No');
    }

    final docType = companion.companionDocumentType?.trim() ?? '';
    final docNum = companion.companionDocumentNumber?.trim() ?? '';
    final docCombined =
        (docType.isNotEmpty && docNum.isNotEmpty)
            ? '$docType - $docNum'
            : (docNum.isNotEmpty ? docNum : docType);
    if (docCombined.isNotEmpty) addField('Tipo y número de documento', docCombined);

    final helpNeeds = companion.companionHelpNeeds;
    if (helpNeeds != null && helpNeeds.isNotEmpty) {
      final helpNeedsText = helpNeeds.where((s) => s.trim().isNotEmpty).join(', ');
      if (helpNeedsText.isNotEmpty) addField('Ayudas seleccionadas', helpNeedsText);
    }

    final schedule = companion.companionContactSchedule;
    if (schedule != null && schedule.isNotEmpty) {
      addField('Horario de contacto', schedule.join(', '));
    }

    if (companion.companionFormHelp != null) {
      addField('Ayuda al rellenar el formulario', companion.companionFormHelp! ? 'Sí' : 'No');
    }
    addField('Observaciones', companion.companionOtherRelevantData);
  }

  // ── Consentimientos y autorizaciones ──────────────────────────────────────
  items.add(pw.SizedBox(height: 16));
  items.add(
    pw.Text(
      'Consentimientos y autorizaciones',
      style: pw.TextStyle(
        fontSize: 12,
        fontWeight: pw.FontWeight.bold,
        color: pdfPrimary900,
      ),
    ),
  );
  items.add(pw.SizedBox(height: 8));

  void addConsentRow(String label, bool? accepted) {
    final boxColor = (accepted == true)
        ? PdfColor.fromInt(0xFF1A7A4A)
        : PdfColor.fromInt(0xFFB00020);
    final statusText = (accepted == true) ? 'Si' : 'No';
    items.add(
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6.0),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 10,
              height: 10,
              margin: const pw.EdgeInsets.only(top: 1),
              decoration: pw.BoxDecoration(
                color: boxColor,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
              ),
              child: pw.Center(
                child: pw.Text(
                  statusText,
                  style: pw.TextStyle(
                    fontSize: 5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ),
            pw.SizedBox(width: 6),
            pw.Expanded(
              child: pw.Text(
                label,
                style: pw.TextStyle(
                  fontSize: 9,
                  color: pdfBlack,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  addConsentRow(
    'Acepto la Política de Privacidad y Condiciones de Uso.',
    checkAgreePrivacy,
  );
  addConsentRow(
    'Según la Ley Orgánica 3/2018, de 5 de diciembre, de Protección de Datos Personales y garantía de los derechos digitales, '
    'autorizo a la empresa el uso y tratamiento de mis datos con fines exclusivamente de selección de personal y bolsas de empleo.',
    checkAgreeCV,
  );

  // Build page theme using TrueType fonts with Unicode support
  pw.PageTheme? pageTheme;
  if (logoImage != null) {
    final capturedLogo = logoImage;
    pageTheme = pw.PageTheme(
      pageFormat: adjustedFormat,
      margin: pw.EdgeInsets.fromLTRB(
        adjustedFormat.marginLeft,
        adjustedFormat.marginTop,
        adjustedFormat.marginRight,
        adjustedFormat.marginBottom,
      ),
      theme: pw.ThemeData.withFont(
        base: baseFont,
        bold: boldFont,
      ),
      buildBackground: (pw.Context context) {
        return pw.FullPage(
          ignoreMargins: true,
          child: pw.Stack(
            children: [
              pw.Positioned(
                left: 10,
                top: 30,
                right: 10,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Container(
                      width: 550,
                      child: pw.Image(capturedLogo, width: 550, fit: pw.BoxFit.contain),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  doc.addPage(
    pw.MultiPage(
      pageTheme: pageTheme,
      pageFormat: pageTheme == null ? adjustedFormat : null,
      theme: pageTheme == null
          ? pw.ThemeData.withFont(
              base: baseFont,
              bold: boldFont,
            )
          : null,
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
                style: const pw.TextStyle(color: pdfGrey),
              ),
            ),
            pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 2),
              child: pw.Text(
                'Pág. ${context.pageNumber} de ${context.pagesCount}',
                textScaleFactor: 0.8,
                style: const pw.TextStyle(color: pdfGrey),
              ),
            ),
          ],
        );
      },
      build: (pw.Context context) => items,
    ),
  );

  return doc.save();
}

class MyInitialFormDataPdfPreview extends StatefulWidget {
  const MyInitialFormDataPdfPreview({
    Key? key,
    required this.user,
    this.companion,
    this.resolvedEducation = '',
    this.interests = '',
    this.specificInterests = '',
    this.keepLearning = '',
    this.subsidyIndex = -1,
    this.checkAgreePrivacy,
    this.checkAgreeCV,
  }) : super(key: key);

  final UserEnreda user;
  final CompanionData? companion;
  final String resolvedEducation;
  final String interests;
  final String specificInterests;
  final String keepLearning;
  final int subsidyIndex;
  final bool? checkAgreePrivacy;
  final bool? checkAgreeCV;

  @override
  State<MyInitialFormDataPdfPreview> createState() =>
      _MyInitialFormDataPdfPreviewState();
}

class _MyInitialFormDataPdfPreviewState
    extends State<MyInitialFormDataPdfPreview> {
  void _showPrintedToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.penLightBlue,
        content: Text('Documento impreso con éxito'),
      ),
    );
  }

  void _showSharedToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.penLightBlue,
        content: Text('Documento compartido con éxito'),
      ),
    );
  }

  Future<void> _saveAsFile(
    BuildContext context,
    LayoutCallback build,
    PdfPageFormat pageFormat,
  ) async {
    final bytes = await build(pageFormat);
    final appDocDir = await getApplicationDocumentsDirectory();
    final file = File(
        '${appDocDir.path}/Datos_Formulario_${widget.user.firstName ?? 'Participante'}.pdf');
    await file.writeAsBytes(bytes);
    await OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final actions = <PdfPreviewAction>[
      if (!kIsWeb)
        PdfPreviewAction(
          icon: const Icon(Icons.save),
          onPressed: _saveAsFile,
        )
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary100,
        iconTheme: const IconThemeData(color: AppColors.turquoiseBlue),
        leading: IconButton(
          onPressed: () {
            setWebPdfTitle(StringConst.PAGE_TITLE);
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        title: CustomTextBoldCenter(
          title:
              'Datos del Formulario de ${widget.user.firstName ?? ''}',
          color: AppColors.turquoiseBlue,
        ),
        titleTextStyle: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 22.0,
        ),
      ),
      body: PdfPreview(
        maxPageWidth: 700,
        pdfFileName:
            'Datos_Formulario_${widget.user.firstName ?? 'Participante'}.pdf',
        build: (format) {
          setWebPdfTitle(
              'Datos_Formulario_${widget.user.firstName ?? 'Participante'}');
          return generateInitialFormDataPdf(
            format,
            user: widget.user,
            companion: widget.companion,
            resolvedEducation: widget.resolvedEducation,
            interests: widget.interests,
            specificInterests: widget.specificInterests,
            keepLearning: widget.keepLearning,
            subsidyIndex: widget.subsidyIndex,
            checkAgreePrivacy: widget.checkAgreePrivacy,
            checkAgreeCV: widget.checkAgreeCV,
          );
        },
        actions: actions,
        canDebug: false,
        initialPageFormat: PdfPageFormat.a4,
        onPrinted: _showPrintedToast,
        onShared: _showSharedToast,
      ),
    );
  }
}
