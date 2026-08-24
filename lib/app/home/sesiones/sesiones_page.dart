import 'dart:async';

import 'package:enreda_empresas/app/common_widgets/alert_dialog.dart';
import 'package:enreda_empresas/app/home/resources/global.dart' as globals;
import 'package:enreda_empresas/app/home/sesiones/calendar/sesion_calendar_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:enreda_empresas/app/home/sesiones/create/create_sesion_flow_page.dart';
import 'package:enreda_empresas/app/home/sesiones/detail/sesion_detail_page.dart';
import 'package:enreda_empresas/app/home/sesiones/export/sesion_export_page.dart';
import 'package:enreda_empresas/app/home/sesiones/widgets/sesion_list_tile.dart';
import 'package:enreda_empresas/app/models/sesion.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Admin Dashboard "Sesiones" page — list of Próximas / Pasadas sesiones,
/// with a CTA to create a new one.
///
/// Layout follows the Figma `1:545` (Próximas) and `1:94` (Pasadas) frames.
/// Per product decision the Pasadas list view mirrors the Próximas list
/// structure (no separate compact Pasadas frame exists in Figma yet).
class SesionesPage extends StatefulWidget {
  const SesionesPage({super.key, required this.socialEntity});

  final SocialEntity socialEntity;

  @override
  State<SesionesPage> createState() => _SesionesPageState();
}

class _SesionesPageState extends State<SesionesPage> {
  _SesionesTab _activeTab = _SesionesTab.proximas;
  bool _misSesiones = false; // off = all group + my own; on = filter to mine only
  _Mode _mode = _Mode.list;
  Sesion? _viewingSesion;
  Sesion? _editingSesion;
  Sesion? _exportingSesion;

