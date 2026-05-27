import 'package:enreda_empresas/app/common_widgets/custom_drop_down_button_form_field_title.dart';
import 'package:enreda_empresas/app/home/sesiones/export/sesion_export_pdf.dart';
import 'package:enreda_empresas/app/home/sesiones/widgets/sesion_list_tile.dart';
import 'package:enreda_empresas/app/models/program.dart';
import 'package:enreda_empresas/app/models/sesion.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Exportar view — opened from the Sesion detail page's "Exportar" CTA.
///
/// Layout follows the Figma export frame (loose nodes 1:1828+ on the canvas):
///   • Top: collapsed session info (reuses [SesionListTile])
///   • Left card: read-only Título / Desarrollo / Observaciones
///   • Right card: 6 PARTICIPANTES + Listado + bulk "Seleccionar subvención"
///     dropdown + per-participant row with its own dropdown
///   • Bottom: Cancelar (outlined) + Exportar (filled)
///
/// Subvenciones source: the [SocialEntity]'s `programs` list (program IDs
/// the entity participates in). Programs come from [LocationCache.programs]
/// — zero new Firestore reads.
///
/// On Exportar: persists `_assignments` to `sesion.participantSubvenciones`
/// via [Database.setSesion], then triggers [SesionExportPdf.generate] which
/// opens the platform print/share dialog.
class SesionExportPage extends StatefulWidget {
  const SesionExportPage({
    super.key,
    required this.sesion,
    required this.socialEntity,
    required this.onClose,
  });

  final Sesion sesion;
  final SocialEntity socialEntity;
  final VoidCallback onClose;

  @override
  State<SesionExportPage> createState() => _SesionExportPageState();
}

class _SesionExportPageState extends State<SesionExportPage> {
  late Map<String, String> _assignments;
  String? _bulkSelected;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _assignments = Map<String, String>.from(widget.sesion.participantSubvenciones);
  }

  List<Program> get _availableSubvenciones {
    final entityProgramIds =
        (widget.socialEntity.programs ?? const <String>[]).toSet();
    if (entityProgramIds.isEmpty) return const <Program>[];
    final all = LocationCache.instance.programs;
    return [
      for (final p in all)
        if (p.programId != null && entityProgramIds.contains(p.programId!)) p,
    ];
  }

  void _applyBulk(String? programId) {
    if (programId == null || programId.isEmpty) return;
    setState(() {
      _bulkSelected = programId;
      for (final id in widget.sesion.invitedParticipants) {
        _assignments[id] = programId;
      }
    });
  }

  void _setAssignment(String userId, String? programId) {
    setState(() {
      if (programId == null || programId.isEmpty) {
        _assignments.remove(userId);
      } else {
        _assignments[userId] = programId;
      }
    });
  }

  Future<void> _handleExport() async {
    if (_exporting) return;
    setState(() => _exporting = true);

    final database = Provider.of<Database>(context, listen: false);
    try {
      // 1. Persist subvención assignments.
      final updated = _cloneSesionWithAssignments();
      await database.setSesion(updated);

      // 2. Resolve participants + subvenciones for the PDF (sync from cache).
      final participantsById = <String, UserEnreda>{};
      for (final id in updated.invitedParticipants) {
        final u = LocationCache.instance.userCache[id];
        if (u != null) participantsById[id] = u;
      }
      // Fall back to async fetch for any uncached participant (rare).
      for (final id in updated.invitedParticipants) {
        if (!participantsById.containsKey(id)) {
          final u = await LocationCache.instance.getUser(database, id);
          if (u != null) participantsById[id] = u;
        }
      }
      final subvencionesById = <String, Program>{
        for (final p in _availableSubvenciones)
          if (p.programId != null) p.programId!: p,
      };

      // 3. Generate + present PDF.
      await SesionExportPdf.generate(
        sesion: updated,
        socialEntity: widget.socialEntity,
        participantsById: participantsById,
        subvencionesById: subvencionesById,
      );

      if (!mounted) return;
      setState(() => _exporting = false);
      widget.onClose();
    } catch (e) {
      if (!mounted) return;
      setState(() => _exporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(StringConst.SESION_EXPORT_ERROR),
        ),
      );
    }
  }

  /// Reconstructs the [Sesion] with the new `participantSubvenciones`
  /// assignment (all other fields preserved).
  Sesion _cloneSesionWithAssignments() {
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
      attendedParticipants: s.attendedParticipants,
      absentParticipants: s.absentParticipants,
      title: s.title,
      description: s.description,
      observations: s.observations,
      lugar: s.lugar,
      duracion: s.duracion,
      createIpil: s.createIpil,
      competenciaCategoriaId: s.competenciaCategoriaId,
      competenciaSubCategoriaId: s.competenciaSubCategoriaId,
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
      participantSubvenciones: Map<String, String>.from(_assignments),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isCompact = !Responsive.isDesktop(context);
    final subvenciones = _availableSubvenciones;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? Sizes.PADDING_12 : Sizes.PADDING_30,
        vertical: isMobile ? Sizes.PADDING_16 : Sizes.PADDING_24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(onClose: widget.onClose, isMobile: isMobile),
            SizedBox(height: isMobile ? Sizes.PADDING_12 : Sizes.PADDING_20),
            SesionListTile(sesion: widget.sesion),
            SizedBox(height: isMobile ? Sizes.PADDING_16 : Sizes.PADDING_20),
            if (isCompact) ...[
              _LeftCard(sesion: widget.sesion),
              const SizedBox(height: Sizes.PADDING_20),
              _RightCard(
                sesion: widget.sesion,
                assignments: _assignments,
                bulkSelected: _bulkSelected,
                subvenciones: subvenciones,
                onBulk: _applyBulk,
                onAssign: _setAssignment,
              ),
            ] else
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _LeftCard(sesion: widget.sesion)),
                    const SizedBox(width: Sizes.PADDING_20),
                    Expanded(
                      flex: 1,
                      child: _RightCard(
                        sesion: widget.sesion,
                        assignments: _assignments,
                        bulkSelected: _bulkSelected,
                        subvenciones: subvenciones,
                        onBulk: _applyBulk,
                        onAssign: _setAssignment,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: Sizes.PADDING_24),
            _ActionRow(
              exporting: _exporting,
              onCancel: widget.onClose,
              onExport: _handleExport,
            ),
            const SizedBox(height: Sizes.PADDING_30),
          ],
        ),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onClose, required this.isMobile});
  final VoidCallback onClose;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final back = TextButton.icon(
      onPressed: onClose,
      icon: const Icon(
        Icons.arrow_back,
        color: AppColors.primary900,
        size: Sizes.ICON_SIZE_20,
      ),
      label: Text(
        StringConst.SESIONES,
        style: (isMobile ? textTheme.titleMedium : textTheme.headlineSmall)
            ?.copyWith(color: AppColors.primary900),
      ),
    );
    final title = Text(
      StringConst.SESION_EXPORTAR_TITLE,
      style: (isMobile ? textTheme.bodyLarge : textTheme.titleMedium)?.copyWith(
        color: AppColors.greyTxtAlt,
        fontWeight: FontWeight.w400,
      ),
      overflow: TextOverflow.ellipsis,
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          back,
          Padding(
            padding: const EdgeInsets.only(left: Sizes.PADDING_8),
            child: title,
          ),
        ],
      );
    }
    return Row(
      children: [back, const Spacer(), Flexible(child: title)],
    );
  }
}

