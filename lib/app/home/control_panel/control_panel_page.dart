import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/rounded_container.dart';
import 'package:enreda_empresas/app/home/resources/build_collapsed_resources.dart';
import 'package:enreda_empresas/app/home/tool_box/tool_box_page.dart';
import 'package:enreda_empresas/app/home/web_home.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

class ControlPanelPage extends StatefulWidget {
  const ControlPanelPage({super.key, required this.socialEntity, required this.user});

  final SocialEntity? socialEntity;
  final UserEnreda? user;

  @override
  State<ControlPanelPage> createState() => _ControlPanelPageState();
}

class _ControlPanelPageState extends State<ControlPanelPage> {
  @override
  Widget build(BuildContext context) {

    return _myWelcomePage(context);
  }

  Widget _myWelcomePage(BuildContext context){
    final textTheme = Theme.of(context).textTheme;

    return RoundedContainer(
        child: SingleChildScrollView(
          child: Column(
          children: [
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10.0, right: 10.0, left: 10.0, bottom: 340.0,),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    border: Border.all(color: AppColors.greyLight2.withOpacity(0.3), width: 1),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 0, bottom: 20.0),
                    child: Flex(
                      direction: Responsive.isMobile(context) ? Axis.vertical : Axis.horizontal,
                      children: [
                        Expanded(
                          flex: Responsive.isMobile(context) ? 0 : 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text('Hola ${widget.user?.firstName},',
                                  style: textTheme.displaySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: Responsive.isMobile(context) ? 30 : 42.0,
                                      color: AppColors.turquoiseBlue),),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text(StringConst.WELCOME_COMPANY,
                                  style: textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: Responsive.isMobile(context) ? 30 : 42.0,
                                      color: Colors.black),),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 20.0),
                                child: Text(StringConst.WELCOME_TEXT,
                                  style: textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.normal,
                                      fontSize: Responsive.isMobile(context) ? 15 : 18.0,
                                      color: AppColors.greyAlt),),
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: 20,),
                        Expanded(
                            flex: Responsive.isMobile(context) ? 0 : 1,
                            child: Container(child: Image.asset(ImagePath.CONTROL_PANEL), width: 100,))
                      ]
                    ),
                  )),
                Container(
                    margin: const EdgeInsets.only(top: 340.0, right: 10.0, left: 10.0, bottom: 10.0,),
                    child: Image.asset(ImagePath.LOGO_LINES)),
                Container(
                    margin: const EdgeInsets.only(top: 350.0),
                    height: Responsive.isMobile(context) || Responsive.isDesktopS(context) ? 700 : 500,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.rectangle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0, left: 10, right: 10, bottom: 20.0),
                      child: Flex(
                          direction: Responsive.isMobile(context) || Responsive.isDesktopS(context) ? Axis.vertical : Axis.horizontal,
                          children: [
                            Expanded(
                              flex: Responsive.isMobile(context) ? 0 : 2,
                              child: Flex(
                                direction: Axis.vertical,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Flex(
                                      direction: Axis.horizontal,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Stack(
                                            children: [
                                              Container(
                                                height: double.infinity,
                                                width: double.infinity,
                                                margin: const EdgeInsets.only(top: 30.0, bottom: 30.0),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary100,
                                                  shape: BoxShape.rectangle,
                                                  borderRadius: BorderRadius.circular(15.0),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 30.0, top: 30),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        width: 300,
                                                        child: Text('Directorio Entidades',
                                                          style: textTheme.displaySmall?.copyWith(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: Responsive.isMobile(context) ? 25 : 35.0,
                                                              color: AppColors.white),),
                                                      ),
                                                      InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              WebHome.goToEntities();
                                                            });
                                                          },
                                                          child: CustomTextBold(title: 'Ver más')),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: -20,
                                                top: -20,
                                                right: -10,
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      WebHome.goToEntities();
                                                    });
                                                  },
                                                  child: Container(
                                                      child: Image.asset(ImagePath.CONTROL_PANEL_CALENDAR)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Responsive.isMobile(context) || Responsive.isDesktopS(context) ? Container() :
                                        Expanded(
                                            flex: 2,
                                            child: Container()),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20,),
                                  Expanded(
                                    flex: 1,
                                    child: Stack(
                                      children: [
                                        RoundedContainer(
                                          color: Colors.white,
                                          borderWith: 1,
                                          height: double.infinity,
                                          borderColor: AppColors.greyLight2.withOpacity(0.3),
                                          contentPadding: EdgeInsets.all(10.0),
                                          margin: EdgeInsets.zero,
                                          width: double.infinity,
                                          child: Flex(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            direction: Axis.vertical,
                                            children: [
                                              Expanded(child: CustomTextBoldTitle(title: StringConst.TOOL_BOX)),
                                              Expanded( child: InkWell(
                                                  onTap: () {
                                                    WebHome.goToolBox();
                                                    ToolBoxPage.selectedIndex.value = 1;
                                                  },
                                                  child: CustomTextMedium(text: StringConst.ENREDA_METHODOLOGY))),
                                              Expanded(child: InkWell(
                                                  onTap: () {
                                                    WebHome.goToolBox();
                                                    ToolBoxPage.selectedIndex.value = 2;
                                                  },
                                                  child: CustomTextMedium(text: StringConst.WORKFLOW))),
                                            ],
                                          ),),
                                        Positioned(
                                          bottom: -20,
                                          top: -20,
                                          right: -10,
                                          child: Container(
                                              child: Image.asset(ImagePath.CONTROL_CHECKED_BOOK)),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(width: 20,),
                            Responsive.isMobile(context) || Responsive.isDesktopS(context) ? SizedBox(height: 30,) : Container(),
                            Expanded(
                                flex: Responsive.isMobile(context) ? 0 : 1,
                                child: RoundedContainer(
                                  color: Colors.white,
                                  borderWith: 1,
                                  borderColor: AppColors.greyLight2.withOpacity(0.3),
                                  contentPadding: EdgeInsets.all(10.0),
                                  margin: EdgeInsets.zero,
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
                                        child: CustomTextBoldTitle(title: StringConst.MY_RESOURCES),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 50.0),
                                        height: double.infinity,
                                        width: double.infinity,
                                        child: CollapsedResourcesList(),),
                                    ],
                                  ),
                                )
                            )
                          ]
                      ),
                    )),

              ],
            ),

          ],
      ),
        ),
    );
  }
}
