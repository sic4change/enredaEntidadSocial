class CompanionData {
  CompanionData({
    this.companionDataId,
    this.userId,
    this.companionFamilyStatus,
    this.companionArrivalDateInSpain,
    this.companionAdministrativeStatus,
    this.companionWorkPermit,
    this.companionWorkPermitRenewalDate,
    this.companionDocumentType,
    this.companionDocumentNumber,
    this.companionHelpNeeds,
    this.companionHelpNeedsOther,
    this.companionContactSchedule,
    this.companionFormHelp,
    this.companionOtherRelevantData,
  });

  final String? companionDataId;
  final String? userId;
  final String? companionFamilyStatus;
  final String? companionArrivalDateInSpain;
  final String? companionAdministrativeStatus;
  /// Stored as bool in Firestore (source enreda-app) but may arrive as String
  /// ('Sí' / 'No') from older documents. Always use [companionWorkPermitBool]
  /// for UI logic.
  final bool? companionWorkPermit;
  final String? companionWorkPermitRenewalDate;
  final String? companionDocumentType;
  final String? companionDocumentNumber;
  final List<String>? companionHelpNeeds;
  final String? companionHelpNeedsOther;
  /// List of selected schedules ('Mañana', 'Tarde').
  final List<String>? companionContactSchedule;
  /// Whether a professional helped fill in the form (maps to companionProfessionalHelp).
  final bool? companionFormHelp;
  final String? companionOtherRelevantData;

  factory CompanionData.fromMap(Map<String, dynamic> data, String documentId) {
    List<String> helpNeeds = [];
    final rawNeeds = data['companionHelpNeeds'] ?? data['helpNeeds'] ?? data['aidsSelected'];
    if (rawNeeds != null) {
      if (rawNeeds is List) {
        helpNeeds = rawNeeds.map((e) => e.toString()).toList();
      } else if (rawNeeds is String && rawNeeds.trim().isNotEmpty) {
        helpNeeds = [rawNeeds.trim()];
      }
    }

    // workPermit can be bool or legacy string ('Sí'/'No')
    final rawWorkPermit = data['companionWorkPermit'] ?? data['workPermit'];
    bool? workPermit;
    if (rawWorkPermit is bool) {
      workPermit = rawWorkPermit;
    } else if (rawWorkPermit is String) {
      final lower = rawWorkPermit.trim().toLowerCase();
      if (lower == 'true' || lower == 'si' || lower == 'sí') {
        workPermit = true;
      } else if (lower == 'false' || lower == 'no') {
        workPermit = false;
      }
    }

    // companionContactSchedule can be List or legacy String
    final rawSchedule = data['companionContactSchedule'] ?? data['contactSchedule'] ?? data['schedule'];
    List<String>? schedule;
    if (rawSchedule != null) {
      if (rawSchedule is List) {
        final items = rawSchedule
            .map((e) => e.toString().replaceAll('[', '').replaceAll(']', '').trim())
            .where((s) => s.isNotEmpty)
            .toList();
        if (items.isNotEmpty) schedule = items;
      } else if (rawSchedule is String) {
        final str = rawSchedule.toString().replaceAll('[', '').replaceAll(']', '').trim();
        if (str.isNotEmpty) schedule = [str];
      }
    }

    // companionFormHelp / companionProfessionalHelp stored as bool
    final rawFormHelp = data['companionFormHelp'] ?? data['companionProfessionalHelp'] ?? data['helpFillingForm'] ?? data['formHelp'];
    bool? formHelp;
    if (rawFormHelp is bool) {
      formHelp = rawFormHelp;
    } else if (rawFormHelp is String) {
      final lower = rawFormHelp.trim().toLowerCase();
      if (lower == 'true' || lower == 'si' || lower == 'sí') {
        formHelp = true;
      } else if (lower == 'false' || lower == 'no') {
        formHelp = false;
      }
    }

    String? getString(dynamic v) =>
        (v != null && v.toString().trim().isNotEmpty) ? v.toString().trim() : null;

    return CompanionData(
      companionDataId: documentId,
      userId: getString(data['userId']),
      companionFamilyStatus: getString(
        data['companionFamilyStatus'] ?? data['companionFamilySituation'] ?? data['familyStatus'] ?? data['familySituation'],
      ),
      companionArrivalDateInSpain: getString(
        data['companionArrivalDateInSpain'] ?? data['companionDateArriveSpain'] ?? data['arrivalDateInSpain'] ?? data['arrivalDate'],
      ),
      companionAdministrativeStatus: getString(
        data['companionAdministrativeStatus'] ?? data['administrativeStatus'],
      ),
      companionWorkPermit: workPermit,
      companionWorkPermitRenewalDate: getString(
        data['companionWorkPermitRenewalDate'] ?? data['workPermitRenewalDate'],
      ),
      companionDocumentType: getString(
        data['companionDocumentType'] ?? data['documentType'] ?? data['personalDocumentType'],
      ),
      companionDocumentNumber: getString(
        data['companionDocumentNumber'] ?? data['documentNumber'] ?? data['dni'],
      ),
      companionHelpNeeds: helpNeeds.isEmpty ? null : helpNeeds,
      companionHelpNeedsOther: getString(data['companionHelpNeedsOther'] ?? data['helpNeedsOther']),
      companionContactSchedule: schedule,
      companionFormHelp: formHelp,
      companionOtherRelevantData: getString(
        data['companionOtherRelevantData'] ?? data['otherRelevantData'] ?? data['observations'] ?? data['observaciones'],
      ),
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
      'companionWorkPermitRenewalDate': companionWorkPermitRenewalDate,
      'companionDocumentType': companionDocumentType,
      'companionDocumentNumber': companionDocumentNumber,
      'companionHelpNeeds': companionHelpNeeds,
      'companionHelpNeedsOther': companionHelpNeedsOther,
      'companionContactSchedule': companionContactSchedule,
      'companionFormHelp': companionFormHelp,
      'companionOtherRelevantData': companionOtherRelevantData,
    };
  }
}
