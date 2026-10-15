import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enreda_empresas/app/common_widgets/custom_check_box_selectable.dart';
import 'package:enreda_empresas/app/common_widgets/custom_drop_down-button_form_field_no_title_check.dart';
import 'package:enreda_empresas/app/common_widgets/custom_drop_down_button_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_form_field_long.dart';
import 'package:enreda_empresas/app/common_widgets/flex_row_column.dart';
import 'package:enreda_empresas/app/home/resources/global.dart' as globals;
import 'package:enreda_empresas/app/home/participants/participant_detail/ipils/participant_ipil_page.dart';
import 'package:enreda_empresas/app/models/ipilCoordination.dart';
import 'package:enreda_empresas/app/models/ipilDigitalSkills.dart';
import 'package:enreda_empresas/app/models/ipilEconomicBag.dart';
import 'package:enreda_empresas/app/models/ipilImprovementEmployment.dart';
import 'package:enreda_empresas/app/models/ipilIntermediations.dart';
import 'package:enreda_empresas/app/models/ipilLaborSkills.dart';
import 'package:enreda_empresas/app/models/ipilLegal.dart';
import 'package:enreda_empresas/app/models/ipilObtainingEmployment.dart';
import 'package:enreda_empresas/app/models/ipilPostWorkSupport.dart';
import 'package:enreda_empresas/app/models/ipilSoftSkills.dart';
import 'package:enreda_empresas/app/models/ipilSpecificSkills.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enreda_empresas/app/values/strings.dart';

import '../../../../common_widgets/alert_dialog.dart';
import '../../../../common_widgets/custom_date_picker_open.dart';
import '../../../../common_widgets/custom_drop_down_button_form_field_title_check.dart';
import '../../../../common_widgets/custom_text_form_field_title.dart';
import '../../../../common_widgets/enreda_button.dart';
import '../../../../common_widgets/show_exception_alert_dialog.dart';
import '../../../../models/closureReport.dart';
import '../../../../models/ipilConnectionTerritory.dart';
import '../../../../models/ipilContextualization.dart';
import '../../../../models/ipilEntry.dart';
import '../../../../models/ipilInterviews.dart';
import '../../../../models/userEnreda.dart';
import '../../../../services/database.dart';
import '../../../../services/location_cache.dart';
import '../../../../utils/responsive.dart';
import '../../../../values/values.dart';
import 'ipil_follow_up_section.dart';

class CreateIpilForm extends StatefulWidget {
  const CreateIpilForm({super.key, required this.participantUser, this.selectedIpil});
  final UserEnreda participantUser;
  final IpilEntry? selectedIpil;

  @override
  State<CreateIpilForm> createState() => _CreateIpilFormState();
}

class _CreateIpilFormState extends State<CreateIpilForm> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController textEditingControllerDateInput = TextEditingController();
  late List<String> reinforcement;
  late List<String> contextualization;
  late List<String> connectionTerritory;
  late List<String> interviews;
  late List<String> intermediations;
  late List<String> obtainingEmployment;
  late List<String> improvingEmployment;
  late List<String> coordination;
  late List<String> legal;
  late List<String> postWorkSupport;
  late List<String> economicBag;
  late List<String> specificSkills;
  late List<String> softSkills;
  late List<String> digitalSkills;
  late List<String> laborSkills;
  String? content;
  DateTime? lastUpdateDate;
  List<String> userConnectionTerritory = [];
  List<String> userContextualization = [];
  List<String> userReinforcement = [];
  List<String> userInterviews = [];
  List<String> userIntermediations = [];
  List<String> userObtainingEmployment = [];
  List<String> userImprovingEmployment = [];
  List<String> userCoordination = [];
  List<String> userLegal = [];
  List<String> userPostWorkSupport = [];
  List<String> userEconomicBag = [];
  List<String> userSpecificSkills = [];
  List<String> userSoftSkills = [];
  List<String> userDigitalSkills = [];
  List<String> userLaborSkills = [];
  late bool initialInterview = false;
  late bool initialQuestionary = false;
  late bool closeInterview = false;
  late bool closeQuestionary = false;
  late bool contactedPersonEvaluation = false;
  late bool contactedPersonNoIntervention = false;
  String? other;
  String? techId;
  final ValueNotifier<String> techName = ValueNotifier<String>("");
  bool wasManuallyChanged = false;

  Stream<UserEnreda>? _assignedUserStream;
  Stream<List<UserEnreda>>? _socialUsersStream;
  Stream<ClosureReport?>? _closureReportStream;

  // Estado del bloque de seguimiento a 4 semanas / 6 meses
  bool isFollowUpFourWeeksVisible = false;
  bool isFollowUpSixMonthsVisible = false;
  String? followUpSituation;
  String? followUpEmploymentTypeId;
  int? followUpSatisfaction;
  int? followUpImpact;
  String? followUpImprovement;

  @override
  void dispose() {
    textEditingControllerDateInput.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_assignedUserStream == null) {
      final database = Provider.of<Database>(context, listen: false);
      final assignedById = widget.participantUser.assignedById;
      if (assignedById != null && assignedById.isNotEmpty) {
        _assignedUserStream = database.userEnredaStreamByUserId(assignedById);
      }
      final entityId = globals.currentSocialEntityUser?.socialEntityId
          ?? widget.participantUser.assignedEntityId;
      if (entityId != null && entityId.isNotEmpty) {
        _socialUsersStream = database.getSocialUsersByEntityId(entityId);
      }
      String? closureReportId = widget.participantUser.closureReportId;
      if ((closureReportId == null || closureReportId.isEmpty) &&
          widget.participantUser.socialItineraryHistory.isNotEmpty) {
        for (final cycle in widget.participantUser.socialItineraryHistory.reversed) {
          if (cycle.closureReportId != null && cycle.closureReportId!.isNotEmpty) {
            closureReportId = cycle.closureReportId;
            break;
          }
        }
      }
      if (closureReportId != null && closureReportId.isNotEmpty) {
        _closureReportStream = database.closureReportStreamById(closureReportId);
      } else if (widget.participantUser.userId != null) {
        _closureReportStream = database
            .closureReportsStreamByUserId(widget.participantUser.userId)
            .map<ClosureReport?>((r) => r)
            .handleError((_) => null);
      }
    }
  }

