import 'dart:io';

import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/closure_report_participant.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/initial_report_participant.dart';
import 'package:enreda_empresas/app/home/participants/pdf_generator/pdf_initial_report_preview.dart';
import 'package:enreda_empresas/app/models/closureReport.dart';
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
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class ParticipantSocialReportPage extends StatefulWidget {
  ParticipantSocialReportPage({required this.participantUser, super.key, required this.context});

  final UserEnreda participantUser;
  final BuildContext context;

  @override
  State<ParticipantSocialReportPage> createState() => _ParticipantSocialReportPageState();
}

class _ParticipantSocialReportPageState extends State<ParticipantSocialReportPage> {
  final int totalReports = 2;
  late UserEnreda user;
  late Widget currentPage;

  @override
  void initState() {
    if(widget.participantUser.initialReportId == null){
        currentPage = initialReport(context, widget.participantUser);
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
    late InitialReport initialReportUser;

    return StreamBuilder<UserEnreda>(
        stream: database.userEnredaStreamByUserId(
            widget.participantUser.userId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            user = snapshot.data!;
          }else{
            user = widget.participantUser;
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
                            database.addClosureReport(ClosureReport(
                              userId: widget.participantUser.userId,
                            ));
                          }
                        }),
                      if (!Responsive.isDesktop(context) ||
                          Responsive.isDesktopS(context))
                        _buildHeaderMobile((){
                          if(widget.participantUser.closureReportId == null){
                            database.addClosureReport(ClosureReport(
                              userId: widget.participantUser.userId,
                            ));
                          }
                        }),
                      Divider(
                        color: AppColors.greyBorder,
                        height: 0,
                      ),
                      Column(
                          children: [
                            if(user.initialReportId != null)
                              StreamBuilder<InitialReport>(
                                stream: database.initialReportsStreamByUserId(user.userId),
                                builder: (context, snapshot) {
                                  if(snapshot.hasData){
                                    initialReportUser = snapshot.data!;
                                  }
                                  return _documentTile(context, 'INFORME INICIAL', '11/04/2012', 0, (){
                                    setState(() {
                                      currentPage = initialReport(context, widget.participantUser);
                                    });
                                  }, () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MyInitialReport(
                                                user: user,
                                                initialReport: initialReportUser,
                                              )),
                                    );
                                  });
                                }
                              ),
                            if(user.closureReportId != null)
                              _documentTile(context, 'INFORME DE CIERRE', '23/07/2012', 1, (){
                                setState(() {
                                  currentPage = closureReport(context, widget.participantUser);
                                });
                              }, (){}),
                          ]
                      )
                    ]
                ),
              )
          );
        }
    );
  }

  Widget _buildHeaderDesktop(VoidCallback onTap) {
    return Padding(
        padding: EdgeInsets.only(
            left: 50.0, top: 15.0, bottom: 15.0, right: 40),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextBoldTitle(
                  title: StringConst.PERSONAL_DOCUMENTATION.toUpperCase()),
              Row(
                  children: [
                    InkWell(
                      child: Row(
                        children: [
                          ///TODO make selector
                          Icon(
                            Icons.add_circle_outlined,
                            color: AppColors.turquoiseBlue,
                            size: 24,
                          ),
                        ],
                      ),
                      onTap: onTap,
                    )
                  ]
              ),
            ]
        )
    );
  }

  Widget _buildHeaderMobile(VoidCallback onTap) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextBoldTitle(
                  title: StringConst.PERSONAL_DOCUMENTATION.toUpperCase()),
              SpaceH8(),
              InkWell(
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
              ),
            ]
        )
    );
  }

  Widget _documentTile(BuildContext context, String title, String date, int order, VoidCallback onView, VoidCallback onDownload) {
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
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: GoogleFonts
                      .inter()
                      .fontFamily,
                  fontWeight: FontWeight.w500,
                  fontSize: Responsive.isDesktop(context) ? 16 : 12,
                  color: AppColors.chatDarkGray,
                ),
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
                IconButton(
                  icon: Image.asset(
                    ImagePath.PERSONAL_DOCUMENTATION_DOWNLOAD,
                    width: 20,
                    height: 20,
                  ),
                  onPressed: onDownload
                ),
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
