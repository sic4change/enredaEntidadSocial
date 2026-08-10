/// Domain model for a Sesión (admin dashboard "Sesiones" feature).
///
/// A `Sesion` is a scheduled meeting between a técnico (social entity worker)
/// and one or more participants. The list view is split into:
///   * Próximas: `scheduledAt >= now`
///   * Pasadas:  `scheduledAt <  now`
///
/// Schema decisions (locked by product):
///   * `invitedParticipants` and `attendedParticipants` are **always** arrays
///     of user IDs, even for individual sessions (count = 1). This is to
///     avoid type-mixing errors in Firestore.
///   * `tecnicoId` is the user ID of the convener (the social entity worker
///     who created the session).
///   * `socialEntityId` is denormalized for cheap server-side filtering.
class Sesion {
  Sesion({
    this.sesionId,
    required this.tecnicoId,
    this.socialEntityId,
    required this.sessionType,
    required this.modality,
    required this.scheduledAt,
    this.fechaFin,
    this.isAllDay = false,
    required this.invitedParticipants,
    required this.attendedParticipants,
    this.title,
    this.description,
    this.observations,
    this.lugar,
    this.duracion,
    this.createIpil = false,
    List<String> competenciaCategorias = const <String>[],
    List<String> competenciaSubCategorias = const <String>[],
    List<String> competencias = const <String>[],
    String? competenciaCategoriaId,
    String? competenciaSubCategoriaId,
    this.createdAt,
    this.lastUpdated,
    this.absentParticipants = const <String>[],
    this.ipilContent,
    this.ipilReinforcement = const <String>[],
    this.ipilContextualization = const <String>[],
    this.ipilConnectionTerritory = const <String>[],
    this.ipilInterviews = const <String>[],
    this.ipilIntermediations = const <String>[],
    this.ipilObtainingEmployment = const <String>[],
    this.ipilImprovingEmployment = const <String>[],
    this.ipilCoordination = const <String>[],
    this.ipilLegal = const <String>[],
    this.ipilPostWorkSupport = const <String>[],
    this.ipilEconomicBag = const <String>[],
    this.ipilSpecificSkills = const <String>[],
    this.ipilSoftSkills = const <String>[],
    this.ipilDigitalSkills = const <String>[],
    this.ipilLaborSkills = const <String>[],
    this.ipilInitialInterview = false,
    this.ipilInitialJobValoration = false,
    this.ipilFinalInterview = false,
    this.ipilFinalJobValoration = false,
    this.ipilOther,
    this.participantSubvenciones = const <String, String>{},
    this.reminderUserIds = const <String>[],
    this.confirmedParticipants = const <String>[],
  }) : this.competenciaCategorias = competenciaCategorias.isNotEmpty
            ? competenciaCategorias
            : (competenciaCategoriaId != null && competenciaCategoriaId.isNotEmpty ? [competenciaCategoriaId] : const <String>[]),
       this.competenciaSubCategorias = competenciaSubCategorias.isNotEmpty
            ? competenciaSubCategorias
            : (competenciaSubCategoriaId != null && competenciaSubCategoriaId.isNotEmpty ? [competenciaSubCategoriaId] : const <String>[]),
       this.competencias = competencias;

  /// Firestore document id.
  final String? sesionId;

  /// User id of the técnico (social entity worker) who convened the session.
  final String tecnicoId;

  /// Owning social entity id. Used as the primary server-side filter on
  /// every list query.
  final String? socialEntityId;

  /// `individual` | `grupal`. Drives the displayed row title
  /// ("Sesión individual" / "Sesión grupal").
  final String sessionType;

  /// `online` | `presencial` | `blended`. Drives the status chip label.
  final String modality;

  /// When the session is/was scheduled to take place. The time component is
  /// honoured when [isAllDay] is false; when [isAllDay] is true the time
  /// component is ignored by the UI (sessions sort to the top of the day).
  ///
  /// Used to bucket into Próximas vs Pasadas.
  final DateTime scheduledAt;

