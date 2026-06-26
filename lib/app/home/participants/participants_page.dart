import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/rounded_container.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/common_widgets/alert_dialog.dart';
import 'package:enreda_empresas/app/home/external_social_entity/filter_text_field_row.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/participant_detail_page.dart';
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

      final user = await LocationCache.instance.getUser(database, auth.currentUser!.uid);
      if (user != null) {
        socialEntityUser = user;
        globals.currentSocialEntityUser = user;

        _socialEntity = await LocationCache.instance.getSocialEntity(database, user.socialEntityId!);
        if (_socialEntity != null) {
          await LocationCache.instance.loadAllParticipants(database, user.socialEntityId!, _socialEntity!.programs ?? []);
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
            borderColor: Responsive.isMobile(context) ? Colors.transparent : AppColors.greyLight,
            margin: Responsive.isMobile(context) ? EdgeInsets.all(20) : EdgeInsets.all(Sizes.kDefaultPaddingDouble),
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                Container(
                  height: 80,
                  padding:  Responsive.isDesktopS(context) ? EdgeInsets.symmetric(horizontal: 20, vertical: 10) :
                    Responsive.isMobile(context) ? EdgeInsets.symmetric(horizontal: 0, vertical: 10) :
                      EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: Row(
                    children: [
                      InkWell(
                          onTap: () async {
                            if (ParticipantDetailPage.isEditing) {
                              final leave = await showAlertDialog(
                                context,
                                title: '¿Estás seguro que quieres dejar de editar?',
                                content: 'Si sales, los cambios no guardados se perderán.',
                                defaultActionText: 'Salir',
                                cancelActionText: 'Cancelar',
                              );
                              if (leave != true) return;
                              ParticipantDetailPage.isEditing = false;
                            }
                            setState(() {
                              ParticipantsListPage.selectedIndex.value = 0;
                            });
                          },
                          child: selectedIndex != 0 ? CustomTextMedium(text: 'Participantes ') :
                          CustomTextMediumBold(text: 'Participantes ') ),
                      if (selectedIndex == 1)
                        Flexible(
                          child: Text(
                            '> ${globals.currentParticipant!.firstName} ${globals.currentParticipant!.lastName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.primary900,
                              height: 1.5,
                              fontSize: responsiveSize(context, 15, 20, md: 16),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  height: double.infinity,
                  margin: Responsive.isDesktopS(context) ? EdgeInsets.symmetric(horizontal: 20, vertical: 60) : EdgeInsets.only(top: 60),
                  child: selectedIndex == 0 ? _buildParticipantsList() : const ParticipantDetailPage()
                ),
              ],
            ),
          );
      }
    );
  }

  Widget _buildParticipantsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)));
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

            return _buildListBody(context, filteredUsers, isSearch: query.isNotEmpty);
          },
        );
      },
    );
  }

  Widget _buildListBody(BuildContext context, List<UserEnreda> users, {required bool isSearch}) {
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
      final raw = ((width - 80) / 265.0).floor(); // 40px padding each side
      final crossAxisCount = raw < 1 ? 1 : raw;

      Widget participantsSliver(List<UserEnreda> list, String emptyMessage) {
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
            crossAxisSpacing: 15.0,
            mainAxisSpacing: 15.0,
            mainAxisExtent: 370.0,
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
                    child: FilterTextFieldRow(
                      searchTextController: _searchTextController,
                      onPressed: () async {
                        searchText.value = _searchTextController.text;
                      },
                      onFieldSubmitted: (value) =>
                          _setState(_searchTextController.text),
                      clearFilter: () => _clearFilter(),
                      hintText:
                          'Busca por nombre, apellidos, correo electrónico...',
                    ),
                  ),
                  SpaceH12(),
                  header(isSearch
                      ? "Resultados de búsqueda: Mis"
                      : StringConst.MY_PARTICIPANTS),
                  SpaceH20(),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: pad,
            sliver: participantsSliver(
              myParticipants,
              isSearch
                  ? 'No se encontraron resultados en tus participantes'
                  : 'No hay participantes gestionados por ti',
            ),
          ),
          SliverPadding(
            padding: pad,
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SpaceH40(),
                  header(isSearch
                      ? "Resultados de búsqueda: Todos"
                      : StringConst.allParticipants(_socialEntity?.name ?? '')),
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

  void _setState(String text){
    WidgetsBinding.instance.addPostFrameCallback((_) =>
    setState(() {
      searchText.value = text;
    }));
    ParticipantsListPage.selectedIndex.value = 0;

  }

}
