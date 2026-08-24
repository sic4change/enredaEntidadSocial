import 'package:enreda_empresas/app/models/ipilEntry.dart';
import 'package:enreda_empresas/app/models/sesion.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Shared body of the Sesión detail experience — rendered both inside
/// [SesionDetailPage] and inline beneath an expanded [SesionListTile].
///
/// Layout (Figma frame `1:94`):
///   * Wide viewports: left text column + right participants sub-card
///     side-by-side, with the Editar / Exportar CTAs centred underneath.
///   * Compact viewports: text column on top, participants sub-card under it,
///     CTAs centred at the bottom.
///
/// **No outer chrome** — the parent surface (expanded list row, detail page)
/// supplies the shadowed/rounded card. This widget just lays out the body.
/// Editar / Exportar CTAs are rendered only when their callback is non-null,
/// so the same widget can be reused on read-only surfaces.
class SesionDetailContent extends StatelessWidget {
  const SesionDetailContent({
    super.key,
    required this.sesion,
    this.onEdit,
    this.onExport,
  });

  final Sesion sesion;
  final VoidCallback? onEdit;
  final VoidCallback? onExport;

  @override
  Widget build(BuildContext context) {
    final isCompact = !Responsive.isDesktop(context);
    final showCtas = onEdit != null || onExport != null;

    final body = isCompact
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DetailContentCard(sesion: sesion),
              const SizedBox(height: Sizes.PADDING_8),
              _ParticipantPanel(sesion: sesion),
            ],
          )
        : IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _DetailContentCard(sesion: sesion),
                ),
                Expanded(
                  flex: 1,
                  child: _ParticipantPanel(sesion: sesion),
                ),
              ],
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        body,
        if (showCtas) ...[
          const SizedBox(height: Sizes.PADDING_20),
          _DetailCtaRow(onEdit: onEdit, onExport: onExport),
          const SizedBox(height: Sizes.PADDING_8),
        ],
      ],
    );
  }
}

class _DetailContentCard extends StatelessWidget {
  const _DetailContentCard({required this.sesion});

  final Sesion sesion;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // No outer Container — the parent (SesionDetailContent → expanded row
    // wrapper / detail page) provides the shadowed card chrome. CTAs no
    // longer live in this column either; SesionDetailContent renders them
    // full-width and centred underneath.
    return Padding(
      padding: const EdgeInsets.all(Sizes.PADDING_30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _titleFor(sesion),
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.primary900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Sizes.PADDING_22),
          Text(
            StringConst.SESION_DETAIL_DESARROLLO,
            // Figma correction #4: section headers now render in turquoise
            // (primary900 = #054D5E) — was greyTxtAlt.
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.primary900,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: Sizes.PADDING_8),
          Text(
            (sesion.description == null ||
                    sesion.description!.trim().isEmpty)
                ? StringConst.SESION_DETAIL_NO_DESARROLLO
                : sesion.description!,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.greyTxtAlt,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: Sizes.PADDING_22),
          Text(
            StringConst.SESION_DETAIL_OBSERVACIONES,
            // Same turquoise treatment as the Desarrollo header above.
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.primary900,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: Sizes.PADDING_8),
          Text(
            (sesion.observations == null ||
                    sesion.observations!.trim().isEmpty)
                ? StringConst.SESION_DETAIL_NO_OBSERVACIONES
                : sesion.observations!,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.greyTxtAlt,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  String _titleFor(Sesion s) {
    if (s.title != null && s.title!.trim().isNotEmpty) return s.title!;
    return s.sessionType == SesionType.grupal
        ? StringConst.SESION_GRUPAL
        : StringConst.SESION_INDIVIDUAL;
  }
}

class _DetailCtaRow extends StatelessWidget {
  const _DetailCtaRow({required this.onEdit, required this.onExport});
  final VoidCallback? onEdit;
  final VoidCallback? onExport;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget cta(String label, VoidCallback onTap, {Color? bg}) {
      return SizedBox(
        width: 154,
        height: Sizes.HEIGHT_50,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: bg ?? AppColors.primary400,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Sizes.RADIUS_25),
            ),
          ),
          onPressed: onTap,
          child: Text(
            label,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // Centered per Figma correction #4: "los botones de 'editar' y
    // 'exportar' en el centro" — was right-aligned.
    return Wrap(
      spacing: Sizes.PADDING_16,
      runSpacing: Sizes.PADDING_12,
      alignment: WrapAlignment.center,
      children: [
        if (onEdit != null)
          cta(StringConst.SESION_BUTTON_EDITAR, onEdit!),
        if (onExport != null)
          cta(StringConst.SESION_BUTTON_EXPORTAR, onExport!),
      ],
    );
  }
}

/// 3-state attendance enum for optimistic UI overlay.
enum _AttendanceState { unconfirmed, attended, absent }

/// Right-side bordered panel listing each invited participant.
/// Each row shows the participant name + two explicit action buttons:
///   ✓ (green circle) → mark attended; tap again to un-confirm.
///   ✗ (red circle)   → mark absent;   tap again to un-confirm.
///
/// Marking attended on a session with `createIpil = true` auto-creates an
/// [IpilEntry] from the session's IPIL template fields.
class _ParticipantPanel extends StatefulWidget {
  const _ParticipantPanel({required this.sesion});
  final Sesion sesion;

