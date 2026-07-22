import 'package:chips_choice/chips_choice.dart';
import 'package:enreda_empresas/app/common_widgets/custom_chip.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/models/filterResource.dart';
import 'package:enreda_empresas/app/models/socialEntitiesType.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/external_entities_cache.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enreda_empresas/app/home/resources/global.dart' as globals;
import 'package:enreda_empresas/app/utils/functions.dart';
import '../../models/externalSocialEntity.dart';
import 'entity_directory_page.dart';
import 'entity_list_tile.dart';
import 'filter_text_field_row.dart';

class EntitiesListPage extends StatefulWidget {
  const EntitiesListPage({Key? key, required this.socialEntityId}) : super(key: key);
  final String? socialEntityId;

  @override
  State<EntitiesListPage> createState() => _EntitiesListPageState();
}

class _EntitiesListPageState extends State<EntitiesListPage> {

  List<SocialEntitiesType> socialEntityTypes = [];
  final _searchTextController = TextEditingController();
  FilterResource filterResource = FilterResource("", []);
  List<SocialEntity> finalSocialEntities = [];
  bool create = false;  //Choose between show list of social entities or create form

  // Fetched once with .get() and cached in a session singleton, so returning
  // to this list re-reads 0 documents. Search/category filters are applied
  // client-side, so setState never re-fetches.
  late Future<List<ExternalSocialEntity>> _entitiesFuture;

  @override
  void initState() {
    super.initState();
    final database = Provider.of<Database>(context, listen: false);
    _entitiesFuture =
        ExternalEntitiesCache.instance.load(database, widget.socialEntityId!);
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
    return _buildEntitiesList();
  }

  Widget _buildEntitiesList(){
    // CustomScrollView + SliverGrid so only visible tiles are built/painted.
    // The old SingleChildScrollView + Wrap laid out all ~400 cards per frame.
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: Sizes.mainPadding,)),
        SliverToBoxAdapter(
          child: Padding(
            padding: Responsive.isMobile(context) ? EdgeInsets.all(Sizes.mainPadding) : const EdgeInsets.all(8.0),
            child: FilterTextFieldRow(
              searchTextController: _searchTextController,
              onPressed: () async {
                filterResource.searchText = _searchTextController.text;
              },
              onFieldSubmitted: (value) => setState(() {
                filterResource.searchText = _searchTextController.text;
              }),
              clearFilter: () => _clearFilter(),
              hintText: 'Nombre del contacto ...',
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: Responsive.isMobile(context) ? EdgeInsets.all(Sizes.mainPadding) : const EdgeInsets.all(8.0),
            child: chipFilter(),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: Sizes.mainPadding * 3)),
        _buildEntitiesStream(context),
      ],
    );
  }

  Widget chipFilter() {
    final socialEntityTypes = LocationCache.instance.socialEntitiesTypes;
    if (socialEntityTypes.isEmpty) return Container();
    
    return ChipsChoice<String>.multiple(
      padding: EdgeInsets.all(5),
      wrapped: true,
      value: filterResource.externalSocialEntityTypesIds,
      onChanged: (val){
        setState(() => filterResource.externalSocialEntityTypesIds = val);
      },
      choiceItems: C2Choice.listFrom<String, SocialEntitiesType>(
        source: socialEntityTypes,
        value: (i, v) => v.id,
        label: (i, v) => v.name,
      ),
      choiceBuilder: (item, i) => CustomChip(
        label: item.label,
        borderRadius: 17.0,
        backgroundColor: AppColors.greyChip,
        selectedBackgroundColor: AppColors.bluePetrol,
        textColor: AppColors.greyLetter,
        selected: item.selected,
        onSelect: item.select!,
      ),
    );
  }

  // Returns a sliver: SliverGrid for data, SliverToBoxAdapter for load/error.
  Widget _buildEntitiesStream(BuildContext context) {
    return FutureBuilder<List<ExternalSocialEntity>>(
        future: _entitiesFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return SliverToBoxAdapter(
                child: Center(child: CustomTextMedium(text: StringConst.FORM_ERROR)));
          }
          if(snapshot.hasData) {
            final List<ExternalSocialEntity> socialEntities =
                _applyFilter(snapshot.data!);
            return SliverGrid.builder(
              // Card is fixed 335x276 with a 27px avatar overhang; padding 15.
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 365,
                mainAxisExtent: 306,
              ),
              itemCount: socialEntities.length,
              itemBuilder: (context, index) {
                final currentExternalSocialEntity = socialEntities[index];
                return Padding(
                  padding: const EdgeInsets.all(15),
                  child: EntityListTile(
                      socialEntity: currentExternalSocialEntity,
                      onTap: () {
                        setState(() {
                          globals.currentExternalSocialEntity = currentExternalSocialEntity;
                          EntityDirectoryPage.selectedIndex.value = 2;
                        });
                      },
                      onEdit: () {
                        setState(() {
                          globals.currentExternalSocialEntity = currentExternalSocialEntity;
                          EntityDirectoryPage.selectedIndex.value = 3;
                        });
                      }
                  ),
                );
              },
            );
          }
          return const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()));
        });
  }

  /// Client-side search + category filter over the already-loaded list
  /// (0 Firestore reads). Mirrors the OR semantics of the old server-builder
  /// filter, but matches search against `name` (the model has no searchText,
  /// and imported directory contacts never had one).
  List<ExternalSocialEntity> _applyFilter(List<ExternalSocialEntity> all) {
    final searchText = removeDiacritics(filterResource.searchText.toLowerCase());
    final searchWords =
        searchText.split(' ').where((w) => w.isNotEmpty).toList();
    final selectedCategories =
        filterResource.externalSocialEntityTypesIds.toSet();

    if (searchWords.isEmpty && selectedCategories.isEmpty) return all;

    return all.where((e) {
      bool textMatch = false;
      if (searchWords.isNotEmpty) {
        final name = removeDiacritics(e.name.toLowerCase());
        textMatch = searchWords.any((w) => name.contains(w));
      }
      bool categoryMatch = false;
      if (selectedCategories.isNotEmpty) {
        categoryMatch = (e.types ?? const [])
            .toSet()
            .intersection(selectedCategories)
            .isNotEmpty;
      }
      return textMatch || categoryMatch;
    }).toList();
  }

  void _clearFilter() {
    setStateIfMounted(() {
      _searchTextController.clear();
      _searchTextController.text = '';
      filterResource.searchText = '';
      filterResource.externalSocialEntityTypesIds = [];
    });
  }

}
