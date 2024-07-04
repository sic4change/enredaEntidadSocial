class IpilResults {
  IpilResults({this.ipilResultsId, required this.label, required this.order });

  final String? ipilResultsId;
  final String label;
  final int order;

  factory IpilResults.fromMap(Map<String, dynamic> data, String documentId) {
    return IpilResults(
      ipilResultsId: data['ipilResultsId'],
      label: data['label'],
      order: data['order'],

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