  /// True when the session occupies the entire day rather than a specific
  /// hour. UI displays "Todo el día" instead of a time prefix. Maps cleanly
  /// to Google Calendar's `event.start.date` (vs `dateTime`) when a future
  /// gCal integration is wired in.
  ///
  /// Defaults to `false` for newly created sessions; for legacy Firestore
  /// documents without this field, [fromMap] also defaults to `false` so
  /// existing records (whose `scheduledAt` time component is 00:00) read
  /// out as midnight scheduled sessions — flag them as all-day from the
  /// edit flow if that's the intended meaning.
  final bool isAllDay;

  /// Optional explicit end timestamp. When set, the gCal / ICS exports use
  /// this directly for the event's DTEND instead of deriving it from the
  /// free-text `duracion` field. Nullable so legacy Firestore documents
  /// (which only ever wrote `scheduledAt`) keep working — the exports fall
  /// back to the duration heuristic in that case.
  final DateTime? fechaFin;

  /// IDs of invited participants. Always an array — even for individual
  /// sessions (length 1). Type-mixing guard.
  final List<String> invitedParticipants;

  /// IDs of participants who actually attended. Always an array.
  final List<String> attendedParticipants;

  /// Optional user-supplied title override. Falls back to the default
  /// per-`sessionType` label in the UI when null/empty.
  final String? title;

  /// Long-form "Desarrollo y evaluación" body.
  final String? description;

  /// Long-form "Observaciones y/o incidencias" body.
  final String? observations;

  /// "Lugar de la actividad" — free-text venue / address.
  final String? lugar;

  /// "Duración" — free-text duration label (e.g. "2 horas", "90 min").
  final String? duracion;

  /// `createIpil` — true when the convener flagged this session to also
  /// generate an IPIL (Itinerario Personal de Inclusión Laboral) record.
  /// Drives the multi-step create flow's branch.
  final bool createIpil;

  final List<String> competenciaCategorias;
  final List<String> competenciaSubCategorias;
  final List<String> competencias;

  /// `Categoría de Competencias` selection (FK into `competenciesCategories`).
  String? get competenciaCategoriaId =>
      competenciaCategorias.isNotEmpty ? competenciaCategorias.first : null;

  /// `Sub categoría de Competencias` selection (FK into `competenciesSubCategories`).
  String? get competenciaSubCategoriaId =>
      competenciaSubCategorias.isNotEmpty ? competenciaSubCategorias.first : null;

  /// Created timestamp. Set on initial write.
  final DateTime? createdAt;

  /// Last-update timestamp. Set on every write.
  final DateTime? lastUpdated;

  /// Participants explicitly confirmed as absent. Always an array.
  /// Paired with [attendedParticipants] for 3-state attendance:
  ///   • in neither → unconfirmed
  ///   • in [attendedParticipants] → attended
  ///   • in [absentParticipants] → absent
  final List<String> absentParticipants;

  // ── IPIL template (only populated when createIpil = true) ──────────────
  // When attendance is confirmed for a session with IPIL, an IpilEntry is
  // created for each attended participant using these template values.
  final String? ipilContent;
  final List<String> ipilReinforcement;
  final List<String> ipilContextualization;
  final List<String> ipilConnectionTerritory;
  final List<String> ipilInterviews;
  final List<String> ipilIntermediations;
  final List<String> ipilObtainingEmployment;
  final List<String> ipilImprovingEmployment;
  final List<String> ipilCoordination;
  final List<String> ipilLegal;
  final List<String> ipilPostWorkSupport;
  final List<String> ipilEconomicBag;
  final List<String> ipilSpecificSkills;
  final List<String> ipilSoftSkills;
  final List<String> ipilDigitalSkills;
  final List<String> ipilLaborSkills;
  final bool ipilInitialInterview;
  final bool ipilInitialJobValoration;
  final bool ipilFinalInterview;
  final bool ipilFinalJobValoration;
  final String? ipilOther;

  /// Per-participant grant assignment captured at export time.
  /// Map of `userId` → `programId` (programs are treated as subvenciones).
  /// Empty Map when nothing has been assigned yet.
  final Map<String, String> participantSubvenciones;

