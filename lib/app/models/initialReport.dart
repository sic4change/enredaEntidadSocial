class InitialReport {
  InitialReport({
    this.initialReportId,
    this.userId,
    this.finished,

    this.subsidy,

    //Section 1
    this.orientation1,
    this.arriveDate,
    this.receptionResources,
    this.externalResources,
    this.administrativeSituation,

    //Section 2
    this.orientation2,
    this.expirationDate,
    this.healthCard,
    this.disease,
    this.medication,

    //Section 2.1
    this.orientation2_1,
    this.rest,
    this.diagnosis,
    this.treatment,
    this.tracking,
    this.psychosocial,

    //Section 2.2
    this.orientation2_2,
    this.disabilityState,
    this.referenceProfessionalDisability,
    this.disabilityGrade,

    //Section 2.3
    this.orientation2_3,
    this.dependenceState,
    this.referenceProfessionalDependence,
    this.homeAssistance,
    this.teleassistance,
    this.dependenceGrade,

    //Section 2.4
    this.orientation2_4,
    this.externalDerivation,
    this.consumptionLevel,
    this.addictionTreatment,

    //Section 3
    this.orientation3,
    this.openLegalProcess,
    this.closeLegalProcess,
    this.legalRepresentation,

    //Section 4
    this.orientation4,
    this.ownershipType,
    this.location,
    this.livingUnit,
    this.centerContact,
    this.hostingObservations,

    //Section 5
    this.orientation5,
    this.informationNetworks,

    //Section 6
    this.orientation6,
    this.socialStructureKnowledge,
    this.autonomyPhysicMental,
    this.socialSkills,

    //Section 7
    this.orientation7,
    this.language,
    this.languageLevel,

    //Section 8
    this.orientation8,
    this.economicProgramHelp,
    this.familySupport,
    this.familyResponsibilities,

    //Section 9
    this.orientation9,
    this.socialServiceAccess,
    this.centerTSReference,
    this.subsidyBeneficiary,
    this.socialServicesUser,
    this.socialExclusionCertificate,

    //Section 10
    this.orientation10,
    this.digitalSkillsLevel,

    //Section 11
    this.orientation11,
    this.laborMarkerInterest,
    this.laborExpectations,

    //Section 12
    this.orientation12,
    this.vulnerabilityOptions,

    //Section 13
    this.orientation13,
    this.educationLevel,
    this.laborSituation,
    this.laborExternalResources,
    this.educationalEvaluation,
    this.formativeItinerary,
    this.laborInsertion,
    this.accompanimentPostLabor,
    this.laborUpgrade,


  });

  //Basic
  final String? initialReportId;
  final String? userId;
  final bool? finished;

  //Pre-Sections
  final String? subsidy;

  //Section 1
  final String? orientation1;
  final DateTime? arriveDate;
  final String? receptionResources;
  final String? externalResources;
  final String? administrativeSituation;

  //Section 2
  final String? orientation2;
  final DateTime? expirationDate;
  final String? healthCard;
  final String? disease;
  final String? medication;

  //Section 2.1
  final String? orientation2_1;
  final String? rest;
  final String? diagnosis;
  final String? treatment;
  final String? tracking;
  final String? psychosocial;

  //Section 2.2
  final String? orientation2_2;
  final String? disabilityState;
  final String? referenceProfessionalDisability;
  final String? disabilityGrade;

  //Section 2.3
  final String? orientation2_3;
  final String? dependenceState;
  final String? referenceProfessionalDependence;
  final String? homeAssistance;
  final String? teleassistance;
  final String? dependenceGrade;

  //Section 2.4
  final String? orientation2_4;
  final String? externalDerivation;
  final String? consumptionLevel;
  final String? addictionTreatment;

  //Section 3
  final String? orientation3;
  final String? openLegalProcess;
  final String? closeLegalProcess;
  final String? legalRepresentation;

  //Section 4
  final String? orientation4;
  final String? ownershipType;
  final String? location;
  final String? livingUnit;
  final String? centerContact;
  final List<String>? hostingObservations;

  //Section 5
  final String? orientation5;
  final String? informationNetworks;

  //Section 6
  final String? orientation6;
  final String? socialStructureKnowledge;
  final String? autonomyPhysicMental;
  final String? socialSkills;

  //Section 7
  final String? orientation7;
  final String? language;
  final String? languageLevel;

  //Section 8
  final String? orientation8;
  final String? economicProgramHelp;
  final String? familySupport;
  final String? familyResponsibilities;

  //Section 9
  final String? orientation9;
  final String? socialServiceAccess;
  final String? centerTSReference;
  final String? subsidyBeneficiary;
  final String? socialServicesUser;
  final String? socialExclusionCertificate;

  //Section 10
  final String? orientation10;
  final String? digitalSkillsLevel;

  //Section 11
  final String? orientation11;
  final String? laborMarkerInterest;
  final String? laborExpectations;

  //Section 12
  final String? orientation12;
  final List<String>? vulnerabilityOptions;

  //Section 13
  final String? orientation13;
  final String? educationLevel;
  final String? laborSituation;
  final String? laborExternalResources;
  final String? educationalEvaluation;
  final String? formativeItinerary;
  final String? laborInsertion;
  final String? accompanimentPostLabor;
  final String? laborUpgrade;



  factory InitialReport.fromMap(Map<String, dynamic> data, String documentId) {
    List<String> hostingObservations = [];
    if (data['hostingObservations'] != null) {
      List<dynamic> list = data['hostingObservations'];
      list.forEach((element) {
        hostingObservations.add(element);
      });
    }

    List<String> vulnerabilityOptions = [];
    if (data['vulnerabilityOptions'] != null) {
      List<dynamic> list = data['vulnerabilityOptions'];
      list.forEach((element) {
        vulnerabilityOptions.add(element);
      });
    }

    return InitialReport(

        //Basic
      initialReportId: data['initialReportId'],
      userId: data['userId'],
      finished: data['finished'],

      //Pre-Sections
      subsidy: data['subsidy'],

      //Section 1
      orientation1: data['orientation1'],
      arriveDate: data['arriveDate'] != null ? data['arriveDate'].toDate() : null,
      receptionResources: data['receptionResources'],
      externalResources: data['externalResources'],
      administrativeSituation: data['administrativeSituation'],

      //Section 2
      orientation2: data['orientation2'],
      expirationDate: data['expirationDate'] != null ? data['expirationDate'].toDate() : null,
      healthCard: data['healthCard'],
      disease: data['disease'],
      medication: data['medication'],

      //Section 2.1
      orientation2_1: data['orientation2_1'],
      rest: data['rest'],
      diagnosis: data['diagnosis'],
      treatment: data['treatment'],
      tracking: data['tracking'],
      psychosocial: data['psychosocial'],

      //Section 2.2
      orientation2_2: data['orientation2_2'],
      disabilityState: data['disabilityState'],
      referenceProfessionalDisability: data['referenceProfessionalDisability'],
      disabilityGrade: data['disabilityGrade'],

      //Section 2.3
      orientation2_3: data['orientation2_3'],
      dependenceState: data['dependenceState'],
      referenceProfessionalDependence: data['referenceProfessionalDependence'],
      homeAssistance: data['homeAssistance'],
      teleassistance: data['teleassistance'],
      dependenceGrade: data['dependenceGrade'],

      //Section 2.4
      orientation2_4: data['orientation2_4'],
      externalDerivation: data['externalDerivation'],
      consumptionLevel: data['consumptionLevel'],
      addictionTreatment: data['addictionTreatment'],

      //Section 3
      orientation3: data['orientation3'],
      openLegalProcess: data['openLegalProcess'],
      closeLegalProcess: data['closeLegalProcess'],
      legalRepresentation: data['legalRepresentation'],

      //Section 4
      orientation4: data['orientation4'],
      ownershipType: data['ownershipType'],
      location: data['location'],
      livingUnit: data['livingUnit'],
      centerContact: data['centerContact'],
      hostingObservations: hostingObservations,


      //Section 5
      orientation5: data['orientation5'],
      informationNetworks: data['informationNetworks'],

      //Section 6
      orientation6: data['orientation6'],
      socialStructureKnowledge: data['socialStructureKnowledge'],
      autonomyPhysicMental: data['autonomyPhysicMental'],
      socialSkills: data['socialSkills'],

      //Section 7
      orientation7: data['orientation7'],
      language: data['language'],
      languageLevel: data['languageLevel'],

      //Section 8
      orientation8: data['orientation8'],
      economicProgramHelp: data['economicProgramHelp'],
      familySupport: data['familySupport'],
      familyResponsibilities: data['familyResponsibilities'],

      //Section 9
      orientation9: data['orientation9'],
      socialServiceAccess: data['socialServiceAccess'],
      centerTSReference: data['centerTSReference'],
      subsidyBeneficiary: data['subsidyBeneficiary'],
      socialServicesUser: data['socialServicesUser'],
      socialExclusionCertificate: data['socialExclusionCertificate'],

      //Section 10
      orientation10: data['orientation10'],
      digitalSkillsLevel: data['digitalSkillsLevel'],

      //Section 11
      orientation11: data['orientation11'],
      laborMarkerInterest: data['laborMarkerInterest'],
      laborExpectations: data['laborExpectations'],

      //Section 12
      orientation12: data['orientation12'],
      vulnerabilityOptions: vulnerabilityOptions,

      //Section 13
      orientation13: data['orientation13'],
      educationLevel: data['educationLevel'],
      laborSituation: data['laborSituation'],
      laborExternalResources: data['laborExternalResources'],
      educationalEvaluation: data['educationalEvaluation'],
      formativeItinerary: data['formativeItinerary'],
      laborInsertion: data['laborInsertion'],
      accompanimentPostLabor: data['accompanimentPostLabor'],
      laborUpgrade: data['laborUpgrade'],
    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InitialReport &&
            other.initialReportId == initialReportId);
  }

  Map<String, dynamic> toMap() {
    return {

      'initialReportId': initialReportId,
      'userId': userId,
      'finished': finished,

      //Pre-Sections
      'subsidy': subsidy,

      //Section 1
      'orientation1': orientation1,
      'arriveDate': arriveDate,
      'receptionResources': receptionResources,
      'externalResources': externalResources,
      'administrativeSituation': administrativeSituation,

      //Section 2
      'orientation2': administrativeSituation,
      'expirationDate': expirationDate,
      'healthCard': healthCard,
      'disease': disease,
      'medication': medication,

      //Section 2.1
      'orientation2_1': orientation2_1,
      'rest': rest,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'tracking': tracking,
      'psychosocial': psychosocial,

      //Section 2.2
      'orientation2_2': orientation2_2,
      'disabilityState': disabilityState,
      'referenceProfessionalDisability': referenceProfessionalDisability,
      'disabilityGrade': disabilityGrade,

      //Section 2.3
      'orientation2_3': orientation2_3,
      'dependenceState': dependenceState,
      'referenceProfessionalDependence': referenceProfessionalDependence,
      'homeAssistance': homeAssistance,
      'teleassistance': teleassistance,
      'dependenceGrade': dependenceGrade,

      //Section 2.4
      'orientation2_4': orientation2_4,
      'externalDerivation': externalDerivation,
      'consumptionLevel': consumptionLevel,
      'addictionTreatment': addictionTreatment,

      //Section 3
      'orientation3': orientation3,
      'openLegalProcess': openLegalProcess,
      'closeLegalProcess': closeLegalProcess,
      'legalRepresentation': legalRepresentation,

      //Section 4
      'orientation4': orientation4,
      'ownershipType': ownershipType,
      'location': location,
      'livingUnit': livingUnit,
      'centerContact': centerContact,
      'hostingObservations': hostingObservations,


      //Section 5
      'orientation5': orientation5,
      'informationNetworks': informationNetworks,

      //Section 6
      'orientation6': orientation6,
      'socialStructureKnowledge': socialStructureKnowledge,
      'autonomyPhysicMental': autonomyPhysicMental,
      'socialSkills': socialSkills,

      //Section 7
      'orientation7': orientation7,
      'language': language,
      'languageLevel': languageLevel,

      //Section 8
      'orientation8': orientation8,
      'economicProgramHelp': economicProgramHelp,
      'familySupport': familySupport,
      'familyResponsibilities': familyResponsibilities,

      //Section 9
      'orientation9': orientation9,
      'socialServiceAccess': socialServiceAccess,
      'centerTSReference': centerTSReference,
      'subsidyBeneficiary': subsidyBeneficiary,
      'socialServicesUser': socialServicesUser,
      'socialExclusionCertificate': socialExclusionCertificate,

      //Section 10
      'orientation10': orientation10,
      'digitalSkillsLevel': digitalSkillsLevel,

      //Section 11
      'orientation11': orientation11,
      'laborMarkerInterest': laborMarkerInterest,
      'laborExpectations': laborExpectations,

      //Section 12
      'orientation12': orientation12,
      'vulnerabilityOptions': vulnerabilityOptions,

      //Section 13
      'orientation13': orientation13,
      'educationLevel': educationLevel,
      'laborSituation': laborSituation,
      'laborExternalResources': laborExternalResources,
      'educationalEvaluation': educationalEvaluation,
      'formativeItinerary': formativeItinerary,
      'laborInsertion': laborInsertion,
      'accompanimentPostLabor': accompanimentPostLabor,
      'laborUpgrade': laborUpgrade,

    };
  }
}