// ── Left card ──────────────────────────────────────────────────────────────

class _LeftCard extends StatelessWidget {
  const _LeftCard({required this.sesion});
  final Sesion sesion;

  String _titleFor() {
    if (sesion.title != null && sesion.title!.trim().isNotEmpty) {
      return sesion.title!;
    }
    return sesion.sessionType == SesionType.grupal
        ? StringConst.SESION_GRUPAL
        : StringConst.SESION_INDIVIDUAL;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Sizes.RADIUS_16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary900.withOpacity(0.1),
            blurRadius: Sizes.PADDING_20,
          ),
        ],
      ),
      padding: const EdgeInsets.all(Sizes.PADDING_30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _titleFor(),
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.primary900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Sizes.PADDING_22),
          _Section(
            header: StringConst.SESION_DETAIL_DESARROLLO,
            body: sesion.description,
            fallback: StringConst.SESION_EXPORT_NO_DESARROLLO,
          ),
          const SizedBox(height: Sizes.PADDING_22),
          _Section(
            header: StringConst.SESION_DETAIL_OBSERVACIONES,
            body: sesion.observations,
            fallback: StringConst.SESION_EXPORT_NO_OBSERVACIONES,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.header,
    required this.body,
    required this.fallback,
  });
  final String header;
  final String? body;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.greyTxtAlt,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: Sizes.PADDING_8),
        Text(
          (body == null || body!.trim().isEmpty) ? fallback : body!,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.greyTxtAlt,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

// ── Right card ─────────────────────────────────────────────────────────────

class _RightCard extends StatelessWidget {
  const _RightCard({
    required this.sesion,
    required this.assignments,
    required this.bulkSelected,
    required this.subvenciones,
    required this.onBulk,
    required this.onAssign,
  });

  final Sesion sesion;
  final Map<String, String> assignments;
  final String? bulkSelected;
  final List<Program> subvenciones;
  final ValueChanged<String?> onBulk;
  final void Function(String userId, String? programId) onAssign;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final invited = sesion.invitedParticipants;
    final hasSubvenciones = subvenciones.isNotEmpty;
    final dropdownItems = <DropdownMenuItem<String>>[
      for (final p in subvenciones)
        if (p.programId != null)
          DropdownMenuItem<String>(value: p.programId, child: Text(p.name)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Sizes.RADIUS_16),
        border: Border.all(color: AppColors.greyBorder),
      ),
      padding: const EdgeInsets.all(Sizes.PADDING_24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${invited.length} ${StringConst.SESION_DETAIL_PARTICIPANTES_HEADER}',
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.primary900,
            ),
          ),
          const SizedBox(height: Sizes.PADDING_8),
          Text(
            StringConst.SESION_DETAIL_PARTICIPANTES_HELPER,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.greyTxtAlt,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: Sizes.PADDING_20),
          Text(
            StringConst.SESION_EXPORT_LISTADO_PARTICIPANTES,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.primary900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Sizes.PADDING_12),
          if (!hasSubvenciones)
            _NoSubvencionesMessage()
          else ...[
            CustomDropDownButtonFormFieldTittle(
              labelText: StringConst.SESION_EXPORT_SELECCIONAR_SUBVENCION,
              hintText: StringConst.SESION_EXPORT_SELECCIONA_OPCION,
              value: dropdownItems.any((i) => i.value == bulkSelected)
                  ? bulkSelected
                  : null,
              source: dropdownItems,
              onChanged: onBulk,
            ),
            const SizedBox(height: Sizes.PADDING_16),
            const Divider(height: 1, color: AppColors.greyBorder),
            const SizedBox(height: Sizes.PADDING_12),
            for (final id in invited)
              _ParticipantSubvencionRow(
                userId: id,
                value: assignments[id],
                dropdownItems: dropdownItems,
                onChanged: (v) => onAssign(id, v),
              ),
          ],
        ],
      ),
    );
  }
}

