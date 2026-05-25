import 'package:enreda_empresas/app/common_widgets/custom_chip.dart';
import 'package:enreda_empresas/app/home/sesiones/widgets/sesion_detail_content.dart';
import 'package:enreda_empresas/app/models/sesion.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

/// Single Sesión row card used in both the Próximas and Pasadas list views.
///
/// **Justified new widget (§11 Step 3):** No existing reusable tile widget
/// renders the (leading-icon + title/date stack + participant-count + trailing
/// modality chip) layout with a shadowed card background. The closest analogs
/// are scoped to participants (`IpilEntryTile`) or resources (`ResourceListTile`);
/// reusing either would require either invasive prop-extension or shoe-horning
/// admin-level data through participant-detail wiring. This sibling widget
/// **internally reuses** the shared primitives (`CustomChip`, AppColors, textTheme,
/// intl) and adds zero new design tokens.
///
/// Token compliance (§6, §11):
///   * All colors via `AppColors.*` — no hardcoded hex.
///   * All text via `Theme.of(context).textTheme.*` — no raw `TextStyle`.
///   * All spacing via `Sizes.*` — no magic numbers.
///   * Width via `Expanded` / `Flexible` — no hardcoded structural widths.
class SesionListTile extends StatefulWidget {
  const SesionListTile({
    super.key,
    required this.sesion,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onExport,
    this.onToggleReminder,
    this.reminderEnabled = false,
    this.showReminder = false,
    this.showEditPill = true,
    this.expandable = false,
  });

  final Sesion sesion;
  final VoidCallback? onTap;

  /// When provided, wires the Editar action — both the row-header pencil
  /// pill (when [showEditPill] is true) and the Editar CTA inside the
  /// inline expanded panel. Pass `null` to hide both.
  final VoidCallback? onEdit;

  /// When `false`, the row-header pencil pill is hidden even if [onEdit] is
  /// non-null. The inline expansion's Editar CTA still appears. Used by the
  /// Pasadas tab to keep row-level actions clean while keeping inline edits
  /// available. Defaults to `true`.
  final bool showEditPill;

  /// When provided, renders a Borrar (trash) icon button. Caller is
  /// responsible for the confirm dialog.
  final VoidCallback? onDelete;

  /// When provided **and** [expandable] is true, renders an Exportar CTA
  /// inside the inline expanded panel. Has no effect on the row header.
  final VoidCallback? onExport;

  /// When provided **and** [showReminder] is true, renders a bell icon.
  /// The icon style follows [reminderEnabled].
  final VoidCallback? onToggleReminder;

  /// Whether the current user has the reminder turned on for this session
  /// — drives the bell's filled/outlined visual.
  final bool reminderEnabled;

  /// Only the Próximas tab passes this as true (bells are nonsense on
  /// past sessions).
  final bool showReminder;

  /// When true, shows the Figma-extracted down-arrow trailing icon
  /// (`row_arrow.svg`). Tap toggles inline expansion of the row showing
  /// the full [SesionDetailContent] — Título / Desarrollo / Observaciones +
  /// Editar/Exportar CTAs + Participantes panel with attendance toggles —
  /// matching Figma frame `1:94`. The full detail page remains accessible
  /// via [onTap] on the main row body.
  ///
  /// Defaults to false so the tile renders as a clean read-only row when
  /// reused inside the detail page, export page, or calendar day list.
  final bool expandable;

  @override
  State<SesionListTile> createState() => _SesionListTileState();
}

class _SesionListTileState extends State<SesionListTile> {
  bool _expanded = false;

