import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/home/resources/resource_detail_dialog.dart';
import 'package:enreda_empresas/app/models/competency.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

class CompetenciesByResource extends StatelessWidget {
  const CompetenciesByResource({super.key, required this.competenciesIdList});

  final List<String?> competenciesIdList;

  @override
  Widget build(BuildContext context) {
    final allCompetencies = LocationCache.instance.competencies;
    final matched = allCompetencies.where((c) => competenciesIdList.contains(c.id)).toList();

    if (matched.isEmpty) {
      return const CustomTextTitle(title: '¡El recurso aun no tiene competencias!');
    }

    return Wrap(
      children: matched.map((competency) => Container(
        key: Key('resource-${competency.id}'),
        margin: const EdgeInsets.only(left: 0, right: 4, top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.greyLight2.withOpacity(0.2), width: 1),
          borderRadius: BorderRadius.circular(Consts.padding),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
          child: CustomText(title: competency.name),
        ),
      )).toList(),
    );
  }
}
