class IpilSpecificSkills {
  IpilSpecificSkills({this.ipilSpecificSkillsId, required this.label, required this.order });

  final String? ipilSpecificSkillsId;
  final String label;
  final int order;

  factory IpilSpecificSkills.fromMap(Map<String, dynamic> data, String documentId) {
    return IpilSpecificSkills(
      ipilSpecificSkillsId: data['ipilSpecificSkillsId'],
      label: data['label'],
      order: data['order'],

    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IpilSpecificSkills &&
            other.ipilSpecificSkillsId == ipilSpecificSkillsId);
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'order': order,
    };
  }
}