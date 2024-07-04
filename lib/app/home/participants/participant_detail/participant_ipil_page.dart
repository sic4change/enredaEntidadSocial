import 'package:enreda_empresas/app/common_widgets/custom_multi_selection_radio_list.dart';
import 'package:enreda_empresas/app/common_widgets/custom_multi_selection_radio_list_title.dart';
import 'package:enreda_empresas/app/common_widgets/custom_radio_list_title.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_form_field_long.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/common_widgets/text_form_field.dart';
import 'package:enreda_empresas/app/home/participants/pdf_generator/pdf_ipil_preview.dart';
import 'package:enreda_empresas/app/models/ipilConnectionTerritory.dart';
import 'package:enreda_empresas/app/models/ipilContextualization.dart';
import 'package:enreda_empresas/app/models/ipilEntry.dart';
import 'package:enreda_empresas/app/models/ipilInterviews.dart';
import 'package:enreda_empresas/app/models/ipilObjectives.dart';
import 'package:enreda_empresas/app/models/ipilReinforcement.dart';
import 'package:enreda_empresas/app/models/ipilResults.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/auth.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../common_widgets/custom_drop_down_button_form_field_title_check.dart';

class ParticipantIPILPage extends StatefulWidget {
  ParticipantIPILPage({required this.participantUser, super.key});

  final UserEnreda participantUser;

  @override
  State<ParticipantIPILPage> createState() => _ParticipantIPILPageState();
}

class _ParticipantIPILPageState extends State<ParticipantIPILPage> {
  String? techNameComplete;
  List<String> _menuOptions = [
    "Seguimiento", "Objetivos"];
  Widget? _currentPage;
  String? _value;

