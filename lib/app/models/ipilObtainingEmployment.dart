class IpilObtainingEmployment {
  IpilObtainingEmployment({this.ipilObtainingEmploymentId, required this.label, required this.order });

  final String? ipilObtainingEmploymentId;
  final String label;
  final int order;

  factory IpilObtainingEmployment.fromMap(Map<String, dynamic> data, String documentId) {
    return IpilObtainingEmployment(
      ipilObtainingEmploymentId: data['ipilObtainingEmploymentId']?.toString(),
      label: data['label']?.toString() ?? '',
      order: data['order'] is int ? data['order'] : int.tryParse(data['order']?.toString() ?? '0') ?? 0,

    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IpilObtainingEmployment &&
            other.ipilObtainingEmploymentId == ipilObtainingEmploymentId);
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'order': order,
    };
  }
}