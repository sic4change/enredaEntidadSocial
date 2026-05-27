import 'package:enreda_empresas/app/common_widgets/custom_date_picker_open.dart';
import 'package:enreda_empresas/app/common_widgets/custom_drop_down_button_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_form_field_title.dart';
import 'package:enreda_empresas/app/home/sesiones/create/widgets/participant_picker.dart';
import 'package:enreda_empresas/app/models/competencyCategory.dart';
import 'package:enreda_empresas/app/models/competencySubCategory.dart';
import 'package:enreda_empresas/app/models/sesion.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

/// Callback signature emitted by Step 1 on a valid Siguiente tap. The parent
/// flow widget consumes this and either jumps to the IPIL stub or Revisión.
typedef Step1Submit = void Function({
  required String? title,
  required String modality,
  required DateTime? scheduledAt,
  required DateTime? fechaFin,
  required bool isAllDay,
  required String? lugar,
  required String? duracion,
  required bool createIpil,
  required String sessionType,
  required String? competenciaCategoriaId,
  required String? competenciaSubCategoriaId,
  required String? description,
  required List<String> invitedParticipants,
});

/// Step 1 of the Crear Nueva Sesión flow (frame `1:321`).
///
/// All form widgets are existing `common_widgets/` primitives —
/// `CustomTextFormFieldTitle`, `CustomDatePickerTitleClosed`, and Material's
/// `Switch` / `DropdownButtonFormField`. The ONLINE/PRESENCIAL toggle and
/// step pills inherit the same active/inactive pattern as the list view.
class CreateSesionStep1 extends StatefulWidget {
  const CreateSesionStep1({
    super.key,
    required this.socialEntityId,
    required this.entityPrograms,
    required this.initialTitle,
    required this.initialModality,
    required this.initialScheduledAt,
    required this.initialFechaFin,
    required this.initialIsAllDay,
    required this.initialLugar,
    required this.initialDuracion,
    required this.initialCreateIpil,
    required this.initialSessionType,
    required this.initialCompetenciaCategoriaId,
    required this.initialCompetenciaSubCategoriaId,
    required this.initialDescription,
    required this.initialInvitedParticipants,
    required this.onNext,
  });

  final String socialEntityId;
  final List<String> entityPrograms;
  final String? initialTitle;
  final String initialModality;
  final DateTime? initialScheduledAt;
  final DateTime? initialFechaFin;
  final bool initialIsAllDay;
  final String? initialLugar;
  final String? initialDuracion;
  final bool initialCreateIpil;
  final String initialSessionType;
  final String? initialCompetenciaCategoriaId;
  final String? initialCompetenciaSubCategoriaId;
  final String? initialDescription;
  final List<String> initialInvitedParticipants;
  final Step1Submit onNext;

  @override
  State<CreateSesionStep1> createState() => _CreateSesionStep1State();
}

class _CreateSesionStep1State extends State<CreateSesionStep1> {
  final _formKey = GlobalKey<FormState>();

