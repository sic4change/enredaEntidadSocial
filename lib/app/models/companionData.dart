class CompanionData {
  CompanionData({
    this.companionDataId,
    this.userId,
    this.companionDocumentNumber,
    this.companionAdministrativeStatus,
    this.companionHelpNeeds,
    this.companionOtherRelevantData,
  });

  final String? companionDataId;
  final String? userId;
  final String? companionDocumentNumber;
  final String? companionAdministrativeStatus;
  final List<String>? companionHelpNeeds;
  final String? companionOtherRelevantData;

  factory CompanionData.fromMap(Map<String, dynamic> data, String documentId) {
    List<String> helpNeeds = [];
    if (data['companionHelpNeeds'] != null) {
      final raw = data['companionHelpNeeds'];
      if (raw is List) {
        helpNeeds = raw.map((e) => e.toString()).toList();
      }
    }

    return CompanionData(
      companionDataId: documentId,
      userId: data['userId'] as String?,
      companionDocumentNumber: data['companionDocumentNumber'] as String?,
      companionAdministrativeStatus:
          data['companionAdministrativeStatus'] as String?,
      companionHelpNeeds: helpNeeds.isEmpty ? null : helpNeeds,
      companionOtherRelevantData:
          data['companionOtherRelevantData'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'companionDataId': companionDataId,
      'userId': userId,
      'companionDocumentNumber': companionDocumentNumber,
      'companionAdministrativeStatus': companionAdministrativeStatus,
      'companionHelpNeeds': companionHelpNeeds,
      'companionOtherRelevantData': companionOtherRelevantData,
    };
  }
}
