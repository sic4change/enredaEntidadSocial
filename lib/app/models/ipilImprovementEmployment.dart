class IpilImprovingEmployment {
  IpilImprovingEmployment({this.ipilImprovingEmploymentId, required this.label, required this.order });

  final String? ipilImprovingEmploymentId;
  final String label;
  final int order;

  factory IpilImprovingEmployment.fromMap(Map<String, dynamic> data, String documentId) {
    return IpilImprovingEmployment(
      ipilImprovingEmploymentId: data['ipilImprovingEmploymentId']?.toString(),
      label: data['label']?.toString() ?? '',
      order: data['order'] is int ? data['order'] : int.tryParse(data['order']?.toString() ?? '0') ?? 0,

    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IpilImprovingEmployment &&
            other.ipilImprovingEmploymentId == ipilImprovingEmploymentId);
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'order': order,
    };
  }
}