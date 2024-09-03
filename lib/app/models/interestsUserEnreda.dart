class InterestsUserEnreda {
  InterestsUserEnreda({required this.interests, required this.specificInterests, required this.keepLearningOptions});

  factory InterestsUserEnreda.fromMap(Map<String, dynamic> data, String documentId) {
    final List<String> interests = data['interests']??[];
    final List<String> specificInterests = data['specificInterests']??[];
    final List<String> keepLearningOptions = data['keepLearningOptions']??[];

    return InterestsUserEnreda(
      interests: interests,
      specificInterests: specificInterests,
      keepLearningOptions: keepLearningOptions,
    );
  }

  final List<String> interests;
  final List<String> specificInterests;
  final List<String> keepLearningOptions;

  Map<String, dynamic> toMap() {
    return {
      'interests': interests,
      'specificInterests': specificInterests,
      'keepLearningOptions': keepLearningOptions,
    };
  }
}