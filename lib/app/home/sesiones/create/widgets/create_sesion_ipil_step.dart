import 'package:enreda_empresas/app/common_widgets/custom_check_box_selectable.dart';
import 'package:enreda_empresas/app/common_widgets/custom_drop_down-button_form_field_no_title_check.dart';
import 'package:enreda_empresas/app/common_widgets/custom_drop_down_button_form_field_title_check.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_form_field_long.dart';
import 'package:enreda_empresas/app/models/ipilConnectionTerritory.dart';
import 'package:enreda_empresas/app/models/ipilContextualization.dart';
import 'package:enreda_empresas/app/models/ipilCoordination.dart';
import 'package:enreda_empresas/app/models/ipilDigitalSkills.dart';
import 'package:enreda_empresas/app/models/ipilEconomicBag.dart';
import 'package:enreda_empresas/app/models/ipilImprovementEmployment.dart';
import 'package:enreda_empresas/app/models/ipilIntermediations.dart';
import 'package:enreda_empresas/app/models/ipilInterviews.dart';
import 'package:enreda_empresas/app/models/ipilLaborSkills.dart';
import 'package:enreda_empresas/app/models/ipilLegal.dart';
import 'package:enreda_empresas/app/models/ipilObtainingEmployment.dart';
import 'package:enreda_empresas/app/models/ipilPostWorkSupport.dart';
import 'package:enreda_empresas/app/models/ipilReinforcement.dart';
import 'package:enreda_empresas/app/models/ipilSoftSkills.dart';
import 'package:enreda_empresas/app/models/ipilSpecificSkills.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

/// Callback type for submitting IPIL template data from the session create flow.
typedef IpilSubmit = void Function({
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
});

/// Session-level IPIL template step in the "Crear nueva sesión" flow.
///
/// Unlike the per-participant [CreateIpilForm], this step:
///   • Has no `techId` dropdown (inherited from the session).
///   • Has no per-participant itinerary history StreamBuilder.
///   • Uses `scheduledAt` passed in from the session info step.
///   • All data sources read from [LocationCache] — no Firestore reads.
///
/// The values collected here are stored on the [Sesion] document and then
/// applied as a template when individual [IpilEntry] records are auto-created
/// upon marking a participant as attended.
class CreateSesionIpilStep extends StatefulWidget {
  const CreateSesionIpilStep({
    super.key,
    required this.sessionType,
    required this.scheduledAt,
    required this.invitedCount,
    this.initialContent,
    this.initialReinforcement = const <String>[],
    this.initialContextualization = const <String>[],
    this.initialConnectionTerritory = const <String>[],
    this.initialInterviews = const <String>[],
    this.initialIntermediations = const <String>[],
    this.initialObtainingEmployment = const <String>[],
    this.initialImprovingEmployment = const <String>[],
    this.initialCoordination = const <String>[],
    this.initialLegal = const <String>[],
    this.initialPostWorkSupport = const <String>[],
    this.initialEconomicBag = const <String>[],
    this.initialSpecificSkills = const <String>[],
    this.initialSoftSkills = const <String>[],
    this.initialDigitalSkills = const <String>[],
    this.initialLaborSkills = const <String>[],
    this.initialInitialInterview = false,
    this.initialInitialJobValoration = false,
    this.initialFinalInterview = false,
    this.initialFinalJobValoration = false,
    this.initialOther,
    required this.onNext,
    required this.onBack,
  });

  /// `individual` | `grupal` — passed from step 1.
  final String sessionType;

  /// Date/time inherited from step 1.
  final DateTime scheduledAt;

  /// Number of invited participants (for display note only).
  final int invitedCount;

  // ── Initial values for edit mode ──────────────────────────────────────
  final String? initialContent;
  final List<String> initialReinforcement;
  final List<String> initialContextualization;
  final List<String> initialConnectionTerritory;
  final List<String> initialInterviews;
  final List<String> initialIntermediations;
  final List<String> initialObtainingEmployment;
  final List<String> initialImprovingEmployment;
  final List<String> initialCoordination;
  final List<String> initialLegal;
  final List<String> initialPostWorkSupport;
  final List<String> initialEconomicBag;
  final List<String> initialSpecificSkills;
  final List<String> initialSoftSkills;
  final List<String> initialDigitalSkills;
  final List<String> initialLaborSkills;
  final bool initialInitialInterview;
  final bool initialInitialJobValoration;
  final bool initialFinalInterview;
  final bool initialFinalJobValoration;
  final String? initialOther;

