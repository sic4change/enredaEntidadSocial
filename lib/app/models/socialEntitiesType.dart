class SocialEntitiesType {
  SocialEntitiesType({required this.id, required this.name, this.description});
  final String id;
  final String name;
  final String? description;

  factory SocialEntitiesType.fromMap(Map<String, dynamic> data, String documentId) {
    return SocialEntitiesType(
      id: data['id'],
      name: data['name'],
      description: data['description'],
    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SocialEntitiesType &&
            other.id == id);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;

}