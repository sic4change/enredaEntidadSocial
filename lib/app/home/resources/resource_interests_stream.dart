import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/home/resources/resource_detail_dialog.dart';
import 'package:enreda_empresas/app/models/interest.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

class InterestsByResource extends StatelessWidget {
  const InterestsByResource({super.key, required this.interestsIdList});

  final List<String?> interestsIdList;

  @override
  Widget build(BuildContext context) {
    final allInterests = LocationCache.instance.interests;
    final matched = allInterests.where((i) => interestsIdList.contains(i.interestId)).toList();

    if (matched.isEmpty) {
      return const CustomTextTitle(title: '¡El recurso aun no tiene intereses!');
    }

    return Wrap(
      children: matched.map((interest) => Container(
        key: Key('resource-${interest.interestId}'),
        margin: const EdgeInsets.only(left: 0, right: 4, top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.greyLight2.withOpacity(0.2), width: 1),
          borderRadius: BorderRadius.circular(Consts.padding),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
          child: CustomText(title: interest.name),
        ),
      )).toList(),
    );
  }
}
