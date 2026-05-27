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
  late DateTime? _scheduledAt = widget.initialScheduledAt;
  late bool _isAllDay = widget.initialIsAllDay;
  late TimeOfDay _scheduledTime = _scheduledAtToTimeOfDay(
    widget.initialScheduledAt,
    widget.initialIsAllDay,
  );
  // Hora de fin defaults to 1 hour after the start when no fechaFin was
  // provided (i.e. a fresh "Crear nueva sesión" flow). In edit mode we
  // seed from the existing `fechaFin` so the user sees their saved value.
  late TimeOfDay _fechaFinTime = _fechaFinToTimeOfDay(
    widget.initialFechaFin,
    widget.initialScheduledAt,
    widget.initialIsAllDay,
  );
  String? _horaFinError;
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
            // Tipo de sesión + Fecha row — Wrap so it stacks on narrow viewports
            Wrap(
              spacing: Sizes.PADDING_24,
              runSpacing: Sizes.PADDING_20,
              children: [
                _LabeledBlock(
                  label: StringConst.SESION_FIELD_TIPO_LABEL,
                  child: _ModalityToggle(
                    value: _modality,
                    onChanged: (v) => setState(() => _modality = v),
                  ),
                ),
                _LabeledBlock(
                  label: StringConst.SESION_FIELD_FECHA_LABEL,
                  child: SizedBox(
                    width: 320,
                    child: CustomDatePickerTitleOpen(
                      labelText: '',
                      initialValue: _scheduledAt,
                      onChanged: (d) => setState(() => _scheduledAt = d),
                      validator: (d) {
                        if (d == null) {
                          return StringConst.SESION_VALIDATION_FECHA_REQUIRED;
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                // Hora de inicio + Hora de fin (hidden when Todo el día).
                // Same-day end is the common case; when the técnica needs a
                // multi-day session she can mark "Todo el día" or extend
                // the duration field. Once the model gains a separate
                // `fechaFin` date picker (per sesiones-correcciones-figma
                // item #5), this row becomes Fecha de inicio + Fecha de fin.
                if (!_isAllDay) ...[
                  _LabeledBlock(
                    label: StringConst.SESION_FIELD_HORA_LABEL,
                    child: _TimePickerField(
                      value: _scheduledTime,
                      onChanged: (t) {
                        setState(() {
                          _scheduledTime = t;
                          _horaFinError = null;
                        });
                      },
                    ),
                  ),
                  _LabeledBlock(
                    label: StringConst.SESION_FIELD_HORA_FIN_LABEL,
                    child: _TimePickerField(
                      value: _fechaFinTime,
                      errorText: _horaFinError,
                      onChanged: (t) {
                        setState(() {
                          _fechaFinTime = t;
                          _horaFinError = null;
                        });
                      },
                    ),
                  ),
                ],
                // Todo el día toggle — when on, time picker is hidden and
                // session sorts to the top of its day in the calendar.
                _LabeledBlock(
                  label: StringConst.SESION_FIELD_TODO_EL_DIA,
                  child: Switch.adaptive(
                    value: _isAllDay,
                    activeColor: AppColors.primary400,
                    onChanged: (v) => setState(() => _isAllDay = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Sizes.PADDING_20),
            // Lugar + Duración row
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
            // Creación de IPIL toggle
            _LabeledBlock(
              label: StringConst.SESION_FIELD_CREAR_IPIL_LABEL,
              child: Switch.adaptive(
                value: _createIpil,
                activeColor: AppColors.primary400,
                onChanged: (v) => setState(() => _createIpil = v),
              ),
            ),
            const SizedBox(height: Sizes.PADDING_20),
            // Convocar participantes — searchable multi-select picker
            // (Figma overlay 1:493). Reads participants from LocationCache —
            // never opens a fresh stream per CLAUDE.md §0 HIGH strictness.
            _LabeledBlock(
              label: StringConst.SESION_FIELD_CONVOCAR_LABEL,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    StringConst.SESION_FIELD_CONVOCAR_HINT,
                    // Bumped from bodySmall to bodyMedium per Figma
                    // correction #6 — the previous Inter 14 was too small
                    // to read comfortably under the section label.
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
                    singleSelect: _sessionType == SesionType.individual,
                    onChanged: (ids) => setState(() => _invitedIds = ids),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Sizes.PADDING_20),
            // Sesión sub-field: Individual / Grupal dropdown
            _LabeledBlock(
              label: StringConst.SESION_FIELD_SESION_SUBLABEL,
              child: SizedBox(
                width: 320,
                child: DropdownButtonFormField<String>(
                  value: _sessionType,
                  // Shrink selected-value typography to bodyMedium (Inter 16)
                  // per Figma correction #7 — the default Material dropdown
                  // style rendered "Sesión grupal" oversized vs the rest of
                  // the form labels.
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
                    // When switching to individual mode, keep only the last
                    // selected participant (most recently added) so the list
                    // never exceeds 1 entry.
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
            const SizedBox(height: Sizes.PADDING_20),
            // Competencias — cascading dropdowns sourced from LocationCache.
            // Categoría drives the Sub categoría filter (CompetencySubCategory
            // entries are filtered by competencyCategoryId).
            _CompetenciaCategoriaDropdown(
              value: _competenciaCategoriaId,
              onChanged: (id) => setState(() {
                _competenciaCategoriaId = id;
                // Reset sub-category when category changes — keeps the
                // dropdown legal (sub-category options depend on category).
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
              alignment: Alignment.centerRight,
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

    // Cross-field validator: Hora de fin must be later than Hora de inicio
    // when the session has a specific hour (not all-day). Same-day end is
    // the supported case for now — see step1 comment for the multi-day
    // future direction.
    if (!_isAllDay) {
      final startMin = _scheduledTime.hour * 60 + _scheduledTime.minute;
      final endMin = _fechaFinTime.hour * 60 + _fechaFinTime.minute;
      if (endMin <= startMin) {
        setState(() =>
            _horaFinError = StringConst.SESION_VALIDATION_HORA_FIN_INVALID);
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

  /// Combines [_scheduledAt] (date) and [_scheduledTime] (time) into a single
  /// DateTime. When [_isAllDay] is true the time component is forced to
  /// midnight so legacy queries against `scheduledAt` (year/month/day) stay
  /// consistent.
  DateTime? _combinedScheduledAt() {
    final d = _scheduledAt;
    if (d == null) return null;
    if (_isAllDay) {
      return DateTime(d.year, d.month, d.day);
    }
    return DateTime(
      d.year,
      d.month,
      d.day,
      _scheduledTime.hour,
      _scheduledTime.minute,
    );
  }

  /// Returns the end DateTime — same calendar day as the start, with the
  /// chosen `_fechaFinTime`. For all-day sessions returns the next day at
  /// midnight (matching gCal's exclusive-end convention).
  DateTime? _combinedFechaFin() {
    final d = _scheduledAt;
    if (d == null) return null;
    if (_isAllDay) {
      return DateTime(d.year, d.month, d.day).add(const Duration(days: 1));
    }
    return DateTime(
      d.year,
      d.month,
      d.day,
      _fechaFinTime.hour,
      _fechaFinTime.minute,
    );
  }
}

/// Seeds the time-of-day picker from an existing `scheduledAt` (edit mode)
/// or defaults to 10:00 for new sessions. Returns midnight when [isAllDay].
TimeOfDay _scheduledAtToTimeOfDay(DateTime? scheduledAt, bool isAllDay) {
  if (isAllDay) return const TimeOfDay(hour: 0, minute: 0);
  if (scheduledAt == null) return const TimeOfDay(hour: 10, minute: 0);
  return TimeOfDay(hour: scheduledAt.hour, minute: scheduledAt.minute);
}

/// Seeds the "Hora de fin" picker. Priority:
///   1. The persisted `fechaFin` time (edit mode).
///   2. One hour after the persisted `scheduledAt` (edit mode, no fechaFin).
///   3. Default 11:00 (one hour after the default 10:00 start).
TimeOfDay _fechaFinToTimeOfDay(
  DateTime? fechaFin,
  DateTime? scheduledAt,
  bool isAllDay,
) {
  if (isAllDay) return const TimeOfDay(hour: 0, minute: 0);
  if (fechaFin != null) {
    return TimeOfDay(hour: fechaFin.hour, minute: fechaFin.minute);
  }
  if (scheduledAt != null) {
    final plusHour = scheduledAt.add(const Duration(hours: 1));
    return TimeOfDay(hour: plusHour.hour, minute: plusHour.minute);
  }
  return const TimeOfDay(hour: 11, minute: 0);
}

/// Read-only text field that opens the native [showTimePicker] on tap.
/// Mirrors the visual chrome of `CustomDatePickerTitleOpen` so the Fecha /
/// Hora pair reads as a unit. Renders [errorText] beneath when provided.
class _TimePickerField extends StatelessWidget {
  const _TimePickerField({
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final TimeOfDay value;
  final ValueChanged<TimeOfDay> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: 180,
      child: InkWell(
        borderRadius: BorderRadius.circular(Sizes.RADIUS_8),
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: value,
            builder: (context, child) => Theme(
              // Match the brand palette on the picker chrome.
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: AppColors.primary400,
                      onPrimary: AppColors.white,
                      onSurface: AppColors.primary900,
                    ),
              ),
              child: child!,
            ),
          );
          if (picked != null) onChanged(picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            isDense: true,
            hintText: StringConst.SESION_HORA_PICKER_HINT,
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Sizes.PADDING_12,
              vertical: Sizes.PADDING_12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Sizes.RADIUS_8),
              borderSide: const BorderSide(color: AppColors.greyBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Sizes.RADIUS_8),
              borderSide: const BorderSide(color: AppColors.greyBorder),
            ),
            suffixIcon: const Icon(
              Icons.access_time,
              color: AppColors.primary400,
              size: Sizes.ICON_SIZE_20,
            ),
          ),
          child: Text(
            _formatTime(value),
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.primary900,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
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
