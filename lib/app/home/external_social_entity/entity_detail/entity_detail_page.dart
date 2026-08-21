import 'package:cached_network_image/cached_network_image.dart';
import 'package:enreda_empresas/app/common_widgets/alert_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/enreda_button.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/resources/resource_detail_dialog.dart';
import 'package:enreda_empresas/app/models/city.dart';
import 'package:enreda_empresas/app/models/country.dart';
import 'package:enreda_empresas/app/models/province.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/external_entities_cache.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:enreda_empresas/app/home/resources/global.dart' as globals;

import '../../../models/externalSocialEntity.dart';
import '../../../services/auth.dart';
import '../../../utils/functions.dart';
import '../entity_directory_page.dart';
import 'box_social_entity_contact.dart';
import 'box_social_network_data.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/models/interest.dart';
import 'package:enreda_empresas/app/models/scope_action.dart';
import 'social_entity_category_stream.dart';

class ExternalEntityDetailPage extends StatefulWidget {
  const ExternalEntityDetailPage({Key? key, required this.socialEntityId}) : super(key: key);
  final String? socialEntityId;

  @override
  State<ExternalEntityDetailPage> createState() => _ExternalEntityDetailPageState();
}

class _ExternalEntityDetailPageState extends State<ExternalEntityDetailPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _getActionScopeNames(ExternalSocialEntity entity) {
    if (entity.actionScope == null || entity.actionScope!.isEmpty) return '';
    if (entity.category == 'Empresas /Asociaciones empresariales/Clúster') {
      return entity.actionScope!.map((id) {
        try {
          return LocationCache.instance.interests.firstWhere((e) => e.interestId == id).name;
        } catch (_) {
          return '';
        }
      }).where((name) => name.isNotEmpty).join(', ');
    } else {
      return entity.actionScope!.map((id) {
        try {
          return LocationCache.instance.scopeActions.firstWhere((e) => e.id == id).name;
        } catch (_) {
          return '';
        }
      }).where((name) => name.isNotEmpty).join(', ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildResourcePage(context);
  }

  Widget _buildResourcePage(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return globals.currentExternalSocialEntity!.externalSocialEntityId == null ? const Center(child: CircularProgressIndicator()) :
    StreamBuilder<ExternalSocialEntity>(
      stream: database.externalSocialEntityByIdStream(globals.currentExternalSocialEntity!.externalSocialEntityId!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator());
        }
        final externalSocialEntity = snapshot.data!;
        return StreamBuilder<Country>(
            stream: database.countryStream(externalSocialEntity.address?.country),
            builder: (context, snapshot) {
              final country = snapshot.data;
              externalSocialEntity.countryName = country == null ? '' : country.name;
              return StreamBuilder<Province>(
                stream: database.provinceStream(externalSocialEntity.address?.province),
                builder: (context, snapshot) {
                  final province = snapshot.data;
                  externalSocialEntity.provinceName = province == null ? '' : province.name;
                  return StreamBuilder<City>(
                      stream: database
                          .cityStream(externalSocialEntity.address?.city),
                      builder: (context, snapshot) {
                        final city = snapshot.data;
                        externalSocialEntity.cityName = city == null ? '' : city.name;
                        return _buildResourceDetail(context, externalSocialEntity);
                      });
                },
              );
            });
      },
    );
  }

  Widget _buildResourceDetail(BuildContext context, ExternalSocialEntity externalSocialEntity) {
    TextTheme textTheme = Theme.of(context).textTheme;
    final auth = Provider.of<AuthBase>(context, listen: false);
    double fontSizeTitle = responsiveSize(context, 14, 22, md: 18);
    double fontSizePromotor = responsiveSize(context, 12, 16, md: 14);
    return SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: Responsive.isMobile(context) ? MediaQuery.of(context).size.width - 4  :
              MediaQuery.of(context).size.width * 0.5,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              border: Border.all(
                  color: Responsive.isMobile(context) ? Colors.transparent : AppColors.greyLight2.withOpacity(0.2),
                  width: 1),
              borderRadius: Responsive.isMobile(context) ? BorderRadius.zero : BorderRadius.circular(Consts.padding),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(ImagePath.RECTANGLE_SOCIAL_ENTITY),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: Responsive.isMobile(context) ? BorderRadius.zero : BorderRadius.only(
                        bottomRight: Radius.circular(Consts.padding),
                        bottomLeft: Radius.circular(Consts.padding)),
                  ),
                  margin: Responsive.isMobile(context) ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                      children: [
                        Responsive.isMobile(context)
                            ? const SpaceH8()
                            : const SpaceH20(),
                        externalSocialEntity.photo == null ||
                            externalSocialEntity.photo!.isEmpty
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
                                    CachedNetworkImageProvider(externalSocialEntity.photo!),
                                    onBackgroundImageError: (_, __) {},
                                  ),
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, right: 30.0, left: 30.0),
                          child: Text(
                            externalSocialEntity.name,
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
                              _getActionScopeNames(externalSocialEntity),
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
                        auth.currentUser?.uid == externalSocialEntity.createdBy ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                              child: EnredaButtonIcon(
                                onPressed: () => {
                                  setState(() {
                                    EntityDirectoryPage.selectedIndex.value = 3;
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
                                onPressed: () => _confirmDeleteSocialEntity(context, externalSocialEntity),
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
                _buildSocialEntityContactBoxes(externalSocialEntity),
                SizedBox(height: 15,),
                _buildDetailSocialEntity(context, externalSocialEntity),
                externalSocialEntity.website == null || externalSocialEntity.website == '' ? Container() :
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Container(
                    width: 290,
                    child: OutlinedButton(
                        onPressed: (){
                          launchURL(externalSocialEntity.website!);
                        },
                        child: Text(
                          externalSocialEntity.website!,
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
                SizedBox(height: 20,)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSocialEntity(BuildContext context, ExternalSocialEntity socialEntity) {
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

  Widget _buildInformationSocialEntity(BuildContext context, ExternalSocialEntity externalSocialEntity) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        externalSocialEntity.actionScope == null || externalSocialEntity.actionScope!.isEmpty ? Container() :
        CustomTextBold(title: StringConst.ACTION_SCOPE.toUpperCase(), color: AppColors.turquoiseBlue,),
        externalSocialEntity.actionScope == null || externalSocialEntity.actionScope!.isEmpty ? Container() :
        CustomTextSmallColor(text: _getActionScopeNames(externalSocialEntity),),

        (() {
          final bool hasPdfUrl = externalSocialEntity.signedAgreements != null &&
              (externalSocialEntity.signedAgreements!.startsWith('http://') || externalSocialEntity.signedAgreements!.startsWith('https://'));
          final bool hasAgreement = hasPdfUrl || externalSocialEntity.signedAgreementsDate != null;
          if (!hasAgreement) return Container();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextBold(title: StringConst.FORM_ENTITY_SIGNED_AGREEMENTS.toUpperCase(), color: AppColors.turquoiseBlue,),
              if (externalSocialEntity.signedAgreementsDate != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: CustomTextSmallColor(
                    text: 'Fecha de renovación: ${DateFormat('dd/MM/yyyy').format(externalSocialEntity.signedAgreementsDate!)}',
                  ),
                ),
              if (hasPdfUrl)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextButton.icon(
                    onPressed: () => launchURL(externalSocialEntity.signedAgreements!),
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                    label: const Text(
                      'Descargar / Ver acuerdo (PDF)',
                      style: TextStyle(color: AppColors.turquoiseBlue, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
            ],
          );
        })(),

        externalSocialEntity.offeredServices == null || externalSocialEntity.offeredServices == '' ? Container() :
        CustomTextBold(title: 'INICIATIVAS O SERVICIOS OFRECIDOS', color: AppColors.turquoiseBlue,),
        externalSocialEntity.offeredServices == null || externalSocialEntity.offeredServices == '' ? Container() :
        CustomTextSmallColor(text: externalSocialEntity.offeredServices!),

        externalSocialEntity.category == null || externalSocialEntity.category == '' ? Container() :
        CustomTextBold(title: StringConst.CATEGORY.toUpperCase(), color: AppColors.turquoiseBlue,),
        externalSocialEntity.category == null || externalSocialEntity.category == '' ? Container() :
        CustomTextSmallColor(text: externalSocialEntity.category!,),

        externalSocialEntity.geographicZone == null || externalSocialEntity.geographicZone == '' ? Container() :
        CustomTextBold(title: StringConst.ZONE.toUpperCase(), color: AppColors.turquoiseBlue,),
        externalSocialEntity.geographicZone == null || externalSocialEntity.geographicZone == '' ? Container() :
        CustomTextSmallColor(text: externalSocialEntity.geographicZone!,),

        externalSocialEntity.subGeographicZone == null || externalSocialEntity.subGeographicZone == '' ? Container() :
        CustomTextBold(title: StringConst.SUB_ZONE.toUpperCase(), color: AppColors.turquoiseBlue,),
        externalSocialEntity.subGeographicZone == null || externalSocialEntity.subGeographicZone == '' ? Container() :
        CustomTextSmallColor(text: externalSocialEntity.subGeographicZone!,),

        externalSocialEntity.twitter == null || externalSocialEntity.twitter == '' &&
        externalSocialEntity.linkedin == null || externalSocialEntity.linkedin == '' &&
        externalSocialEntity.otherSocialMedia == null || externalSocialEntity.otherSocialMedia == '' ? Container() :
        CustomTextBold(title: StringConst.SOCIAL_NETWORK.toUpperCase(), color: AppColors.turquoiseBlue,),
        externalSocialEntity.twitter == null || externalSocialEntity.twitter == '' &&
            externalSocialEntity.linkedin == null || externalSocialEntity.linkedin == '' &&
            externalSocialEntity.otherSocialMedia == null || externalSocialEntity.otherSocialMedia == '' ? Container() :
        _buildSocialNetworkBoxes(externalSocialEntity),
        SizedBox(height: 20,),


        externalSocialEntity.contactName == null || externalSocialEntity.contactName == '' &&
        externalSocialEntity.contactPhone == null || externalSocialEntity.contactPhone == '' &&
        externalSocialEntity.contactEmail == null || externalSocialEntity.contactEmail == '' &&
        externalSocialEntity.contactPosition == null || externalSocialEntity.contactPosition == '' &&
        externalSocialEntity.contactChoiceGrade == null || externalSocialEntity.contactChoiceGrade == '' &&
        externalSocialEntity.contactKOL == null || externalSocialEntity.contactKOL == '' ? Container() :
        CustomTextMediumBold(text: StringConst.CONTACT_INFORMATION.toUpperCase(),),

        externalSocialEntity.contactName == null || externalSocialEntity.contactName == '' ? Container() :
        CustomTextSmallColor(text: externalSocialEntity.contactName!, padding: const EdgeInsets.only(bottom: 10.0),),

        externalSocialEntity.contactPhone == null || externalSocialEntity.contactPhone == '' ? Container() :
        CustomTextSmallColor(text: externalSocialEntity.contactPhone!, padding: const EdgeInsets.only(bottom: 10.0), height: 0,),

        externalSocialEntity.contactEmail == null || externalSocialEntity.contactEmail == '' ? Container() :
        CustomTextSmallColor(text: externalSocialEntity.contactEmail!),

        externalSocialEntity.contactPosition == null || externalSocialEntity.contactPosition == '' ? Container() :
        CustomTextBold(title: StringConst.CONTACT_POSITION.toUpperCase(), color: AppColors.turquoiseBlue,),
        externalSocialEntity.contactPosition == null || externalSocialEntity.contactPosition == '' ? Container() :
        CustomTextSmallColor(text: externalSocialEntity.contactPosition!),

        externalSocialEntity.contactChoiceGrade == null || externalSocialEntity.contactChoiceGrade == '' ? Container() :
        CustomTextBold(title: StringConst.CONTACT_CHOICE_GRADE.toUpperCase(), color: AppColors.turquoiseBlue,),
        externalSocialEntity.contactChoiceGrade == null || externalSocialEntity.contactChoiceGrade == '' ? Container() :
        CustomTextSmallColor(text: externalSocialEntity.contactChoiceGrade!),

        externalSocialEntity.contactKOL == null || externalSocialEntity.contactKOL == '' ? Container() :
        CustomTextBold(title: StringConst.CONTACT_OPINION_LEADER.toUpperCase(), color: AppColors.turquoiseBlue,),
        externalSocialEntity.contactKOL == null || externalSocialEntity.contactKOL == '' ? Container() :
        CustomTextSmallColor(text: externalSocialEntity.contactKOL!),

        externalSocialEntity.contactKOL == 'Si' && externalSocialEntity.kolType != null && externalSocialEntity.kolType != '' ? CustomTextBold(title: 'TIPO DE KOL', color: AppColors.turquoiseBlue,) : Container(),
        externalSocialEntity.contactKOL == 'Si' && externalSocialEntity.kolType != null && externalSocialEntity.kolType != '' ? CustomTextSmallColor(text: externalSocialEntity.kolType!) : Container(),

        (externalSocialEntity.referencePeople == null || externalSocialEntity.referencePeople!.isEmpty) ? Container() :
        CustomTextMediumBold(text: StringConst.REFERENCE_PEOPLE.toUpperCase(),),
        for (final person in externalSocialEntity.referencePeople ?? [])
          CustomTextSmallColor(
            text: [person.name, person.phone].where((s) => s.isNotEmpty).join(' - '),
            padding: const EdgeInsets.only(bottom: 10.0),
            height: 0,
          ),
      ],
    );
  }

  Widget _buildSocialNetworkBoxes(ExternalSocialEntity externalSocialEntity) {
    List<BoxSocialNetworkData> boxItemDataNetwork = [
      BoxSocialNetworkData(
          icon: FontAwesomeIcons.xTwitter,
          title: externalSocialEntity.twitter!,
      ),
      BoxSocialNetworkData(
        icon: FontAwesomeIcons.linkedinIn,
        title: externalSocialEntity.linkedin!,
      ),
      BoxSocialNetworkData(
        icon: FontAwesomeIcons.facebookF,
        title: externalSocialEntity.otherSocialMedia!,
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

  Widget _buildSocialEntityContactBoxes(ExternalSocialEntity externalSocialEntity) {
    List<BoxSocialEntityContactData> boxItemDataSocialEntity = [
      BoxSocialEntityContactData(
        icon: Icons.email,
        title: externalSocialEntity.email!,
        onPressed: () { launchURL('mailto:${externalSocialEntity.email}?subject=Contacto ${externalSocialEntity.name}');},
      ),
      BoxSocialEntityContactData(
        icon: Icons.phone,
        title: externalSocialEntity.entityPhone!,
      ),
    ];
    return Padding(
      padding: Responsive.isMobile(context) || Responsive.isDesktopS(context) ? const EdgeInsets.all(20.0) :
        const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: boxItemDataSocialEntity.map((data) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7.5),
              child: BoxItemSocialEntityContact(
                icon: data.icon,
                title: data.title,
                onPressed: data.onPressed,
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  Future<void> _deleteSocialEntity(BuildContext context, ExternalSocialEntity externalSocialEntity) async {
    try {
      final database = Provider.of<Database>(context, listen: false);
      await database.deleteExternalSocialEntity(externalSocialEntity);
      ExternalEntitiesCache.instance.invalidate();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _confirmDeleteSocialEntity(BuildContext context, ExternalSocialEntity externalSocialEntity) async {
    final didRequestSignOut = await showAlertDialog(context,
        title: 'Eliminar contacto: ${externalSocialEntity.name} ',
        content: StringConst.DELETE_DOCUMENT,
        cancelActionText: 'Cancelar',
        defaultActionText: 'Aceptar');
    if (didRequestSignOut == true) {
      _deleteSocialEntity(context, externalSocialEntity);
      setState(() {
        EntityDirectoryPage.selectedIndex.value = 0;
      });
    }
  }
}
