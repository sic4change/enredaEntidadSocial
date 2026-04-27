class IpilPostWorkSupport {
  IpilPostWorkSupport({this.ipilPostWorkSupportId, required this.label, required this.order });

  final String? ipilPostWorkSupportId;
  final String label;
  final int order;

  factory IpilPostWorkSupport.fromMap(Map<String, dynamic> data, String documentId) {
    return IpilPostWorkSupport(
      ipilPostWorkSupportId: data['ipilPostWorkSupportId']?.toString(),
      label: data['label']?.toString() ?? '',
      order: data['order'] is int ? data['order'] : int.tryParse(data['order']?.toString() ?? '0') ?? 0,

    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IpilPostWorkSupport &&
            other.ipilPostWorkSupportId == ipilPostWorkSupportId);
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'order': order,
    };
  }
}