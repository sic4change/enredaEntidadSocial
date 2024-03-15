import 'package:enreda_empresas/app/models/languageReport.dart';

class FollowReport {
  FollowReport({
    this.followReportId,
    this.userId,
    this.finished,
    this.completedDate,

    this.subsidy,

    //Section 1
    this.orientation1,
    this.arriveDate,
    this.receptionResources,
    this.administrativeSituation,

    //Section 2
    this.orientation2,
    this.expirationDate,
    this.healthCard,
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
    this.granted,
    this.revisionDate,
    this.disabilityType,

    //Section 2.3
    this.orientation2_3,
    this.dependenceState,
    this.referenceProfessionalDependence,
    this.dependenceGrade,

    //Section 2.4
    this.orientation2_4,
    this.externalDerivation,

    //Section 3
    this.orientation3,
    this.internalDerivationLegal,
    this.externalDerivationLegal,
    this.legalRepresentation,

    //Section 4
    this.orientation4,
    this.ownershipType,
    this.location,
    this.centerContact,
    this.hostingObservations,

    //Section 5
    this.orientation5,
    this.informationNetworks,
    this.institutionNetworks,
    this.familyConciliation,

    //Section 7
    this.orientation7,
    this.languages,

    //Section 9
    this.orientation9,
    this.centerTSReference,
    this.subsidyBeneficiary,
    this.socialServicesUser,
    this.socialExclusionCertificate,

    //Section 12
    this.orientation12,
    this.vulnerabilityOptions,

    //Section 13
    this.orientation13,
    this.educationLevel,
    this.laborSituation,
    this.activeLabor,
    this.occupiedLabor,
    this.tempLabor,
    this.workingDayLabor,
    this.competencies,
    this.contextualization,
    this.connexion,
    this.shortTerm,
    this.mediumTerm,
    this.longTerm,


  });

  //Basic
  final String? followReportId;
  final String? userId;
  final bool? finished;
  final DateTime? completedDate;

  //Pre-Sections
  final String? subsidy;

  //Section 1
  final String? orientation1;
  final DateTime? arriveDate;
  final String? receptionResources;
  final String? administrativeSituation;

  //Section 2
  final String? orientation2;
  final DateTime? expirationDate;
  final String? healthCard;
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
  final String? granted;
  final DateTime? revisionDate;
  final String? disabilityType;

  //Section 2.3
  final String? orientation2_3;
  final String? dependenceState;
  final String? referenceProfessionalDependence;
  final String? dependenceGrade;

  //Section 2.4
  final String? orientation2_4;
  final String? externalDerivation;

  //Section 3
  final String? orientation3;
  final String? internalDerivationLegal;
  final String? externalDerivationLegal;
  final String? legalRepresentation;

  //Section 4
  final String? orientation4;
  final String? ownershipType;
  final String? location;
  final String? centerContact;
  final List<String>? hostingObservations;

  //Section 5
  final String? orientation5;
  final String? informationNetworks;
  final String? institutionNetworks;
  final String? familyConciliation;

  //Section 7
  final String? orientation7;
  final List<LanguageReport>? languages;

  //Section 9
  final String? orientation9;
  final String? centerTSReference;
  final String? subsidyBeneficiary;
  final String? socialServicesUser;
  final String? socialExclusionCertificate;

  //Section 12
  final String? orientation12;
  final List<String>? vulnerabilityOptions;

  //Section 13
  final String? orientation13;
  final String? educationLevel;
  final String? laborSituation;
  final String? activeLabor;
  final String? occupiedLabor;
  final String? tempLabor;
  final String? workingDayLabor;
  final String? competencies;
  final String? contextualization;
  final String? connexion;
  final String? shortTerm;
  final String? mediumTerm;
  final String? longTerm;




