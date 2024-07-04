class IpilInterviews {
  IpilInterviews({this.ipilInterviewsId, required this.label, required this.order });

  final String? ipilInterviewsId;
  final String label;
  final int order;

  factory IpilInterviews.fromMap(Map<String, dynamic> data, String documentId) {
    return IpilInterviews(
      ipilInterviewsId: data['ipilInterviewsId'],
      label: data['label'],
      order: data['order'],

    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IpilInterviews &&
            other.ipilInterviewsId == ipilInterviewsId);
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'order': order,
    };
  }
}