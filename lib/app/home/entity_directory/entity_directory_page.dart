import 'dart:js_util';

import 'package:algolia/algolia.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:enreda_empresas/app/common_widgets/add_yellow_button.dart';
import 'package:enreda_empresas/app/common_widgets/custom_chip.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/entity_directory/filter_text_field_row.dart';
import 'package:enreda_empresas/app/home/entity_directory/search_bar.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/participant_detail_page.dart';
import 'package:enreda_empresas/app/home/resources/list_item_builder_grid.dart';
import 'package:enreda_empresas/app/home/social_entity/create_social_entity_page.dart';
import 'package:enreda_empresas/app/models/addressUser.dart';
import 'package:enreda_empresas/app/models/city.dart';
import 'package:enreda_empresas/app/models/country.dart';
import 'package:enreda_empresas/app/models/filterResource.dart';
import 'package:enreda_empresas/app/models/socialEntitiesType.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/algolia_search.dart';
import 'package:enreda_empresas/app/services/auth.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';

class EntityDirectoryPage extends StatefulWidget {
  EntityDirectoryPage({super.key});


  @override
  State<EntityDirectoryPage> createState() => _EntityDirectoryPageState();
}

class _EntityDirectoryPageState extends State<EntityDirectoryPage> {
  Widget? _currentPage;
  late UserEnreda socialEntityUser;

  bool? isVisible = true;
  List<UserEnreda>? myParticipantsList = [];
  List<String>? interestsIdsList = [];
  String? socialEntityId;
  SocialEntity? organizer;
  List<String> interestSelectedName = [];
  final _searchTextController = TextEditingController();
  FilterResource filterResource = FilterResource("", []);

  List<String> tags = ['hBBhGYoCiJ6bWK0fZqmL'];

  final _queryController = TextEditingController();
  String get searchQuery => _queryController.text;
  List<SocialEntity> finalSocialEntities = [];




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
  void initState(){
    _currentPage = _buildEntitiesList();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: ScrollController(),
      child: _currentPage,
    );
  }

  Widget _buildEntitiesList(){
    return Container(
      padding: EdgeInsets.all(Sizes.mainPadding),
      margin: EdgeInsets.all(Sizes.mainPadding),
      decoration: BoxDecoration(
        color: AppColors.altWhite,
        shape: BoxShape.rectangle,
        border: Border.all(color: AppColors.greyLight2.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 45, bottom: 35),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text('Directorio de entidades',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.greyDark2),),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: Align(
                      alignment: Alignment.topRight,
                      child: AddYellowButton(
                        text: 'Crear nueva entidad',
                        onPressed: () => setState(() {
                          _currentPage =  CreateSocialEntityPage(
                           /* onBack: () => setState(() {
                              _currentPage = _buildEntitiesList();
                            }),*/
                          );
                        }),
                      )
                  ),
                ),
              ],
            ),
          ),

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

          chipFilter(),

          Container(
              margin: EdgeInsets.only(top: Sizes.mainPadding * 2),
              child: _buildResourcesList(context, tags)),
        ],
      ),);
  }

  Widget entityContainer(SocialEntity currentSocialEntity, List<String> filter){
    final database = Provider.of<Database>(context, listen: false);
    String name = currentSocialEntity.name;
    String email = currentSocialEntity.email ?? '';
    String phone = currentSocialEntity.phone ?? '';
    String web = currentSocialEntity.website ?? '';
    Address fullLocation = currentSocialEntity.address ?? Address();
    String cityName = '';
    String countryName = '';
    String location = '';
    List<String> types = currentSocialEntity.types ?? [];
    return StreamBuilder<City>(
      stream: database.cityStream(fullLocation.city),
      builder: (context, snapshot) {
        final city = snapshot.data;
        cityName = city == null ? '' : city.name;
        return StreamBuilder<Country>(
          stream: database.countryStream(fullLocation.country),
          builder: (context, snapshot) {
            final country = snapshot.data;
            countryName = country == null ? '' : country.name;
            if(countryName != ''){
              location = countryName;
            }else if(cityName != ''){
              location = cityName;
            }
            if(cityName != '' && countryName != ''){
              location = location + ', ' + cityName;
            }
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Container(
                  height: 270,
                  width: 335,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: AppColors.greyBorder,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 5,
                      )],
                    color: Colors.white
                  ),
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20, right: 28),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Icon(
                            Icons.upload,
                            size: 20,
                            color: AppColors.greyTxtAlt,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 40, bottom: 18),
                        child: Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      //Email
                      Padding(
                        padding: const EdgeInsets.only(left: 25),
                        child: email != '' ? Row(
                          children: [
                            Icon(
                              Icons.email,
                              color: AppColors.bluePetrol,
                              size: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                email,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            )
                          ],
                        ) :
                        Container(),
                      ),
                      //Phone
                      Padding(
                        padding: const EdgeInsets.only(left: 25, top: 8),
                        child: phone != '' ? Row(
                          children: [
                            Icon(
                              Icons.phone,
                              color: AppColors.bluePetrol,
                              size: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                phone,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            )
                          ],
                        ) :
                        Container(),
                      ),
                      //Location
                      Padding(
                        padding: const EdgeInsets.only(left: 25, top: 8, bottom: 18),
                        child: location != '' ? Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppColors.bluePetrol,
                              size: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                location,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ) :
                        Container(),
                      ),
                      //Button
                      web != '' ? Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Container(
                          width: 290,
                          child: OutlinedButton(
                            onPressed: (){},
                            child: Text(
                              web,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.greyLetter
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(width: 1, color: AppColors.greyBorder),
                            )
                          ),
                        ),
                      ) :
                      Container(),
                    ],
                  ),
                ),
                Positioned(
                  top: -27,
                  child: CachedNetworkImage(
                      width: 92,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      alignment: Alignment.center,
                      imageUrl: currentSocialEntity.photo!,
                  ),
                ),
              ],
            );
          }
        );
      }
    );
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

  Widget _buildResourcesList(BuildContext context, List<String> filter) {
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
                    child: entityContainer(currentSocialEntity, filter),
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