import 'package:enreda_empresas/app/common_widgets/alert_dialog.dart';
import 'package:enreda_empresas/app/models/ipilCoordination.dart';
import 'package:enreda_empresas/app/models/ipilImprovementEmployment.dart';
import 'package:enreda_empresas/app/models/ipilObtainingEmployment.dart';
import 'package:enreda_empresas/app/models/ipilPostWorkSupport.dart';
import 'package:enreda_empresas/app/models/personalDocumentType.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/values/values.dart';

import '../../../../common_widgets/spaces.dart';
import '../../../../models/documentCategory.dart';
import '../../../../models/ipilConnectionTerritory.dart';
import '../../../../models/ipilContextualization.dart';
import '../../../../models/ipilEntry.dart';
import '../../../../models/ipilInterviews.dart';
import '../../../../models/ipilReinforcement.dart';
import '../../../../utils/responsive.dart';
import '../../../../values/strings.dart';

class DocumentCategoryTile extends StatelessWidget {
  const DocumentCategoryTile({
    Key? key,
    required this.documentCategory,
  }) : super(key: key);
  final DocumentCategory documentCategory;

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20,),
        StreamBuilder<List<PersonalDocumentType>>(
            stream: database.personalDocumentTypeByIdStream(documentCategory.documentCategoryId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();
              if (snapshot.hasData){
                List<PersonalDocumentType> personalDocTypeByCategoryList =  snapshot.data!;
                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: personalDocTypeByCategoryList.map((e) {
                    return InkWell(
                        onTap: () {
                          showAlertDialog(
                            context,
                            title: 'Aviso',
                            content: 'El Informe Inicial aún no se ha completado.',
                            defaultActionText: 'Aceptar',
                          );
                        },
                        child: CustomTextSmall(text:e.title));
                  }).toList(),
                );
              }
              return Container();
            }
        ),
        // ipilEntry.contextualization!.isEmpty ? Container() :
        // CustomTextBold(title: StringConst.IPIL_CONTEXTUALIZATION, color: AppColors.primary900, padding: EdgeInsets.only(top: 16),),
        // StreamBuilder<List<IpilContextualization>>(
        //     stream: database.ipilContextualizationStreamByUser(ipilEntry.contextualization ?? []),
        //     builder: (context, snapshot) {
        //       if (!snapshot.hasData) return Container();
        //       if (snapshot.hasData){
        //         List<IpilContextualization> userContextualization =  snapshot.data!;
        //         return ListView(
        //           shrinkWrap: true,
        //           physics: const NeverScrollableScrollPhysics(),
        //           children: userContextualization.map((e) {
        //             return CustomTextSmall(text:e.label);
        //           }).toList(),
        //         );
        //       }
        //       return Container();
        //     }
        // ),
        // ipilEntry.connectionTerritory!.isEmpty ? Container() :
        // CustomTextBold(title: StringConst.IPIL_CONNECTION_TERRITORY, color: AppColors.primary900, padding: EdgeInsets.only(top: 16),),
        // StreamBuilder<List<IpilConnectionTerritory>>(
        //     stream: database.ipilConnectionTerritoryStreamByUser(ipilEntry.connectionTerritory ?? []),
        //     builder: (context, snapshot) {
        //       if (!snapshot.hasData) return Container();
        //       if (snapshot.hasData){
        //         List<IpilConnectionTerritory> userContextualization =  snapshot.data!;
        //         return ListView(
        //           shrinkWrap: true,
        //           physics: const NeverScrollableScrollPhysics(),
        //           children: userContextualization.map((e) {
        //             return CustomTextSmall(text:e.label);
        //           }).toList(),
        //         );
        //       }
        //       return Container();
        //     }
        // ),
        // ipilEntry.interviews!.isEmpty ? Container() :
        // CustomTextBold(title: StringConst.IPIL_INTERVIEWS, color: AppColors.primary900, padding: EdgeInsets.only(top: 16),),
        // StreamBuilder<List<IpilInterviews>>(
        //     stream: database.ipilInterviewsStreamByUser(ipilEntry.interviews ?? []),
        //     builder: (context, snapshot) {
        //       if (!snapshot.hasData) return Container();
        //       if (snapshot.hasData){
        //         List<IpilInterviews> userContextualization =  snapshot.data!;
        //         return ListView(
        //           shrinkWrap: true,
        //           physics: const NeverScrollableScrollPhysics(),
        //           children: userContextualization.map((e) {
        //             return CustomTextSmall(text:e.label);
        //           }).toList(),
        //         );
        //       }
        //       return Container();
        //     }
        // ),
        // ipilEntry.obtainingEmployment == null || ipilEntry.obtainingEmployment!.isEmpty ? Container() :
        // CustomTextBold(title: StringConst.IPIL_OBTAINING_EMPLOYMENT, color: AppColors.primary900, padding: EdgeInsets.only(top: 16),),
        // StreamBuilder<IpilObtainingEmployment>(
        //     stream: database.ipilObtainingEmploymentStreamByUser(ipilEntry.obtainingEmployment ?? ""),
        //     builder: (context, snapshot) {
        //       if (!snapshot.hasData) return Container();
        //       if (snapshot.hasData){
        //         IpilObtainingEmployment obtainingEmployment =  snapshot.data!;
        //         return CustomTextSmall(text: obtainingEmployment.label);
        //       }
        //       return Container();
        //     }
        // ),
        // ipilEntry.improvingEmployment == null || ipilEntry.improvingEmployment!.isEmpty ? Container() :
        // CustomTextBold(title: StringConst.IPIL_IMPROVING_EMPLOYMENT, color: AppColors.primary900, padding: EdgeInsets.only(top: 16),),
        // StreamBuilder<IpilImprovingEmployment>(
        //     stream: database.ipilImprovingEmploymentStreamByUser(ipilEntry.improvingEmployment ?? ""),
        //     builder: (context, snapshot) {
        //       if (!snapshot.hasData) return Container();
        //       if (snapshot.hasData){
        //         IpilImprovingEmployment improvingEmployment =  snapshot.data!;
        //         return CustomTextSmall(text: improvingEmployment.label);
        //       }
        //       return Container();
        //     }
        // ),
        // ipilEntry.coordination == null || ipilEntry.coordination!.isEmpty ? Container() :
        // CustomTextBold(title: StringConst.IPIL_COORDINATION, color: AppColors.primary900, padding: EdgeInsets.only(top: 16),),
        // StreamBuilder<IpilCoordination>(
        //     stream: database.ipilCoordinationStreamByUser(ipilEntry.coordination ?? ""),
        //     builder: (context, snapshot) {
        //       if (!snapshot.hasData) return Container();
        //       if (snapshot.hasData){
        //         IpilCoordination coordination =  snapshot.data!;
        //         return CustomTextSmall(text: coordination.label);
        //       }
        //       return Container();
        //     }
        // ),
        // ipilEntry.postWorkSupport == null || ipilEntry.postWorkSupport!.isEmpty ? Container() :
        // CustomTextBold(title: StringConst.IPIL_POST_WORK_SUPPORT, color: AppColors.primary900, padding: EdgeInsets.only(top: 16),),
        // StreamBuilder<IpilPostWorkSupport>(
        //     stream: database.ipilPostWorkSupportStreamByUser(ipilEntry.postWorkSupport ?? ""),
        //     builder: (context, snapshot) {
        //       if (!snapshot.hasData) return Container();
        //       if (snapshot.hasData){
        //         IpilPostWorkSupport postWorkSupport =  snapshot.data!;
        //         return CustomTextSmall(text: postWorkSupport.label);
        //       }
        //       return Container();
        //     }
        // ),
        SpaceH20(),
      ],
    );
  }


}