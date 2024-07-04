import 'package:enreda_empresas/app/models/ipilConnectionTerritory.dart';
import 'package:enreda_empresas/app/models/ipilContextualization.dart';
import 'package:enreda_empresas/app/models/ipilInterviews.dart';
import 'package:enreda_empresas/app/models/ipilReinforcement.dart';

class IpilObjectives {
  IpilObjectives({
    this.userId,
    this.ipilObjectivesId,
    this.monthShort1,
    this.monthShort2,
    this.monthShort3,
    this.monthMedium1,
    this.monthMedium2,
    this.monthMedium3,
    this.monthLong1,
    this.monthLong2,
    this.monthLong3,
  });

  final String? userId;
  final String? ipilObjectivesId;
  final String? monthShort1;
  final String? monthShort2;
  final String? monthShort3;
  final String? monthMedium1;
  final String? monthMedium2;
  final String? monthMedium3;
  final String? monthLong1;
  final String? monthLong2;
  final String? monthLong3;

  factory IpilObjectives.fromMap(Map<String, dynamic> data, String documentId) {

    return IpilObjectives(
      userId: data['userId'],
      ipilObjectivesId: data['ipilObjectivesId'],
      monthShort1: data['monthShort1'],
      monthShort2: data['monthShort2'],
      monthShort3: data['monthShort3'],
      monthMedium1: data['monthMedium1'],
      monthMedium2: data['monthMedium2'],
      monthMedium3: data['monthMedium3'],
      monthLong1: data['monthLong1'],
      monthLong2: data['monthLong2'],
      monthLong3: data['monthLong3'],
    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IpilObjectives &&
            other.ipilObjectivesId == ipilObjectivesId);
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'ipilObjectivesId': ipilObjectivesId,
      'monthShort1': monthShort1,
      'monthShort2': monthShort2,
      'monthShort3': monthShort3,
      'monthMedium1': monthMedium1,
      'monthMedium2': monthMedium2,
      'monthMedium3': monthMedium3,
      'monthLong1': monthLong1,
      "monthLong2": monthLong2,
      'monthLong3': monthLong3,
    };
  }
}