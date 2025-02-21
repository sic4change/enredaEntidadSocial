class LanguageReport {
  LanguageReport({
    required this.name,
    required this.level,
    required this.accreditation,
  });

  String name;
  String level;
  String accreditation;

  factory LanguageReport.fromMap(Map<String, dynamic> data, String documentId) {
    return LanguageReport(
      name: data['name'] ?? '',
      level: data['level'] ?? '',
      accreditation: data['accreditation'] ?? '',
    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LanguageReport &&
            other.name == name);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'level': level,
      'accreditation': accreditation,
    };
  }
}