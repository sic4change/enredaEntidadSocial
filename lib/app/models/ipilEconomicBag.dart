class IpilEconomicBag {
  IpilEconomicBag({this.ipilEconomicBagId, required this.label, required this.order });

  final String? ipilEconomicBagId;
  final String label;
  final int order;

  factory IpilEconomicBag.fromMap(Map<String, dynamic> data, String documentId) {
    return IpilEconomicBag(
      ipilEconomicBagId: data['ipilEconomicBagId'],
      label: data['label'],
      order: data['order'],

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