/// Read-only snapshot of the in-progress "Crear nueva sesión" form. Passed
/// from `CreateSesionFlowPage` down to `CreateSesionRevision` so the readback
/// widget doesn't have to know about parent state.
///
/// Kept in its own file to avoid a circular import between the flow page and
/// the revision widget.
class SesionDraft {
  const SesionDraft({
    required this.title,
    required this.modality,
    required this.scheduledAt,
    required this.fechaFin,
    required this.isAllDay,
    required this.lugar,
    required this.duracion,
    required this.createIpil,
    required this.sessionType,
    required this.description,
    required this.invitedParticipants,
    required this.invitedCount,
    required this.hasIpil,
    this.tecnicoName,
    this.ipil,
  });

  final String? title;
  final String modality;
  final DateTime? scheduledAt;
  final DateTime? fechaFin;
  final bool isAllDay;
  final String? lugar;
  final String? duracion;
  final bool createIpil;
  final String sessionType;
  final String? description;
  final List<String> invitedParticipants;

  /// Convenience count for revision display — avoids re-computing length.
  final int invitedCount;

  /// Whether the IPIL step was enabled and filled. Mirrors [createIpil] for
  /// the revision widget's readback.
  final bool hasIpil;

  /// Resolved display name of the convening técnico — shown in the revisión
  /// readback ("Nombre de la técnica" row in Figma 1:1099 / 1:1205).
  /// Null falls back to a dash placeholder.
  final String? tecnicoName;

  /// IPIL template snapshot — null when [createIpil] is false.
  final IpilDraft? ipil;
}

/// Snapshot of the IPIL template captured in step 2. Stored as IDs;
/// `CreateSesionRevision` resolves them to display labels via
/// `LocationCache.instance.ipil*`.
class IpilDraft {
  const IpilDraft({
    required this.content,
    required this.reinforcement,
    required this.contextualization,
    required this.connectionTerritory,
    required this.interviews,
    required this.intermediations,
    required this.obtainingEmployment,
    required this.improvingEmployment,
    required this.coordination,
    required this.legal,
    required this.postWorkSupport,
    required this.economicBag,
    required this.specificSkills,
    required this.softSkills,
    required this.digitalSkills,
    required this.laborSkills,
    required this.initialInterview,
    required this.initialJobValoration,
    required this.finalInterview,
    required this.finalJobValoration,
    required this.other,
  });

  final String? content;
  final List<String> reinforcement;
  final List<String> contextualization;
  final List<String> connectionTerritory;
  final List<String> interviews;
  final List<String> intermediations;
  final List<String> obtainingEmployment;
  final List<String> improvingEmployment;
  final List<String> coordination;
  final List<String> legal;
  final List<String> postWorkSupport;
  final List<String> economicBag;
  final List<String> specificSkills;
  final List<String> softSkills;
  final List<String> digitalSkills;
  final List<String> laborSkills;
  final bool initialInterview;
  final bool initialJobValoration;
  final bool finalInterview;
  final bool finalJobValoration;
  final String? other;

  /// True when no IPIL section has any selection — used by the revision to
  /// fall back to a "(sin selecciones)" placeholder.
  bool get isEmpty =>
      (content == null || content!.trim().isEmpty) &&
      (other == null || other!.trim().isEmpty) &&
      !initialInterview &&
      !initialJobValoration &&
      !finalInterview &&
      !finalJobValoration &&
      reinforcement.isEmpty &&
      contextualization.isEmpty &&
      connectionTerritory.isEmpty &&
      interviews.isEmpty &&
      intermediations.isEmpty &&
      obtainingEmployment.isEmpty &&
      improvingEmployment.isEmpty &&
      coordination.isEmpty &&
      legal.isEmpty &&
      postWorkSupport.isEmpty &&
      economicBag.isEmpty &&
      specificSkills.isEmpty &&
      softSkills.isEmpty &&
      digitalSkills.isEmpty &&
      laborSkills.isEmpty;
}
