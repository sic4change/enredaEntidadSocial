class FormationReport {
  FormationReport({
    required this.name,
    required this.type,
    required this.certification,
  });

  String name;
  String type;
  String certification;

  factory FormationReport.fromMap(Map<String, dynamic> data, String documentId) {
    return FormationReport(
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      certification: data['certification'] ?? '',
    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FormationReport &&
            other.name == name);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'certification': certification,
    };
  }
}