import 'package:enreda_empresas/app/common_widgets/add_yellow_button.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/rounded_container.dart';
import 'package:enreda_empresas/app/home/social_entity/edit_social_entity/edit_social_entity_page.dart';
import 'package:enreda_empresas/app/home/social_entity/entities_list_page.dart';
import 'package:enreda_empresas/app/home/social_entity/create_social_entity/create_social_entity_page.dart';
import 'package:enreda_empresas/app/home/social_entity/entity_detail/entity_detail_page.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

class EntityDirectoryPage extends StatefulWidget {
  EntityDirectoryPage({Key? key, required this.socialEntity}) : super(key: key);
  final SocialEntity socialEntity;
  static ValueNotifier<int> selectedIndex = ValueNotifier(0);

  @override
  State<EntityDirectoryPage> createState() => _EntityDirectoryPageState();
}

class _EntityDirectoryPageState extends State<EntityDirectoryPage> {
  var bodyWidget = [];

  @override
  void initState() {
    bodyWidget = [
      EntitiesListPage(),
      CreateSocialEntityPage(),
      EntityDetailPage(socialEntityId: widget.socialEntity.socialEntityId,),
      EditSocialEntity()
    ];
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: EntityDirectoryPage.selectedIndex,
        builder: (context, selectedIndex, child) {
          return RoundedContainer(
            borderColor: Responsive.isMobile(context) ? Colors.transparent : AppColors.greyLight,
            margin: Responsive.isMobile(context) ? EdgeInsets.all(0) : EdgeInsets.all(Sizes.kDefaultPaddingDouble),
            contentPadding: Responsive.isMobile(context) ? EdgeInsets.all(0) :
              EdgeInsets.all(Sizes.kDefaultPaddingDouble * 2),
            child: Stack(
              children: [
                Flex(
                  direction: Responsive.isMobile(context) ? Axis.vertical : Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 50,
                      padding: Responsive.isMobile(context) ? EdgeInsets.only(left: Sizes.mainPadding) : EdgeInsets.all(0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                              onTap: () => {
                                setState(() {
                                  EntityDirectoryPage.selectedIndex.value = 0;
                                })
                              },
                              child: selectedIndex != 0 ? CustomTextMedium(text: 'Directorio de entidades ') :
                              CustomTextMediumBold(text: 'Directorio de entidades ') ),
                          selectedIndex == 1 ? CustomTextMediumBold(text: '> Crear entidad',) :
                          selectedIndex == 2 ? CustomTextMediumBold(text:'> Detalle de la entidad') :
                          selectedIndex == 3 ? Row(
                            children: [
                              InkWell(
                                  onTap: () => {
                                    setState(() {
                                      EntityDirectoryPage.selectedIndex.value = 2;
                                    })
                                  },
                                  child: CustomTextMedium(text:'> Detalle de la entidad ')),
                              CustomTextMediumBold(text:'> Editar entidad'),
                            ],
                          ) : Container()
                        ],
                      ),
                    ),
                    Responsive.isMobile(context) ? Container() : Spacer(),
                    selectedIndex == 0 ?
                    Padding(
                      padding: Responsive.isMobile(context) ? EdgeInsets.zero : EdgeInsets.only(right: 5.0),
                      child: Align(
                          alignment: Responsive.isMobile(context) ? Alignment.center : Alignment.topRight,
                          child: AddYellowButton(
                            text: 'Crear nueva entidad',
                            onPressed: () => setState(() {
                              setState(() {
                                EntityDirectoryPage.selectedIndex.value = 1;
                              });
                            }),
                          )
                      ),
                    ) : Container(),
                  ],
                ),
                Container(
                    margin: selectedIndex != 0 && Responsive.isMobile(context) ? EdgeInsets.only(top: Sizes.mainPadding * 2) :
                    Responsive.isMobile(context) ? EdgeInsets.only(top: Sizes.mainPadding * 5) :
                    EdgeInsets.only(top: Sizes.mainPadding * 3),
                    child: bodyWidget[selectedIndex]),
              ],
            ),
          );
        });
  }

}