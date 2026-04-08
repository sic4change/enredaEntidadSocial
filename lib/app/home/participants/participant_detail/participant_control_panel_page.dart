import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/gamification_item.dart';
import 'package:enreda_empresas/app/common_widgets/gamification_slider.dart';
import 'package:enreda_empresas/app/common_widgets/rounded_container.dart';
import 'package:enreda_empresas/app/common_widgets/show_custom_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/competencies/competency_tile.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/my_curriculum_page.dart';
import 'package:enreda_empresas/app/models/competency.dart';
import 'package:enreda_empresas/app/models/education.dart';
import 'package:enreda_empresas/app/models/experience.dart';
import 'package:enreda_empresas/app/models/interest.dart';
import 'package:enreda_empresas/app/models/keepLearningOption.dart';
import 'package:enreda_empresas/app/models/resource.dart';
import 'package:enreda_empresas/app/models/specificinterest.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/utils/my_custom_scroll_behavior.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ParticipantControlPanelPage extends StatefulWidget {
  const ParticipantControlPanelPage({required this.participantUser, super.key});

  final UserEnreda participantUser;

  @override
  State<ParticipantControlPanelPage> createState() => _ParticipantControlPanelPageState();
}

class _ParticipantControlPanelPageState extends State<ParticipantControlPanelPage> {
  late Stream<List<Experience>>? _experiencesStream;
  List<Education>? _allEducations;
  late Stream<List<Resource>> _participantResourcesStream;
  final ScrollController _competenciesScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final database = Provider.of<Database>(context, listen: false);
    _experiencesStream = database.myExperiencesStream(widget.participantUser.userId ?? '');
    _allEducations = LocationCache.instance.educations;
    _participantResourcesStream = database.participantsResourcesStream(
      widget.participantUser.userId,
      widget.participantUser.assignedEntityId,
    );
  }

  @override
  void dispose() {
    _competenciesScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Responsive.isMobile(context) || Responsive.isDesktopS(context) ? _buildBodyMobile(context):
        _buildBodyDesktop(context);
  }

  Widget _buildBodyDesktop(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGamificationSection(context),
        SpaceH40(),
        Container(
          height: widget.participantUser.competencies.isEmpty ? 460 : 650,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInitialFormSection(context),
                    SpaceH20(),
                    _buildCompetenciesSection(context),
                  ],
                ),
              ),
              SpaceW20(),
              _buildCvSection(context),
            ],
          ),
        ),
        SpaceH20(),
        Row(
          children: [
            Expanded(
              child: _buildResourcesSection(context),
            ),
          ],
        ),
        SpaceH20(),
      ],
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
                    value: widget.participantUser.gamificationFlags.length,
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
                              progress: (widget.participantUser.gamificationFlags[UserEnreda.FLAG_CHAT]?? false) ? 100 : 0,
                              title: (widget.participantUser.gamificationFlags[UserEnreda.FLAG_CHAT]?? false) ? "CHAT INICIADO": "CHAT NO INICIADO",
                            ),
                            GamificationItem(
                              imagePath: ImagePath.GAMIFICATION_PILL_ICON,
                              progress: (_getUserPillsConsumed()/totalGamificationPills) * 100,
                              progressText: "${_getUserPillsConsumed()}",
                              title: "PÍLDORAS CONSUMIDAS",
                            ),
                            (() {
                                final competenciesList = LocationCache.instance.competencies;
                                double competenciesProgress = 0;
                                Map<String, String> certifiedCompetencies = {};
                                
                                certifiedCompetencies = Map.from(widget.participantUser.competencies);
                                certifiedCompetencies.removeWhere((key, value) => value != "certified");
                                if (competenciesList.isNotEmpty) {
                                  competenciesProgress = (certifiedCompetencies.length / competenciesList.length) * 100;
                                }

                                return GamificationItem(
                                  imagePath: ImagePath.GAMIFICATION_COMPETENCIES_ICON,
                                  progress: competenciesProgress,
                                  progressText: "${certifiedCompetencies.length}",
                                  title: "COMPETENCIAS CERTIFICADAS",
                                );
                              })(),
                            GamificationItem(
                              imagePath: ImagePath.GAMIFICATION_RESOURCES_ICON,
                              progress: ((widget.participantUser.resourcesAccessCount?? 0) / 15) * 100,
                              progressText: "${widget.participantUser.resourcesAccessCount}",
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
    int calculateAge(DateTime birthDate) {
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    }
    int age = calculateAge(widget.participantUser.birthday!);
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
            padding: const EdgeInsets.only(bottom: Sizes.kDefaultPaddingDouble, left: Sizes.kDefaultPaddingDouble, right: Sizes.kDefaultPaddingDouble),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomTextBold(title: StringConst.FORM_AGE, color: AppColors.primary900,),
                    CustomTextSmall(text: '${age} años'),
                  ],
                ),
                SpaceH12(),
                (() {
                   Education? myMaxEducation;
                   final educations = _allEducations ?? [];
                   if (widget.participantUser.educationId!.isNotEmpty) {
                     myMaxEducation = educations.firstWhere((e) => e.educationId == widget.participantUser.educationId, orElse: () => Education(label: "", value: "", order: 0));
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
                   }
                   else {
                     return StreamBuilder<List<Experience>>(
                         stream: _experiencesStream,
                         builder: (context, snapshotExperiences) {
                           if (snapshotExperiences.hasData) {
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
                             return Row(
                               children: [
                                 CustomTextBold(title: StringConst.FORM_EDUCATION_REV, color: AppColors.primary900,),
                                 CustomTextSmall(text: 'No indicado'),
                               ],
                             );
                           }
                         });
                   }
                })(),
                SpaceH12(),
                (() {
                  String interestsString = "";
                  final interestsList = LocationCache.instance.interests;
                  widget.participantUser.interests.forEach((interestId) {
                    final interest = interestsList.firstWhere((i) => interestId == i.interestId, orElse: () => Interest(interestId: "", name: ""));
                    if (interest.name.isNotEmpty) {
                      interestsString = "$interestsString${interest.name}, ";
                    }
                  });
                  if (interestsString.isNotEmpty) {
                    interestsString = interestsString.substring(0, interestsString.lastIndexOf(","));
                  }
                  return RichText(
                    text: TextSpan(
                      text: StringConst.FORM_INTERESTS_DOTS,
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary900,
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
                })(),
                SpaceH12(),
                (() {
                  String specificInterestsString = "";
                  final specificInterestsList = LocationCache.instance.specificInterests;
                  widget.participantUser.specificInterests.forEach((specificInterestId) {
                    final specificInterest = specificInterestsList.firstWhere((s) => specificInterestId == s.specificInterestId, orElse: () => SpecificInterest(specificInterestId: "", name: ""));
                    if (specificInterest.name.isNotEmpty) {
                      specificInterestsString = "$specificInterestsString${specificInterest.name}, ";
                    }
                  });
                  if (specificInterestsString.isNotEmpty) {
                    specificInterestsString = specificInterestsString.substring(0, specificInterestsString.lastIndexOf(","));
                  }

                  return RichText(
                    text: TextSpan(
                      text: StringConst.FORM_SPECIFIC_INTERESTS_DOTS,
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary900,
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
                })(),
                SpaceH12(),
                (() {
                  String keepLearningString = "";
                  final options = LocationCache.instance.keepLearningOptions;
                  widget.participantUser.keepLearningOptions.forEach((id) {
                    try {
                      final name = options.firstWhere((i) => id == i.keepLearningOptionId).title;
                      keepLearningString = "$keepLearningString$name, ";
                    } catch (_) {}
                  });
                  if (keepLearningString.isNotEmpty) {
                    keepLearningString = keepLearningString.substring(0, keepLearningString.lastIndexOf(","));
                  }
                  if (keepLearningString.isEmpty || keepLearningString == " ") {
                    keepLearningString = 'No indicado';
                  }

                  return RichText(
                    text: TextSpan(
                      text: StringConst.FORM_KEEP_LEARNING,
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary900,
                        height: 1.5,
                        fontSize: fontSize,
                      ),
                      children: [
                        TextSpan(
                          text: keepLearningString,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: fontSize,
                          ),)
                      ],
                    ),
                  );
                })(),
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
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      borderColor: AppColors.greyAlt.withOpacity(0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextBoldTitle(title: StringConst.COMPETENCIES),
              (() {
                final controller = _competenciesScrollController;
                var scrollJump = Responsive.isDesktopS(context) ? 350 : 410;
                List<Competency> myCompetencies = List.from(LocationCache.instance.competencies);
                final competenciesIds = widget.participantUser.competencies.keys.toList();
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
                ) : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: Responsive.isDesktop(context)? 210.0 : 180.0,
                      child: ScrollConfiguration(
                        behavior: MyCustomScrollBehavior(),
                        child: ListView(
                          controller: controller,
                          scrollDirection: Axis.horizontal,
                          children: myCompetencies.map((competency) {
                            final status =
                                widget.participantUser.competencies[competency.id] ??
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
                                      bottom: 0,
                                      child: Text(
                                          status ==
                                              StringConst
                                                  .BADGE_VALIDATED
                                              ? 'EVALUADA'
                                              : 'CERTIFICADA',
                                          style: textTheme.bodySmall
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
              })(),
        ],),
    );
  }

  Widget _buildCvSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RoundedContainer(
          margin: EdgeInsets.all(0.0),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          width: Responsive.isMobile(context) ? MediaQuery.sizeOf(context).width : 340.0,
          height: Responsive.isMobile(context) || Responsive.isDesktopS(context) ? 450.0 : widget.participantUser.competencies.isEmpty ? 430.0 : 620,
          borderColor: AppColors.greyAlt.withOpacity(0.15),
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    CustomTextBoldTitle(title: StringConst.CV),
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
                  child: SizedBox(
                    width: 300,
                    height: 350,
                    child: OverflowBox(
                      alignment: Alignment.topLeft,
                      maxWidth: double.infinity,
                      maxHeight: double.infinity,
                      child: Transform.scale(
                        scale: 0.3,
                        alignment: Alignment.topLeft,
                        child: MyCurriculumPage(mini: true),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),)
      ],
    );
  }

  Widget _buildResourcesSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextBoldTitle(title: StringConst.RESOURCES_JOINED),
        SpaceH20(),
        StreamBuilder<List<Resource>>(
          stream: _participantResourcesStream,
          builder: (context, snapshot) {
            final myResources = snapshot.data ?? [];
            return myResources.isEmpty
                ? Text(
                    StringConst.NO_RESOURCES,
                    style: textTheme.bodyMedium,
                  )
                : Wrap(
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
          },
        ),
      ],
    );
  }

  int _getUserPillsConsumed() {
    int userPillsConsumed = 2; // 2 first pills are always consumed
    if (widget.participantUser.gamificationFlags[UserEnreda.FLAG_PILL_COMPETENCIES]?? false) {
      userPillsConsumed++;
    }
    if (widget.participantUser.gamificationFlags[UserEnreda.FLAG_PILL_CV_COMPETENCIES]?? false) {
      userPillsConsumed++;
    }
    if (widget.participantUser.gamificationFlags[UserEnreda.FLAG_PILL_HOW_TO_DO_CV]?? false) {
      userPillsConsumed++;
    }
    return userPillsConsumed;
  }

  int _getUserCvStepsCompleted() {
    int userCvStepsCompleted = 0;

    if (widget.participantUser.gamificationFlags[UserEnreda.FLAG_CV_PHOTO]?? false) {
      userCvStepsCompleted++;
    }
    if (widget.participantUser.gamificationFlags[UserEnreda.FLAG_CV_ABOUT_ME]?? false) {
      userCvStepsCompleted++;
    }
    if (widget.participantUser.gamificationFlags[UserEnreda.FLAG_CV_DATA_OF_INTEREST]?? false) {
      userCvStepsCompleted++;
    }
    if (widget.participantUser.gamificationFlags[UserEnreda.FLAG_CV_FORMATION]?? false) {
      userCvStepsCompleted++;
    }
    if (widget.participantUser.gamificationFlags[UserEnreda.FLAG_CV_COMPLEMENTARY_FORMATION]?? false) {
      userCvStepsCompleted++;
    }
    if (widget.participantUser.gamificationFlags[UserEnreda.FLAG_CV_PERSONAL]?? false) {
      userCvStepsCompleted++;
    }
    if (widget.participantUser.gamificationFlags[UserEnreda.FLAG_CV_PROFESSIONAL]?? false) {
      userCvStepsCompleted++;
    }

    return userCvStepsCompleted;
  }
}
