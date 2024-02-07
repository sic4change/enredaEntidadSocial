import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_form_field_long.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/common_widgets/text_form_field.dart';
import 'package:enreda_empresas/app/home/participants/pdf_generator/pdf_ipil_preview.dart';
import 'package:enreda_empresas/app/models/ipilEntry.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/auth.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ParticipantIPILPage extends StatelessWidget {
  ParticipantIPILPage({required this.participantUser, super.key});

  final UserEnreda participantUser;
  String? techNameComplete;

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final auth = Provider.of<AuthBase>(context, listen: false);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.isDesktop(context)? 50.0: 20.0, vertical: 30),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.greyBorder)
        ),
        child: StreamBuilder<List<IpilEntry>>(
            stream: database.getIpilEntriesByUserStream(participantUser.userId!),
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
                return
                  Column(
                    //Provide unique key so that when flutter rebuilds the column, it is able to differentiate between the old posts and the new list of posts
                    key: Key(ipilEntriesKey.toString()),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomTextBoldTitle(title: StringConst.IPIL),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.add, color: Colors.black, size: 24,),
                                  onPressed: (){
                                    IpilEntry newIpilEntry = IpilEntry(
                                      date: DateTime.now(),
                                      userId: participantUser.userId!,
                                      techId: participantUser.assignedById,
                                    );
                                    database.addIpilEntry(newIpilEntry);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.download_for_offline_rounded, color: Colors.black, size: 24,),
                                  onPressed: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MyIpilEntries(
                                                user: participantUser,
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
                      Padding(
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
                                SpaceH12(),
                                Padding(
                                  padding: EdgeInsets.only(left:  Responsive.isDesktop(context)?50:30, right: 35, bottom: 30),
                                  child: Form(
                                    key: contentKeys[ipilEntries.indexOf(ipilEntry)],
                                    child: CustomTextFormFieldLong(
                                      labelText: StringConst.GOALS_MONITORING,
                                      hintText: StringConst.START_HERE,
                                      initialValue: ipilEntry.content,
                                      validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
                                      enabled: auth.currentUser!.uid == ipilEntry.techId,
                                      onSaved: (content) async{
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
              }else{
                return Container();
              }
            }
        ),
      ),
    );
  }
}
