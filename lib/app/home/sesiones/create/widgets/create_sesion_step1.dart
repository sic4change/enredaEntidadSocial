import 'package:enreda_empresas/app/common_widgets/custom_text_form_field_title.dart';
import 'package:enreda_empresas/app/home/sesiones/create/widgets/participant_picker.dart';
import 'package:enreda_empresas/app/models/competencySubCategory.dart';
import 'package:enreda_empresas/app/models/sesion.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  required String? observations,
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
    required this.initialObservations,
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
  final String? initialObservations;
  final List<String> initialInvitedParticipants;
  final Step1Submit onNext;

  @override
  State<CreateSesionStep1> createState() => _CreateSesionStep1State();
}

class _CreateSesionStep1State extends State<CreateSesionStep1> {
  final _formKey = GlobalKey<FormState>();

  late String? _title = widget.initialTitle;
  late String _modality = widget.initialModality;
  // Single date picker — Fecha de inicio. Time precision comes from the
  // two TimeOfDay pickers below. Sessions are always timed events
  // (`isAllDay` is hard-coded false) so the gCal compose URL + ICS DTEND
  // get accurate start / end timestamps.
  late DateTime? _scheduledAt = _stripTime(widget.initialScheduledAt);
  // Nullable so the pickers render their hint ("Hora de inicio" /
  // "Hora de fin") on a fresh form instead of seeded defaults. Edit
  // mode round-trips the persisted times.
  late TimeOfDay? _scheduledTime =
      _timeOfDayFromDate(widget.initialScheduledAt);
  late TimeOfDay? _horaFin = _timeOfDayFromDate(widget.initialFechaFin);
  // `isAllDay = false` permanently now — every form submission produces a
  // session with explicit start / end timestamps. Kept as a private
  // constant so the rest of the file (save handler) reads the same way.
  static const bool _isAllDay = false;
  String? _horaInicioError;
  String? _horaFinError;
  String? _fechaError;
  late String? _lugar = widget.initialLugar;
  late bool _createIpil = widget.initialCreateIpil;
  late String _sessionType = widget.initialSessionType;
  late String? _competenciaCategoriaId = widget.initialCompetenciaCategoriaId;
  late String? _competenciaSubCategoriaId =
      widget.initialCompetenciaSubCategoriaId;
  late String? _description = widget.initialDescription;
  late String? _observations = widget.initialObservations;
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
            // ── Top section ─── two stacked columns ─────────────────────
            // LEFT (flex 3): Título on top, then Fecha + 2 Horas underneath.
            // RIGHT (fixed 280): Sesión on top, then Tipo de sesión directly
            // beneath it so the modality toggle aligns vertically with the
            // session-type dropdown.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
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
                            return StringConst
                                .SESION_VALIDATION_TITLE_REQUIRED;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: Sizes.PADDING_20),
                      // Fecha + Hora inicio + Hora fin — all share the same
                      // chrome (white fill, greyUltraLight border, RADIUS_6,
                      // HEIGHT_46) so they read as a unit.
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LabeledBlock(
                            label: StringConst.SESION_FIELD_FECHA_LABEL,
                            child: SizedBox(
                              width: 200,
                              child: _DatePickerField(
                                value: _scheduledAt,
                                errorText: _fechaError,
                                onChanged: (d) => setState(() {
                                  _scheduledAt = _stripTime(d);
                                  _horaFinError = null;
                                  _fechaError = null;
                                }),
                              ),
                            ),
                          ),
                          const SizedBox(width: Sizes.PADDING_20),
                          _LabeledBlock(
                            label: StringConst.SESION_FIELD_HORA_LABEL,
                            child: _TimePickerField(
                              value: _scheduledTime,
                              hint: StringConst.SESION_FIELD_HORA_LABEL,
                              errorText: _horaInicioError,
                              onChanged: (t) => setState(() {
                                _scheduledTime = t;
                                _horaInicioError = null;
                                _horaFinError = null;
                              }),
                            ),
                          ),
                          const SizedBox(width: Sizes.PADDING_20),
                          _LabeledBlock(
                            label: StringConst.SESION_FIELD_HORA_FIN_LABEL,
                            child: _TimePickerField(
                              value: _horaFin,
                              hint: StringConst.SESION_FIELD_HORA_FIN_LABEL,
                              errorText: _horaFinError,
                              onChanged: (t) => setState(() {
                                _horaFin = t;
                                _horaFinError = null;
                              }),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Sizes.PADDING_24),
                SizedBox(
                  width: 280,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LabeledBlock(
                        label: StringConst.SESION_FIELD_SESION_SUBLABEL,
                        child: _BorderedDropdown<String>(
                          value: _sessionType,
                          hint: StringConst.SESION_FIELD_SESION_HINT,
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
                        ),
                      ),
                      const SizedBox(height: Sizes.PADDING_20),
                      _LabeledBlock(
                        label: StringConst.SESION_FIELD_TIPO_LABEL,
                        child: _ModalityToggle(
                          value: _modality,
                          onChanged: (v) =>
                              setState(() => _modality = v),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Sizes.PADDING_20),
            // ── Lugar de la actividad ─ full row ─────────────────────────
            CustomTextFormFieldTitle(
              labelText: StringConst.SESION_FIELD_LUGAR_LABEL,
              initialValue: _lugar,
              onChanged: (v) => _lugar = v,
            ),
            const SizedBox(height: Sizes.PADDING_20),
            // ── Creación de IPIL ─ Sí / No dropdown ──────────────────────
            _LabeledBlock(
              label: StringConst.SESION_FIELD_CREAR_IPIL_LABEL,
              child: _BorderedDropdown<bool>(
                value: _createIpil,
                hint: StringConst.SESION_FIELD_CREAR_IPIL_HINT,
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
              ),
            ),
            const SizedBox(height: Sizes.PADDING_20),
            // ── Competencias section ─────────────────────────────────────
            // One bold section header above three dropdowns (no per-dropdown
            // labels — placeholders inside each box read as the field name).
            Text(
              StringConst.SESION_FIELD_COMPETENCIAS_LABEL,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.greyDark,
                fontWeight: FontWeight.w700,
                fontSize: Sizes.TEXT_SIZE_14,
              ),
            ),
            const SizedBox(height: Sizes.PADDING_8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _CompetenciaCategoriaDropdown(
                    value: _competenciaCategoriaId,
                    onChanged: (id) => setState(() {
                      _competenciaCategoriaId = id;
                      _competenciaSubCategoriaId = null;
                    }),
                  ),
                ),
                const SizedBox(width: Sizes.PADDING_20),
                Expanded(
                  flex: 1,
                  child: _CompetenciaSubCategoriaDropdown(
                    categoriaId: _competenciaCategoriaId,
                    value: _competenciaSubCategoriaId,
                    onChanged: (id) =>
                        setState(() => _competenciaSubCategoriaId = id),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Sizes.PADDING_12),
            // Third Competencias dropdown — TODO: wire to a competency
            // multi-select once product confirms which collection drives it
            // and adds a field to Sesion. Visual placeholder for now so the
            // form matches the Figma layout.
            _BorderedDropdown<String>(
              value: null,
              hint: StringConst.SESION_FIELD_COMPETENCIAS_LABEL,
              items: const <DropdownMenuItem<String>>[],
              onChanged: null,
            ),
            const SizedBox(height: Sizes.PADDING_20),
            // ── Row N: Descripción (wide textarea) + Convocar (list) ─────
            // Fixed-height textarea so the two columns line up visually
            // (the picker's list caps at 280; with label + search the right
            // column is ~340 tall, so we match).
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _LabeledBlock(
                    label: StringConst.SESION_FIELD_DESCRIPTION_LABEL,
                    child: _MultilineField(
                      initialValue: _description,
                      hint: StringConst.SESION_FIELD_DESCRIPTION_HINT,
                      height: 320,
                      onChanged: (v) => _description = v,
                    ),
                  ),
                ),
                const SizedBox(width: Sizes.PADDING_24),
                Expanded(
                  flex: 2,
                  child: _LabeledBlock(
                    label: StringConst.SESION_FIELD_CONVOCAR_LABEL,
                    child: ParticipantPicker(
                      socialEntityId: widget.socialEntityId,
                      entityPrograms: widget.entityPrograms,
                      selectedIds: _invitedIds,
                      singleSelect:
                          _sessionType == SesionType.individual,
                      isGroupSession: _sessionType == SesionType.grupal,
                      onChanged: (ids) =>
                          setState(() => _invitedIds = ids),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Sizes.PADDING_20),
            // ── Observaciones y/o incidencias (full-width textarea) ───────
            // Editable here so staff can add a brief evaluation when reviewing
            // a past session via "Editar" (mirrors the Descripción field).
            _LabeledBlock(
              label: StringConst.SESION_FIELD_OBSERVACIONES_LABEL,
              child: _MultilineField(
                initialValue: _observations,
                hint: StringConst.SESION_FIELD_OBSERVACIONES_HINT,
                height: 160,
                onChanged: (v) => _observations = v,
              ),
            ),
            const SizedBox(height: Sizes.PADDING_30),
            // ── Siguiente ────────────────────────────────────────────────
            Align(
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

    // Required-field checks for the three bespoke pickers (Fecha + 2 Horas).
    // None of them are FormFields, so we surface their errors inline.
    if (_scheduledAt == null) {
      setState(() =>
          _fechaError = StringConst.SESION_VALIDATION_FECHA_REQUIRED);
      return;
    }
    final inicio = _scheduledTime;
    if (inicio == null) {
      setState(() => _horaInicioError =
          StringConst.SESION_VALIDATION_HORA_INICIO_REQUIRED);
      return;
    }
    final fin = _horaFin;
    if (fin == null) {
      setState(() => _horaFinError =
          StringConst.SESION_VALIDATION_HORA_FIN_REQUIRED);
      return;
    }

    // Cross-field validator: Hora de fin must be later than Hora de
    // inicio (same calendar day — multi-day sessions can use the
    // Duración field on the model if needed, but the form treats the
    // event as same-day for now).
    final startMin = inicio.hour * 60 + inicio.minute;
    final endMin = fin.hour * 60 + fin.minute;
    if (endMin <= startMin) {
      setState(() => _horaFinError =
          StringConst.SESION_VALIDATION_HORA_FIN_INVALID);
      return;
    }

    widget.onNext(
      title: _title,
      modality: _modality,
      scheduledAt: _combinedScheduledAt(),
      fechaFin: _combinedFechaFin(),
      isAllDay: _isAllDay,
      lugar: _lugar,
      // Duración no longer surfaces in the form — pass the seed value
      // through unchanged so edits don't clobber any pre-existing free
      // text on the document.
      duracion: widget.initialDuracion,
      createIpil: _createIpil,
      sessionType: _sessionType,
      competenciaCategoriaId: _competenciaCategoriaId,
      competenciaSubCategoriaId: _competenciaSubCategoriaId,
      description: _description,
      observations: _observations,
      invitedParticipants: List<String>.from(_invitedIds),
    );
  }

  /// Combines the picked Fecha de inicio with Hora de inicio. Returns `null`
  /// when either piece is unset — `_onSiguiente` guards against that path so
  /// the parent only ever sees a fully-formed timestamp.
  DateTime? _combinedScheduledAt() {
    final d = _scheduledAt;
    final t = _scheduledTime;
    if (d == null || t == null) return null;
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  /// Combines the picked Fecha de inicio with Hora de fin — assumed to be
  /// the same calendar day. gCal / ICS exports read this directly for
  /// DTEND.
  DateTime? _combinedFechaFin() {
    final d = _scheduledAt;
    final t = _horaFin;
    if (d == null || t == null) return null;
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }
}

/// Strip time component — returns a `DateTime` at midnight of the same day.
/// `null` round-trips as `null`. Used to seed the Fecha de inicio picker.
DateTime? _stripTime(DateTime? d) =>
    d == null ? null : DateTime(d.year, d.month, d.day);

/// Returns the hour/minute of [d] as a [TimeOfDay], or `null` when [d] is
/// `null`. Used to seed the Hora pickers — only edit mode passes a value;
/// fresh forms start empty so the hint stays visible.
TimeOfDay? _timeOfDayFromDate(DateTime? d) =>
    d == null ? null : TimeOfDay(hour: d.hour, minute: d.minute);

/// Read-only field that opens the native [showDatePicker] on tap. Delegates
/// the visual shell to [_PickerBox] so Fecha / Hora inicio / Hora fin all
/// render as identical boxes with a circle-bordered prefix glyph on the left.
/// Renders [errorText] beneath when provided (used for the required-field
/// check on Siguiente).
class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return _PickerBox(
      icon: Icons.calendar_today_outlined,
      hint: StringConst.SESION_FECHA_PICKER_HINT,
      formattedValue:
          value == null ? null : DateFormat('dd/MM/yyyy').format(value!),
      errorText: errorText,
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          locale: const Locale('es', 'ES'),
          initialDate: value ?? now,
          firstDate: DateTime(now.year - 5),
          lastDate: DateTime(now.year + 5),
          builder: (context, child) => Theme(
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
    );
  }
}

/// Read-only field that opens the native [showTimePicker] on tap. Shares the
/// [_PickerBox] chrome with [_DatePickerField].
///
/// [value] is nullable so the picker starts empty on a fresh form — the
/// hint stays visible until the user explicitly picks a time. Renders
/// [errorText] beneath when provided (used by both the required-field
/// check and the Hora-fin-must-exceed-Hora-inicio cross-field validator
/// on Siguiente).
class _TimePickerField extends StatelessWidget {
  const _TimePickerField({
    required this.value,
    required this.hint,
    required this.onChanged,
    this.errorText,
  });

  final TimeOfDay? value;
  final String hint;
  final ValueChanged<TimeOfDay> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: _PickerBox(
        icon: Icons.access_time,
        hint: hint,
        formattedValue: value == null ? null : _formatTime(value!),
        errorText: errorText,
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: value ?? const TimeOfDay(hour: 10, minute: 0),
            builder: (context, child) => Theme(
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
      ),
    );
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

/// Shared visual shell for the date / time pickers.
///
/// Outer pill: white fill, `AppColors.greyUltraLight` (`#D9D9D9`) 1px stroke,
/// `RADIUS_6` corners, `HEIGHT_46` — same chrome as the rest of the form
/// boxes (`CustomTextFormFieldTitle`, etc.).
///
/// Prefix glyph: a 32×32 circle with a 1px greyUltraLight outline and a
/// primary900 icon centred inside — the calendar/clock affordance from the
/// Figma frame.
///
/// Tapping anywhere on the pill fires [onTap]; the parent owns the actual
/// `showDatePicker` / `showTimePicker` invocation so the locale + theme
/// overrides stay in one place.
class _PickerBox extends StatelessWidget {
  const _PickerBox({
    required this.icon,
    required this.hint,
    required this.formattedValue,
    required this.onTap,
    this.errorText,
  });

  final IconData icon;
  final String hint;

  /// `null` (or empty) → render [hint] in the muted dropdown-placeholder colour.
  /// Non-empty → render in `primary900`.
  final String? formattedValue;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasValue =
        formattedValue != null && formattedValue!.isNotEmpty;
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(Sizes.RADIUS_6),
            onTap: onTap,
            child: Container(
              height: Sizes.HEIGHT_46,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(Sizes.RADIUS_6),
                border: Border.all(
                  color:
                      hasError ? AppColors.red : AppColors.greyUltraLight,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.PADDING_6,
              ),
              child: Row(
                children: [
                  Container(
                    width: Sizes.SIZE_32,
                    height: Sizes.SIZE_32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.greyUltraLight,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.primary900,
                      size: Sizes.ICON_SIZE_18,
                    ),
                  ),
                  const SizedBox(width: Sizes.PADDING_12),
                  Expanded(
                    child: Text(
                      hasValue ? formattedValue! : hint,
                      style: textTheme.bodyMedium?.copyWith(
                        color: hasValue
                            ? AppColors.primary900
                            : AppColors.greyDropMenuBorder,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: Sizes.PADDING_4),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: Sizes.PADDING_12),
            child: Text(
              errorText!,
              style:
                  textTheme.bodySmall?.copyWith(color: AppColors.red),
            ),
          ),
        ],
      ],
    );
  }
}

/// Fixed-height multiline textarea — shared by the Descripción and
/// Observaciones fields (same chrome: white fill, greyUltraLight border,
/// RADIUS_6).
class _MultilineField extends StatelessWidget {
  const _MultilineField({
    required this.initialValue,
    required this.hint,
    required this.height,
    required this.onChanged,
  });

  final String? initialValue;
  final String hint;
  final double height;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: height,
      child: TextFormField(
        initialValue: initialValue,
        maxLines: null,
        minLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: textTheme.bodyMedium?.copyWith(color: AppColors.greyDark),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.white,
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.greyDropMenuBorder),
          contentPadding: const EdgeInsets.all(Sizes.PADDING_12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Sizes.RADIUS_6),
            borderSide: const BorderSide(color: AppColors.greyUltraLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Sizes.RADIUS_6),
            borderSide: const BorderSide(color: AppColors.greyUltraLight),
          ),
        ),
        onChanged: onChanged,
      ),
    );
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
/// (CLAUDE.md §0 HIGH strictness). No internal label — sits under the
/// shared "Competencias" section header in the form.
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
    return _BorderedDropdown<String>(
      value: selected,
      hint: StringConst.SESION_FIELD_COMPETENCIA_CAT_LABEL,
      items: items,
      onChanged: onChanged,
    );
  }
}

