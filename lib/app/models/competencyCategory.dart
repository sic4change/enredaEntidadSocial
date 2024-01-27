class CompetencyCategory {
  CompetencyCategory({this.competencyCategoryId, required this.name, required this.order});

  factory CompetencyCategory.fromMap(Map<String, dynamic> data, String documentId) {
    final String name = data['name'];
    final String? competencyCategoryId = data['competencyCategoryId'];
    final int? order = data['order'];

    return CompetencyCategory(
      order: order,
      name: name,
      competencyCategoryId: competencyCategoryId,
    );
  }

  final String name;
  final String? competencyCategoryId;
  final int? order;

  @override
  bool operator == (Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CompetencyCategory &&
            other.competencyCategoryId == competencyCategoryId);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'competencyCategoryId': competencyCategoryId,
      'order': order,
    };
  }

  @override
  // TODO: implement hashCode
  int get hashCode => competencyCategoryId.hashCode;

}