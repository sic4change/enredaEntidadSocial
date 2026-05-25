import 'package:enreda_empresas/app/common_widgets/alert_dialog.dart';
import 'package:enreda_empresas/app/home/resources/global.dart' as globals;
import 'package:enreda_empresas/app/home/sesiones/create/sesion_draft.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/home/sesiones/create/widgets/create_sesion_ipil_step.dart';
import 'package:enreda_empresas/app/home/sesiones/create/widgets/create_sesion_revision.dart';
import 'package:enreda_empresas/app/home/sesiones/create/widgets/create_sesion_step1.dart';
import 'package:enreda_empresas/app/models/sesion.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/services/auth.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Multi-step "Crear nueva sesión" flow.
///
/// Steps (inferred from Figma canvas labels — no prototype data exists in
/// the file so the arrow direction is reconstructed, not extracted):
///
/// ```
///   Step 1 (1:321) — Información general
///       │
///       ├── createIpil = false ─► Revisión (1:1205)
///       │
///       └── createIpil = true  ─► IPIL stub (1:689 / 1:941 deferred)
///                                       │
///                                       └► Revisión with IPIL (1:1099)
///
///   Revisión → "Guardar" → Database.addSesion(...) → onClose()
/// ```
///
/// The IPIL detail step is a stub: it acknowledges the `createIpil` intent
/// and routes through to Revisión. Full IPIL data capture (per-participant
/// itinerary checkboxes + 11 competency multi-selects) is deferred to a
/// follow-up because it overlaps with the existing per-participant IPIL
/// infrastructure under `participants/participant_detail/ipils/` and needs
/// a separate architectural decision (per-session vs per-participant IPIL).
class CreateSesionFlowPage extends StatefulWidget {
  const CreateSesionFlowPage({
    super.key,
    required this.socialEntity,
    required this.onClose,
    this.initialSesion,
  });

  final SocialEntity socialEntity;
  final VoidCallback onClose;

  /// If non-null the flow runs in **edit mode**: form fields are
  /// pre-populated from this Sesión and `_handleSave` calls
  /// `Database.setSesion(...)` instead of `addSesion(...)`. The Sesion's
  /// `sesionId`, `createdAt`, and `attendedParticipants` are preserved
  /// — only the editable fields plus `lastUpdated` are rewritten.
  final Sesion? initialSesion;

  @override
  State<CreateSesionFlowPage> createState() => _CreateSesionFlowPageState();
}

class _CreateSesionFlowPageState extends State<CreateSesionFlowPage> {
  _Step _step = _Step.info;
  bool _saving = false;
  String? _saveError;

  // ── Draft state ─────────────────────────────────────────────────────────
  String? _title;
  String _modality = SesionModality.presencial;
  DateTime? _scheduledAt;
  bool _isAllDay = false;
  String? _lugar;
  String? _duracion;
  bool _createIpil = false;
  String _sessionType = SesionType.individual;
  String? _competenciaCategoriaId;
  String? _competenciaSubCategoriaId;
  String? _description;
  final List<String> _invitedParticipants = <String>[];

  // ── IPIL draft state ─────────────────────────────────────────────────────
  String? _ipilContent;
  List<String> _ipilReinforcement = <String>[];
  List<String> _ipilContextualization = <String>[];
  List<String> _ipilConnectionTerritory = <String>[];
  List<String> _ipilInterviews = <String>[];
  List<String> _ipilIntermediations = <String>[];
  List<String> _ipilObtainingEmployment = <String>[];
  List<String> _ipilImprovingEmployment = <String>[];
  List<String> _ipilCoordination = <String>[];
  List<String> _ipilLegal = <String>[];
  List<String> _ipilPostWorkSupport = <String>[];
  List<String> _ipilEconomicBag = <String>[];
  List<String> _ipilSpecificSkills = <String>[];
  List<String> _ipilSoftSkills = <String>[];
  List<String> _ipilDigitalSkills = <String>[];
  List<String> _ipilLaborSkills = <String>[];
  bool _ipilInitialInterview = false;
  bool _ipilInitialJobValoration = false;
  bool _ipilFinalInterview = false;
  bool _ipilFinalJobValoration = false;
  String? _ipilOther;

  bool get _isEditing => widget.initialSesion != null;