  factory FollowReport.fromMap(Map<String, dynamic> data, String documentId) {
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

    List<LanguageReport> languages = [];
    if (data['languages'] != null) {
      data['languages'].forEach((language) {
        final languagesFirestore = language as Map<String, dynamic>;
        languages.add(
            LanguageReport(
              name: languagesFirestore['name'] ?? '',
              level: languagesFirestore['level'] ?? '',
            )
        );
      });
    }

    return FollowReport(

      //Basic
      followReportId: data['followReportId'],
      userId: data['userId'],
      finished: data['finished'],
      completedDate: data['completedDate'] != null ? data['completedDate'].toDate() : null,

      //Pre-Sections
      subsidy: data['subsidy'],

      //Section 1
      orientation1: data['orientation1'],
      arriveDate: data['arriveDate'] != null ? data['arriveDate'].toDate() : null,
      receptionResources: data['receptionResources'],
      administrativeSituation: data['administrativeSituation'],

      //Section 2
      orientation2: data['orientation2'],
      expirationDate: data['expirationDate'] != null ? data['expirationDate'].toDate() : null,
      healthCard: data['healthCard'],
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
      granted: data['granted'],
      revisionDate: data['revisionDate'] != null ? data['revisionDate'].toDate() : null,
      disabilityType: data['disabilityType'],

      //Section 2.3
      orientation2_3: data['orientation2_3'],
      dependenceState: data['dependenceState'],
      referenceProfessionalDependence: data['referenceProfessionalDependence'],
      dependenceGrade: data['dependenceGrade'],

      //Section 2.4
      orientation2_4: data['orientation2_4'],
      externalDerivation: data['externalDerivation'],

      //Section 3
      orientation3: data['orientation3'],
      internalDerivationLegal: data['internalDerivationLegal'],
      externalDerivationLegal: data['externalDerivationLegal'],
      legalRepresentation: data['legalRepresentation'],

      //Section 4
      orientation4: data['orientation4'],
      ownershipType: data['ownershipType'],
      location: data['location'],
      centerContact: data['centerContact'],
      hostingObservations: hostingObservations,


      //Section 5
      orientation5: data['orientation5'],
      informationNetworks: data['informationNetworks'],
      institutionNetworks: data['institutionNetworks'],
      familyConciliation: data['familyConciliation'],

      //Section 7
      orientation7: data['orientation7'],
      languages: languages,

      //Section 9
      orientation9: data['orientation9'],
      centerTSReference: data['centerTSReference'],
      subsidyBeneficiary: data['subsidyBeneficiary'],
      socialServicesUser: data['socialServicesUser'],
      socialExclusionCertificate: data['socialExclusionCertificate'],

      //Section 12
      orientation12: data['orientation12'],
      vulnerabilityOptions: vulnerabilityOptions,

      //Section 13
      orientation13: data['orientation13'],
      educationLevel: data['educationLevel'],
      laborSituation: data['laborSituation'],
      activeLabor: data['activeLabor'],
      occupiedLabor: data['occupiedLabor'],
      tempLabor: data['tempLabor'],
      workingDayLabor: data['workingDayLabor'],
      competencies: data['competencies'],
      contextualization: data['contextualization'],
      connexion: data['connexion'],
      shortTerm: data['shortTerm'],
      mediumTerm: data['mediumTerm'],
      longTerm: data['longTerm'],
    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FollowReport &&
            other.followReportId == followReportId);
  }

  Map<String, dynamic> toMap() {
    return {

      'followReportId': followReportId,
      'userId': userId,
      'finished': finished,
      'completedDate': completedDate,

      //Pre-Sections
      'subsidy': subsidy,

      //Section 1
      'orientation1': orientation1,
      'arriveDate': arriveDate,
      'receptionResources': receptionResources,
      'administrativeSituation': administrativeSituation,

      //Section 2
      'orientation2': administrativeSituation,
      'expirationDate': expirationDate,
      'healthCard': healthCard,
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
      'granted': granted,
      'revisionDate': revisionDate,
      'disabilityType': disabilityType,

      //Section 2.3
      'orientation2_3': orientation2_3,
      'dependenceState': dependenceState,
      'referenceProfessionalDependence': referenceProfessionalDependence,
      'dependenceGrade': dependenceGrade,

      //Section 2.4
      'orientation2_4': orientation2_4,
      'externalDerivation': externalDerivation,

      //Section 3
      'orientation3': orientation3,
      'internalDerivationLegal': internalDerivationLegal,
      'externalDerivationLegal': externalDerivationLegal,
      'legalRepresentation': legalRepresentation,

      //Section 4
      'orientation4': orientation4,
      'ownershipType': ownershipType,
      'location': location,
      'centerContact': centerContact,
      'hostingObservations': hostingObservations,


      //Section 5
      'orientation5': orientation5,
      'informationNetworks': informationNetworks,
      'institutionNetworks': institutionNetworks,
      'familyConciliation': familyConciliation,


      //Section 7
      'orientation7': orientation7,
      'languages': languages != null ? languages!.map((e) => e.toMap()).toList() : [],

      //Section 9
      'orientation9': orientation9,
      'centerTSReference': centerTSReference,
      'subsidyBeneficiary': subsidyBeneficiary,
      'socialServicesUser': socialServicesUser,
      'socialExclusionCertificate': socialExclusionCertificate,

      //Section 12
      'orientation12': orientation12,
      'vulnerabilityOptions': vulnerabilityOptions,

      //Section 13
      'orientation13': orientation13,
      'educationLevel': educationLevel,
      'laborSituation': laborSituation,
      'activeLabor': activeLabor,
      'occupiedLabor': occupiedLabor,
      'tempLabor': tempLabor,
      'workingDayLabor': workingDayLabor,
      'competencies': competencies,
      'contextualization': contextualization,
      'connexion': connexion,
      'shortTerm': shortTerm,
      'mediumTerm': mediumTerm,
      'longTerm': longTerm,

    };
  }
}