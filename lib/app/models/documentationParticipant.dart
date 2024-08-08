// class PersonalDocument {
//   PersonalDocument({
//     required this.personalDocumentId,
//     required this.userId,
//     required this.name,
//     required this.createDate,
//     required this.documentCategoryId,
//     required this.documentSubCategoryId,
//     this.renovationDate,
//   });
//
//   final String personalDocumentId;
//   final String userId;
//   final String name;
//   final DateTime createDate;
//   final DateTime? renovationDate;
//   final String documentCategoryId;
//   final String documentSubCategoryId;
//
//   factory PersonalDocument.fromMap(Map<String, dynamic> data, String documentId) {
//     return PersonalDocument(
//       name: data['name'] ?? "",
//       userId: data['userId'] ?? "",
//       personalDocumentId: documentId,
//       documentCategoryId: data['documentCategoryId'] ?? '',
//       documentSubCategoryId: data['documentSubCategoryId'] ?? '',
//       createDate: data['createDate'] != null ? DateTime.parse(data['createDate']) : DateTime.now(),
//       renovationDate: data['renovationDate'] != null ? DateTime.parse(data['renovationDate']) : null,
//     );
//   }
//
//   @override
//   bool operator ==(Object other){
//     return identical(this, other) ||
//         (other.runtimeType == runtimeType &&
//             other is PersonalDocument &&
//             other.personalDocumentId == personalDocumentId);
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'userId': userId,
//       'personalDocumentId': personalDocumentId,
//       'createDate': createDate.toIso8601String(),
//       'renovationDate': renovationDate?.toIso8601String(),
//       'documentCategoryId': documentCategoryId,
//       'documentSubCategoryId': documentSubCategoryId
//     };
//   }
// }


class DocumentationParticipant {
  DocumentationParticipant({
    this.documentationParticipantId,
    required this.name,
    required this.userId,
    required this.createDate,
    required this.documentCategoryId,
    required this.documentSubCategoryId,
    this.renovationDate,
  });

  final String? documentationParticipantId;
  final String name;
  final String userId;
  final DateTime createDate;
  final DateTime? renovationDate;
  final String documentCategoryId;
  final String documentSubCategoryId;

  factory DocumentationParticipant.fromMap(Map<String, dynamic> data, String documentId) {

    return DocumentationParticipant(
      documentationParticipantId: data['documentationParticipantId'],
      name: data['name'],
      userId: data['userId'],
      createDate: DateTime.parse(data['createDate'].toDate().toString()),
      documentCategoryId: data['documentCategoryId'],
      documentSubCategoryId: data['documentSubCategoryId'],
      renovationDate: data['renovationDate'] != null ? DateTime.parse(data['renovationDate'].toDate().toString()) : null,
    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DocumentationParticipant &&
            other.documentationParticipantId == documentationParticipantId);
  }

  Map<String, dynamic> toMap() {
    return {
      'documentationParticipantId': documentationParticipantId,
      'name': name,
      'userId': userId,
      'createDate': createDate,
      'renovationDate': renovationDate,
      'documentCategoryId': documentCategoryId,
      'documentSubCategoryId': documentSubCategoryId
    };
  }
}