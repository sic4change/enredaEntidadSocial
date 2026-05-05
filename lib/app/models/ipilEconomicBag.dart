class IpilEconomicBag {
  IpilEconomicBag({this.ipilEconomicBagId, required this.label, required this.order });

  final String? ipilEconomicBagId;
  final String label;
  final int order;

  factory IpilEconomicBag.fromMap(Map<String, dynamic> data, String documentId) {
    return IpilEconomicBag(
      ipilEconomicBagId: data['ipilEconomicBagId']?.toString() ?? documentId,
      label: data['label']?.toString() ?? '',
      order: data['order'] is int ? data['order'] : int.tryParse(data['order']?.toString() ?? '0') ?? 0,

    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IpilEconomicBag &&
            other.ipilEconomicBagId == ipilEconomicBagId);
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'order': order,
    };
  }
}