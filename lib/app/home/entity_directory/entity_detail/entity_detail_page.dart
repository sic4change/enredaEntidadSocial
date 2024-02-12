import 'package:enreda_empresas/app/common_widgets/add_yellow_button.dart';
import 'package:enreda_empresas/app/common_widgets/custom_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/enreda_button.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/common_widgets/user_avatar.dart';
import 'package:enreda_empresas/app/home/resources/list_item_builder.dart';
import 'package:enreda_empresas/app/home/resources/my_resources_list_page.dart';
import 'package:enreda_empresas/app/home/resources/resource_detail/box_item_data.dart';
import 'package:enreda_empresas/app/home/resources/resource_detail/invite_users_page.dart';
import 'package:enreda_empresas/app/home/resources/resource_detail_dialog.dart';
import 'package:enreda_empresas/app/home/social_entity/box_social_network_data.dart';
import 'package:enreda_empresas/app/models/city.dart';
import 'package:enreda_empresas/app/models/country.dart';
import 'package:enreda_empresas/app/models/province.dart';
import 'package:enreda_empresas/app/models/resource.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:enreda_empresas/app/home/resources/global.dart' as globals;

import '../social_entity_category_stream.dart';


class EntityDetailPage extends StatefulWidget {
  const EntityDetailPage({Key? key, required this.socialEntityId}) : super(key: key);
  final String? socialEntityId;

  @override
  State<EntityDetailPage> createState() => _EntityDetailPageState();
}

class _EntityDetailPageState extends State<EntityDetailPage> {

  @override
  Widget build(BuildContext context) {
    return _buildResourcePage(context, globals.currentSocialEntity! );
  }

