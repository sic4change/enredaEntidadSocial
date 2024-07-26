import 'package:enreda_empresas/app/common_widgets/alert_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/closure_report_participant.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/derivation_report_participant.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/follow_report_participant.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/initial_report_participant.dart';
import 'package:enreda_empresas/app/home/participants/pdf_generator/pdf_closure_follow_preview.dart';
import 'package:enreda_empresas/app/home/participants/pdf_generator/pdf_initial_derivation_preview.dart';
import 'package:enreda_empresas/app/home/participants/pdf_generator/pdf_initial_follow_preview.dart';
import 'package:enreda_empresas/app/home/participants/pdf_generator/pdf_initial_report_preview.dart';
import 'package:enreda_empresas/app/models/closureReport.dart';
import 'package:enreda_empresas/app/models/derivationReport.dart';
import 'package:enreda_empresas/app/models/followReport.dart';
import 'package:enreda_empresas/app/models/initialReport.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:enreda_empresas/app/home/resources/global.dart' as globals;

import '../../../common_widgets/empty-list.dart';

enum SampleItem { itemOne, itemTwo, itemThree, itemFour }

class ParticipantSocialReportPage extends StatefulWidget {
  ParticipantSocialReportPage({required this.participantUser, super.key, required this.context});
  static ValueNotifier<int> selectedIndexInforms = ValueNotifier(0);
  final UserEnreda participantUser;
  final BuildContext context;

  @override
  State<ParticipantSocialReportPage> createState() => _ParticipantSocialReportPageState();
}

class _ParticipantSocialReportPageState extends State<ParticipantSocialReportPage> {
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  int totalReports = 1;
  late UserEnreda user;
  late Widget currentPage;
  var bodyWidget = <Widget>[];
  String? participantAssignedUserId;
  late InitialReport initialReport = InitialReport();
  bool? noneAreSet;

  @override
  void initState() {
    bodyWidget = [
      selectionPage(),
      InitialReportForm(user: widget.participantUser),
      FollowReportForm(user: widget.participantUser),
      DerivationReportForm(user: widget.participantUser),
      ClosureReportForm(user: widget.participantUser),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: ParticipantSocialReportPage.selectedIndexInforms,
        builder: (context, selectedIndex, child) {
          return SingleChildScrollView(
            child: Container(
                child: bodyWidget[selectedIndex]),
          );
        }
    );
    //return currentPage;
  }

