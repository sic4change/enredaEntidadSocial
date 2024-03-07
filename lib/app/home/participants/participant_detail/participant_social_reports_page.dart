import 'dart:io';

import 'package:enreda_empresas/app/common_widgets/alert_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/closure_report_participant.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/follow_report_participant.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/initial_report_participant.dart';
import 'package:enreda_empresas/app/home/participants/pdf_generator/pdf_closure_follow_preview.dart';
import 'package:enreda_empresas/app/home/participants/pdf_generator/pdf_initial_follow_preview.dart';
import 'package:enreda_empresas/app/home/participants/pdf_generator/pdf_initial_report_preview.dart';
import 'package:enreda_empresas/app/models/closureReport.dart';
import 'package:enreda_empresas/app/models/followReport.dart';
import 'package:enreda_empresas/app/models/initialReport.dart';
import 'package:enreda_empresas/app/models/personalDocument.dart';
import 'package:enreda_empresas/app/models/personalDocumentType.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/functions.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

enum SampleItem { itemOne, itemTwo, itemThree, itemFour }

class ParticipantSocialReportPage extends StatefulWidget {
  ParticipantSocialReportPage({required this.participantUser, super.key, required this.context});

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

  @override
  void initState() {
    if(widget.participantUser.initialReportId == null){
        currentPage = InitialReportForm(user: widget.participantUser);
    }else{
      currentPage = selectionPage();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return currentPage;
  }

  Widget selectionPage(){
    final database = Provider.of<Database>(context, listen: false);
    late InitialReport initialReportUser = InitialReport();
    late ClosureReport closureReportUser = ClosureReport();
    late FollowReport followReportUser = FollowReport();

    return StreamBuilder<UserEnreda>(
        stream: database.userEnredaStreamByUserId(
            widget.participantUser.userId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            user = snapshot.data!;
            totalReports = 1;
            if(user.followReportId != null ){
              totalReports++;
            }
            if(user.closureReportId != null ){
              totalReports++;
            }
          }else{
            user = widget.participantUser;
          }
          return StreamBuilder<InitialReport>(
            stream: database.initialReportsStreamByUserId(user.userId),
            builder: (context, snapshot) {
              if(snapshot.hasData){
                initialReportUser = snapshot.data!;
              }
              return StreamBuilder<ClosureReport>(
                stream: database.closureReportsStreamByUserId(user.userId),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    closureReportUser = snapshot.data!;
                  }
                  return StreamBuilder<FollowReport>(
                    stream: database.followReportsStreamByUserId(user.userId),
                    builder: (context, snapshot) {
                      if(snapshot.hasData){
                        followReportUser = snapshot.data!;
                      }
                      return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: Responsive.isDesktop(context) ? 50.0 : 20.0,
                              vertical: 30),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: AppColors.greyBorder)
                            ),
                            child:
                            Column(
                                children: [
                                  if (Responsive.isDesktop(context) &&
                                      !Responsive.isDesktopS(context))
                                    _buildHeaderDesktop(() {
                                      if(user.closureReportId == null){
                                        setState(() {
                                          currentPage = ClosureReportForm(user: widget.participantUser);
                                        });
                                      }
                                    }, user, initialReportUser),
                                  if (!Responsive.isDesktop(context) ||
                                      Responsive.isDesktopS(context))
                                    _buildHeaderMobile((){
                                      if(widget.participantUser.closureReportId == null){

                                      }
                                    }, user),
                                  Divider(
                                    color: AppColors.greyBorder,
                                    height: 0,
                                  ),
                                  Column(
                                      children: [
                                        if(user.initialReportId != null)
                                           _documentTile(
                                              context,
                                              'INFORME INICIAL',
                                              formatter.format(initialReportUser.completedDate ?? DateTime.now()),
                                              0,
                                              (){
                                                setState(() {
                                                  currentPage = InitialReportForm(user: widget.participantUser);
                                                });
                                              },
                                              () async {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        MyInitialReport(
                                                          user: user,
                                                          initialReport: initialReportUser,
                                                        )
                                                  ),
                                                );
                                              },
                                            initialReportUser.finished ?? false,
                                          ),

                                        if(user.followReportId != null)
                                          _documentTile(context, 'INFORME DE SEGUIMIENTO', formatter.format(followReportUser.completedDate ?? DateTime.now()), 1, (){
                                            setState(() {
                                              currentPage = FollowReportForm(user: widget.participantUser);
                                            });
                                          },
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
                                          }, followReportUser.finished ?? false),

                                        if(user.closureReportId != null)
                                          _documentTile(context, 'INFORME DE CIERRE', formatter.format(closureReportUser.completedDate ?? DateTime.now()), user.followReportId == null ? 1 : 2, (){
                                            setState(() {
                                              currentPage = ClosureReportForm(user: widget.participantUser);
                                            });
                                          },
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
                                          }, closureReportUser.finished ?? false),
                                      ]
                                  )
                                ]
                            ),
                          )
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

  Widget _buildHeaderDesktop(VoidCallback onTap, UserEnreda user, InitialReport initialReport) {
    SampleItem? selectedItem;
    return Padding(
        padding: EdgeInsets.only(
            left: 50.0, top: 15.0, bottom: 15.0, right: 40),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextBoldTitle(
                  title: StringConst.PERSONAL_DOCUMENTATION.toUpperCase()),
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
                          Text(
                            'Crear Nuevo Informe',
                            style: TextStyle(
                              fontFamily: GoogleFonts.outfit().fontFamily,
                              fontSize: 16,
                              color: AppColors.turquoiseBlue,
                              fontWeight: FontWeight.w300,

                            ),
                          ),
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
                      child: Text(
                        'INFORME DE SEGUIMIENTO',
                        style: TextStyle(
                          fontFamily: GoogleFonts.inter().fontFamily,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      onTap: (){
                        if(user.followReportId != null){
                          showAlertDialog(
                            context,
                            title: 'Error',
                            content: 'Este participante ya tiene un informe de seguimiento',
                            defaultActionText: 'Aceptar',
                          );
                          return;
                        }
                        if(!initialReport.finished!){
                          showAlertDialog(
                            context,
                            title: 'Error',
                            content: 'El informe inicial aún no se ha completado',
                            defaultActionText: 'Aceptar',
                          );
                          return;
                        }
                        setState(() {
                          currentPage = FollowReportForm(
                              user: widget.participantUser,
                              followReport: FollowReport(
                                    userId: user.userId,
                                    subsidy: initialReport.subsidy,
                                    orientation1: initialReport.orientation1,
                                    arriveDate: initialReport.arriveDate,
                                    receptionResources: initialReport.receptionResources,
                                    externalResources: initialReport.externalResources,
                                    administrativeSituation: initialReport.administrativeSituation,
                                    expirationDate: initialReport.expirationDate,
                                    orientation2: initialReport.orientation2,
                                    healthCard: initialReport.healthCard,
                                    disease: initialReport.disease,
                                    medication: initialReport.medication,
                                    orientation2_1: initialReport.orientation2_1,
                                    rest: initialReport.rest,
                                    diagnosis: initialReport.diagnosis,
                                    treatment: initialReport.treatment,
                                    tracking: initialReport.tracking,
                                    psychosocial: initialReport.psychosocial,
                                    orientation2_2: initialReport.orientation2_2,
                                    disabilityState: initialReport.disabilityState,
                                    referenceProfessionalDisability: initialReport.referenceProfessionalDisability,
                                    disabilityGrade: initialReport.disabilityGrade,
                                    orientation2_3: initialReport.orientation2_3,
                                    dependenceState: initialReport.dependenceState,
                                    referenceProfessionalDependence: initialReport.referenceProfessionalDependence,
                                    homeAssistance: initialReport.homeAssistance,
                                    teleassistance: initialReport.teleassistance,
                                    dependenceGrade: initialReport.dependenceGrade,
                                    orientation2_4: initialReport.orientation2_4,
                                    externalDerivation: initialReport.externalDerivation,
                                    consumptionLevel: initialReport.consumptionLevel,
                                    addictionTreatment: initialReport.addictionTreatment,
                                    orientation3: initialReport.orientation3,
                                    openLegalProcess: initialReport.openLegalProcess,
                                    closeLegalProcess: initialReport.closeLegalProcess,
                                    legalRepresentation: initialReport.legalRepresentation,
                                    orientation4: initialReport.orientation4,
                                    ownershipType: initialReport.ownershipType,
                                    location: initialReport.location,
                                    livingUnit: initialReport.livingUnit,
                                    centerContact: initialReport.centerContact,
                                    hostingObservations: initialReport.hostingObservations,
                                    orientation5: initialReport.orientation5,
                                    informationNetworks: initialReport.informationNetworks,
                                    orientation6: initialReport.orientation6,
                                    socialStructureKnowledge: initialReport.socialStructureKnowledge,
                                    autonomyPhysicMental: initialReport.autonomyPhysicMental,
                                    socialSkills: initialReport.socialSkills,
                                    orientation7: initialReport.orientation7,
                                    language: initialReport.language,
                                    languageLevel: initialReport.languageLevel,
                                    orientation8: initialReport.orientation8,
                                    economicProgramHelp: initialReport.economicProgramHelp,
                                    familySupport: initialReport.familySupport,
                                    familyResponsibilities: initialReport.familyResponsibilities,
                                    orientation9: initialReport.orientation9,
                                    socialServiceAccess: initialReport.socialServiceAccess,
                                    centerTSReference: initialReport.centerTSReference,
                                    subsidyBeneficiary: initialReport.subsidyBeneficiary,
                                    socialServicesUser: initialReport.socialServicesUser,
                                    socialExclusionCertificate: initialReport.socialExclusionCertificate,
                                    orientation10: initialReport.orientation10,
                                    digitalSkillsLevel: initialReport.digitalSkillsLevel,
                                    orientation11: initialReport.orientation11,
                                    laborMarkerInterest: initialReport.laborMarkerInterest,
                                    laborExpectations: initialReport.laborExpectations,
                                    orientation12: initialReport.orientation12,
                                    vulnerabilityOptions: initialReport.vulnerabilityOptions,
                                    orientation13: initialReport.orientation13,
                                    educationLevel: initialReport.educationLevel,
                                    laborSituation: initialReport.laborSituation,
                                    laborExternalResources: initialReport.laborExternalResources,
                                    educationalEvaluation: initialReport.educationalEvaluation,
                                    formativeItinerary: initialReport.formativeItinerary,
                                    laborInsertion: initialReport.laborInsertion,
                                    accompanimentPostLabor: initialReport.accompanimentPostLabor,
                                    laborUpgrade: initialReport.laborUpgrade,
                                    finished: false,
                                  ),
                          );
                        });

                      }
                    ),
                    PopupMenuItem<SampleItem>(
                      value: SampleItem.itemThree,
                      enabled: false,
                      child: Text(
                        'INFORME DE DERIVACIÓN',
                        style: TextStyle(
                          fontFamily: GoogleFonts.inter().fontFamily,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    PopupMenuItem<SampleItem>(
                      value: SampleItem.itemFour,
                      child: Text(
                        'INFORME DE CIERRE',
                        style: TextStyle(
                          fontFamily: GoogleFonts.inter().fontFamily,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                        onTap: (){
                          if(user.closureReportId != null){
                            showAlertDialog(
                              context,
                              title: 'Error',
                              content: 'Este participante ya tiene un informe de cierre',
                              defaultActionText: 'Aceptar',
                            );
                            return;
                          }
                          if(!initialReport.finished!){
                            showAlertDialog(
                              context,
                              title: 'Error',
                              content: 'El informe inicial aún no se ha completado',
                              defaultActionText: 'Aceptar',
                            );
                            return;
                          }
                          setState(() {
                            currentPage = ClosureReportForm(user: widget.participantUser);
                          });
                        }
                    ),
                  ],
                ),
              )
            ]
          )
      );
  }

  Widget _buildHeaderMobile(VoidCallback onTap, UserEnreda user) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextBoldTitle(
                  title: StringConst.PERSONAL_DOCUMENTATION.toUpperCase()),
              SpaceH8(),
              user.closureReportId == null ? InkWell(
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle_outlined,
                      color: AppColors.turquoiseBlue,
                      size: 24,
                    ),
                  ],
                ),
                onTap: onTap,
              ) : Container(),
            ]
        )
    );
  }

  Widget _documentTile(BuildContext context, String title, String date, int order, VoidCallback onView, VoidCallback onDownload, bool visibleDownload) {
    bool paridad = order % 2 == 0;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: paridad ? AppColors.greySearch : AppColors.white,
        borderRadius: order == totalReports - 1 ?
        BorderRadius.only(
            bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)) :
        BorderRadius.all(Radius.circular(0)),
        //border: Border.all(color: AppColors.greyBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  left: Responsive.isDesktop(context) ? 50.0 : 16.0),
              child: Row(
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
                  Text(
                    ' - ',
                    style: TextStyle(
                      fontFamily: GoogleFonts
                          .inter()
                          .fontFamily,
                      fontWeight: FontWeight.w500,
                      fontSize: Responsive.isDesktop(context) ? 16 : 13,
                      color: AppColors.chatDarkGray,
                    ),
                  ),
                  visibleDownload ? Text(
                    date,
                    style: TextStyle(
                      fontFamily: GoogleFonts
                          .inter()
                          .fontFamily,
                      fontWeight: FontWeight.w500,
                      fontSize: Responsive.isDesktop(context) ? 16 : 13,
                      color: AppColors.chatDarkGray,
                    ),
                  ) :
                  InkWell(
                    onTap: onView,
                    child: Text(
                      'Seguir y finalizar',
                      style: TextStyle(
                        fontFamily: GoogleFonts
                            .inter()
                            .fontFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: Responsive.isDesktop(context) ? 16 : 13,
                        color: AppColors.turquoiseButton2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: title != '' ? Row(
              children: [
                IconButton(
                  icon: Image.asset(
                    ImagePath.PERSONAL_DOCUMENTATION_VIEW,
                    width: 20,
                    height: 20,
                  ),
                  onPressed: onView,
                ),
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
            ) :
            IconButton(
              icon: Image.asset(
                ImagePath.PERSONAL_DOCUMENTATION_ADD,
                width: 20,
                height: 20,
              ),
              onPressed: () async {

              },
            ),
          )
        ],
      ),
    );
  }

}
