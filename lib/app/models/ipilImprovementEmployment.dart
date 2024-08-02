class IpilImprovingEmployment {
  IpilImprovingEmployment({this.ipilImprovingEmploymentId, required this.label, required this.order });

  final String? ipilImprovingEmploymentId;
  final String label;
  final int order;

  factory IpilImprovingEmployment.fromMap(Map<String, dynamic> data, String documentId) {
    return IpilImprovingEmployment(
      ipilImprovingEmploymentId: data['ipilImprovingEmploymentId'],
      label: data['label'],
      order: data['order'],

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