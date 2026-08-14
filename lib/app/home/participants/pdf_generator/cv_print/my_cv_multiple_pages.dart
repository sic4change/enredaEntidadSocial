import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:enreda_empresas/app/home/participants/pdf_generator/cv_print/cv_multiple_pages.dart';
import 'package:enreda_empresas/app/home/participants/pdf_generator/cv_print/data.dart';
import 'package:enreda_empresas/app/models/certificationRequest.dart';
import 'package:enreda_empresas/app/models/language.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/models/experience.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class MyCvMultiplePages extends StatefulWidget {
  const MyCvMultiplePages({
    Key? key,
    required this.user,
    required this.city,
    required this.province,
    required this.country,
    required this.myExperiences,
    required this.myPersonalExperiences,
    required this.myEducation,
    required this.mySecondaryEducation,
    required this.idSelectedDateEducation,
    required this.idSelectedDateSecondaryEducation,
    required this.idSelectedDateExperience,
    required this.idSelectedDatePersonalExperience,
    required this.competenciesNames,
    required this.languagesNames,
    required this.aboutMe,
    required this.myDataOfInterest,
    required this.myCustomEmail,
    required this.myCustomPhone,
    required this.myPhoto,
    required this.myCustomReferences,
    required this.myMaxEducation,
  }) : super(key: key);

  final UserEnreda? user;
  final String? city;
  final String? province;
  final String? country;
  final List<Experience>? myExperiences;
  final List<Experience>? myPersonalExperiences;
  final List<Experience>? myEducation;
  final List<Experience>? mySecondaryEducation;
  final List<String>? idSelectedDateEducation;
  final List<String>? idSelectedDateSecondaryEducation;
  final List<String>? idSelectedDateExperience;
  final List<String>? idSelectedDatePersonalExperience;
  final List<String>? competenciesNames;
  final List<Language>? languagesNames;
  final String? aboutMe;
  final List<String>? myDataOfInterest;
  final String myCustomEmail;
  final String myCustomPhone;
  final String myMaxEducation;
  final bool myPhoto;
  final List<CertificationRequest>? myCustomReferences;

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyCvMultiplePages> {
  int _selectedTemplateIndex = 0;
  PrintingInfo? printingInfo;
  var _data = const CustomData();

  static const Color tealColor = Color(0xFF005B5B);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final info = await Printing.info();
    setState(() {
      printingInfo = info;
    });
  }

  void _showPrintedToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF00D0CE),
        content: Text('Documento impreso con éxito'),
      ),
    );
  }

  void _showSharedToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF00D0CE),
        content: Text('Documento compartido con éxito'),
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    return await examplesMultiplePages[_selectedTemplateIndex].builder(
      format,
      _data,
      widget.user,
      widget.city,
      widget.province,
      widget.country,
      widget.myExperiences,
      widget.myPersonalExperiences,
      widget.myEducation,
      widget.mySecondaryEducation,
      widget.idSelectedDateEducation,
      widget.idSelectedDateSecondaryEducation,
      widget.idSelectedDateExperience,
      widget.idSelectedDatePersonalExperience,
      widget.competenciesNames,
      widget.languagesNames,
      widget.aboutMe,
      widget.myDataOfInterest,
      widget.myCustomEmail,
      widget.myCustomPhone,
      widget.myPhoto,
      widget.myCustomReferences,
      widget.myMaxEducation,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back & Download Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.arrow_back,
                          color: tealColor, size: 28),
                    ),
                    InkWell(
                      onTap: () async {
                        final bytes = await _generatePdf(PdfPageFormat.a4);
                        final appDocDir =
                            await getApplicationDocumentsDirectory();
                        final appDocPath = appDocDir.path;
                        final filename =
                            '${widget.user?.firstName ?? ""} ${widget.user?.lastName ?? ""} CV.pdf'
                                .trim();
                        final file = File('$appDocPath/$filename');
                        await file.writeAsBytes(bytes);
                        await OpenFile.open(file.path);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D0CE),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Descargar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.download, color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Info Banner
                const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: tealColor,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Elige una plantilla para descargar el currículum.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(height: 1, color: Colors.grey[200]),
                const SizedBox(height: 12),

                // Template Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:
                      List.generate(examplesMultiplePages.length, (index) {
                    final isSelected = _selectedTemplateIndex == index;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedTemplateIndex = index;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFA7E4E1)
                                  : Colors.white,
                              border: Border.all(color: tealColor, width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.description_outlined,
                                  color: tealColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    examplesMultiplePages[index].name,
                                    style: const TextStyle(
                                      color: tealColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 14),

                // PDF Preview Area
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!, width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: PdfPreview(
                        key: ValueKey(_selectedTemplateIndex),
                        build: (format) => _generatePdf(format),
                        useActions: false,
                        canChangePageFormat: false,
                        canChangeOrientation: false,
                        canDebug: false,
                        initialPageFormat: PdfPageFormat.a4,
                        onPrinted: _showPrintedToast,
                        onShared: _showSharedToast,
                        scrollViewDecoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Desktop Layout
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 71,
        backgroundColor: tealColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Volver atrás',
                  style: TextStyle(
                    color: tealColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Print Button
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: InkWell(
              onTap: () async {
                await Printing.layoutPdf(
                  onLayout: (format) => _generatePdf(format),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Text(
                      'IMPRIMIR',
                      style: TextStyle(
                        color: tealColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.print, color: tealColor, size: 20),
                  ],
                ),
              ),
            ),
          ),
          // Download Button
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: InkWell(
              onTap: () async {
                final bytes = await _generatePdf(PdfPageFormat.a4);
                await Printing.sharePdf(
                  bytes: bytes,
                  filename:
                      '${widget.user?.firstName ?? ""} ${widget.user?.lastName ?? ""} CV.pdf'
                          .trim(),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Text(
                      'DESCARGAR',
                      style: TextStyle(
                        color: tealColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.download, color: tealColor, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar with Templates
          Container(
            width: 250,
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: examplesMultiplePages.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedTemplateIndex == index;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedTemplateIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFA7E4E1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.description_outlined,
                                color: tealColor,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                examplesMultiplePages[index].name,
                                style: const TextStyle(
                                  color: tealColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Separator line
          Container(width: 1, color: Colors.grey[300]),
          // PDF Preview Area
          Expanded(
            child: Container(
              color: const Color(0xFFF5F7FB),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 660),
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: tealColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Elige una plantilla para descargar el currículum.',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: PdfPreview(
                      key: ValueKey(_selectedTemplateIndex),
                      maxPageWidth: 700,
                      build: (format) => _generatePdf(format),
                      useActions: false,
                      canChangePageFormat: false,
                      canChangeOrientation: false,
                      canDebug: false,
                      initialPageFormat: PdfPageFormat.a4,
                      onPrinted: _showPrintedToast,
                      onShared: _showSharedToast,
                      scrollViewDecoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
