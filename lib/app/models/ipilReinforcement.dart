class IpilReinforcement {
  IpilReinforcement({this.ipilReinforcementId, required this.label, required this.order });

  final String? ipilReinforcementId;
  final String label;
  final int order;

  factory IpilReinforcement.fromMap(Map<String, dynamic> data, String documentId) {
    return IpilReinforcement(
      ipilReinforcementId: data['ipilReinforcementId'],
      label: data['label'],
      order: data['order'],

    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IpilReinforcement &&
            other.ipilReinforcementId == ipilReinforcementId);
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'order': order,
    };
  }
}