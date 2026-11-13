import 'package:cloud_firestore/cloud_firestore.dart';

/// Observaciones internas de los técnicos sobre un participante.
///
/// Se guardan en la colección `technicianObservations` (un documento por
/// participante, con su userId como id), separadas de los datos del
/// participante (`users`, `companionData`) para que solo las vean los
/// técnicos desde esta aplicación.
///
/// Estructura del documento:
/// ```json
/// {
///   "userId": "<participante>",
///   "socialEntityId": "<entidad>",
///   "message": "<última observación>",
///   "updatedAt": <Timestamp>,
///   "updatedBy": "<id del técnico>",
///   "entries": [
///     { "message": "...", "createdAt": <Timestamp>, "technicianId": "..." }
///   ]
/// }
/// ```
class TechnicianObservations {
  TechnicianObservations({
    required this.userId,
    this.socialEntityId,
    this.message,
    this.updatedAt,
    this.updatedBy,
    this.entries = const [],
  });

  final String userId;
  final String? socialEntityId;

  /// Última observación (la que se muestra en el listado).
  final String? message;
  final DateTime? updatedAt;
  final String? updatedBy;

  /// Historial de observaciones, de la más antigua a la más reciente.
  final List<TechnicianObservationEntry> entries;

  factory TechnicianObservations.fromMap(
      Map<String, dynamic> data, String documentId) {
    final rawEntries = data['entries'];
    final entries = <TechnicianObservationEntry>[
      if (rawEntries is List)
        for (final e in rawEntries)
          if (e is Map) TechnicianObservationEntry.fromMap(Map.from(e)),
    ]..sort((a, b) => (a.createdAt ?? DateTime(0))
        .compareTo(b.createdAt ?? DateTime(0)));
    return TechnicianObservations(
      userId: data['userId']?.toString() ?? documentId,
      socialEntityId: data['socialEntityId']?.toString(),
      message: data['message']?.toString(),
      updatedAt: _toDate(data['updatedAt']),
      updatedBy: data['updatedBy']?.toString(),
      entries: entries,
    );
  }
}

/// Una observación: mensaje, fecha de creación y técnico que la escribió.
class TechnicianObservationEntry {
  TechnicianObservationEntry({
    required this.message,
    required this.technicianId,
    this.createdAt,
  });

  final String message;
  final String technicianId;
  final DateTime? createdAt;

  factory TechnicianObservationEntry.fromMap(Map<String, dynamic> data) =>
      TechnicianObservationEntry(
        message: data['message']?.toString() ?? '',
        technicianId: data['technicianId']?.toString() ?? '',
        createdAt: _toDate(data['createdAt']),
      );

  Map<String, dynamic> toMap() => {
        'message': message,
        'technicianId': technicianId,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : Timestamp.now(),
      };
}

DateTime? _toDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
