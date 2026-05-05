class IpilDigitalSkills {
  IpilDigitalSkills({this.ipilDigitalSkillsId, required this.label, required this.order });

  final String? ipilDigitalSkillsId;
  final String label;
  final int order;

  factory IpilDigitalSkills.fromMap(Map<String, dynamic> data, String documentId) {
    return IpilDigitalSkills(
      ipilDigitalSkillsId: data['ipilDigitalSkillsId']?.toString() ?? documentId,
      label: data['label']?.toString() ?? '',
      order: data['order'] is int ? data['order'] : int.tryParse(data['order']?.toString() ?? '0') ?? 0,

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