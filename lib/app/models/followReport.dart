import 'package:enreda_empresas/app/models/formationReport.dart';
import 'package:enreda_empresas/app/models/languageReport.dart';

class FollowReport {
  FollowReport({
    this.followReportId,
    this.userId,
    this.finished,
    this.completedDate,
    this.dniParticipant,

    this.subsidy,
    this.techPerson,
    this.techPersonName,

    //Section 1
    this.orientation1,
    this.arriveDate,
    this.receptionResources,
    this.administrativeExternalResources,

    //Section 1.1
    this.adminState,
    this.adminNoThrough,
    this.adminDateAsk,
    this.adminDateResolution,
    this.adminDateConcession,
    this.adminTemp,
    this.adminResidenceWork,
    this.adminDateRenovation,
    this.adminResidenceType,
    this.adminJuridicFigure,
    this.adminOther,

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
    this.motive,

    //Section 3
    this.orientation3,
    this.internalDerivationLegal,
    this.internalDerivationDate,
    this.internalDerivationMotive,
    this.externalDerivationLegal,
    this.externalDerivationDate,
    this.externalDerivationMotive,
    this.psychosocialDerivationLegal,
    this.psychosocialDerivationDate,
    this.psychosocialDerivationMotive,
    this.legalRepresentation,
    this.processingBag,
    this.processingBagDate,
    this.economicAmount,

    //Section 4
    this.orientation4,
    this.ownershipType,
    this.location,
    this.centerContact,
    this.hostingObservations,
    this.ownershipTypeOpen,
    this.homelessnessSituation,
    this.homelessnessSituationOpen,
    this.livingUnit,
    this.ownershipTypeConcrete,

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
    this.socialExclusionCertificate,
    this.subsidyName,
    this.socialExclusionCertificateDate,
    this.socialExclusionCertificateObservations,

    //Section 12
    this.orientation12,
    this.vulnerabilityOptions,

    //Section 13
    this.orientation13,
    this.educationLevel,
    this.homologation,
    this.laborSituation,
    this.laborOtherConsiderations,
    this.tempLabor,
    this.workingDayLabor,
    this.competencies,
    this.contextualization,
    this.connexion,
    this.shortTerm,
    this.mediumTerm,
    this.longTerm,
    this.orientation13_2,

    //Section 9.5
    this.orientation9_5,
    this.formations,
    this.formationBag,
    this.formationBagDate,
    this.formationBagMotive,
    this.formationBagEconomic,
    this.jobObtaining,
    this.jobObtainDate,
    this.jobFinishDate,
    this.jobUpgrade,
    this.upgradeMotive,
    this.upgradeDate,
    this.orientation9_6,
    this.postLaborAccompaniment,
    this.postLaborAccompanimentMotive,
    this.postLaborInitialDate,
    this.postLaborFinalDate,
    this.postLaborTotalDays,
    this.jobMaintenance,


  });

  //Basic
  final String? followReportId;
  final String? userId;
  final bool? finished;
  final DateTime? completedDate;

  //Pre-Sections
  final String? subsidy;
  final String? techPerson;
  final String? techPersonName;
  final String? dniParticipant;

  //Section 1
  final String? orientation1;
  final DateTime? arriveDate;
  final String? receptionResources;
  final String? administrativeExternalResources;

  //Section 1.1
  final String? adminState;
  final String? adminNoThrough;
  final DateTime? adminDateAsk;
  final DateTime? adminDateResolution;
  final DateTime? adminDateConcession;
  final String? adminTemp;
  final DateTime? adminDateRenovation;
  final String? adminResidenceWork;
  final String? adminResidenceType;
  final String? adminJuridicFigure;
  final String? adminOther;

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
  final String? motive;

  //Section 3
  final String? orientation3;
  final String? internalDerivationLegal;
  final DateTime? internalDerivationDate;
  final String? internalDerivationMotive;
  final String? externalDerivationLegal;
  final DateTime? externalDerivationDate;
  final String? externalDerivationMotive;
  final String? psychosocialDerivationLegal;
  final DateTime? psychosocialDerivationDate;
  final String? psychosocialDerivationMotive;
  final String? legalRepresentation;
  final String? processingBag;
  final DateTime? processingBagDate;
  final String? economicAmount;

