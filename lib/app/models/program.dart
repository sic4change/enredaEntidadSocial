class Program {
  Program({
    this.programId,
    this.code,
    required this.name,
    this.shortName,
  });

  final String? programId;
  final String? code;
  final String name;
  final String? shortName;

  factory Program.fromMap(Map<String, dynamic> data, String documentId) {
    return Program(
      programId: documentId,
      code: data['code'] as String?,
      name: data['name'] as String? ?? '',
      shortName: data['shortName'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'shortName': shortName,
    };
  }
}
