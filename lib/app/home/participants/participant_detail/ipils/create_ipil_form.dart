import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enreda_empresas/app/common_widgets/custom_check_box_selectable.dart';
import 'package:enreda_empresas/app/common_widgets/custom_drop_down-button_form_field_no_title_check.dart';
import 'package:enreda_empresas/app/common_widgets/custom_drop_down_button_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_form_field.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_form_field_long.dart';
import 'package:enreda_empresas/app/common_widgets/flex_row_column.dart';
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
import '../../../../models/ipilConnectionTerritory.dart';
import '../../../../models/ipilContextualization.dart';
import '../../../../models/ipilEntry.dart';
import '../../../../models/ipilInterviews.dart';
import '../../../../models/ipilReinforcement.dart';
import '../../../../models/userEnreda.dart';
import '../../../../services/database.dart';
import '../../../../utils/responsive.dart';
import '../../../../values/values.dart';

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
  String? other;
  String? techId;
  final ValueNotifier<String> techName = ValueNotifier<String>("");
  bool wasManuallyChanged = false;

  @override
  void dispose() {
    textEditingControllerDateInput.dispose();
    super.dispose();
  }
@override
void initState() {
  super.initState();

  final ipil = widget.selectedIpil;
  print('Existe el ipil? $ipil');

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
  techId = ipil?.techId ?? widget.participantUser.assignedById;
  techName.value = ipil?.techName ?? '';

  userConnectionTerritory = ipil?.connectionTerritory ?? [];
  userContextualization = ipil?.contextualization ?? [];
  userReinforcement = ipil?.reinforcement ?? [];
  userInterviews = ipil?.interviews ?? [];
  userIntermediations = ipil?.intermediations ?? [];
  userObtainingEmployment = ipil?.obtainingEmployment ?? [];;
  userImprovingEmployment = ipil?.improvingEmployment ?? [];;
  userCoordination = ipil?.coordination ?? [];
  userLegal = ipil?.legal ?? [];
  userPostWorkSupport = ipil?.postWorkSupport ?? [];
  userEconomicBag = ipil?.economicBag ?? [];
  userSpecificSkills = ipil?.specificSkills ?? [];
  userSoftSkills = ipil?.softSkills ?? [];
  userDigitalSkills = ipil?.digitalSkills ?? [];
  userLaborSkills = ipil?.laborSkills ?? [];
}

  @override
  Widget build(BuildContext context) {
    return createIpilForm();
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
                  stream: database.userEnredaStreamByUserId(widget.participantUser.assignedById),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && !wasManuallyChanged) {
                      final newName = '${snapshot.data!.firstName} ${snapshot.data!.lastName}';
                      if (techName.value != newName) {
                        techName.value = newName;
                      }
                    }
                    return StreamBuilder<List<UserEnreda>>(
                      stream: database.getSocialUsersByEntityId(widget.participantUser.assignedEntityId!),
                      builder: (context, snapshot) {
                        List<DropdownMenuItem<String>> techUsers = [];
                        List<UserEnreda> techUsersComplete = [];
                        UserEnreda realTechUser;
                        if(snapshot.hasData){
                          techUsersComplete = snapshot.data!;
                          techUsers = 
                            snapshot.data!.map((userTech) {
                              return DropdownMenuItem<String>(
                                value: userTech.userId,
                                child: Text('${userTech.firstName}' + ' ' + '${userTech.lastName}'),
                              );
                            }).toList();
                            realTechUser = techUsersComplete.firstWhere((element) => element.userId == widget.participantUser.assignedById!);
                        }
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
                              UserEnreda techUserComplete = techUsersComplete.firstWhere((element) => element.userId == value);
                              techName.value = '${techUserComplete.firstName}' + ' ' + '${techUserComplete.lastName}';
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

            Padding(
              padding: const EdgeInsets.symmetric(vertical: Sizes.kDefaultPaddingDouble / 2),
              child: StreamBuilder(
                stream: database.getIpilEntriesByUserStream(widget.participantUser.userId!), 
                builder: (context, snapshot){
                  bool initialInterviewSelectable = true;
                  bool initialQuestionarySelectable = true;
                  bool closeInterviewSelectable = true;
                  bool closeQuestionarySelectable = true;
                  if(snapshot.hasData){
                    List<IpilEntry> ipilsFromUser = snapshot.data!;
                    for(IpilEntry entry in ipilsFromUser){
                      if(entry.initialInterview!){
                        initialInterview = true;
                        initialInterviewSelectable = false;
                      }
                      if(entry.initialJobValorationQuestionary!){
                        initialQuestionary = true;
                        initialQuestionarySelectable = false;
                      }
                      if(entry.finalInterview!){
                        closeInterview = true;
                        closeInterviewSelectable = false;
                      }
                      if(entry.finalJobValorationQuestionary!){
                        closeQuestionary = true;
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
                          title:StringConst.IPIL_INITIAL_INTERVIEW, 
                          isSelected: initialInterview, 
                          onTapItem: (value){
                            setState(() {
                              initialInterview = value;
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
                            });
                          }, 
                          selectable: initialQuestionarySelectable,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Sizes.kDefaultPaddingDouble / 2),
                          child: CustomTextBold(title: StringConst.IPIL_CLOSE_ITINERARY, color: AppColors.primary900,),
                        ),
                        CustomCheckBoxSelectable(
                          title:StringConst.IPIL_CLOSE_INTERVIEW, 
                          isSelected: closeInterview, 
                          onTapItem: (value){
                            setState(() {
                              closeInterview = value;
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
            StreamBuilder<List<IpilSpecificSkills>>(
              stream: database.ipilSpecificSkillsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<IpilSpecificSkills> specificSkillsOptions = snapshot.data!;
                  List<DropdownItem> specificSkillsOptionsDropdown = [];
                  for (var element in specificSkillsOptions) {
                    specificSkillsOptionsDropdown.add(DropdownItem(
                      title: element.label,
                      isSelected: userSpecificSkills.contains(element.ipilSpecificSkillsId),
                    ));
                  }
                  return CheckboxDropdownNoTitle(
                    title: StringConst.IPIL_SPECIFIC_SKILLS,
                    options: specificSkillsOptionsDropdown,
                    cornerBottom: false,
                    cornerTop: true,
                    onTapItem: (value, title) {
                      setState(() {
                        IpilSpecificSkills itemSelected = specificSkillsOptions.firstWhere((element) => element.label == title);
                        if (value) {
                          userSpecificSkills.add(itemSelected.ipilSpecificSkillsId!);
                        } else {
                          userSpecificSkills.removeWhere((element) => element == itemSelected.ipilSpecificSkillsId);
                        }
                        specificSkills = userSpecificSkills;
                      });
                    },
                  );
                } else {
                  return Container(); // Placeholder for loading state
                }
              },
            ),
            StreamBuilder<List<IpilSoftSkills>>(
              stream: database.ipilSoftSkillsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<IpilSoftSkills> softSkillsOptions = snapshot.data!;
                  List<DropdownItem> softSkillsOptionsDropdown = [];
                  for (var element in softSkillsOptions) {
                    softSkillsOptionsDropdown.add(DropdownItem(
                      title: element.label,
                      isSelected: userSoftSkills.contains(element.ipilSoftSkillsId),
                    ));
                  }
                  return CheckboxDropdownNoTitle(
                    title: StringConst.IPIL_SOFT_SKILLS,
                    options: softSkillsOptionsDropdown,
                    cornerBottom: false,
                    cornerTop: false,
                    onTapItem: (value, title) {
                      setState(() {
                        IpilSoftSkills itemSelected = softSkillsOptions.firstWhere((element) => element.label == title);
                        if (value) {
                          userSoftSkills.add(itemSelected.ipilSoftSkillsId!);
                        } else {
                          userSoftSkills.removeWhere((element) => element == itemSelected.ipilSoftSkillsId);
                        }
                        softSkills = userSoftSkills;
                      });
                    },
                  );
                } else {
                  return Container(); // Placeholder for loading state
                }
              },
            ),
            StreamBuilder<List<IpilDigitalSkills>>(
              stream: database.ipilDigitalSkillsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<IpilDigitalSkills> digitalSkillsOptions = snapshot.data!;
                  List<DropdownItem> digitalSkillsOptionsDropdown = [];
                  for (var element in digitalSkillsOptions) {
                    digitalSkillsOptionsDropdown.add(DropdownItem(
                      title: element.label,
                      isSelected: userDigitalSkills.contains(element.ipilDigitalSkillsId),
                    ));
                  }
                  return CheckboxDropdownNoTitle(
                    title: StringConst.IPIL_DIGITAL_SKILLS,
                    options: digitalSkillsOptionsDropdown,
                    cornerBottom: false,
                    cornerTop: false,
                    onTapItem: (value, title) {
                      setState(() {
                        IpilDigitalSkills itemSelected = digitalSkillsOptions.firstWhere((element) => element.label == title);
                        if (value) {
                          userDigitalSkills.add(itemSelected.ipilDigitalSkillsId!);
                        } else {
                          userDigitalSkills.removeWhere((element) => element == itemSelected.ipilDigitalSkillsId);
                        }
                        digitalSkills = userDigitalSkills;
                      });
                    },
                  );
                } else {
                  return Container(); // Placeholder for loading state
                }
              },
            ),
            StreamBuilder<List<IpilLaborSkills>>(
              stream: database.ipilLaborSkillsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<IpilLaborSkills> laborSkillsOptions = snapshot.data!;
                  List<DropdownItem> laborSkillsOptionsDropdown = [];
                  for (var element in laborSkillsOptions) {
                    laborSkillsOptionsDropdown.add(DropdownItem(
                      title: element.label,
                      isSelected: userLaborSkills.contains(element.ipilLaborSkillsId),
                    ));
                  }
                  return CheckboxDropdownNoTitle(
                    title: StringConst.IPIL_LABOR_SKILLS,
                    options: laborSkillsOptionsDropdown,
                    cornerTop: false,
                    cornerBottom: true,
                    onTapItem: (value, title) {
                      setState(() {
                        IpilLaborSkills itemSelected = laborSkillsOptions.firstWhere((element) => element.label == title);
                        if (value) {
                          userLaborSkills.add(itemSelected.ipilLaborSkillsId!);
                        } else {
                          userLaborSkills.removeWhere((element) => element == itemSelected.ipilLaborSkillsId);
                        }
                        laborSkills = userLaborSkills;
                      });
                    },
                  );
                } else {
                  return Container(); // Placeholder for loading state
                }
              },
            ),
            SizedBox(
              height: Sizes.kDefaultPaddingDouble / 2,
            ),
            StreamBuilder<List<IpilContextualization>>(
                stream: database.ipilContextualizationStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData){
                    List<IpilContextualization> contextualizationOptions =  snapshot.data!;
                    List<DropdownItem> contextualizationOptionsDropdown = [];
                    contextualizationOptions.forEach((element) {
                      contextualizationOptionsDropdown.add(DropdownItem(title:
                      element.label,
                          isSelected: userContextualization.contains(element.ipilContextualizationId)));
                    });
                    return CheckboxDropdown(
                      title: StringConst.IPIL_CONTEXTUALIZATION,
                      options: contextualizationOptionsDropdown,
                      onTapItem: (value, title){
                        setState(() {
                          IpilContextualization itemSelected = contextualizationOptions.firstWhere((element) => element.label == title);
                          if(value){
                            userContextualization.add(itemSelected.ipilContextualizationId!);
                          }
                          else{
                            userContextualization.removeWhere((element) => element == itemSelected.ipilContextualizationId);
                          }
                          contextualization = userContextualization;
                        });
                      },
                    );
                  }
                  else{
                    return Container();
                  }
                }
            ),
            StreamBuilder<List<IpilConnectionTerritory>>(
              stream: database.ipilConnectionTerritoryStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<IpilConnectionTerritory> connectionTerritoryOptions = snapshot.data!;
                  List<DropdownItem> connectionTerritoryOptionsDropdown = [];
                  for (var element in connectionTerritoryOptions) {
                    connectionTerritoryOptionsDropdown.add(DropdownItem(
                      title: element.label,
                      isSelected: userConnectionTerritory.contains(element.ipilConnectionTerritoryId),
                    ));
                  }
                  return CheckboxDropdown(
                    title: StringConst.IPIL_CONNECTION_TERRITORY,
                    options: connectionTerritoryOptionsDropdown,
                    onTapItem: (value, title) {
                      setState(() {
                        IpilConnectionTerritory itemSelected = connectionTerritoryOptions.firstWhere((element) => element.label == title);
                        if (value) {
                          userConnectionTerritory.add(itemSelected.ipilConnectionTerritoryId!);
                        } else {
                          userConnectionTerritory.removeWhere((element) => element == itemSelected.ipilConnectionTerritoryId);
                        }
                        connectionTerritory = userConnectionTerritory;
                      });
                    },
                  );
                } else {
                  return Container(); // Placeholder for loading state
                }
              },
            ),
            StreamBuilder<List<IpilIntermediations>>(
              stream: database.ipilIntermediationsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<IpilIntermediations> intermediationsOptions = snapshot.data!;
                  List<DropdownItem> intermediationsOptionsDropdown = [];
                  for (var element in intermediationsOptions) {
                    intermediationsOptionsDropdown.add(DropdownItem(
                      title: element.label,
                      isSelected: userIntermediations.contains(element.ipilIntermediationsId),
                    ));
                  }
                  return CheckboxDropdown(
                    title: StringConst.IPIL_INTERMEDIATIONS,
                    options: intermediationsOptionsDropdown,
                    onTapItem: (value, title) {
                      setState(() {
                        IpilIntermediations itemSelected = intermediationsOptions.firstWhere((element) => element.label == title);
                        if (value) {
                          userIntermediations.add(itemSelected.ipilIntermediationsId!);
                        } else {
                          userIntermediations.removeWhere((element) => element == itemSelected.ipilIntermediationsId);
                        }
                        intermediations = userIntermediations;
                      });
                    },
                  );
                } else {
                  return Container(); // Placeholder for loading state
                }
              },
            ),
            StreamBuilder<List<IpilInterviews>>(
              stream: database.ipilInterviewsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<IpilInterviews> interviewsOptions = snapshot.data!;
                  List<DropdownItem> interviewsOptionsDropdown = [];
                  for (var element in interviewsOptions) {
                    interviewsOptionsDropdown.add(DropdownItem(
                      title: element.label,
                      isSelected: userInterviews.contains(element.ipilInterviewsId),
                    ));
                  }
                  return CheckboxDropdown(
                    title: StringConst.IPIL_INTERVIEWS,
                    options: interviewsOptionsDropdown,
                    onTapItem: (value, title) {
                      setState(() {
                        IpilInterviews itemSelected = interviewsOptions.firstWhere((element) => element.label == title);
                        if (value) {
                          userInterviews.add(itemSelected.ipilInterviewsId!);
                        } else {
                          userInterviews.removeWhere((element) => element == itemSelected.ipilInterviewsId);
                        }
                        interviews = userInterviews;
                      });
                    },
                  );
                } else {
                  return Container(); // Placeholder for loading state
                }
              },
            ),
            StreamBuilder<List<IpilObtainingEmployment>>(
              stream: database.ipilObtainingEmploymentStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<IpilObtainingEmployment> obtainingEmploymentOptions = snapshot.data!;
                  List<DropdownItem> obtainingEmploymentOptionsDropdown = [];
                  for (var element in obtainingEmploymentOptions) {
                    obtainingEmploymentOptionsDropdown.add(DropdownItem(
                      title: element.label,
                      isSelected: userObtainingEmployment.contains(element.ipilObtainingEmploymentId),
                    ));
                  }
                  return CheckboxDropdown(
                    title: StringConst.IPIL_OBTAINING_EMPLOYMENT,
                    options: obtainingEmploymentOptionsDropdown,
                    onTapItem: (value, title) {
                      setState(() {
                        IpilObtainingEmployment itemSelected = obtainingEmploymentOptions.firstWhere((element) => element.label == title);
                        if (value) {
                          userObtainingEmployment.add(itemSelected.ipilObtainingEmploymentId!);
                        } else {
                          userObtainingEmployment.removeWhere((element) => element == itemSelected.ipilObtainingEmploymentId);
                        }
                        obtainingEmployment = userObtainingEmployment;
                      });
                    },
                  );
                } else {
                  return Container(); // Placeholder for loading state
                }
              },
            ),
            StreamBuilder<List<IpilImprovingEmployment>>(
              stream: database.ipilImprovingEmploymentStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<IpilImprovingEmployment> improvingEmploymentOptions = snapshot.data!;
                  List<DropdownItem> improvingEmploymentOptionsDropdown = [];
                  for (var element in improvingEmploymentOptions) {
                    improvingEmploymentOptionsDropdown.add(DropdownItem(
                      title: element.label,
                      isSelected: userImprovingEmployment.contains(element.ipilImprovingEmploymentId),
                    ));
                  }
                  return CheckboxDropdown(
                    title: StringConst.IPIL_IMPROVING_EMPLOYMENT,
                    options: improvingEmploymentOptionsDropdown,
                    onTapItem: (value, title) {
                      setState(() {
                        IpilImprovingEmployment itemSelected = improvingEmploymentOptions.firstWhere((element) => element.label == title);
                        if (value) {
                          userImprovingEmployment.add(itemSelected.ipilImprovingEmploymentId!);
                        } else {
                          userImprovingEmployment.removeWhere((element) => element == itemSelected.ipilImprovingEmploymentId);
                        }
                        improvingEmployment = userImprovingEmployment;
                      });
                    },
                  );
                } else {
                  return Container(); // Placeholder for loading state
                }
              },
            ),
            StreamBuilder<List<IpilCoordination>>(
              stream: database.ipilCoordinationStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<IpilCoordination> coordinationOptions = snapshot.data!;
                  List<DropdownItem> coordinationOptionsDropdown = [];
                  for (var element in coordinationOptions) {
                    coordinationOptionsDropdown.add(DropdownItem(
                      title: element.label,
                      isSelected: userCoordination.contains(element.ipilCoordinationId),
                    ));
                  }
                  return CheckboxDropdown(
                    title: StringConst.IPIL_COORDINATION,
                    options: coordinationOptionsDropdown,
                    onTapItem: (value, title) {
                      setState(() {
                        IpilCoordination itemSelected = coordinationOptions.firstWhere((element) => element.label == title);
                        if (value) {
                          userCoordination.add(itemSelected.ipilCoordinationId!);
                        } else {
                          userCoordination.removeWhere((element) => element == itemSelected.ipilCoordinationId);
                        }
                        coordination = userCoordination;
                      });
                    },
                  );
                } else {
                  return Container(); // Placeholder for loading state
                }
              },
            ),
            StreamBuilder<List<IpilLegal>>(
              stream: database.ipilLegalStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<IpilLegal> legalOptions = snapshot.data!;
                  List<DropdownItem> legalOptionsDropdown = [];
                  for (var element in legalOptions) {
                    legalOptionsDropdown.add(DropdownItem(
                      title: element.label,
                      isSelected: userLegal.contains(element.ipilLegalId),
                    ));
                  }
                  return CheckboxDropdown(
                    title: StringConst.IPIL_LEGAL,
                    options: legalOptionsDropdown,
                    onTapItem: (value, title) {
                      setState(() {
                        IpilLegal itemSelected = legalOptions.firstWhere((element) => element.label == title);
                        if (value) {
                          userLegal.add(itemSelected.ipilLegalId!);
                        } else {
                          userLegal.removeWhere((element) => element == itemSelected.ipilLegalId);
                        }
                        legal = userLegal;
                      });
                    },
                  );
                } else {
                  return Container(); // Placeholder for loading state
                }
              },
            ),
            StreamBuilder<List<IpilPostWorkSupport>>(
              stream: database.ipilPostWorkSupportStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<IpilPostWorkSupport> postWorkSupportOptions = snapshot.data!;
                  List<DropdownItem> postWorkSupportOptionsDropdown = [];
                  for (var element in postWorkSupportOptions) {
                    postWorkSupportOptionsDropdown.add(DropdownItem(
                      title: element.label,
                      isSelected: userPostWorkSupport.contains(element.ipilPostWorkSupportId),
                    ));
                  }
                  return CheckboxDropdown(
                    title: StringConst.IPIL_POST_WORK_SUPPORT,
                    options: postWorkSupportOptionsDropdown,
                    onTapItem: (value, title) {
                      setState(() {
                        IpilPostWorkSupport itemSelected = postWorkSupportOptions.firstWhere((element) => element.label == title);
                        if (value) {
                          userPostWorkSupport.add(itemSelected.ipilPostWorkSupportId!);
                        } else {
                          userPostWorkSupport.removeWhere((element) => element == itemSelected.ipilPostWorkSupportId);
                        }
                        postWorkSupport = userPostWorkSupport;
                      });
                    },
                  );
                } else {
                  return Container(); // Placeholder for loading state
                }
              },
            ),
            StreamBuilder<List<IpilEconomicBag>>(
              stream: database.ipilEconomicBagStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<IpilEconomicBag> economicBagOptions = snapshot.data!;
                  List<DropdownItem> economicBagOptionsDropdown = [];
                  for (var element in economicBagOptions) {
                    economicBagOptionsDropdown.add(DropdownItem(
                      title: element.label,
                      isSelected: userEconomicBag.contains(element.ipilEconomicBagId),
                    ));
                  }
                  return CheckboxDropdown(
                    title: StringConst.IPIL_ECONOMIC_BAG,
                    options: economicBagOptionsDropdown,
                    onTapItem: (value, title) {
                      setState(() {
                        IpilEconomicBag itemSelected = economicBagOptions.firstWhere((element) => element.label == title);
                        if (value) {
                          userEconomicBag.add(itemSelected.ipilEconomicBagId!);
                        } else {
                          userEconomicBag.removeWhere((element) => element == itemSelected.ipilEconomicBagId);
                        }
                        economicBag = userEconomicBag;
                      });
                    },
                  );
                } else {
                  return Container(); // Placeholder for loading state
                }
              },
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
    }
    if (_validateAndSaveForm()) {
      print("validado");
      _formKey.currentState!.save();
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
            other: other
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
            other: other
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
