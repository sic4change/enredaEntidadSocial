class IpilContextualization {
  IpilContextualization({this.ipilContextualizationId, required this.label, required this.order });

  final String? ipilContextualizationId;
  final String label;
  final int order;

  factory IpilContextualization.fromMap(Map<String, dynamic> data, String documentId) {
    return IpilContextualization(
      ipilContextualizationId: data['ipilContextualizationId'],
      label: data['label'],
      order: data['order'],

    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IpilContextualization &&
            other.ipilContextualizationId == ipilContextualizationId);
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'order': order,
    };
  }
}