

class IpilEntry {
  IpilEntry({
    this.ipilId,
    this.sesionId,
    this.content,
    this.techId,
    this.techName,
    required this.userId,
    required this.date,
    this.lastUpdateDate,
    this.reinforcement,
    this.reinforcementsText,
    this.contextualization,
    this.contextualizationText,
    this.connectionTerritory,
    this.connectionTerritoryText,
    this.interviews,
    this.interviewsText,
    this.intermediations,
    this.intermediationsText,
    this.obtainingEmployment,
    this.obtainingEmploymentText,
    this.improvingEmployment,
    this.improvingEmploymentText,
    this.coordination,
    this.coordinationText,
    this.postWorkSupport,
    this.postWorkSupportText,
    this.legal,
    this.legalText,
    this.economicBag,
    this.economicBagText,
    this.specificSkills,
    this.specificSkillsText,
    this.softSkills,
    this.softSkillsText,
    this.digitalSkills,
    this.digitalSkillsText,
    this.laborSkills,
    this.laborSkillsText,
    this.initialInterview,
    this.initialJobValorationQuestionary,
    this.finalInterview,
    this.finalJobValorationQuestionary,
    this.contactedPersonEvaluation,
    this.contactedPersonNoIntervention,
    this.other,
    this.results,
    this.fourWeeksCheck,
    this.fourWeeksSituation,
    this.fourWeeksEmploymentTypeId,
    this.fourWeeksSatisfaction,
    this.fourWeeksImpact,
    this.fourWeeksImprovement,
    this.sixMonthsCheck,
    this.sixMonthsSituation,
    this.sixMonthsEmploymentTypeId,
    this.sixMonthsSatisfaction,
    this.sixMonthsImpact,
    this.sixMonthsImprovement,
  });

  final String? ipilId;

  /// Origin link: when an IpilEntry is auto-created from a Sesion (after
  /// the participant is marked attended), the session's id is stored here
  /// so the lifecycle can be reversed — toggling attendance off / absent
  /// deletes the matching entry via [Database.deleteIpilEntriesBySesionAndUser].
  /// Null for manually-created (per-participant) IPIL entries.
  final String? sesionId;

  late String? content;
  final String? techId;
  final String? techName;
  final String userId;
  late DateTime date;
  late DateTime? lastUpdateDate;
  late List<String>? reinforcement;
  late String? reinforcementsText;
  late List<String>? contextualization;
  late String? contextualizationText;
  late List<String>? connectionTerritory;
  late String? connectionTerritoryText;
  late List<String>? interviews;
  late String? interviewsText;
  late List<String>? intermediations;
  late String? intermediationsText;
  late List<String>? obtainingEmployment;
  late String? obtainingEmploymentText;
  late List<String>? improvingEmployment;
  late String? improvingEmploymentText;
  late List<String>? coordination;
  late String? coordinationText;
  late List<String>? postWorkSupport;
  late String? postWorkSupportText;
  late List<String>? legal;
  late String? legalText;
  late List<String>? economicBag;
  late String? economicBagText;
  late List<String>? specificSkills;
  late String? specificSkillsText;
  late List<String>? softSkills;
  late String? softSkillsText;
  late List<String>? digitalSkills;
  late String? digitalSkillsText;
  late List<String>? laborSkills;
  late String? laborSkillsText;
  late bool? initialInterview;
  late bool? initialJobValorationQuestionary;
  late bool? finalInterview;
  late bool? finalJobValorationQuestionary;
  /// New option under "Inicio de itinerario": Persona contactada - En valoración.
  late bool? contactedPersonEvaluation;
  /// New option under "Cierre de itinerario": Persona contactada - No corresponde acompañamiento.
  late bool? contactedPersonNoIntervention;
  late String? other;
  late List<String>? results;

  /// Seguimiento a las 4 semanas tras completar el Informe de Cierre (ClosureReport).
  /// Solo un IPIL por participante puede tener este flag a true.
  final bool? fourWeeksCheck;
  /// Texto de la opción elegida (ver [StringConst.IPIL_FOUR_WEEKS_SITUATIONS]).
  final String? fourWeeksSituation;
  /// Id del `interest` elegido como tipo de empleo (solo si "Obtienen empleo").
  final String? fourWeeksEmploymentTypeId;
  /// Satisfacción 1–4 (solo si "Obtienen empleo").
  final int? fourWeeksSatisfaction;
  /// Impacto percibido 1–6.
  final int? fourWeeksImpact;
  final String? fourWeeksImprovement;

