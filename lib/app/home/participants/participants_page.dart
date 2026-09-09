import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/rounded_container.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/common_widgets/alert_dialog.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/participant_detail_page.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/participant_social_reports_page.dart';
import 'package:enreda_empresas/app/home/participants/participants_detail_table.dart';
import 'package:enreda_empresas/app/home/participants/participants_item_builder.dart';
import 'package:enreda_empresas/app/home/participants/participants_tile.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/auth.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enreda_empresas/app/home/resources/global.dart' as globals;

class ParticipantsListPage extends StatefulWidget {
  const ParticipantsListPage({super.key});

  static ValueNotifier<int> selectedIndex = ValueNotifier(0);

  @override
  State<ParticipantsListPage> createState() => _ParticipantsListPageState();
}

class _ParticipantsListPageState extends State<ParticipantsListPage> {
  late UserEnreda socialEntityUser;
  final _searchTextController = TextEditingController();
  static ValueNotifier<String> searchText = ValueNotifier('');

  bool _isLoading = true;
  // Figma toggle: false = card grid ("Vista general"), true = wide table.
  bool _detailView = false;
  // Detail view tabs (Figma 10919:8496): 0 = Mis participantes, 1 = entity.
  int _detailTab = 0;
  // General view chips (Figma 7950:6029): activos / inactivos.
  bool _showInactive = false;
  SocialEntity? _socialEntity;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  Future<void> _initData() async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      final database = Provider.of<Database>(context, listen: false);

