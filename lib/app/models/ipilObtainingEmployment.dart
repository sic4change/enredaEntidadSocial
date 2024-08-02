class IpilObtainingEmployment {
  IpilObtainingEmployment({this.ipilObtainingEmploymentId, required this.label, required this.order });

  final String? ipilObtainingEmploymentId;
  final String label;
  final int order;

  factory IpilObtainingEmployment.fromMap(Map<String, dynamic> data, String documentId) {
    return IpilObtainingEmployment(
      ipilObtainingEmploymentId: data['ipilObtainingEmploymentId'],
      label: data['label'],
      order: data['order'],

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