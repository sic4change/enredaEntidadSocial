class IpilLaborSkills {
  IpilLaborSkills({this.ipilLaborSkillsId, required this.label, required this.order });

  final String? ipilLaborSkillsId;
  final String label;
  final int order;

  factory IpilLaborSkills.fromMap(Map<String, dynamic> data, String documentId) {
    return IpilLaborSkills(
      ipilLaborSkillsId: data['ipilLaborSkillsId'],
      label: data['label'],
      order: data['order'],

    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IpilLaborSkills &&
            other.ipilLaborSkillsId == ipilLaborSkillsId);
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'order': order,
    };
  }
}