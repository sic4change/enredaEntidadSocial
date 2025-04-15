class IpilLegal {
  IpilLegal({this.ipilLegalId, required this.label, required this.order });

  final String? ipilLegalId;
  final String label;
  final int order;

  factory IpilLegal.fromMap(Map<String, dynamic> data, String documentId) {
    return IpilLegal(
      ipilLegalId: data['ipilLegalId'],
      label: data['label'],
      order: data['order'],

    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IpilLegal &&
            other.ipilLegalId == ipilLegalId);
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'order': order,
    };
  }
}