/// Sub-categoría dropdown — filtered by the currently-selected categoría.
/// Disabled (no onChanged) when no categoría is selected. No internal
/// label — sits under the shared "Competencias" section header.
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
    return _BorderedDropdown<String>(
      value: selected,
      hint: StringConst.SESION_FIELD_COMPETENCIA_SUBCAT_LABEL,
      items: items,
      onChanged: categoriaId == null ? null : onChanged,
    );
  }
}

/// Shared dropdown chrome — matches the natural Material height of
/// `CustomTextFormFieldTitle`'s `TextFormField` (no `isDense`, light content
/// padding) so the Sesión / IPIL / Competencias dropdowns line up vertically
/// with the Título input above them and the rest of the form's text fields.
/// White fill, greyUltraLight border, RADIUS_6.
class _BorderedDropdown<T> extends StatelessWidget {
  const _BorderedDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Drive height via vertical contentPadding — DropdownButtonFormField's
    // InputDecorator computes its own size from its content + padding and
    // ignores outer SizedBox constraints in many cases, so the SizedBox
    // approach left the rendered box unchanged. Bumping the vertical padding
    // directly grows the visible box, matching the height of the Título
    // TextFormField above.
    return DropdownButtonFormField<T>(
      isExpanded: true,
      value: value,
      items: items,
      onChanged: onChanged,
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: AppColors.primary400,
      ),
      style: textTheme.bodySmall?.copyWith(
        color: AppColors.greyDark,
        fontWeight: FontWeight.w400,
        height: 1.5,
        fontSize: Sizes.TEXT_SIZE_14,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.white,
        hintText: hint,
        // Hint must mirror the value `style` line-metrics — without an
        // explicit `height` + `fontSize` on `hintStyle`, the placeholder
        // inherits Material's default and renders off-center vertically
        // inside the box (visible on the IPIL + third-Competencias
        // dropdowns where no value is selected by default).
        hintStyle: textTheme.bodySmall?.copyWith(
          color: AppColors.greyDropMenuBorder,
          fontWeight: FontWeight.w400,
          height: 1.5,
          fontSize: Sizes.TEXT_SIZE_14,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Sizes.PADDING_12,
          vertical: Sizes.PADDING_17_5,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sizes.RADIUS_6),
          borderSide: const BorderSide(color: AppColors.greyUltraLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sizes.RADIUS_6),
          borderSide: const BorderSide(color: AppColors.greyUltraLight),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sizes.RADIUS_6),
          borderSide: const BorderSide(color: AppColors.greyUltraLight),
        ),
      ),
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