  final IpilSubmit onNext;
  final VoidCallback onBack;

  @override
  State<CreateSesionIpilStep> createState() => _CreateSesionIpilStepState();
}

class _CreateSesionIpilStepState extends State<CreateSesionIpilStep> {
  final _formKey = GlobalKey<FormState>();

  // ── Seguimiento text ────────────────────────────────────────────────
  String? _content;

  // ── Multi-select lists ──────────────────────────────────────────────
  late List<String> _reinforcement;
  late List<String> _contextualization;
  late List<String> _connectionTerritory;
  late List<String> _interviews;
  late List<String> _intermediations;
  late List<String> _obtainingEmployment;
  late List<String> _improvingEmployment;
  late List<String> _coordination;
  late List<String> _legal;
  late List<String> _postWorkSupport;
  late List<String> _economicBag;
  late List<String> _specificSkills;
  late List<String> _softSkills;
  late List<String> _digitalSkills;
  late List<String> _laborSkills;

  // ── Itinerary checkboxes ────────────────────────────────────────────
  late bool _initialInterview;
  late bool _initialJobValoration;
  late bool _finalInterview;
  late bool _finalJobValoration;

  // ── Otros text ─────────────────────────────────────────────────────
  String? _other;

  @override
  void initState() {
    super.initState();
    _content = widget.initialContent;
    _reinforcement = List<String>.from(widget.initialReinforcement);
    _contextualization = List<String>.from(widget.initialContextualization);
    _connectionTerritory = List<String>.from(widget.initialConnectionTerritory);
    _interviews = List<String>.from(widget.initialInterviews);
    _intermediations = List<String>.from(widget.initialIntermediations);
    _obtainingEmployment = List<String>.from(widget.initialObtainingEmployment);
    _improvingEmployment = List<String>.from(widget.initialImprovingEmployment);
    _coordination = List<String>.from(widget.initialCoordination);
    _legal = List<String>.from(widget.initialLegal);
    _postWorkSupport = List<String>.from(widget.initialPostWorkSupport);
    _economicBag = List<String>.from(widget.initialEconomicBag);
    _specificSkills = List<String>.from(widget.initialSpecificSkills);
    _softSkills = List<String>.from(widget.initialSoftSkills);
    _digitalSkills = List<String>.from(widget.initialDigitalSkills);
    _laborSkills = List<String>.from(widget.initialLaborSkills);
    _initialInterview = widget.initialInitialInterview;
    _initialJobValoration = widget.initialInitialJobValoration;
    _finalInterview = widget.initialFinalInterview;
    _finalJobValoration = widget.initialFinalJobValoration;
    _other = widget.initialOther;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.altWhite,
        borderRadius: BorderRadius.circular(Sizes.RADIUS_16),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Sizes.PADDING_24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Nota informativa ──────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.PADDING_16,
                        vertical: Sizes.PADDING_12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary400.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(Sizes.RADIUS_12),
                        border: Border.all(
                          color: AppColors.primary400.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        StringConst.SESION_IPIL_INVITED_NOTE
                            .replaceFirst('{count}',
                                widget.invitedCount.toString()),
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary900,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: Sizes.PADDING_20),

                    // ── Seguimiento ───────────────────────────────────
                    CustomTextFormFieldLong(
                      labelText: StringConst.GOALS_MONITORING,
                      hintText: StringConst.IPIL_GOALS_MONITORING_PLACEHOLDER,
                      initialValue: _content,
                      enabled: true,
                      onSaved: (value) async {
                        _content = value;
                      },
                    ),
                    const SizedBox(height: Sizes.PADDING_20),

                    // ── Inicio de itinerario ──────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Sizes.kDefaultPaddingDouble / 2),
                      child: CustomTextBold(
                        title: StringConst.IPIL_INITIAL_ITINERARY,
                        color: AppColors.primary900,
                      ),
                    ),
                    CustomCheckBoxSelectable(
                      title: StringConst.IPIL_INITIAL_INTERVIEW,
                      isSelected: _initialInterview,
                      onTapItem: (value) {
                        setState(() => _initialInterview = value);
                      },
                      selectable: true,
                    ),
                    CustomCheckBoxSelectable(
                      title: StringConst.IPIL_INITIAL_QUESTIONARY,
                      isSelected: _initialJobValoration,
                      onTapItem: (value) {
                        setState(() => _initialJobValoration = value);
                      },
                      selectable: true,
                    ),

