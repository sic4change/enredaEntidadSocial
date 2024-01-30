class CompetencySubCategory {
  CompetencySubCategory({this.competencySubCategoryId, this.competencyCategoryId, required this.name, this.order});

  factory CompetencySubCategory.fromMap(Map<String, dynamic> data, String documentId) {
    final String name = data['name'];
    final String? competencyCategoryId = data['competencyCategoryId'];
    final String? competencySubCategoryId = data['competencySubCategoryId'];
    final int? order = data['order'];

    return CompetencySubCategory(
      order: order,
      name: name,
      competencyCategoryId: competencyCategoryId,
      competencySubCategoryId: competencySubCategoryId,
    );
  }

  final String name;
  final String? competencyCategoryId;
  final String? competencySubCategoryId;
  final int? order;

  @override
  bool operator == (Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CompetencySubCategory &&
            other.competencySubCategoryId == competencySubCategoryId);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'competencyCategoryId': competencyCategoryId,
      'competencySubCategoryId': competencySubCategoryId,
      'order': order,
    };
  }

  @override
  // TODO: implement hashCode
  int get hashCode => competencySubCategoryId.hashCode;

}