  @override
  void initState() {
    _value = _menuOptions[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.isDesktop(context)? 50.0: 20.0, vertical: 30),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.greyBorder)
        ),
        child: StreamBuilder<List<IpilEntry>>(
            stream: database.getIpilEntriesByUserStream(widget.participantUser.userId!),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();
              if (snapshot.hasData) {
                List<IpilEntry> ipilEntries = snapshot.data!;
                List<GlobalKey<FormState>> contentKeys = [];
                List<GlobalKey<FormState>> dateKeys = [];
                //Create unique key based on ipilEntries timestamps
                double ipilEntriesKey = 0;
                ipilEntries.forEach((element) {
                  ipilEntriesKey += element.date.millisecondsSinceEpoch;
                  contentKeys.add(GlobalKey<FormState>());
                  dateKeys.add(GlobalKey<FormState>());
                });
                if(_currentPage == null){
                  _currentPage = followPage(ipilEntries, contentKeys, dateKeys);
                }
                return
                  Column(
                    //Provide unique key so that when flutter rebuilds the column, it is able to differentiate between the old posts and the new list of posts
                    key: Key(ipilEntriesKey.toString()),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                            child: CustomTextBoldTitle(title: StringConst.IPIL)
                        ),
                      ),
                      Divider(color: AppColors.greyBorder,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children:
                              List<Widget>.generate(
                                2,
                                    (int index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 30),
                                    child: ChoiceChip(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(25)),
                                          side: BorderSide(color: _value == _menuOptions[index] ? Colors.transparent : AppColors.violet)),
                                      disabledColor: Colors.white,
                                      selectedColor: AppColors.turquoiseBlue,
                                      labelStyle: TextStyle(
                                        fontSize: Responsive.isMobile(context)? 12.0: 16.0,
                                        fontWeight: FontWeight.w400,
                                        color: _value == _menuOptions[index] ? AppColors.white : AppColors.greyTxtAlt,
                                      ),

                                      label: Text(_menuOptions[index]),
                                      selected: _value == _menuOptions[index],
                                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                      showCheckmark: false,
                                      onSelected: (bool selected) {
                                        setState(() {
                                          _value = _menuOptions[index];
                                          switch (index) {
                                            case 0:
                                              _currentPage = followPage(ipilEntries, contentKeys, dateKeys);
                                              break;
                                            case 1:
                                              _currentPage = objectivePage();
                                              break;
                                          }

                                        });
                                      },
                                    ),
                                  );
                                },
                              ).toList(),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.add_circle_outlined,
                                    color: AppColors.turquoiseBlue,
                                    size: 24,
                                  ),
                                  onPressed: (){
                                    IpilEntry newIpilEntry = IpilEntry(
                                      date: DateTime.now(),
                                      userId: widget.participantUser.userId!,
                                      techId: widget.participantUser.assignedById,
                                      results: [],
                                      interviews: [],
                                      connectionTerritory: [],
                                      contextualization: [],
                                      reinforcement: [],
                                    );
                                    database.addIpilEntry(newIpilEntry);
                                    setState(() {
                                      _currentPage = objectivePage();
                                    });
                                    setState(() {
                                      _currentPage = followPage(ipilEntries, contentKeys, dateKeys);
                                    });

                                  },
                                ),
                                IconButton(
                                  icon: Image.asset(
                                    ImagePath.PERSONAL_DOCUMENTATION_DOWNLOAD,
                                    width: 24,
                                    height: 24,
                                  ),
                                  onPressed: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MyIpilEntries(
                                                user: widget.participantUser,
                                                ipilEntries: ipilEntries,
                                                techName: techNameComplete!,
                                              )),
                                    );
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Divider(color: AppColors.greyBorder,),
                      //Save button
                      _currentPage!,
                    ],
                  );
              }else{
                return Container();
              }
            }
        ),
      ),
    );
  }

  Widget followPage(List<IpilEntry> ipilEntries, List<GlobalKey<FormState>> contentKeys, List<GlobalKey<FormState>> dateKeys){
    final database = Provider.of<Database>(context, listen: false);
    final auth = Provider.of<AuthBase>(context, listen: false);
    return Column(
      children: [
        ipilEntries.isEmpty ? Container() : Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Container(
            height: 50,
            width: 150,
            child: ElevatedButton(
                onPressed: () async {
                  bool emptyContent = false;
                  for(var key in contentKeys){
                    if(key.currentState!.validate()){
                      //key.currentState!.save();
                    }else{
                      emptyContent = true;
                    }
                  }
                  if(emptyContent){
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(StringConst.EMPTY_FORM_ERROR,
                            style: TextStyle(
                              color: AppColors.greyDark,
                              height: 1.5,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            )),
                        content: Text(StringConst.WANNA_REMOVE,
                            style: TextStyle(
                              color: AppColors.greyDark,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            )),
                        actions: <Widget>[
                          ElevatedButton(
                              onPressed: (){
                                Navigator.of(context).pop();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(StringConst.NO,
                                    style: TextStyle(
                                        color: AppColors.black,
                                        height: 1.5,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14)),
                              )),
                          ElevatedButton(
                              onPressed: (){
                                for(IpilEntry ipilEntry in ipilEntries){
                                  if(ipilEntry.content == null || ipilEntry.content == ''){
                                    database.deleteIpilEntry(ipilEntry);
                                  }
                                }
                                Navigator.of(context).pop();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(StringConst.YES,
                                    style: TextStyle(
                                        color: AppColors.red,
                                        height: 1.5,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14)),
                              )),
                        ],
                      ),
                    );
                  }else{
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                            title: Text(StringConst.SAVE_SUCCEED,
                                style: TextStyle(
                                  color: AppColors.greyDark,
                                  height: 1.5,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                )),
                            actions: <Widget>[
                              ElevatedButton(
                                  onPressed: (){
                                    for(int index = 0; index < contentKeys.length; index++){
                                      if(contentKeys[index].currentState!.validate()){
                                        contentKeys[index].currentState!.save();
                                      }
                                      if(dateKeys[index].currentState!.validate()){
                                        dateKeys[index].currentState!.save();
                                      }
                                      database.setIpilEntry(ipilEntries[index]);
                                    }
                                    Navigator.of(context).pop();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(StringConst.OK,
                                        style: TextStyle(
                                            color: AppColors.black,
                                            height: 1.5,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14)),
                                  )),
                            ]
                        )
                    );
                  }
                },
                child: Text(
                  StringConst.SAVE,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.turquoiseButton,
                  shadowColor: Colors.transparent,
                )
            ),
          ),
        ),
        Column(
            children: [
              SpaceH30(),
              for (var ipilEntry in ipilEntries)
                ipilEntry.ipilId != null ?  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (Responsive.isDesktop(context))
                      Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: Row(
                          children: [
                            //Date
                            Form(
                              key: dateKeys[ipilEntries.indexOf(ipilEntry)],
                              child: Padding(
                                padding: const EdgeInsets.only(right: 22),
                                child: Container(
                                  height: 85,
                                  width: 95,
                                  child: customDatePickerTitle(
                                    context,
                                    ipilEntry.date,
                                    StringConst.DATE, StringConst.DATE_ERROR,
                                        (date){
                                          ipilEntry.date = date;
                                          database.updateIpilEntryDate(ipilEntry, date);
                                    },
                                    auth.currentUser!.uid == ipilEntry.techId,
                                  ),
                                ),
                              ),
                            ),
                            //Tech name
                            StreamBuilder<UserEnreda>(
                                stream: database.userEnredaStreamByUserId(ipilEntry.techId),
                                builder: (context, snapshot) {
                                  if(snapshot.hasData){
                                    String techName = snapshot.data?.firstName ?? '';
                                    String techLastName = snapshot.data?.lastName ?? '';
                                    techNameComplete = '$techName $techLastName';
                                    return Container(
                                      height: 85,
                                      width: 220,
                                      child: Column(
                                        children: [
                                          CustomTextFormFieldTitle(
                                            labelText: StringConst.TECHNICAL_NAME,
                                            height: 45,
                                            initialValue: '$techName $techLastName',
                                            enabled: false,
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  else{
                                    return Container(

                                    );
                                  }
                                }
                            )
                          ],
                        ),
                      ),
                    if (!Responsive.isDesktop(context))
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Form(
                              key: dateKeys[ipilEntries.indexOf(ipilEntry)],
                              child: Padding(
                                padding: const EdgeInsets.only(right: 22),
                                child: Container(
                                  height: 85,
                                  width: 95,
                                  child: customDatePickerTitle(
                                    context,
                                    ipilEntry.date,
                                    StringConst.DATE, StringConst.DATE_ERROR,
                                        (date){
                                      ipilEntry.date = date;
                                      database.updateIpilEntryDate(ipilEntry, date);
                                    },
                                    auth.currentUser!.uid == ipilEntry.techId,
                                  ),
                                ),
                              ),
                            ),
                            StreamBuilder<UserEnreda>(
                                stream: database.userEnredaStreamByUserId(ipilEntry.techId),
                                builder: (context, snapshot) {
                                  if(snapshot.hasData){
                                    String techName = snapshot.data?.firstName ?? '';
                                    String techLastName = snapshot.data?.lastName ?? '';
                                    techNameComplete = '$techName $techLastName';
                                    return Container(
                                      height: 85,
                                      width: 220,
                                      child: Column(
                                        children: [
                                          CustomTextFormFieldTitle(
                                            labelText: StringConst.TECHNICAL_NAME,
                                            height: 45,
                                            initialValue: '$techName $techLastName',
                                            enabled: false,
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  else{
                                    return Container();
                                  }
                                })
                          ],
                        ),
                      ),
                    SpaceH16(),
                    Padding(
                        padding: EdgeInsets.only(left:  Responsive.isDesktop(context)?50:30, right: 35),
                        child: StreamBuilder<List<IpilReinforcement>>(
                          stream: database.ipilReinforcementStream(),
                          builder: (context, snapshot) {
                            List<String> userReinforcement = ipilEntry.reinforcement ?? [];
                            if (snapshot.hasData){
                              List<IpilReinforcement> reinforcementOptions =  snapshot.data!;
                              List<DropdownItem> reinforcementOptionsDropdown = [];
                              reinforcementOptions.forEach((element) {
                                reinforcementOptionsDropdown.add(DropdownItem(title:
                                  element.label,
                                  isSelected: userReinforcement.contains(element.ipilReinforcementId)));
                              });
                              return CheckboxDropdown(
                                title: "Fortalecimiento de las competencias",
                                options: reinforcementOptionsDropdown,
                                onTapItem: (value, title){
                                  IpilReinforcement itemSelected = reinforcementOptions.firstWhere((element) => element.label == title);
                                  if(value){
                                    userReinforcement.add(itemSelected.ipilReinforcementId!);
                                  }
                                  else{
                                    userReinforcement.removeWhere((element) => element == itemSelected.ipilReinforcementId);
                                  }
                                  print(userReinforcement);
                                  ipilEntry.reinforcement = userReinforcement;
                                },
                              );
                            }
                            else{
                              return Container();
                            }

                          }
                        )
                    ),
                    SpaceH16(),
                    Padding(
                        padding: EdgeInsets.only(left:  Responsive.isDesktop(context)?50:30, right: 35),
                        child: StreamBuilder<List<IpilContextualization>>(
                            stream: database.ipilContextualizationStream(),
                            builder: (context, snapshot) {
                              List<String> userContextualization = ipilEntry.contextualization ?? [];
                              if (snapshot.hasData){
                                List<IpilContextualization> contextualizationOptions =  snapshot.data!;
                                List<DropdownItem> contextualizationOptionsDropdown = [];
                                contextualizationOptions.forEach((element) {
                                  contextualizationOptionsDropdown.add(DropdownItem(title:
                                  element.label,
                                      isSelected: userContextualization.contains(element.ipilContextualizationId)));
                                });
                                return CheckboxDropdown(
                                  title: "Contextualización",
                                  options: contextualizationOptionsDropdown,
                                  onTapItem: (value, title){
                                    IpilContextualization itemSelected = contextualizationOptions.firstWhere((element) => element.label == title);
                                    if(value){
                                      userContextualization.add(itemSelected.ipilContextualizationId!);
                                    }
                                    else{
                                      userContextualization.removeWhere((element) => element == itemSelected.ipilContextualizationId);
                                    }
                                    ipilEntry.contextualization = userContextualization;
                                  },
                                );
                              }
                              else{
                                return Container();
                              }

                            }
                        )
                    ),
                    SpaceH16(),
                    Padding(
                        padding: EdgeInsets.only(left:  Responsive.isDesktop(context)?50:30, right: 35),
                        child: StreamBuilder<List<IpilConnectionTerritory>>(
                            stream: database.ipilConnectionTerritoryStream(),
                            builder: (context, snapshot) {
                              List<String> userConnectionTerritory = ipilEntry.connectionTerritory ?? [];
                              if (snapshot.hasData){
                                List<IpilConnectionTerritory> connectionTerritoryOptions =  snapshot.data!;
                                List<DropdownItem> connectionTerritoryOptionsDropdown = [];
                                connectionTerritoryOptions.forEach((element) {
                                  connectionTerritoryOptionsDropdown.add(DropdownItem(title:
                                  element.label,
                                      isSelected: userConnectionTerritory.contains(element.ipilConnectionTerritoryId)));
                                });
                                return CheckboxDropdown(
                                  title: "Conexión con el territorio",
                                  options: connectionTerritoryOptionsDropdown,
                                  onTapItem: (value, title){
                                    IpilConnectionTerritory itemSelected = connectionTerritoryOptions.firstWhere((element) => element.label == title);
                                    if(value){
                                      userConnectionTerritory.add(itemSelected.ipilConnectionTerritoryId!);
                                    }
                                    else{
                                      userConnectionTerritory.removeWhere((element) => element == itemSelected.ipilConnectionTerritoryId);
                                    }
                                    ipilEntry.connectionTerritory = userConnectionTerritory;
                                  },
                                );
                              }
                              else{
                                return Container();
                              }

                            }
                        )
                    ),
                    SpaceH16(),
                    Padding(
                        padding: EdgeInsets.only(left:  Responsive.isDesktop(context)?50:30, right: 35),
                        child: StreamBuilder<List<IpilInterviews>>(
                            stream: database.ipilInterviewsStream(),
                            builder: (context, snapshot) {
                              List<String> userInterviews = ipilEntry.interviews ?? [];
                              if (snapshot.hasData){
                                List<IpilInterviews> interviewsOptions =  snapshot.data!;
                                List<DropdownItem> interviewsOptionsDropdown = [];
                                interviewsOptions.forEach((element) {
                                  interviewsOptionsDropdown.add(DropdownItem(title:
                                  element.label,
                                      isSelected: userInterviews.contains(element.ipilInterviewsId)));
                                });
                                return CheckboxDropdown(
                                  title: "Entrevistas",
                                  options: interviewsOptionsDropdown,
                                  onTapItem: (value, title){
                                    IpilInterviews itemSelected = interviewsOptions.firstWhere((element) => element.label == title);
                                    if(value){
                                      userInterviews.add(itemSelected.ipilInterviewsId!);
                                    }
                                    else{
                                      userInterviews.removeWhere((element) => element == itemSelected.ipilInterviewsId);
                                    }
                                    ipilEntry.interviews = userInterviews;
                                  },
                                );
                              }
                              else{
                                return Container();
                              }

                            }
                        )
                    ),
                    SpaceH16(),
                    Padding(
                      padding: EdgeInsets.only(left:  Responsive.isDesktop(context)?50:30, right: 35),
                      child: StreamBuilder<List<IpilResults>>(
                        stream: database.ipilResultsStream(),
                        builder: (context, snapshot) {
                          List<String> userResults = ipilEntry.results ?? [];
                          if (snapshot.hasData) {
                            List<IpilResults> resultsOptions = snapshot.data!;
                            List<DropdownItem> resultsOptionsDropdown = [];
                            List<String> options = [];
                            List<String> selections = [];
                            resultsOptions.forEach((element) {
                              resultsOptionsDropdown.add(DropdownItem(
                                title: element.label,
                                isSelected: userResults.contains(
                                      element.ipilResultsId)));
                              options.add(element.label);
                              resultsOptionsDropdown.forEach((element) {
                                if(element.isSelected){
                                  selections.add(element.title);
                                }
                              });
                            });
                            return CustomMultiSelectionRadioListTitle(
                              title: 'Resultados',
                              options: options,
                              selections: selections,
                              enabled: true,
                              onTapItem: (option){
                                IpilResults itemSelected = resultsOptions.firstWhere((element) => element.label == option);
                                String itemSelectedId = itemSelected.ipilResultsId!;
                                if(selections.contains(option)){
                                  userResults.removeWhere((element) => element == itemSelectedId);
                                }else{
                                  userResults.add(itemSelectedId);
                                }
                                ipilEntry.results = userResults;
                              },
                            );
                          }
                          else{
                            return Container();
                          }
                        }
                      ),
                    ),
                    SpaceH16(),
                    Padding(
                      padding: EdgeInsets.only(left:  Responsive.isDesktop(context)?50:30, right: 35, bottom: 30),
                      child: Form(
                        key: contentKeys[ipilEntries.indexOf(ipilEntry)],
                        child: CustomTextFormFieldLong(
                          labelText: StringConst.GOALS_MONITORING,
                          hintText: 'Por favor, utiliza este espacio para documentar los detalles de la entrevista. Incluye las impresiones generales, avances del participante, y una descripción de los eventos y cambios ocurridos desde la última entrevista. Anota también cualquier objetivo o plan de acción acordado para las próximas semanas.',
                          initialValue: ipilEntry.content,
                          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
                          enabled: auth.currentUser!.uid == ipilEntry.techId,
                          onSaved: (content) async{
                            ipilEntry.content = content;
                            await database.updateIpilEntryContent(ipilEntry, content!);
                          },
                          onTapOutside: (content) async{
                            await database.updateIpilEntryContent(ipilEntry, content);
                          },
                          onFieldSubmitted: (content) async{
                            await database.updateIpilEntryContent(ipilEntry, content);
                          },
                        ),
                      ),
                    ),
                  ],
                ) :
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
            ]
        ),
      ],
    );
  }

  Widget objectivePageContent(IpilObjectives ipilObjectives){
    final database = Provider.of<Database>(context, listen: false);

    TextEditingController short1 = TextEditingController(text: ipilObjectives.monthShort1 ?? '');
    TextEditingController short2 = TextEditingController(text: ipilObjectives.monthShort2 ?? '');
    TextEditingController short3 = TextEditingController(text: ipilObjectives.monthShort3 ?? '');
    TextEditingController medium1 = TextEditingController(text: ipilObjectives.monthMedium1 ?? '');
    TextEditingController medium2 = TextEditingController(text: ipilObjectives.monthMedium2 ?? '');
    TextEditingController medium3 = TextEditingController(text: ipilObjectives.monthMedium3 ?? '');
    TextEditingController long1 = TextEditingController(text: ipilObjectives.monthLong1 ?? '');
    TextEditingController long2 = TextEditingController(text: ipilObjectives.monthLong2 ?? '');
    TextEditingController long3 = TextEditingController(text: ipilObjectives.monthLong3 ?? '');


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 40),
      child: Column(
        children: [
          Container(
            height: 50,
            width: 150,
            child: ElevatedButton(
                onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                            title: Text(StringConst.SAVE_SUCCEED,
                                style: TextStyle(
                                  color: AppColors.greyDark,
                                  height: 1.5,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                )),
                            actions: <Widget>[
                              ElevatedButton(
                                  onPressed: (){
                                    database.setIpilObjectives(IpilObjectives(
                                      ipilObjectivesId: ipilObjectives.ipilObjectivesId,
                                      userId: ipilObjectives.userId,
                                      monthShort1: short1.text,
                                      monthShort2: short2.text,
                                      monthShort3: short3.text,
                                      monthMedium1: medium1.text,
                                      monthMedium2: medium2.text,
                                      monthMedium3: medium3.text,
                                      monthLong1: long1.text,
                                      monthLong2: long2.text,
                                      monthLong3: long3.text,
                                    ));
                                    Navigator.of(context).pop();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(StringConst.OK,
                                        style: TextStyle(
                                            color: AppColors.black,
                                            height: 1.5,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14)),
                                  )),
                            ]
                        )
                    );
                  },
                child: Text(
                  StringConst.SAVE,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.turquoiseButton,
                  shadowColor: Colors.transparent,
                )
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleObjectives('Revisión de objetivos de 1-3 meses '),
              SpaceH16(),
              CustomTextFormFieldTitle(
                labelText: 'Corto plazo',
                hintText: 'Detalla los objetivos, metas, aspiraciones del participante.',
                controller: short1,
              ),
              SpaceH16(),
              CustomTextFormFieldTitle(
                labelText: 'Medio plazo',
                hintText: 'Detalla los objetivos, metas, aspiraciones del participante.',
                controller: medium1,
              ),
              SpaceH16(),
              CustomTextFormFieldTitle(
                labelText: 'Largo plazo',
                hintText: 'Detalla los objetivos, metas, aspiraciones del participante.',
                controller: long1,
              ),

              SpaceH50(),
              titleObjectives('Revisión de objetivos de 3-6 meses '),
              SpaceH16(),
              CustomTextFormFieldTitle(
                labelText: 'Corto plazo',
                hintText: 'Detalla los objetivos, metas, aspiraciones del participante.',
                controller: short2,
              ),
              SpaceH16(),
              CustomTextFormFieldTitle(
                labelText: 'Medio plazo',
                hintText: 'Detalla los objetivos, metas, aspiraciones del participante.',
                controller: medium2,
              ),
              SpaceH16(),
              CustomTextFormFieldTitle(
                labelText: 'Largo plazo',
                hintText: 'Detalla los objetivos, metas, aspiraciones del participante.',
                controller: long2,
              ),


              SpaceH50(),
              titleObjectives('Revisión de objetivos de 6-12 meses '),
              SpaceH16(),
              CustomTextFormFieldTitle(
                labelText: 'Corto plazo',
                hintText: 'Detalla los objetivos, metas, aspiraciones del participante.',
                controller: short3,
              ),
              SpaceH16(),
              CustomTextFormFieldTitle(
                labelText: 'Medio plazo',
                hintText: 'Detalla los objetivos, metas, aspiraciones del participante.',
                controller: medium3,
              ),
              SpaceH16(),
              CustomTextFormFieldTitle(
                labelText: 'Largo plazo',
                hintText: 'Detalla los objetivos, metas, aspiraciones del participante.',
                controller: long3,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget objectivePage(){
    final database = Provider.of<Database>(context, listen: false);

    return StreamBuilder<IpilObjectives>(
        stream: database.ipilObjectivesStreamByUserId(widget.participantUser.userId!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            IpilObjectives ipilObjectivesSaved = snapshot.data!;
            return objectivePageContent(ipilObjectivesSaved);
          }
          else {
            if (widget.participantUser.ipilObjectivesId == null && snapshot.connectionState != ConnectionState.waiting) {
              IpilObjectives ipilObjectivesNew = IpilObjectives(userId: widget.participantUser.userId);
              database.addIpilObjectives(ipilObjectivesNew);
            }
            return Container(
              height: 300,
            );
          }
        }
    );
  }

  Widget titleObjectives(String title){
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 18,
        color: AppColors.turquoiseBlue,

      ),
    );
  }


}
