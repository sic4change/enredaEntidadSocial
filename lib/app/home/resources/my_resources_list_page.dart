import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/rounded_container.dart';
import 'package:enreda_empresas/app/home/resources/create_resource/create_resource.dart';
import 'package:enreda_empresas/app/home/resources/resource_detail_page.dart';
import 'package:enreda_empresas/app/home/resources/resources_page.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';


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
      ResourcesListPage(),
      CreateResource(socialEntityId: widget.socialEntity?.socialEntityId!),
      ResourceDetailPage(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: MyResourcesListPage.selectedIndex,
        builder: (context, selectedIndex, child) {
          return RoundedContainer(
            child: Stack(
              children: [
                Container(
                  height: 50,
                  child: Row(
                    children: [
                      InkWell(
                          onTap: () => {
                            setState(() {
                              MyResourcesListPage.selectedIndex.value = 0;
                            })
                          },
                          child: CustomTextSmall(text: 'Recursos > ')),
                      selectedIndex == 1 ? CustomTextBold(title: 'Crear recurso',) :
                      selectedIndex == 2 ? CustomTextBold(title:'Detalle del recurso') : Container()
                    ],
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(top: Sizes.mainPadding * 2),
                    child: bodyWidget[selectedIndex]),
              ],
            ),
          );
        });

  }



}
