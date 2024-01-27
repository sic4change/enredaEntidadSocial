// class Country {
//   Country({
//     required this.countryId,
//     required this.name,
//   });
//
//   final String countryId, name;
//
//   factory Country.fromMap(Map<String, dynamic> data, String documentId) {
//     final countryId = data['id'].toString();
//     final name = data['translations']['es'] ?? data['name'];
//
//     return Country(
//       countryId: countryId,
//       name: name,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'id': countryId as int,
//       'name': name,
//     };
//   }
//
//   @override
//   bool operator == (Object other){
//     return identical(this, other) ||
//         (other.runtimeType == runtimeType &&
//             other is Country &&
//             other.countryId == countryId);
//   }
//
//   @override
//   // TODO: implement hashCode
//   int get hashCode => super.hashCode;
//
// }

class Country {
  Country({this.countryId, required this.name,});

  factory Country.fromMap(Map<String, dynamic> data, String documentId) {
    final String name = data['name'];
    final String? countryId = data['countryId'];

    return Country(
        countryId: countryId,
        name: name
    );
  }

  final String? countryId;
  final String name;

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Country &&
            other.countryId == countryId);
  }


  Map<String, dynamic> toMap() {
    return {
      'countryId': countryId,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'Id: $countryId, Name: $name';
  }

  @override
  // TODO: implement hashCode
  int get hashCode => countryId.hashCode;

}