  Widget selectionPage(){
    final database = Provider.of<Database>(context, listen: false);
    late InitialReport initialReportUser = InitialReport();
    late ClosureReport closureReportUser = ClosureReport();
    late FollowReport followReportUser = FollowReport();
    late DerivationReport derivationReportUser = DerivationReport();

    return StreamBuilder<UserEnreda>(
        stream: database.userEnredaStreamByUserId(
            widget.participantUser.userId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            user = snapshot.data!;
            participantAssignedUserId = user.assignedById ?? '';
            totalReports = 1;
            if(user.followReportId != null ){
              totalReports++;
            }
            if(user.closureReportId != null ){
              totalReports++;
            }
            if(user.derivationReportId != null){
              totalReports++;
            }
            noneAreSet = [user.initialReportId, user.followReportId,
              user.derivationReportId, user.closureReportId]
                .every((id) => id == null);
          }else{
            user = widget.participantUser;
          }
          return StreamBuilder<InitialReport>(
            stream: database.initialReportsStreamByUserId(user.userId),
            builder: (context, snapshot) {
              if(snapshot.hasData){
                globals.currentInitialReportUser = snapshot.data!;
                initialReportUser = snapshot.data!;
              }
              return StreamBuilder<ClosureReport>(
                stream: database.closureReportsStreamByUserId(user.userId),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    globals.currentClosureReportUser = snapshot.data!;
                    closureReportUser = snapshot.data!;
                  }
                  return StreamBuilder<FollowReport>(
                    stream: database.followReportsStreamByUserId(user.userId),
                    builder: (context, snapshot) {
                      if(snapshot.hasData){
                        globals.currentFollowReportUser = snapshot.data!;
                        followReportUser = snapshot.data!;
                      }
                      return StreamBuilder<DerivationReport>(
                        stream: database.derivationReportsStreamByUserId(user.userId),
                        builder: (context, snapshot) {
                          if(snapshot.hasData){
                            globals.currentDerivationReportUser = snapshot.data!;
                            derivationReportUser = snapshot.data!;
                          }
                          return Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: AppColors.greyBorder),
                            ),
                            child: Column(
                                children: [
                                  _buildHeader(
                                          user,
                                          initialReportUser,
                                          followReportUser,
                                          derivationReportUser,
                                          closureReportUser),
                                      Divider(
                                    color: AppColors.greyBorder,
                                    height: 0,
                                  ),
                                  Column(
                                    children: [
                                        noneAreSet == true ?
                                          globals.currentSocialEntityUser?.userId == participantAssignedUserId ?
                                        EmptyList(
                                            title: 'Todavía no has creado ningún informe social.',
                                            subtitle: 'Crea el Informe Inicial.',
                                            imagePath: ImagePath.EMPTY_LiST_ICON,
                                            onPressed: () {
                                                ParticipantSocialReportPage.selectedIndexInforms.value = 1;
                                            }
                                        ) : EmptyList(
                                              title: 'No hay informes creados.',
                                              imagePath: ImagePath.EMPTY_LiST_ICON,
                                          ) : Container(),
                                        if(user.initialReportId != null)
                                           _documentTile(
                                              context,
                                              'INFORME INICIAL',
                                              formatter.format(initialReportUser.completedDate ?? DateTime.now()),
                                              0,
                                              (){ setState(() { ParticipantSocialReportPage.selectedIndexInforms.value = 1;});},
                                              () async {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        MyInitialReport(
                                                          user: user,
                                                          initialReport: globals.currentInitialReportUser,
                                                        )
                                                  ),
                                                );
                                              },
                                              initialReportUser.finished ?? false,
                                          ),

                                        if(user.followReportId != null)
                                          _documentTile(
                                              context,
                                              'INFORME DE SEGUIMIENTO',
                                              formatter.format(followReportUser.completedDate ?? DateTime.now()),
                                              1,
                                              (){ setState(() { ParticipantSocialReportPage.selectedIndexInforms.value = 2;});},
                                              () async {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MyFollowReport(
                                                            user: user,
                                                            followReport: followReportUser,
                                                          )
                                                  ),
                                                );
                                              },
                                              followReportUser.finished ?? false),

                                        if(user.derivationReportId != null)
                                          _documentTile(
                                              context,
                                              'INFORME DE DERIVACIÓN',
                                              formatter.format(followReportUser.completedDate ?? DateTime.now()),
                                              user.followReportId == null ? 1 : 2,
                                              (){ setState(() { ParticipantSocialReportPage.selectedIndexInforms.value = 3;});},
                                              () async {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MyDerivationReport(
                                                            user: user,
                                                            derivationReport: derivationReportUser,
                                                          ),
                                                  ),
                                                );
                                              },
                                              derivationReportUser.finished ?? false),

                                        if(user.closureReportId != null)
                                          _documentTile(
                                              context,
                                              'INFORME DE CIERRE',
                                              formatter.format(closureReportUser.completedDate ?? DateTime.now()),
                                              _closureReportNumber(),
                                              () { setState(() { ParticipantSocialReportPage.selectedIndexInforms.value = 4;});},
                                              () async {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MyClosureReport(
                                                            user: user,
                                                            closureReport: closureReportUser,
                                                          )
                                                  ),
                                                );
                                              },
                                              closureReportUser.finished ?? false),
                                      ]
                                  ),
                                ]
                            ),
                          );
                        }
                      );
                    }
                  );
                }
              );
            }
          );
        }
    );
  }

  int _closureReportNumber(){
    int result = 1;
    if(user.derivationReportId != null){
      result++;
    }
    if(user.followReportId != null){
      result++;
    }
    return result;
  }

  Widget _buildHeader(
      UserEnreda user,
      InitialReport initialReport,
      FollowReport followReport,
      DerivationReport derivationReport,
      ClosureReport closureReport) {
    SampleItem? selectedItem;
    return Padding(
        padding: Responsive.isMobile(context) ? EdgeInsets.symmetric(horizontal: 8.0) : EdgeInsets.only(
            left: 50.0, top: 15.0, bottom: 15.0, right: 40),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextBoldTitle(
                  title: StringConst.SOCIAL_REPORTS.toUpperCase()),
              globals.currentSocialEntityUser?.userId != participantAssignedUserId ? Container() :
              Theme(
                data: Theme.of(context).copyWith(
                  dividerTheme: DividerThemeData(
                    color: AppColors.greyDropMenuBorder,
                  )
                ),
                child: PopupMenuButton<SampleItem>(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  enableFeedback: false,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: AppColors.greyDropMenuBorder,),
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                  ),
                  icon: Icon(
                    Icons.add_circle_outlined,
                    color: AppColors.turquoiseBlue,
                    size: 24,
                  ),
                  initialValue: selectedItem,
                  onSelected: (SampleItem item) {
                    setState(() {
                      selectedItem = item;
                    });
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
                    PopupMenuItem<SampleItem>(
                      value: SampleItem.itemOne,
                      enabled: false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextTitle(title: 'Crear Nuevo Informe', color: AppColors.primary900),
                          Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.turquoiseBlue,
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(
                      height: 1,
                    ),
                    PopupMenuItem<SampleItem>(
                        value: SampleItem.itemTwo,
                        child: CustomTextTitle(title: 'INFORME INICIAL', color: AppColors.primary900),
                        onTap: (){
                          if(user.initialReportId != null){
                            showAlertDialog(
                              context,
                              title: 'Aviso',
                              content: 'Este participante ya tiene un Informe Inicial.',
                              defaultActionText: 'Aceptar',
                            );
                            return;
                          }
                          setState(() {
                            ParticipantSocialReportPage.selectedIndexInforms.value = 1;
                          });
                        }
                    ),
                    PopupMenuItem<SampleItem>(
                      value: SampleItem.itemTwo,
                      child: CustomTextTitle(title: 'INFORME DE SEGUIMIENTO', color: AppColors.primary900),
                      onTap: (){
                        if(user.followReportId != null){
                          showAlertDialog(
                            context,
                            title: 'Aviso',
                            content: 'Este participante ya tiene un Informe de Seguimiento.',
                            defaultActionText: 'Aceptar',
                          );
                          return;
                        }
                        if(user.initialReportId != null){
                          if(initialReport.completedDate == null){
                            showAlertDialog(
                              context,
                              title: 'Aviso',
                              content: 'El Informe Inicial aún no se ha completado.',
                              defaultActionText: 'Aceptar',
                            );
                            return;
                          }
                        }
                        if(user.initialReportId != null){
                          if(initialReport.completedDate!.add(Duration(days: 180)).isBefore(DateTime.now()) == false){
                            showAlertDialog(
                              context,
                              title: 'Aviso',
                              content: 'Inicie el Informe de Seguimiento transcurridos los 6 meses del Informe Inicial.',
                              defaultActionText: 'Aceptar',
                            );
                            return;
                          }
                        }
                        setState(() {
                          ParticipantSocialReportPage.selectedIndexInforms.value = 2;
                        });

                      }
                    ),
                    PopupMenuItem<SampleItem>(
                      value: SampleItem.itemThree,
                      enabled: true,
                      child: CustomTextTitle(title: 'INFORME DE DERIVACIÓN', color: AppColors.primary900),
                      onTap: (){
                        if(user.derivationReportId != null){
                          showAlertDialog(
                            context,
                            title: 'Aviso',
                            content: 'Este participante ya tiene un Informe de Derivación.',
                            defaultActionText: 'Aceptar',
                          );
                          return;
                        }
                        if(initialReport.completedDate == null){
                          showAlertDialog(
                            context,
                            title: 'Aviso',
                            content: 'El Informe Inicial aún no se ha completado.',
                            defaultActionText: 'Aceptar',
                          );
                          return;
                        }
                        if(followReport.completedDate == null){
                          showAlertDialog(
                            context,
                            title: 'Aviso',
                            content: 'El Informe de Seguimiento aún no se ha completado.',
                            defaultActionText: 'Aceptar',
                          );
                          return;
                        }
                        setState(() {
                          ParticipantSocialReportPage.selectedIndexInforms.value = 3;
                        });
                      },
                    ),
                    PopupMenuItem<SampleItem>(
                      value: SampleItem.itemFour,
                      child: CustomTextTitle(title: 'INFORME DE CIERRE', color: AppColors.primary900),
                        onTap: (){
                          if(user.closureReportId != null){
                            showAlertDialog(
                              context,
                              title: 'Aviso',
                              content: 'Este participante ya tiene un Informe de Cierre',
                              defaultActionText: 'Aceptar',
                            );
                            return;
                          }
                          if(initialReport.completedDate == null){
                            showAlertDialog(
                              context,
                              title: 'Aviso',
                              content: 'El Informe Inicial aún no se ha completado.',
                              defaultActionText: 'Aceptar',
                            );
                            return;
                          }
                          if(followReport.completedDate == null){
                            showAlertDialog(
                              context,
                              title: 'Aviso',
                              content: 'El Informe de Seguimiento aún no se ha completado.',
                              defaultActionText: 'Aceptar',
                            );
                            return;
                          }
                          if(derivationReport.completedDate == null){
                            showAlertDialog(
                              context,
                              title: 'Aviso',
                              content: 'El Informe de Derivación aún no se ha completado.',
                              defaultActionText: 'Aceptar',
                            );
                            return;
                          }
                          setState(() {
                            ParticipantSocialReportPage.selectedIndexInforms.value = 4;
                          });
                        },
                    ),
                  ],
                ),
              )
            ]
          )
      );
  }

  Widget _documentTile(
      BuildContext context,
      String title,
      String date,
      int order,
      VoidCallback onView,
      VoidCallback onDownload,
      bool visibleDownload) {
    bool paridad = order % 2 == 0;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: paridad ? AppColors.greySearch : AppColors.white,
        borderRadius: order == totalReports - 1 ?
        BorderRadius.only(
            bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)) :
        BorderRadius.all(Radius.circular(0)),
      ),
      padding: Responsive.isMobile(context) ? const EdgeInsets.symmetric(horizontal: 20.0) : const EdgeInsets.symmetric(horizontal: 50.0),
      child: Row(
        children: [
          Flex(
            direction: Responsive.isMobile(context) ? Axis.vertical : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: GoogleFonts
                      .inter()
                      .fontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: Responsive.isDesktop(context) ? 16 : 13,
                  color: AppColors.chatDarkGray,
                ),
              ),
              visibleDownload ? Text(
                ' - ' + date,
                style: TextStyle(
                  fontFamily: GoogleFonts
                      .inter()
                      .fontFamily,
                  fontWeight: FontWeight.w500,
                  fontSize: Responsive.isDesktop(context) ? 16 : 13,
                  color: AppColors.chatDarkGray,
                ),
              ) : globals.currentSocialEntityUser?.userId == participantAssignedUserId ?
              InkWell(
                onTap: onView,
                child: Text(
                  ' - Seguir y finalizar',
                  style: TextStyle(
                    fontFamily: GoogleFonts
                        .inter()
                        .fontFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: Responsive.isDesktop(context) ? 16 : 13,
                    color: AppColors.turquoiseButton2,
                  ),
                ),
              ) :
              Text(
                ' - En proceso',
                style: TextStyle(
                  fontFamily: GoogleFonts.inter().fontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize:
                      Responsive.isDesktop(context) ? 16 : 13,
                  color: AppColors.turquoiseButton2,
                ),
              ),
            ],
          ),
          Spacer(),
          visibleDownload ? IconButton(
            icon: Image.asset(
              ImagePath.PERSONAL_DOCUMENTATION_VIEW,
              width: 20,
              height: 20,
            ),
            onPressed: onView,
          ) : Container(),
          SpaceW8(),
          visibleDownload ? IconButton(
            icon: Image.asset(
              ImagePath.PERSONAL_DOCUMENTATION_DOWNLOAD,
              width: 20,
              height: 20,
            ),
            onPressed: onDownload
          ) : Container(),
        ],
      ),
    );
  }

}
