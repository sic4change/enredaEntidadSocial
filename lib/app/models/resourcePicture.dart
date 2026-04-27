class ResourcePicture {
  ResourcePicture({required this.id, required this.resourcePhoto, required this.name, required this.role});

  factory ResourcePicture.fromMap(Map<String, dynamic> data, String documentId) {
    String extractSrc(dynamic field) {
      if (field is String) return field;
      if (field is Map && field['src'] != null) return field['src'].toString();
      return '';
    }

    String extractTitle(dynamic field) {
      if (field is String) return '';
      if (field is Map && field['title'] != null) return field['title'].toString();
      return '';
    }

    return ResourcePicture(
      id: data['id'] ?? documentId,
      resourcePhoto: extractSrc(data['resourcePhoto']),
      name: extractTitle(data['resourcePhoto']) != '' ? extractTitle(data['resourcePhoto']) : (data['name']?.toString() ?? ''),
      role: data['role']?.toString() ?? '',
    );
  }
  final String id;
  final String resourcePhoto;
  final String name;
  final String role;

  @override
  bool operator == (Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ResourcePicture &&
            other.id == id);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'resourcePhoto': resourcePhoto,
      'name': name,
      'role': role,
    };
  }

  @override
  // TODO: implement hashCode
  int get hashCode => id.hashCode;

}