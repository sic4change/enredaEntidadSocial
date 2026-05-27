import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Searchable multi-select participant picker for the "Convocar participantes"
/// field in the Crear Nueva Sesión form (Figma overlay `1:493`).
///
/// Behaviour:
///   * Reads participants from `LocationCache.instance.allParticipants` —
///     never opens a new stream (per CLAUDE.md §0 HIGH strictness).
///   * Calls `loadAllParticipants(...)` once on init to ensure the cache
///     has been seeded for the current entity; the method is idempotent and
///     re-uses an existing in-flight load.
///   * Subscribes to `LocationCache.instance.paginationUpdates` via a
///     `StreamBuilder<void>` so the list rebuilds as pages stream in.
///   * Search filter is name-only (`firstName lastName`), case-insensitive.
///   * Each candidate is its own rounded chip card; selection is the right-
///     side square checkbox affordance — no separate "selected chips"
///     cluster above the list.
class ParticipantPicker extends StatefulWidget {
  const ParticipantPicker({
    super.key,
    required this.socialEntityId,
    required this.entityPrograms,
    required this.selectedIds,
    required this.onChanged,
    this.singleSelect = false,
  });

  /// Owning entity (passed in from `widget.socialEntity` in the flow page).
  final String socialEntityId;

  /// Programs to scope the participant load by. Empty list = entity scope only.
  final List<String> entityPrograms;

  /// Current selection (drives chip + checkbox state).
  final List<String> selectedIds;

  /// Fires the new selection list (immutable, order = chip render order).
  final ValueChanged<List<String>> onChanged;

  /// When true only one participant can be selected at a time (individual
  /// session mode). Selecting a new participant automatically replaces the
  /// previous one instead of adding to the list.
  final bool singleSelect;

  @override
  State<ParticipantPicker> createState() => _ParticipantPickerState();
}

class _ParticipantPickerState extends State<ParticipantPicker> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchLower = '';
  bool _loadKicked = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _kickLoadIfNeeded() {
    if (_loadKicked) return;
    _loadKicked = true;
    final database = Provider.of<Database>(context, listen: false);
    // Idempotent — LocationCache short-circuits if scope unchanged.
    LocationCache.instance.loadAllParticipants(
      database,
      widget.socialEntityId,
      widget.entityPrograms,
    );
  }

  @override
  Widget build(BuildContext context) {
    _kickLoadIfNeeded();
    final textTheme = Theme.of(context).textTheme;

    return StreamBuilder<void>(
      // ─── §10 audit note ────────────────────────────────────────────────
      // This StreamBuilder is a *rebuild trigger only*. The stream is a
      // `Stream<void>` from `LocationCache._paginationController` that
      // never carries data — it just notifies that the cache's
      // `allParticipants` list grew during paginated loading. There is no
      // `snapshot.data` to render and no per-stream error path to handle:
      //   * Empty / "no data yet"   → handled by `_buildBody` via
      //     `LocationCache.isLoadingParticipants` and the empty-list
      //     branch.
      //   * Errors during load      → swallowed inside
      //     `LocationCache.loadAllParticipants` (which prints and resets
      //     `isLoadingParticipants`). Surfacing them to the picker would
      //     require a separate error channel on the cache itself.
      // ──────────────────────────────────────────────────────────────────
      stream: LocationCache.instance.paginationUpdates,
      builder: (context, _) {
        final all = LocationCache.instance.allParticipants;
        final filtered = _applySearch(all);
        final isLoading = LocationCache.instance.isLoadingParticipants &&
            all.isEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SearchField(
              controller: _searchCtrl,
              onChanged: (v) =>
                  setState(() => _searchLower = v.trim().toLowerCase()),
            ),
            const SizedBox(height: Sizes.PADDING_12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: _buildBody(
                context,
                textTheme: textTheme,
                items: filtered,
                isLoading: isLoading,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required TextTheme textTheme,
    required List<UserEnreda> items,
    required bool isLoading,
  }) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(Sizes.PADDING_20),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(Sizes.PADDING_20),
        child: Text(
          _searchLower.isEmpty
              ? StringConst.SESION_PICKER_EMPTY
              : StringConst.SESION_PICKER_NO_RESULTS,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.greyTxtAlt,
          ),
        ),
      );
    }
    // Per the updated Figma: each candidate row renders as its own rounded
    // card (white fill, subtle shadow, no outer container). Selection state
    // is the right-side square checkbox — primary900 fill when checked,
    // white with greyUltraLight border when not.
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: Sizes.PADDING_4),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final user = items[index];
        final id = user.userId ?? '';
        final isSelected = widget.selectedIds.contains(id);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: Sizes.PADDING_4),
          child: _ParticipantRow(
            user: user,
            isSelected: isSelected,
            onToggle: (v) => _toggle(id, v),
          ),
        );
      },
    );
  }

  List<UserEnreda> _applySearch(List<UserEnreda> source) {
    if (_searchLower.isEmpty) return source;
    return source.where((u) {
      final name = '${u.firstName ?? ''} ${u.lastName ?? ''}'.toLowerCase();
      return name.contains(_searchLower);
    }).toList(growable: false);
  }

  void _toggle(String id, bool nowSelected) {
    if (id.isEmpty) return;
    final List<String> next;
    if (nowSelected) {
      if (widget.singleSelect) {
        // Individual mode: replace any existing selection with the new pick.
        next = [id];
      } else {
        next = List<String>.from(widget.selectedIds);
        if (!next.contains(id)) next.add(id);
      }
    } else {
      next = List<String>.from(widget.selectedIds);
      next.remove(id);
    }
    widget.onChanged(next);
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: textTheme.bodyMedium?.copyWith(color: AppColors.greyDark),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.seaBlue,
          size: Sizes.ICON_SIZE_20,
        ),
        hintText: StringConst.SESION_PICKER_SEARCH_HINT,
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.seaBlue),
        filled: true,
        fillColor: AppColors.primary050,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Sizes.PADDING_12,
          vertical: Sizes.PADDING_8,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sizes.RADIUS_30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sizes.RADIUS_30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sizes.RADIUS_30),
          borderSide: const BorderSide(color: AppColors.primary500),
        ),
      ),
    );
  }
}