  /// Tracks whether we've already kicked off the participant-cache load so we
  /// don't re-issue the request every time `didChangeDependencies` fires
  /// (e.g. on theme / locale changes). The call itself is idempotent inside
  /// `LocationCache`, but skipping the no-op keeps the build path quiet.
  bool _participantsLoadKicked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _kickParticipantCacheLoad();
  }

  /// Kicks the bulk participants load so that individual-session rows can
  /// resolve their invitee's display name on first render. Without this, the
  /// row's `_participantsLabel` falls back to a count placeholder until the
  /// detail page (or another feature) happens to warm the cache.
  ///
  /// LocationCache short-circuits when the scope (`socialEntityId` + programs)
  /// is unchanged, so this is safe to call on every dependency change — but
  /// we additionally gate behind `_participantsLoadKicked` to avoid the
  /// Provider lookup on subsequent rebuilds.
  void _kickParticipantCacheLoad() {
    if (_participantsLoadKicked) return;
    _participantsLoadKicked = true;
    final database = Provider.of<Database>(context, listen: false);
    LocationCache.instance.loadAllParticipants(
      database,
      widget.socialEntity.socialEntityId ?? '',
      widget.socialEntity.programs ?? const <String>[],
    );
  }

  void _showCreate() => setState(() {
        _mode = _Mode.form;
        _editingSesion = null;
      });

  void _showCalendar() => setState(() => _mode = _Mode.calendar);

  void _showExport(Sesion s) => setState(() {
        _mode = _Mode.exporting;
        _exportingSesion = s;
      });

  /// Confirmation dialog → hard-delete via [Database.deleteSesion].
  /// The list stream auto-removes the row when the deletion lands.
  Future<void> _confirmAndDelete(Sesion s) async {
    final database = Provider.of<Database>(context, listen: false);
    final go = await showAlertDialog(
      context,
      title: StringConst.SESION_DELETE_CONFIRM_TITLE,
      content: StringConst.SESION_DELETE_CONFIRM_BODY,
      defaultActionText: StringConst.SESION_DELETE_CONFIRM_DEFAULT,
      cancelActionText: StringConst.SESION_DELETE_CONFIRM_CANCEL,
    );
    if (go != true || !mounted) return;
    try {
      await database.deleteSesion(s);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(StringConst.SESION_DELETE_SUCCESS)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(StringConst.SESION_DELETE_ERROR)),
      );
    }
  }

  /// Toggles the current user's id in/out of [Sesion.reminderUserIds].
  /// Optimistic write via [Database.setSesion]; the stream will reflect the
  /// new state on next emit. The actual notification scheduling is left to
  /// a follow-up — this commits intent only.
  Future<void> _toggleReminder(Sesion s) async {
    final database = Provider.of<Database>(context, listen: false);
    final me = globals.currentSocialEntityUser?.userId ?? '';
    if (me.isEmpty) return;
    final next = List<String>.from(s.reminderUserIds);
    final nowOn = !next.contains(me);
    if (nowOn) {
      next.add(me);
    } else {
      next.remove(me);
    }
    try {
      await database.setSesion(_cloneSesionWithReminders(s, next));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(nowOn
              ? StringConst.SESION_REMINDER_ON
              : StringConst.SESION_REMINDER_OFF),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(StringConst.SESION_REMINDER_ERROR)),
      );
    }
  }

  /// Round-trips every Sesion field, only swapping out [reminderUserIds].
  /// Mirrors the pattern used by the detail page's `_buildUpdatedSesion`.
  Sesion _cloneSesionWithReminders(Sesion s, List<String> reminders) {
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
      participantSubvenciones: s.participantSubvenciones,
      reminderUserIds: reminders,
    );
  }

  void _showDetail(Sesion s) => setState(() {
        _mode = _Mode.detail;
        _viewingSesion = s;
      });

  void _showEdit(Sesion s) => setState(() {
        _mode = _Mode.form;
        _editingSesion = s;
      });

  void _returnToList() => setState(() {
        _mode = _Mode.list;
        _viewingSesion = null;
        _editingSesion = null;
        _exportingSesion = null;
      });

  @override
  Widget build(BuildContext context) {
    if (_mode == _Mode.form) {
      return CreateSesionFlowPage(
        socialEntity: widget.socialEntity,
        initialSesion: _editingSesion,
        onClose: _returnToList,
      );
    }
    if (_mode == _Mode.detail && _viewingSesion != null) {
      return SesionDetailPage(
        initialSesion: _viewingSesion!,
        onClose: _returnToList,
        onEdit: _showEdit,
        onExport: _showExport,
      );
    }
    if (_mode == _Mode.calendar) {
      return SesionCalendarPage(
        socialEntity: widget.socialEntity,
        onTapSesion: _showDetail,
        onClose: _returnToList,
      );
    }
    if (_mode == _Mode.exporting && _exportingSesion != null) {
      return SesionExportPage(
        sesion: _exportingSesion!,
        socialEntity: widget.socialEntity,
        onClose: _returnToList,
      );
    }

    final textTheme = Theme.of(context).textTheme;
    final database = Provider.of<Database>(context, listen: false);
    final socialEntityId = widget.socialEntity.socialEntityId ?? '';
    final isMobile = Responsive.isMobile(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? Sizes.PADDING_16 : Sizes.PADDING_30,
        vertical: Sizes.PADDING_24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderRow(
            isMobile: isMobile,
            onCreate: _showCreate,
            onCalendar: _showCalendar,
          ),
          const SizedBox(height: Sizes.PADDING_24),
          _TabBar(
            activeTab: _activeTab,
            onSelect: (tab) => setState(() => _activeTab = tab),
            misSesiones: _misSesiones,
            onToggleMis: () => setState(() => _misSesiones = !_misSesiones),
            entityName: widget.socialEntity.name ?? '',
          ),
          const SizedBox(height: Sizes.PADDING_30),
          Text(
            _activeTab == _SesionesTab.proximas
                ? StringConst.SESIONES_PROXIMAS
                : StringConst.SESIONES_PASADAS,
            style: textTheme.headlineMedium?.copyWith(
              color: AppColors.primary900,
            ),
          ),
          const SizedBox(height: Sizes.PADDING_20),
          Expanded(
            child: _SesionesList(
              stream: _activeTab == _SesionesTab.proximas
                  ? database.sesionesProximasStream(socialEntityId)
                  : database.sesionesPasadasStream(socialEntityId),
              emptyMessage: _activeTab == _SesionesTab.proximas
                  ? StringConst.SESION_EMPTY_PROXIMAS
                  : StringConst.SESION_EMPTY_PASADAS,
              onTapSesion: _showDetail,
              onEditSesion: _showEdit,
              onDeleteSesion: _confirmAndDelete,
              onExportSesion: _showExport,
              onToggleReminder: _toggleReminder,
              isProximas: _activeTab == _SesionesTab.proximas,
              misSesiones: _misSesiones,
            ),
          ),
        ],
      ),
    );
  }
}