@override
void initState() {
  super.initState();

  final ipil = widget.selectedIpil;

  reinforcement = ipil?.reinforcement ?? [];
  contextualization = ipil?.contextualization ?? [];
  connectionTerritory = ipil?.connectionTerritory ?? [];
  interviews = ipil?.interviews ?? [];
  intermediations = ipil?.intermediations ?? [];
  obtainingEmployment = ipil?.obtainingEmployment ?? [];
  improvingEmployment = ipil?.improvingEmployment ?? [];
  coordination = ipil?.coordination ?? [];
  legal = ipil?.legal ?? [];
  economicBag = ipil?.economicBag ?? [];
  specificSkills = ipil?.specificSkills ?? [];
  softSkills = ipil?.softSkills ?? [];
  digitalSkills = ipil?.digitalSkills ?? [];
  laborSkills = ipil?.laborSkills ?? [];
  content = ipil?.content ?? '';
  postWorkSupport = ipil?.postWorkSupport ?? [];
  other = ipil?.other ?? '';
  lastUpdateDate = ipil?.lastUpdateDate ?? DateTime.now();
  final currentUser = globals.currentSocialEntityUser;
  techId = ipil?.techId ?? currentUser?.userId ?? widget.participantUser.assignedById;
  techName.value = ipil?.techName ?? (currentUser != null ? '${currentUser.firstName} ${currentUser.lastName}' : '');

  contactedPersonEvaluation = ipil?.contactedPersonEvaluation ?? false;
  contactedPersonNoIntervention = ipil?.contactedPersonNoIntervention ?? false;

  userConnectionTerritory = ipil?.connectionTerritory ?? [];
  userContextualization = ipil?.contextualization ?? [];
  userReinforcement = ipil?.reinforcement ?? [];
  userInterviews = ipil?.interviews ?? [];
  userIntermediations = ipil?.intermediations ?? [];
  userObtainingEmployment = ipil?.obtainingEmployment ?? [];
  userImprovingEmployment = ipil?.improvingEmployment ?? [];
  userCoordination = ipil?.coordination ?? [];
  userLegal = ipil?.legal ?? [];
  userPostWorkSupport = ipil?.postWorkSupport ?? [];
  userEconomicBag = ipil?.economicBag ?? [];
  userSpecificSkills = ipil?.specificSkills ?? [];
  userSoftSkills = ipil?.softSkills ?? [];
  userDigitalSkills = ipil?.digitalSkills ?? [];
  userLaborSkills = ipil?.laborSkills ?? [];

  if (ipil != null) {
    if (ipil.fourWeeksCheck == true) {
      followUpSituation = ipil.fourWeeksSituation;
      followUpEmploymentTypeId = ipil.fourWeeksEmploymentTypeId;
      followUpSatisfaction = ipil.fourWeeksSatisfaction;
      followUpImpact = ipil.fourWeeksImpact;
      followUpImprovement = ipil.fourWeeksImprovement;
    } else if (ipil.sixMonthsCheck == true) {
      followUpSituation = ipil.sixMonthsSituation;
      followUpEmploymentTypeId = ipil.sixMonthsEmploymentTypeId;
      followUpSatisfaction = ipil.sixMonthsSatisfaction;
      followUpImpact = ipil.sixMonthsImpact;
      followUpImprovement = ipil.sixMonthsImprovement;
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return createIpilForm();
  }

  Widget _buildCachedCheckboxNoTitle({
    required String title,
    required List<dynamic> options,
    required List<String> selectedIds,
    required String Function(dynamic) getId,
    required String Function(dynamic) getLabel,
    required bool cornerTop,
    required bool cornerBottom,
    required void Function(List<String>) onChanged,
  }) {
    if (options.isEmpty) return Container();
    final dropdownItems = options.map((e) => DropdownItem(
      title: getLabel(e),
      isSelected: selectedIds.contains(getId(e)),
    )).toList();
    return CheckboxDropdownNoTitle(
      title: title,
      options: dropdownItems,
      cornerTop: cornerTop,
      cornerBottom: cornerBottom,
      onTapItem: (value, tapTitle) {
        final match = options.where((e) => getLabel(e) == tapTitle).firstOrNull;
        if (match == null) return;
        final id = getId(match);
        final updated = List<String>.from(selectedIds);
        if (value) { updated.add(id); } else { updated.remove(id); }
        onChanged(updated);
      },
    );
  }

  Widget _buildCachedCheckbox({
    required String title,
    required List<dynamic> options,
    required List<String> selectedIds,
    required String Function(dynamic) getId,
    required String Function(dynamic) getLabel,
    required void Function(List<String>) onChanged,
  }) {
    if (options.isEmpty) return Container();
    final dropdownItems = options.map((e) => DropdownItem(
      title: getLabel(e),
      isSelected: selectedIds.contains(getId(e)),
    )).toList();
    return CheckboxDropdown(
      title: title,
      options: dropdownItems,
      onTapItem: (value, tapTitle) {
        final match = options.where((e) => getLabel(e) == tapTitle).firstOrNull;
        if (match == null) return;
        final id = getId(match);
        final updated = List<String>.from(selectedIds);
        if (value) { updated.add(id); } else { updated.remove(id); }
        onChanged(updated);
      },
    );
  }

  Widget createIpilForm(){
    final database = Provider.of<Database>(context, listen: false);
    return Container(
      padding: Responsive.isMobile(context) ? EdgeInsets.all(10) : EdgeInsets.all(20),
      margin:  Responsive.isMobile(context) ? EdgeInsets.all(0) : EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      width: Responsive.isMobile(context) ? MediaQuery.of(context).size.width
          : MediaQuery.of(context).size.width * 0.6,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextMediumBold(text: StringConst.IPIL_CREATE),
            const SizedBox(height: 20),
            CustomFlexRowColumn(
              childRight: 
                StreamBuilder<UserEnreda>(
                  stream: _assignedUserStream,
                  builder: (context, assignedUserSnapshot) {
                    if (assignedUserSnapshot.hasData && !wasManuallyChanged) {
                      final newName = '${assignedUserSnapshot.data!.firstName} ${assignedUserSnapshot.data!.lastName}';
                      if (techName.value != newName) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          techName.value = newName;
                        });
                      }
                    }
                    return StreamBuilder<List<UserEnreda>>(
                      stream: _socialUsersStream,
                      builder: (context, snapshot) {
                        List<DropdownMenuItem<String>> techUsers = [];
                        List<UserEnreda> techUsersComplete = [];
                        if (snapshot.hasData) {
                          techUsersComplete = List.from(snapshot.data!);
                        }
                        
                        // Only add current user as fallback if the stream hasn't loaded yet
                        // and they belong to the same entity (guaranteed by stream query).
                        final currentUser = globals.currentSocialEntityUser;
                        if (currentUser != null && !techUsersComplete.any((u) => u.userId == currentUser.userId)) {
                          techUsersComplete.add(currentUser);
                        }

                        techUsers = techUsersComplete.map((userTech) {
                          return DropdownMenuItem<String>(
                            value: userTech.userId,
                            child: Text('${userTech.firstName ?? ''} ${userTech.lastName ?? ''}'),
                          );
                        }).toList();

                        String? currentTechId = (techId == '' ? widget.participantUser.assignedById : techId);
                        if (!techUsers.any((item) => item.value == currentTechId)) {
                          currentTechId = null;
                        }
                        return CustomDropDownButtonFormFieldTittle(
                          labelText: StringConst.TECHNICAL_NAME,
                          value: currentTechId,
                          onChanged: (value) {
                            setState(() {
                              wasManuallyChanged = true;
                              techId = value!;
                              final match = techUsersComplete.where((e) => e.userId == value).firstOrNull;
                              if (match != null) {
                                techName.value = '${match.firstName ?? ''} ${match.lastName ?? ''}';
                              }
                            });
                          },
                          source: techUsers);
                      }
                    );
                  }
                ),         
              childLeft: CustomDatePickerTitleOpen(
                labelText: StringConst.DATE,
                enabled: true,
                color: AppColors.primary900,
                initialValue: lastUpdateDate,
                onChanged: (value) {
                  setState(() {
                    lastUpdateDate = value;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble / 2),
              child: CustomTextFormFieldLong(
                labelText: StringConst.GOALS_MONITORING,
                hintText: StringConst.IPIL_GOALS_MONITORING_PLACEHOLDER,
                initialValue: content,
                validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
                enabled: true,
                onSaved: (value) async{
                  content = value;
                },
              ),
            ),

            // Bloque de seguimiento a las 4 semanas o 6 meses si corresponde
            _buildFollowUpSection(),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: Sizes.kDefaultPaddingDouble / 2),
              child: StreamBuilder(
                stream: database.getIpilEntriesByUserStream(widget.participantUser.userId ?? ''), 
                builder: (context, snapshot){
                  bool initialInterviewSelectable = true;
                  bool initialQuestionarySelectable = true;
                  bool closeInterviewSelectable = true;
                  bool closeQuestionarySelectable = true;
                  bool contactedPersonEvaluationSelectable = true;
                  bool contactedPersonNoInterventionSelectable = true;
                  if(snapshot.hasData){
                    List<IpilEntry> ipilsFromUser = snapshot.data!;
                    for(IpilEntry entry in ipilsFromUser){
                      // Skip the currently-edited entry so its own values don't
                      // block itself.
                      if (widget.selectedIpil != null &&
                          entry.ipilId == widget.selectedIpil!.ipilId) continue;
                      if(entry.initialInterview == true){
                        initialInterview = true;
                        initialInterviewSelectable = false;
                        // Entrevista inicial already taken → block new option
                        contactedPersonEvaluationSelectable = false;
                      }
                      if(entry.initialJobValorationQuestionary == true){
                        initialQuestionary = true;
                        initialQuestionarySelectable = false;
                        contactedPersonEvaluationSelectable = false;
                      }
                      if(entry.contactedPersonEvaluation == true){
                        contactedPersonEvaluation = true;
                        contactedPersonEvaluationSelectable = false;
                        // "En evaluación" already taken → block the other initial options
                        initialInterviewSelectable = false;
                        initialQuestionarySelectable = false;
                      }
                      if(entry.finalInterview == true){
                        closeInterview = true;
                        closeInterviewSelectable = false;
                        contactedPersonNoInterventionSelectable = false;
                      }
                      if(entry.finalJobValorationQuestionary == true){
                        closeQuestionary = true;
                        closeQuestionarySelectable = false;
                        contactedPersonNoInterventionSelectable = false;
                      }
                      if(entry.contactedPersonNoIntervention == true){
                        contactedPersonNoIntervention = true;
                        contactedPersonNoInterventionSelectable = false;
                        closeInterviewSelectable = false;
                        closeQuestionarySelectable = false;
                      }
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Sizes.kDefaultPaddingDouble / 2),
                          child: CustomTextBold(title: StringConst.IPIL_INITIAL_ITINERARY, color: AppColors.primary900,),
                        ),
                        CustomCheckBoxSelectable(
                          title: StringConst.IPIL_INITIAL_CONTACTED,
                          isSelected: contactedPersonEvaluation,
                          onTapItem: (value){
                            setState(() {
                              contactedPersonEvaluation = value;
                              // Mutually exclusive with Entrevista inicial
                              // and Cuestionario inicial
                              if (value) {
                                initialInterview = false;
                                initialQuestionary = false;
                              }
                            });
                          },
                          selectable: contactedPersonEvaluationSelectable,
                        ),
                        CustomCheckBoxSelectable(
                          title:StringConst.IPIL_INITIAL_INTERVIEW, 
                          isSelected: initialInterview, 
                          onTapItem: (value){
                            setState(() {
                              initialInterview = value;
                              if (value) contactedPersonEvaluation = false;
                            });
                          }, 
                          selectable: initialInterviewSelectable,
                        ),
                        CustomCheckBoxSelectable(
                          title:StringConst.IPIL_INITIAL_QUESTIONARY, 
                          isSelected: initialQuestionary, 
                          onTapItem: (value){
                            setState(() {
                              initialQuestionary = value;
                              if (value) contactedPersonEvaluation = false;
                            });
                          }, 
                          selectable: initialQuestionarySelectable,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Sizes.kDefaultPaddingDouble / 2),
                          child: CustomTextBold(title: StringConst.IPIL_CLOSE_ITINERARY, color: AppColors.primary900,),
                        ),
                        CustomCheckBoxSelectable(
                          title: StringConst.IPIL_CLOSE_CONTACTED_NO_INTERVENTION,
                          isSelected: contactedPersonNoIntervention,
                          onTapItem: (value){
                            setState(() {
                              contactedPersonNoIntervention = value;
                              if (value) {
                                closeInterview = false;
                                closeQuestionary = false;
                              }
                            });
                          },
                          selectable: contactedPersonNoInterventionSelectable,
                        ),
                        CustomCheckBoxSelectable(
                          title:StringConst.IPIL_CLOSE_INTERVIEW, 
                          isSelected: closeInterview, 
                          onTapItem: (value){
                            setState(() {
                              closeInterview = value;
                              if (value) contactedPersonNoIntervention = false;
                            });
                          }, 
                          selectable: closeInterviewSelectable,
                        ),
                        CustomCheckBoxSelectable(
                          title:StringConst.IPIL_CLOSE_QUESTIONARY, 
                          isSelected: closeQuestionary, 
                          onTapItem: (value){
                            setState(() {
                              closeQuestionary = value;
                              if (value) contactedPersonNoIntervention = false;
                            });
                          }, 
                          selectable: closeQuestionarySelectable,
                        ),
                      ]
                    );
                  }
                  else{
                    return Container();
                  }
                }
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sizes.kDefaultPaddingDouble / 2),
              child: CustomTextBold(title: StringConst.IPIL_REINFORCEMENT, color: AppColors.primary900,),
            ),
            _buildCachedCheckboxNoTitle(
              title: StringConst.IPIL_SPECIFIC_SKILLS,
              options: LocationCache.instance.ipilSpecificSkills,
              selectedIds: userSpecificSkills,
              getId: (e) => (e as IpilSpecificSkills).ipilSpecificSkillsId ?? '',
              getLabel: (e) => (e as IpilSpecificSkills).label,
              cornerTop: true,
              cornerBottom: false,
              onChanged: (ids) => setState(() { userSpecificSkills = ids; specificSkills = ids; }),
            ),
            _buildCachedCheckboxNoTitle(
              title: StringConst.IPIL_SOFT_SKILLS,
              options: LocationCache.instance.ipilSoftSkills,
              selectedIds: userSoftSkills,
              getId: (e) => (e as IpilSoftSkills).ipilSoftSkillsId ?? '',
              getLabel: (e) => (e as IpilSoftSkills).label,
              cornerTop: false,
              cornerBottom: false,
              onChanged: (ids) => setState(() { userSoftSkills = ids; softSkills = ids; }),
            ),
            _buildCachedCheckboxNoTitle(
              title: StringConst.IPIL_DIGITAL_SKILLS,
              options: LocationCache.instance.ipilDigitalSkills,
              selectedIds: userDigitalSkills,
              getId: (e) => (e as IpilDigitalSkills).ipilDigitalSkillsId ?? '',
              getLabel: (e) => (e as IpilDigitalSkills).label,
              cornerTop: false,
              cornerBottom: false,
              onChanged: (ids) => setState(() { userDigitalSkills = ids; digitalSkills = ids; }),
            ),
            _buildCachedCheckboxNoTitle(
              title: StringConst.IPIL_LABOR_SKILLS,
              options: LocationCache.instance.ipilLaborSkills,
              selectedIds: userLaborSkills,
              getId: (e) => (e as IpilLaborSkills).ipilLaborSkillsId ?? '',
              getLabel: (e) => (e as IpilLaborSkills).label,
              cornerTop: false,
              cornerBottom: true,
              onChanged: (ids) => setState(() { userLaborSkills = ids; laborSkills = ids; }),
            ),
            SizedBox(height: Sizes.kDefaultPaddingDouble / 2),
            _buildCachedCheckbox(
              title: StringConst.IPIL_CONTEXTUALIZATION,
              options: LocationCache.instance.ipilContextualizations,
              selectedIds: userContextualization,
              getId: (e) => (e as IpilContextualization).ipilContextualizationId ?? '',
              getLabel: (e) => (e as IpilContextualization).label,
              onChanged: (ids) => setState(() { userContextualization = ids; contextualization = ids; }),
            ),
            _buildCachedCheckbox(
              title: StringConst.IPIL_CONNECTION_TERRITORY,
              options: LocationCache.instance.ipilConnectionTerritories,
              selectedIds: userConnectionTerritory,
              getId: (e) => (e as IpilConnectionTerritory).ipilConnectionTerritoryId ?? '',
              getLabel: (e) => (e as IpilConnectionTerritory).label,
              onChanged: (ids) => setState(() { userConnectionTerritory = ids; connectionTerritory = ids; }),
            ),
            _buildCachedCheckbox(
              title: StringConst.IPIL_INTERMEDIATIONS,
              options: LocationCache.instance.ipilIntermediations,
              selectedIds: userIntermediations,
              getId: (e) => (e as IpilIntermediations).ipilIntermediationsId ?? '',
              getLabel: (e) => (e as IpilIntermediations).label,
              onChanged: (ids) => setState(() { userIntermediations = ids; intermediations = ids; }),
            ),
            _buildCachedCheckbox(
              title: StringConst.IPIL_INTERVIEWS,
              options: LocationCache.instance.ipilInterviews,
              selectedIds: userInterviews,
              getId: (e) => (e as IpilInterviews).ipilInterviewsId ?? '',
              getLabel: (e) => (e as IpilInterviews).label,
              onChanged: (ids) => setState(() { userInterviews = ids; interviews = ids; }),
            ),
            _buildCachedCheckbox(
              title: StringConst.IPIL_OBTAINING_EMPLOYMENT,
              options: LocationCache.instance.ipilObtainingEmployments,
              selectedIds: userObtainingEmployment,
              getId: (e) => (e as IpilObtainingEmployment).ipilObtainingEmploymentId ?? '',
              getLabel: (e) => (e as IpilObtainingEmployment).label,
              onChanged: (ids) => setState(() { userObtainingEmployment = ids; obtainingEmployment = ids; }),
            ),
            _buildCachedCheckbox(
              title: StringConst.IPIL_IMPROVING_EMPLOYMENT,
              options: LocationCache.instance.ipilImprovingEmployments,
              selectedIds: userImprovingEmployment,
              getId: (e) => (e as IpilImprovingEmployment).ipilImprovingEmploymentId ?? '',
              getLabel: (e) => (e as IpilImprovingEmployment).label,
              onChanged: (ids) => setState(() { userImprovingEmployment = ids; improvingEmployment = ids; }),
            ),
            _buildCachedCheckbox(
              title: StringConst.IPIL_COORDINATION,
              options: LocationCache.instance.ipilCoordinations,
              selectedIds: userCoordination,
              getId: (e) => (e as IpilCoordination).ipilCoordinationId ?? '',
              getLabel: (e) => (e as IpilCoordination).label,
              onChanged: (ids) => setState(() { userCoordination = ids; coordination = ids; }),
            ),
            _buildCachedCheckbox(
              title: StringConst.IPIL_LEGAL,
              options: LocationCache.instance.ipilLegals,
              selectedIds: userLegal,
              getId: (e) => (e as IpilLegal).ipilLegalId ?? '',
              getLabel: (e) => (e as IpilLegal).label,
              onChanged: (ids) => setState(() { userLegal = ids; legal = ids; }),
            ),
            _buildCachedCheckbox(
              title: StringConst.IPIL_POST_WORK_SUPPORT,
              options: LocationCache.instance.ipilPostWorkSupports,
              selectedIds: userPostWorkSupport,
              getId: (e) => (e as IpilPostWorkSupport).ipilPostWorkSupportId ?? '',
              getLabel: (e) => (e as IpilPostWorkSupport).label,
              onChanged: (ids) => setState(() { userPostWorkSupport = ids; postWorkSupport = ids; }),
            ),
            _buildCachedCheckbox(
              title: StringConst.IPIL_ECONOMIC_BAG,
              options: LocationCache.instance.ipilEconomicBags,
              selectedIds: userEconomicBag,
              getId: (e) => (e as IpilEconomicBag).ipilEconomicBagId ?? '',
              getLabel: (e) => (e as IpilEconomicBag).label,
              onChanged: (ids) => setState(() { userEconomicBag = ids; economicBag = ids; }),
            ),
            Padding(
              padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble / 2),
              child: CustomTextFormFieldTitle(
                color: AppColors.primary900,
                labelText: StringConst.IPIL_OTHERS,
                initialValue: other,
                onSaved: (value) async{
                  other = value;
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    EnredaButton(
                      buttonTitle: StringConst.CANCEL,
                      buttonColor: AppColors.turquoise,
                      titleColor: Colors.white,
                      height: 50.0,
                      width: 160,
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      onPressed: (){
                        setState(() {
                          ParticipantIPILPage.selectedIndexIpils.value = 0;
                        });
                      },
                    ),
                    SizedBox(width: 20),
                    EnredaButton(
                      buttonTitle: StringConst.SAVE,
                      buttonColor: AppColors.turquoise,
                      titleColor: Colors.white,
                      height: 50.0,
                      width: 160,
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowUpSection() {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<ClosureReport?>(
      stream: _closureReportStream,
      builder: (context, closureReportSnapshot) {
        final closureReport = closureReportSnapshot.data;
        return StreamBuilder<List<IpilEntry>>(
          stream: database.getIpilEntriesByUserStream(widget.participantUser.userId ?? ''),
          builder: (context, ipilsSnapshot) {
            final ipilsFromUser = ipilsSnapshot.data ?? [];

            bool showFourWeeks = false;
            bool showSixMonths = false;

            // 1. Si se está editando un IPIL que ya tenía guardado el check:
            if (widget.selectedIpil != null) {
              if (widget.selectedIpil!.fourWeeksCheck == true) {
                showFourWeeks = true;
              } else if (widget.selectedIpil!.sixMonthsCheck == true) {
                showSixMonths = true;
              }
            }

            // 2. Si no viene ya marcado por edición, evaluamos el tiempo transcurrido
            // desde la fecha de completado del Informe de Cierre hasta la fecha del selector del IPIL
            if (!showFourWeeks && !showSixMonths) {
              DateTime? completedDate = closureReport?.completedDate;
              bool isFinished = closureReport?.finished ?? false;

              if (completedDate == null && widget.participantUser.socialItineraryHistory.isNotEmpty) {
                for (final cycle in widget.participantUser.socialItineraryHistory.reversed) {
                  if (cycle.closureDate != null) {
                    completedDate = cycle.closureDate;
                    isFinished = true;
                    break;
                  }
                }
              }

              if (isFinished && completedDate != null) {
                final completedDateVal = completedDate;
                final selectedDate = lastUpdateDate ?? DateTime.now();
                final diffDays = selectedDate.difference(completedDateVal).inDays;

                final sixMonthsDate = DateTime(
                  completedDateVal.year,
                  completedDateVal.month + 6,
                  completedDateVal.day,
                );
                final isAtLeastSixMonths = selectedDate.isAfter(sixMonthsDate) ||
                    selectedDate.isAtSameMomentAs(sixMonthsDate) ||
                    diffDays >= 182;
                final isAtLeastFourWeeks = diffDays >= 28;

                final hasFourWeeksDone = ipilsFromUser.any((e) =>
                    e.ipilId != widget.selectedIpil?.ipilId && e.fourWeeksCheck == true);
                final hasSixMonthsDone = ipilsFromUser.any((e) =>
                    e.ipilId != widget.selectedIpil?.ipilId && e.sixMonthsCheck == true);

                if (!hasFourWeeksDone) {
                  // Si no se ha completado el de 4 semanas, solo se evalúa y muestra ese
                  if (isAtLeastFourWeeks) {
                    showFourWeeks = true;
                  }
                } else if (!hasSixMonthsDone) {
                  // Si el de 4 semanas ya se completó y no se ha hecho el de 6 meses
                  if (isAtLeastSixMonths) {
                    showSixMonths = true;
                  }
                }
              }
            }

            isFollowUpFourWeeksVisible = showFourWeeks;
            isFollowUpSixMonthsVisible = showSixMonths;

            if (!showFourWeeks && !showSixMonths) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.kDefaultPaddingDouble / 2,
              ),
              child: IpilFollowUpSection(
                isFourWeeks: showFourWeeks,
                situation: followUpSituation,
                employmentTypeId: followUpEmploymentTypeId,
                satisfaction: followUpSatisfaction,
                impact: followUpImpact,
                improvement: followUpImprovement,
                onSituationChanged: (val) {
                  setState(() {
                    followUpSituation = val;
                    if (val != StringConst.IPIL_SITUATION_EMPLOYMENT) {
                      followUpEmploymentTypeId = null;
                      followUpSatisfaction = null;
                    }
                  });
                },
                onEmploymentTypeChanged: (val) {
                  setState(() {
                    followUpEmploymentTypeId = val;
                  });
                },
                onSatisfactionChanged: (val) {
                  setState(() {
                    followUpSatisfaction = val;
                  });
                },
                onImpactChanged: (val) {
                  setState(() {
                    followUpImpact = val;
                  });
                },
                onImprovementChanged: (val) {
                  followUpImprovement = val;
                },
              ),
            );
          },
        );
      },
    );
  }

  bool _validateAndSaveForm() {
    if (_formKey.currentState != null &&
        _formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      return true;
    }
    return false;
  }

  Future<void> _submit() async {
    if (_validateAndSaveForm() == false) {
      await showAlertDialog(context,
          title: StringConst.FORM_ENTITY_ERROR,
          content: StringConst.FORM_ENTITY_CHECK,
          defaultActionText: StringConst.CLOSE);
      return;
    }

    // Validación obligatoria de los campos del seguimiento si está activo
    if (isFollowUpFourWeeksVisible || isFollowUpSixMonthsVisible) {
      if (followUpSituation == null || followUpSituation!.isEmpty) {
        await showAlertDialog(
          context,
          title: StringConst.FORM_ENTITY_ERROR,
          content: 'Por favor, selecciona en qué situación se encuentra la persona en el seguimiento pendiente.',
          defaultActionText: StringConst.FORM_ACCEPT,
        );
        return;
      }
      if (followUpSituation == StringConst.IPIL_SITUATION_EMPLOYMENT) {
        if (followUpEmploymentTypeId == null || followUpEmploymentTypeId!.isEmpty) {
          await showAlertDialog(
            context,
            title: StringConst.FORM_ENTITY_ERROR,
            content: 'Por favor, selecciona el tipo de empleo en el seguimiento pendiente.',
            defaultActionText: StringConst.FORM_ACCEPT,
          );
          return;
        }
        if (followUpSatisfaction == null) {
          await showAlertDialog(
            context,
            title: StringConst.FORM_ENTITY_ERROR,
            content: 'Por favor, selecciona el nivel de satisfacción (1 al 4) en el seguimiento pendiente.',
            defaultActionText: StringConst.FORM_ACCEPT,
          );
          return;
        }
      }
      if (followUpImpact == null) {
        await showAlertDialog(
          context,
          title: StringConst.FORM_ENTITY_ERROR,
          content: 'Por favor, selecciona el impacto percibido (1 al 6) en el seguimiento pendiente.',
          defaultActionText: StringConst.FORM_ACCEPT,
        );
        return;
      }
      if (followUpImprovement == null || followUpImprovement!.trim().isEmpty) {
        await showAlertDialog(
          context,
          title: StringConst.FORM_ENTITY_ERROR,
          content: 'Por favor, indica cómo cree la persona que podemos mejorar el acompañamiento.',
          defaultActionText: StringConst.FORM_ACCEPT,
        );
        return;
      }
    }

    if (_validateAndSaveForm()) {
      debugPrint("validado");
      try {
        final database = Provider.of<Database>(context, listen: false);
        print('selectedIPIL: ${widget.selectedIpil}');
        if(widget.selectedIpil == null){
          IpilEntry newIpilEntry = IpilEntry(
            date: DateTime.now(),
            lastUpdateDate: lastUpdateDate!,
            userId: widget.participantUser.userId!,
            techId: techId,
            techName: techName.value,
            content: content,
            interviews: interviews,
            intermediations: intermediations,
            connectionTerritory: connectionTerritory,
            contextualization: contextualization,
            reinforcement: reinforcement,
            obtainingEmployment: obtainingEmployment,
            improvingEmployment: improvingEmployment,
            coordination: coordination,
            legal: legal,
            economicBag: economicBag,
            postWorkSupport: postWorkSupport,
            specificSkills: specificSkills,
            softSkills: softSkills,
            digitalSkills: digitalSkills,
            laborSkills: laborSkills,
            initialInterview: initialInterview,
            initialJobValorationQuestionary: initialQuestionary,
            finalInterview: closeInterview,
            finalJobValorationQuestionary: closeQuestionary,
            contactedPersonEvaluation: contactedPersonEvaluation,
            contactedPersonNoIntervention: contactedPersonNoIntervention,
            other: other,
            fourWeeksCheck: isFollowUpFourWeeksVisible ? true : null,
            fourWeeksSituation: isFollowUpFourWeeksVisible ? followUpSituation : null,
            fourWeeksEmploymentTypeId: isFollowUpFourWeeksVisible
                ? (followUpSituation == StringConst.IPIL_SITUATION_EMPLOYMENT ? followUpEmploymentTypeId : null)
                : null,
            fourWeeksSatisfaction: isFollowUpFourWeeksVisible
                ? (followUpSituation == StringConst.IPIL_SITUATION_EMPLOYMENT ? followUpSatisfaction : null)
                : null,
            fourWeeksImpact: isFollowUpFourWeeksVisible ? followUpImpact : null,
            fourWeeksImprovement: isFollowUpFourWeeksVisible ? followUpImprovement : null,
            sixMonthsCheck: isFollowUpSixMonthsVisible ? true : null,
            sixMonthsSituation: isFollowUpSixMonthsVisible ? followUpSituation : null,
            sixMonthsEmploymentTypeId: isFollowUpSixMonthsVisible
                ? (followUpSituation == StringConst.IPIL_SITUATION_EMPLOYMENT ? followUpEmploymentTypeId : null)
                : null,
            sixMonthsSatisfaction: isFollowUpSixMonthsVisible
                ? (followUpSituation == StringConst.IPIL_SITUATION_EMPLOYMENT ? followUpSatisfaction : null)
                : null,
            sixMonthsImpact: isFollowUpSixMonthsVisible ? followUpImpact : null,
            sixMonthsImprovement: isFollowUpSixMonthsVisible ? followUpImprovement : null,
          );
          await database.addIpilEntry(newIpilEntry);
          await showAlertDialog(
            context,
            title: StringConst.CREATE_IPIL,
            content: StringConst.CREATE_IPIL_SUCCESS,
            defaultActionText: StringConst.FORM_ACCEPT,
          );
        }else{
          IpilEntry updatedIpilEntry = IpilEntry(
            ipilId: widget.selectedIpil!.ipilId,
            lastUpdateDate: lastUpdateDate,
            date: widget.selectedIpil!.date,
            userId: widget.participantUser.userId!,
            techId: techId,
            techName: techName.value,
            content: content,
            interviews: interviews,
            intermediations: intermediations,
            connectionTerritory: connectionTerritory,
            contextualization: contextualization,
            reinforcement: reinforcement,
            obtainingEmployment: obtainingEmployment,
            improvingEmployment: improvingEmployment,
            coordination: coordination,
            legal: legal,
            economicBag: economicBag,
            postWorkSupport: postWorkSupport,
            specificSkills: specificSkills,
            softSkills: softSkills,
            digitalSkills: digitalSkills,
            laborSkills: laborSkills,
            initialInterview: initialInterview,
            initialJobValorationQuestionary: initialQuestionary,
            finalInterview: closeInterview,
            finalJobValorationQuestionary: closeQuestionary,
            contactedPersonEvaluation: contactedPersonEvaluation,
            contactedPersonNoIntervention: contactedPersonNoIntervention,
            other: other,
            fourWeeksCheck: isFollowUpFourWeeksVisible ? true : widget.selectedIpil!.fourWeeksCheck,
            fourWeeksSituation: isFollowUpFourWeeksVisible ? followUpSituation : widget.selectedIpil!.fourWeeksSituation,
            fourWeeksEmploymentTypeId: isFollowUpFourWeeksVisible
                ? (followUpSituation == StringConst.IPIL_SITUATION_EMPLOYMENT ? followUpEmploymentTypeId : null)
                : widget.selectedIpil!.fourWeeksEmploymentTypeId,
            fourWeeksSatisfaction: isFollowUpFourWeeksVisible
                ? (followUpSituation == StringConst.IPIL_SITUATION_EMPLOYMENT ? followUpSatisfaction : null)
                : widget.selectedIpil!.fourWeeksSatisfaction,
            fourWeeksImpact: isFollowUpFourWeeksVisible ? followUpImpact : widget.selectedIpil!.fourWeeksImpact,
            fourWeeksImprovement: isFollowUpFourWeeksVisible ? followUpImprovement : widget.selectedIpil!.fourWeeksImprovement,
            sixMonthsCheck: isFollowUpSixMonthsVisible ? true : widget.selectedIpil!.sixMonthsCheck,
            sixMonthsSituation: isFollowUpSixMonthsVisible ? followUpSituation : widget.selectedIpil!.sixMonthsSituation,
            sixMonthsEmploymentTypeId: isFollowUpSixMonthsVisible
                ? (followUpSituation == StringConst.IPIL_SITUATION_EMPLOYMENT ? followUpEmploymentTypeId : null)
                : widget.selectedIpil!.sixMonthsEmploymentTypeId,
            sixMonthsSatisfaction: isFollowUpSixMonthsVisible
                ? (followUpSituation == StringConst.IPIL_SITUATION_EMPLOYMENT ? followUpSatisfaction : null)
                : widget.selectedIpil!.sixMonthsSatisfaction,
            sixMonthsImpact: isFollowUpSixMonthsVisible ? followUpImpact : widget.selectedIpil!.sixMonthsImpact,
            sixMonthsImprovement: isFollowUpSixMonthsVisible ? followUpImprovement : widget.selectedIpil!.sixMonthsImprovement,
          );
          await database.setIpilEntry(updatedIpilEntry);
          await showAlertDialog(
            context,
            title: StringConst.UPDATE_IPIL,
            content: StringConst.UPDATE_IPIL_SUCCESS,
            defaultActionText: StringConst.FORM_ACCEPT,
          );
        }
        
        ParticipantIPILPage.selectedIndexIpils.value = 0;
      } on FirebaseException catch (e) {
        showExceptionAlertDialog(context,
            title: StringConst.FORM_ERROR, exception: e).then((value) => Navigator.pop(context));
      }
    }
  }
}