  @override
  State<_ParticipantPanel> createState() => _ParticipantPanelState();
}

class _ParticipantPanelState extends State<_ParticipantPanel> {
  /// Optimistic overlay — written immediately on action, then persisted via
  /// `setSesion`. Reverted on error.
  Set<String>? _optimisticAttended;
  Set<String>? _optimisticAbsent;
  bool _saving = false;

  Set<String> get _effectiveAttended =>
      _optimisticAttended ?? widget.sesion.attendedParticipants.toSet();

  Set<String> get _effectiveAbsent =>
      _optimisticAbsent ?? widget.sesion.absentParticipants.toSet();

  _AttendanceState _stateFor(String userId) {
    if (_effectiveAttended.contains(userId)) return _AttendanceState.attended;
    if (_effectiveAbsent.contains(userId)) return _AttendanceState.absent;
    return _AttendanceState.unconfirmed;
  }

  @override
  void didUpdateWidget(covariant _ParticipantPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_optimisticAttended != null) {
      if (_setEquals(
          widget.sesion.attendedParticipants.toSet(), _optimisticAttended!)) {
        _optimisticAttended = null;
      }
    }
    if (_optimisticAbsent != null) {
      if (_setEquals(
          widget.sesion.absentParticipants.toSet(), _optimisticAbsent!)) {
        _optimisticAbsent = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final invited = widget.sesion.invitedParticipants;
    final count = invited.length;

    // Participants live inside their own bordered + softly shadowed
    // sub-card per the updated Figma — visually separated from the
    // Título / Desarrollo / Observaciones column but still contained
    // within the outer SesionDetailContent shell.
    return Padding(
      padding: const EdgeInsets.all(Sizes.PADDING_24),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.PADDING_20,
          vertical: Sizes.PADDING_24,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(Sizes.RADIUS_16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary900.withOpacity(0.1),
              blurRadius: Sizes.PADDING_12,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Figma correction #4: "el título de '3 PARTICIPANTES' centrado".
            Text(
              '$count ${StringConst.SESION_DETAIL_PARTICIPANTES_HEADER}',
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                color: AppColors.primary900,
              ),
            ),
            const SizedBox(height: Sizes.PADDING_8),
            Text(
              StringConst.SESION_DETAIL_PARTICIPANTES_HELPER,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.greyTxtAlt,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: Sizes.PADDING_20),
            if (invited.isEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: Sizes.PADDING_20),
                child: Text(
                  StringConst.SESION_DETAIL_NO_PARTICIPANTES,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.greyTxtAlt,
                  ),
                ),
              )
            else
              ...invited.map(
                (id) => _ParticipantAttendanceChip(
                  userId: id,
                  attendanceState: _stateFor(id),
                  hasConfirmed:
                      widget.sesion.confirmedParticipants.contains(id),
                  hasRejected:
                      widget.sesion.rejectedParticipants.contains(id),
                  saving: _saving,
                  onMarkAttended: () => _markAttended(id),
                  onMarkAbsent: () => _markAbsent(id),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _markAttended(String userId) async {
    if (_saving) return;

    final currentAttended = Set<String>.from(_effectiveAttended);
    final currentAbsent = Set<String>.from(_effectiveAbsent);
    final isAlreadyAttended = currentAttended.contains(userId);

    final nextAttended = Set<String>.from(currentAttended);
    final nextAbsent = Set<String>.from(currentAbsent);

    if (isAlreadyAttended) {
      nextAttended.remove(userId);
    } else {
      nextAttended.add(userId);
      nextAbsent.remove(userId);
    }

    setState(() {
      _optimisticAttended = nextAttended;
      _optimisticAbsent = nextAbsent;
      _saving = true;
    });

    final database = Provider.of<Database>(context, listen: false);
    try {
      final updated = _buildUpdatedSesion(
        attendedParticipants: nextAttended.toList(growable: false),
        absentParticipants: nextAbsent.toList(growable: false),
      );
      await database.setSesion(updated);
      if (!mounted) return;
      setState(() => _saving = false);

      if (widget.sesion.createIpil) {
        if (!isAlreadyAttended) {
          await _createIpilForUser(userId);
        } else {
          await _removeIpilForUser(userId);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _optimisticAttended = currentAttended;
        _optimisticAbsent = currentAbsent;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(StringConst.SESION_ATTENDANCE_ERROR),
        ),
      );
    }
  }

  Future<void> _markAbsent(String userId) async {
    if (_saving) return;

    final currentAttended = Set<String>.from(_effectiveAttended);
    final currentAbsent = Set<String>.from(_effectiveAbsent);
    final isAlreadyAbsent = currentAbsent.contains(userId);
    final wasAttended = currentAttended.contains(userId);

    final nextAttended = Set<String>.from(currentAttended);
    final nextAbsent = Set<String>.from(currentAbsent);

    if (isAlreadyAbsent) {
      nextAbsent.remove(userId);
    } else {
      nextAbsent.add(userId);
      nextAttended.remove(userId);
    }

    setState(() {
      _optimisticAttended = nextAttended;
      _optimisticAbsent = nextAbsent;
      _saving = true;
    });

    final database = Provider.of<Database>(context, listen: false);
    try {
      final updated = _buildUpdatedSesion(
        attendedParticipants: nextAttended.toList(growable: false),
        absentParticipants: nextAbsent.toList(growable: false),
      );
      await database.setSesion(updated);
      if (!mounted) return;
      setState(() => _saving = false);

      if (wasAttended && !isAlreadyAbsent && widget.sesion.createIpil) {
        await _removeIpilForUser(userId);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _optimisticAttended = currentAttended;
        _optimisticAbsent = currentAbsent;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(StringConst.SESION_ATTENDANCE_ABSENT_ERROR),
        ),
      );
    }
  }

  Future<void> _createIpilForUser(String userId) async {
    final database = Provider.of<Database>(context, listen: false);
    final s = widget.sesion;
    final ipilEntry = IpilEntry(
      sesionId: s.sesionId,
      date: s.scheduledAt,
      lastUpdateDate: DateTime.now(),
      userId: userId,
      techId: s.tecnicoId,
      techName: '',
      content: s.ipilContent,
      reinforcement: s.ipilReinforcement,
      contextualization: s.ipilContextualization,
      connectionTerritory: s.ipilConnectionTerritory,
      interviews: s.ipilInterviews,
      intermediations: s.ipilIntermediations,
      obtainingEmployment: s.ipilObtainingEmployment,
      improvingEmployment: s.ipilImprovingEmployment,
      coordination: s.ipilCoordination,
      legal: s.ipilLegal,
      postWorkSupport: s.ipilPostWorkSupport,
      economicBag: s.ipilEconomicBag,
      specificSkills: s.ipilSpecificSkills,
      softSkills: s.ipilSoftSkills,
      digitalSkills: s.ipilDigitalSkills,
      laborSkills: s.ipilLaborSkills,
      initialInterview: s.ipilInitialInterview,
      initialJobValorationQuestionary: s.ipilInitialJobValoration,
      finalInterview: s.ipilFinalInterview,
      finalJobValorationQuestionary: s.ipilFinalJobValoration,
      other: s.ipilOther,
    );
    try {
      await database.addIpilEntry(ipilEntry);
    } catch (e) {
      debugPrint('_createIpilForUser: addIpilEntry failed: $e');
    }
  }

  Future<void> _removeIpilForUser(String userId) async {
    final database = Provider.of<Database>(context, listen: false);
    final sId = widget.sesion.sesionId;
    if (sId == null || sId.isEmpty) return;
    try {
      await database.deleteIpilEntriesBySesionAndUser(sId, userId);
    } catch (e) {
      debugPrint('_removeIpilForUser: delete failed: $e');
    }
  }

  Sesion _buildUpdatedSesion({
    required List<String> attendedParticipants,
    required List<String> absentParticipants,
  }) {
    final s = widget.sesion;
    return Sesion(
      sesionId: s.sesionId,
      tecnicoId: s.tecnicoId,
      socialEntityId: s.socialEntityId,
      sessionType: s.sessionType,
      modality: s.modality,
      scheduledAt: s.scheduledAt,
      fechaFin: s.fechaFin,
      isAllDay: s.isAllDay,
      invitedParticipants: s.invitedParticipants,
      attendedParticipants: attendedParticipants,
      absentParticipants: absentParticipants,
      title: s.title,
      description: s.description,
      observations: s.observations,
      lugar: s.lugar,
      duracion: s.duracion,
      createIpil: s.createIpil,
      competenciaCategorias: s.competenciaCategorias,
      competenciaSubCategorias: s.competenciaSubCategorias,
      competencias: s.competencias,
      createdAt: s.createdAt,
      lastUpdated: DateTime.now(),
      ipilContent: s.ipilContent,
      ipilReinforcement: s.ipilReinforcement,
      ipilContextualization: s.ipilContextualization,
      ipilConnectionTerritory: s.ipilConnectionTerritory,
      ipilInterviews: s.ipilInterviews,
      ipilIntermediations: s.ipilIntermediations,
      ipilObtainingEmployment: s.ipilObtainingEmployment,
      ipilImprovingEmployment: s.ipilImprovingEmployment,
      ipilCoordination: s.ipilCoordination,
      ipilLegal: s.ipilLegal,
      ipilPostWorkSupport: s.ipilPostWorkSupport,
      ipilEconomicBag: s.ipilEconomicBag,
      ipilSpecificSkills: s.ipilSpecificSkills,
      ipilSoftSkills: s.ipilSoftSkills,
      ipilDigitalSkills: s.ipilDigitalSkills,
      ipilLaborSkills: s.ipilLaborSkills,
      ipilInitialInterview: s.ipilInitialInterview,
      ipilInitialJobValoration: s.ipilInitialJobValoration,
      ipilFinalInterview: s.ipilFinalInterview,
      ipilFinalJobValoration: s.ipilFinalJobValoration,
      ipilOther: s.ipilOther,
    );
  }

  bool _setEquals(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    return a.every(b.contains);
  }
}

class _ParticipantAttendanceChip extends StatelessWidget {
  const _ParticipantAttendanceChip({
    required this.userId,
    required this.attendanceState,
    required this.hasConfirmed,
    required this.hasRejected,
    required this.saving,
    required this.onMarkAttended,
    required this.onMarkAbsent,
  });

  final String userId;
  final _AttendanceState attendanceState;

  /// Participant tapped "Confirmar Asistencia" in enreda-app.
  final bool hasConfirmed;

  /// Participant tapped "Cancelar Asistencia" in enreda-app.
  final bool hasRejected;
  final bool saving;
  final VoidCallback onMarkAttended;
  final VoidCallback onMarkAbsent;

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.PADDING_4),
      child: FutureBuilder<UserEnreda?>(
        future: LocationCache.instance.getUser(database, userId),
        builder: (context, snapshot) {
          final isWaiting =
              snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData;
          final user = snapshot.data;
          final fullName = isWaiting
              ? StringConst.SESION_PICKER_LOADING
              : (snapshot.hasError || user == null
                  ? StringConst.SESION_PICKER_UNKNOWN_USER
                  : '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim());

          final isAttended = attendanceState == _AttendanceState.attended;
          final isAbsent = attendanceState == _AttendanceState.absent;

          return Container(
            height: Sizes.HEIGHT_42,
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.PADDING_12,
              vertical: Sizes.PADDING_4,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(Sizes.RADIUS_20),
              border: Border.all(color: AppColors.greyBorder),
            ),
            child: Row(
              children: [
                // Dot: green when the participant confirmed (or the entity
                // marked attendance), red when the participant cancelled.
                // Never yellow — an entity mark ("attended") outranks a
                // participant cancellation.
                if (hasConfirmed || hasRejected || isAttended) ...[
                  Tooltip(
                    message: isAttended
                        ? StringConst.SESION_ACCEPTED_BY_ENTITY
                        : (hasRejected
                            ? StringConst.SESION_CANCELLED_BY_PARTICIPANT
                            : StringConst.SESION_CONFIRMED_BY_PARTICIPANT),
                    child: Container(
                      width: Sizes.WIDTH_12,
                      height: Sizes.HEIGHT_12,
                      decoration: BoxDecoration(
                        color: !isAttended && hasRejected
                            ? AppColors.attendanceRed
                            : AppColors.attendanceGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: Sizes.PADDING_8),
                ],
                Expanded(
                  child: Text(
                    fullName.isEmpty
                        ? StringConst.SESION_PICKER_UNKNOWN_USER
                        : fullName,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.seaBlue,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: Sizes.PADDING_8),
                InkWell(
                  borderRadius: BorderRadius.circular(Sizes.ICON_SIZE_16),
                  onTap: saving ? null : onMarkAttended,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isAttended
                          ? AppColors.attendanceGreen
                          : Colors.transparent,
                      border: Border.all(
                        color: AppColors.attendanceGreen,
                        width: isAttended ? 0 : 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.check,
                      color: isAttended
                          ? AppColors.white
                          : AppColors.attendanceGreen,
                      size: Sizes.ICON_SIZE_16,
                    ),
                  ),
                ),
                const SizedBox(width: Sizes.PADDING_8),
                InkWell(
                  borderRadius: BorderRadius.circular(Sizes.ICON_SIZE_16),
                  onTap: saving ? null : onMarkAbsent,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isAbsent
                          ? AppColors.attendanceRed
                          : Colors.transparent,
                      border: Border.all(
                        color: AppColors.attendanceRed,
                        width: isAbsent ? 0 : 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.close,
                      color: isAbsent
                          ? AppColors.white
                          : AppColors.attendanceRed,
                      size: Sizes.ICON_SIZE_16,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