  /// Seguimiento a los 6 meses tras completar el Informe de Cierre (ClosureReport).
  /// Solo se ofrece si otro IPIL ya tiene [fourWeeksCheck] a true.
  final bool? sixMonthsCheck;
  final String? sixMonthsSituation;
  final String? sixMonthsEmploymentTypeId;
  final int? sixMonthsSatisfaction;
  final int? sixMonthsImpact;
  final String? sixMonthsImprovement;

  /// Firestore list fields may hold legacy values like "" instead of an
  /// array, so accept any shape and fall back to an empty list.
  static List<String> _toStringList(dynamic value) {
    if (value is Iterable) return value.map((e) => e.toString()).toList();
    if (value is String && value.isNotEmpty) return [value];
    return [];
  }

  factory IpilEntry.fromMap(Map<String, dynamic> data, String documentId) {

    final reinforcements = _toStringList(data['reinforcement']);
    final contextualizations = _toStringList(data['contextualization']);
    final connectionTerritories = _toStringList(data['connectionTerritory']);
    final interviews = _toStringList(data['interviews']);
    final intermediations = _toStringList(data['intermediations']);
    final obtainingEmployment = _toStringList(data['obtainingEmployment']);
    final improvingEmployment = _toStringList(data['improvingEmployment']);
    final coordination = _toStringList(data['coordination']);
    final legal = _toStringList(data['legal']);
    final postWorkSupport = _toStringList(data['postWorkSupport']);
    final economicBag = _toStringList(data['economicBag']);
    final specificSkills = _toStringList(data['specificSkills']);
    final softSkills = _toStringList(data['softSkills']);
    final digitalSkills = _toStringList(data['digitalSkills']);
    final laborSkills = _toStringList(data['laborSkills']);
    final results = _toStringList(data['results']);

    return IpilEntry(
      ipilId: data['ipilId']?.toString() ?? documentId,
      sesionId: data['sesionId']?.toString(),
      content: data['content'],
      techId: data['techId']?.toString() ?? documentId,
      techName: data['techName'] == null ? '' : data['techName'],
      userId: data['userId']?.toString() ?? '',
      date: data['date'].toDate(),
      lastUpdateDate: data['lastUpdateDate'] != null ? data['lastUpdateDate'].toDate() : null,
      reinforcement: reinforcements,
      reinforcementsText: data['reinforcementsText'] ?? '',
      contextualization: contextualizations,
      contextualizationText: data['contextualizationText']  ?? '',
      connectionTerritory: connectionTerritories,
      connectionTerritoryText: data['connectionTerritoryText']  ?? '',
      interviews: interviews,
      interviewsText: data['interviewsText'] ?? '',
      intermediations: intermediations,
      intermediationsText: data['intermediationsText'] ?? '',
      obtainingEmployment: obtainingEmployment,
      obtainingEmploymentText: data['obtainingEmploymentText'] ?? '',
      improvingEmployment: improvingEmployment,
      improvingEmploymentText: data['improvingEmploymentText'] ?? '',
      coordination: coordination,
      coordinationText: data['coordinationText'] ?? '',
      postWorkSupport: postWorkSupport,
      postWorkSupportText: data['postWorkSupportText'] ?? '',
      legal: legal,
      legalText: data['legalText'] ?? '',
      economicBag: economicBag,
      economicBagText: data['economicBagText'] ?? '',
      specificSkills: specificSkills,
      specificSkillsText: data['specificSkillsText'] ?? '',
      softSkills: softSkills,
      softSkillsText: data['softSkillsText'] ?? '',
      digitalSkills: digitalSkills,
      digitalSkillsText: data['digitalSkillsText'] ?? '',
      laborSkills: laborSkills,
      laborSkillsText: data['laborSkillsText'] ?? '',
      initialInterview: data['initialInterview'] ?? false,
      initialJobValorationQuestionary: data['initialJobValorationQuestionary'] ?? false,
      finalInterview: data['finalInterview'] ?? false,
      finalJobValorationQuestionary: data['finalJobValorationQuestionary'] ?? false,
      contactedPersonEvaluation: data['contactedPersonEvaluation'] ?? false,
      contactedPersonNoIntervention: data['contactedPersonNoIntervention'] ?? false,
      other: data['other'] ?? '',
      results: results,
      fourWeeksCheck: data['fourWeeksCheck'] == true,
      fourWeeksSituation: data['fourWeeksSituation']?.toString(),
      fourWeeksEmploymentTypeId: data['fourWeeksEmploymentTypeId']?.toString(),
      fourWeeksSatisfaction: (data['fourWeeksSatisfaction'] as num?)?.toInt(),
      fourWeeksImpact: (data['fourWeeksImpact'] as num?)?.toInt(),
      fourWeeksImprovement: data['fourWeeksImprovement']?.toString(),
      sixMonthsCheck: data['sixMonthsCheck'] == true,
      sixMonthsSituation: data['sixMonthsSituation']?.toString(),
      sixMonthsEmploymentTypeId: data['sixMonthsEmploymentTypeId']?.toString(),
      sixMonthsSatisfaction: (data['sixMonthsSatisfaction'] as num?)?.toInt(),
      sixMonthsImpact: (data['sixMonthsImpact'] as num?)?.toInt(),
      sixMonthsImprovement: data['sixMonthsImprovement']?.toString(),
    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IpilEntry &&
            other.ipilId == ipilId);
  }

