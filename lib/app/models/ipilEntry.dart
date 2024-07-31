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
    this.connectionTerritory,
    this.interviews,
    this.results,
  });

  final String? ipilId;
  late String? content;
  final String? techId;
  final String userId;
  late DateTime date;
  late List<String>? reinforcement;
  late List<String>? reinforcementsText;
  late List<String>? contextualization;
  late List<String>? connectionTerritory;
  late List<String>? interviews;
  late List<String>? results;

  factory IpilEntry.fromMap(Map<String, dynamic> data, String documentId) {
/*
    final IpilReinforcement? reinforcement = new IpilReinforcement(
        label: data['reinforcement']['label'],
        order: data['reinforcement']['order']
    );

    final IpilContextualization? contextualization = new IpilContextualization(
        label: data['contextualization']['label'],
        order: data['contextualization']['order']
    );

    final IpilConnectionTerritory? connectionTerritory = new IpilConnectionTerritory(
        label: data['connectionTerritory']['label'],
        order: data['connectionTerritory']['order']
    );

    final IpilInterviews? interviews = new IpilInterviews(
        label: data['interviews']['label'],
        order: data['interviews']['order']
    );
 */
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
      contextualization: contextualizations,
      connectionTerritory: connectionTerritories,
      interviews: interviews,
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
      'contextualization': contextualization,
      'connectionTerritory': connectionTerritory,
      "interviews": interviews,
      'results': results,
    };
  }
}