  late String? _title = widget.initialTitle;
  late String _modality = widget.initialModality;
  late DateTime? _scheduledAt = _stripTime(widget.initialScheduledAt);
  // User-picked Fecha de fin is treated as INCLUSIVE last day of the event.
  // Storage in `Sesion.fechaFin` keeps the EXCLUSIVE convention (+1 day) —
  // see `_combinedFechaFin()` for save and `_initFechaFinForPicker` for load.
  late DateTime? _fechaFin = _initFechaFinForPicker(
    widget.initialFechaFin,
    widget.initialIsAllDay,
  );
  // The new Figma layout drops Hora de inicio / Hora de fin / Todo el día
  // and treats every session as all-day under the hood. Keeping the field
  // as a private constant so validators + save logic read the same way as
  // before; flipping back to `false` would require restoring time pickers,
  // which we explicitly removed per "mimic the attached image".
  static const bool _isAllDay = true;
  String? _fechaFinError;
  late String? _lugar = widget.initialLugar;
  late String? _duracion = widget.initialDuracion;
  late bool _createIpil = widget.initialCreateIpil;
  late String _sessionType = widget.initialSessionType;
  late String? _competenciaCategoriaId = widget.initialCompetenciaCategoriaId;
  late String? _competenciaSubCategoriaId =
      widget.initialCompetenciaSubCategoriaId;
  late String? _description = widget.initialDescription;
  late List<String> _invitedIds =
      List<String>.from(widget.initialInvitedParticipants);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: Sizes.PADDING_30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextFormFieldTitle(
              labelText: StringConst.SESION_FIELD_TITLE_LABEL,
              hintText: StringConst.SESION_FIELD_TITLE_HINT,
              initialValue: _title,
              onChanged: (v) => _title = v,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return StringConst.SESION_VALIDATION_TITLE_REQUIRED;
                }
                return null;
              },
            ),
            const SizedBox(height: Sizes.PADDING_20),
            // Fecha (with Fecha de inicio + Fecha de fin) on the LEFT,
            // Tipo de sesión on the RIGHT — matches the Figma layout.
            // Wrap rather than Row so on narrow viewports the right column
            // drops below the left without overflowing.
            Wrap(
              spacing: Sizes.PADDING_24,
              runSpacing: Sizes.PADDING_20,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                _LabeledBlock(
                  label: StringConst.SESION_FIELD_FECHA_LABEL,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 200,
                        child: CustomDatePickerTitleOpen(
                          labelText: StringConst.SESION_FIELD_FECHA_INICIO_LABEL,
                          initialValue: _scheduledAt,
                          onChanged: (d) => setState(() {
                            _scheduledAt = _stripTime(d);
                            _fechaFinError = null;
                          }),
                          validator: (d) {
                            if (d == null) {
                              return StringConst
                                  .SESION_VALIDATION_FECHA_REQUIRED;
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: Sizes.PADDING_12),
                      SizedBox(
                        width: 200,
                        child: CustomDatePickerTitleOpen(
                          labelText: StringConst.SESION_FIELD_FECHA_FIN_LABEL,
                          initialValue: _fechaFin,
                          onChanged: (d) => setState(() {
                            _fechaFin = _stripTime(d);
                            _fechaFinError = null;
                          }),
                          validator: (d) {
                            if (d == null) {
                              return StringConst
                                  .SESION_VALIDATION_FECHA_REQUIRED;
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                _LabeledBlock(
                  label: StringConst.SESION_FIELD_TIPO_LABEL,
                  child: _ModalityToggle(
                    value: _modality,
                    onChanged: (v) => setState(() => _modality = v),
                  ),
                ),
              ],
            ),
            if (_fechaFinError != null) ...[
              const SizedBox(height: Sizes.PADDING_8),
              Text(
                _fechaFinError!,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.deleteRed,
                ),
              ),
            ],
            const SizedBox(height: Sizes.PADDING_20),
            // Lugar + Duración row — image splits roughly 60/40.
            Wrap(
              spacing: Sizes.PADDING_24,
              runSpacing: Sizes.PADDING_20,
              children: [
                SizedBox(
                  width: 420,
                  child: CustomTextFormFieldTitle(
                    labelText: StringConst.SESION_FIELD_LUGAR_LABEL,
                    initialValue: _lugar,
                    onChanged: (v) => _lugar = v,
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: CustomTextFormFieldTitle(
                    labelText: StringConst.SESION_FIELD_DURACION_LABEL,
                    initialValue: _duracion,
                    onChanged: (v) => _duracion = v,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Sizes.PADDING_20),
            // Creación de IPIL — Sí / No dropdown per the Figma chevron
            // visual. Was a Switch.adaptive; semantics are still boolean
            // but the picker rhythm matches the rest of the form.
            _LabeledBlock(
              label: StringConst.SESION_FIELD_CREAR_IPIL_LABEL,
              child: DropdownButtonFormField<bool>(
                value: _createIpil,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary900,
                  fontWeight: FontWeight.w500,
                ),
                items: const [
                  DropdownMenuItem(
                    value: false,
                    child: Text(StringConst.SESION_FIELD_CREAR_IPIL_NO),
                  ),
                  DropdownMenuItem(
                    value: true,
                    child: Text(StringConst.SESION_FIELD_CREAR_IPIL_SI),
                  ),
                ],
                onChanged: (v) => setState(() => _createIpil = v ?? false),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: AppColors.white,
                  hintText: StringConst.SESION_FIELD_CREAR_IPIL_HINT,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.greyBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary500),
                  ),
                ),
              ),
            ),
            const SizedBox(height: Sizes.PADDING_20),
            // Convocar participantes (left) + Sesión (right) — same row in
            // the Figma. Wrap so it stacks gracefully on narrow viewports.
            Wrap(
              spacing: Sizes.PADDING_24,
              runSpacing: Sizes.PADDING_20,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                SizedBox(
                  width: 420,
                  child: _LabeledBlock(
                    label: StringConst.SESION_FIELD_CONVOCAR_LABEL,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          StringConst.SESION_FIELD_CONVOCAR_HINT,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.greyTxtAlt,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: Sizes.PADDING_8),
                        ParticipantPicker(
                          socialEntityId: widget.socialEntityId,
                          entityPrograms: widget.entityPrograms,
                          selectedIds: _invitedIds,
                          singleSelect:
                              _sessionType == SesionType.individual,
                          onChanged: (ids) =>
                              setState(() => _invitedIds = ids),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: _LabeledBlock(
                    label: StringConst.SESION_FIELD_SESION_SUBLABEL,
                    child: DropdownButtonFormField<String>(
                      value: _sessionType,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary900,
                        fontWeight: FontWeight.w500,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: SesionType.individual,
                          child: Text(StringConst.SESION_INDIVIDUAL),
                        ),
                        DropdownMenuItem(
                          value: SesionType.grupal,
                          child: Text(StringConst.SESION_GRUPAL),
                        ),
                      ],
                      onChanged: (v) => setState(() {
                        _sessionType = v ?? SesionType.individual;
                        if (_sessionType == SesionType.individual &&
                            _invitedIds.length > 1) {
                          _invitedIds = [_invitedIds.last];
                        }
                      }),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: AppColors.white,
                        hintText: StringConst.SESION_FIELD_SESION_HINT,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.greyBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary500),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Sizes.PADDING_20),
            // Competencias — cascading dropdowns sourced from LocationCache.
            _CompetenciaCategoriaDropdown(
              value: _competenciaCategoriaId,
              onChanged: (id) => setState(() {
                _competenciaCategoriaId = id;
                _competenciaSubCategoriaId = null;
              }),
            ),
            const SizedBox(height: Sizes.PADDING_16),
            _CompetenciaSubCategoriaDropdown(
              categoriaId: _competenciaCategoriaId,
              value: _competenciaSubCategoriaId,
              onChanged: (id) => setState(() => _competenciaSubCategoriaId = id),
            ),
            const SizedBox(height: Sizes.PADDING_20),
            // Descripción — multi-line textarea
            _LabeledBlock(
              label: StringConst.SESION_FIELD_DESCRIPTION_LABEL,
              child: TextFormField(
                initialValue: _description,
                maxLines: 5,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.greyDark,
                ),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: AppColors.white,
                  hintText: StringConst.SESION_FIELD_DESCRIPTION_HINT,
                  contentPadding: EdgeInsets.all(Sizes.PADDING_12),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.greyBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary500),
                  ),
                ),
                onChanged: (v) => _description = v,
              ),
            ),
            const SizedBox(height: Sizes.PADDING_30),
            Align(
              // Centred per Figma layout — was right-aligned previously.
              alignment: Alignment.center,
              child: SizedBox(
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
                  onPressed: _onSiguiente,
                  child: Text(
                    StringConst.SESION_BUTTON_SIGUIENTE,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSiguiente() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    // Cross-field validator: Fecha de fin must be on or after Fecha de
    // inicio. Both are user-picked INCLUSIVE dates; same-day pick = a
    // single-day event.
    if (_scheduledAt != null && _fechaFin != null) {
      if (_fechaFin!.isBefore(_scheduledAt!)) {
        setState(() => _fechaFinError =
            StringConst.SESION_VALIDATION_FECHA_FIN_INVALID);
        return;
      }
    }

    widget.onNext(
      title: _title,
      modality: _modality,
      scheduledAt: _combinedScheduledAt(),
      fechaFin: _combinedFechaFin(),
      isAllDay: _isAllDay,
      lugar: _lugar,
      duracion: _duracion,
      createIpil: _createIpil,
      sessionType: _sessionType,
      competenciaCategoriaId: _competenciaCategoriaId,
      competenciaSubCategoriaId: _competenciaSubCategoriaId,
      description: _description,
      invitedParticipants: List<String>.from(_invitedIds),
    );
  }

  /// Returns the picked date stripped to its day (time component zeroed).
  /// The new form is date-only — every session is persisted as all-day.
  DateTime? _combinedScheduledAt() => _stripTime(_scheduledAt);

  /// User-picked `_fechaFin` is INCLUSIVE (the last day of the event);
  /// `Sesion.fechaFin` stores the EXCLUSIVE convention used by gCal /
  /// RFC 5545 (the day AFTER the last day). Add 1 day on save and the
  /// existing exports read it as-is.
  DateTime? _combinedFechaFin() {
    final d = _fechaFin;
    if (d == null) return null;
    return DateTime(d.year, d.month, d.day).add(const Duration(days: 1));
  }
}

/// Strip time component — returns a `DateTime` at midnight of the same day.
/// `null` round-trips as `null`.
DateTime? _stripTime(DateTime? d) =>
    d == null ? null : DateTime(d.year, d.month, d.day);

/// Seeds the "Fecha de fin" picker from the persisted `Sesion.fechaFin`.
/// The model stores EXCLUSIVE end (day AFTER the event) for all-day
/// sessions; convert back to the INCLUSIVE last day for display. For
/// legacy sessions saved with a specific time (isAllDay=false), strip
/// the time and use the date as-is — the new form has no time pickers.
DateTime? _initFechaFinForPicker(DateTime? stored, bool storedIsAllDay) {
  if (stored == null) return null;
  final dateOnly = DateTime(stored.year, stored.month, stored.day);
  if (storedIsAllDay) {
    return dateOnly.subtract(const Duration(days: 1));
  }
  return dateOnly;
}

class _LabeledBlock extends StatelessWidget {
  const _LabeledBlock({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.greyDark,
            fontWeight: FontWeight.w700,
            fontSize: Sizes.TEXT_SIZE_14,
          ),
        ),
        const SizedBox(height: Sizes.PADDING_8),
        child,
      ],
    );
  }
}

