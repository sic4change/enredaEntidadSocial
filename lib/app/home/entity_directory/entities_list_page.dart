import 'package:chips_choice/chips_choice.dart';
import 'package:enreda_empresas/app/common_widgets/custom_chip.dart';
import 'package:enreda_empresas/app/home/entity_directory/entity_directory_page.dart';
import 'package:enreda_empresas/app/home/entity_directory/filter_text_field_row.dart';
import 'package:enreda_empresas/app/home/social_entity/entity_list_tile.dart';
import 'package:enreda_empresas/app/models/filterResource.dart';
import 'package:enreda_empresas/app/models/socialEntitiesType.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/services/algolia_search.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enreda_empresas/app/home/resources/global.dart' as globals;

class EntitiesListPage extends StatefulWidget {
  const EntitiesListPage({Key? key}) : super(key: key);

  @override
  State<EntitiesListPage> createState() => _EntitiesListPageState();
}

class _EntitiesListPageState extends State<EntitiesListPage> {

  List<String> tags = [];
  final _queryController = TextEditingController();
  final _searchTextController = TextEditingController();
  FilterResource filterResource = FilterResource("", []);
  String get searchQuery => _queryController.text;
  List<SocialEntity> finalSocialEntities = [];
  bool create = false;  //Choose between show list of social entities or create form

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  void _clearFilter() {
    setStateIfMounted(() {
      _searchTextController.clear();
      filterResource.searchText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildEntitiesList();
  }

  Widget _buildEntitiesList(){
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: Sizes.mainPadding,),
          FilterTextFieldRow(
            searchTextController: _queryController,
            onPressed: () async {
              var fetchUsers = await AlgoliaSearch().fetchUsers(_queryController.text);
              setState((){
                finalSocialEntities = fetchUsers;
              });

            },
            onFieldSubmitted: (value) async {
              setStateIfMounted(() {
                filterResource.searchText = _queryController.text;
              });
              var fetchUsers = await AlgoliaSearch().fetchUsers(_queryController.text);
              setState((){
                finalSocialEntities = fetchUsers;
              });
            },
            clearFilter: (){
              setState(() {
                _queryController.clear();
                finalSocialEntities.clear();
                _clearFilter();
              });

            },
            hintText: '',
          ),
          SizedBox(height: Sizes.mainPadding,),
          chipFilter(),
          Container(
              margin: EdgeInsets.only(top: Sizes.mainPadding * 3),
              child: _buildEntitiesStream(context, tags)),
        ],
      ),);
  }

  Widget chipFilter(){
    final database = Provider.of<Database>(context, listen: false);
    List<SocialEntitiesType> socialEntityTypes = [];
    return StreamBuilder<List<SocialEntitiesType>>(
        stream: database.socialEntitiesTypeStream(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) return Container();
          socialEntityTypes.clear();
          snapshot.data!.toList().forEach((element) {
            socialEntityTypes.add(element);
          });
          print('socialEntities: $socialEntityTypes');
          return ChipsChoice<String>.multiple(
            padding: EdgeInsets.all(5),
            wrapped: true,
            value: tags,
            onChanged: (val){
              setState(() => tags = val);
              print('tags: $tags');
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
    );
  }

  bool _showSocialEntitySearch(SocialEntity currentSocialEntity, List<SocialEntity> finalSocialEntities){
    if(finalSocialEntities.contains(currentSocialEntity) || _queryController.text == ''){
      return true;
    }else return false;
  }

  bool _showSocialEntityChipFilter(SocialEntity currentSocialEntity, List<String> tags){
    bool result = false;
    if(currentSocialEntity.types != null){
      currentSocialEntity.types!.forEach((element) {
        if(tags.contains(element)){
          result = true;
        }
      });
    }
    if(tags.isEmpty){
      result = true; //No filter selected -> show all socialEntities
    }
    print(tags);
    return result;

  }

  bool _showSocialEntity(SocialEntity currentSocialEntity, List<String> tags, List<SocialEntity> finalSocialEntities){
    return
      _showSocialEntitySearch(currentSocialEntity, finalSocialEntities) &&
          _showSocialEntityChipFilter(currentSocialEntity, tags);
  }

  Widget _buildEntitiesStream(BuildContext context, List<String> filter) {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<List<SocialEntity>>(
        stream: database.socialEntitiesStream(),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            final List<SocialEntity> socialEntities = snapshot.data!.toList();
            return SingleChildScrollView(
              controller: ScrollController(),
              child: Wrap(
                children: [
                  for(SocialEntity currentSocialEntity in socialEntities)
                    _showSocialEntity(currentSocialEntity, tags, finalSocialEntities) ?
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: EntityListTile(
                          socialEntity: currentSocialEntity,
                          filter: filter,
                          onTap: () {
                            setState(() {
                              globals.currentSocialEntity = currentSocialEntity;
                              EntityDirectoryPage.selectedIndex.value = 2;
                            });
                          }
                      ),
                    ) :
                    Container(),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

}
