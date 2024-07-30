import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/participants/pdf_generator/ipils_print/pdf_ipil_preview.dart';
import 'package:enreda_empresas/app/models/ipilEntry.dart';
import 'package:enreda_empresas/app/models/ipilObjectives.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common_widgets/alert_dialog.dart';
import '../../../../common_widgets/empty-list.dart';
import '../../../../common_widgets/enreda_button.dart';
import '../../../resources/list_item_builder.dart';
import 'create_ipil_form.dart';
import 'expandable_ipil.dart';

class ParticipantIPILPage extends StatefulWidget {
  ParticipantIPILPage({required this.participantUser, super.key});
  static ValueNotifier<int> selectedIndexIpils = ValueNotifier(0);
  final UserEnreda participantUser;

  @override
  State<ParticipantIPILPage> createState() => _ParticipantIPILPageState();
}

class _ParticipantIPILPageState extends State<ParticipantIPILPage> {
  String? techNameComplete;
  List<String> _menuOptions = [
    "Seguimiento", "Objetivos"];
  String? _value;
  var bodyWidget = <Widget>[];

  @override
  void initState() {
    _value = _menuOptions[0];
    bodyWidget = [
      followPage(),
      objectivePage(),
      CreateIpilForm(participantUser: widget.participantUser),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: ParticipantIPILPage.selectedIndexIpils,
        builder: (context, selectedIndex, child) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.greyBorder)
            ),
            child: Column(
              children: [
                Padding(
                  padding: Responsive.isMobile(context) ? EdgeInsets.only(left: 20.0 , top: 10)
                      : EdgeInsets.only(left: 40, top: 15, bottom: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomTextBoldTitle(title: StringConst.IPIL),
                      Padding(
                        padding: Responsive.isMobile(context) ? EdgeInsets.symmetric(horizontal: 10.0) :
                        EdgeInsets.symmetric(horizontal: 40),
                        child: Row(
                          children:
                          List<Widget>.generate(
                            2,
                                (int index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 30),
                                child: ChoiceChip(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(25)),
                                      side: BorderSide(color: _value == _menuOptions[index] ?
                                      Colors.transparent : AppColors.violet)),
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
                                          ParticipantIPILPage.selectedIndexIpils.value = 0;
                                          break;
                                        case 1:
                                          ParticipantIPILPage.selectedIndexIpils.value = 1;
                                          break;
                                      }

                                    });
                                  },
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: AppColors.greyBorder,),
                //Save button
                SingleChildScrollView(
                  child: Container(
                      child: bodyWidget[selectedIndex]),
                )
              ],
            ),
          );
        }
    );

  }

  Widget followPage(){
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<List<IpilEntry>>(
        stream: database.getIpilEntriesByUserStream(widget.participantUser.userId!),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();
          if (snapshot.hasData) {
            List<IpilEntry> ipilEntries = snapshot.data!;
            return Column(
              children: [
                Padding(
                  padding: Responsive.isMobile(context) ? EdgeInsets.symmetric(horizontal: 8.0)
                      : EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: Row(
                    children: [
                      EnredaButtonIconSmall(
                        buttonTitle: StringConst.ADD_IPIL_ENTRY,
                        buttonColor: AppColors.greySearch,
                        titleColor: AppColors.primary900,
                        widget: Icon(
                          Icons.add_circle_outlined,
                          color: AppColors.turquoiseBlue,
                          size: 24,
                        ),
                        onPressed: () {
                          if(widget.participantUser.assignedById == null ||
                              widget.participantUser.assignedById == ''){
                            showAlertDialog(
                              context,
                              title: 'Aviso',
                              content: 'Este participante no tiene técnica asignada, para crear un IPIL asigne una técnica.',
                              defaultActionText: 'Aceptar',
                            );
                            return;
                          }
                          setState(() {
                            ParticipantIPILPage.selectedIndexIpils.value = 2;
                          });
                        },
                      ),
                      SizedBox(width: 20,),
                      EnredaButtonIconSmall(
                        buttonTitle: StringConst.DOWNLOAD_ALL,
                        buttonColor: AppColors.greySearch,
                        titleColor: AppColors.primary900,
                        widget: Image.asset(
                          ImagePath.DOWNLOAD_FILLED,
                          width: 24,
                          height: 24,
                        ),
                        onPressed: () async {
                          if(ipilEntries.isEmpty || ipilEntries.length == 0){
                            showAlertDialog(
                              context,
                              title: 'Aviso',
                              content: 'Este participante aún no tiene IPILs creados.',
                              defaultActionText: 'Aceptar',
                            );
                            return;
                          }
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
                  ),
                ),
                Divider(color: AppColors.greyBorder,),
                SpaceH8(),
                ipilEntries.isEmpty ? EmptyList(
                  title: 'No hay IPILs creados.',
                  imagePath: ImagePath.EMPTY_LiST_ICON,
                ) :
                listIpils(),
                SizedBox(height: 20),
              ],
            );
          } else {
            return Container();
          }
        }
    );
  }

  Widget listIpils(){
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<List<IpilEntry>>(
        stream: database.getIpilEntriesByUserStream(widget.participantUser.userId!),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();
          if (snapshot.hasData) {
            return ListItemBuilder<IpilEntry>(
              snapshot: snapshot,
              itemBuilder: (context, ipilEntry) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                return StreamBuilder<UserEnreda>(
                    stream: database.userEnredaStreamByUserId(ipilEntry.techId),
                    builder: (context, snapshot) {
                      if(snapshot.hasData){
                        String techName = snapshot.data?.firstName ?? '';
                        String techLastName = snapshot.data?.lastName ?? '';
                        techNameComplete = '$techName $techLastName';
                        return ExpandableIpilEntryTile(
                          ipilEntry: ipilEntry,
                          techNameComplete: techNameComplete!,
                          participantUser: widget.participantUser,
                        );
                      }
                      else{
                        return Container(
                        );
                      }
                    }
                );

              },
            );
          } else {
            return Container();
          }
        }
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
          SpaceH30(),
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
