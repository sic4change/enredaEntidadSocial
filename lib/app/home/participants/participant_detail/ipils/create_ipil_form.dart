import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_form_field_long.dart';
import 'package:enreda_empresas/app/common_widgets/flex_row_column.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/ipils/participant_ipil_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enreda_empresas/app/values/strings.dart';

import '../../../../common_widgets/alert_dialog.dart';
import '../../../../common_widgets/custom_date_picker_title.dart';
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
import '../../../../services/auth.dart';
import '../../../../services/database.dart';
import '../../../../utils/responsive.dart';
import '../../../../values/values.dart';

class CreateIpilForm extends StatefulWidget {
  const CreateIpilForm({super.key, required this.participantUser});
  final UserEnreda participantUser;

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
  String? content;

  @override
  void dispose() {
    textEditingControllerDateInput.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    reinforcement = [];
    contextualization = [];
    connectionTerritory = [];
    interviews = [];
    content = '';
  }

  @override
  Widget build(BuildContext context) {
    return createIpilForm();
  }

  Widget createIpilForm(){
    final database = Provider.of<Database>(context, listen: false);
    final auth = Provider.of<AuthBase>(context, listen: false);
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
          children: [
            CustomTextMediumBold(text: 'Crear nuevo IPIL'),
            const SizedBox(height: 20),
            CustomFlexRowColumn(
              childRight: StreamBuilder<UserEnreda>(
                  stream: database
                      .userEnredaStreamByUserId(widget.participantUser.userId!),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      String techId = snapshot.data?.assignedById ?? '';
                      return StreamBuilder<UserEnreda>(
                          stream: database.userEnredaStreamByUserId(techId),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              String techName = snapshot.data?.firstName ?? '';
                              String techLastName = snapshot.data?.lastName ?? '';
                              return Column(
                                children: [
                                  CustomTextFormFieldTitle(
                                    labelText: StringConst.TECHNICAL_NAME,
                                    height: 45,
                                    initialValue: '$techName $techLastName',
                                    enabled: false,
                                    color: AppColors.primary900,
                                  ),
                                ],
                              );
                            } else {
                              return Container();
                            }
                          });
                    } else {
                      return Container();
                    }
                  }),
              childLeft: CustomDatePickerTitle(
                labelText: StringConst.DATE,
                enabled: false,
                color: AppColors.primary900,
                initialValue: DateTime.now(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble / 2),
              child: CustomTextFormFieldLong(
                labelText: StringConst.GOALS_MONITORING,
                hintText: 'Por favor, utiliza este espacio para documentar los detalles de la entrevista. Incluye las impresiones generales, avances del participante, y una descripción de los eventos y cambios ocurridos desde la última entrevista. Anota también cualquier objetivo o plan de acción acordado para las próximas semanas.',
                initialValue: content,
                validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
                enabled: true,
                onSaved: (value) async{
                  content = value;
                },
              ),
            ),
            StreamBuilder<List<IpilReinforcement>>(
                stream: database.ipilReinforcementStream(),
                builder: (context, snapshot) {
                  List<String> userReinforcement = [];
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
                        reinforcement = userReinforcement;
                      },
                    );
                  }
                  else{
                    return Container();
                  }
                }
            ),
            StreamBuilder<List<IpilContextualization>>(
                stream: database.ipilContextualizationStream(),
                builder: (context, snapshot) {
                  List<String> userContextualization = [];
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
                        contextualization = userContextualization;
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
                  List<String> userConnectionTerritory = [];
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
                        connectionTerritory = userConnectionTerritory;
                      },
                    );
                  }
                  else{
                    return Container();
                  }

                }
            ),
            StreamBuilder<List<IpilInterviews>>(
                stream: database.ipilInterviewsStream(),
                builder: (context, snapshot) {
                  List<String> userInterviews = [];
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
                        interviews = userInterviews;
                      },
                    );
                  }
                  else{
                    return Container();
                  }
                }
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    EnredaButton(
                      buttonTitle: 'Cancelar',
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
                      buttonTitle: 'Guardar',
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

  Future<void> _submit() async {

    if (_validateAndSaveForm() == false) {
      await showAlertDialog(context,
          title: StringConst.FORM_ENTITY_ERROR,
          content: StringConst.FORM_ENTITY_CHECK,
          defaultActionText: StringConst.CLOSE);
    }

    if (_validateAndSaveForm()) {
      _formKey.currentState!.save();
      IpilEntry newIpilEntry = IpilEntry(
        date: DateTime.now(),
        userId: widget.participantUser.userId!,
        techId: widget.participantUser.assignedById,
        content: content,
        interviews: interviews,
        connectionTerritory: connectionTerritory,
        contextualization: contextualization,
        reinforcement: reinforcement,
      );

      try {
        final database = Provider.of<Database>(context, listen: false);
        await database.addIpilEntry(newIpilEntry);
        await showAlertDialog(
          context,
          title: StringConst.CREATE_IPIL,
          content: StringConst.CREATE_IPIL_SUCCESS,
          defaultActionText: StringConst.FORM_ACCEPT,
        );
        ParticipantIPILPage.selectedIndexIpils.value = 0;
      } on FirebaseException catch (e) {
        showExceptionAlertDialog(context,
            title: StringConst.FORM_ERROR, exception: e).then((value) => Navigator.pop(context));
      }

    }
  }


  bool _validateAndSaveForm() {
    if (_formKey.currentState != null &&
        _formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      return true;
    }
    return false;
  }
}
