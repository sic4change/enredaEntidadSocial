class ScopeAction {
  ScopeAction({this.id, required this.name});

  final String? id;
  final String name;

  factory ScopeAction.fromMap(Map<String, dynamic> data, String documentId) {
    return ScopeAction(
      id: data['id'] ?? documentId,
      name: data['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScopeAction &&
            other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}
