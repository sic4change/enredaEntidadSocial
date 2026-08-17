import 'package:enreda_empresas/app/services/location_cache.dart';

class DocumentationParticipant {
  DocumentationParticipant({
    this.documentationParticipantId,
    required this.name,
    required this.userId,
    required this.createDate,
    required this.documentCategoryId,
    required this.documentSubCategoryId,
    this.renovationDate,
    this.urlDocument,
    this.nameDocument,
    this.createdBy,
    this.documentSubCategoryName,
    this.techCreated = false,
  });

  final String? documentationParticipantId;
  final String name;
  final String userId;
  final DateTime createDate;
  final DateTime? renovationDate;
  final String documentCategoryId;
  final String documentSubCategoryId;
  final String? urlDocument;
  final String? nameDocument;
  final String? createdBy;
  final String? documentSubCategoryName;
  final bool techCreated;

  factory DocumentationParticipant.fromMap(Map<String, dynamic> data, String documentId) {

    String? urlDocument;
    try {
      urlDocument = data['file']['src'];
    } catch (e) {
      urlDocument = '';
    }

    String? nameDocument;
    try {
      nameDocument = data['file']['title'];
    } catch (e) {
      nameDocument = '';
    }

    final subCategoryId = data['documentSubCategoryId'];
    String? typeName = data['documentSubCategoryName'];
    
    // Fallback to LocationCache if the name is not stored yet
    if (typeName == null || typeName.isEmpty) {
      typeName = LocationCache.instance.personalDocumentTypeById(subCategoryId)?.title;
    }

    return DocumentationParticipant(
      documentationParticipantId: data['documentationParticipantId'],
      name: data['name'],
      userId: data['userId'],
      createdBy: data['createdBy'],
      createDate: DateTime.parse(data['createDate'].toDate().toString()),
      documentCategoryId: data['documentCategoryId'],
      documentSubCategoryId: subCategoryId,
      documentSubCategoryName: typeName,
      renovationDate: data['renovationDate'] != null ? DateTime.parse(data['renovationDate'].toDate().toString()) : null,
      urlDocument: urlDocument,
      nameDocument: nameDocument,
      techCreated: data['techCreated'] ?? false,
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
      'createdBy': createdBy,
      'createDate': createDate,
      'renovationDate': renovationDate,
      'documentCategoryId': documentCategoryId,
      'documentSubCategoryId': documentSubCategoryId,
      'documentSubCategoryName': documentSubCategoryName,
      'techCreated': techCreated,
    };
  }

  DocumentationParticipant copyWith({
    String? documentationParticipantId,
    String? name,
    String? userId,
    String? createdBy,
    DateTime? createDate,
    DateTime? renovationDate,
    String? documentCategoryId,
    String? documentSubCategoryId,
    String? documentSubCategoryName,
    bool? techCreated,
  }) {
    return DocumentationParticipant(
        documentationParticipantId: documentationParticipantId?? this.documentationParticipantId,
        name: name?? this.name,
        userId: userId?? this.userId,
        createdBy: createdBy?? this.createdBy,
        createDate: createDate?? this.createDate,
        documentCategoryId: documentCategoryId?? this.documentCategoryId,
        documentSubCategoryId: documentSubCategoryId?? this.documentSubCategoryId,
        documentSubCategoryName: documentSubCategoryName?? this.documentSubCategoryName,
        renovationDate: renovationDate?? this.renovationDate,
        techCreated: techCreated?? this.techCreated,
    );
  }

}