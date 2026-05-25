import 'package:enreda_empresas/app/home/sesiones/create/sesion_draft.dart';
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
import 'package:enreda_empresas/app/models/sesion.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Revisión step (frames `1:1099` with IPIL and `1:1205` without).
///
/// Read-only summary of the draft Sesión. The user reviews and either:
///   * goes back to fix (Volver), or
///   * commits (Guardar) — which triggers `Database.addSesion(...)`.
///
/// Layout: one shadowed card with stacked "Label: value" rows for the core
/// session fields, followed (when `draft.createIpil` is true) by a second
/// card containing the **Detalle IPIL** — section by section, mirroring
/// Figma frame `1:1099`. IDs in the IpilDraft are resolved to display
/// labels via `LocationCache.instance.ipil*` (no Firestore reads).
class CreateSesionRevision extends StatelessWidget {
  const CreateSesionRevision({
    super.key,
    required this.draft,
    required this.saving,
    required this.onBack,
    required this.onSave,
  });

  final SesionDraft draft;
  final bool saving;
  final VoidCallback onBack;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final rows = _buildRows();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Core session readback card ────────────────────────────────
          Container(
            padding: const EdgeInsets.all(Sizes.PADDING_30),
            decoration: BoxDecoration(
              color: AppColors.altWhite,
              borderRadius: BorderRadius.circular(Sizes.RADIUS_16),
              border: Border.all(color: AppColors.greyBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final row in rows) ...[
                  _ReadbackRow(label: row.$1, value: row.$2),
                  const SizedBox(height: Sizes.PADDING_12),
                ],
              ],
            ),
          ),
          // ── IPIL detail card (only when createIpil = true) ────────────
          if (draft.createIpil) ...[
            const SizedBox(height: Sizes.PADDING_20),
            _IpilDetailCard(ipil: draft.ipil),
          ],
          const SizedBox(height: Sizes.PADDING_24),
          // ── Volver / Guardar ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: saving ? null : onBack,
                child: Text(
                  StringConst.SESION_BUTTON_VOLVER,
                  style: textTheme.bodyLarge?.copyWith(
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
                  onPressed: saving ? null : onSave,
                  child: saving
                      ? const SizedBox(
                          width: Sizes.ICON_SIZE_20,
                          height: Sizes.ICON_SIZE_20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          StringConst.SESION_BUTTON_GUARDAR,
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Each row = (label, value). Order mirrors the Figma readback.
  List<(String, String)> _buildRows() {
    return <(String, String)>[
      (StringConst.SESION_FIELD_TITLE_LABEL, draft.title ?? '—'),
      (StringConst.SESION_FIELD_FECHA_LABEL, _formatDate(draft.scheduledAt)),
      (StringConst.SESION_FIELD_TIPO_LABEL, _modalityLabel(draft.modality)),
      (StringConst.SESION_FIELD_LUGAR_LABEL, draft.lugar ?? '—'),
      (StringConst.SESION_FIELD_DURACION_LABEL, draft.duracion ?? '—'),
      (StringConst.SESION_FIELD_SESION_SUBLABEL,
          _sessionTypeLabel(draft.sessionType)),
      (StringConst.SESION_REVISION_PARTICIPANTES, _participantsLabel()),
      (
        StringConst.SESION_FIELD_DESCRIPTION_LABEL,
        (draft.description == null || draft.description!.trim().isEmpty)
            ? '—'
            : draft.description!
      ),
      (
        StringConst.TECHNICAL_NAME,
        (draft.tecnicoName == null || draft.tecnicoName!.trim().isEmpty)
            ? '—'
            : draft.tecnicoName!
      ),
    ];
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    try {
      return DateFormat("d 'de' MMMM yyyy", 'es_ES').format(d);
    } catch (_) {
      return DateFormat('d MMMM yyyy').format(d);
    }
  }

  String _modalityLabel(String m) {
    switch (m) {
      case SesionModality.online:
        return StringConst.SESION_ONLINE_LABEL;
      case SesionModality.blended:
        return StringConst.SESION_BLENDED_LABEL;
      case SesionModality.presencial:
      default:
        return StringConst.SESION_PRESENCIAL_LABEL;
    }
  }

  String _sessionTypeLabel(String t) {
    return t == SesionType.grupal
        ? StringConst.SESION_GRUPAL
        : StringConst.SESION_INDIVIDUAL;
  }

  String _participantsLabel() {
    if (draft.invitedParticipants.isEmpty) {
      return StringConst.SESION_REVISION_NINGUNO;
    }
    final cache = LocationCache.instance;
    final byId = {
      for (final u in cache.allParticipants)
        if (u.userId != null) u.userId!: u,
    };
    final names = draft.invitedParticipants.map((id) {
      final u = byId[id];
      if (u == null) return id;
      final name = '${u.firstName ?? ''} ${u.lastName ?? ''}'.trim();
      return name.isEmpty ? id : name;
    }).join('\n');
    return names.isEmpty ? StringConst.SESION_REVISION_NINGUNO : names;
  }
}

// ── Readback row ──────────────────────────────────────────────────────────

class _ReadbackRow extends StatelessWidget {
  const _ReadbackRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return RichText(
      text: TextSpan(
        style: textTheme.bodyMedium?.copyWith(
          color: AppColors.greyDark,
          fontWeight: FontWeight.w700,
        ),
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
            text: value,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.greyDark,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ── IPIL detail card (Figma frame 1:1099) ─────────────────────────────────

class _IpilDetailCard extends StatelessWidget {
  const _IpilDetailCard({required this.ipil});

  final IpilDraft? ipil;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cache = LocationCache.instance;
    final draft = ipil;

    return Container(
      padding: const EdgeInsets.all(Sizes.PADDING_30),
      decoration: BoxDecoration(
        color: AppColors.altWhite,
        borderRadius: BorderRadius.circular(Sizes.RADIUS_16),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card title
          Text(
            StringConst.SESION_TAB_IPIL,
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.primary900,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Sizes.PADDING_16),

          if (draft == null || draft.isEmpty)
            Text(
              StringConst.SESION_IPIL_EMPTY,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.greyTxtAlt,
                fontStyle: FontStyle.italic,
              ),
            )
          else ...[
            // Seguimiento (content) — long-form text
            if (draft.content != null && draft.content!.trim().isNotEmpty)
              _IpilLongText(
                label: StringConst.GOALS_MONITORING,
                value: draft.content!,
              ),

            // Itinerary: initial
            _IpilBooleanGroup(
              header: StringConst.IPIL_INITIAL_ITINERARY,
              items: [
                if (draft.initialInterview)
                  StringConst.IPIL_INITIAL_INTERVIEW,
                if (draft.initialJobValoration)
                  StringConst.IPIL_INITIAL_QUESTIONARY,
              ],
            ),

            // Itinerary: close
            _IpilBooleanGroup(
              header: StringConst.IPIL_CLOSE_ITINERARY,
              items: [
                if (draft.finalInterview) StringConst.IPIL_CLOSE_INTERVIEW,
                if (draft.finalJobValoration)
                  StringConst.IPIL_CLOSE_QUESTIONARY,
              ],
            ),

            // Fortalecimiento de competencias — header with 4 sub-rows
            _IpilSkillsGroup(
              header: StringConst.IPIL_REINFORCEMENT,
              subSections: [
                (
                  StringConst.IPIL_SPECIFIC_SKILLS,
                  _resolveLabels<IpilSpecificSkills>(
                    draft.specificSkills,
                    cache.ipilSpecificSkills,
                    (e) => e.ipilSpecificSkillsId ?? '',
                    (e) => e.label,
                  ),
                ),
                (
                  StringConst.IPIL_SOFT_SKILLS,
                  _resolveLabels<IpilSoftSkills>(
                    draft.softSkills,
                    cache.ipilSoftSkills,
                    (e) => e.ipilSoftSkillsId ?? '',
                    (e) => e.label,
                  ),
                ),
                (
                  StringConst.IPIL_DIGITAL_SKILLS,
                  _resolveLabels<IpilDigitalSkills>(
                    draft.digitalSkills,
                    cache.ipilDigitalSkills,
                    (e) => e.ipilDigitalSkillsId ?? '',
                    (e) => e.label,
                  ),
                ),
                (
                  StringConst.IPIL_LABOR_SKILLS,
                  _resolveLabels<IpilLaborSkills>(
                    draft.laborSkills,
                    cache.ipilLaborSkills,
                    (e) => e.ipilLaborSkillsId ?? '',
                    (e) => e.label,
                  ),
                ),
              ],
            ),

            // Direct sections (each = label + comma-joined labels)
            _IpilLabelRow(
              label: StringConst.IPIL_CONTEXTUALIZATION,
              labels: _resolveLabels<IpilContextualization>(
                draft.contextualization,
                cache.ipilContextualizations,
                (e) => e.ipilContextualizationId ?? '',
                (e) => e.label,
              ),
            ),
            _IpilLabelRow(
              label: StringConst.IPIL_CONNECTION_TERRITORY,
              labels: _resolveLabels<IpilConnectionTerritory>(
                draft.connectionTerritory,
                cache.ipilConnectionTerritories,
                (e) => e.ipilConnectionTerritoryId ?? '',
                (e) => e.label,
              ),
            ),
            _IpilLabelRow(
              label: StringConst.IPIL_INTERVIEWS,
              labels: _resolveLabels<IpilInterviews>(
                draft.interviews,
                cache.ipilInterviews,
                (e) => e.ipilInterviewsId ?? '',
                (e) => e.label,
              ),
            ),
            _IpilLabelRow(
              label: StringConst.IPIL_INTERMEDIATIONS,
              labels: _resolveLabels<IpilIntermediations>(
                draft.intermediations,
                cache.ipilIntermediations,
                (e) => e.ipilIntermediationsId ?? '',
                (e) => e.label,
              ),
            ),
            _IpilLabelRow(
              label: StringConst.IPIL_OBTAINING_EMPLOYMENT,
              labels: _resolveLabels<IpilObtainingEmployment>(
                draft.obtainingEmployment,
                cache.ipilObtainingEmployments,
                (e) => e.ipilObtainingEmploymentId ?? '',
                (e) => e.label,
              ),
            ),
            _IpilLabelRow(
              label: StringConst.IPIL_IMPROVING_EMPLOYMENT,
              labels: _resolveLabels<IpilImprovingEmployment>(
                draft.improvingEmployment,
                cache.ipilImprovingEmployments,
                (e) => e.ipilImprovingEmploymentId ?? '',
                (e) => e.label,
              ),
            ),
            _IpilLabelRow(
              label: StringConst.IPIL_COORDINATION,
              labels: _resolveLabels<IpilCoordination>(
                draft.coordination,
                cache.ipilCoordinations,
                (e) => e.ipilCoordinationId ?? '',
                (e) => e.label,
              ),
            ),
            _IpilLabelRow(
              label: StringConst.IPIL_LEGAL,
              labels: _resolveLabels<IpilLegal>(
                draft.legal,
                cache.ipilLegals,
                (e) => e.ipilLegalId ?? '',
                (e) => e.label,
              ),
            ),
            _IpilLabelRow(
              label: StringConst.IPIL_POST_WORK_SUPPORT,
              labels: _resolveLabels<IpilPostWorkSupport>(
                draft.postWorkSupport,
                cache.ipilPostWorkSupports,
                (e) => e.ipilPostWorkSupportId ?? '',
                (e) => e.label,
              ),
            ),
            _IpilLabelRow(
              label: StringConst.IPIL_ECONOMIC_BAG,
              labels: _resolveLabels<IpilEconomicBag>(
                draft.economicBag,
                cache.ipilEconomicBags,
                (e) => e.ipilEconomicBagId ?? '',
                (e) => e.label,
              ),
            ),

            // Otros — free-form text
            if (draft.other != null && draft.other!.trim().isNotEmpty)
              _IpilLongText(
                label: StringConst.IPIL_OTHERS,
                value: draft.other!,
              ),
          ],
        ],
      ),
    );
  }

  /// Resolve a list of selected IDs to a comma-joined string of their labels.
  /// Returns an empty list when nothing is selected (caller hides the row).
  static List<String> _resolveLabels<T>(
    List<String> selectedIds,
    List<T> cacheList,
    String Function(T) getId,
    String Function(T) getLabel,
  ) {
    if (selectedIds.isEmpty) return const <String>[];
    final byId = {for (final item in cacheList) getId(item): getLabel(item)};
    return [
      for (final id in selectedIds)
        if (byId.containsKey(id)) byId[id]! else id,
    ];
  }
}

/// One section header with comma-joined value labels. Hidden when empty.
class _IpilLabelRow extends StatelessWidget {
  const _IpilLabelRow({required this.label, required this.labels});

  final String label;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: Sizes.PADDING_12),
      child: _ReadbackRow(label: label, value: labels.join(', ')),
    );
  }
}

