import 'package:cloud_firestore/cloud_firestore.dart';

/// Snapshot of a completed social-reports lifecycle (itinerary cycle).
///
/// When a participant's itinerary is closed (ClosureReport.completedDate != null
/// && ClosureReport.finished == true) the active pointers on [UserEnreda] are
/// archived into an instance of this class, appended to
/// `UserEnreda.socialItineraryHistory`, and then cleared on the live user doc
/// so a new cycle can start without losing history.
class SocialItineraryCycle {
  SocialItineraryCycle({
    this.initialReportId,
    this.followReportId,
    this.derivationReportId,
    this.closureReportId,
    this.startDate,
    this.closureDate,
    this.programId,
    this.archivedAt,
  });

  final String? initialReportId;
  final String? followReportId;
  final String? derivationReportId;
  final String? closureReportId;
  final DateTime? startDate;
  final DateTime? closureDate;
  final String? programId;
  final DateTime? archivedAt;

  factory SocialItineraryCycle.fromMap(Map<String, dynamic> data) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return SocialItineraryCycle(
      initialReportId: data['initialReportId'] as String?,
      followReportId: data['followReportId'] as String?,
      derivationReportId: data['derivationReportId'] as String?,
      closureReportId: data['closureReportId'] as String?,
      startDate: parseDate(data['startDate']),
      closureDate: parseDate(data['closureDate']),
      programId: data['programId'] as String?,
      archivedAt: parseDate(data['archivedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'initialReportId': initialReportId,
      'followReportId': followReportId,
      'derivationReportId': derivationReportId,
      'closureReportId': closureReportId,
      'startDate': startDate,
      'closureDate': closureDate,
      'programId': programId,
      'archivedAt': archivedAt,
    };
  }
}
