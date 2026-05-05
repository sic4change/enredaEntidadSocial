class IpilResults {
  IpilResults({this.ipilResultsId, required this.label, required this.order });

  final String? ipilResultsId;
  final String label;
  final int order;

  factory IpilResults.fromMap(Map<String, dynamic> data, String documentId) {
    return IpilResults(
      ipilResultsId: data['ipilResultsId']?.toString() ?? documentId,
      label: data['label']?.toString() ?? '',
      order: data['order'] is int ? data['order'] : int.tryParse(data['order']?.toString() ?? '0') ?? 0,

    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IpilResults &&
            other.ipilResultsId == ipilResultsId);
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'order': order,
    };
  }
}