  Widget _buildResourcePage(BuildContext context, SocialEntity entity) {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<SocialEntity>(
      stream: database.socialEntityStream(globals.currentSocialEntity!.socialEntityId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator());
        }
        final socialEntity = snapshot.data!;
        return StreamBuilder<Country>(
            stream: database.countryStream(socialEntity.country),
            builder: (context, snapshot) {
              final country = snapshot.data;
              socialEntity.countryName = country == null ? '' : country.name;
              return StreamBuilder<Province>(
                stream: database.provinceStream(socialEntity.province),
                builder: (context, snapshot) {
                  final province = snapshot.data;
                  socialEntity.provinceName = province == null ? '' : province.name;
                  return StreamBuilder<City>(
                      stream: database
                          .cityStream(socialEntity.city),
                      builder: (context, snapshot) {
                        final city = snapshot.data;
                        socialEntity.cityName = city == null ? '' : city.name;
                        return _buildResourceDetail(context, socialEntity);
                      });
                },
              );
            });
      },
    );
  }

  Widget _buildResourceDetail(BuildContext context, SocialEntity socialEntity) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSizeTitle = responsiveSize(context, 14, 22, md: 18);
    double fontSizePromotor = responsiveSize(context, 12, 16, md: 14);
    return SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: Responsive.isMobile(context) ? MediaQuery.of(context).size.width * 0.8 :
              MediaQuery.of(context).size.width * 0.5,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              border: Border.all(
                  color: AppColors.greyLight2.withOpacity(0.2),
                  width: 1),
              borderRadius: BorderRadius.circular(Consts.padding),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(ImagePath.RECTANGLE_SOCIAL_ENTITY),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(Consts.padding),
                        bottomLeft: Radius.circular(Consts.padding)),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                      children: [
                        Responsive.isMobile(context)
                            ? const SpaceH8()
                            : const SpaceH20(),
                        socialEntity.photo == null ||
                            socialEntity.photo!.isEmpty
                            ? Container()
                            : Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1.0, color: AppColors.greyLight),
                                      borderRadius: BorderRadius.circular(
                                        100,
                                      ),
                                      color: AppColors.greyLight),
                                  child: CircleAvatar(
                                    radius:
                                    Responsive.isMobile(context) ? 28 : 40,
                                    backgroundColor: AppColors.white,
                                    backgroundImage:
                                    NetworkImage(socialEntity.photo!),
                                  ),
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, right: 30.0, left: 30.0),
                          child: Text(
                            socialEntity.name,
                            textAlign: TextAlign.center,
                            maxLines:
                            Responsive.isMobile(context) ? 2 : 1,
                            style: textTheme.bodySmall?.copyWith(
                              letterSpacing: 1.2,
                              color: AppColors.white,
                              height: 1.5,
                              fontWeight: FontWeight.w300,
                              fontSize: fontSizeTitle,
                            ),
                          ),
                        ),
                        const SpaceH4(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              socialEntity.actionScope!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                letterSpacing: 1.2,
                                fontSize: fontSizePromotor,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                        socialEntity.socialEntityId == widget.socialEntityId ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                              child: EnredaButtonIcon(
                                onPressed: () => {
                                  setState(() {
                                    MyResourcesListPage.selectedIndex.value = 3;
                                  })
                                },
                                buttonColor: Colors.white,
                                padding: const EdgeInsets.all(0),
                                width: 80,
                                height: 10,
                                widget: Icon(
                                  Icons.edit_outlined,
                                  color: AppColors.greyTxtAlt,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                              child: EnredaButtonIcon(
                                //onPressed: () => _confirmDeleteResource(context, resource),
                                onPressed: () => {},
                                buttonColor: Colors.white,
                                padding: const EdgeInsets.all(0),
                                width: 80,
                                height: 10,
                                widget: Icon(
                                  Icons.delete_outline,
                                  color: AppColors.greyTxtAlt,
                                ),

                              ),
                            ),
                            //buildShareButton(context, resource, AppColors.darkGray),
                            SizedBox(width: 10),
                          ],
                        ) : SizedBox(height: 30,),
                      ]
                  ),
                ),
                Flex(
                  direction: Responsive.isMobile(context) ||
                      Responsive.isTablet(context) ||
                      Responsive.isDesktopS(context)
                      ? Axis.vertical
                      : Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: Responsive.isMobile(context) ||
                            Responsive.isTablet(context) ||
                            Responsive.isDesktopS(context)
                            ? 0
                            : 4,
                        child: _buildDetailSocialEntity(context, socialEntity)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSocialEntity(BuildContext context, SocialEntity socialEntity) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInformationSocialEntity(context, socialEntity),
        ],
      ),
    );
  }

  Widget _buildInformationSocialEntity(BuildContext context, SocialEntity socialEntity) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextBold(title: StringConst.ACTION_SCOPE.toUpperCase(), color: AppColors.turquoiseBlue,),
        CustomTextSmallColor(text: socialEntity.actionScope!,),
        CustomTextBold(title: StringConst.TYPES.toUpperCase(), color: AppColors.turquoiseBlue,),
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: TypesBySocialEntity(typesIdList: socialEntity.types!,),
        ),
        CustomTextBold(title: StringConst.CATEGORY.toUpperCase(), color: AppColors.turquoiseBlue,),
        CustomTextSmallColor(text: socialEntity.category!,),
        CustomTextBold(title: StringConst.SUB_CATEGORY.toUpperCase(), color: AppColors.turquoiseBlue,),
        CustomTextSmallColor(text: socialEntity.subCategory!,),
        CustomTextBold(title: StringConst.ZONE.toUpperCase(), color: AppColors.turquoiseBlue,),
        CustomTextSmallColor(text: socialEntity.geographicZone!,),
        CustomTextBold(title: StringConst.SUB_ZONE.toUpperCase(), color: AppColors.turquoiseBlue,),
        CustomTextSmallColor(text: socialEntity.subGeographicZone!,),
        CustomTextBold(title: StringConst.SOCIAL_NETWORK.toUpperCase(), color: AppColors.turquoiseBlue,),
        _buildSocialNetworkBoxes(socialEntity),
        SizedBox(height: 20,),
        CustomTextMediumBold(text: StringConst.CONTACT_INFORMATION.toUpperCase(),),
      ],
    );
  }

  Widget _buildSocialNetworkBoxes(SocialEntity socialEntity) {
    List<BoxSocialNetworkData> boxItemDataNetwork = [
      BoxSocialNetworkData(
          icon: FontAwesomeIcons.twitter,
          title: socialEntity.twitter!,
      ),
      BoxSocialNetworkData(
        icon: FontAwesomeIcons.linkedin,
        title: socialEntity.linkedin!,
      ),
      BoxSocialNetworkData(
        icon: FontAwesomeIcons.facebook,
        title: socialEntity.otherSocialMedia!,
      ),
    ];
    const int crossAxisCount = 2; // The number of columns in the grid
    double maxCrossAxisExtent = Responsive.isMobile(context) ? 300 : 250;
    const double mainAxisExtent = 60;
    const double childAspectRatio = 30 / 2;
    const double crossAxisSpacing = 10;
    const double mainAxisSpacing = 10;
    int rowCount = (boxItemDataNetwork.length / crossAxisCount).ceil();
    double gridHeight = rowCount * mainAxisExtent + (rowCount - 1) * mainAxisSpacing;
    //double gridHeightD = rowCount * mainAxisExtent + (rowCount - 15) * mainAxisSpacing;
    return SizedBox(
      height: Responsive.isMobile(context) || Responsive.isDesktopS(context) ? gridHeight : 60,
      child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: maxCrossAxisExtent,
              mainAxisExtent: mainAxisExtent,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing),
          itemCount: boxItemDataNetwork.length,
          itemBuilder: (BuildContext context, index) {
            return BoxItemNetwork(
              icon: boxItemDataNetwork[index].icon,
              title: boxItemDataNetwork[index].title,
            );
          }),
    );
  }

  Widget _buildBoxes(Resource resource) {
    List<BoxItemData> boxItemData = [
      BoxItemData(
          icon: Icons.card_travel,
          title: StringConst.RESOURCE_TYPE,
          contact: '${resource.resourceCategoryName}'
      ),
      BoxItemData(
        icon: Icons.location_on_outlined,
        title: StringConst.LOCATION,
        contact: '${resource.countryName}',
      ),
      BoxItemData(
        icon: Icons.card_travel,
        title: StringConst.MODALITY,
        contact: '${resource.modality}',
      ),
      BoxItemData(
        icon: Icons.people,
        title: StringConst.CAPACITY,
        contact: '${resource.capacity}',
      ),
      BoxItemData(
        icon: Icons.calendar_month_outlined,
        title: StringConst.DATE,
        contact: '${DateFormat('dd/MM/yyyy').format(resource.start!)} - ${DateFormat('dd/MM/yyyy').format(resource.end!)}',
      ),
      BoxItemData(
        icon: Icons.list_alt,
        title: StringConst.CONTRACT_TYPE,
        contact: resource.contractType != null && resource.contractType != ''  ? '${resource.contractType}' : 'Sin especificar',
      ),
      BoxItemData(
        icon: Icons.alarm,
        title: StringConst.FORM_SCHEDULE,
        contact: resource.temporality != null && resource.temporality != ''  ? '${resource.temporality}' :  'Sin especificar',
      ),
      BoxItemData(
        icon: Icons.currency_exchange,
        title: StringConst.SALARY,
        contact: resource.salary != null && resource.salary != ''  ? '${resource.salary}' :  'Sin especificar',
      ),
    ];
    const int crossAxisCount = 2; // The number of columns in the grid
    const double maxCrossAxisExtent = 250;
    const double mainAxisExtent = 60;
    const double childAspectRatio = 6 / 2;
    const double crossAxisSpacing = 10;
    const double mainAxisSpacing = 10;
    int rowCount = (boxItemData.length / crossAxisCount).ceil();
    double gridHeight = rowCount * mainAxisExtent + (rowCount - 1) * mainAxisSpacing;
    double gridHeightD = rowCount * mainAxisExtent + (rowCount - 15) * mainAxisSpacing;
    return SizedBox(
      height: Responsive.isDesktop(context) ? gridHeightD : gridHeight,
      child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: maxCrossAxisExtent,
              mainAxisExtent: mainAxisExtent,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing),
          itemCount: boxItemData.length,
          itemBuilder: (BuildContext context, index) {
            return BoxItem(
              icon: boxItemData[index].icon,
              title: boxItemData[index].title,
              contact: boxItemData[index].contact,
            );
          }),
    );
  }


  Future<void> _deleteResource(BuildContext context, Resource resource) async {
    try {
      final database = Provider.of<Database>(context, listen: false);
      await database.deleteResource(resource);
    } catch (e) {
      print(e.toString());
    }
  }

  // Future<void> _confirmDeleteEntity(BuildContext context, SocialEntity socialEntity) async {
  //   final didRequestSignOut = await showAlertDialog(context,
  //       title: 'Eliminar entidad social: ${socialEntity.name} ',
  //       content: 'Si pulsa en Aceptar se procederá a la eliminación completa '
  //           'de la entidad social, esta acción no se podrá deshacer, '
  //           '¿Está seguro que quiere continuar?',
  //       cancelActionText: 'Cancelar',
  //       defaultActionText: 'Aceptar');
  //   if (didRequestSignOut == true) {
  //     _deleteResource(context, socialEntity);
  //     setState(() {
  //       MyResourcesListPage.selectedIndex.value = 0;
  //     });
  //   }
  // }
}
