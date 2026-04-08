import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/values/values.dart';

import '../../../../common_widgets/spaces.dart';
import '../../../../models/ipilEntry.dart';
import '../../../../utils/responsive.dart';
import '../../../../values/strings.dart';

class IpilEntryTile extends StatelessWidget {
  const IpilEntryTile({
    Key? key,
    required this.ipilEntry,
    required this.techNameComplete,
    this.onDelete,
  }) : super(key: key);
  final IpilEntry ipilEntry;
  final String? techNameComplete;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    String dateEntry = formatter.format(ipilEntry.lastUpdateDate!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        if (onDelete != null)
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: onDelete,
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.delete, color: AppColors.deleteRed, size: 22),
              ),
            ),
          ),
        Flex(
          direction: Responsive.isMobile(context) ? Axis.vertical : Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Row(
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
                        child: CustomTextSmall(text: dateEntry),
                      ),
                    ],
                  ),
                  SizedBox(width: 20, height: 10),
                  if (techNameComplete != null)
                    Column(
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
                          child: CustomTextSmall(text: techNameComplete!),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
        _labelSection(StringConst.IPIL_FOLLOW, ipilEntry.content),
        _labelSection(StringConst.IPIL_SPECIFIC_SKILLS, ipilEntry.specificSkillsText),
        _labelSection(StringConst.IPIL_SOFT_SKILLS, ipilEntry.softSkillsText),
        _labelSection(StringConst.IPIL_DIGITAL_SKILLS, ipilEntry.digitalSkillsText),
        _labelSection(StringConst.IPIL_LABOR_SKILLS, ipilEntry.laborSkillsText),
        _labelSection(StringConst.IPIL_CONTEXTUALIZATION, ipilEntry.contextualizationText),
        _labelSection(StringConst.IPIL_CONNECTION_TERRITORY, ipilEntry.connectionTerritoryText),
        _labelSection(StringConst.IPIL_INTERMEDIATIONS, ipilEntry.intermediationsText),
        _labelSection(StringConst.IPIL_INTERVIEWS, ipilEntry.interviewsText),
        _labelSection(StringConst.IPIL_OBTAINING_EMPLOYMENT, ipilEntry.obtainingEmploymentText),
        _labelSection(StringConst.IPIL_IMPROVING_EMPLOYMENT, ipilEntry.improvingEmploymentText),
        _labelSection(StringConst.IPIL_COORDINATION, ipilEntry.coordinationText),
        _labelSection(StringConst.IPIL_LEGAL, ipilEntry.legalText),
        _labelSection(StringConst.IPIL_POST_WORK_SUPPORT, ipilEntry.postWorkSupportText),
        _labelSection(StringConst.IPIL_ECONOMIC_BAG, ipilEntry.economicBagText),
        if (ipilEntry.reinforcement?.isNotEmpty == true)
          _labelSection('Refuerzo', ipilEntry.reinforcementsText),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _labelSection(String title, String? text) {
    if (text == null || text.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextBold(title: title, color: AppColors.primary900),
          CustomTextSmall(text: text),
        ],
      ),
    );
  }
}
