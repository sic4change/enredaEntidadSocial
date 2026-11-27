import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const PdfColor black = PdfColor.fromInt(0xF44494B);

const String _emptyLocation = '.........................';

/// Returns the technician's location (city, or province if there is no city)
/// to print in the signature line, or null if it can't be resolved.
Future<String?> resolveTechLocation(String? techPersonId) async {
  if (techPersonId == null || techPersonId.trim().isEmpty) return null;
  try {
    final Database database = FirestoreDatabase();
    final cache = LocationCache.instance;
    final tech = await cache
        .getUser(database, techPersonId)
        .timeout(const Duration(seconds: 5));
    final cityId = tech?.address?.city;
    if (cityId != null && cityId.trim().isNotEmpty) {
      final city = await cache
          .getCity(database, cityId)
          .timeout(const Duration(seconds: 5));
      if (city != null && city.name.trim().isNotEmpty) return city.name.trim();
    }
    final provinceId = tech?.address?.province;
    if (provinceId != null && provinceId.trim().isNotEmpty) {
      final province = await cache
          .getProvince(database, provinceId)
          .timeout(const Duration(seconds: 5));
      final name = province?.name.trim();
      if (name != null && name.isNotEmpty) return name;
    }
  } catch (e) {
    // If the location can't be fetched, keep the blank placeholder.
  }
  return null;
}

class BottomSignatures extends pw.StatelessWidget {
  BottomSignatures({this.location});

  /// Technician's location. When null/empty a dotted placeholder is printed.
  final String? location;

  @override
  pw.Widget build(pw.Context context) {
    final String place = (location != null && location!.trim().isNotEmpty)
        ? location!.trim()
        : _emptyLocation;
    final String date = DateFormat('dd/MM/yyyy').format(DateTime.now());
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 50.0, left: 0.0, right: 50),
      child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text('Nombre del/a técnico/a de Enreda:\nEn $place a $date\nFDO:',
                      textScaleFactor: 0.8,
                      style: pw.Theme.of(context)
                          .defaultTextStyle
                          .copyWith(fontWeight: pw.FontWeight.bold, color: black)),
                ]
            ),
          ]
      ),
    );
  }
}
