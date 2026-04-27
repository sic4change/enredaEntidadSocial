class IpilConnectionTerritory {
  IpilConnectionTerritory({this.ipilConnectionTerritoryId, required this.label, required this.order });

  final String? ipilConnectionTerritoryId;
  final String label;
  final int order;

  factory IpilConnectionTerritory.fromMap(Map<String, dynamic> data, String documentId) {
    return IpilConnectionTerritory(
      ipilConnectionTerritoryId: data['ipilConnectionTerritoryId']?.toString(),
      label: data['label']?.toString() ?? '',
      order: data['order'] is int ? data['order'] : int.tryParse(data['order']?.toString() ?? '0') ?? 0,

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