/// Categoría dropdown sourced from `LocationCache.competencyCategories`.
/// Static collection — must come from the cache, never via a fresh stream
/// (CLAUDE.md §0 HIGH strictness).
class _CompetenciaCategoriaDropdown extends StatelessWidget {
  const _CompetenciaCategoriaDropdown({
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final categories = LocationCache.instance.competencyCategories;
    final items = <DropdownMenuItem<String>>[
      for (final c in categories)
        if (c.competencyCategoryId != null)
          DropdownMenuItem<String>(
            value: c.competencyCategoryId,
            child: Text(c.name),
          ),
    ];
    // Defensive fallback — if the cache is unexpectedly empty (e.g. warm-up
    // failed silently) we still render a usable, validating widget. The
    // user can still proceed with no selection; the field is optional.
    final selected = items.any((i) => i.value == value) ? value : null;
    return CustomDropDownButtonFormFieldTittle(
      labelText: StringConst.SESION_FIELD_COMPETENCIA_CAT_LABEL,
      hintText: StringConst.SESION_FIELD_COMPETENCIA_CAT_HINT,
      value: selected,
      source: items,
      onChanged: onChanged,
    );
  }
}

/// Sub-categoría dropdown — filtered by the currently-selected categoría.
/// Disabled (single placeholder item) when no categoría is selected.
class _CompetenciaSubCategoriaDropdown extends StatelessWidget {
  const _CompetenciaSubCategoriaDropdown({
    required this.categoriaId,
    required this.value,
    required this.onChanged,
  });