  /// User IDs who have opted into a reminder for this session — driven by
  /// the bell icon ("campanita") on each row of the Próximas list. The
  /// actual notification scheduling is left to a follow-up; this field
  /// records the user's intent so the same toggle persists across devices.
  final List<String> reminderUserIds;

  /// Participants who confirmed they will attend, written from enreda-app's
  /// "Confirmar Asistencia" button on the participant calendar.
  final List<String> confirmedParticipants;

  factory Sesion.fromMap(Map<String, dynamic> data, String documentId) {
    final invited = <String>[];
    if (data['invitedParticipants'] != null) {
      for (final p in (data['invitedParticipants'] as Iterable)) {
        invited.add(p.toString());
      }
    }

    final attended = <String>[];
    if (data['attendedParticipants'] != null) {
      for (final p in (data['attendedParticipants'] as Iterable)) {
        attended.add(p.toString());
      }
    }

    return Sesion(
      sesionId: data['sesionId']?.toString() ?? documentId,
      tecnicoId: data['tecnicoId']?.toString() ?? '',
      socialEntityId: data['socialEntityId']?.toString(),
      sessionType: data['sessionType']?.toString() ?? 'individual',
      modality: data['modality']?.toString() ?? 'presencial',
      scheduledAt: data['scheduledAt']?.toDate() ?? DateTime.now(),
      fechaFin: data['fechaFin']?.toDate(),
      isAllDay: data['isAllDay'] == true,
      invitedParticipants: invited,
      attendedParticipants: attended,
      title: data['title']?.toString(),
      description: data['description']?.toString(),
      observations: data['observations']?.toString(),
      lugar: data['lugar']?.toString(),
      duracion: data['duracion']?.toString(),
      createIpil: data['createIpil'] == true,
      competenciaCategorias: data['competenciaCategorias'] != null
          ? [for (final c in (data['competenciaCategorias'] as Iterable)) c.toString()]
          : (data['competenciaCategoriaId'] != null && data['competenciaCategoriaId'].toString().isNotEmpty
              ? [data['competenciaCategoriaId'].toString()]
              : const <String>[]),
      competenciaSubCategorias: data['competenciaSubCategorias'] != null
          ? [for (final sc in (data['competenciaSubCategorias'] as Iterable)) sc.toString()]
          : (data['competenciaSubCategoriaId'] != null && data['competenciaSubCategoriaId'].toString().isNotEmpty
              ? [data['competenciaSubCategoriaId'].toString()]
              : const <String>[]),
      competencias: data['competencias'] != null
          ? [for (final c in (data['competencias'] as Iterable)) c.toString()]
          : (data['competenciaId'] != null && data['competenciaId'].toString().isNotEmpty
              ? [data['competenciaId'].toString()]
              : const <String>[]),
      createdAt: data['createdAt']?.toDate(),
      lastUpdated: data['lastUpdated']?.toDate(),
      absentParticipants: _parseStringList(data['absentParticipants']),
      ipilContent: data['ipilContent']?.toString(),
      ipilReinforcement: _parseStringList(data['ipilReinforcement']),
      ipilContextualization: _parseStringList(data['ipilContextualization']),
      ipilConnectionTerritory: _parseStringList(data['ipilConnectionTerritory']),
      ipilInterviews: _parseStringList(data['ipilInterviews']),
      ipilIntermediations: _parseStringList(data['ipilIntermediations']),
      ipilObtainingEmployment: _parseStringList(data['ipilObtainingEmployment']),
      ipilImprovingEmployment: _parseStringList(data['ipilImprovingEmployment']),
      ipilCoordination: _parseStringList(data['ipilCoordination']),
      ipilLegal: _parseStringList(data['ipilLegal']),
      ipilPostWorkSupport: _parseStringList(data['ipilPostWorkSupport']),
      ipilEconomicBag: _parseStringList(data['ipilEconomicBag']),
      ipilSpecificSkills: _parseStringList(data['ipilSpecificSkills']),
      ipilSoftSkills: _parseStringList(data['ipilSoftSkills']),
      ipilDigitalSkills: _parseStringList(data['ipilDigitalSkills']),
      ipilLaborSkills: _parseStringList(data['ipilLaborSkills']),
      ipilInitialInterview: data['ipilInitialInterview'] == true,
      ipilInitialJobValoration: data['ipilInitialJobValoration'] == true,
      ipilFinalInterview: data['ipilFinalInterview'] == true,
      ipilFinalJobValoration: data['ipilFinalJobValoration'] == true,
      ipilOther: data['ipilOther']?.toString(),
      participantSubvenciones:
          _parseStringStringMap(data['participantSubvenciones']),
      reminderUserIds: _parseStringList(data['reminderUserIds']),
      confirmedParticipants: _parseStringList(data['confirmedParticipants']),
    );
  }

