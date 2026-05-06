class Dedication {
  Dedication({this.dedicationId, required this.label, required this.value });

  final String? dedicationId;
  final String label;
  final int value;

  factory Dedication.fromMap(Map<String, dynamic> data, String documentId) {
    return Dedication(
      dedicationId: data['dedicationId']?.toString() ?? documentId,
      label: data['label'],
      value: data['value'],
    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Dedication &&
            other.dedicationId == dedicationId);
  }

  @override
  int get hashCode => dedicationId.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'dedicationId': dedicationId,
      'label': label,
      'value': value,
    };
  }
}