      final user =
          await LocationCache.instance.getUser(database, auth.currentUser!.uid);
      if (user != null) {
        socialEntityUser = user;
        globals.currentSocialEntityUser = user;

        // The detail table resolves participant resource IDs from this catalog.
        // Initialise it here so opening Participants directly loads the chips.
        LocationCache.instance
            .initResourcesStream(database, user.socialEntityId!);
        _socialEntity = await LocationCache.instance
            .getSocialEntity(database, user.socialEntityId!);
        if (_socialEntity != null) {
          await LocationCache.instance.loadAllParticipants(
              database, user.socialEntityId!, _socialEntity!.programs ?? []);
        }
      }
    } catch (e, st) {
      _errorMessage = 'Error en initData: $e\n$st';
      print(_errorMessage);
    } finally {
      setStateIfMounted(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    super.dispose();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: ParticipantsListPage.selectedIndex,
        builder: (context, selectedIndex, child) {
          return RoundedContainer(
            color: AppColors.grey80,
            borderColor: Responsive.isMobile(context)
                ? Colors.transparent
                : AppColors.greyLight,
            margin: Responsive.isMobile(context)
                ? EdgeInsets.all(20)
                : EdgeInsets.all(Sizes.kDefaultPaddingDouble),
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                Container(
                  height: 80,
                  padding: Responsive.isDesktopS(context)
                      ? EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                      : Responsive.isMobile(context)
                          ? EdgeInsets.symmetric(horizontal: 0, vertical: 10)
                          : EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: Row(
                    children: [
                      InkWell(
                          onTap: () async {
                            if (ParticipantDetailPage.isEditing ||
                                ParticipantSocialReportPage.isEditingReport) {
                              final leave = await showAlertDialog(
                                context,
                                title: '¿Estás seguro que quieres salir?',
                                content:
                                    'Si sales, los cambios no guardados se perderán.',
                                defaultActionText: 'Salir',
                                cancelActionText: 'Cancelar',
                              );
                              if (leave != true) return;
                              ParticipantDetailPage.isEditing = false;
                              ParticipantSocialReportPage.isEditingReport =
                                  false;
                              ParticipantSocialReportPage
                                  .selectedIndexInforms.value = 0;
                            }
                            setState(() {
                              ParticipantsListPage.selectedIndex.value = 0;
                            });
                          },
                          child: selectedIndex != 0
                              ? CustomTextMedium(text: 'Participantes ')
                              : CustomTextMediumBold(text: 'Participantes ')),
                      if (selectedIndex == 1)
                        Flexible(
                          child: Text(
                            '> ${globals.currentParticipant!.firstName} ${globals.currentParticipant!.lastName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: AppColors.primary900,
                                  height: 1.5,
                                  fontSize:
                                      responsiveSize(context, 15, 20, md: 16),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                    height: double.infinity,
                    margin: Responsive.isDesktopS(context)
                        ? EdgeInsets.symmetric(horizontal: 20, vertical: 60)
                        : EdgeInsets.only(top: 60),
                    child: selectedIndex == 0
                        ? _buildParticipantsList()
                        : const ParticipantDetailPage()),
              ],
            ),
          );
        });
  }

  Widget _buildParticipantsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage.isNotEmpty) {
      return Center(
          child:
              Text(_errorMessage, style: const TextStyle(color: Colors.red)));
    }

    return ValueListenableBuilder<String>(
      valueListenable: searchText,
      builder: (context, selectedSearchValue, child) {
        return StreamBuilder<void>(
          stream: LocationCache.instance.paginationUpdates,
          builder: (context, snapshot) {
            final allUsers = LocationCache.instance.allParticipants;
            final query = selectedSearchValue.trim().toLowerCase();

            // Client-side filtering by name, last name, or email
            final filteredUsers = query.isEmpty
                ? allUsers
                : allUsers.where((u) {
                    final firstName = (u.firstName ?? '').toLowerCase();
                    final lastName = (u.lastName ?? '').toLowerCase();
                    final email = u.email.toLowerCase();
                    final fullName = '$firstName $lastName';
                    return firstName.contains(query) ||
                        lastName.contains(query) ||
                        email.contains(query) ||
                        fullName.contains(query);
                  }).toList();

            return _buildListBody(context, filteredUsers,
                isSearch: query.isNotEmpty);
          },
        );
      },
    );
  }

  Widget _buildListBody(BuildContext context, List<UserEnreda> users,
      {required bool isSearch}) {
    final textTheme = Theme.of(context).textTheme;
    // The Participantes page shows the técnico's own participants at the top
    // ("Mis participantes") and the rest of the entity's participants below
    // ("Todos los participantes de {entidad}"). Note: the Panel/dashboard
    // carousel (my_participants_list.dart) stays scoped to "mis" only.
    final currentEntityId = socialEntityUser.socialEntityId;
    final currentUserId = socialEntityUser.userId;
    final myParticipants = <UserEnreda>[];
    final allOtherParticipants = <UserEnreda>[];
    for (final user in users) {
      final isMine = user.assignedEntityId == currentEntityId &&
          user.assignedById == currentUserId;
      if (isMine) {
        myParticipants.add(user);
      } else {
        allOtherParticipants.add(user);
      }
    }

    // Activos / inactivos split of "mis" (Figma chips). Docs without the
    // `active` flag count as active.
    final activeCount = myParticipants.where((u) => u.active ?? true).length;
    final inactiveCount = myParticipants.length - activeCount;
    final myVisible = myParticipants
        .where((u) => (u.active ?? true) == !_showInactive)
        .toList();

    // ponytail: lazy CustomScrollView so only on-screen participant cards
    // build. The old SingleChildScrollView + shrinkWrap grids built every tile
    // of the whole entity up front, which janked when entering the page.
    Widget header(String text) => Text(
          text,
          style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold, color: AppColors.turquoiseBlue),
        );
    ParticipantsListTile tile(UserEnreda user) => ParticipantsListTile(
          user: user,
          socialEntityUserId: socialEntityUser.socialEntityId!,
          onTap: () => setState(() {
            globals.currentParticipant = user;
            ParticipantsListPage.selectedIndex.value = 1;
          }),
        );

    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : MediaQuery.of(context).size.width;
      // The reference uses compact 194px cards with 12px gutters.
      final raw = ((width - 80 + 12) / 206.0).floor();
      final crossAxisCount = raw < 1 ? 1 : raw;

      Widget participantsSliver(List<UserEnreda> list, String emptyMessage) {
        // "Vista detalle" (Figma): same data, projected as one wide table.
        if (_detailView && list.isNotEmpty) {
          return SliverToBoxAdapter(
            child: ParticipantsDetailTable(
              users: list,
              pageSize: 40,
              onTapUser: (user) => setState(() {
                globals.currentParticipant = user;
                ParticipantsListPage.selectedIndex.value = 1;
              }),
            ),
          );
        }
        if (list.isEmpty) {
          // Reuse ParticipantsItemBuilder's empty state (renders EmptyList).
          return SliverToBoxAdapter(
            child: ParticipantsItemBuilder(
              usersList: const <UserEnreda>[],
              emptyMessage: emptyMessage,
              itemBuilder: (_, __) => const SizedBox.shrink(),
            ),
          );
        }
        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 14.0,
            mainAxisExtent: 248.0,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, i) => tile(list[i]),
            childCount: list.length,
          ),
        );
      }

      const pad = EdgeInsets.symmetric(horizontal: 40);
      return CustomScrollView(
        slivers: [
          SliverPadding(
            padding: pad,
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: Responsive.isMobile(context)
                        ? EdgeInsets.all(Sizes.mainPadding)
                        : const EdgeInsets.all(8.0),
                    child: _ParticipantSearchAutocomplete(
                      searchTextController: _searchTextController,
                      participants: LocationCache.instance.allParticipants,
                      onChanged: (value) => searchText.value = value,
                      onSubmitted: _setState,
                      onClear: _clearFilter,
                    ),
                  ),
                  SpaceH12(),
                  if (_detailView) ...[
                    _TabsRow(
                      labels: [
                        StringConst.MY_PARTICIPANTS,
                        StringConst.entityParticipantsTab(
                            _socialEntity?.name ?? ''),
                      ],
                      selected: _detailTab,
                      onSelect: (i) => setState(() => _detailTab = i),
                    ),
                    SpaceH20(),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: header(isSearch
                            ? (_detailView && _detailTab == 1
                                ? "Resultados de búsqueda: Todos"
                                : "Resultados de búsqueda: Mis")
                            : (_detailView && _detailTab == 1
                                ? StringConst.allParticipants(
                                    _socialEntity?.name ?? '')
                                : StringConst.MY_PARTICIPANTS)),
                      ),
                      _ViewToggle(
                        detailView: _detailView,
                        onChanged: (v) => setState(() => _detailView = v),
                      ),
                    ],
                  ),
                  if (!_detailView) ...[
                    SpaceH12(),
                    Row(
                      children: [
                        _CountChip(
                          label: StringConst.PARTICIPANTS_ACTIVE,
                          count: activeCount,
                          selected: !_showInactive,
                          onTap: () => setState(() => _showInactive = false),
                        ),
                        const SizedBox(width: 12),
                        _CountChip(
                          label: StringConst.PARTICIPANTS_INACTIVE,
                          count: inactiveCount,
                          selected: _showInactive,
                          onTap: () => setState(() => _showInactive = true),
                        ),
                      ],
                    ),
                  ],
                  SpaceH20(),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: pad,
            sliver: participantsSliver(
              // Detail view: the tab picks which list the single table shows.
              // General view: chips pick activos / inactivos among "mis".
              _detailView
                  ? (_detailTab == 1 ? allOtherParticipants : myParticipants)
                  : myVisible,
              isSearch
                  ? 'No se encontraron resultados en tus participantes'
                  : 'No hay participantes gestionados por ti',
            ),
          ),
          if (!_detailView) ...[
            SliverPadding(
              padding: pad,
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SpaceH40(),
                    header(isSearch
                        ? "Resultados de búsqueda: Todos"
                        : StringConst.allParticipants(
                            _socialEntity?.name ?? '')),
                    SpaceH20(),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: pad,
              sliver: participantsSliver(
                allOtherParticipants,
                isSearch
                    ? 'No se encontraron resultados en la entidad'
                    : 'No hay participantes gestionados por tu entidad',
              ),
            ),
          ],
          if (LocationCache.instance.isLoadingParticipants)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          SliverToBoxAdapter(child: SpaceH40()),
        ],
      );
    });
  }

  void _clearFilter() {
    setStateIfMounted(() {
      _searchTextController.clear();
      _searchTextController.text = '';
      searchText.value = '';
    });
  }

  void _setState(String text) {
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          searchText.value = text;
        }));
    ParticipantsListPage.selectedIndex.value = 0;
  }
}

