import 'package:circular_seek_bar/circular_seek_bar.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_title.dart';
import 'package:enreda_empresas/app/common_widgets/gamification_item.dart';
import 'package:enreda_empresas/app/common_widgets/gamification_slider.dart';
import 'package:enreda_empresas/app/common_widgets/rounded_container.dart';
import 'package:enreda_empresas/app/common_widgets/show_custom_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/competencies/competency_tile.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/my_curriculum_page.dart';
import 'package:enreda_empresas/app/models/ability.dart';
import 'package:enreda_empresas/app/models/competency.dart';
import 'package:enreda_empresas/app/models/education.dart';
import 'package:enreda_empresas/app/models/interest.dart';
import 'package:enreda_empresas/app/models/personalDocumentType.dart';
import 'package:enreda_empresas/app/models/resource.dart';
import 'package:enreda_empresas/app/models/specificinterest.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/utils/my_custom_scroll_behavior.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ParticipantControlPanelPage extends StatelessWidget {
  const ParticipantControlPanelPage({required this.participantUser, super.key});

  final UserEnreda participantUser;

  @override
  Widget build(BuildContext context) {
    return Responsive.isDesktop(context)? _buildBodyDesktop(context):
        _buildBodyMobile(context);
  }

  Widget _buildBodyDesktop(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGamificationSection(context),
          SpaceH40(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInitialFormSection(context),
                    SpaceH40(),
                    _buildCompetenciesSection(context),
                    SpaceH40(),
                    _buildResourcesSection(context),
                  ],
                ),
              ),
              SpaceW20(),
              Column(
                children: [
                  _buildCvSection(context),
                  SpaceH40(),
                  //_buildDocumetationSection(context),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBodyMobile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGamificationSection(context),
          SpaceH20(),
          _buildInitialFormSection(context),
          SpaceH20(),
          _buildCompetenciesSection(context),
          SpaceH20(),
          _buildResourcesSection(context),
          SpaceH20(),
          _buildCvSection(context),
          SpaceH20(),
          //_buildDocumetationSection(context),
        ],
      ),
    );
  }

  Widget _buildGamificationSection(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final totalGamificationPills = 5;
    final cvTotalSteps = 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextBoldTitle(title: StringConst.GAMIFICATION),
        SpaceH8(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (Responsive.isDesktop(context))
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Image.asset(ImagePath.GAMIFICATION_LOGO,
                  height: Responsive.isMobile(context) || Responsive.isDesktopS(context) ? 80 : 180.0,),
              ),
            if (Responsive.isDesktop(context))
              SpaceW8(),
            Expanded(
              child: Column(
                children: [
                  GamificationSlider(
                    height: 10,
                    value: participantUser.gamificationFlags.length,
                  ),
                  SpaceH20(),
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: Responsive.isDesktop(context) ? 8.0 : 4.0,
                          runSpacing: Responsive.isDesktop(context) ? 8.0 : 4.0,
                          alignment: WrapAlignment.spaceEvenly,
                          children: [
                            GamificationItem(
                              imagePath: ImagePath.GAMIFICATION_CHAT_ICON,
                              progress: (participantUser.gamificationFlags[UserEnreda.FLAG_CHAT]?? false) ? 100 : 0,
                              title: (participantUser.gamificationFlags[UserEnreda.FLAG_CHAT]?? false) ? "CHAT INICIADO": "CHAT NO INICIADO",
                            ),
                            GamificationItem(
                              imagePath: ImagePath.GAMIFICATION_PILL_ICON,
                              progress: (_getUserPillsConsumed()/totalGamificationPills) * 100,
                              progressText: "${_getUserPillsConsumed()}",
                              title: "PÍLDORAS CONSUMIDAS",
                            ),
                            StreamBuilder<List<Competency>>(
                                stream: database.competenciesStream(),
                                builder: (context, competenciesStream) {
                                  double competenciesProgress = 0;
                                  Map<String, String> certifiedCompetencies = {};
                                  if (competenciesStream.hasData) {
                                    certifiedCompetencies = Map.from(participantUser.competencies);
                                    certifiedCompetencies.removeWhere((key, value) => value != "certified");
                                    competenciesProgress = (certifiedCompetencies.length / competenciesStream.data!.length) * 100;
                                  }

                                  return GamificationItem(
                                    imagePath: ImagePath.GAMIFICATION_COMPETENCIES_ICON,
                                    progress: competenciesProgress,
                                    progressText: "${certifiedCompetencies.length}",
                                    title: "COMPETENCIAS CERTIFICADAS",
                                  );
                                }),
                            GamificationItem(
                              imagePath: ImagePath.GAMIFICATION_RESOURCES_ICON,
                              progress: ((participantUser.resourcesAccessCount?? 0) / 15) * 100,
                              progressText: "${participantUser.resourcesAccessCount}",
                              title: "RECURSOS INSCRITOS",
                            ),
                            GamificationItem(
                              imagePath: ImagePath.GAMIFICATION_CV_ICON,
                              progress: (_getUserCvStepsCompleted()/cvTotalSteps) * 100,
                              progressText: "${(_getUserCvStepsCompleted() / cvTotalSteps * 100).toStringAsFixed(2)}%",
                              title: "CV COMPLETADO",
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ],);
  }

  Widget _buildInitialFormSection(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 12, 16, md: 15);

    return RoundedContainer(
      margin: EdgeInsets.all(0.0),
      contentPadding: EdgeInsets.all(0.0),
      borderColor: AppColors.greyAlt.withOpacity(0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: Sizes.kDefaultPaddingDouble, top: Sizes.kDefaultPaddingDouble),
            child: CustomTextBoldTitle(title: StringConst.INITIAL_FORM_DATA),
          ),
          Padding(
            padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<List<Ability>>(
                    stream: database.abilityStream(),
                    builder: (context, snapshot) {
                      String abilitiesString = "";
                      if (snapshot.hasData) {
                        participantUser.abilities!.forEach((abilityId) {
                          final abilityName = snapshot.data!.firstWhere((a) => abilityId == a.abilityId).name;
                          abilitiesString = "$abilitiesString$abilityName, ";
                        });
                        if (abilitiesString.isNotEmpty) {
                          abilitiesString = abilitiesString.substring(0, abilitiesString.lastIndexOf(","));
                        }
                      }
                      return RichText(
                        text: TextSpan(
                          text: "${StringConst.FORM_ABILITIES_REV}: ",
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.turquoiseBlue,
                            height: 1.5,
                            fontSize: fontSize,
                          ),
                          children: [
                            TextSpan(
                              text: abilitiesString,
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: fontSize,
                              ),)
                          ],
                        ),
                      );
                    }
                ),
                SpaceH12(),
                RichText(
                  text: TextSpan(
                    text: "${StringConst.FORM_DEDICATION_REV}: ",
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.turquoiseBlue,
                      height: 1.5,
                      fontSize: fontSize,
                    ),
                    children: [
                      TextSpan(
                        text: participantUser.motivation?.dedication?.label??"",
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: fontSize,
                        ),)
                    ],
                  ),
                ),
                SpaceH12(),
                RichText(
                  text: TextSpan(
                    text: "${StringConst.FORM_TIME_SEARCHING_REV}: ",
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.turquoiseBlue,
                      height: 1.5,
                      fontSize: fontSize,
                    ),
                    children: [
                      TextSpan(
                        text: participantUser.motivation?.timeSearching?.label??"",
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: fontSize,
                        ),)
                    ],
                  ),
                ),
                SpaceH12(),
                RichText(
                  text: TextSpan(
                    text: "${StringConst.FORM_TIME_SPENT_WEEKLY_REV}: ",
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.turquoiseBlue,
                      height: 1.5,
                      fontSize: fontSize,
                    ),
                    children: [
                      TextSpan(
                        text: participantUser.motivation?.timeSpentWeekly?.label??"",
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: fontSize,
                        ),)
                    ],
                  ),
                ),
                SpaceH12(),
                StreamBuilder(
                    stream: database.educationStream(),
                    builder: (context, snapshotEducations) {
                      Education? myMaxEducation;
                      if (snapshotEducations.hasData) {
                        final educations = snapshotEducations.data!;

                        if (participantUser.educationId!.isNotEmpty) {
                          myMaxEducation = educations.firstWhere((e) => e.educationId == participantUser.educationId, orElse: () => Education(label: "", value: "", order: 0));
                          return RichText(
                            text: TextSpan(
                              text: "${StringConst.FORM_EDUCATION_REV}: ",
                              style: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.turquoiseBlue,
                                height: 1.5,
                                fontSize: fontSize,
                              ),
                              children: [
                                TextSpan(
                                  text: myMaxEducation.label??"",
                                  style: textTheme.bodySmall?.copyWith(
                                    fontSize: fontSize,
                                  ),)
                              ],
                            ),
                          );
                        } else {
                          return StreamBuilder(
                              stream: database.myExperiencesStream(participantUser.userId ?? ''),
                              builder: (context, snapshotExperiences) {
                                if (snapshotEducations.hasData && snapshotExperiences.hasData) {
                                  final myEducationalExperiencies = snapshotExperiences.data!
                                      .where((experience) => experience.type == 'Formativa')
                                      .toList();
                                  if (myEducationalExperiencies.isNotEmpty) {
                                    final areEduactions = myEducationalExperiencies.any((exp) => exp.education != null && exp.education!.isNotEmpty);
                                    if (areEduactions) {
                                      final myEducations = educations.where((edu) => myEducationalExperiencies.any((exp) => exp.education == edu.label)).toList();
                                      myEducations.sort((a, b) => a.order.compareTo(b.order));
                                      if(myEducations.isNotEmpty){
                                        myMaxEducation = myEducations.first;
                                      } else {
                                        myMaxEducation = Education(label: "", value: "", order: 0);
                                      }
                                    } else {
                                      myMaxEducation = Education(label: "", value: "", order: 0);
                                    }
                                    return RichText(
                                      text: TextSpan(
                                        text: "${StringConst.FORM_EDUCATION_REV}: ",
                                        style: textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.turquoiseBlue,
                                          height: 1.5,
                                          fontSize: fontSize,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: myMaxEducation?.label??"",
                                            style: textTheme.bodySmall?.copyWith(
                                              fontSize: fontSize,
                                            ),)
                                        ],
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                } else {
                                  return Container();
                                }
                              });
                        }
                      } else {
                        return Container();
                      }
                    }),
                SpaceH12(),
                StreamBuilder<List<Interest>>(
                    stream: database.interestStream(),
                    builder: (context, snapshot) {
                      String interestsString = "";
                      if (snapshot.hasData) {
                        participantUser.interests.forEach((interestId) {
                          final interestName = snapshot.data!.firstWhere((i) => interestId == i.interestId).name;
                          interestsString = "$interestsString$interestName, ";
                        });
                        if (interestsString.isNotEmpty) {
                          interestsString = interestsString.substring(0, interestsString.lastIndexOf(","));
                        }}
                      return RichText(
                        text: TextSpan(
                          text: "${StringConst.FORM_INTERESTS}: ",
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.turquoiseBlue,
                            height: 1.5,
                            fontSize: fontSize,
                          ),
                          children: [
                            TextSpan(
                              text: interestsString,
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: fontSize,
                              ),)
                          ],
                        ),
                      );
                    }),
                SpaceH12(),
                StreamBuilder<List<SpecificInterest>>(
                    stream: database.specificInterestsStream(),
                    builder: (context, snapshot) {
                      String specificInterestsString = "";
                      if (snapshot.hasData) {
                        participantUser.specificInterests.forEach((specificInterestId) {
                          final specificInterestName = snapshot.data!.firstWhere((s) => specificInterestId == s.specificInterestId).name;
                          specificInterestsString = "$specificInterestsString$specificInterestName, ";
                        });
                        if (specificInterestsString.isNotEmpty) {
                          specificInterestsString = specificInterestsString.substring(0, specificInterestsString.lastIndexOf(","));
                        }
                      }

                      return RichText(
                        text: TextSpan(
                          text: "${StringConst.FORM_SPECIFIC_INTERESTS}: ",
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.turquoiseBlue,
                            height: 1.5,
                            fontSize: fontSize,
                          ),
                          children: [
                            TextSpan(
                              text: specificInterestsString,
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: fontSize,
                              ),)
                          ],
                        ),
                      );
                    }),
                SpaceH12(),
              ],
            ),
          ),
        ],),
    );
  }

  Widget _buildCompetenciesSection(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;

    return RoundedContainer(
      margin: EdgeInsets.all(0.0),
      borderColor: AppColors.greyAlt.withOpacity(0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextBoldTitle(title: StringConst.COMPETENCIES),
          SpaceH20(),
          StreamBuilder<List<Competency>>(
              stream: database.competenciesStream(),
              builder: (context, snapshotCompetencies) {
                if (snapshotCompetencies.hasData) {
                  final controller = ScrollController();
                  var scrollJump = Responsive.isDesktopS(context) ? 350 : 410;
                  List<Competency> myCompetencies = snapshotCompetencies.data!;
                  final competenciesIds = participantUser.competencies.keys.toList();
                  myCompetencies = myCompetencies
                      .where((competency) => competenciesIds.any((id) => competency.id == id))
                      .toList();
                  return myCompetencies.isEmpty? Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Center(
                        child: Text(
                          StringConst.NO_COMPETENCIES,
                          style: textTheme.bodyMedium,
                        )),
                  ): Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: Responsive.isDesktop(context)? 270.0: 180.0,
                        child: ScrollConfiguration(
                          behavior: MyCustomScrollBehavior(),
                          child: ListView(
                            controller: controller,
                            scrollDirection: Axis.horizontal,
                            children: myCompetencies.map((competency) {
                              final status =
                                  participantUser.competencies[competency.id] ??
                                      StringConst.BADGE_EMPTY;
                              return Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CompetencyTile(
                                        competency: competency,
                                        status: status,
                                        //mini: true,
                                      ),
                                      Positioned(
                                        bottom: Responsive.isDesktop(context)?5.0: 0.0,
                                        child: Text(
                                            status ==
                                                StringConst
                                                    .BADGE_VALIDATED
                                                ? 'EVALUADA'
                                                : 'CERTIFICADA',
                                            style: textTheme.bodyText1
                                                ?.copyWith(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                    ],
                                  ),
                                ],
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
              }),
        ],),
    );
  }

  Widget _buildCvSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RoundedContainer(
          margin: EdgeInsets.all(0.0),
          width: 340.0,
          height: 365.0,
          borderColor: AppColors.greyAlt.withOpacity(0.15),
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    CustomTextBoldTitle(title: StringConst.MY_CV),
                  ],
                ),
                InkWell(
                  onTap: () => showCustomDialog(
                    context,
                    content: Container(
                        height: MediaQuery.sizeOf(context).height * 0.85,
                        width: Responsive.isDesktop(context) ? MediaQuery.sizeOf(context).width * 0.6: MediaQuery.sizeOf(context).width,
                        child: MyCurriculumPage()),
                  ),
                  child: Transform.scale(
                    scale: 0.3,
                    child: MyCurriculumPage(
                      mini: true,
                    ),
                    alignment: Alignment.topLeft,),
                ),
              ],
            ),
          ),)
      ],
    );
  }

  // Widget _buildDocumetationSection(BuildContext context) {
  //   final database = Provider.of<Database>(context, listen: false);
  //   double maxValue = 10;
  //   double value = 0;
  //   return StreamBuilder<List<PersonalDocumentType>>(
  //       stream: database.personalDocumentTypeStream(),
  //       builder: (context, snapshot) {
  //         if (snapshot.hasData) {
  //           maxValue = snapshot.data!.length.toDouble();
  //           value = participantUser.personalDocuments.where((userDocument) =>
  //               userDocument.document.isNotEmpty && snapshot.data!.any((document) => document.title == userDocument.name)
  //           ).length.toDouble();
  //         }
  //         return RoundedContainer(
  //           margin: EdgeInsets.all(0.0),
  //           height: 420.0,
  //           width: 340.0,
  //           borderColor: AppColors.greyAlt.withOpacity(0.15),
  //           child: Column (
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               CustomTextBoldTitle(title: StringConst.DOCUMENTATION),
  //               SpaceH20(),
  //               Stack(
  //                 children: [
  //                   Center(
  //                     child: CircularSeekBar(
  //                       height: 260,
  //                       width: 260,
  //                       startAngle: 45,
  //                       sweepAngle: 270,
  //                       progress: value,
  //                       maxProgress: maxValue,
  //                       barWidth: 15,
  //                       progressColor: AppColors.darkYellow,
  //                       innerThumbStrokeWidth: 15,
  //                       innerThumbColor: AppColors.darkYellow,
  //                       outerThumbColor: Colors.transparent,
  //                       trackColor: AppColors.lightYellow,
  //                       strokeCap: StrokeCap.round,
  //                       animation: true,
  //                       animDurationMillis: 1500,
  //                     ),
  //                   ),
  //                   Center(
  //                     child: Column(
  //                         children: [
  //                           Padding(
  //                             padding: const EdgeInsets.only(left: 40.0),
  //                             child: Image.asset(ImagePath.PARTICIPANT_DOCUMENTATION_ICON, width:220,),
  //                           ),
  //                           CustomTextBoldTitle(title: "${(value/maxValue)*100}%"),
  //                           CustomTextMediumBold(text: StringConst.COMPLETED.toUpperCase()),
  //                         ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         );
  //     }
  //   );
  // }

  Widget _buildResourcesSection(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextBoldTitle(title: StringConst.RESOURCES_JOINED),
        SpaceH20(),
        StreamBuilder<List<Resource>>(
            stream: database.resourcesStream(),
            builder: (context, snapshot) {
              List<Resource> myResources = [];
              if (snapshot.hasData) {
                myResources = snapshot.data!.where((resource) =>
                    participantUser.resources.any((id) => resource.resourceId == id))
                    .toList();
              }

              return myResources.isEmpty? Text(
                StringConst.NO_RESOURCES,
                style: textTheme.bodyMedium,
              ): Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: myResources.map((r) => Container(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: AppColors.altWhite,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: AppColors.greyAlt.withOpacity(0.15), width: 2.0,),
                  ),
                  child: Text(r.title),)).toList(),
              );
            }
        )
      ],
    );
  }

  int _getUserPillsConsumed() {
    int userPillsConsumed = 2; // 2 first pills are always consumed
    if (participantUser.gamificationFlags[UserEnreda.FLAG_PILL_COMPETENCIES]?? false) {
      userPillsConsumed++;
    }
    if (participantUser.gamificationFlags[UserEnreda.FLAG_PILL_CV_COMPETENCIES]?? false) {
      userPillsConsumed++;
    }
    if (participantUser.gamificationFlags[UserEnreda.FLAG_PILL_HOW_TO_DO_CV]?? false) {
      userPillsConsumed++;
    }
    return userPillsConsumed;
  }

  int _getUserCvStepsCompleted() {
    int userCvStepsCompleted = 0;

    if (participantUser.gamificationFlags[UserEnreda.FLAG_CV_PHOTO]?? false) {
      userCvStepsCompleted++;
    }
    if (participantUser.gamificationFlags[UserEnreda.FLAG_CV_ABOUT_ME]?? false) {
      userCvStepsCompleted++;
    }
    if (participantUser.gamificationFlags[UserEnreda.FLAG_CV_DATA_OF_INTEREST]?? false) {
      userCvStepsCompleted++;
    }
    if (participantUser.gamificationFlags[UserEnreda.FLAG_CV_FORMATION]?? false) {
      userCvStepsCompleted++;
    }
    if (participantUser.gamificationFlags[UserEnreda.FLAG_CV_COMPLEMENTARY_FORMATION]?? false) {
      userCvStepsCompleted++;
    }
    if (participantUser.gamificationFlags[UserEnreda.FLAG_CV_PERSONAL]?? false) {
      userCvStepsCompleted++;
    }
    if (participantUser.gamificationFlags[UserEnreda.FLAG_CV_PROFESSIONAL]?? false) {
      userCvStepsCompleted++;
    }

    return userCvStepsCompleted;
  }
}
