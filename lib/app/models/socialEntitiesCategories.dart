class SocialEntityCategory {
  SocialEntityCategory({required this.name, required this.socialEntityCategoryId, required this.order});

  factory SocialEntityCategory.fromMap(Map<String, dynamic>? data, String documentId) {
    final String name = data?['name'];
    final int order = data?['order'];
    final String socialEntityCategoryId = documentId;

    return SocialEntityCategory(
      name: name,
      order: order,
      socialEntityCategoryId: socialEntityCategoryId,
    );
  }

  final String name;
  final String socialEntityCategoryId;
  final int order;

  @override
  bool operator == (Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SocialEntityCategory &&
            other.socialEntityCategoryId == socialEntityCategoryId);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'socialEntityCategoryId' : socialEntityCategoryId,
      'order' : order,
    };
  }

  @override
  // TODO: implement hashCode
  int get hashCode => socialEntityCategoryId.hashCode;

}