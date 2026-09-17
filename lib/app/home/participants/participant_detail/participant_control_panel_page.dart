import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/gamification_item.dart';
import 'package:enreda_empresas/app/common_widgets/gamification_slider.dart';
import 'package:enreda_empresas/app/common_widgets/rounded_container.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/participants/pdf_generator/pdf_initial_form_data_preview.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/competencies/competency_tile.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/my_curriculum_page.dart';
import 'package:enreda_empresas/app/models/companionData.dart';
import 'package:enreda_empresas/app/models/competency.dart';
import 'package:enreda_empresas/app/models/education.dart';
import 'package:enreda_empresas/app/models/experience.dart';
import 'package:enreda_empresas/app/models/interest.dart';
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
  const ParticipantControlPanelPage({
    required this.participantUser,
    this.onNavigateToCV,
    this.onNavigateToSection,
    super.key,
  });

  final UserEnreda participantUser;
  final VoidCallback? onNavigateToCV;
  final void Function(String sectionName)? onNavigateToSection;

  @override
  State<ParticipantControlPanelPage> createState() => _ParticipantControlPanelPageState();
}

class _ParticipantControlPanelPageState extends State<ParticipantControlPanelPage> {
  late Stream<List<Experience>>? _experiencesStream;
  List<Education>? _allEducations;
  late Stream<List<Resource>> _participantResourcesStream;
  Future<CompanionData?>? _companionFuture;
  final ScrollController _competenciesScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final database = Provider.of<Database>(context, listen: false);
    _experiencesStream = database.myExperiencesStream(widget.participantUser.userId ?? '');
    _allEducations = LocationCache.instance.educations;
    _participantResourcesStream = database.participantsResourcesStream(
      widget.participantUser.userId ?? '',
      widget.participantUser.assignedEntityId,
    );
    final userId = widget.participantUser.userId;
    if (userId != null && userId.isNotEmpty) {
      _companionFuture = database.getCompanionData(userId);
    }
  }

  @override
  void didUpdateWidget(covariant ParticipantControlPanelPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.participantUser.userId != widget.participantUser.userId) {
      final database = Provider.of<Database>(context, listen: false);
      final userId = widget.participantUser.userId;
      if (userId != null && userId.isNotEmpty) {
        _companionFuture = database.getCompanionData(userId);
      } else {
        _companionFuture = null;
      }
    }
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
        Row(
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

  Future<String> _getResolvedEducation() async {
    final educations = _allEducations ?? LocationCache.instance.educations;
    final userEduId = widget.participantUser.educationId?.trim() ?? '';
    final userEduName = widget.participantUser.educationName?.trim() ?? '';

    String resolvedEducation = '';

    if (userEduId.isNotEmpty) {
      final match = educations.firstWhere(
        (e) => e.educationId == userEduId || e.label == userEduId || e.value == userEduId,
        orElse: () => Education(label: userEduId, value: userEduId, order: 0),
      );
      resolvedEducation = match.label.isNotEmpty ? match.label : userEduId;
    }

    if (resolvedEducation.isEmpty && userEduName.isNotEmpty) {
      resolvedEducation = userEduName;
    }

    if (resolvedEducation.isEmpty && _experiencesStream != null) {
      try {
        final experiences = await _experiencesStream!.first;
        final myEducationalExperiencies = experiences
            .where((experience) => experience.type == 'Formativa')
            .toList();
        if (myEducationalExperiencies.isNotEmpty) {
          final myEducations = educations
              .where((edu) => myEducationalExperiencies.any((exp) => exp.education == edu.label || exp.nameFormation == edu.label))
              .toList();
          myEducations.sort((a, b) => a.order.compareTo(b.order));
          if (myEducations.isNotEmpty) {
            resolvedEducation = myEducations.first.label;
          } else if (myEducationalExperiencies.first.education != null && myEducationalExperiencies.first.education!.isNotEmpty) {
            resolvedEducation = myEducationalExperiencies.first.education!;
          }
        }
      } catch (_) {}
    }

    if (resolvedEducation.isEmpty) {
      resolvedEducation = 'No indicado';
    }

    return resolvedEducation;
  }

  String _getInterestsString() {
    String interestsString = "";
    final interestsList = LocationCache.instance.interests;
    widget.participantUser.interests.forEach((interestId) {
      final interest = interestsList.firstWhere(
        (i) => interestId == i.interestId || interestId == i.name,
        orElse: () => Interest(interestId: "", name: interestId),
      );
      final name = interest.name.isNotEmpty ? interest.name : interestId;
      if (name.trim().isNotEmpty) {
        interestsString = "$interestsString$name, ";
      }
    });
    if (interestsString.isNotEmpty && interestsString.endsWith(", ")) {
      interestsString = interestsString.substring(0, interestsString.length - 2);
    }
    if (interestsString.trim().isEmpty) {
      interestsString = 'No indicado';
    }
    return interestsString;
  }

  String _getSpecificInterestsString() {
    String specificInterestsString = "";
    final specificInterestsList = LocationCache.instance.specificInterests;
    widget.participantUser.specificInterests.forEach((specificInterestId) {
      final specificInterest = specificInterestsList.firstWhere(
        (s) => specificInterestId == s.specificInterestId || specificInterestId == s.name,
        orElse: () => SpecificInterest(specificInterestId: "", name: specificInterestId),
      );
      final name = specificInterest.name.isNotEmpty ? specificInterest.name : specificInterestId;
      if (name.trim().isNotEmpty) {
        specificInterestsString = "$specificInterestsString$name, ";
      }
    });
    if (specificInterestsString.isNotEmpty && specificInterestsString.endsWith(", ")) {
      specificInterestsString = specificInterestsString.substring(0, specificInterestsString.length - 2);
    }
    if (specificInterestsString.trim().isEmpty) {
      specificInterestsString = 'No indicado';
    }
    return specificInterestsString;
  }

  String _getKeepLearningString() {
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
    return keepLearningString;
  }

  Future<void> _openInitialFormDataPdfPreview(BuildContext context) async {
    final database = Provider.of<Database>(context, listen: false);
    final companion = _companionFuture != null ? await _companionFuture : null;
    final resolvedEducation = await _getResolvedEducation();
    final interests = _getInterestsString();
    final specificInterests = _getSpecificInterestsString();
    final keepLearning = _getKeepLearningString();

    int subsidyIndex = -1;
    final initialReportId = widget.participantUser.initialReportId;
    if (initialReportId != null && initialReportId.isNotEmpty) {
      try {
        final initialReport = await database
            .initialReportStreamById(initialReportId)
            .first;
        if (initialReport != null &&
            (initialReport.completedDate != null || initialReport.finished == true) &&
            initialReport.subsidy != null &&
            initialReport.subsidy!.trim().isNotEmpty) {
          subsidyIndex = StringConst.getSubsidyIndex(initialReport.subsidy);
        }
      } catch (_) {}
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyInitialFormDataPdfPreview(
          user: widget.participantUser,
          companion: companion,
          resolvedEducation: resolvedEducation,
          interests: interests,
          specificInterests: specificInterests,
          keepLearning: keepLearning,
          subsidyIndex: subsidyIndex,
        ),
      ),
    );
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
            padding: const EdgeInsets.only(
              left: Sizes.kDefaultPaddingDouble,
              right: Sizes.kDefaultPaddingDouble,
              top: Sizes.kDefaultPaddingDouble,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomTextBoldTitle(title: StringConst.INITIAL_FORM_DATA),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.file_download_outlined,
                    color: AppColors.primary900,
                    size: 24,
                  ),
                  tooltip: 'Descargar datos del formulario',
                  onPressed: () => _openInitialFormDataPdfPreview(context),
                ),
              ],
            ),
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
                   final educations = _allEducations ?? LocationCache.instance.educations;
                   final userEduId = widget.participantUser.educationId?.trim() ?? '';
                   final userEduName = widget.participantUser.educationName?.trim() ?? '';

                   String resolvedEducation = '';

                   if (userEduId.isNotEmpty) {
                     final match = educations.firstWhere(
                       (e) => e.educationId == userEduId || e.label == userEduId || e.value == userEduId,
                       orElse: () => Education(label: userEduId, value: userEduId, order: 0),
                     );
                     resolvedEducation = match.label.isNotEmpty ? match.label : userEduId;
                   }

                   if (resolvedEducation.isEmpty && userEduName.isNotEmpty) {
                     resolvedEducation = userEduName;
                   }

                   if (resolvedEducation.isNotEmpty) {
                     return RichText(
                       text: TextSpan(
                         text: "${StringConst.FORM_EDUCATION_REV}: ",
                         style: textTheme.bodySmall?.copyWith(
                           fontWeight: FontWeight.bold,
                           color: AppColors.primary900,
                           height: 1.5,
                           fontSize: fontSize,
                         ),
                         children: [
                           TextSpan(
                             text: resolvedEducation,
                             style: textTheme.bodySmall?.copyWith(
                               fontSize: fontSize,
                             ),
                           )
                         ],
                       ),
                     );
                   }

                   return StreamBuilder<List<Experience>>(
                     stream: _experiencesStream,
                     builder: (context, snapshotExperiences) {
                       String streamEdu = '';
                       if (snapshotExperiences.hasData && snapshotExperiences.data != null) {
                         final myEducationalExperiencies = snapshotExperiences.data!
                             .where((experience) => experience.type == 'Formativa')
                             .toList();
                         if (myEducationalExperiencies.isNotEmpty) {
                           final myEducations = educations
                               .where((edu) => myEducationalExperiencies.any((exp) => exp.education == edu.label || exp.nameFormation == edu.label))
                               .toList();
                           myEducations.sort((a, b) => a.order.compareTo(b.order));
                           if (myEducations.isNotEmpty) {
                             streamEdu = myEducations.first.label;
                           } else if (myEducationalExperiencies.first.education != null && myEducationalExperiencies.first.education!.isNotEmpty) {
                             streamEdu = myEducationalExperiencies.first.education!;
                           }
                         }
                       }
                       if (streamEdu.isEmpty) {
                         streamEdu = 'No indicado';
                       }
                       return RichText(
                         text: TextSpan(
                           text: "${StringConst.FORM_EDUCATION_REV}: ",
                           style: textTheme.bodySmall?.copyWith(
                             fontWeight: FontWeight.bold,
                             color: AppColors.primary900,
                             height: 1.5,
                             fontSize: fontSize,
                           ),
                           children: [
                             TextSpan(
                               text: streamEdu,
                               style: textTheme.bodySmall?.copyWith(
                                 fontSize: fontSize,
                               ),
                             )
                           ],
                         ),
                       );
                     },
                   );
                })(),
                SpaceH12(),
                (() {
                  String interestsString = "";
                  final interestsList = LocationCache.instance.interests;
                  widget.participantUser.interests.forEach((interestId) {
                    final interest = interestsList.firstWhere(
                      (i) => interestId == i.interestId || interestId == i.name,
                      orElse: () => Interest(interestId: "", name: interestId),
                    );
                    final name = interest.name.isNotEmpty ? interest.name : interestId;
                    if (name.trim().isNotEmpty) {
                      interestsString = "$interestsString$name, ";
                    }
                  });
                  if (interestsString.isNotEmpty && interestsString.endsWith(", ")) {
                    interestsString = interestsString.substring(0, interestsString.length - 2);
                  }
                  if (interestsString.trim().isEmpty) {
                    interestsString = 'No indicado';
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
                          ),
                        )
                      ],
                    ),
                  );
                })(),
                SpaceH12(),
                (() {
                  String specificInterestsString = "";
                  final specificInterestsList = LocationCache.instance.specificInterests;
                  widget.participantUser.specificInterests.forEach((specificInterestId) {
                    final specificInterest = specificInterestsList.firstWhere(
                      (s) => specificInterestId == s.specificInterestId || specificInterestId == s.name,
                      orElse: () => SpecificInterest(specificInterestId: "", name: specificInterestId),
                    );
                    final name = specificInterest.name.isNotEmpty ? specificInterest.name : specificInterestId;
                    if (name.trim().isNotEmpty) {
                      specificInterestsString = "$specificInterestsString$name, ";
                    }
                  });
                  if (specificInterestsString.isNotEmpty && specificInterestsString.endsWith(", ")) {
                    specificInterestsString = specificInterestsString.substring(0, specificInterestsString.length - 2);
                  }
                  if (specificInterestsString.trim().isEmpty) {
                    specificInterestsString = 'No indicado';
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
                          ),
                        )
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
                FutureBuilder<CompanionData?>(
                  future: _companionFuture,
                  builder: (context, snapshot) {
                    final companion = snapshot.data;
                    if (companion == null) return const SizedBox.shrink();

                    final children = <Widget>[];

                    void addCompanionField(String label, String? value) {
                      if (value != null && value.trim().isNotEmpty) {
                        children.add(
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: RichText(
                              text: TextSpan(
                                text: label,
                                style: textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary900,
                                  height: 1.5,
                                  fontSize: fontSize,
                                ),
                                children: [
                                  TextSpan(
                                    text: value.trim(),
                                    style: textTheme.bodySmall?.copyWith(
                                      fontSize: fontSize,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    }

                    // 1. Situación familiar
                    addCompanionField('Situación familiar: ', companion.companionFamilyStatus);

                    // 2. Fecha de llegada a España
                    addCompanionField('Fecha de llegada a España: ', companion.companionArrivalDateInSpain);

                    // 3. Situación administrativa
                    addCompanionField('Situación administrativa: ', companion.companionAdministrativeStatus);

                    // 4. Permiso de trabajo
                    final rawPermit = companion.companionWorkPermit?.trim();
                    if (rawPermit != null && rawPermit.isNotEmpty) {
                      String permitDisplay = rawPermit;
                      final lower = rawPermit.toLowerCase();
                      if (lower == 'true' || lower == 'si' || lower == 'sí') {
                        permitDisplay = 'Sí';
                      } else if (lower == 'false' || lower == 'no') {
                        permitDisplay = 'No';
                      }
                      addCompanionField('Permiso de trabajo: ', permitDisplay);
                    }

                    // 5. Tipo y número de documento
                    final docType = companion.companionDocumentType?.trim() ?? '';
                    final docNum = companion.companionDocumentNumber?.trim() ?? '';
                    final docCombined = (docType.isNotEmpty && docNum.isNotEmpty)
                        ? '$docType - $docNum'
                        : (docNum.isNotEmpty ? docNum : docType);
                    addCompanionField('Tipo y número de documento: ', docCombined);

                    // 6. Ayudas seleccionadas
                    final helpNeeds = companion.companionHelpNeeds;
                    if (helpNeeds != null && helpNeeds.isNotEmpty) {
                      final helpNeedsText = helpNeeds
                          .where((s) => s.trim().isNotEmpty)
                          .join(', ');
                      addCompanionField('Ayudas seleccionadas: ', helpNeedsText);
                    }

                    // 7. Horario de contacto
                    final rawSchedule = companion.companionContactSchedule?.trim();
                    if (rawSchedule != null && rawSchedule.isNotEmpty) {
                      final cleanSchedule = rawSchedule
                          .replaceAll('[', '')
                          .replaceAll(']', '')
                          .trim();
                      if (cleanSchedule.isNotEmpty) {
                        addCompanionField('Horario de contacto: ', cleanSchedule);
                      }
                    }

                    // 8. Ayuda al rellenar el formulario
                    addCompanionField('Ayuda al rellenar el formulario: ', companion.companionFormHelp);

                    // 9. Observaciones
                    addCompanionField('Observaciones: ', companion.companionOtherRelevantData);

                    if (children.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: children,
                    );
                  },
                ),
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
                                      height: 40.0,
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
                            if (controller.hasClients &&
                                controller.position.pixels >
                                    controller.position.minScrollExtent) {
                              controller.animateTo(
                                  (controller.position.pixels - scrollJump)
                                      .clamp(
                                    controller.position.minScrollExtent,
                                    controller.position.maxScrollExtent,
                                  ),
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease);
                            }
                          },
                          child: Image.asset(
                            ImagePath.ARROW_BACK,
                            width: 36.0,
                          ),
                        ),
                        SpaceW12(),
                        InkWell(
                          onTap: () {
                            if (controller.hasClients &&
                                controller.position.pixels <
                                    controller.position.maxScrollExtent) {
                              controller.animateTo(
                                  (controller.position.pixels + scrollJump)
                                      .clamp(
                                    controller.position.minScrollExtent,
                                    controller.position.maxScrollExtent,
                                  ),
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease);
                            }
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          width: Responsive.isMobile(context) ? MediaQuery.sizeOf(context).width : 340.0,
          borderColor: AppColors.greyAlt.withOpacity(0.15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CustomTextBoldTitle(title: StringConst.CV),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  if (widget.onNavigateToCV != null) {
                    widget.onNavigateToCV!();
                  } else if (widget.onNavigateToSection != null) {
                    widget.onNavigateToSection!(StringConst.MY_CV);
                  }
                },
                child: SizedBox(
                  width: 300,
                  height: 350,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: 1020,
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: MyCurriculumPage(
                            mini: true,
                            user: widget.participantUser,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