/// Single participant chip card — white pill with the name on the left and
/// a square checkbox affordance on the right. Matches the Figma list rhythm:
/// each row is its own rounded card with a thin border + subtle shadow, not
/// a flat list item with a divider.
class _ParticipantRow extends StatelessWidget {
  const _ParticipantRow({
    required this.user,
    required this.isSelected,
    required this.onToggle,
  });

  final UserEnreda user;
  final bool isSelected;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fullName = '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(Sizes.RADIUS_8),
        onTap: () => onToggle(!isSelected),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.PADDING_16,
            vertical: Sizes.PADDING_10,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(Sizes.RADIUS_8),
            border: Border.all(color: AppColors.greyUltraLight),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary900.withOpacity(0.06),
                blurRadius: Sizes.PADDING_6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  fullName.isEmpty
                      ? StringConst.SESION_PICKER_UNKNOWN_USER
                      : fullName,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.seaBlue,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: Sizes.PADDING_8),
              _SquareCheckbox(
                value: isSelected,
                onChanged: onToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Square checkbox affordance — primary900 fill with a white checkmark
/// when checked; white fill with a greyUltraLight border when not.
/// Matches the right-side selector glyph in the Figma "Convocar
/// participantes" list.
class _SquareCheckbox extends StatelessWidget {
  const _SquareCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(Sizes.RADIUS_4),
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: Sizes.SIZE_20,
        height: Sizes.SIZE_20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: value ? AppColors.primary900 : AppColors.white,
          borderRadius: BorderRadius.circular(Sizes.RADIUS_4),
          border: Border.all(
            color: value ? AppColors.primary900 : AppColors.greyUltraLight,
            width: 1,
          ),
        ),
        child: value
            ? const Icon(
                Icons.check,
                size: Sizes.ICON_SIZE_14,
                color: AppColors.white,
              )
            : null,
      ),
    );
  }
}
