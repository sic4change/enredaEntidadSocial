import 'package:enreda_empresas/app/models/documentationParticipant.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:pdf/widgets.dart' as pw;

const kDuration = Duration(milliseconds: 600);

Future<void> launchURL(url) async {
  if (!url.contains('http://') && !url.contains('https://')) {
    url = 'http://' + url;
  }
  final Uri _url = Uri.parse(url);
  final bool nativeAppLaunchSucceeded = await launchUrl(
    _url,
    mode: LaunchMode.externalNonBrowserApplication,
  );
  if (!nativeAppLaunchSucceeded) {
    if (!await launchUrl(
      _url,
      mode: LaunchMode.inAppWebView,
    )) throw 'No se puede mostrar la dirección $_url';
  }
}

Future<void> openFile(DocumentationParticipant documentParticipant) async{
  final url = documentParticipant.urlDocument;
  if (url == null) {
    throw ArgumentError('URL cannot be null');
  }
  var response = await http.get(Uri.parse(url));
  if (response.statusCode != 200) {
    throw Exception('Failed to load document');
  }
  var pdfData = response.bodyBytes;
  var extension = p.extension(url).substring(0,4);
  if(extension != '.pdf'){
    printNotPDF(url);
  }
  else {
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfData);
  }
}

Future<void> printNotPDF(String path) async{
  final doc = pw.Document();
  final netImage = await networkImage(path);
  doc.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Image(netImage),
        );
      })
  );
  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
}

scrollToSection(BuildContext context) {
  Scrollable.ensureVisible(
    context,
    duration: kDuration,
  );
}

int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
}

String removeDiacritics(String str) {
  var withDia = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
  var withoutDia = 'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';

  for (int i = 0; i < withDia.length; i++) {
    str = str.replaceAll(withDia[i], withoutDia[i]);
  }

  return str;
}

bool isEmailValid(String email) =>
    RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);

