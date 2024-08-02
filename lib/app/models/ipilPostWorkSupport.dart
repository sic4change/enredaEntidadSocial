class IpilPostWorkSupport {
  IpilPostWorkSupport({this.ipilPostWorkSupportId, required this.label, required this.order });

  final String? ipilPostWorkSupportId;
  final String label;
  final int order;

  factory IpilPostWorkSupport.fromMap(Map<String, dynamic> data, String documentId) {
    return IpilPostWorkSupport(
      ipilPostWorkSupportId: data['ipilPostWorkSupportId'],
      label: data['label'],
      order: data['order'],

    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IpilPostWorkSupport &&
            other.ipilPostWorkSupportId == ipilPostWorkSupportId);
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'order': order,
    };
  }
}