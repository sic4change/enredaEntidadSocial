import 'package:enreda_empresas/app/models/ipilConnectionTerritory.dart';
import 'package:enreda_empresas/app/models/ipilContextualization.dart';
import 'package:enreda_empresas/app/models/ipilInterviews.dart';
import 'package:enreda_empresas/app/models/ipilReinforcement.dart';

class IpilEntry {
  IpilEntry({
    this.ipilId,
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
    this.other,
    this.results,
  });

  final String? ipilId;
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
  late String? other;
  late List<String>? results;

  factory IpilEntry.fromMap(Map<String, dynamic> data, String documentId) {

    List<String> reinforcements = [];
    if (data['reinforcement'] != null) {
      data['reinforcement'].forEach((reinforcement) {reinforcements.add(reinforcement.toString());});
    }

    List<String> contextualizations = [];
    if (data['contextualization'] != null) {
      data['contextualization'].forEach((contextualization) {contextualizations.add(contextualization.toString());});
    }

    List<String> connectionTerritories = [];
    if (data['connectionTerritory'] != null) {
      data['connectionTerritory'].forEach((connectionTerritory) {connectionTerritories.add(connectionTerritory.toString());});
    }

    List<String> interviews = [];
    if (data['interviews'] != null) {
      data['interviews'].forEach((interview) {interviews.add(interview.toString());});
    }

    List<String> intermediations = [];
    if (data['intermediations'] != null) {
      data['intermediations'].forEach((intermediation) {intermediations.add(intermediation.toString());});
    }

    List<String> obtainingEmployment = [];
    if (data['obtainingEmployment'] != null) {
      data['obtainingEmployment'].forEach((obtainedEmployment) {obtainingEmployment.add(obtainedEmployment.toString());});
    }

    List<String> improvingEmployment = [];
    if (data['improvingEmployment'] != null) {
      data['improvingEmployment'].forEach((improvedEmployment) {improvingEmployment.add(improvedEmployment.toString());});
    }

    List<String> coordination = [];
    if (data['coordination'] != null) {
      data['coordination'].forEach((singleCoordination) {coordination.add(singleCoordination.toString());});
    }

    List<String> legal = [];
    if (data['legal'] != null) {
      data['legal'].forEach((singleLegal) {legal.add(singleLegal.toString());});
    }

    List<String> postWorkSupport = [];
    if (data['postWorkSupport'] != null) {
      data['postWorkSupport'].forEach((singlePostWorkSupport) {postWorkSupport.add(singlePostWorkSupport.toString());});
    }

    List<String> economicBag = [];
    if (data['economicBag'] != null) {
      data['economicBag'].forEach((singleEconomicBag) {economicBag.add(singleEconomicBag.toString());});
    }

    List<String> specificSkills = [];
    if (data['specificSkills'] != null) {
      data['specificSkills'].forEach((specificSkill) {specificSkills.add(specificSkill.toString());});
    }

    List<String> softSkills = [];
    if (data['softSkills'] != null) {
      data['softSkills'].forEach((softSkill) {softSkills.add(softSkill.toString());});
    }

    List<String> digitalSkills = [];
    if (data['digitalSkills'] != null) {
      data['digitalSkills'].forEach((digitalSkill) {digitalSkills.add(digitalSkill.toString());});
    }

    List<String> laborSkills = [];
    if (data['laborSkills'] != null) {
      data['laborSkills'].forEach((laborSkill) {laborSkills.add(laborSkill.toString());});
    }

    List<String> results = [];
    if (data['results'] != null) {
      data['results'].forEach((result) {results.add(result.toString());});
    }

    return IpilEntry(
      ipilId: data['ipilId']?.toString() ?? documentId,
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
      other: data['other'] ?? '',
      results: results,
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
      "other": other,
      'results': results,
    };
  }
}