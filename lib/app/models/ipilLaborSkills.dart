class IpilLaborSkills {
  IpilLaborSkills({this.ipilLaborSkillsId, required this.label, required this.order });

  final String? ipilLaborSkillsId;
  final String label;
  final int order;

  factory IpilLaborSkills.fromMap(Map<String, dynamic> data, String documentId) {
    return IpilLaborSkills(
      ipilLaborSkillsId: data['ipilLaborSkillsId']?.toString() ?? documentId,
      label: data['label']?.toString() ?? '',
      order: data['order'] is int ? data['order'] : int.tryParse(data['order']?.toString() ?? '0') ?? 0,

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