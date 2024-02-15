class ClosureReport {
  ClosureReport({
    this.closureReportId,
    this.userId,
    this.finished,

    this.background,
    this.initialDiagnosis,
    this.closureReasons,
    this.itineraryFollowed,

  });

  //Basic
  final String? closureReportId;
  final String? userId;
  final bool? finished;

  final String? background;
  final String? initialDiagnosis;
  final String? closureReasons;
  final String? itineraryFollowed;

  factory ClosureReport.fromMap(Map<String, dynamic> data, String documentId) {
    return ClosureReport(

      //Basic
      closureReportId: data['closureReportId'],
      userId: data['userId'],
      finished: data['finished'],

      background: data['background'],
      initialDiagnosis: data['initialDiagnosis'],
      closureReasons: data['closureReasons'],
      itineraryFollowed: data['itineraryFollowed'],
    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ClosureReport &&
            other.closureReportId == closureReportId);
  }

  Map<String, dynamic> toMap() {
    return {

      'closureReportId': closureReportId,
      'userId': userId,
      'finished': finished,

      'background': background,
      'initialDiagnosis': initialDiagnosis,
      'closureReasons': closureReasons,
      'itineraryFollowed': itineraryFollowed,

    };
  }
}