enum _SesionesTab { proximas, pasadas }

enum _Mode { list, form, detail, calendar, exporting }

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.isMobile,
    required this.onCreate,
    required this.onCalendar,
  });

  final bool isMobile;
  final VoidCallback onCreate;
  final VoidCallback onCalendar;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final title = Text(
      StringConst.SESIONES,
      style: textTheme.headlineSmall?.copyWith(color: AppColors.primary900),
    );

    final calendarBtn = TextButton.icon(
      onPressed: onCalendar,
      icon: const Icon(
        Icons.calendar_month_outlined,
        color: AppColors.primary900,
        size: Sizes.ICON_SIZE_24,
      ),
      label: Text(
        StringConst.CALENDARIO_BUTTON_LABEL,
        style: textTheme.bodyLarge?.copyWith(
          color: AppColors.primary900,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.PADDING_12,
          vertical: Sizes.PADDING_8,
        ),
      ),
    );

    // Pill-shaped CTA matching the updated Figma frame: primary500 fill, label
    // "Crear nueva sesión" (bodyLarge w600), and the trailing `cta_plus.svg`
    // at its native 50×50 so its yellow disc (r=25) aligns flush with the
    // button's right rounded corner (RADIUS_25).
    final cta = FilledButton(
      onPressed: onCreate,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary500,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.RADIUS_25),
        ),
        padding: const EdgeInsets.only(
          left: Sizes.PADDING_24,
          right: Sizes.PADDING_0,
          top: Sizes.PADDING_0,
          bottom: Sizes.PADDING_0,
        ),
        minimumSize: const Size(0, Sizes.HEIGHT_50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            StringConst.CREAR_NUEVA_SESION,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: Sizes.PADDING_8),
          SvgPicture.asset(
            ImagePath.SESIONES_ICON_CTA_PLUS,
            width: Sizes.ICON_SIZE_50,
            height: Sizes.ICON_SIZE_50,
          ),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [title, const Spacer(), calendarBtn]),
          const SizedBox(height: Sizes.PADDING_12),
          cta,
        ],
      );
    }

    return Row(
      children: [
        title,
        const Spacer(),
        calendarBtn,
        const SizedBox(width: Sizes.PADDING_12),
        cta,
      ],
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.activeTab,
    required this.onSelect,
    required this.misSesiones,
    required this.onToggleMis,
    required this.entityName,
  });

  final _SesionesTab activeTab;
  final ValueChanged<_SesionesTab> onSelect;
  final bool misSesiones;
  final VoidCallback onToggleMis;
  final String entityName;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Sizes.PADDING_20,
      runSpacing: Sizes.PADDING_12,
      children: [
        _SesionTabPill(
          label: StringConst.SESIONES_PROXIMAS,
          isActive: activeTab == _SesionesTab.proximas,
          onTap: () => onSelect(_SesionesTab.proximas),
        ),
        _SesionTabPill(
          label: StringConst.SESIONES_PASADAS,
          isActive: activeTab == _SesionesTab.pasadas,
          onTap: () => onSelect(_SesionesTab.pasadas),
        ),
        // Content filter, same pill UI, as two mutually-exclusive pills:
        // entity name = shared view (group sessions + my own individual),
        // "Mis sesiones" = only my own (group + individual). Brand teal
        // (not yellow) so it reads as a different filter axis than the
        // Próximas/Pasadas tabs.
        _SesionTabPill(
          label: entityName,
          isActive: !misSesiones,
          onTap: () {
            if (misSesiones) onToggleMis();
          },
          activeColor: AppColors.primaryColor,
        ),
        _SesionTabPill(
          label: StringConst.SESION_FILTER_MIS,
          isActive: misSesiones,
          onTap: () {
            if (!misSesiones) onToggleMis();
          },
          activeColor: AppColors.primaryColor,
        ),
      ],
    );
  }
}

