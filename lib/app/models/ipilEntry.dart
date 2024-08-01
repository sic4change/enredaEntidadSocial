import 'package:enreda_empresas/app/models/ipilConnectionTerritory.dart';
import 'package:enreda_empresas/app/models/ipilContextualization.dart';
import 'package:enreda_empresas/app/models/ipilInterviews.dart';
import 'package:enreda_empresas/app/models/ipilReinforcement.dart';

class IpilEntry {
  IpilEntry({
    this.ipilId,
    this.content,
    this.techId,
    required this.userId,
    required this.date,
    this.reinforcement,
    this.reinforcementsText,
    this.contextualization,
    this.contextualizationText,
    this.connectionTerritory,
    this.connectionTerritoryText,
    this.interviews,
    this.interviewsText,
    this.results,
  });

  final String? ipilId;
  late String? content;
  final String? techId;
  final String userId;
  late DateTime date;
  late List<String>? reinforcement;
  late String? reinforcementsText;
  late List<String>? contextualization;
  late String? contextualizationText;
  late List<String>? connectionTerritory;
  late String? connectionTerritoryText;
  late List<String>? interviews;
  late String? interviewsText;
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

    List<String> results = [];
    if (data['results'] != null) {
      data['results'].forEach((result) {results.add(result.toString());});
    }

    return IpilEntry(
      ipilId: data['ipilId'],
      content: data['content'],
      techId: data['techId'],
      userId: data['userId'],
      date: data['date'].toDate(),
      reinforcement: reinforcements,
      reinforcementsText: data['reinforcementsText'] ?? '',
      contextualization: contextualizations,
      contextualizationText: data['contextualizationText']  ?? '',
      connectionTerritory: connectionTerritories,
      connectionTerritoryText: data['connectionTerritoryText']  ?? '',
      interviews: interviews,
      interviewsText: data['interviewsText'] ?? '',
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
      'userId': userId,
      'date': date,
      'reinforcement': reinforcement,
      'reinforcementsText': reinforcementsText,
      'contextualization': contextualization,
      'contextualizationText': contextualizationText,
      'connectionTerritory': connectionTerritory,
      'connectionTerritoryText': connectionTerritoryText,
      "interviews": interviews,
      "interviewsText": interviewsText,
      'results': results,
    };
  }
}