  //Section 4
  final String? orientation4;
  final String? ownershipType;
  final String? location;
  final String? centerContact;
  final List<String>? hostingObservations;
  final String? ownershipTypeOpen;
  final String? homelessnessSituation;
  final String? homelessnessSituationOpen;
  final String? livingUnit;
  final String? ownershipTypeConcrete;

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
  final String? socialExclusionCertificate;
  final String? subsidyName;
  final DateTime? socialExclusionCertificateDate;
  final String? socialExclusionCertificateObservations;

  //Section 12
  final String? orientation12;
  final List<String>? vulnerabilityOptions;

  //Section 13
  final String? orientation13;
  final String? educationLevel;
  final String? homologation;
  final String? laborSituation;
  final String? laborOtherConsiderations;
  final String? tempLabor;
  final String? workingDayLabor;
  final String? competencies;
  final String? contextualization;
  final String? connexion;
  final String? shortTerm;
  final String? mediumTerm;
  final String? longTerm;
  final String? orientation13_2;

  //Section 9.5
  final String? orientation9_5;
  final List<FormationReport>? formations;
  final String? formationBag;
  final DateTime? formationBagDate;
  final String? formationBagMotive;
  final String? formationBagEconomic;
  final String? jobObtaining;
  final DateTime? jobObtainDate;
  final DateTime? jobFinishDate;
  final String? jobUpgrade;
  final String? upgradeMotive;
  final DateTime? upgradeDate;
  final String? orientation9_6;
  final String? postLaborAccompaniment;
  final String? postLaborAccompanimentMotive;
  final DateTime? postLaborInitialDate;
  final DateTime? postLaborFinalDate;
  final int? postLaborTotalDays;
  final String? jobMaintenance;


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
              accreditation:  languagesFirestore['accreditation'] ?? '',
            )
        );
      });
    }

    List<FormationReport> formations = [];
    if (data['formations'] != null) {
      data['formations'].forEach((formation) {
        final formationsFirestore = formation as Map<String, dynamic>;
        formations.add(
            FormationReport(
              name: formationsFirestore['name'] ?? '',
              type: formationsFirestore['type'] ?? '',
              certification: formationsFirestore['certification'] ?? '',
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
      techPerson: data['techPerson'],
      techPersonName: data['techPersonName'],
      dniParticipant: data['dniParticipant'],

      //Section 1
      orientation1: data['orientation1'],
      arriveDate: data['arriveDate'] != null ? data['arriveDate'].toDate() : null,
      receptionResources: data['receptionResources'],
      administrativeExternalResources: data['administrativeExternalResources'],

      //Section 1.1
      adminState: data['adminState'],
      adminNoThrough: data['adminNoThrough'],
      adminDateAsk: data['adminDateAsk'] != null ? data['adminDateAsk'].toDate() : null,
      adminDateResolution: data['adminDateResolution'] != null ? data['adminDateResolution'].toDate() : null,
      adminDateConcession: data['adminDateConcession'] != null ? data['adminDateConcession'].toDate() : null,
      adminTemp: data['adminTemp'],
      adminResidenceWork: data['adminResidenceWork'],
      adminDateRenovation: data['adminDateRenovation'] != null ? data['adminDateRenovation'].toDate() : null,
      adminResidenceType: data['adminResidenceType'],
      adminJuridicFigure: data['adminJuridicFigure'],
      adminOther: data['adminOther'],

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
      motive: data['motive'],

      //Section 3
      orientation3: data['orientation3'],
      internalDerivationLegal: data['internalDerivationLegal'],
      internalDerivationDate: data['internalDerivationDate'] != null ? data['internalDerivationDate'].toDate() : null,
      internalDerivationMotive: data['internalDerivationMotive'],
      externalDerivationLegal: data['externalDerivationLegal'],
      externalDerivationDate: data['externalDerivationDate'] != null ? data['externalDerivationDate'].toDate() : null,
      externalDerivationMotive: data['externalDerivationMotive'],
      psychosocialDerivationLegal: data['psychosocialDerivationLegal'],
      psychosocialDerivationDate: data['psychosocialDerivationDate'] != null ? data['psychosocialDerivationDate'].toDate() : null,
      psychosocialDerivationMotive: data['psychosocialDerivationMotive'],
      legalRepresentation: data['legalRepresentation'],
      processingBag: data['processingBag'],
      processingBagDate: data['processingBagDate'] != null ? data['processingBagDate'].toDate() : null,
      economicAmount: data['economicAmount'],

      //Section 4
      orientation4: data['orientation4'],
      ownershipType: data['ownershipType'],
      location: data['location'],
      centerContact: data['centerContact'],
      hostingObservations: hostingObservations,
      ownershipTypeOpen: data['ownershipTypeOpen'],
      homelessnessSituation: data['homelessnessSituation'],
      homelessnessSituationOpen: data['homelessnessSituationOpen'],
      livingUnit: data['livingUnit'],
      ownershipTypeConcrete: data['ownershipTypeConcrete'],


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
      socialExclusionCertificate: data['socialExclusionCertificate'],
      subsidyName: data['subsidyName'],
      socialExclusionCertificateDate: data['socialExclusionCertificateDate'] != null ? data['socialExclusionCertificateDate'].toDate() : null,
      socialExclusionCertificateObservations: data['socialExclusionCertificateObservations'],

      //Section 12
      orientation12: data['orientation12'],
      vulnerabilityOptions: vulnerabilityOptions,

      //Section 13
      orientation13: data['orientation13'],
      educationLevel: data['educationLevel'],
      homologation: data['homologation'],
      laborSituation: data['laborSituation'],
      laborOtherConsiderations: data['laborOtherConsiderations'],
      tempLabor: data['tempLabor'],
      workingDayLabor: data['workingDayLabor'],
      competencies: data['competencies'],
      contextualization: data['contextualization'],
      connexion: data['connexion'],
      shortTerm: data['shortTerm'],
      mediumTerm: data['mediumTerm'],
      longTerm: data['longTerm'],
      orientation13_2: data['orientation13_2'],

      //Section 9.5
      orientation9_5: data['orientation9_5'],
      formations: formations,
      formationBag: data['formationBag'],
      formationBagDate: data['formationBagDate'] != null ? data['formationBagDate'].toDate() : null,
      formationBagMotive: data['formationBagMotive'],
      formationBagEconomic: data['formationBagEconomic'],
      jobObtaining: data['jobObtaining'],
      jobObtainDate: data['jobObtainDate'] != null ? data['jobObtainDate'].toDate() : null,
      jobFinishDate: data['jobFinishDate'] != null ? data['jobFinishDate'].toDate() : null,
      jobUpgrade: data['jobUpgrade'],
      upgradeMotive: data['upgradeMotive'],
      upgradeDate: data['upgradeDate'] != null ? data['upgradeDate'].toDate() : null,
      orientation9_6: data['orientation9_6'],
      postLaborAccompaniment: data['postLaborAccompaniment'],
      postLaborAccompanimentMotive: data['postLaborAccompanimentMotive'],
      postLaborInitialDate: data['postLaborInitialDate'] != null ? data['postLaborInitialDate'].toDate() : null,
      postLaborFinalDate: data['postLaborFinalDate'] != null ? data['postLaborFinalDate'].toDate() : null,
      postLaborTotalDays: data['postLaborTotalDays'],
      jobMaintenance: data['jobMaintenance'],


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
      'techPerson': techPerson,
      'techPersonName': techPersonName,
      'dniParticipant': dniParticipant,

      //Section 1
      'orientation1': orientation1,
      'arriveDate': arriveDate,
      'receptionResources': receptionResources,
      'administrativeExternalResources': administrativeExternalResources,

      //Section 1.1
      'adminState': adminState,
      'adminNoThrough': adminNoThrough,
      'adminDateAsk': adminDateAsk,
      'adminDateResolution': adminDateResolution,
      'adminDateConcession': adminDateConcession,
      'adminTemp': adminTemp,
      'adminResidenceWork': adminResidenceWork,
      'adminDateRenovation': adminDateRenovation,
      'adminResidenceType': adminResidenceType,
      'adminJuridicFigure': adminJuridicFigure,
      'adminOther': adminOther,

      //Section 2
      'orientation2': orientation2,
      'expirationDate': expirationDate,
      'healthCard': healthCard,
      'medication': medication,

      //Section 2.1
      'orientation2_1': orientation2_1,
      'rest': rest,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'tracking': tracking,

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
      'motive': motive,

      //Section 3
      'orientation3': orientation3,
      'internalDerivationLegal': internalDerivationLegal,
      'internalDerivationDate': internalDerivationDate,
      'internalDerivationMotive': internalDerivationMotive,
      'externalDerivationLegal': externalDerivationLegal,
      'externalDerivationDate': externalDerivationDate,
      'externalDerivationMotive': externalDerivationMotive,
      'psychosocialDerivationLegal': psychosocialDerivationLegal,
      'psychosocialDerivationDate': psychosocialDerivationDate,
      'psychosocialDerivationMotive': psychosocialDerivationMotive,
      'legalRepresentation': legalRepresentation,
      'processingBag': processingBag,
      'processingBagDate': processingBagDate,
      'economicAmount': economicAmount,

      //Section 4
      'orientation4': orientation4,
      'ownershipType': ownershipType,
      'location': location,
      'centerContact': centerContact,
      'hostingObservations': hostingObservations,
      'ownershipTypeOpen': ownershipTypeOpen,
      'homelessnessSituation': homelessnessSituation,
      'homelessnessSituationOpen': homelessnessSituationOpen,
      'livingUnit': livingUnit,
      'ownershipTypeConcrete': ownershipTypeConcrete,


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
      'socialExclusionCertificate': socialExclusionCertificate,
      'subsidyName': subsidyName,
      'socialExclusionCertificateDate': socialExclusionCertificateDate,
      'socialExclusionCertificateObservations': socialExclusionCertificateObservations,

      //Section 12
      'orientation12': orientation12,
      'vulnerabilityOptions': vulnerabilityOptions,

      //Section 13
      'orientation13': orientation13,
      'educationLevel': educationLevel,
      'homologation': homologation,
      'laborSituation': laborSituation,
      'laborOtherConsiderations': laborOtherConsiderations,
      'tempLabor': tempLabor,
      'workingDayLabor': workingDayLabor,
      'competencies': competencies,
      'contextualization': contextualization,
      'connexion': connexion,
      'shortTerm': shortTerm,
      'mediumTerm': mediumTerm,
      'longTerm': longTerm,
      'orientation13_2': orientation13_2,

      //Section 9.5
      'orientation9_5': orientation9_5,
      'formations': formations != null ? formations!.map((e) => e.toMap()).toList() : [],
      'formationBag': formationBag,
      'formationBagDate': formationBagDate,
      'formationBagMotive': formationBagMotive,
      'formationBagEconomic': formationBagEconomic,
      'jobObtaining': jobObtaining,
      'jobObtainDate': jobObtainDate,
      'jobFinishDate': jobFinishDate,
      'jobUpgrade': jobUpgrade,
      'upgradeMotive': upgradeMotive,
      'upgradeDate': upgradeDate,
      'orientation9_6': orientation9_6,
      'postLaborAccompaniment': postLaborAccompaniment,
      'postLaborAccompanimentMotive': postLaborAccompanimentMotive,
      'postLaborInitialDate': postLaborInitialDate,
      'postLaborFinalDate': postLaborFinalDate,
      'postLaborTotalDays': postLaborTotalDays,
      'jobMaintenance': jobMaintenance,

    };
  }
}