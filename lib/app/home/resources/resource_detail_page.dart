import 'package:cached_network_image/cached_network_image.dart';
import 'package:enreda_empresas/app/common_widgets/alert_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/build_share_button.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/enreda_button.dart';
import 'package:enreda_empresas/app/common_widgets/precached_avatar.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/resources/list_item_builder.dart';
import 'package:enreda_empresas/app/home/resources/resource_detail/box_item_data.dart';
import 'package:enreda_empresas/app/home/resources/resource_detail_dialog.dart';
import 'package:enreda_empresas/app/home/resources/resource_interests_stream.dart';
import 'package:enreda_empresas/app/models/city.dart';
import 'package:enreda_empresas/app/models/country.dart';
import 'package:enreda_empresas/app/models/interest.dart';
import 'package:enreda_empresas/app/models/province.dart';
import 'package:enreda_empresas/app/models/resource.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:enreda_empresas/app/home/resources/global.dart' as globals;
import 'my_resources_list_page.dart';

class ResourceDetailPage extends StatefulWidget {
  const ResourceDetailPage({Key? key}) : super(key: key);

  @override
  State<ResourceDetailPage> createState() => _ResourceDetailPageState();
}

class _ResourceDetailPageState extends State<ResourceDetailPage> {
  String? socialEntityId;
  SocialEntity? organizer;

  @override
  Widget build(BuildContext context) {
    return _buildResourcePage(context, globals.currentResource! );
  }

