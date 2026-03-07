import 'package:enreda_empresas/app/models/ipilCoordination.dart';
import 'package:enreda_empresas/app/models/ipilDigitalSkills.dart';
import 'package:enreda_empresas/app/models/ipilEconomicBag.dart';
import 'package:enreda_empresas/app/models/ipilImprovementEmployment.dart';
import 'package:enreda_empresas/app/models/ipilIntermediations.dart';
import 'package:enreda_empresas/app/models/ipilLaborSkills.dart';
import 'package:enreda_empresas/app/models/ipilLegal.dart';
import 'package:enreda_empresas/app/models/ipilObtainingEmployment.dart';
import 'package:enreda_empresas/app/models/ipilPostWorkSupport.dart';
import 'package:enreda_empresas/app/models/ipilSoftSkills.dart';
import 'package:enreda_empresas/app/models/ipilSpecificSkills.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/values/values.dart';

import '../../../../common_widgets/spaces.dart';
import '../../../../models/ipilConnectionTerritory.dart';
import '../../../../models/ipilContextualization.dart';
import '../../../../models/ipilEntry.dart';
import '../../../../models/ipilInterviews.dart';
import '../../../../models/ipilReinforcement.dart';
import '../../../../utils/responsive.dart';
import '../../../../values/strings.dart';