  @override
  void initState() {
    super.initState();
    final seed = widget.initialSesion;
    if (seed != null) {
      _title = seed.title;
      _modality = seed.modality;
      _scheduledAt = seed.scheduledAt;
      _isAllDay = seed.isAllDay;
      _lugar = seed.lugar;
      _duracion = seed.duracion;
      _createIpil = seed.createIpil;
      _sessionType = seed.sessionType;
      _competenciaCategoriaId = seed.competenciaCategoriaId;
      _competenciaSubCategoriaId = seed.competenciaSubCategoriaId;
      _description = seed.description;
      _invitedParticipants.addAll(seed.invitedParticipants);

      // Seed IPIL template from existing sesion (edit mode).
      _ipilContent = seed.ipilContent;
      _ipilReinforcement = List<String>.from(seed.ipilReinforcement);
      _ipilContextualization = List<String>.from(seed.ipilContextualization);
      _ipilConnectionTerritory =
          List<String>.from(seed.ipilConnectionTerritory);
      _ipilInterviews = List<String>.from(seed.ipilInterviews);
      _ipilIntermediations = List<String>.from(seed.ipilIntermediations);
      _ipilObtainingEmployment =
          List<String>.from(seed.ipilObtainingEmployment);
      _ipilImprovingEmployment =
          List<String>.from(seed.ipilImprovingEmployment);
      _ipilCoordination = List<String>.from(seed.ipilCoordination);
      _ipilLegal = List<String>.from(seed.ipilLegal);
      _ipilPostWorkSupport = List<String>.from(seed.ipilPostWorkSupport);
      _ipilEconomicBag = List<String>.from(seed.ipilEconomicBag);
      _ipilSpecificSkills = List<String>.from(seed.ipilSpecificSkills);
      _ipilSoftSkills = List<String>.from(seed.ipilSoftSkills);
      _ipilDigitalSkills = List<String>.from(seed.ipilDigitalSkills);
      _ipilLaborSkills = List<String>.from(seed.ipilLaborSkills);
      _ipilInitialInterview = seed.ipilInitialInterview;
      _ipilInitialJobValoration = seed.ipilInitialJobValoration;
      _ipilFinalInterview = seed.ipilFinalInterview;
      _ipilFinalJobValoration = seed.ipilFinalJobValoration;
      _ipilOther = seed.ipilOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = Responsive.isMobile(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? Sizes.PADDING_16 : Sizes.PADDING_30,
        vertical: Sizes.PADDING_24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderBar(onCancel: _handleCancel, textTheme: textTheme),
          const SizedBox(height: Sizes.PADDING_20),
          _StepTabs(currentStep: _step, createIpil: _createIpil),
          const SizedBox(height: Sizes.PADDING_24),
          Expanded(child: _buildStepBody(context)),
          if (_saveError != null) ...[
            const SizedBox(height: Sizes.PADDING_12),
            Text(
              _saveError!,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.deleteRed,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepBody(BuildContext context) {
    switch (_step) {
      case _Step.info:
        return CreateSesionStep1(
          socialEntityId: widget.socialEntity.socialEntityId ?? '',
          entityPrograms: widget.socialEntity.programs ?? const <String>[],
          initialTitle: _title,
          initialModality: _modality,
          initialScheduledAt: _scheduledAt,
          initialIsAllDay: _isAllDay,
          initialLugar: _lugar,
          initialDuracion: _duracion,
          initialCreateIpil: _createIpil,
          initialSessionType: _sessionType,
          initialCompetenciaCategoriaId: _competenciaCategoriaId,
          initialCompetenciaSubCategoriaId: _competenciaSubCategoriaId,
          initialDescription: _description,
          initialInvitedParticipants: _invitedParticipants,
          onNext: _handleStep1Submit,
        );
      case _Step.ipilStub:
        return CreateSesionIpilStep(
          sessionType: _sessionType,
          scheduledAt: _scheduledAt ?? DateTime.now(),
          invitedCount: _invitedParticipants.length,
          initialContent: _ipilContent,
          initialReinforcement: _ipilReinforcement,
          initialContextualization: _ipilContextualization,
          initialConnectionTerritory: _ipilConnectionTerritory,
          initialInterviews: _ipilInterviews,
          initialIntermediations: _ipilIntermediations,
          initialObtainingEmployment: _ipilObtainingEmployment,
          initialImprovingEmployment: _ipilImprovingEmployment,
          initialCoordination: _ipilCoordination,
          initialLegal: _ipilLegal,
          initialPostWorkSupport: _ipilPostWorkSupport,
          initialEconomicBag: _ipilEconomicBag,
          initialSpecificSkills: _ipilSpecificSkills,
          initialSoftSkills: _ipilSoftSkills,
          initialDigitalSkills: _ipilDigitalSkills,
          initialLaborSkills: _ipilLaborSkills,
          initialInitialInterview: _ipilInitialInterview,
          initialInitialJobValoration: _ipilInitialJobValoration,
          initialFinalInterview: _ipilFinalInterview,
          initialFinalJobValoration: _ipilFinalJobValoration,
          initialOther: _ipilOther,
          onBack: () => setState(() => _step = _Step.info),
          onNext: _handleIpilSubmit,
        );
      case _Step.revision:
        return CreateSesionRevision(
          draft: _draftSnapshot(),
          saving: _saving,
          onBack: _handleRevisionBack,
          onSave: _handleSave,
        );
    }
  }

  void _handleStep1Submit({
    required String? title,
    required String modality,
    required DateTime? scheduledAt,
    required bool isAllDay,
    required String? lugar,
    required String? duracion,
    required bool createIpil,
    required String sessionType,
    required String? competenciaCategoriaId,
    required String? competenciaSubCategoriaId,
    required String? description,
    required List<String> invitedParticipants,
  }) {
    setState(() {
      _title = title;
      _modality = modality;
      _scheduledAt = scheduledAt;
      _isAllDay = isAllDay;
      _lugar = lugar;
      _duracion = duracion;
      _createIpil = createIpil;
      _sessionType = sessionType;
      _competenciaCategoriaId = competenciaCategoriaId;
      _competenciaSubCategoriaId = competenciaSubCategoriaId;
      _description = description;
      _invitedParticipants
        ..clear()
        ..addAll(invitedParticipants);
      _step = createIpil ? _Step.ipilStub : _Step.revision;
      _saveError = null;
    });
  }

  void _handleRevisionBack() {
    setState(() {
      _step = _createIpil ? _Step.ipilStub : _Step.info;
    });
  }

  /// Stores all IPIL template values collected from [CreateSesionIpilStep]
  /// and advances to the revision step.
  void _handleIpilSubmit({
    required String? ipilContent,
    required List<String> ipilReinforcement,
    required List<String> ipilContextualization,
    required List<String> ipilConnectionTerritory,
    required List<String> ipilInterviews,
    required List<String> ipilIntermediations,
    required List<String> ipilObtainingEmployment,
    required List<String> ipilImprovingEmployment,
    required List<String> ipilCoordination,
    required List<String> ipilLegal,
    required List<String> ipilPostWorkSupport,
    required List<String> ipilEconomicBag,
    required List<String> ipilSpecificSkills,
    required List<String> ipilSoftSkills,
    required List<String> ipilDigitalSkills,
    required List<String> ipilLaborSkills,
    required bool ipilInitialInterview,
    required bool ipilInitialJobValoration,
    required bool ipilFinalInterview,
    required bool ipilFinalJobValoration,
    required String? ipilOther,
  }) {
    setState(() {
      _ipilContent = ipilContent;
      _ipilReinforcement = ipilReinforcement;
      _ipilContextualization = ipilContextualization;
      _ipilConnectionTerritory = ipilConnectionTerritory;
      _ipilInterviews = ipilInterviews;
      _ipilIntermediations = ipilIntermediations;
      _ipilObtainingEmployment = ipilObtainingEmployment;
      _ipilImprovingEmployment = ipilImprovingEmployment;
      _ipilCoordination = ipilCoordination;
      _ipilLegal = ipilLegal;
      _ipilPostWorkSupport = ipilPostWorkSupport;
      _ipilEconomicBag = ipilEconomicBag;
      _ipilSpecificSkills = ipilSpecificSkills;
      _ipilSoftSkills = ipilSoftSkills;
      _ipilDigitalSkills = ipilDigitalSkills;
      _ipilLaborSkills = ipilLaborSkills;
      _ipilInitialInterview = ipilInitialInterview;
      _ipilInitialJobValoration = ipilInitialJobValoration;
      _ipilFinalInterview = ipilFinalInterview;
      _ipilFinalJobValoration = ipilFinalJobValoration;
      _ipilOther = ipilOther;
      _step = _Step.revision;
      _saveError = null;
    });
  }

  /// Wraps the parent's `onClose` with an "unsaved changes" confirmation
  /// dialog — mirrors the `ParticipantDetailPage.isEditing` pattern.
  ///
  /// The whole create flow is treated as one editing session: any cancel
  /// (header `Cancelar`) prompts the user before discarding. Successful
  /// save calls `widget.onClose()` directly and bypasses this guard.
  ///
  /// Note: we always prompt rather than tracking field-level dirty bits.
  /// Step 1's TextFormFields hold transient text inside `CreateSesionStep1`
  /// state until Siguiente is tapped — propagating those keystrokes up to
  /// here just to make the dirty check granular would add a lot of
  /// listener churn for negligible UX gain (one extra click on cancel of
  /// an empty form). Discarding form input is a destructive action and a
  /// confirm is reasonable UX in either case.
  Future<void> _handleCancel() async {
    if (_saving) return;
    final leave = await showAlertDialog(
      context,
      title: StringConst.SESION_CONFIRM_LEAVE_TITLE,
      content: StringConst.SESION_CONFIRM_LEAVE_BODY,
      defaultActionText: StringConst.SESION_CONFIRM_LEAVE_DEFAULT,
      cancelActionText: StringConst.SESION_CONFIRM_LEAVE_CANCEL,
    );
    if (leave == true && mounted) {
      widget.onClose();
    }
  }

  Future<void> _handleSave() async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    final seed = widget.initialSesion;
    // Edit mode reuses the existing tecnicoId so attribution stays with the
    // original convener even if a different técnico is editing. Create mode
    // sources tecnicoId from the currently-authenticated user.
    final tecnicoId = seed?.tecnicoId ?? auth.currentUser?.uid;
    if (tecnicoId == null) {
      setState(() => _saveError = _isEditing
          ? StringConst.SESION_UPDATE_ERROR
          : StringConst.SESION_CREATE_ERROR);
      return;
    }

    setState(() {
      _saving = true;
      _saveError = null;
    });

    final now = DateTime.now();
    final sesion = Sesion(
      // Preserve identity + audit trail when editing.
      sesionId: seed?.sesionId,
      tecnicoId: tecnicoId,
      socialEntityId: widget.socialEntity.socialEntityId,
      sessionType: _sessionType,
      modality: _modality,
      scheduledAt: _scheduledAt ?? seed?.scheduledAt ?? now,
      isAllDay: _isAllDay,
      invitedParticipants: List<String>.from(_invitedParticipants),
      // Preserve attendance when editing — it's edited from the detail page,
      // not from the create flow.
      attendedParticipants:
          seed?.attendedParticipants ?? const <String>[],
      // Preserve absent participants when editing.
      absentParticipants: seed?.absentParticipants ?? const <String>[],
      title: _title,
      description: _description,
      observations: seed?.observations,
      lugar: _lugar,
      duracion: _duracion,
      createIpil: _createIpil,
      competenciaCategoriaId: _competenciaCategoriaId,
      competenciaSubCategoriaId: _competenciaSubCategoriaId,
      createdAt: seed?.createdAt ?? now,
      lastUpdated: now,
      // IPIL template fields.
      ipilContent: _ipilContent,
      ipilReinforcement: _ipilReinforcement,
      ipilContextualization: _ipilContextualization,
      ipilConnectionTerritory: _ipilConnectionTerritory,
      ipilInterviews: _ipilInterviews,
      ipilIntermediations: _ipilIntermediations,
      ipilObtainingEmployment: _ipilObtainingEmployment,
      ipilImprovingEmployment: _ipilImprovingEmployment,
      ipilCoordination: _ipilCoordination,
      ipilLegal: _ipilLegal,
      ipilPostWorkSupport: _ipilPostWorkSupport,
      ipilEconomicBag: _ipilEconomicBag,
      ipilSpecificSkills: _ipilSpecificSkills,
      ipilSoftSkills: _ipilSoftSkills,
      ipilDigitalSkills: _ipilDigitalSkills,
      ipilLaborSkills: _ipilLaborSkills,
      ipilInitialInterview: _ipilInitialInterview,
      ipilInitialJobValoration: _ipilInitialJobValoration,
      ipilFinalInterview: _ipilFinalInterview,
      ipilFinalJobValoration: _ipilFinalJobValoration,
      ipilOther: _ipilOther,
    );

    try {
      if (_isEditing) {
        await database.setSesion(sesion);
      } else {
        await database.addSesion(sesion);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? StringConst.SESION_UPDATE_SUCCESS
              : StringConst.SESION_CREATE_SUCCESS),
        ),
      );
      widget.onClose();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveError = _isEditing
            ? StringConst.SESION_UPDATE_ERROR
            : StringConst.SESION_CREATE_ERROR;
      });
    }
  }

