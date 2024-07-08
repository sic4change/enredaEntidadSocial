import 'dart:async';
import 'dart:io';

import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/home/participants/pdf_generator/derivation_report_pdf_page.dart';
import 'package:enreda_empresas/app/models/derivationReport.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'cv_print/data.dart';


class MyDerivationReport extends StatefulWidget {
  const MyDerivationReport({
    Key? key,
    required this.user,
    required this.derivationReport,
  }) : super(key: key);

  final UserEnreda user;
  final DerivationReport derivationReport;

  @override
  MyAppState createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyDerivationReport> with SingleTickerProviderStateMixin {

  int _tab = 0;
  TabController? _tabController;
  PrintingInfo? printingInfo;
  var _data = const CustomData();

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _init() async {
    final info = await Printing.info();

    _tabController = TabController(
      vsync: this,
      length: examplesDerivationReport.length,
      initialIndex: _tab,
    );
    _tabController!.addListener(() {
      if (_tab != _tabController!.index) {
        setState(() {
          _tab = _tabController!.index;
        });
      }
    });

    setState(() {
      printingInfo = info;
    });
  }

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
    final appDocPath = appDocDir.path;
    final file = File('$appDocPath/myDerivationReport.pdf');
    print('Save as file ${file.path} ...');
    await file.writeAsBytes(bytes);
    await OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    pw.RichText.debug = true;

    if (_tabController == null) {
      return const Center(child: CircularProgressIndicator());
    }

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
        iconTheme: const IconThemeData(color: AppColors.turquoiseBlue,),
        actionsIconTheme: const IconThemeData(color: AppColors.white,),
        foregroundColor: Colors.white,
        title: CustomTextBoldCenter(title: 'Reporte de derivación de ${widget.user.firstName}', color: AppColors.turquoiseBlue,),
        titleTextStyle: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22.0),
        bottom: TabBar(
          controller: _tabController,
          tabs: examplesDerivationReport.map((e) => CustomTextBold(title: e.name,)).toList(),
          labelColor: Colors.white,
          labelStyle: TextStyle(fontSize: 20),
          isScrollable: true,
        ),
      ),
      body: PdfPreview(
        maxPageWidth: 700,
        build: (format) => examplesDerivationReport[_tab].builder(
          format,
          _data,
          widget.user!,
          widget.derivationReport,
        ),
        actions: actions,
        canDebug: false,
        onPrinted: _showPrintedToast,
        onShared: _showSharedToast,
      ),
    );
  }
}
