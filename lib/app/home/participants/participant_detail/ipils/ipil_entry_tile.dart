import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/values/values.dart';

import '../../../../models/ipilEntry.dart';
import '../../../../services/location_cache.dart';
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
    String dateEntry = formatter.format(ipilEntry.lastUpdateDate ?? ipilEntry.date);

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
        _labelSection(StringConst.IPIL_INITIAL_ITINERARY, _checkedOptions({
          StringConst.IPIL_INITIAL_CONTACTED: ipilEntry.contactedPersonEvaluation,
          StringConst.IPIL_INITIAL_INTERVIEW: ipilEntry.initialInterview,
          StringConst.IPIL_INITIAL_QUESTIONARY: ipilEntry.initialJobValorationQuestionary,
        })),
        _labelSection(StringConst.IPIL_CLOSE_ITINERARY, _checkedOptions({
          StringConst.IPIL_CLOSE_CONTACTED_NO_INTERVENTION: ipilEntry.contactedPersonNoIntervention,
          StringConst.IPIL_CLOSE_INTERVIEW: ipilEntry.finalInterview,
          StringConst.IPIL_CLOSE_QUESTIONARY: ipilEntry.finalJobValorationQuestionary,
        })),
        if (ipilEntry.fourWeeksCheck == true || ipilEntry.sixMonthsCheck == true)
          _buildFollowUpDetail(context, ipilEntry),
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
        _labelSection(StringConst.IPIL_OTHERS, ipilEntry.other),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFollowUpDetail(BuildContext context, IpilEntry ipil) {
    final isFourWeeks = ipil.fourWeeksCheck == true;
    final situation = isFourWeeks ? ipil.fourWeeksSituation : ipil.sixMonthsSituation;
    final employmentTypeId = isFourWeeks ? ipil.fourWeeksEmploymentTypeId : ipil.sixMonthsEmploymentTypeId;
    final satisfaction = isFourWeeks ? ipil.fourWeeksSatisfaction : ipil.sixMonthsSatisfaction;
    final impact = isFourWeeks ? ipil.fourWeeksImpact : ipil.sixMonthsImpact;
    final improvement = isFourWeeks ? ipil.fourWeeksImprovement : ipil.sixMonthsImprovement;

    String employmentTypeName = '';
    if (employmentTypeId != null && employmentTypeId.isNotEmpty) {
      final interest = LocationCache.instance.interests.where((i) =>
          (i.interestId ?? i.name) == employmentTypeId || i.name == employmentTypeId).firstOrNull;
      employmentTypeName = interest?.name ?? employmentTypeId;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.primary010.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.primary100, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextBold(
            title: isFourWeeks
                ? StringConst.IPIL_FOLLOW_UP_FOUR_WEEKS
                : StringConst.IPIL_FOLLOW_UP_SIX_MONTHS,
            color: AppColors.primary900,
          ),
          if (situation != null && situation.isNotEmpty) ...[
            const SizedBox(height: 10),
            CustomTextSmallBold(title: StringConst.IPIL_FOLLOW_UP_SITUATION, color: AppColors.primary900),
            CustomTextSmall(text: situation),
          ],
          if (employmentTypeName.isNotEmpty) ...[
            const SizedBox(height: 10),
            CustomTextSmallBold(title: StringConst.IPIL_FOLLOW_UP_EMPLOYMENT_TYPE, color: AppColors.primary900),
            CustomTextSmall(text: employmentTypeName),
          ],
          if (satisfaction != null) ...[
            const SizedBox(height: 10),
            CustomTextSmallBold(title: StringConst.IPIL_FOLLOW_UP_SATISFACTION, color: AppColors.primary900),
            CustomTextSmall(text: '$satisfaction / 4'),
          ],
          if (impact != null) ...[
            const SizedBox(height: 10),
            CustomTextSmallBold(title: StringConst.IPIL_FOLLOW_UP_IMPACT, color: AppColors.primary900),
            CustomTextSmall(text: '$impact / 6'),
          ],
          if (improvement != null && improvement.isNotEmpty) ...[
            const SizedBox(height: 10),
            CustomTextSmallBold(title: StringConst.IPIL_FOLLOW_UP_IMPROVEMENT, color: AppColors.primary900),
            CustomTextSmall(text: improvement),
          ],
        ],
      ),
    );
  }

  /// Joins the labels of the checked options, one per line.
  String _checkedOptions(Map<String, bool?> options) {
    return options.entries
        .where((e) => e.value == true)
        .map((e) => e.key)
        .join('\n');
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