                    // ── Cierre de itinerario ──────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Sizes.kDefaultPaddingDouble / 2),
                      child: CustomTextBold(
                        title: StringConst.IPIL_CLOSE_ITINERARY,
                        color: AppColors.primary900,
                      ),
                    ),
                    CustomCheckBoxSelectable(
                      title: StringConst.IPIL_CLOSE_INTERVIEW,
                      isSelected: _finalInterview,
                      onTapItem: (value) {
                        setState(() => _finalInterview = value);
                      },
                      selectable: true,
                    ),
                    CustomCheckBoxSelectable(
                      title: StringConst.IPIL_CLOSE_QUESTIONARY,
                      isSelected: _finalJobValoration,
                      onTapItem: (value) {
                        setState(() => _finalJobValoration = value);
                      },
                      selectable: true,
                    ),
                    const SizedBox(height: Sizes.PADDING_12),

                    // ── Fortalecimiento de las competencias ───────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Sizes.kDefaultPaddingDouble / 2),
                      child: CustomTextBold(
                        title: StringConst.IPIL_REINFORCEMENT,
                        color: AppColors.primary900,
                      ),
                    ),
                    _buildCachedCheckboxNoTitle(
                      title: StringConst.IPIL_SPECIFIC_SKILLS,
                      options: LocationCache.instance.ipilSpecificSkills,
                      selectedIds: _specificSkills,
                      getId: (e) =>
                          (e as IpilSpecificSkills).ipilSpecificSkillsId ?? '',
                      getLabel: (e) => (e as IpilSpecificSkills).label,
                      cornerTop: true,
                      cornerBottom: false,
                      onChanged: (ids) =>
                          setState(() => _specificSkills = ids),
                    ),
                    _buildCachedCheckboxNoTitle(
                      title: StringConst.IPIL_SOFT_SKILLS,
                      options: LocationCache.instance.ipilSoftSkills,
                      selectedIds: _softSkills,
                      getId: (e) =>
                          (e as IpilSoftSkills).ipilSoftSkillsId ?? '',
                      getLabel: (e) => (e as IpilSoftSkills).label,
                      cornerTop: false,
                      cornerBottom: false,
                      onChanged: (ids) => setState(() => _softSkills = ids),
                    ),
                    _buildCachedCheckboxNoTitle(
                      title: StringConst.IPIL_DIGITAL_SKILLS,
                      options: LocationCache.instance.ipilDigitalSkills,
                      selectedIds: _digitalSkills,
                      getId: (e) =>
                          (e as IpilDigitalSkills).ipilDigitalSkillsId ?? '',
                      getLabel: (e) => (e as IpilDigitalSkills).label,
                      cornerTop: false,
                      cornerBottom: false,
                      onChanged: (ids) =>
                          setState(() => _digitalSkills = ids),
                    ),
                    _buildCachedCheckboxNoTitle(
                      title: StringConst.IPIL_LABOR_SKILLS,
                      options: LocationCache.instance.ipilLaborSkills,
                      selectedIds: _laborSkills,
                      getId: (e) =>
                          (e as IpilLaborSkills).ipilLaborSkillsId ?? '',
                      getLabel: (e) => (e as IpilLaborSkills).label,
                      cornerTop: false,
                      cornerBottom: true,
                      onChanged: (ids) => setState(() => _laborSkills = ids),
                    ),
                    const SizedBox(height: Sizes.kDefaultPaddingDouble / 2),

                    // ── Contextualización ─────────────────────────────
                    _buildCachedCheckbox(
                      title: StringConst.IPIL_CONTEXTUALIZATION,
                      options: LocationCache.instance.ipilContextualizations,
                      selectedIds: _contextualization,
                      getId: (e) =>
                          (e as IpilContextualization)
                              .ipilContextualizationId ?? '',
                      getLabel: (e) => (e as IpilContextualization).label,
                      onChanged: (ids) =>
                          setState(() => _contextualization = ids),
                    ),

                    // ── Conexión con el territorio ────────────────────
                    _buildCachedCheckbox(
                      title: StringConst.IPIL_CONNECTION_TERRITORY,
                      options: LocationCache.instance.ipilConnectionTerritories,
                      selectedIds: _connectionTerritory,
                      getId: (e) =>
                          (e as IpilConnectionTerritory)
                              .ipilConnectionTerritoryId ?? '',
                      getLabel: (e) => (e as IpilConnectionTerritory).label,
                      onChanged: (ids) =>
                          setState(() => _connectionTerritory = ids),
                    ),

                    // ── Entrevistas-laboral ───────────────────────────
                    _buildCachedCheckbox(
                      title: StringConst.IPIL_INTERVIEWS,
                      options: LocationCache.instance.ipilInterviews,
                      selectedIds: _interviews,
                      getId: (e) =>
                          (e as IpilInterviews).ipilInterviewsId ?? '',
                      getLabel: (e) => (e as IpilInterviews).label,
                      onChanged: (ids) => setState(() => _interviews = ids),
                    ),

                    // ── Intermediación laboral ────────────────────────
                    _buildCachedCheckbox(
                      title: StringConst.IPIL_INTERMEDIATIONS,
                      options: LocationCache.instance.ipilIntermediations,
                      selectedIds: _intermediations,
                      getId: (e) =>
                          (e as IpilIntermediations).ipilIntermediationsId ??
                              '',
                      getLabel: (e) => (e as IpilIntermediations).label,
                      onChanged: (ids) =>
                          setState(() => _intermediations = ids),
                    ),

                    // ── Obtención de empleo ───────────────────────────
                    _buildCachedCheckbox(
                      title: StringConst.IPIL_OBTAINING_EMPLOYMENT,
                      options: LocationCache.instance.ipilObtainingEmployments,
                      selectedIds: _obtainingEmployment,
                      getId: (e) =>
                          (e as IpilObtainingEmployment)
                              .ipilObtainingEmploymentId ?? '',
                      getLabel: (e) => (e as IpilObtainingEmployment).label,
                      onChanged: (ids) =>
                          setState(() => _obtainingEmployment = ids),
                    ),

                    // ── Mejora de empleo ──────────────────────────────
                    _buildCachedCheckbox(
                      title: StringConst.IPIL_IMPROVING_EMPLOYMENT,
                      options: LocationCache.instance.ipilImprovingEmployments,
                      selectedIds: _improvingEmployment,
                      getId: (e) =>
                          (e as IpilImprovingEmployment)
                              .ipilImprovingEmploymentId ?? '',
                      getLabel: (e) => (e as IpilImprovingEmployment).label,
                      onChanged: (ids) =>
                          setState(() => _improvingEmployment = ids),
                    ),

                    // ── Coordinación/derivación ───────────────────────
                    _buildCachedCheckbox(
                      title: StringConst.IPIL_COORDINATION,
                      options: LocationCache.instance.ipilCoordinations,
                      selectedIds: _coordination,
                      getId: (e) =>
                          (e as IpilCoordination).ipilCoordinationId ?? '',
                      getLabel: (e) => (e as IpilCoordination).label,
                      onChanged: (ids) => setState(() => _coordination = ids),
                    ),

                    // ── Jurídico ──────────────────────────────────────
                    _buildCachedCheckbox(
                      title: StringConst.IPIL_LEGAL,
                      options: LocationCache.instance.ipilLegals,
                      selectedIds: _legal,
                      getId: (e) => (e as IpilLegal).ipilLegalId ?? '',
                      getLabel: (e) => (e as IpilLegal).label,
                      onChanged: (ids) => setState(() => _legal = ids),
                    ),

                    // ── Acompañamientos ───────────────────────────────
                    _buildCachedCheckbox(
                      title: StringConst.IPIL_POST_WORK_SUPPORT,
                      options: LocationCache.instance.ipilPostWorkSupports,
                      selectedIds: _postWorkSupport,
                      getId: (e) =>
                          (e as IpilPostWorkSupport).ipilPostWorkSupportId ??
                              '',
                      getLabel: (e) => (e as IpilPostWorkSupport).label,
                      onChanged: (ids) =>
                          setState(() => _postWorkSupport = ids),
                    ),

                    // ── Bolsas económicas ─────────────────────────────
                    _buildCachedCheckbox(
                      title: StringConst.IPIL_ECONOMIC_BAG,
                      options: LocationCache.instance.ipilEconomicBags,
                      selectedIds: _economicBag,
                      getId: (e) =>
                          (e as IpilEconomicBag).ipilEconomicBagId ?? '',
                      getLabel: (e) => (e as IpilEconomicBag).label,
                      onChanged: (ids) => setState(() => _economicBag = ids),
                    ),
                    const SizedBox(height: Sizes.kDefaultPaddingDouble / 2),

                    // ── Otros ─────────────────────────────────────────
                    CustomTextFormFieldLong(
                      labelText: StringConst.IPIL_OTHERS,
                      initialValue: _other,
                      enabled: true,
                      onSaved: (value) async {
                        _other = value;
                      },
                    ),
                    const SizedBox(height: Sizes.PADDING_24),
                  ],
                ),
              ),
            ),

            // ── Navigation row (Volver / Siguiente) ──────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.PADDING_24,
                vertical: Sizes.PADDING_16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onBack,
                    child: Text(
                      StringConst.SESION_BUTTON_VOLVER,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.greyTxtAlt,
                          ),
                    ),
                  ),
                  const SizedBox(width: Sizes.PADDING_16),
                  SizedBox(
                    width: 154,
                    height: Sizes.HEIGHT_50,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary400,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Sizes.RADIUS_25),
                        ),
                      ),
                      onPressed: _handleNext,
                      child: Text(StringConst.SESION_BUTTON_SIGUIENTE),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNext() {
    _formKey.currentState?.save();
    widget.onNext(
      ipilContent: _content,
      ipilReinforcement: List<String>.unmodifiable(_reinforcement),
      ipilContextualization: List<String>.unmodifiable(_contextualization),
      ipilConnectionTerritory: List<String>.unmodifiable(_connectionTerritory),
      ipilInterviews: List<String>.unmodifiable(_interviews),
      ipilIntermediations: List<String>.unmodifiable(_intermediations),
      ipilObtainingEmployment: List<String>.unmodifiable(_obtainingEmployment),
      ipilImprovingEmployment: List<String>.unmodifiable(_improvingEmployment),
      ipilCoordination: List<String>.unmodifiable(_coordination),
      ipilLegal: List<String>.unmodifiable(_legal),
      ipilPostWorkSupport: List<String>.unmodifiable(_postWorkSupport),
      ipilEconomicBag: List<String>.unmodifiable(_economicBag),
      ipilSpecificSkills: List<String>.unmodifiable(_specificSkills),
      ipilSoftSkills: List<String>.unmodifiable(_softSkills),
      ipilDigitalSkills: List<String>.unmodifiable(_digitalSkills),
      ipilLaborSkills: List<String>.unmodifiable(_laborSkills),
      ipilInitialInterview: _initialInterview,
      ipilInitialJobValoration: _initialJobValoration,
      ipilFinalInterview: _finalInterview,
      ipilFinalJobValoration: _finalJobValoration,
      ipilOther: _other,
    );
  }

  // ── Multi-select helpers (mirrored from create_ipil_form.dart) ────────

  Widget _buildCachedCheckboxNoTitle({
    required String title,
    required List<dynamic> options,
    required List<String> selectedIds,
    required String Function(dynamic) getId,
    required String Function(dynamic) getLabel,
    required bool cornerTop,
    required bool cornerBottom,
    required void Function(List<String>) onChanged,
  }) {
    if (options.isEmpty) return const SizedBox.shrink();
    final dropdownItems = options
        .map((e) => DropdownItem(
              title: getLabel(e),
              isSelected: selectedIds.contains(getId(e)),
            ))
        .toList();
    return CheckboxDropdownNoTitle(
      title: title,
      options: dropdownItems,
      cornerTop: cornerTop,
      cornerBottom: cornerBottom,
      onTapItem: (value, tapTitle) {
        final match =
            options.where((e) => getLabel(e) == tapTitle).firstOrNull;
        if (match == null) return;
        final id = getId(match);
        final updated = List<String>.from(selectedIds);
        if (value) {
          updated.add(id);
        } else {
          updated.remove(id);
        }
        onChanged(updated);
      },
    );
  }

  Widget _buildCachedCheckbox({
    required String title,
    required List<dynamic> options,
    required List<String> selectedIds,
    required String Function(dynamic) getId,
    required String Function(dynamic) getLabel,
    required void Function(List<String>) onChanged,
  }) {
    if (options.isEmpty) return const SizedBox.shrink();
    final dropdownItems = options
        .map((e) => DropdownItem(
              title: getLabel(e),
              isSelected: selectedIds.contains(getId(e)),
            ))
        .toList();
    return CheckboxDropdown(
      title: title,
      options: dropdownItems,
      onTapItem: (value, tapTitle) {
        final match =
            options.where((e) => getLabel(e) == tapTitle).firstOrNull;
        if (match == null) return;
        final id = getId(match);
        final updated = List<String>.from(selectedIds);
        if (value) {
          updated.add(id);
        } else {
          updated.remove(id);
        }
        onChanged(updated);
      },
    );
  }
}
