
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/rounded_container.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/participants/participants_page.dart';
import 'package:enreda_empresas/app/home/participants/participants_tile.dart';
import 'package:enreda_empresas/app/home/web_home.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/auth.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/my_custom_scroll_behavior.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enreda_empresas/app/home/resources/global.dart' as globals;

class MyParticipantsScrollPage extends StatefulWidget {
  const MyParticipantsScrollPage({Key? key}) : super(key: key);

  @override
  State<MyParticipantsScrollPage> createState() => _MyParticipantsScrollPageState();
}

class _MyParticipantsScrollPageState extends State<MyParticipantsScrollPage> {
  @override
  Widget build(BuildContext context) {
    return buildParticipantsList(context);
  }

  Widget buildParticipantsList(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    return RoundedContainer(
      color: Colors.white,
      borderWith: 1,
      borderColor: AppColors.greyLight2.withOpacity(0.3),
      contentPadding: EdgeInsets.all(20.0),
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextBoldTitle(title: StringConst.MY_PARTICIPANTS),
          SpaceH4(),
          StreamBuilder<UserEnreda>(
              stream: database.userEnredaStreamByUserId(auth.currentUser!.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData) {
                  globals.currentSocialEntityUser = snapshot.data!;
                  UserEnreda socialEntityUser = snapshot.data!;
                  final controller = ScrollController();
                  var scrollJump = Responsive.isDesktopS(context) ? 350 : 410;
                  return StreamBuilder<List<UserEnreda>>(
                    stream: database.getParticipantsBySocialEntityStream(socialEntityUser.socialEntityId!),
                    builder: (context, userSnapshot) {
                      if(userSnapshot.hasData) {
                        final participants = userSnapshot.data!;
                        final myParticipants = participants.where((user) =>
                        user.assignedEntityId == socialEntityUser.socialEntityId!
                            && user.assignedById == socialEntityUser.userId).toList();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: Responsive.isDesktop(context) ? 382.0 : 180.0,
                              color: Colors.white,
                              child: ScrollConfiguration(
                                behavior: MyCustomScrollBehavior(),
                                child: ListView(
                                  controller: controller,
                                  scrollDirection: Axis.horizontal,
                                  children: myParticipants.map((user) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ParticipantsListTile(
                                          user: user,
                                          socialEntityUserId: socialEntityUser.socialEntityId!,
                                          onTap: () => setState(() {
                                            globals.currentParticipant = user;
                                            WebHome.goToParticipants();
                                            ParticipantsListPage.selectedIndex.value = 1;
                                          })
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (controller.position.pixels >=
                                        controller.position.minScrollExtent)
                                      controller.animateTo(
                                          controller.position.pixels - scrollJump,
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.ease);
                                  },
                                  child: Image.asset(
                                    ImagePath.ARROW_BACK,
                                    width: 36.0,
                                  ),
                                ),
                                SpaceW12(),
                                InkWell(
                                  onTap: () {
                                    if (controller.position.pixels <=
                                        controller.position.maxScrollExtent)
                                      controller.animateTo(
                                          controller.position.pixels + scrollJump,
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.ease);
                                  },
                                  child: Image.asset(
                                    ImagePath.ARROW_FORWARD,
                                    width: 36.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    });
                }
                return const Center(child: CircularProgressIndicator());
              }),
        ],
      ),
    );
  }
}