  Widget _buildResourcePage(BuildContext context, Resource resource) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSizeTitle = responsiveSize(context, 14, 22, md: 18);
    double fontSizePromotor = responsiveSize(context, 12, 16, md: 14);
    List<String> interestsLocal = [];
    Set<Interest> selectedInterests = {};
    String? interestsNames;
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<Resource>(
        stream: database.resourceStream(resource.resourceId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            Resource resource = snapshot.data!;
            resource.setResourceTypeName();
            resource.setResourceCategoryName();
            if (resource.resourceId == null) {
              return const Center(
                  child: CircularProgressIndicator());
            }
            return StreamBuilder<SocialEntity>(
              stream: database.socialEntityStream(resource.organizer),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                final organization = snapshot.data;
                organizer = organization;
                globals.organizerCurrentResource = organization;
                socialEntityId = resource.organizer;
                resource.organizerName =
                organization == null ? '' : organization.name;
                resource.organizerImage =
                organization == null ? '' : organization.photo;
                interestsLocal = resource.interests ?? [];
                globals.interestsCurrentResource = resource.interests ?? [];
                resource.setResourceTypeName();
                resource.setResourceCategoryName();
                return StreamBuilder<Country>(
                    stream: database.countryStream(resource.country),
                    builder: (context, snapshot) {
                      final country = snapshot.data;
                      resource.countryName = country == null ? '' : country.name;
                      resource.province ?? "";
                      resource.city ?? "";
                      return StreamBuilder<Province>(
                        stream: database.provinceStream(resource.province),
                        builder: (context, snapshot) {
                          final province = snapshot.data;
                          resource.provinceName = province == null ? '' : province.name;
                          return StreamBuilder<City>(
                              stream: database
                                  .cityStream(resource.city),
                              builder: (context, snapshot) {
                                final city = snapshot.data;
                                resource.cityName = city == null ? '' : city.name;
                                return StreamBuilder<List<Interest>>(
                                    stream: database.resourcesInterestsStream(interestsLocal),
                                    builder: (context, snapshotInterest) {
                                      if (snapshotInterest.hasData) {
                                        selectedInterests = snapshotInterest.data!.toSet();
                                        globals.selectedInterestsCurrentResource = snapshotInterest.data!.toSet();
                                        var concatenate = StringBuffer();
                                        for (var item in selectedInterests) {
                                          concatenate.write('${item.name} / ');
                                        }
                                        interestsNames = concatenate.toString();
                                        globals.interestsNamesCurrentResource = concatenate.toString();
                                        return SingleChildScrollView(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Flex(
                                                direction: Responsive.isMobile(context) ||
                                                    Responsive.isTablet(context) ||
                                                    Responsive.isDesktopS(context)
                                                    ? Axis.vertical
                                                    : Axis.horizontal,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                      flex: Responsive.isMobile(context) ||
                                                          Responsive.isTablet(context) ||
                                                          Responsive.isDesktopS(context)
                                                          ? 0
                                                          : 6,
                                                      child: Stack(
                                                        children: [
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.rectangle,
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
                                                                      image: AssetImage(ImagePath.RECTANGLE_RESOURCE),
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
                                                                      resource.organizerImage == null ||
                                                                          resource.organizerImage!.isEmpty
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
                                                                            NetworkImage(resource.organizerImage!),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(top: 10, right: 30.0, left: 30.0),
                                                                        child: Text(
                                                                          resource.title,
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
                                                                            resource.promotor != null
                                                                                ? resource.promotor != ""
                                                                                ? resource.promotor!
                                                                                : resource.organizerName!
                                                                                : resource.organizerName!,
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
                                                                      Row(
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
                                                                              onPressed: () => _confirmDeleteResource(context, resource),
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
                                                                          buildShareButton(context, resource, AppColors.darkGray),
                                                                          SizedBox(width: 10),
                                                                        ],
                                                                      ),
                                                                    ]
                                                                  ),
                                                                ),
                                                                Container(
                                                                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                                                  constraints: BoxConstraints(
                                                                    maxHeight: 150,
                                                                    maxWidth:
                                                                    Responsive.isMobile(context) || Responsive.isDesktopS(context)
                                                                        ? MediaQuery.of(context).size.width
                                                                        : MediaQuery.of(context).size.width / 1.5,
                                                                  ),
                                                                  child: _buildBoxes(resource),
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
                                                                        child: _buildDetailResource(
                                                                            context, resource)),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      )),
                                                  Expanded(
                                                      flex: Responsive.isMobile(context) ||
                                                          Responsive.isTablet(context) ||
                                                          Responsive.isDesktopS(context)
                                                          ? 0
                                                          : 3,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: AppColors.greyLight2.withOpacity(0.2),
                                                              width: 1),
                                                          borderRadius: BorderRadius.circular(Consts.padding),
                                                        ),
                                                        alignment: Alignment.center,
                                                        margin: Responsive.isMobile(context) ?  EdgeInsets.only(top: 10) : EdgeInsets.only(left: 10),
                                                        padding: const EdgeInsets.all(20.0),
                                                        child: SingleChildScrollView(
                                                            child: Stack(
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    CustomTextTitle(title: '${resource.participants?.length.toString()} ${StringConst.PARTICIPANTS.toUpperCase()}', color: AppColors.turquoiseBlue),
                                                                  ],
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 30.0),
                                                                  child: _buildParticipantsList(context, resource.resourceId!),
                                                                ),
                                                              ],
                                                            )),
                                                      ))
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      return Container();
                                    });
                              });
                        },
                      );
                    });
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  Widget _buildDetailResource(BuildContext context, Resource resource) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringConst.FORM_DESCRIPTION.toUpperCase(),
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.turquoiseBlue,
            ),
          ),
          const SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text(
              resource.description,
              textAlign: TextAlign.left,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.greyTxtAlt,
                height: 1.5,
              ),
            ),
          ),
          _buildInformationResource(context, resource),
        ],
      ),
    );
  }

  Widget _buildInformationResource(BuildContext context, Resource resource) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConst.FORM_INTERESTS.toUpperCase(),
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.turquoiseBlue,
          ),
        ),
        const SizedBox(height: 10,),
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: InterestsByResource(interestsIdList: resource.interests!,),
        ),
        const SizedBox(height: 10,),
        Text(
          StringConst.AVAILABLE.toUpperCase(),
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.turquoiseBlue,
          ),
        ),
        Container(
            width: 130,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  color: AppColors.greyLight2.withOpacity(0.2),
                  width: 1),
              borderRadius: BorderRadius.circular(Consts.padding),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(4.0),
            margin: const EdgeInsets.only(top: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                    color: resource.status == "No disponible" ? Colors.red : Colors.lightGreenAccent,
                    borderRadius: BorderRadius.circular(Consts.padding),
                  ),
                ),
                const SizedBox(width: 8),
                CustomTextBody(text: resource.status!),
              ],
            )),
        const SizedBox(height: 30,),
      ],
    );
  }

  Widget _buildBoxes(Resource resource) {
    List<BoxItemData> boxItemData = [
      BoxItemData(
          icon: Icons.card_travel,
          title: StringConst.RESOURCE_TYPE,
          contact: '${resource.resourceTypeName}'
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
    return GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 250,
            mainAxisExtent: 60,
            childAspectRatio: 6 / 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        itemCount: boxItemData.length,
        itemBuilder: (BuildContext context, index) {
          return BoxItem(
            icon: boxItemData[index].icon,
            title: boxItemData[index].title,
            contact: boxItemData[index].contact,
          );
        });
  }

  // Widget _buildDetailCard(BuildContext context, Resource resource) {
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     margin: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       border: Border.all(color: AppColors.greyDark, width: 1),
  //       borderRadius: const BorderRadius.all(Radius.circular(10)),
  //     ),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         CustomTextTitle(title: StringConst.RESOURCE_TYPE.toUpperCase()),
  //         CustomTextBody(text: '${resource.resourceTypeName}'),
  //         const SpaceH16(),
  //         CustomTextTitle(title: StringConst.LOCATION.toUpperCase()),
  //         Row(
  //           children: [
  //             CustomTextBody(text: '${resource.cityName}'),
  //             resource.address?.province == "undefined" ? Container() : CustomTextBody(text: ', '),
  //             CustomTextBody(text: '${resource.provinceName}'),
  //             resource.address?.country == "undefined" ? Container() : CustomTextBody(text: ', '),
  //             CustomTextBody(text: '${resource.countryName}'),
  //           ],
  //         ),
  //         const SpaceH16(),
  //         CustomTextTitle(title: StringConst.MODALITY.toUpperCase()),
  //         CustomTextBody(text: resource.modality!),
  //         const SpaceH16(),
  //         CustomTextTitle(title: StringConst.CAPACITY.toUpperCase()),
  //         CustomTextBody(text: '${resource.capacity}'),
  //         const SpaceH16(),
  //         CustomTextTitle(title: StringConst.DATE.toUpperCase()),
  //         DateFormat('dd/MM/yyyy').format(resource.start!) == '31/12/2050'
  //             ? const CustomTextBody(
  //           text: StringConst.ALWAYS_AVAILABLE,
  //         )
  //             : Row(
  //           children: [
  //             CustomTextBody(
  //                 text: DateFormat('dd/MM/yyyy').format(resource.start!)),
  //             const SpaceW4(),
  //             const CustomTextBody(text: '-'),
  //             const SpaceW4(),
  //             CustomTextBody(
  //                 text: DateFormat('dd/MM/yyyy').format(resource.end!))
  //           ],
  //         ),
  //         const SpaceH16(),
  //         CustomTextTitle(title: StringConst.CONTRACT_TYPE.toUpperCase()),
  //         CustomTextBody(text: resource.contractType != null && resource.contractType != ''  ? '${resource.contractType}' : 'Sin especificar' ),
  //         const SpaceH16(),
  //         CustomTextTitle(title: StringConst.DURATION.toUpperCase()),
  //         CustomTextBody(text: resource.duration!),
  //         const SpaceH16(),
  //         CustomTextTitle(title: StringConst.SALARY.toUpperCase()),
  //         CustomTextBody(text: resource.salary != null && resource.salary != ''  ? '${resource.salary}' :  'Sin especificar'),
  //         const SpaceH16(),
  //         CustomTextTitle(title: StringConst.FORM_SCHEDULE.toUpperCase()),
  //         CustomTextBody(text: resource.temporality != null && resource.temporality != ''  ? '${resource.temporality}' :  'Sin especificar'),
  //         const SpaceH16(),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildParticipantsList(BuildContext context, String resourceId) {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<List<UserEnreda>>(
      stream: database.participantsByResourceStream(resourceId),
      builder: (context, snapshot) {
        return ListItemBuilder(
            snapshot: snapshot,
            emptyTitle: 'Sin participantes',
            emptyMessage: 'Aún no se ha registrado ningún participante',
            itemBuilder: (context, user) {
              return  Container(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: AppColors.greyLight2.withOpacity(0.2),
                      width: 1),
                  borderRadius: BorderRadius.circular(Consts.padding * 2),
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      _buildMyUserPhoto(context, user.photo!),
                      const SpaceW20(),
                      Text('${user.firstName!} ${user.lastName!}'),
                    ],
                  ),
                ),
              );
            }
        );
      },
    );
  }

  Widget _buildMyUserPhoto(BuildContext context, String profilePic) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            !kIsWeb ?
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(60)),
              child:
              Center(
                child:
                profilePic == "" ?
                Container(
                  color:  Colors.transparent,
                  height: 40,
                  width: 40,
                  child: Image.asset(ImagePath.USER_DEFAULT),
                ):
                CachedNetworkImage(
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    imageUrl: profilePic),
              ),
            ):
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(60)),
              child:
              profilePic == "" ?
              Container(
                color:  Colors.transparent,
                height: 40,
                width: 40,
                child: Image.asset(ImagePath.USER_DEFAULT),
              ):
              PrecacheAvatarCard(
                imageUrl: profilePic,
                width: 35,
                height: 35,
              ),
            )
          ],
        ),
      ],
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

  Future<void> _confirmDeleteResource(BuildContext context, Resource resource) async {
    final didRequestSignOut = await showAlertDialog(context,
        title: 'Eliminar recurso: ${resource.title} ',
        content: 'Si pulsa en Aceptar se procederá a la eliminación completa '
            'del recurso, esta acción no se podrá deshacer, '
            '¿Está seguro que quiere continuar?',
        cancelActionText: 'Cancelar',
        defaultActionText: 'Aceptar');
    if (didRequestSignOut == true) {
      _deleteResource(context, resource);
      setState(() {
        MyResourcesListPage.selectedIndex.value = 0;
      });
    }
  }
}
