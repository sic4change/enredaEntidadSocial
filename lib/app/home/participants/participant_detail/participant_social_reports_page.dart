import 'dart:io';

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
    late DerivationReport derivationReportUser = DerivationReport();

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
            if(user.derivationReportId != null){
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
                      return StreamBuilder<DerivationReport>(
                        stream: database.derivationReportsStreamByUserId(user.userId),
                        builder: (context, snapshot) {
                          if(snapshot.hasData){
                            derivationReportUser = snapshot.data!;
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
                                        }, user, initialReportUser, followReportUser),
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

                                            if(user.derivationReportId != null)
                                              _documentTile(context, 'INFORME DE DERIVACIÓN', formatter.format(followReportUser.completedDate ?? DateTime.now()), user.followReportId == null ? 1 : 2, (){
                                                setState(() {
                                                  currentPage = DerivationReportForm(user: widget.participantUser);
                                                });
                                              },
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
                                                  }, derivationReportUser.finished ?? false),

                                            if(user.closureReportId != null)
                                              _documentTile(context, 'INFORME DE CIERRE', formatter.format(closureReportUser.completedDate ?? DateTime.now()), _closureReportNumber(), (){
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

  Widget _buildHeaderDesktop(VoidCallback onTap, UserEnreda user, InitialReport initialReport, FollowReport followReport) {
    SampleItem? selectedItem;
    return Padding(
        padding: EdgeInsets.only(
            left: 50.0, top: 15.0, bottom: 15.0, right: 40),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextBoldTitle(
                  title: StringConst.SOCIAL_REPORTS.toUpperCase()),
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
                                userId: initialReport.userId,
                                subsidy: initialReport.subsidy,
                                techPerson: initialReport.techPerson,
                                orientation1: initialReport.orientation1,
                                arriveDate: initialReport.arriveDate,
                                receptionResources: initialReport.receptionResources,
                                administrativeExternalResources: initialReport.administrativeExternalResources,
                                expirationDate: initialReport.expirationDate,
                                adminState: initialReport.adminState,
                                adminNoThrough: initialReport.adminNoThrough,
                                adminDateAsk: initialReport.adminDateAsk,
                                adminDateResolution: initialReport.adminDateResolution,
                                adminDateConcession: initialReport.adminDateConcession,
                                adminTemp: initialReport.adminTemp,
                                adminResidenceWork: initialReport.adminResidenceWork,
                                adminDateRenovation: initialReport.adminDateRenovation,
                                adminResidenceType: initialReport.adminResidenceType,
                                adminJuridicFigure: initialReport.adminJuridicFigure,
                                adminOther: initialReport.adminOther,
                                orientation2: initialReport.orientation2,
                                healthCard: initialReport.healthCard,
                                medication: initialReport.medication,
                                orientation2_1: initialReport.orientation2_1,
                                rest: initialReport.rest,
                                diagnosis: initialReport.diagnosis,
                                treatment: initialReport.treatment,
                                tracking: initialReport.tracking,
                                orientation2_2: initialReport.orientation2_2,
                                disabilityState: initialReport.disabilityState,
                                referenceProfessionalDisability: initialReport.referenceProfessionalDisability,
                                disabilityGrade: initialReport.disabilityGrade,
                                disabilityType: initialReport.disabilityType,
                                granted: initialReport.granted,
                                revisionDate: initialReport.revisionDate,
                                orientation2_3: initialReport.orientation2_3,
                                dependenceState: initialReport.dependenceState,
                                referenceProfessionalDependence: initialReport.referenceProfessionalDependence,
                                dependenceGrade: initialReport.dependenceGrade,
                                orientation2_4: initialReport.orientation2_4,
                                externalDerivation: initialReport.externalDerivation,
                                motive: initialReport.motive,
                                orientation3: initialReport.orientation3,
                                internalDerivationLegal: initialReport.internalDerivationLegal,
                                internalDerivationDate: initialReport.internalDerivationDate,
                                internalDerivationMotive: initialReport.internalDerivationMotive,
                                externalDerivationLegal: initialReport.externalDerivationLegal,
                                externalDerivationDate: initialReport.externalDerivationDate,
                                externalDerivationMotive: initialReport.externalDerivationMotive,
                                psychosocialDerivationLegal: initialReport.psychosocialDerivationLegal,
                                psychosocialDerivationDate: initialReport.psychosocialDerivationDate,
                                psychosocialDerivationMotive: initialReport.psychosocialDerivationMotive,
                                legalRepresentation: initialReport.legalRepresentation,
                                orientation4: initialReport.orientation4,
                                ownershipType: initialReport.ownershipType,
                                location: initialReport.location,
                                centerContact: initialReport.centerContact,
                                hostingObservations: initialReport.hostingObservations,
                                ownershipTypeOpen: initialReport.ownershipTypeOpen,
                                homelessnessSituation: initialReport.homelessnessSituation,
                                homelessnessSituationOpen: initialReport.homelessnessSituationOpen,
                                livingUnit: initialReport.livingUnit,
                                ownershipTypeConcrete: initialReport.ownershipTypeConcrete,
                                orientation5: initialReport.orientation5,
                                informationNetworks: initialReport.informationNetworks,
                                institutionNetworks: initialReport.institutionNetworks,
                                familyConciliation: initialReport.familyConciliation,
                                orientation7: initialReport.orientation7,
                                languages: initialReport.languages,
                                orientation9: initialReport.orientation9,
                                centerTSReference: initialReport.centerTSReference,
                                subsidyBeneficiary: initialReport.subsidyBeneficiary,
                                socialExclusionCertificate: initialReport.socialExclusionCertificate,
                                subsidyName: initialReport.subsidyName,
                                socialExclusionCertificateDate: initialReport.socialExclusionCertificateDate,
                                socialExclusionCertificateObservations: initialReport.socialExclusionCertificateObservations,
                                orientation12: initialReport.orientation12,
                                vulnerabilityOptions: initialReport.vulnerabilityOptions,
                                orientation13: initialReport.orientation13,
                                orientation13_2: initialReport.orientation13_2,
                                educationLevel: initialReport.educationLevel,
                                tempLabor: initialReport.tempLabor,
                                workingDayLabor: initialReport.workingDayLabor,
                                competencies: initialReport.competencies,
                                contextualization: initialReport.contextualization,
                                connexion: initialReport.connexion,
                                shortTerm: initialReport.shortTerm,
                                mediumTerm: initialReport.mediumTerm,
                                longTerm: initialReport.longTerm,
                                finished: false,
                                  ),
                          );
                        });

                      }
                    ),
                    PopupMenuItem<SampleItem>(
                      value: SampleItem.itemThree,
                      enabled: true,
                      child: Text(
                        'INFORME DE DERIVACIÓN',
                        style: TextStyle(
                          fontFamily: GoogleFonts.inter().fontFamily,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      onTap: (){
                        if(user.derivationReportId != null){
                          showAlertDialog(
                            context,
                            title: 'Error',
                            content: 'Este participante ya tiene un informe de derivación',
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
                          if(followReport.finished!){
                            currentPage = DerivationReportForm(
                                user: widget.participantUser,
                                derivationReport: DerivationReport(
                                  userId: followReport.userId,
                                  subsidy: followReport.subsidy,
                                  techPerson: followReport.techPerson,
                                  orientation1: followReport.orientation1,
                                  arriveDate: followReport.arriveDate,
                                  receptionResources: followReport.receptionResources,
                                  administrativeExternalResources: followReport.administrativeExternalResources,
                                  expirationDate: followReport.expirationDate,
                                  adminState: followReport.adminState,
                                  adminNoThrough: followReport.adminNoThrough,
                                  adminDateAsk: followReport.adminDateAsk,
                                  adminDateResolution: followReport.adminDateResolution,
                                  adminDateConcession: followReport.adminDateConcession,
                                  adminTemp: followReport.adminTemp,
                                  adminResidenceWork: followReport.adminResidenceWork,
                                  adminDateRenovation: followReport.adminDateRenovation,
                                  adminResidenceType: followReport.adminResidenceType,
                                  adminJuridicFigure: followReport.adminJuridicFigure,
                                  adminOther: followReport.adminOther,
                                  orientation2: followReport.orientation2,
                                  healthCard: followReport.healthCard,
                                  medication: followReport.medication,
                                  orientation2_1: followReport.orientation2_1,
                                  rest: followReport.rest,
                                  diagnosis: followReport.diagnosis,
                                  treatment: followReport.treatment,
                                  tracking: followReport.tracking,
                                  orientation2_2: followReport.orientation2_2,
                                  disabilityState: followReport.disabilityState,
                                  referenceProfessionalDisability: followReport.referenceProfessionalDisability,
                                  disabilityGrade: followReport.disabilityGrade,
                                  disabilityType: followReport.disabilityType,
                                  granted: followReport.granted,
                                  revisionDate: followReport.revisionDate,
                                  orientation2_3: followReport.orientation2_3,
                                  dependenceState: followReport.dependenceState,
                                  referenceProfessionalDependence: followReport.referenceProfessionalDependence,
                                  dependenceGrade: followReport.dependenceGrade,
                                  orientation2_4: followReport.orientation2_4,
                                  externalDerivation: followReport.externalDerivation,
                                  motive: followReport.motive,
                                  orientation3: followReport.orientation3,
                                  internalDerivationLegal: followReport.internalDerivationLegal,
                                  internalDerivationDate: followReport.internalDerivationDate,
                                  internalDerivationMotive: followReport.internalDerivationMotive,
                                  externalDerivationLegal: followReport.externalDerivationLegal,
                                  externalDerivationDate: followReport.externalDerivationDate,
                                  externalDerivationMotive: followReport.externalDerivationMotive,
                                  psychosocialDerivationLegal: followReport.psychosocialDerivationLegal,
                                  psychosocialDerivationDate: followReport.psychosocialDerivationDate,
                                  psychosocialDerivationMotive: followReport.psychosocialDerivationMotive,
                                  legalRepresentation: followReport.legalRepresentation,
                                  processingBag: followReport.processingBag,
                                  processingBagDate: followReport.processingBagDate,
                                  economicAmount: followReport.economicAmount,
                                  orientation4: followReport.orientation4,
                                  ownershipType: followReport.ownershipType,
                                  location: followReport.location,
                                  centerContact: followReport.centerContact,
                                  hostingObservations: followReport.hostingObservations,
                                  ownershipTypeOpen: followReport.ownershipTypeOpen,
                                  homelessnessSituation: followReport.homelessnessSituation,
                                  homelessnessSituationOpen: followReport.homelessnessSituationOpen,
                                  livingUnit: followReport.livingUnit,
                                  ownershipTypeConcrete: followReport.ownershipTypeConcrete,
                                  orientation5: followReport.orientation5,
                                  informationNetworks: followReport.informationNetworks,
                                  institutionNetworks: followReport.institutionNetworks,
                                  familyConciliation: followReport.familyConciliation,
                                  orientation7: followReport.orientation7,
                                  languages: followReport.languages,
                                  orientation9: followReport.orientation9,
                                  centerTSReference: followReport.centerTSReference,
                                  subsidyBeneficiary: followReport.subsidyBeneficiary,
                                  socialExclusionCertificate: followReport.socialExclusionCertificate,
                                  subsidyName: followReport.subsidyName,
                                  socialExclusionCertificateDate: followReport.socialExclusionCertificateDate,
                                  socialExclusionCertificateObservations: followReport.socialExclusionCertificateObservations,
                                  orientation12: followReport.orientation12,
                                  vulnerabilityOptions: followReport.vulnerabilityOptions,
                                  orientation13: followReport.orientation13,
                                  orientation13_2: followReport.orientation13_2,
                                  educationLevel: followReport.educationLevel,
                                  tempLabor: followReport.tempLabor,
                                  workingDayLabor: followReport.workingDayLabor,
                                  competencies: followReport.competencies,
                                  contextualization: followReport.contextualization,
                                  connexion: followReport.connexion,
                                  shortTerm: followReport.shortTerm,
                                  mediumTerm: followReport.mediumTerm,
                                  longTerm: followReport.longTerm,
                                  orientation9_5: followReport.orientation9_5,
                                  formations: followReport.formations,
                                  formationBag: followReport.formationBag,
                                  formationBagDate: followReport.formationBagDate,
                                  formationBagMotive: followReport.formationBagMotive,
                                  formationBagEconomic: followReport.formationBagEconomic,
                                  jobObtaining: followReport.jobObtaining,
                                  jobObtainDate: followReport.jobObtainDate,
                                  jobFinishDate: followReport.jobFinishDate,
                                  jobUpgrade: followReport.jobUpgrade,
                                  upgradeMotive: followReport.upgradeMotive,
                                  upgradeDate: followReport.upgradeDate,
                                  orientation9_6: followReport.orientation9_6,
                                  postLaborAccompaniment: followReport.postLaborAccompaniment,
                                  postLaborAccompanimentMotive: followReport.postLaborAccompanimentMotive,
                                  postLaborInitialDate: followReport.postLaborInitialDate,
                                  postLaborFinalDate: followReport.postLaborFinalDate,
                                  postLaborTotalDays: followReport.postLaborTotalDays,
                                  jobMaintenance: followReport.jobMaintenance,
                                  finished: false,
                                ),);
                          } else{
                            currentPage = DerivationReportForm(
                              user: widget.participantUser,
                              derivationReport: DerivationReport(
                                userId: initialReport.userId,
                                subsidy: initialReport.subsidy,
                                techPerson: initialReport.techPerson,
                                orientation1: initialReport.orientation1,
                                arriveDate: initialReport.arriveDate,
                                receptionResources: initialReport.receptionResources,
                                administrativeExternalResources: initialReport.administrativeExternalResources,
                                expirationDate: initialReport.expirationDate,
                                adminState: initialReport.adminState,
                                adminNoThrough: initialReport.adminNoThrough,
                                adminDateAsk: initialReport.adminDateAsk,
                                adminDateResolution: initialReport.adminDateResolution,
                                adminDateConcession: initialReport.adminDateConcession,
                                adminTemp: initialReport.adminTemp,
                                adminResidenceWork: initialReport.adminResidenceWork,
                                adminDateRenovation: initialReport.adminDateRenovation,
                                adminResidenceType: initialReport.adminResidenceType,
                                adminJuridicFigure: initialReport.adminJuridicFigure,
                                adminOther: initialReport.adminOther,
                                orientation2: initialReport.orientation2,
                                healthCard: initialReport.healthCard,
                                medication: initialReport.medication,
                                orientation2_1: initialReport.orientation2_1,
                                rest: initialReport.rest,
                                diagnosis: initialReport.diagnosis,
                                treatment: initialReport.treatment,
                                tracking: initialReport.tracking,
                                orientation2_2: initialReport.orientation2_2,
                                disabilityState: initialReport.disabilityState,
                                referenceProfessionalDisability: initialReport.referenceProfessionalDisability,
                                disabilityGrade: initialReport.disabilityGrade,
                                disabilityType: initialReport.disabilityType,
                                granted: initialReport.granted,
                                revisionDate: initialReport.revisionDate,
                                orientation2_3: initialReport.orientation2_3,
                                dependenceState: initialReport.dependenceState,
                                referenceProfessionalDependence: initialReport.referenceProfessionalDependence,
                                dependenceGrade: initialReport.dependenceGrade,
                                orientation2_4: initialReport.orientation2_4,
                                externalDerivation: initialReport.externalDerivation,
                                motive: initialReport.motive,
                                orientation3: initialReport.orientation3,
                                internalDerivationLegal: initialReport.internalDerivationLegal,
                                internalDerivationDate: initialReport.internalDerivationDate,
                                internalDerivationMotive: initialReport.internalDerivationMotive,
                                externalDerivationLegal: initialReport.externalDerivationLegal,
                                externalDerivationDate: initialReport.externalDerivationDate,
                                externalDerivationMotive: initialReport.externalDerivationMotive,
                                psychosocialDerivationLegal: initialReport.psychosocialDerivationLegal,
                                psychosocialDerivationDate: initialReport.psychosocialDerivationDate,
                                psychosocialDerivationMotive: initialReport.psychosocialDerivationMotive,
                                legalRepresentation: initialReport.legalRepresentation,
                                orientation4: initialReport.orientation4,
                                ownershipType: initialReport.ownershipType,
                                location: initialReport.location,
                                centerContact: initialReport.centerContact,
                                hostingObservations: initialReport.hostingObservations,
                                ownershipTypeOpen: initialReport.ownershipTypeOpen,
                                homelessnessSituation: initialReport.homelessnessSituation,
                                homelessnessSituationOpen: initialReport.homelessnessSituationOpen,
                                livingUnit: initialReport.livingUnit,
                                ownershipTypeConcrete: initialReport.ownershipTypeConcrete,
                                orientation5: initialReport.orientation5,
                                informationNetworks: initialReport.informationNetworks,
                                institutionNetworks: initialReport.institutionNetworks,
                                familyConciliation: initialReport.familyConciliation,
                                orientation7: initialReport.orientation7,
                                languages: initialReport.languages,
                                orientation9: initialReport.orientation9,
                                centerTSReference: initialReport.centerTSReference,
                                subsidyBeneficiary: initialReport.subsidyBeneficiary,
                                socialExclusionCertificate: initialReport.socialExclusionCertificate,
                                subsidyName: initialReport.subsidyName,
                                socialExclusionCertificateDate: initialReport.socialExclusionCertificateDate,
                                socialExclusionCertificateObservations: initialReport.socialExclusionCertificateObservations,
                                orientation12: initialReport.orientation12,
                                vulnerabilityOptions: initialReport.vulnerabilityOptions,
                                orientation13: initialReport.orientation13,
                                orientation13_2: initialReport.orientation13_2,
                                educationLevel: initialReport.educationLevel,
                                tempLabor: initialReport.tempLabor,
                                workingDayLabor: initialReport.workingDayLabor,
                                competencies: initialReport.competencies,
                                contextualization: initialReport.contextualization,
                                connexion: initialReport.connexion,
                                shortTerm: initialReport.shortTerm,
                                mediumTerm: initialReport.mediumTerm,
                                longTerm: initialReport.longTerm,
                                finished: false,
                              ),);
                            }


                        });
                      },
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
                            if(followReport.finished!){
                              currentPage = DerivationReportForm(
                                user: widget.participantUser,
                                derivationReport: DerivationReport(
                                  userId: followReport.userId,
                                  subsidy: followReport.subsidy,
                                  techPerson: followReport.techPerson,
                                  fromInitialReport: false,
                                  orientation1: followReport.orientation1,
                                  arriveDate: followReport.arriveDate,
                                  receptionResources: followReport.receptionResources,
                                  administrativeExternalResources: followReport.administrativeExternalResources,
                                  expirationDate: followReport.expirationDate,
                                  adminState: followReport.adminState,
                                  adminNoThrough: followReport.adminNoThrough,
                                  adminDateAsk: followReport.adminDateAsk,
                                  adminDateResolution: followReport.adminDateResolution,
                                  adminDateConcession: followReport.adminDateConcession,
                                  adminTemp: followReport.adminTemp,
                                  adminResidenceWork: followReport.adminResidenceWork,
                                  adminDateRenovation: followReport.adminDateRenovation,
                                  adminResidenceType: followReport.adminResidenceType,
                                  adminJuridicFigure: followReport.adminJuridicFigure,
                                  adminOther: followReport.adminOther,
                                  orientation2: followReport.orientation2,
                                  healthCard: followReport.healthCard,
                                  medication: followReport.medication,
                                  orientation2_1: followReport.orientation2_1,
                                  rest: followReport.rest,
                                  diagnosis: followReport.diagnosis,
                                  treatment: followReport.treatment,
                                  tracking: followReport.tracking,
                                  orientation2_2: followReport.orientation2_2,
                                  disabilityState: followReport.disabilityState,
                                  referenceProfessionalDisability: followReport.referenceProfessionalDisability,
                                  disabilityGrade: followReport.disabilityGrade,
                                  disabilityType: followReport.disabilityType,
                                  granted: followReport.granted,
                                  revisionDate: followReport.revisionDate,
                                  orientation2_3: followReport.orientation2_3,
                                  dependenceState: followReport.dependenceState,
                                  referenceProfessionalDependence: followReport.referenceProfessionalDependence,
                                  dependenceGrade: followReport.dependenceGrade,
                                  orientation2_4: followReport.orientation2_4,
                                  externalDerivation: followReport.externalDerivation,
                                  motive: followReport.motive,
                                  orientation3: followReport.orientation3,
                                  internalDerivationLegal: followReport.internalDerivationLegal,
                                  internalDerivationDate: followReport.internalDerivationDate,
                                  internalDerivationMotive: followReport.internalDerivationMotive,
                                  externalDerivationLegal: followReport.externalDerivationLegal,
                                  externalDerivationDate: followReport.externalDerivationDate,
                                  externalDerivationMotive: followReport.externalDerivationMotive,
                                  psychosocialDerivationLegal: followReport.psychosocialDerivationLegal,
                                  psychosocialDerivationDate: followReport.psychosocialDerivationDate,
                                  psychosocialDerivationMotive: followReport.psychosocialDerivationMotive,
                                  legalRepresentation: followReport.legalRepresentation,
                                  processingBag: followReport.processingBag,
                                  processingBagDate: followReport.processingBagDate,
                                  economicAmount: followReport.economicAmount,
                                  orientation4: followReport.orientation4,
                                  ownershipType: followReport.ownershipType,
                                  location: followReport.location,
                                  centerContact: followReport.centerContact,
                                  hostingObservations: followReport.hostingObservations,
                                  ownershipTypeOpen: followReport.ownershipTypeOpen,
                                  homelessnessSituation: followReport.homelessnessSituation,
                                  homelessnessSituationOpen: followReport.homelessnessSituationOpen,
                                  livingUnit: followReport.livingUnit,
                                  ownershipTypeConcrete: followReport.ownershipTypeConcrete,
                                  orientation5: followReport.orientation5,
                                  informationNetworks: followReport.informationNetworks,
                                  institutionNetworks: followReport.institutionNetworks,
                                  familyConciliation: followReport.familyConciliation,
                                  orientation7: followReport.orientation7,
                                  languages: followReport.languages,
                                  orientation9: followReport.orientation9,
                                  centerTSReference: followReport.centerTSReference,
                                  subsidyBeneficiary: followReport.subsidyBeneficiary,
                                  socialExclusionCertificate: followReport.socialExclusionCertificate,
                                  subsidyName: followReport.subsidyName,
                                  socialExclusionCertificateDate: followReport.socialExclusionCertificateDate,
                                  socialExclusionCertificateObservations: followReport.socialExclusionCertificateObservations,
                                  orientation12: followReport.orientation12,
                                  vulnerabilityOptions: followReport.vulnerabilityOptions,
                                  orientation13: followReport.orientation13,
                                  orientation13_2: followReport.orientation13_2,
                                  educationLevel: followReport.educationLevel,
                                  tempLabor: followReport.tempLabor,
                                  workingDayLabor: followReport.workingDayLabor,
                                  competencies: followReport.competencies,
                                  contextualization: followReport.contextualization,
                                  connexion: followReport.connexion,
                                  shortTerm: followReport.shortTerm,
                                  mediumTerm: followReport.mediumTerm,
                                  longTerm: followReport.longTerm,
                                  orientation9_5: followReport.orientation9_5,
                                  formations: followReport.formations,
                                  formationBag: followReport.formationBag,
                                  formationBagDate: followReport.formationBagDate,
                                  formationBagMotive: followReport.formationBagMotive,
                                  formationBagEconomic: followReport.formationBagEconomic,
                                  jobObtaining: followReport.jobObtaining,
                                  jobObtainDate: followReport.jobObtainDate,
                                  jobFinishDate: followReport.jobFinishDate,
                                  jobUpgrade: followReport.jobUpgrade,
                                  upgradeMotive: followReport.upgradeMotive,
                                  upgradeDate: followReport.upgradeDate,
                                  orientation9_6: followReport.orientation9_6,
                                  postLaborAccompaniment: followReport.postLaborAccompaniment,
                                  postLaborAccompanimentMotive: followReport.postLaborAccompanimentMotive,
                                  postLaborInitialDate: followReport.postLaborInitialDate,
                                  postLaborFinalDate: followReport.postLaborFinalDate,
                                  postLaborTotalDays: followReport.postLaborTotalDays,
                                  jobMaintenance: followReport.jobMaintenance,
                                  finished: false,
                                ),);
                            } else{
                              currentPage = DerivationReportForm(
                                user: widget.participantUser,
                                derivationReport: DerivationReport(
                                  userId: initialReport.userId,
                                  subsidy: initialReport.subsidy,
                                  techPerson: initialReport.techPerson,
                                  fromInitialReport: true,
                                  orientation1: initialReport.orientation1,
                                  arriveDate: initialReport.arriveDate,
                                  receptionResources: initialReport.receptionResources,
                                  administrativeExternalResources: initialReport.administrativeExternalResources,
                                  expirationDate: initialReport.expirationDate,
                                  adminState: initialReport.adminState,
                                  adminNoThrough: initialReport.adminNoThrough,
                                  adminDateAsk: initialReport.adminDateAsk,
                                  adminDateResolution: initialReport.adminDateResolution,
                                  adminDateConcession: initialReport.adminDateConcession,
                                  adminTemp: initialReport.adminTemp,
                                  adminResidenceWork: initialReport.adminResidenceWork,
                                  adminDateRenovation: initialReport.adminDateRenovation,
                                  adminResidenceType: initialReport.adminResidenceType,
                                  adminJuridicFigure: initialReport.adminJuridicFigure,
                                  adminOther: initialReport.adminOther,
                                  orientation2: initialReport.orientation2,
                                  healthCard: initialReport.healthCard,
                                  medication: initialReport.medication,
                                  orientation2_1: initialReport.orientation2_1,
                                  rest: initialReport.rest,
                                  diagnosis: initialReport.diagnosis,
                                  treatment: initialReport.treatment,
                                  tracking: initialReport.tracking,
                                  orientation2_2: initialReport.orientation2_2,
                                  disabilityState: initialReport.disabilityState,
                                  referenceProfessionalDisability: initialReport.referenceProfessionalDisability,
                                  disabilityGrade: initialReport.disabilityGrade,
                                  disabilityType: initialReport.disabilityType,
                                  granted: initialReport.granted,
                                  revisionDate: initialReport.revisionDate,
                                  orientation2_3: initialReport.orientation2_3,
                                  dependenceState: initialReport.dependenceState,
                                  referenceProfessionalDependence: initialReport.referenceProfessionalDependence,
                                  dependenceGrade: initialReport.dependenceGrade,
                                  orientation2_4: initialReport.orientation2_4,
                                  externalDerivation: initialReport.externalDerivation,
                                  motive: initialReport.motive,
                                  orientation3: initialReport.orientation3,
                                  internalDerivationLegal: initialReport.internalDerivationLegal,
                                  internalDerivationDate: initialReport.internalDerivationDate,
                                  internalDerivationMotive: initialReport.internalDerivationMotive,
                                  externalDerivationLegal: initialReport.externalDerivationLegal,
                                  externalDerivationDate: initialReport.externalDerivationDate,
                                  externalDerivationMotive: initialReport.externalDerivationMotive,
                                  psychosocialDerivationLegal: initialReport.psychosocialDerivationLegal,
                                  psychosocialDerivationDate: initialReport.psychosocialDerivationDate,
                                  psychosocialDerivationMotive: initialReport.psychosocialDerivationMotive,
                                  legalRepresentation: initialReport.legalRepresentation,
                                  orientation4: initialReport.orientation4,
                                  ownershipType: initialReport.ownershipType,
                                  location: initialReport.location,
                                  centerContact: initialReport.centerContact,
                                  hostingObservations: initialReport.hostingObservations,
                                  ownershipTypeOpen: initialReport.ownershipTypeOpen,
                                  homelessnessSituation: initialReport.homelessnessSituation,
                                  homelessnessSituationOpen: initialReport.homelessnessSituationOpen,
                                  livingUnit: initialReport.livingUnit,
                                  ownershipTypeConcrete: initialReport.ownershipTypeConcrete,
                                  orientation5: initialReport.orientation5,
                                  informationNetworks: initialReport.informationNetworks,
                                  institutionNetworks: initialReport.institutionNetworks,
                                  familyConciliation: initialReport.familyConciliation,
                                  orientation7: initialReport.orientation7,
                                  languages: initialReport.languages,
                                  orientation9: initialReport.orientation9,
                                  centerTSReference: initialReport.centerTSReference,
                                  subsidyBeneficiary: initialReport.subsidyBeneficiary,
                                  socialExclusionCertificate: initialReport.socialExclusionCertificate,
                                  subsidyName: initialReport.subsidyName,
                                  socialExclusionCertificateDate: initialReport.socialExclusionCertificateDate,
                                  socialExclusionCertificateObservations: initialReport.socialExclusionCertificateObservations,
                                  orientation12: initialReport.orientation12,
                                  vulnerabilityOptions: initialReport.vulnerabilityOptions,
                                  orientation13: initialReport.orientation13,
                                  orientation13_2: initialReport.orientation13_2,
                                  educationLevel: initialReport.educationLevel,
                                  tempLabor: initialReport.tempLabor,
                                  workingDayLabor: initialReport.workingDayLabor,
                                  competencies: initialReport.competencies,
                                  contextualization: initialReport.contextualization,
                                  connexion: initialReport.connexion,
                                  shortTerm: initialReport.shortTerm,
                                  mediumTerm: initialReport.mediumTerm,
                                  longTerm: initialReport.longTerm,
                                  finished: false,
                                ),);
                            }
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