/// Itinerary-style header + bullet list. Hidden when [items] is empty.
class _IpilBooleanGroup extends StatelessWidget {
  const _IpilBooleanGroup({required this.header, required this.items});

  final String header;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Sizes.PADDING_12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$header:',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.primary900,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Sizes.PADDING_4),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(left: Sizes.PADDING_12),
              child: Text(
                '• $item',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.greyDark,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Skills group — "Fortalecimiento de las competencias" header followed by
/// 4 sub-rows (specific / soft / digital / labor). Hidden if all 4 are empty.
class _IpilSkillsGroup extends StatelessWidget {
  const _IpilSkillsGroup({required this.header, required this.subSections});

  final String header;
  final List<(String, List<String>)> subSections;

  @override
  Widget build(BuildContext context) {
    final populated =
        subSections.where((s) => s.$2.isNotEmpty).toList(growable: false);
    if (populated.isEmpty) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Sizes.PADDING_12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$header:',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.primary900,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Sizes.PADDING_8),
          for (final (label, labels) in populated)
            Padding(
              padding: const EdgeInsets.only(
                left: Sizes.PADDING_12,
                bottom: Sizes.PADDING_4,
              ),
              child: _ReadbackRow(label: label, value: labels.join(', ')),
            ),
        ],
      ),
    );
  }
}

/// Multi-line text block (Seguimiento, Otros). Hidden when empty.
class _IpilLongText extends StatelessWidget {
  const _IpilLongText({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Sizes.PADDING_12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.primary900,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Sizes.PADDING_4),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.greyDark,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
