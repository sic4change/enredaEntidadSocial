class IpilConnectionTerritory {
  IpilConnectionTerritory({this.ipilConnectionTerritoryId, required this.label, required this.order });

  final String? ipilConnectionTerritoryId;
  final String label;
  final int order;

  factory IpilConnectionTerritory.fromMap(Map<String, dynamic> data, String documentId) {
    return IpilConnectionTerritory(
      ipilConnectionTerritoryId: data['ipilConnectionTerritoryId'],
      label: data['label'],
      order: data['order'],

    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IpilConnectionTerritory &&
            other.ipilConnectionTerritoryId == ipilConnectionTerritoryId);
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'order': order,
    };
  }
}