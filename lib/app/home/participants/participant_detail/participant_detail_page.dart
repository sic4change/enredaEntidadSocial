import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:enreda_empresas/app/common_widgets/add_yellow_button.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_form_field_long.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/enreda_button.dart';
import 'package:enreda_empresas/app/common_widgets/gamification_item.dart';
import 'package:enreda_empresas/app/common_widgets/gamification_slider.dart';
import 'package:enreda_empresas/app/common_widgets/rounded_container.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/common_widgets/text_form_field.dart';
import 'package:enreda_empresas/app/home/participants/my_cv_page.dart';
import 'package:enreda_empresas/app/home/participants/pdf_generator/pdf_ipil_preview.dart';
import 'package:enreda_empresas/app/home/participants/resources_participants.dart';
import 'package:enreda_empresas/app/home/participants/show_invitation_diaglog.dart';
import 'package:enreda_empresas/app/models/ability.dart';
import 'package:enreda_empresas/app/models/city.dart';
import 'package:enreda_empresas/app/models/competency.dart';
import 'package:enreda_empresas/app/models/country.dart';
import 'package:enreda_empresas/app/models/gamificationFlags.dart';
import 'package:enreda_empresas/app/models/interest.dart';
import 'package:enreda_empresas/app/models/ipilEntry.dart';
import 'package:enreda_empresas/app/models/province.dart';
import 'package:enreda_empresas/app/models/specificinterest.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/auth.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ParticipantDetailPage extends StatefulWidget {
  const ParticipantDetailPage({
    super.key,
    required this.user,
    required this.socialEntityUser,
    this.onBack,
  });

  final UserEnreda user;
  final UserEnreda socialEntityUser;
  final VoidCallback? onBack;

  @override
  State<ParticipantDetailPage> createState() => _ParticipantDetailPageState();
}

class _ParticipantDetailPageState extends State<ParticipantDetailPage> {
  List<String> _menuOptions = ['Panel de control', 'Informes sociales', 'IPIL', 'Documentación personal', 'Cuestionarios'];
  Widget? _currentPage;
  String? _value;

  @override
  void initState() {
    _value = _menuOptions[0];
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    if (_currentPage == null) {
      _currentPage =  _buildControlPanel(context, widget.user);
    }

    return Responsive.isMobile(context) || Responsive.isTablet(context)?
      _buildParticipantProfileMobile(context, widget.user)
        :_buildParticipantWeb(context, widget.user);
  }

  Widget _buildParticipantWeb(BuildContext context, UserEnreda user){
    return SingleChildScrollView(
      controller: ScrollController(),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: _buildHeader(context, user),
            height: 220,
          ),
          Divider(
            indent: 0,
            endIndent: 0,
            color: AppColors.greyBorder,
            thickness: 1,
            height: 1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 22.0),
            child: _buildMenuSelectorChips(context, user),
          ),
          Divider(
            indent: 0,
            endIndent: 0,
            color: AppColors.greyBorder,
            thickness: 1,
            height: 0,
          ),
          SpaceH24(),

