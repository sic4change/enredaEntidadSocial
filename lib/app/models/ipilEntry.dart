class IpilEntry {
  IpilEntry({
    this.ipilId,
    this.content,
    this.techId,
    required this.userId,
    required this.date,
  });

  final String? ipilId;
  final String? content;
  final String? techId;
  final String userId;
  final DateTime date;

  factory IpilEntry.fromMap(Map<String, dynamic> data, String documentId) {
    return IpilEntry(
      ipilId: data['ipilId'],
      content: data['content'],
      techId: data['techId'],
      userId: data['userId'],
      date: data['date'].toDate(),
    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IpilEntry &&
            other.ipilId == ipilId);
  }

  Map<String, dynamic> toMap() {
    return {
      'ipilId': ipilId,
      'content': content,
      'techId': techId,
      'userId': userId,
      'date': date,
    };
  }
}