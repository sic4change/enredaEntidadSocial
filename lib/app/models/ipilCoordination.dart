class IpilCoordination {
  IpilCoordination({this.ipilCoordinationId, required this.label, required this.order });

  final String? ipilCoordinationId;
  final String label;
  final int order;

  factory IpilCoordination.fromMap(Map<String, dynamic> data, String documentId) {
    return IpilCoordination(
      ipilCoordinationId: data['ipilCoordinationId'],
      label: data['label'],
      order: data['order'],

    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IpilCoordination &&
            other.ipilCoordinationId == ipilCoordinationId);
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'order': order,
    };
  }
}