  Map<String, dynamic> toMap() {
    return {
      'ipilId': ipilId,
      'sesionId': sesionId,
      'content': content,
      'techId': techId,
      'techName': techName,
      'userId': userId,
      'date': date,
      'lastUpdateDate': lastUpdateDate,
      'reinforcement': reinforcement,
      'reinforcementsText': reinforcementsText,
      'contextualization': contextualization,
      'contextualizationText': contextualizationText,
      'connectionTerritory': connectionTerritory,
      'connectionTerritoryText': connectionTerritoryText,
      "interviews": interviews,
      "interviewsText": interviewsText,
      "intermediations": intermediations,
      "intermediationsText": intermediationsText,
      "obtainingEmployment": obtainingEmployment,
      "obtainingEmploymentText": obtainingEmploymentText,
      "improvingEmployment": improvingEmployment,
      "improvingEmploymentText": improvingEmploymentText,
      "coordination": coordination,
      "coordinationText": coordinationText,
      "postWorkSupport": postWorkSupport,
      "postWorkSupportText": postWorkSupportText,
      "legal": legal,
      "legalText": legalText,
      "economicBag": economicBag,
      "economicBagText": economicBagText,
      "specificSkills": specificSkills,
      "specificSkillsText": specificSkillsText,
      "softSkills": softSkills,
      "softSkillsText": softSkillsText,
      "digitalSkills": digitalSkills,
      "digitalSkillsText": digitalSkillsText,
      "laborSkills": laborSkills,
      "laborSkillsText": laborSkillsText,
      "initialInterview": initialInterview,
      "initialJobValorationQuestionary": initialJobValorationQuestionary,
      "finalInterview": finalInterview,
      "finalJobValorationQuestionary": finalJobValorationQuestionary,
      "contactedPersonEvaluation": contactedPersonEvaluation,
      "contactedPersonNoIntervention": contactedPersonNoIntervention,
      "other": other,
      'results': results,
      // Follow-up fields: only written when set, so saving an IPIL from a
      // code path unaware of them never clears an existing follow-up.
      if (fourWeeksCheck == true) 'fourWeeksCheck': true,
      if (fourWeeksSituation != null) 'fourWeeksSituation': fourWeeksSituation,
      if (fourWeeksEmploymentTypeId != null) 'fourWeeksEmploymentTypeId': fourWeeksEmploymentTypeId,
      if (fourWeeksSatisfaction != null) 'fourWeeksSatisfaction': fourWeeksSatisfaction,
      if (fourWeeksImpact != null) 'fourWeeksImpact': fourWeeksImpact,
      if (fourWeeksImprovement != null) 'fourWeeksImprovement': fourWeeksImprovement,
      if (sixMonthsCheck == true) 'sixMonthsCheck': true,
      if (sixMonthsSituation != null) 'sixMonthsSituation': sixMonthsSituation,
      if (sixMonthsEmploymentTypeId != null) 'sixMonthsEmploymentTypeId': sixMonthsEmploymentTypeId,
      if (sixMonthsSatisfaction != null) 'sixMonthsSatisfaction': sixMonthsSatisfaction,
      if (sixMonthsImpact != null) 'sixMonthsImpact': sixMonthsImpact,
      if (sixMonthsImprovement != null) 'sixMonthsImprovement': sixMonthsImprovement,
    };
  }
}