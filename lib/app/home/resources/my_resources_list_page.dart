import 'package:enreda_empresas/app/common_widgets/add_yellow_button.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/rounded_container.dart';
import 'package:enreda_empresas/app/home/resources/create_resource/create_resource.dart';
import 'package:enreda_empresas/app/home/resources/edit_resource/edit_resource.dart';
import 'package:enreda_empresas/app/home/resources/resource_detail/resource_detail_page.dart';
import 'package:enreda_empresas/app/home/resources/resources_list.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

import 'my_resources_page.dart';


class MyResourcesListPage extends StatefulWidget {
  const MyResourcesListPage({super.key, required this.socialEntity});
  final SocialEntity? socialEntity;

  static ValueNotifier<int> selectedIndex = ValueNotifier(0);

  @override
  State<MyResourcesListPage> createState() => _MyResourcesListPageState();
}

class _MyResourcesListPageState extends State<MyResourcesListPage> {
  bool? isVisible = true;
  List<UserEnreda>? myParticipantsList = [];
  List<String>? interestsIdsList = [];
  SocialEntity? organizer;
  List<String> interestSelectedName = [];
  var bodyWidget = [];

  @override
  void initState() {
    bodyWidget = [
      MyResourcesPage(),
      CreateResource(socialEntityId: widget.socialEntity?.socialEntityId!),
      ResourceDetailPage(socialEntityId: widget.socialEntity?.socialEntityId!),
      EditResource()
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: MyResourcesListPage.selectedIndex,
        builder: (context, selectedIndex, child) {
          return RoundedContainer(
            borderColor: Responsive.isMobile(context) ? Colors.transparent : AppColors.greyLight,
            color: AppColors.grey80,
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
                      padding: Responsive.isMobile(context) ? EdgeInsets.only(left: Sizes.kDefaultPaddingDouble / 2) :
                        EdgeInsets.zero,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => {
                              setState(() {
                                MyResourcesListPage.selectedIndex.value = 0;
                              })
                            },
                            child: selectedIndex != 0 ? CustomTextMedium(text: 'Recursos ') :
                              CustomTextMediumBold(text: 'Recursos ') ),
                              selectedIndex == 1 ? CustomTextMediumBold(text: '> Crear recurso',) :
                              selectedIndex == 2 ? CustomTextMediumBold(text:'> Detalle del recurso') :
                              selectedIndex == 3 ? Row(
                            children: [
                              InkWell(
                                  onTap: () => {
                                    setState(() {
                                      MyResourcesListPage.selectedIndex.value = 2;
                                    })
                                  },
                                  child: CustomTextMedium(text:'> Detalle del recurso ')),
                              CustomTextMediumBold(text:'> Editar recurso'),
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
                            text: 'Crear nuevo recurso',
                            onPressed: () => setState(() {
                              setState(() {
                                MyResourcesListPage.selectedIndex.value = 1;
                              });
                            }),
                          )
                      ),
                    ) : Container(),
                  ],
                ),
                Container(
                    margin: selectedIndex != 0 && Responsive.isMobile(context) ? EdgeInsets.only(top: Sizes.mainPadding * 2) :
                    Responsive.isMobile(context) ? EdgeInsets.only(top: Sizes.mainPadding * 6, left: Sizes.mainPadding / 2) : EdgeInsets.only(top: Sizes.mainPadding * 3),
                    child: bodyWidget[selectedIndex]),
              ],
            ),
          );
        });

  }

}
