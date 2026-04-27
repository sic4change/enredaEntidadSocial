class IpilIntermediations {
  IpilIntermediations({this.ipilIntermediationsId, required this.label, required this.order });

  final String? ipilIntermediationsId;
  final String label;
  final int order;

  factory IpilIntermediations.fromMap(Map<String, dynamic> data, String documentId) {
    return IpilIntermediations(
      ipilIntermediationsId: data['ipilIntermediationsId']?.toString(),
      label: data['label']?.toString() ?? '',
      order: data['order'] is int ? data['order'] : int.tryParse(data['order']?.toString() ?? '0') ?? 0,

    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IpilIntermediations &&
            other.ipilIntermediationsId == ipilIntermediationsId);
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'order': order,
    };
  }
}