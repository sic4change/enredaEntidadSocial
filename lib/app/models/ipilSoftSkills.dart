class IpilSoftSkills {
  IpilSoftSkills({this.ipilSoftSkillsId, required this.label, required this.order });

  final String? ipilSoftSkillsId;
  final String label;
  final int order;

  factory IpilSoftSkills.fromMap(Map<String, dynamic> data, String documentId) {
    return IpilSoftSkills(
      ipilSoftSkillsId: data['ipilSoftSkillsId'],
      label: data['label'],
      order: data['order'],

    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IpilSoftSkills &&
            other.ipilSoftSkillsId == ipilSoftSkillsId);
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'order': order,
    };
  }
}