  /// Resolves the convening técnico's display name for the revision row.
  ///   • Edit mode  → lookup `seed.tecnicoId` in `LocationCache.userCache`
  ///   • Create mode → use the currently-logged-in social-entity user
  /// Returns null when no name can be resolved (revision shows a dash).
  String? _resolveTecnicoName() {
    final seed = widget.initialSesion;
    if (seed != null && seed.tecnicoId.isNotEmpty) {
      final u = LocationCache.instance.userCache[seed.tecnicoId];
      if (u != null) {
        final n = '${u.firstName ?? ''} ${u.lastName ?? ''}'.trim();
        if (n.isNotEmpty) return n;
      }
    }
    final me = globals.currentSocialEntityUser;
    if (me != null) {
      final n = '${me.firstName ?? ''} ${me.lastName ?? ''}'.trim();
      if (n.isNotEmpty) return n;
    }
    return null;
  }

  SesionDraft _draftSnapshot() => SesionDraft(
        title: _title,
        modality: _modality,
        scheduledAt: _scheduledAt,
        isAllDay: _isAllDay,
        lugar: _lugar,
        duracion: _duracion,
        createIpil: _createIpil,
        sessionType: _sessionType,
        description: _description,
        invitedParticipants: List<String>.unmodifiable(_invitedParticipants),
        invitedCount: _invitedParticipants.length,
        hasIpil: _createIpil,
        tecnicoName: _resolveTecnicoName(),
        ipil: _createIpil
            ? IpilDraft(
                content: _ipilContent,
                reinforcement: List<String>.unmodifiable(_ipilReinforcement),
                contextualization:
                    List<String>.unmodifiable(_ipilContextualization),
                connectionTerritory:
                    List<String>.unmodifiable(_ipilConnectionTerritory),
                interviews: List<String>.unmodifiable(_ipilInterviews),
                intermediations:
                    List<String>.unmodifiable(_ipilIntermediations),
                obtainingEmployment:
                    List<String>.unmodifiable(_ipilObtainingEmployment),
                improvingEmployment:
                    List<String>.unmodifiable(_ipilImprovingEmployment),
                coordination: List<String>.unmodifiable(_ipilCoordination),
                legal: List<String>.unmodifiable(_ipilLegal),
                postWorkSupport:
                    List<String>.unmodifiable(_ipilPostWorkSupport),
                economicBag: List<String>.unmodifiable(_ipilEconomicBag),
                specificSkills:
                    List<String>.unmodifiable(_ipilSpecificSkills),
                softSkills: List<String>.unmodifiable(_ipilSoftSkills),
                digitalSkills: List<String>.unmodifiable(_ipilDigitalSkills),
                laborSkills: List<String>.unmodifiable(_ipilLaborSkills),
                initialInterview: _ipilInitialInterview,
                initialJobValoration: _ipilInitialJobValoration,
                finalInterview: _ipilFinalInterview,
                finalJobValoration: _ipilFinalJobValoration,
                other: _ipilOther,
              )
            : null,
      );
}

