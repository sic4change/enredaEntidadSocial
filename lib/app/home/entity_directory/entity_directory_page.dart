import 'package:cached_network_image/cached_network_image.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:enreda_empresas/app/common_widgets/add_yellow_button.dart';
import 'package:enreda_empresas/app/common_widgets/custom_chip.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/entity_directory/filter_text_field_row.dart';
import 'package:enreda_empresas/app/models/filterResource.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class EntityDirectoryPage extends StatefulWidget {
  const EntityDirectoryPage({super.key});

  @override
  State<EntityDirectoryPage> createState() => _EntityDirectoryPageState();
}

class _EntityDirectoryPageState extends State<EntityDirectoryPage> {
  bool? isVisible = true;
  List<UserEnreda>? myParticipantsList = [];
  List<String>? interestsIdsList = [];
  String? socialEntityId;
  SocialEntity? organizer;
  List<String> interestSelectedName = [];
  final _searchTextController = TextEditingController();
  FilterResource filterResource = FilterResource("", []);

  List<String> tags = [];
  List<String> options = [ 'Salud integral', 'Salud mental', 'Diversidad funcional', 'Empleo', 'Centro de formación', 'Inserción laboral',
    'Empresas', 'Centros educativos', 'Ocio y tiempo libre', 'Deporte', 'Conciliación familiar', 'Educativas', 'Mujeres', 'Migrantes', 'Menores',
    'Servicios sociales', 'Administración pública', 'Otros'];

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
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      controller: ScrollController(),
      child: Container(
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
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text('Directorio de entidades',
                        style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.greyDark2),),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: AddYellowButton(text: 'Crear nueva entidad')
                      ),
                    ),
                  ],
                ),
              ),

              FilterTextFieldRow(
                searchTextController: _searchTextController,
                onPressed: () => setStateIfMounted(() {
                  filterResource.searchText = _searchTextController.text;
                }),
                onFieldSubmitted: (value) => setStateIfMounted(() {
                  filterResource.searchText = _searchTextController.text;
                }),
                clearFilter: () => _clearFilter(),
                hintText: '',
              ),

              chipFilter(),

              Container(
                  margin: EdgeInsets.only(top: Sizes.mainPadding * 2),
                  child: _gamificationWeb()),
            ],
          ),),
    );
  }

  //TODO use ListItemBuilderGrid()
  Widget _gamificationWeb(){
    return SingleChildScrollView(
      controller: ScrollController(),
      child: Column(
        children: [
          Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: entityContainer(),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: entityContainer(),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: entityContainer(),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: entityContainer(),
                )
              ]
          ),
        ],
      ),
    );
  }

  Widget entityContainer(){
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
                  'SAVE THE CHILDREN',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                  ),
                ),
              ),
              //Email
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Row(
                  children: [
                    Icon(
                      Icons.email,
                      color: AppColors.bluePetrol,
                      size: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        'savethechildren@gmail.com',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              //Phone
              Padding(
                padding: const EdgeInsets.only(left: 25, top: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone,
                      color: AppColors.bluePetrol,
                      size: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        '+0034 928 50 54 31',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              //Location
              Padding(
                padding: const EdgeInsets.only(left: 25, top: 8, bottom: 18),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppColors.bluePetrol,
                      size: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        'Las Palmas de G. C.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //Button
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Container(
                  width: 290,
                  child: OutlinedButton(
                    onPressed: (){},
                    child: Text(
                      'www.savethechildren.es',
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
              ),
            ],
          ),
        ),
        Positioned(
          top: -27,
          child: /*CachedNetworkImage(
              width: 92,
              progressIndicatorBuilder:
                  (context, url, downloadProgress) => Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
              alignment: Alignment.center,
              imageUrl:
          ),*/
          Icon(
            Icons.access_time_filled,
            size: 92,
            color: AppColors.penBlue
          )
        ),
      ],
    );
  }



  Widget chipFilter(){
    return ChipsChoice<String>.multiple(
      padding: EdgeInsets.all(5),
      wrapped: true,
      value: tags,
      onChanged: (val) => setState(() => tags = val),
      choiceItems: C2Choice.listFrom<String, String>(
        source: options,
        value: (i, v) => v,
        label: (i, v) => v,
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

}