class IpilEntryTile extends StatelessWidget {
  const IpilEntryTile({
    Key? key,
    required this.ipilEntry,
    required this.techNameComplete
  }) : super(key: key);
    final IpilEntry ipilEntry;
    final String? techNameComplete;

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    String dateEntry = formatter.format(ipilEntry.date);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20,),
        Flex(
          direction: Responsive.isMobile(context) ? Axis.vertical : Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextBold(title: StringConst.DATE, color: AppColors.primary900),
                Container(
                  padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.greyTxtAlt.withOpacity(0.5), width: 1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: CustomTextSmall(text: dateEntry)),
              ],
            ),
            SizedBox(width: 20, height: 10,),
            techNameComplete == null ? Container() : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextBold(title: StringConst.TECHNICAL_NAME, color: AppColors.primary900),
                Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.greyTxtAlt.withOpacity(0.5), width: 1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: CustomTextSmall(text: techNameComplete!)),
              ],
            ),
          ],
        ),
        ipilEntry.content == null ? Container() :
        CustomTextBold(title: StringConst.IPIL_FOLLOW, color: AppColors.primary900, padding: EdgeInsets.only(top: 16),),
        ipilEntry.content == null ? Container() : CustomTextSmall(text: ipilEntry.content!),
        ipilEntry.specificSkills == null || ipilEntry.specificSkills!.isEmpty
          ? Container()
          : CustomTextBold(
              title: StringConst.IPIL_SPECIFIC_SKILLS,
              color: AppColors.primary900,
              padding: EdgeInsets.only(top: 16),
            ),

        StreamBuilder<List<IpilSpecificSkills>>(
          stream: database.ipilSpecificSkillsStreamByUser(ipilEntry.specificSkills ?? []),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Container();
            if (snapshot.hasData) {
              List<IpilSpecificSkills> userSpecificSkills = snapshot.data!;
              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: userSpecificSkills.map((e) {
                  return CustomTextSmall(text: e.label);
                }).toList(),
              );
            }
            return Container();
          }
        ),
        ipilEntry.softSkills == null || ipilEntry.softSkills!.isEmpty
          ? Container()
          : CustomTextBold(
              title: StringConst.IPIL_SOFT_SKILLS,
              color: AppColors.primary900,
              padding: EdgeInsets.only(top: 16),
            ),

        StreamBuilder<List<IpilSoftSkills>>(
          stream: database.ipilSoftSkillsStreamByUser(ipilEntry.softSkills ?? []),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Container();
            if (snapshot.hasData) {
              List<IpilSoftSkills> userSoftSkills = snapshot.data!;
              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: userSoftSkills.map((e) {
                  return CustomTextSmall(text: e.label);
                }).toList(),
              );
            }
            return Container();
          }
        ),
        ipilEntry.digitalSkills == null || ipilEntry.digitalSkills!.isEmpty
          ? Container()
          : CustomTextBold(
              title: StringConst.IPIL_DIGITAL_SKILLS,
              color: AppColors.primary900,
              padding: EdgeInsets.only(top: 16),
            ),

        StreamBuilder<List<IpilDigitalSkills>>(
          stream: database.ipilDigitalSkillsStreamByUser(ipilEntry.digitalSkills ?? []),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Container();
            if (snapshot.hasData) {
              List<IpilDigitalSkills> userDigitalSkills = snapshot.data!;
              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: userDigitalSkills.map((e) {
                  return CustomTextSmall(text: e.label);
                }).toList(),
              );
            }
            return Container();
          }
        ),
        ipilEntry.laborSkills == null || ipilEntry.laborSkills!.isEmpty
          ? Container()
          : CustomTextBold(
              title: StringConst.IPIL_LABOR_SKILLS,
              color: AppColors.primary900,
              padding: EdgeInsets.only(top: 16),
            ),

        StreamBuilder<List<IpilLaborSkills>>(
          stream: database.ipilLaborSkillsStreamByUser(ipilEntry.laborSkills ?? []),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Container();
            if (snapshot.hasData) {
              List<IpilLaborSkills> userLaborSkills = snapshot.data!;
              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: userLaborSkills.map((e) {
                  return CustomTextSmall(text: e.label);
                }).toList(),
              );
            }
            return Container();
          }
        ),
        ipilEntry.contextualization!.isEmpty ? Container() :
        CustomTextBold(title: StringConst.IPIL_CONTEXTUALIZATION, color: AppColors.primary900, padding: EdgeInsets.only(top: 16),),
        StreamBuilder<List<IpilContextualization>>(
            stream: database.ipilContextualizationStreamByUser(ipilEntry.contextualization ?? []),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();
              if (snapshot.hasData){
                List<IpilContextualization> userContextualization =  snapshot.data!;
                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: userContextualization.map((e) {
                    return CustomTextSmall(text:e.label);
                  }).toList(),
                );
              }
              return Container();
            }
        ),
        ipilEntry.connectionTerritory!.isEmpty ? Container() :
        CustomTextBold(title: StringConst.IPIL_CONNECTION_TERRITORY, color: AppColors.primary900, padding: EdgeInsets.only(top: 16),),
        StreamBuilder<List<IpilConnectionTerritory>>(
            stream: database.ipilConnectionTerritoryStreamByUser(ipilEntry.connectionTerritory ?? []),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();
              if (snapshot.hasData){
                List<IpilConnectionTerritory> userContextualization =  snapshot.data!;
                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: userContextualization.map((e) {
                    return CustomTextSmall(text:e.label);
                  }).toList(),
                );
              }
              return Container();
            }
        ),
        ipilEntry.intermediations!.isEmpty ? Container() :
        CustomTextBold(title: StringConst.IPIL_INTERMEDIATIONS, color: AppColors.primary900, padding: EdgeInsets.only(top: 16),),
        StreamBuilder<List<IpilIntermediations>>(
            stream: database.ipilIntermediationsStreamByUser(ipilEntry.intermediations ?? []),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();
              if (snapshot.hasData){
                List<IpilIntermediations> userIntermediations =  snapshot.data!;
                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: userIntermediations.map((e) {
                    return CustomTextSmall(text:e.label);
                  }).toList(),
                );
              }
              return Container();
            }
        ),
        ipilEntry.interviews!.isEmpty ? Container() :
        CustomTextBold(title: StringConst.IPIL_INTERVIEWS, color: AppColors.primary900, padding: EdgeInsets.only(top: 16),),
        StreamBuilder<List<IpilInterviews>>(
            stream: database.ipilInterviewsStreamByUser(ipilEntry.interviews ?? []),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();
              if (snapshot.hasData){
                List<IpilInterviews> userInterviews =  snapshot.data!;
                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: userInterviews.map((e) {
                    return CustomTextSmall(text:e.label);
                  }).toList(),
                );
              }
              return Container();
            }
        ),
        ipilEntry.obtainingEmployment!.isEmpty ? Container() :
        CustomTextBold(title: StringConst.IPIL_OBTAINING_EMPLOYMENT, color: AppColors.primary900, padding: EdgeInsets.only(top: 16),),
        StreamBuilder<List<IpilObtainingEmployment>>(
            stream: database.ipilObtainingEmploymentStreamByUser(ipilEntry.obtainingEmployment ?? []),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();
              if (snapshot.hasData){
                List<IpilObtainingEmployment> userObtainingEmployment =  snapshot.data!;
                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: userObtainingEmployment.map((e) {
                    return CustomTextSmall(text:e.label);
                  }).toList(),
                );
              }
              return Container();
            }
        ),
        ipilEntry.improvingEmployment!.isEmpty ? Container() :
        CustomTextBold(title: StringConst.IPIL_IMPROVING_EMPLOYMENT, color: AppColors.primary900, padding: EdgeInsets.only(top: 16),),
        StreamBuilder<List<IpilImprovingEmployment>>(
            stream: database.ipilImprovingEmploymentStreamByUser(ipilEntry.improvingEmployment ?? []),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();
              if (snapshot.hasData){
                List<IpilImprovingEmployment> userImprovingEmployment =  snapshot.data!;
                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: userImprovingEmployment.map((e) {
                    return CustomTextSmall(text:e.label);
                  }).toList(),
                );
              }
              return Container();
            }
        ),
        ipilEntry.coordination!.isEmpty ? Container() :
        CustomTextBold(title: StringConst.IPIL_COORDINATION, color: AppColors.primary900, padding: EdgeInsets.only(top: 16),),
        StreamBuilder<List<IpilCoordination>>(
            stream: database.ipilCoordinationStreamByUser(ipilEntry.coordination ?? []),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();
              if (snapshot.hasData){
                List<IpilCoordination> userCoordination =  snapshot.data!;
                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: userCoordination.map((e) {
                    return CustomTextSmall(text:e.label);
                  }).toList(),
                );
              }
              return Container();
            }
        ),
        ipilEntry.legal!.isEmpty ? Container() :
        CustomTextBold(title: StringConst.IPIL_LEGAL, color: AppColors.primary900, padding: EdgeInsets.only(top: 16),),
        StreamBuilder<List<IpilLegal>>(
            stream: database.ipilLegalStreamByUser(ipilEntry.legal ?? []),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();
              if (snapshot.hasData){
                List<IpilLegal> userLegal =  snapshot.data!;
                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: userLegal.map((e) {
                    return CustomTextSmall(text:e.label);
                  }).toList(),
                );
              }
              return Container();
            }
        ),
        ipilEntry.postWorkSupport == null || ipilEntry.postWorkSupport!.isEmpty ? Container() :
        CustomTextBold(title: StringConst.IPIL_POST_WORK_SUPPORT, color: AppColors.primary900, padding: EdgeInsets.only(top: 16),),
        StreamBuilder<List<IpilPostWorkSupport>>(
            stream: database.ipilPostWorkSupportStreamByUser(ipilEntry.postWorkSupport ?? []),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();
              if (snapshot.hasData){
                List<IpilPostWorkSupport> userPostWorkSupport =  snapshot.data!;
                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: userPostWorkSupport.map((e) {
                    return CustomTextSmall(text:e.label);
                  }).toList(),
                );
              }
              return Container();
            }
        ),
        ipilEntry.economicBag == null || ipilEntry.economicBag!.isEmpty ? Container() :
        CustomTextBold(title: StringConst.IPIL_ECONOMIC_BAG, color: AppColors.primary900, padding: EdgeInsets.only(top: 16),),
        StreamBuilder<List<IpilEconomicBag>>(
            stream: database.ipilEconomicBagStreamByUser(ipilEntry.economicBag ?? []),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();
              if (snapshot.hasData){
                List<IpilEconomicBag> userEconomicBag =  snapshot.data!;
                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: userEconomicBag.map((e) {
                    return CustomTextSmall(text:e.label);
                  }).toList(),
                );
              }
              return Container();
            }
        ),
        SpaceH50(),
      ],
    );
  }


}