  final String? categoriaId;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final allSubs = LocationCache.instance.competencySubCategories;
    final filtered = (categoriaId == null)
        ? const <CompetencySubCategory>[]
        : allSubs
            .where((s) => s.competencyCategoryId == categoriaId)
            .toList(growable: false);
    final items = <DropdownMenuItem<String>>[
      for (final s in filtered)
        if (s.competencySubCategoryId != null)
          DropdownMenuItem<String>(
            value: s.competencySubCategoryId,
            child: Text(s.name),
          ),
    ];
    final selected = items.any((i) => i.value == value) ? value : null;
    // Hint message switches with state so the user knows *why* the dropdown
    // is empty or disabled — the colleague reported confusion about whether
    // this field even existed.
    final String hint;
    if (categoriaId == null) {
      hint = StringConst.SESION_FIELD_COMPETENCIA_SUBCAT_HINT_DISABLED;
    } else if (items.isEmpty) {
      hint = StringConst.SESION_FIELD_COMPETENCIA_SUBCAT_HINT_EMPTY;
    } else {
      hint = StringConst.SESION_FIELD_COMPETENCIA_SUBCAT_HINT_PICK;
    }
    return CustomDropDownButtonFormFieldTittle(
      labelText: StringConst.SESION_FIELD_COMPETENCIA_SUBCAT_LABEL,
      hintText: hint,
      value: selected,
      source: items,
      onChanged: categoriaId == null ? null : onChanged,
    );
  }
}

/// ONLINE / PRESENCIAL pill toggle. Visual contract matches the list-view
/// status chip (white text on `primary900` when selected) but here both
/// sides are tappable.
class _ModalityToggle extends StatelessWidget {
  const _ModalityToggle({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Sizes.PADDING_8,
      children: [
        _pill(context, SesionModality.online,
            StringConst.SESION_ONLINE_LABEL),
        _pill(context, SesionModality.presencial,
            StringConst.SESION_PRESENCIAL_LABEL),
      ],
    );
  }

  Widget _pill(BuildContext context, String mod, String label) {
    final textTheme = Theme.of(context).textTheme;
    final selected = value == mod;
    return InkWell(
      borderRadius: BorderRadius.circular(Sizes.RADIUS_20),
      onTap: () => onChanged(mod),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.PADDING_16,
          vertical: Sizes.PADDING_8,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary900 : AppColors.white,
          borderRadius: BorderRadius.circular(Sizes.RADIUS_20),
          border: Border.all(color: AppColors.primary900, width: 1),
        ),
        child: Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: selected ? AppColors.white : AppColors.primary900,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
