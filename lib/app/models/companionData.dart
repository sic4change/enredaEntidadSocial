class CompanionData {
  CompanionData({
    this.companionDataId,
    this.userId,
    this.companionFamilyStatus,
    this.companionArrivalDateInSpain,
    this.companionAdministrativeStatus,
    this.companionWorkPermit,
    this.companionDocumentType,
    this.companionDocumentNumber,
    this.companionHelpNeeds,
    this.companionContactSchedule,
    this.companionFormHelp,
    this.companionOtherRelevantData,
  });

  final String? companionDataId;
  final String? userId;
  final String? companionFamilyStatus;
  final String? companionArrivalDateInSpain;
  final String? companionAdministrativeStatus;
  final String? companionWorkPermit;
  final String? companionDocumentType;
  final String? companionDocumentNumber;
  final List<String>? companionHelpNeeds;
  final String? companionContactSchedule;
  final String? companionFormHelp;
  final String? companionOtherRelevantData;

  factory CompanionData.fromMap(Map<String, dynamic> data, String documentId) {
    List<String> helpNeeds = [];
    final rawNeeds = data['companionHelpNeeds'] ?? data['helpNeeds'] ?? data['aidsSelected'];
    if (rawNeeds != null) {
      if (rawNeeds is List) {
        helpNeeds = rawNeeds.map((e) => e.toString()).toList();
      } else if (rawNeeds is String && rawNeeds.toString().trim().isNotEmpty) {
        helpNeeds = [rawNeeds.toString().trim()];
      }
    }

    final rawWorkPermit = data['companionWorkPermit'] ?? data['workPermit'];
    String? workPermitText;
    if (rawWorkPermit != null) {
      if (rawWorkPermit is bool) {
        workPermitText = rawWorkPermit ? 'Sí' : 'No';
      } else {
        final str = rawWorkPermit.toString().trim();
        final lower = str.toLowerCase();
        if (lower == 'true' || lower == 'si' || lower == 'sí') {
          workPermitText = 'Sí';
        } else if (lower == 'false' || lower == 'no') {
          workPermitText = 'No';
        } else if (str.isNotEmpty) {
          workPermitText = str;
        }
      }
    }

    final rawSchedule = data['companionContactSchedule'] ?? data['contactSchedule'] ?? data['schedule'];
    String? scheduleText;
    if (rawSchedule != null) {
      if (rawSchedule is List) {
        scheduleText = rawSchedule
            .map((e) => e.toString().replaceAll('[', '').replaceAll(']', '').trim())
            .where((s) => s.isNotEmpty)
            .join(', ');
      } else {
        var str = rawSchedule.toString().trim();
        str = str.replaceAll('[', '').replaceAll(']', '').trim();
        scheduleText = str.isNotEmpty ? str : null;
      }
    }

    String? getString(dynamic v) => (v != null && v.toString().trim().isNotEmpty) ? v.toString().trim() : null;

    return CompanionData(
      companionDataId: documentId,
      userId: getString(data['userId']),
      companionFamilyStatus: getString(data['companionFamilyStatus'] ?? data['familyStatus'] ?? data['familySituation']),
      companionArrivalDateInSpain: getString(data['companionArrivalDateInSpain'] ?? data['arrivalDateInSpain'] ?? data['arrivalDate'] ?? data['companionArrivalDate']),
      companionAdministrativeStatus: getString(data['companionAdministrativeStatus'] ?? data['administrativeStatus']),
      companionWorkPermit: workPermitText,
      companionDocumentType: getString(data['companionDocumentType'] ?? data['documentType'] ?? data['personalDocumentType']),
      companionDocumentNumber: getString(data['companionDocumentNumber'] ?? data['documentNumber'] ?? data['dni']),
      companionHelpNeeds: helpNeeds.isEmpty ? null : helpNeeds,
      companionContactSchedule: scheduleText,
      companionFormHelp: getString(data['companionFormHelp'] ?? data['helpFillingForm'] ?? data['formHelp']),
      companionOtherRelevantData: getString(data['companionOtherRelevantData'] ?? data['otherRelevantData'] ?? data['observations'] ?? data['observaciones']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'companionDataId': companionDataId,
      'userId': userId,
      'companionFamilyStatus': companionFamilyStatus,
      'companionArrivalDateInSpain': companionArrivalDateInSpain,
      'companionAdministrativeStatus': companionAdministrativeStatus,
      'companionWorkPermit': companionWorkPermit,
      'companionDocumentType': companionDocumentType,
      'companionDocumentNumber': companionDocumentNumber,
      'companionHelpNeeds': companionHelpNeeds,
      'companionContactSchedule': companionContactSchedule,
      'companionFormHelp': companionFormHelp,
      'companionOtherRelevantData': companionOtherRelevantData,
    };
  }
}