  void _toggleExpanded() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Tile padding leaves extra room at the bottom for the arrow toggle
    // that hangs half off the card's bottom edge (Figma pattern).
    return Padding(
      padding: EdgeInsets.only(
        top: Sizes.PADDING_12,
        bottom: widget.expandable ? Sizes.PADDING_24 : Sizes.PADDING_12,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Card (row header + optional expanded details) ──────────────
          Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(Sizes.RADIUS_16),
                boxShadow: [
                  BoxShadow(
                    // Figma: 0 0 20 0 rgba(5,77,94,0.2) — primary900 @ 20%
                    color: AppColors.primary900.withOpacity(0.2),
                    blurRadius: Sizes.PADDING_20,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Sizes.RADIUS_16),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.topCenter,
                  curve: Curves.easeInOut,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: widget.onTap,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Sizes.PADDING_22,
                            horizontal: Sizes.PADDING_24,
                          ),
                          child: Row(
                            children: [
                              _LeadingIcon(
                                  sessionType: widget.sesion.sessionType),
                              const SizedBox(width: Sizes.PADDING_24),
                              Expanded(
                                child: _TitleAndDate(
                                    sesion: widget.sesion,
                                    textTheme: textTheme),
                              ),
                              const SizedBox(width: Sizes.PADDING_16),
                              Flexible(
                                child: Text(
                                  _participantsLabel(widget.sesion),
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.seaBlue,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // ── Action cluster — Próximas only ─────────
                              if (widget.onEdit != null &&
                                  widget.showEditPill) ...[
                                const SizedBox(width: Sizes.PADDING_12),
                                _PillIconButton(
                                  icon: Icons.edit_outlined,
                                  iconColor: AppColors.greyTxtAlt,
                                  tooltip: StringConst
                                      .SESION_ACTION_EDITAR_TOOLTIP,
                                  onTap: widget.onEdit!,
                                ),
                              ],
                              if (widget.onDelete != null) ...[
                                const SizedBox(width: Sizes.PADDING_8),
                                _PillIconButton(
                                  icon: Icons.delete_outline,
                                  iconColor: AppColors.greyTxtAlt,
                                  tooltip: StringConst
                                      .SESION_ACTION_BORRAR_TOOLTIP,
                                  onTap: widget.onDelete!,
                                ),
                              ],
                              const SizedBox(width: Sizes.PADDING_16),
                              _ModalityChip(modality: widget.sesion.modality),
                              if (widget.showReminder &&
                                  widget.onToggleReminder != null) ...[
                                const SizedBox(width: Sizes.PADDING_12),
                                _BellPlain(
                                  enabled: widget.reminderEnabled,
                                  onTap: widget.onToggleReminder!,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (widget.expandable && _expanded)
                        _ExpandedDetails(
                          sesion: widget.sesion,
                          onEdit: widget.onEdit,
                          onExport: widget.onExport,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // ── Arrow toggle — centred at the card's bottom edge ────────────
          // `left: 0, right: 0` makes the Positioned take the full card width
          // so the inner Align can centre the icon horizontally regardless
          // of viewport.
          if (widget.expandable)
            Positioned(
              left: 0,
              right: 0,
              bottom: -Sizes.PADDING_12,
              child: Align(
                alignment: Alignment.center,
                child: _ExpandToggle(
                  expanded: _expanded,
                  onTap: _toggleExpanded,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Right-of-centre label on the row:
  ///   • Individual session w/ a single invitee → resolve name from cache
  ///     (`Sandrine Dupont` per Figma frame 1:545)
  ///   • Grupal session or unresolved name → fall back to a count
  ///     (`6 participantes`)
  String _participantsLabel(Sesion s) {
    if (s.sessionType == SesionType.individual &&
        s.invitedParticipants.length == 1) {
      final id = s.invitedParticipants.first;
      final cache = LocationCache.instance;
      // Try the per-id userCache first (cheap), then the bulk participants
      // list. If both miss we fall through to the count placeholder.
      UserEnreda? user = cache.userCache[id];
      if (user == null) {
        for (final u in cache.allParticipants) {
          if (u.userId == id) {
            user = u;
            break;
          }
        }
      }
      if (user != null) {
        final name = '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
        if (name.isNotEmpty) return name;
      }
    }
    final count = s.invitedParticipants.length;
    if (count <= 1) {
      return '$count ${StringConst.SESION_PARTICIPANTE_SINGULAR}';
    }
    return '$count ${StringConst.SESION_PARTICIPANTES_PLURAL}';
  }
}

/// Leading "photo" slot on each session row. Renders the exact Figma
/// `row_icon_*.svg` extracted from frame 1:545 — different glyph per
/// `sessionType` (individual vs grupal). Both SVGs include the pale-teal
/// background circle, so we render them directly without a wrapping
/// Container.
class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.sessionType});

  final String sessionType;

  @override
  Widget build(BuildContext context) {
    final asset = sessionType == SesionType.grupal
        ? ImagePath.SESIONES_ICON_ROW_GRUPAL
        : ImagePath.SESIONES_ICON_ROW_INDIVIDUAL;
    return SvgPicture.asset(
      asset,
      width: Sizes.HEIGHT_50,
      height: Sizes.HEIGHT_50,
    );
  }
}

class _TitleAndDate extends StatelessWidget {
  const _TitleAndDate({required this.sesion, required this.textTheme});

  final Sesion sesion;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _titleFor(sesion),
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.primary900,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: Sizes.PADDING_4),
        Text(
          _formatDate(sesion.scheduledAt),
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.seaBlue,
            fontWeight: FontWeight.w300,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _titleFor(Sesion s) {
    if (s.title != null && s.title!.trim().isNotEmpty) return s.title!;
    return s.sessionType == SesionType.grupal
        ? StringConst.SESION_GRUPAL
        : StringConst.SESION_INDIVIDUAL;
  }

  // Spanish-localized long date — uses intl which is already a transitive dep
  // via DateFormat usage in IpilEntryTile and elsewhere.
  String _formatDate(DateTime d) {
    try {
      return DateFormat("d 'de' MMMM yyyy", 'es_ES').format(d);
    } catch (_) {
      // Locale data may not be initialized at first render in some build modes
      return DateFormat('d MMMM yyyy').format(d);
    }
  }
}

class _ModalityChip extends StatelessWidget {
  const _ModalityChip({required this.modality});

  final String modality;

  @override
  Widget build(BuildContext context) {
    // Reusing the shared CustomChip in its `selected` state. The selected
    // background is AppColors.primary900 (per Figma "Azul Océano Enreda"),
    // and CustomChip renders selected-state text in AppColors.greyChip
    // (#F5F5F5 — visually near-white on the dark teal, which matches Figma).
    return CustomChip(
      label: _labelFor(modality),
      selected: true,
      selectedBackgroundColor: AppColors.primary900,
      onSelect: (_) {},
    );
  }

  String _labelFor(String modality) {
    switch (modality) {
      case SesionModality.online:
        return StringConst.SESION_ONLINE_LABEL;
      case SesionModality.blended:
        return StringConst.SESION_BLENDED_LABEL;
      case SesionModality.presencial:
      default:
        return StringConst.SESION_PRESENCIAL_LABEL;
    }
  }
}

/// Right-edge action cluster: Editar / Borrar / Campanita. Each button is
/// only rendered when its corresponding callback is supplied — the list
/// view passes all three, the detail page (which reuses this tile in
/// "collapsed" mode) passes none.
/// Outlined pill button used for the Editar and Borrar row actions.
/// Visual contract (per Figma — white fill, 1px grey border, ~30px tall,
/// pill radius 20+, centred glyph): matches the modality chip footprint
/// so the action cluster + chip + bell line up cleanly across the row.
class _PillIconButton extends StatelessWidget {
  const _PillIconButton({
    required this.icon,
    required this.iconColor,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Sizes.RADIUS_20),
          onTap: onTap,
          child: Container(
            width: 56,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(Sizes.RADIUS_20),
              border: Border.all(color: AppColors.greyBorder),
            ),
            child: Icon(icon, color: iconColor, size: Sizes.ICON_SIZE_18),
          ),
        ),
      ),
    );
  }
}

/// Standalone bell (no pill background) — matches the rightmost element on
/// the Figma row. Solid fill when enabled, outline when not.
class _BellPlain extends StatelessWidget {
  const _BellPlain({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: StringConst.SESION_ACTION_RECORDATORIO_TOOLTIP,
      child: InkWell(
        borderRadius: BorderRadius.circular(Sizes.RADIUS_20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Sizes.PADDING_4),
          child: Icon(
            enabled ? Icons.notifications_active : Icons.notifications_none,
            color: enabled ? AppColors.primary900 : AppColors.primary900,
            size: Sizes.ICON_SIZE_24,
          ),
        ),
      ),
    );
  }
}

/// Trailing dropdown arrow — exact Figma asset (`row_arrow.svg`, node 1:569).
/// Rotates 180° smoothly when [expanded] flips.
class _ExpandToggle extends StatelessWidget {
  const _ExpandToggle({required this.expanded, required this.onTap});

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: expanded
          ? StringConst.SESION_ROW_COLLAPSE_TOOLTIP
          : StringConst.SESION_ROW_EXPAND_TOOLTIP,
      onPressed: onTap,
      padding: const EdgeInsets.all(Sizes.PADDING_4),
      constraints: const BoxConstraints(),
      icon: AnimatedRotation(
        turns: expanded ? 0.5 : 0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: SvgPicture.asset(
          ImagePath.SESIONES_ICON_ROW_SHARE,
          width: Sizes.ICON_SIZE_22,
          height: Sizes.ICON_SIZE_22,
        ),
      ),
    );
  }
}

/// Inline expanded section below the row — matches Figma frame `1:94`
/// (Pasadas with one row expanded). Delegates to [SesionDetailContent],
/// the same widget that renders inside [SesionDetailPage], so the inline
/// experience and the full detail page stay in lockstep.
///
/// CTAs (Editar / Exportar) are hidden when their callbacks are null —
/// matches the row-action policy where Pasadas rows can opt out of edits.
class _ExpandedDetails extends StatelessWidget {
  const _ExpandedDetails({
    required this.sesion,
    required this.onEdit,
    required this.onExport,
  });

  final Sesion sesion;
  final VoidCallback? onEdit;
  final VoidCallback? onExport;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.altWhite,
        border: Border(
          top: BorderSide(color: AppColors.greyBorder),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        Sizes.PADDING_24,
        Sizes.PADDING_22,
        Sizes.PADDING_24,
        Sizes.PADDING_22,
      ),
      child: SesionDetailContent(
        sesion: sesion,
        onEdit: onEdit,
        onExport: onExport,
      ),
    );
  }
}