enum _Step { info, ipilStub, revision }

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({required this.onCancel, required this.textTheme});
  final VoidCallback onCancel;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            StringConst.SESION_CREATE_TITLE,
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.primary900,
              fontWeight: FontWeight.w300,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: Sizes.PADDING_16),
        TextButton.icon(
          onPressed: onCancel,
          icon: const Icon(
            Icons.close,
            size: Sizes.ICON_SIZE_20,
            color: AppColors.greyTxtAlt,
          ),
          label: Text(
            StringConst.SESION_BUTTON_CANCELAR,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.greyTxtAlt,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Step indicator: yellow pills connected by horizontal lines.
///
/// Matches Figma frames `1:1099` (with IPIL — 3 pills + 2 connectors) and
/// `1:1205` (no IPIL — 2 pills + 1 connector). The IPIL pill is **hidden
/// entirely** (not just dimmed) when `createIpil` is false, and the
/// remaining pills are spaced via flexible connector lines that fill the
/// available width. The pill boxes themselves use identical UI/UX in both
/// cases — only the count changes.
class _StepTabs extends StatelessWidget {
  const _StepTabs({required this.currentStep, required this.createIpil});
  final _Step currentStep;
  final bool createIpil;

  @override
  Widget build(BuildContext context) {
    final infoActive = true; // step 1 is always considered visited
    final ipilActive = currentStep == _Step.ipilStub ||
        (currentStep == _Step.revision && createIpil);
    final revisionActive = currentStep == _Step.revision;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _StepPill(label: StringConst.SESION_TAB_INFO, isActive: infoActive),
        if (createIpil) ...[
          // First connector — Info → IPIL. Yellow only when both ends are
          // already visited (i.e. user has advanced past Info).
          Expanded(child: _Connector(active: ipilActive)),
          _StepPill(label: StringConst.SESION_TAB_IPIL, isActive: ipilActive),
          // Second connector — IPIL → Revisión.
          Expanded(child: _Connector(active: revisionActive)),
        ] else
          // Single connector when there is no IPIL step.
          Expanded(child: _Connector(active: revisionActive)),
        _StepPill(
          label: StringConst.SESION_TAB_REVISION,
          isActive: revisionActive,
        ),
      ],
    );
  }
}

