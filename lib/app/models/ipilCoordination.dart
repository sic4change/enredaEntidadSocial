class IpilCoordination {
  IpilCoordination({this.ipilCoordinationId, required this.label, required this.order });

  final String? ipilCoordinationId;
  final String label;
  final int order;

  factory IpilCoordination.fromMap(Map<String, dynamic> data, String documentId) {
    return IpilCoordination(
      ipilCoordinationId: data['ipilCoordinationId']?.toString() ?? documentId,
      label: data['label']?.toString() ?? '',
      order: data['order'] is int ? data['order'] : int.tryParse(data['order']?.toString() ?? '0') ?? 0,

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