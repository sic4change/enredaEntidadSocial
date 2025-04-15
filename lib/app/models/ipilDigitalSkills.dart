class IpilDigitalSkills {
  IpilDigitalSkills({this.ipilDigitalSkillsId, required this.label, required this.order });

  final String? ipilDigitalSkillsId;
  final String label;
  final int order;

  factory IpilDigitalSkills.fromMap(Map<String, dynamic> data, String documentId) {
    return IpilDigitalSkills(
      ipilDigitalSkillsId: data['ipilDigitalSkillsId'],
      label: data['label'],
      order: data['order'],

    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IpilDigitalSkills &&
            other.ipilDigitalSkillsId == ipilDigitalSkillsId);
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'order': order,
    };
  }
}