/// Single yellow pill — same visual contract for every step. Read-only:
/// users advance via the Siguiente/Volver buttons inside each step, not by
/// tapping the pill.
class _StepPill extends StatelessWidget {
  const _StepPill({required this.label, required this.isActive});

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: Sizes.HEIGHT_50,
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.PADDING_24,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive ? AppColors.yellow : AppColors.white,
        borderRadius: BorderRadius.circular(Sizes.RADIUS_25),
        border: Border.all(
          color: isActive ? AppColors.yellow : AppColors.violet,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: textTheme.bodyLarge?.copyWith(
          color: isActive ? AppColors.primary900 : AppColors.greyTxtAlt,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }
}

/// Horizontal arrow connecting two adjacent step pills — 2px shaft + small
/// filled triangle head pointing right. Yellow when the step on the right
/// has been reached; otherwise a muted grey. Matches the small arrow in the
/// Figma reference between Info → IPIL and IPIL → Revisión.
class _Connector extends StatelessWidget {
  const _Connector({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.yellow : AppColors.violet;
    return Container(
      height: 14,
      margin: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_8),
      child: CustomPaint(
        size: const Size(double.infinity, 14),
        painter: _ArrowPainter(color: color),
      ),
    );
  }
}

/// Draws a horizontal arrow that fills the painter's allotted width.
///
/// Geometry:
///   • Shaft: 2px thick, vertically centred, runs from x=0 to the base of
///     the arrowhead (with a 1px overlap so they merge cleanly).
///   • Arrowhead: 10×10 filled triangle. Apex at the far right, base flush
///     against the right end of the shaft.
class _ArrowPainter extends CustomPainter {
  _ArrowPainter({required this.color});
  final Color color;

  static const double _headWidth = 10;
  static const double _headHeight = 10;
  static const double _shaftThickness = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final cy = size.height / 2;

    // Shaft — overlaps the arrowhead base by 1px so the seam is invisible.
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        cy - _shaftThickness / 2,
        (size.width - _headWidth + 1).clamp(0, size.width),
        _shaftThickness,
      ),
      paint,
    );

    // Arrowhead — filled triangle, apex pointing right.
    final path = Path()
      ..moveTo(size.width - _headWidth, cy - _headHeight / 2)
      ..lineTo(size.width, cy)
      ..lineTo(size.width - _headWidth, cy + _headHeight / 2)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.color != color;
}

// SesionDraft is exported from `sesion_draft.dart` to avoid a circular
// import with `widgets/create_sesion_revision.dart`.
