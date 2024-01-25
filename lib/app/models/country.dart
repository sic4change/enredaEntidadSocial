class Country {
  Country({
    required this.countryId,
    required this.name,
  });

  final String countryId, name;

  factory Country.fromMap(Map<String, dynamic> data, String documentId) {
    final countryId = data['id'].toString();
    final name = data['translations']['es'] ?? data['name'];

    return Country(
      countryId: countryId,
      name: name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': countryId as int,
      'name': name,
    };
  }

  @override
  bool operator == (Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Country &&
            other.countryId == countryId);
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;

}