          _currentPage!,
        ],
      ),
    );
  }

  Widget _buildMenuSelectorChips(BuildContext context, UserEnreda user){
    return Wrap(
      spacing: 5.0,
      children: List<Widget>.generate(
        5,
            (int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: ChoiceChip(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  side: BorderSide(color: _value == _menuOptions[index] ? Colors.transparent : AppColors.violet)),
              disabledColor: Colors.white,
              selectedColor: AppColors.yellow,
              labelStyle: TextStyle(
                fontSize: 16,
                fontWeight: _value == _menuOptions[index] ? FontWeight.w700 : FontWeight.w400,
                color: _value == _menuOptions[index] ? AppColors.turquoiseBlue : AppColors.greyTxtAlt,

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
                      _currentPage = _buildControlPanel(context, user);
                      break;
                    case 1:
                      _currentPage = _IPILPage(context, user);
                      break;
                    case 2:
                      _currentPage = _IPILPage(context, user);
                      break;
                    case 3:
                      _currentPage = _IPILPage(context, user);
                      break;
                    case 4:
                      _currentPage = _IPILPage(context, user);
                      break;
                  }
                });
              },
            ),
          );
        },
      ).toList(),
    );
  }

  Widget _IPILPage(BuildContext context, UserEnreda user){
    final database = Provider.of<Database>(context, listen: false);
    final auth = Provider.of<AuthBase>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.greyBorder)
        ),
        child: StreamBuilder<List<IpilEntry>>(
          stream: database.getIpilEntriesByUserStream(user.userId!),
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
                        Text(
                          'IPIL',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.bluePetrol,
                            fontSize: 35,
                            fontFamily: GoogleFonts.outfit().fontFamily,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.add, color: Colors.black, size: 24,),
                              onPressed: (){
                                IpilEntry newIpilEntry = IpilEntry(
                                  date: DateTime.now(),
                                  userId: user.userId!,
                                  techId: user.assignedById,
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
                                            user: widget.user,
                                            ipilEntries: ipilEntries,
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
                                  title: Text('Tiene varios campos vacios',
                                      style: TextStyle(
                                        color: AppColors.greyDark,
                                        height: 1.5,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      )),
                                  content: Text('¿Desea borrarlos?',
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
                                          child: Text('No',
                                              style: TextStyle(
                                                  color: AppColors.black,
                                                  height: 1.5,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14)),
                                        )),
                                    ElevatedButton(
                                        onPressed: (){
                                          for(IpilEntry ipilEntry in ipilEntries){
                                            if(ipilEntry.content == null){
                                              database.deleteIpilEntry(ipilEntry);
                                            }
                                          }
                                          Navigator.of(context).pop();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('Si',
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
                                    title: Text('Se ha guardado con exito',
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
                                          child: Text('Ok',
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
                            'Guardar',
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
                    children: <Widget>[for (var ipilEntry in ipilEntries)
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 50, top: 30),
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
                                          'Fecha', 'Fecha no valida',
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
                                        return Container(
                                          height: 85,
                                          width: 220,
                                          child: Column(
                                            children: [
                                              CustomTextFormFieldTitle(
                                                labelText: 'Nombre de la técnica',
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
                          SpaceH12(),
                          Padding(
                            padding: const EdgeInsets.only(left: 50, right: 35, bottom: 30),
                            child: Form(
                              key: contentKeys[ipilEntries.indexOf(ipilEntry)],
                              child: CustomTextFormFieldLong(
                                labelText: 'Objetivos y seguimiento:',
                                hintText: 'Comienza aquí...',
                                initialValue: ipilEntry.content,
                                validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
                                enabled: auth.currentUser!.uid == ipilEntry.techId,
                                onSaved: (content) async{
                                  await database.updateIpilEntryContent(ipilEntry, content!);
                                },
                              ),
                            ),
                          ),
                        ],
                      )
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

  Widget _buildControlPanel(BuildContext context, UserEnreda user){
    final database = Provider.of<Database>(context, listen: false);
    final auth = Provider.of<AuthBase>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;

    final totalGamificationPills = 5;
    final cvTotalSteps = 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextBoldTitle(title: StringConst.GAMIFICATION),
          SpaceH8(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(ImagePath.GAMIFICATION_LOGO, height: 160.0,),
              SpaceW8(),
              Expanded(
                child: Column(
                  children: [
                    GamificationSlider(
                      height: 20.0,
                      value: widget.user.gamificationFlags.length,
                    ),
                    SpaceH20(),
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 12.0,
                            runSpacing: 12.0,
                            alignment: WrapAlignment.spaceEvenly,
                            children: [
                              GamificationItem(
                                imagePath: ImagePath.GAMIFICATION_CHAT_ICON,
                                progress: (widget.user.gamificationFlags[UserEnreda.FLAG_CHAT]?? false)? 100:0,
                                title: (widget.user.gamificationFlags[UserEnreda.FLAG_CHAT]?? false)? "CHAT INICIADO": "CHAT NO INICIADO",
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
                                    certifiedCompetencies = Map.from(widget.user.competencies);
                                    certifiedCompetencies.removeWhere((key, value) => value != "certified");
                                    competenciesProgress = (certifiedCompetencies.length / competenciesStream.data!.length) * 100;
                                  }

                                  return GamificationItem(
                                    imagePath: ImagePath.GAMIFICATION_COMPETENCIES_ICON,
                                    progress: competenciesProgress,
                                    progressText: "${certifiedCompetencies.length}",
                                    title: "COMPETENCIAS CERTIFICADAS",
                                  );
                                }
                              ),
                              GamificationItem(
                                imagePath: ImagePath.GAMIFICATION_RESOURCES_ICON,
                                progress: ((widget.user.resourcesAccessCount?? 0) / 15) * 100,
                                progressText: "${widget.user.resourcesAccessCount}",
                                title: "RECURSOS INSCRITOS",
                              ),
                              GamificationItem(
                                imagePath: ImagePath.GAMIFICATION_CV_ICON,
                                progress: (_getUserCvStepsCompleted()/cvTotalSteps) * 100,
                                progressText: "${(_getUserCvStepsCompleted()/cvTotalSteps) * 100}%",
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
          SpaceH20(),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextBoldTitle(title: StringConst.INITIAL_FORM),
                    SpaceH16(),
                    RoundedContainer(
                      margin: EdgeInsets.all(0.0),
                      contentPadding: EdgeInsets.all(0.0),
                      height: 600,
                      borderColor: AppColors.greyAlt.withOpacity(0.15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
                            child: CustomTextMediumBold(text: StringConst.INITIAL_FORM_DATA),
                          ),
                          Divider(color: AppColors.greyAlt.withOpacity(0.15),),
                          Padding(
                            padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextMedium(text: StringConst.FORM_ABILITIES_REV),
                                StreamBuilder<List<Ability>>(
                                  stream: database.abilityStream(),
                                  builder: (context, snapshot) {
                                    String abilitiesString = "";
                                    if (snapshot.hasData) {
                                      widget.user.abilities!.forEach((abilityId) {
                                        final abilityName = snapshot.data!.firstWhere((a) => abilityId == a.abilityId).name;
                                        abilitiesString = "$abilitiesString$abilityName, ";
                                      });
                                      if (abilitiesString.isNotEmpty) {
                                          abilitiesString = abilitiesString.substring(0, abilitiesString.lastIndexOf(","));
                                        }
                                      }
                                    return Text(abilitiesString);
                                  }
                                ),
                                SpaceH12(),
                                CustomTextMedium(text: StringConst.FORM_DEDICATION_REV),
                                Text(widget.user.motivation?.dedication?.label??""),
                                SpaceH12(),
                                CustomTextMedium(text: StringConst.FORM_TIME_SEARCHING_REV),
                                Text(widget.user.motivation?.timeSearching?.label??""),
                                SpaceH12(),
                                CustomTextMedium(text: StringConst.FORM_TIME_SPENT_WEEKLY_REV),
                                Text(widget.user.motivation?.timeSpentWeekly?.label??""),
                                SpaceH12(),
                                CustomTextMedium(text: StringConst.FORM_EDUCATION_REV),
                                Text(widget.user.education?.label??""),
                                SpaceH12(),
                                CustomTextMedium(text: StringConst.FORM_INTERESTS),
                                StreamBuilder<List<Interest>>(
                                  stream: database.interestStream(),
                                  builder: (context, snapshot) {
                                    String interestsString = "";
                                    if (snapshot.hasData) {
                                      widget.user.interests.forEach((interestId) {
                                        final interestName = snapshot.data!.firstWhere((i) => interestId == i.interestId).name;
                                        interestsString = "$interestsString$interestName, ";
                                      });
                                      if (interestsString.isNotEmpty) {
                                        interestsString = interestsString.substring(0, interestsString.lastIndexOf(","));
                                      }
                                    }
                                    return Text(interestsString);
                                  }
                                ),
                                SpaceH12(),
                                CustomTextMedium(text: StringConst.FORM_SPECIFIC_INTERESTS),
                                StreamBuilder<List<SpecificInterest>>(
                                  stream: database.specificInterestsStream(),
                                  builder: (context, snapshot) {
                                    String specificInterestsString = "";
                                    if (snapshot.hasData) {
                                      widget.user.specificInterests.forEach((specificInterestId) {
                                        final specificInterestName = snapshot.data!.firstWhere((s) => specificInterestId == s.specificInterestId).name;
                                        specificInterestsString = "$specificInterestsString$specificInterestName, ";
                                      });
                                      if (specificInterestsString.isNotEmpty) {
                                        specificInterestsString = specificInterestsString.substring(0, specificInterestsString.lastIndexOf(","));
                                      }
                                    }
                                    return Text(specificInterestsString);
                                  }
                                ),
                                SpaceH12(),
                              ],
                            ),
                          ),
                      ],),
                    )
                  ],
                ),
              ),
              SpaceW20(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextBoldTitle(title: StringConst.CV),
                  SpaceH8(),
                  RoundedContainer(
                    height: 600.0,
                    width: 250.0,
                    borderColor: AppColors.greyAlt.withOpacity(0.15),
                    margin: EdgeInsets.all(0.0),
                    child: Container(),)
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantProfileWeb(BuildContext context, UserEnreda? user) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 250,
          child: Flex(
            direction:  Responsive.isMobile(context) || Responsive.isTablet(context)  ? Axis.vertical : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.greyDark,
                      ),
                      onPressed: widget.onBack,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(120),
                          ),
                          child:
                          !kIsWeb ? ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(60)),
                            child:
                            Center(
                              child:
                              user?.photo == "" ?
                              Container(
                                color:  Colors.transparent,
                                height: Responsive.isMobile(context) ? 90 : 120,
                                width: Responsive.isMobile(context) ? 90 : 120,
                                child: Image.asset(ImagePath.USER_DEFAULT),
                              ):
                              CachedNetworkImage(
                                  width: Responsive.isMobile(context) ? 90 : 120,
                                  height: Responsive.isMobile(context) ? 90 : 120,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                  imageUrl: user?.photo ?? ""),
                            ),
                          ):
                          ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(60)),
                            child:
                            Center(
                              child:
                              user?.photo == "" ?
                              Container(
                                color:  Colors.transparent,
                                height: Responsive.isMobile(context) ? 90 : 120,
                                width: Responsive.isMobile(context) ? 90 : 120,
                                child: Image.asset(ImagePath.USER_DEFAULT),
                              ):
                              FadeInImage.assetNetwork(
                                placeholder: ImagePath.USER_DEFAULT,
                                width: Responsive.isMobile(context) ? 90 : 120,
                                height: Responsive.isMobile(context) ? 90 : 120,
                                fit: BoxFit.cover,
                                image: user?.photo ?? "",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${user!.firstName} ${user.lastName}',
                            style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold, color: AppColors.chatDarkGray),
                          ),
                          const SizedBox(height: 8,),
                          Text(
                            '${user.educationName}'.toUpperCase(),
                            style: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold, color: AppColors.penBlue),
                          ),
                          const SizedBox(height: 30,),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () => showDialog(
                          context: context,
                          builder: (BuildContext context) => ShowInvitationDialog(user: user, organizerId: widget.socialEntityUser.socialEntityId!,)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.violet, // Background color
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(StringConst.INVITE_RESOURCE.toUpperCase(),
                              style: textTheme.titleLarge?.copyWith(
                                color: AppColors.penBlue,
                                letterSpacing: 1.1,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: Responsive.isMobile(context) ? 5 : 20),
                            SizedBox(height: 40, width: 40, child: Image.asset(ImagePath.CREATE_RESOURCE),)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: Responsive.isMobile(context) || Responsive.isTablet(context) ? 500 : 250,
          child: Flex(
            direction:  Responsive.isMobile(context) || Responsive.isTablet(context) ? Axis.vertical : Axis.horizontal,
            children: [
              Expanded(
                  flex: Responsive.isMobile(context) || Responsive.isTablet(context) ? 1 : 1,
                  child: _buildPersonalData(context, user)
              ),
              Expanded(
                  flex: Responsive.isMobile(context) || Responsive.isTablet(context) ? 1 : 3,
                  child: _buildResourcesParticipant(context, user)),
              Expanded(
                  flex: Responsive.isMobile(context) || Responsive.isTablet(context) ? 1 : 1,
                  child: _buildCvParticipant(context, user)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantProfileMobile(BuildContext context, UserEnreda? user) {
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.greyDark,
                ),
                onPressed: widget.onBack,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(120),
                    ),
                    child:
                    !kIsWeb ? ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(60)),
                      child:
                      Center(
                        child:
                        user?.photo == "" ?
                        Container(
                          color:  Colors.transparent,
                          height: Responsive.isMobile(context) ? 90 : 120,
                          width: Responsive.isMobile(context) ? 90 : 120,
                          child: Image.asset(ImagePath.USER_DEFAULT),
                        ):
                        CachedNetworkImage(
                            width: Responsive.isMobile(context) ? 90 : 120,
                            height: Responsive.isMobile(context) ? 90 : 120,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            imageUrl: user?.photo ?? ""),
                      ),
                    ):
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(60)),
                      child:
                      Center(
                        child:
                        user?.photo == "" ?
                        Container(
                          color:  Colors.transparent,
                          height: Responsive.isMobile(context) ? 90 : 120,
                          width: Responsive.isMobile(context) ? 90 : 120,
                          child: Image.asset(ImagePath.USER_DEFAULT),
                        ):
                        FadeInImage.assetNetwork(
                          placeholder: ImagePath.USER_DEFAULT,
                          width: Responsive.isMobile(context) ? 90 : 120,
                          height: Responsive.isMobile(context) ? 90 : 120,
                          fit: BoxFit.cover,
                          image: user?.photo ?? "",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user!.firstName} ${user.lastName}',
                        maxLines: 2,
                        style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold, color: AppColors.chatDarkGray, overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(height: 8,),
                      Text(
                        '${user.educationName}'.toUpperCase(),
                        maxLines: 2,
                        style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold, color: AppColors.penBlue, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20,),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () => showDialog(
                    context: context,
                    builder: (BuildContext context) => ShowInvitationDialog(user: user, organizerId: widget.socialEntityUser.socialEntityId!,)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.violet, // Background color
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(StringConst.INVITE_RESOURCE.toUpperCase(),
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.penBlue,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: Responsive.isMobile(context) ? 5 : 20),
                      SizedBox(height: 40, width: 40, child: Image.asset(ImagePath.CREATE_RESOURCE),)
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20,),
          Column(
            children: [
              _buildPersonalData(context, user),
              _buildResourcesParticipant(context, user),
              _buildCvParticipant(context, user),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserEnreda user){
    final textTheme = Theme.of(context).textTheme;
    final database = Provider.of<Database>(context, listen: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Photo
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 40, top: 30, right: 20, bottom: 30),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(160),
                  ),
                  child:
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(160)),
                    child:
                    Center(
                      child:
                      user.photo == "" ?
                      Container(
                        color:  Colors.transparent,
                        height: 160,
                        width: 160,
                        child: Image.asset(ImagePath.USER_DEFAULT),
                      ):
                      FadeInImage.assetNetwork(
                        placeholder: ImagePath.USER_DEFAULT,
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                        image: user.photo ?? "",
                      ),
                    ),
                  ),
                ),
              ),


              //Personal data
              StreamBuilder<UserEnreda>(
                stream: database.userEnredaStreamByUserId(user.assignedById),
                builder: (context, snapshot) {
                  String techName = snapshot.data?.firstName ?? '';
                  String techLastName = snapshot.data?.lastName ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(top:50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${user.firstName} ${user.lastName}',
                              style:
                                textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.chatDarkGray,
                                fontFamily: GoogleFonts.outfit().fontFamily,
                                fontSize: 35,
                                ),
                            ),
                            //Invite resource
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 150, right: 30),
                                child: AddYellowButton(
                                  text: 'Invitar a un recurso',
                                  onPressed: () => showDialog(
                                      context: context,
                                      builder: (BuildContext context) => ShowInvitationDialog(user: user, organizerId: widget.socialEntityUser.socialEntityId!,)),
                                ),
                              ),
                            )
                          ],
                        ),
                        SpaceH8(),
                        (techName != '' || techLastName != '') ?
                          Text('Tecnico de referencia: $techName $techLastName') :
                          Container(),
                        SpaceH50(),

                        Row(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.mail,
                                  color: AppColors.darkGray,
                                  size: 22.0,
                                ),
                                const SpaceW4(),
                                CustomTextSmall(text: user.email,),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    color: AppColors.darkGray,
                                    size: 22.0,
                                  ),
                                  const SpaceW4(),
                                  CustomTextSmall(text: user.phone ?? '',)
                                ],
                              ),
                            ),
                            _buildMyLocation(context, user),
                          ],
                        )

                      ],
                    ),
                  );
                }
              ),

            ],
          ),
        ),
      ],
    );

    return SizedBox(
      height: 250,
      child: Flex(
        direction:  Responsive.isMobile(context) || Responsive.isTablet(context)  ? Axis.vertical : Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.greyDark,
                  ),
                  onPressed: widget.onBack,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(120),
                      ),
                      child:
                      !kIsWeb ? ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(60)),
                        child:
                        Center(
                          child:
                          user?.photo == "" ?
                          Container(
                            color:  Colors.transparent,
                            height: Responsive.isMobile(context) ? 90 : 120,
                            width: Responsive.isMobile(context) ? 90 : 120,
                            child: Image.asset(ImagePath.USER_DEFAULT),
                          ):
                          CachedNetworkImage(
                              width: Responsive.isMobile(context) ? 90 : 120,
                              height: Responsive.isMobile(context) ? 90 : 120,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              imageUrl: user?.photo ?? ""),
                        ),
                      ):
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(60)),
                        child:
                        Center(
                          child:
                          user?.photo == "" ?
                          Container(
                            color:  Colors.transparent,
                            height: Responsive.isMobile(context) ? 90 : 120,
                            width: Responsive.isMobile(context) ? 90 : 120,
                            child: Image.asset(ImagePath.USER_DEFAULT),
                          ):
                          FadeInImage.assetNetwork(
                            placeholder: ImagePath.USER_DEFAULT,
                            width: Responsive.isMobile(context) ? 90 : 120,
                            height: Responsive.isMobile(context) ? 90 : 120,
                            fit: BoxFit.cover,
                            image: user?.photo ?? "",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user!.firstName} ${user.lastName}',
                        style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold, color: AppColors.chatDarkGray),
                      ),
                      const SizedBox(height: 8,),
                      Text(
                        '${user.educationName}'.toUpperCase(),
                        style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold, color: AppColors.penBlue),
                      ),
                      const SizedBox(height: 30,),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () => showDialog(
                      context: context,
                      builder: (BuildContext context) => ShowInvitationDialog(user: user, organizerId: widget.socialEntityUser.socialEntityId!,)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.violet, // Background color
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(StringConst.INVITE_RESOURCE.toUpperCase(),
                          style: textTheme.titleLarge?.copyWith(
                            color: AppColors.penBlue,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: Responsive.isMobile(context) ? 5 : 20),
                        SizedBox(height: 40, width: 40, child: Image.asset(ImagePath.CREATE_RESOURCE),)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceMenu(BuildContext context, UserEnreda user){
    return Container();
  }

  Widget _buildIPIL(BuildContext context, UserEnreda user){
    return Container();
  }

  Widget _buildPersonalData(BuildContext context, UserEnreda user) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyLight2.withOpacity(0.3), width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
        color: AppColors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringConst.PERSONAL_DATA,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: Responsive.isDesktop(context) ? 18 : 14.0,
              color: AppColors.penBlue,
            ),
          ),
          const SpaceH20(),
          Row(
            children: [
              const Icon(
                Icons.mail,
                color: AppColors.darkGray,
                size: 12.0,
              ),
              const SpaceW4(),
              Flexible(
                  child: CustomTextSmall(text: user.email,)
              ),
            ],
          ),
          const SpaceH8(),
          Row(
            children: [
              const Icon(
                Icons.phone,
                color: AppColors.darkGray,
                size: 12.0,
              ),
              const SpaceW4(),
              CustomTextSmall(text: user.phone ?? '',)
            ],
          ),
          const SpaceH8(),
          _buildMyLocation(context, user),
        ],
      ),
    );
  }

  Widget _buildMyLocation(BuildContext context, UserEnreda? user) {
    final database = Provider.of<Database>(context, listen: false);
    Country? myCountry;
    Province? myProvince;
    City? myCity;
    String? city;
    String? province;
    String? country;

    return StreamBuilder<Country>(
        stream: database.countryStream(user?.address?.country),
        builder: (context, snapshot) {
          myCountry = snapshot.data;
          return StreamBuilder<Province>(
              stream: database.provinceStream(user?.address?.province),
              builder: (context, snapshot) {
                myProvince = snapshot.data;

                return StreamBuilder<City>(
                    stream: database.cityStream(user?.address?.city),
                    builder: (context, snapshot) {
                      myCity = snapshot.data;
                      city = myCity?.name ?? '';
                      province = myProvince?.name ?? '';
                      country = myCountry?.name ?? '';
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.black.withOpacity(0.7),
                            size: 22,
                          ),
                          const SpaceW4(),
                          /*Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextSmall(text: city ?? ''),
                              CustomTextSmall(text: province ?? ''),
                              CustomTextSmall(text: country ?? ''),
                            ],
                          ),*/
                          CustomTextSmall(text: city ?? ''),
                        ],
                      );
                    });
              });
        });
  }

  Widget _buildResourcesParticipant(BuildContext context, UserEnreda user) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: Responsive.isMobile(context) || Responsive.isTablet(context) ? null : 250,
      margin: Responsive.isMobile(context) || Responsive.isTablet(context) ? const EdgeInsets.symmetric(vertical: 20.0) : const EdgeInsets.only(left: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyLight2.withOpacity(0.3), width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
        color: AppColors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            StringConst.RESOURCES_PARTICIPANT,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: Responsive.isDesktop(context) ? 18 : 14.0,
              color: AppColors.penBlue,
            ),
          ),
          const SizedBox(height: 10,),
          ParticipantResourcesList(participantId: user.userId!, organizerId: widget.socialEntityUser.socialEntityId!,),
        ],
      ),
    );
  }

  Widget _buildCvParticipant(BuildContext context, UserEnreda user) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: Responsive.isMobile(context) || Responsive.isTablet(context) ? const EdgeInsets.only(top: 20) : const EdgeInsets.only(left: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyLight2.withOpacity(0.3), width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
        color: AppColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            StringConst.MY_CV,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: Responsive.isDesktop(context) ? 18 : 14.0,
              color: AppColors.penBlue,
            ),
          ),
          const SizedBox(height: 10,),
          IconButton(
            iconSize: 40,
            icon: const Icon(
              Icons.pages,
              color: AppColors.penBlue,
            ),
            onPressed: () => {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  fullscreenDialog: true,
                  builder: ((context) => MyCurriculumPage(user: user)),
                ),
              )
            },
          ),
        ],
      ),
    );
  }

  int _getUserPillsConsumed() {
    int userPillsConsumed = 2; // 2 first pills are always consumed
    if (widget.user.gamificationFlags[UserEnreda.FLAG_PILL_COMPETENCIES]?? false) {
      userPillsConsumed++;
    }
    if (widget.user.gamificationFlags[UserEnreda.FLAG_PILL_CV_COMPETENCIES]?? false) {
      userPillsConsumed++;
    }
    if (widget.user.gamificationFlags[UserEnreda.FLAG_PILL_HOW_TO_DO_CV]?? false) {
      userPillsConsumed++;
    }
    return userPillsConsumed;
  }

  int _getUserCvStepsCompleted() {
    int userCvStepsCompleted = 0;

    if (widget.user.gamificationFlags[UserEnreda.FLAG_CV_PHOTO]?? false) {
      userCvStepsCompleted++;
    }
    if (widget.user.gamificationFlags[UserEnreda.FLAG_CV_ABOUT_ME]?? false) {
      userCvStepsCompleted++;
    }
    if (widget.user.gamificationFlags[UserEnreda.FLAG_CV_DATA_OF_INTEREST]?? false) {
      userCvStepsCompleted++;
    }
    if (widget.user.gamificationFlags[UserEnreda.FLAG_CV_FORMATION]?? false) {
      userCvStepsCompleted++;
    }
    if (widget.user.gamificationFlags[UserEnreda.FLAG_CV_COMPLEMENTARY_FORMATION]?? false) {
      userCvStepsCompleted++;
    }
    if (widget.user.gamificationFlags[UserEnreda.FLAG_CV_PERSONAL]?? false) {
      userCvStepsCompleted++;
    }
    if (widget.user.gamificationFlags[UserEnreda.FLAG_CV_PROFESSIONAL]?? false) {
      userCvStepsCompleted++;
    }

    return userCvStepsCompleted;
  }
}
