
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/rounded_container.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/participants/participants_page.dart';
import 'package:enreda_empresas/app/home/participants/participants_tile.dart';
import 'package:enreda_empresas/app/home/web_home.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/auth.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
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
      contentPadding: Responsive.isMobile(context) || Responsive.isDesktopS(context) ? EdgeInsets.all(10.0) : EdgeInsets.all(20.0),
      margin: Responsive.isMobile(context) || Responsive.isDesktopS(context) ? EdgeInsets.all(0) : EdgeInsets.only(left: 30, right: 10, bottom: 10, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomTextBoldTitle(title: StringConst.MY_PARTICIPANTS),
          SpaceH4(),
          // Step 1: Load the logged-in collaborator's UserEnreda doc
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

                  // Step 2: Load the SocialEntity to retrieve the entity's programs list
                  return StreamBuilder<SocialEntity>(
                    stream: database.socialEntityStream(socialEntityUser.socialEntityId),
                    builder: (context, entitySnapshot) {
                      if (!entitySnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final socialEntity = entitySnapshot.data!;
                      final programs = socialEntity.programs ?? [];

                      // Step 3: Query participants from cache (limited for preview)
                      LocationCache.instance.startParticipantsPreview(database, socialEntityUser.socialEntityId!, programs);
                      return StreamBuilder<List<UserEnreda>>(
                        stream: LocationCache.instance.participantsPreviewStream,
                        initialData: LocationCache.instance.cachedParticipantsPreview,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData && LocationCache.instance.cachedParticipantsPreview == null) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          final participants = snapshot.data?.toList() ?? LocationCache.instance.cachedParticipantsPreview?.toList() ?? [];
                          final myParticipants = participants.take(10).toList();
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 382,
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
                        }
                      );
                    }
                  );
                }
                return const Center(child: CircularProgressIndicator());
              }),
        ],
      ),
    );
  }
}
