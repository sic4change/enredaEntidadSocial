class Region {
  Region({
    required this.regionId,
    required this.countryId,
    required this.name,
  });

  final String regionId, countryId, name;

  factory Region.fromMap(Map<String, dynamic> data, String documentId) {
    final regionId = data['id'].toString();
    final countryId = data['country_id'].toString();
    final name = data['name']?? "";

    return Region(
      regionId: regionId,
      countryId: countryId,
      name: name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': regionId as int,
      'country_id': countryId as int,
      'name': name,
    };
  }

  @override
  bool operator == (Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Region &&
            other.regionId == regionId);
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;

}