class _ParticipantSearchAutocomplete extends StatefulWidget {
  const _ParticipantSearchAutocomplete({
    required this.searchTextController,
    required this.participants,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController searchTextController;
  final List<UserEnreda> participants;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  State<_ParticipantSearchAutocomplete> createState() =>
      _ParticipantSearchAutocompleteState();
}

class _ParticipantSearchAutocompleteState
    extends State<_ParticipantSearchAutocomplete> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fieldHeight = Responsive.isMobile(context) ? 40.0 : 44.0;

    return LayoutBuilder(builder: (context, constraints) {
      return RawAutocomplete<UserEnreda>(
        textEditingController: widget.searchTextController,
        focusNode: _focusNode,
        displayStringForOption: _displayName,
        optionsBuilder: (value) {
          final query = value.text.trim().toLowerCase();
          if (query.isEmpty) return <UserEnreda>[];
          return widget.participants.where((participant) {
            final name = _displayName(participant).toLowerCase();
            final email = participant.email.toLowerCase();
            return name.contains(query) || email.contains(query);
          }).take(8);
        },
        onSelected: (participant) {
          final name = _displayName(participant);
          widget.searchTextController.value = TextEditingValue(
            text: name,
            selection: TextSelection.collapsed(offset: name.length),
          );
          widget.onChanged(name);
        },
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          return ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final hasText = value.text.isNotEmpty;
              return SizedBox(
                height: fieldHeight,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _focusNode,
                        builder: (context, _) => DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.primary030,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: _focusNode.hasFocus
                                  ? AppColors.primary100
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: widget.onChanged,
                        onSubmitted: (text) {
                          onFieldSubmitted();
                          widget.onSubmitted(text);
                        },
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        textInputAction: TextInputAction.search,
                        style: const TextStyle(
                          color: AppColors.primary900,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          hintText:
                              'Busca por nombre, apellidos, correo electrónico...',
                          hintStyle: const TextStyle(
                            color: AppColors.primary900,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 52),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 2,
                      top: 0,
                      bottom: 0,
                      child: SizedBox(
                        width: 40,
                        child: const Center(
                          child: Icon(
                            Icons.search,
                            color: AppColors.primary900,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 2,
                      top: 0,
                      bottom: 0,
                      child: hasText
                          ? SizedBox(
                              width: 40,
                              child: Center(
                                child: IconButton(
                                  constraints: const BoxConstraints.tightFor(
                                    width: 36,
                                    height: 36,
                                  ),
                                  padding: EdgeInsets.zero,
                                  tooltip: 'Limpiar búsqueda',
                                  icon: const Icon(
                                    Icons.close,
                                    color: AppColors.primary900,
                                    size: 20,
                                  ),
                                  onPressed: widget.onClear,
                                ),
                              ),
                            )
                          : const SizedBox(width: 40),
                    ),
                  ],
                ),
              );
            },
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          final suggestions = options.toList();
          return Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: constraints.maxWidth,
              child: Material(
                color: AppColors.white,
                elevation: 4,
                shadowColor: AppColors.primary900.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 232),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shrinkWrap: true,
                    itemCount: suggestions.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      indent: 60,
                      color: AppColors.greyLight,
                    ),
                    itemBuilder: (context, index) {
                      final participant = suggestions[index];
                      final highlighted =
                          AutocompleteHighlightedOption.of(context) == index;
                      return InkWell(
                        onTap: () => onSelected(participant),
                        child: Container(
                          color: highlighted
                              ? AppColors.primary010
                              : AppColors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 9),
                          child: Row(
                            children: [
                              _SuggestionAvatar(participant: participant),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _displayName(participant),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.primary900,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      participant.email,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.greyTxtAlt,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  static String _displayName(UserEnreda participant) =>
      '${participant.firstName ?? ''} ${participant.lastName ?? ''}'.trim();
}

class _SuggestionAvatar extends StatelessWidget {
  const _SuggestionAvatar({required this.participant});

  final UserEnreda participant;

  @override
  Widget build(BuildContext context) {
    final initials =
        '${participant.firstName?.isNotEmpty == true ? participant.firstName![0] : ''}'
                '${participant.lastName?.isNotEmpty == true ? participant.lastName![0] : ''}'
            .toUpperCase();
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.pink600,
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Underlined text tabs ("Mis participantes | Participantes {Entidad}",
/// Figma 10919:8496). Active tab: bold teal with a 2px underline.
class _TabsRow extends StatelessWidget {
  const _TabsRow({
    required this.labels,
    required this.selected,
    required this.onSelect,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.greyBorder)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            InkWell(
              onTap: () => onSelect(i),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected == i
                          ? AppColors.turquoiseBlue
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        selected == i ? FontWeight.w700 : FontWeight.w400,
                    color: selected == i
                        ? AppColors.turquoiseBlue
                        : AppColors.greyTxtAlt,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// "Participantes activos (8)" pill with a count badge (Figma 7950:6029).
class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.turquoiseBlue : AppColors.greyTxtAlt;
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_outlined, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primaryColor : AppColors.greyTxtAlt,
              ),
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Vista general | Vista detalle" segmented pill (Figma
/// ADMIN-ENTIDAD-DASHBOARD). Grey track, white active segment.
class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.detailView, required this.onChanged});

  final bool detailView;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget segment({
      required IconData icon,
      required String label,
      required bool active,
      required VoidCallback onTap,
    }) {
      return InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: active ? Border.all(color: AppColors.greyBorder) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 16,
                  color:
                      active ? AppColors.turquoiseBlue : AppColors.greyTxtAlt),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  color:
                      active ? AppColors.turquoiseBlue : AppColors.greyTxtAlt,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3F3),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          segment(
            icon: Icons.grid_view_outlined,
            label: StringConst.VISTA_GENERAL,
            active: !detailView,
            onTap: () => onChanged(false),
          ),
          segment(
            icon: Icons.table_rows_outlined,
            label: StringConst.VISTA_DETALLE,
            active: detailView,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}
