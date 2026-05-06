class Education {
  Education({this.educationId, required this.label, required this.value, required this.order });

  final String? educationId;
  final String label;
  final String value;
  final int order;

  factory Education.fromMap(Map<String, dynamic> data, String documentId) {
    return Education(
        educationId: data['educationId']?.toString() ?? documentId,
        label: data['label'],
        value: data['value']?.toString() ?? '',
        order: data['order'] ?? 0
    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Education &&
            other.educationId == educationId);
  }

  @override
  int get hashCode => educationId.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'educationId': educationId,
      'label': label,
      'value': value,
      'order' : order,
    };
  }
}