class _NoSubvencionesMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.PADDING_12),
      child: Text(
        StringConst.SESION_EXPORT_NO_SUBVENCIONES,
        style: textTheme.bodyMedium?.copyWith(
          color: AppColors.greyTxtAlt,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class _ParticipantSubvencionRow extends StatelessWidget {
  const _ParticipantSubvencionRow({
    required this.userId,
    required this.value,
    required this.dropdownItems,
    required this.onChanged,
  });

  final String userId;
  final String? value;
  final List<DropdownMenuItem<String>> dropdownItems;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Sizes.PADDING_8),
      child: FutureBuilder<UserEnreda?>(
        future: LocationCache.instance.getUser(database, userId),
        builder: (context, snapshot) {
          // FutureBuilder state handling (CLAUDE.md §10):
          //   waiting → "Cargando..." placeholder
          //   error / null → "(Sin nombre)" fallback
          //   data → resolved name
          final isWaiting = snapshot.connectionState == ConnectionState.waiting
              && !snapshot.hasData;
          final u = snapshot.data;
          final name = isWaiting
              ? StringConst.SESION_PICKER_LOADING
              : (snapshot.hasError || u == null
                  ? StringConst.SESION_PICKER_UNKNOWN_USER
                  : '${u.firstName ?? ''} ${u.lastName ?? ''}'.trim());
          final displayName =
              name.isEmpty ? StringConst.SESION_PICKER_UNKNOWN_USER : name;
          final effectiveValue =
              dropdownItems.any((i) => i.value == value) ? value : null;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  displayName,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary900,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: Sizes.PADDING_8),
              Expanded(
                flex: 4,
                child: CustomDropDownButtonFormFieldTittle(
                  labelText: '',
                  hintText:
                      StringConst.SESION_EXPORT_PLACEHOLDER_SELECCIONAR,
                  value: effectiveValue,
                  source: dropdownItems,
                  onChanged: onChanged,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Action row ─────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.exporting,
    required this.onCancel,
    required this.onExport,
  });

  final bool exporting;
  final VoidCallback onCancel;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Wrap(
      spacing: Sizes.PADDING_16,
      runSpacing: Sizes.PADDING_12,
      alignment: WrapAlignment.end,
      children: [
        SizedBox(
          width: 154,
          height: Sizes.HEIGHT_50,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.greyTxtAlt,
              side: const BorderSide(color: AppColors.greyBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Sizes.RADIUS_25),
              ),
            ),
            onPressed: exporting ? null : onCancel,
            child: Text(
              StringConst.SESION_BUTTON_CANCELAR,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.greyTxtAlt,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
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
            onPressed: exporting ? null : onExport,
            child: exporting
                ? const SizedBox(
                    width: Sizes.ICON_SIZE_20,
                    height: Sizes.ICON_SIZE_20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : Text(
                    StringConst.SESION_BUTTON_EXPORTAR,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