/// **Justified new widget (§11 Step 3):** `CustomChip` hardcodes its selected
/// text color to `AppColors.greyChip` (#F5F5F5). The Sesiones tab pill needs
/// `AppColors.primary900` text on `AppColors.yellow` when active — incompatible
/// with the current `CustomChip` contract. Extending `CustomChip` with a new
/// `selectedTextColor` parameter would touch every existing caller (participants
/// filter, role filter, multi-select rows, etc.) — higher risk for a single
/// new use case. Keeping this private to the Sesiones feature contains the
/// new behaviour.
class _SesionTabPill extends StatelessWidget {
  const _SesionTabPill({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.activeColor = AppColors.yellow,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(Sizes.RADIUS_25),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.PADDING_30,
          vertical: Sizes.PADDING_12,
        ),
        decoration: BoxDecoration(
          color: isActive ? activeColor : AppColors.white,
          borderRadius: BorderRadius.circular(Sizes.RADIUS_25),
          border: Border.all(
            color: isActive ? activeColor : AppColors.violet,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: textTheme.bodyLarge?.copyWith(
            color:
                isActive ? AppColors.primary900 : AppColors.greyTxtAlt,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// Stateful so it can subscribe to [LocationCache.paginationUpdates] and
/// trigger row rebuilds when paginated participant data lands. Without that,
/// `SesionListTile._participantsLabel` for individual sessions would show
/// "1 participante" until something else in the app warmed the cache.
///
/// Why not a nested `StreamBuilder<void>`? The §8 anti-patterns table calls
/// out nested StreamBuilders explicitly — flattening to a single subscription
/// keeps the existing sesion stream as the only `StreamBuilder` in the tree.
class _SesionesList extends StatefulWidget {
  const _SesionesList({
    required this.stream,
    required this.emptyMessage,
    required this.onTapSesion,
    required this.onEditSesion,
    required this.onDeleteSesion,
    required this.onExportSesion,
    required this.onToggleReminder,
    required this.isProximas,
    required this.misSesiones,
  });

  final Stream<List<Sesion>> stream;
  final String emptyMessage;
  final ValueChanged<Sesion> onTapSesion;
  final ValueChanged<Sesion> onEditSesion;
  final ValueChanged<Sesion> onDeleteSesion;
  final ValueChanged<Sesion> onExportSesion;
  final ValueChanged<Sesion> onToggleReminder;
  final bool isProximas;
  final bool misSesiones;

  @override
  State<_SesionesList> createState() => _SesionesListState();
}

class _SesionesListState extends State<_SesionesList> {
  StreamSubscription<void>? _participantsSub;

  @override
  void initState() {
    super.initState();
    // Each pagination tick fires when `LocationCache.allParticipants` grows.
    // We just need to bump the build counter so the visible row tiles re-run
    // `_participantsLabel` against the freshly populated cache.
    _participantsSub =
        LocationCache.instance.paginationUpdates.listen((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _participantsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = globals.currentSocialEntityUser?.userId ?? '';
    return StreamBuilder<List<Sesion>>(
      stream: widget.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ErrorState(error: snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final raw = snapshot.data ?? <Sesion>[];
        // Default view = every entity GROUP session (any técnico) + my own
        // individual sessions; other técnicos' individual sessions stay private.
        // "Mis sesiones" is a filter on top — narrows to my own (group +
        // individual). Filtered client-side.
        final items = widget.misSesiones
            ? raw.where((s) => s.tecnicoId == currentUserId).toList()
            : raw
                .where((s) =>
                    s.sessionType == SesionType.grupal ||
                    s.tecnicoId == currentUserId)
                .toList();
        if (items.isEmpty) {
          return _EmptyState(message: widget.emptyMessage);
        }
        // Individual session cards per Figma — each SesionListTile owns
        // its own shadowed white card with breathing space between rows.
        // Reverted the shared-container experiment (commit e28f9f3) at the
        // user's request: the new mockup keeps cards standalone.
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: Sizes.PADDING_24),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final s = items[index];
            return SesionListTile(
              sesion: s,
              onTap: () => widget.onTapSesion(s),
              onEdit: () => widget.onEditSesion(s),
              showEditPill: widget.isProximas,
              onDelete:
                  widget.isProximas ? () => widget.onDeleteSesion(s) : null,
              onExport: () => widget.onExportSesion(s),
              onToggleReminder: widget.isProximas
                  ? () => widget.onToggleReminder(s)
                  : null,
              reminderEnabled: s.reminderUserIds.contains(currentUserId),
              showReminder: widget.isProximas,
              expandable: true,
            );
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.PADDING_30),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(color: AppColors.greyTxtAlt),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.PADDING_30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.deleteRed,
              size: Sizes.ICON_SIZE_60,
            ),
            const SizedBox(height: Sizes.PADDING_16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.greyTxtAlt,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