  /// Safely parses a Firestore array field into a `List<String>`.
  static List<String> _parseStringList(dynamic raw) {
    if (raw == null) return <String>[];
    return [for (final item in raw as Iterable) item.toString()];
  }

  /// Safely parses a Firestore `Map<String, dynamic>` field into
  /// a `Map<String, String>` — used for `participantSubvenciones`.
  static Map<String, String> _parseStringStringMap(dynamic raw) {
    if (raw == null) return const <String, String>{};
    final out = <String, String>{};
    if (raw is Map) {
      raw.forEach((k, v) {
        if (v != null) out[k.toString()] = v.toString();
      });
    }
    return out;
  }

  Map<String, dynamic> toMap() {
    return {
      'sesionId': sesionId,
      'tecnicoId': tecnicoId,
      'socialEntityId': socialEntityId,
      'sessionType': sessionType,
      'modality': modality,
      'scheduledAt': scheduledAt,
      'fechaFin': fechaFin,
      'isAllDay': isAllDay,
      'invitedParticipants': invitedParticipants,
      'attendedParticipants': attendedParticipants,
      // confirmedParticipants intentionally NOT written from this app: the
      // participant app owns it, and re-writing a stale copy on session edits
      // (merge:true) would clobber confirmations made in the meantime.
      'title': title,
      'description': description,
      'observations': observations,
      'lugar': lugar,
      'duracion': duracion,
      'createIpil': createIpil,
      'competenciaCategoriaId': competenciaCategoriaId,
      'competenciaSubCategoriaId': competenciaSubCategoriaId,
      'competenciaCategorias': competenciaCategorias,
      'competenciaSubCategorias': competenciaSubCategorias,
      'competencias': competencias,
      'createdAt': createdAt,
      'lastUpdated': lastUpdated,
      'absentParticipants': absentParticipants,
      'ipilContent': ipilContent,
      'ipilReinforcement': ipilReinforcement,
      'ipilContextualization': ipilContextualization,
      'ipilConnectionTerritory': ipilConnectionTerritory,
      'ipilInterviews': ipilInterviews,
      'ipilIntermediations': ipilIntermediations,
      'ipilObtainingEmployment': ipilObtainingEmployment,
      'ipilImprovingEmployment': ipilImprovingEmployment,
      'ipilCoordination': ipilCoordination,
      'ipilLegal': ipilLegal,
      'ipilPostWorkSupport': ipilPostWorkSupport,
      'ipilEconomicBag': ipilEconomicBag,
      'ipilSpecificSkills': ipilSpecificSkills,
      'ipilSoftSkills': ipilSoftSkills,
      'ipilDigitalSkills': ipilDigitalSkills,
      'ipilLaborSkills': ipilLaborSkills,
      'ipilInitialInterview': ipilInitialInterview,
      'ipilInitialJobValoration': ipilInitialJobValoration,
      'ipilFinalInterview': ipilFinalInterview,
      'ipilFinalJobValoration': ipilFinalJobValoration,
      'ipilOther': ipilOther,
      'participantSubvenciones': participantSubvenciones,
      'reminderUserIds': reminderUserIds,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Sesion &&
            other.sesionId == sesionId);
  }

  @override
  int get hashCode => sesionId?.hashCode ?? 0;
}

/// Allowed values for `Sesion.sessionType`.
class SesionType {
  static const String individual = 'individual';
  static const String grupal = 'grupal';
}

/// Allowed values for `Sesion.modality`.
class SesionModality {
  static const String online = 'online';
  static const String presencial = 'presencial';
  static const String blended = 'blended';
}
