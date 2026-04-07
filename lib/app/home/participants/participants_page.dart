import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/rounded_container.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/external_social_entity/filter_text_field_row.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/participant_detail_page.dart';
import 'package:enreda_empresas/app/home/participants/participants_item_builder.dart';
import 'package:enreda_empresas/app/home/participants/participants_tile.dart';
import 'package:enreda_empresas/app/models/filterResource.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/auth.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enreda_empresas/app/home/resources/global.dart' as globals;
import 'package:enreda_empresas/app/services/algolia_search.dart';

class ParticipantsListPage extends StatefulWidget {
  const ParticipantsListPage({super.key});

  static ValueNotifier<int> selectedIndex = ValueNotifier(0);

  @override
  State<ParticipantsListPage> createState() => _ParticipantsListPageState();
}

class _ParticipantsListPageState extends State<ParticipantsListPage> {
  late UserEnreda socialEntityUser;
  final _searchTextController = TextEditingController();
  //late String searchText = '';
  static ValueNotifier<String> searchText = ValueNotifier('');
  List<SocialEntity> finalSocialEntities = [];


  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  SocialEntity? _socialEntity;

  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final db = Provider.of<Database>(context, listen: false);
      LocationCache.instance.fetchNextParticipantsPage(db);
    }
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
          await LocationCache.instance.initPaginatedParticipants(database, user.socialEntityId!, _socialEntity!.programs ?? []);
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
    _scrollController.dispose();
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
                          onTap: () => {
                            setState(() {
                              ParticipantsListPage.selectedIndex.value = 0;
                            })
                          },
                          child: selectedIndex != 0 ? CustomTextMedium(text: 'Participantes ') :
                          CustomTextMediumBold(text: 'Participantes ') ),
                      selectedIndex == 1 ? CustomTextMediumBold(text:'> ${globals.currentParticipant!.firstName} ${globals.currentParticipant!.lastName}') : Container()
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
        final query = selectedSearchValue.trim();
        if (query.isNotEmpty) {
          // Task 3: Switch to Algolia Search results
          return FutureBuilder<List<UserEnreda>>(
            future: AlgoliaSearch.queryParticipants(query),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final searchResults = snapshot.data ?? [];
              return _buildListBody(context, searchResults, isAlgolia: true);
            },
          );
        }

        // Task 3 fallback: Firestore Paginated List
        return StreamBuilder<void>(
          stream: LocationCache.instance.paginationUpdates,
          builder: (context, snapshot) {
            final allUsers = LocationCache.instance.allParticipants;
            return _buildListBody(context, allUsers, isAlgolia: false);
          },
        );
      },
    );
  }

  Widget _buildListBody(BuildContext context, List<UserEnreda> users, {required bool isAlgolia}) {
    final textTheme = Theme.of(context).textTheme;

    // Filter by entity/curator (My vs All)
    final myParticipants = users
        .where((u) => u.assignedEntityId == socialEntityUser.socialEntityId! &&
            u.assignedById == socialEntityUser.userId)
        .toList();

    final allOtherParticipants = users
        .where((u) => !myParticipants.contains(u))
        .toList();

    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
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
                onFieldSubmitted: (value) => _setState(_searchTextController.text),
                clearFilter: () => _clearFilter(),
                hintText: 'Busca por nombre, apellidos, correo electrónico...',
              ),
            ),
            SpaceH12(),
            Text(
              isAlgolia ? "Resultados de búsqueda: Mis" : StringConst.MY_PARTICIPANTS,
              style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.turquoiseBlue),
            ),
            SpaceH20(),
            ParticipantsItemBuilder(
                usersList: myParticipants,
                emptyMessage: isAlgolia ? 'No se encontraron resultados en tus participantes' : 'No hay participantes gestionados por ti',
                itemBuilder: (context, user) {
                  return ParticipantsListTile(
                      user: user,
                      socialEntityUserId: socialEntityUser.socialEntityId!,
                      onTap: () => setState(() {
                            globals.currentParticipant = user;
                            ParticipantsListPage.selectedIndex.value = 1;
                          }));
                }),
            SpaceH40(),
            Text(
              isAlgolia ? "Resultados de búsqueda: Todos" : StringConst.allParticipants(_socialEntity?.name ?? ''),
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.turquoiseBlue,
              ),
            ),
            SpaceH20(),
            ParticipantsItemBuilder(
                usersList: allOtherParticipants,
                emptyMessage: isAlgolia ? 'No se encontraron resultados en la entidad' : 'No hay participantes gestionados por tu entidad',
                itemBuilder: (context, user) {
                  return ParticipantsListTile(
                      user: user,
                      socialEntityUserId: socialEntityUser.socialEntityId!,
                      onTap: () => setState(() {
                            globals.currentParticipant = user;
                            ParticipantsListPage.selectedIndex.value = 1;
                          }));
                }),
            if (!isAlgolia && LocationCache.instance.isLoadingParticipants)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            SpaceH40(),
          ],
        ),
      ),
    );
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
