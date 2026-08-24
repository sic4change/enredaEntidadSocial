import 'package:enreda_empresas/app/values/strings.dart';
import 'package:flutter/material.dart';

class Competency {
  Competency({
    this.id,
    required this.name,
    required this.description,
    this.badgesImages = const {},
    this.testQuestions = const [],
    this.trickQuestion,
  });

  factory Competency.fromMap(Map<String, dynamic> data, String documentId) {
    final String id = (data['id'] ?? documentId).toString();
    final String name = (data['name'] ?? '').toString();
    final String description = (data['description'] ?? '').toString();

    Map<String, String> badgesImages = {};
    if (data['badgesImages'] != null && data['badgesImages'] is Map) {
      (data['badgesImages'] as Map).forEach((k, v) {
        if (k != null && v != null) {
          badgesImages[k.toString()] = v.toString();
        }
      });
      // Fallback for BADGE_PROCESSING if missing
      if (!badgesImages.containsKey(StringConst.BADGE_PROCESSING) &&
          badgesImages.containsKey(StringConst.BADGE_VALIDATED)) {
        badgesImages[StringConst.BADGE_PROCESSING] =
            badgesImages[StringConst.BADGE_VALIDATED]!;
      }
    }

    List<String> testQuestions = [];
    if (data['testQuestions'] != null && data['testQuestions'] is List) {
      for (final element in (data['testQuestions'] as List)) {
        if (element != null) {
          testQuestions.add(element.toString());
        }
      }
    }

    final String? trickQuestion = data['trickQuestion']?.toString();

    return Competency(
      id: id,
      name: name,
      description: description,
      badgesImages: badgesImages,
      testQuestions: testQuestions,
      trickQuestion: trickQuestion,
    );
  }

  final String? id;
  final String name;
  final String description;
  final Map<String, String> badgesImages;
  final List<String> testQuestions;
  final String? trickQuestion;

  final ValueNotifier<bool> selected = ValueNotifier<bool>(false);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'badgesImages': badgesImages,
      'testQuestions': testQuestions,
      'trickQuestion': trickQuestion,
    };
  }

  @override
  bool operator == (Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Competency &&
            other.id == id);
  }

  @override
  // TODO: implement hashCode
  int get hashCode => id.hashCode;


}
