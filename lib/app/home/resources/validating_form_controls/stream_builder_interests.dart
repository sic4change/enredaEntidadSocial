import 'package:enreda_empresas/app/home/resources/validating_form_controls/multi_select_button.dart';
import 'package:enreda_empresas/app/models/interest.dart';
import 'package:enreda_empresas/app/models/resource.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:flutter/material.dart';

Widget streamBuilderDropdownInterests (BuildContext context, List<String>selectedInterestsIdList, Set<Interest> selectedInterests, Resource? resource) {
  final allInterests = LocationCache.instance.interests;

  final interestItems = allInterests.map((Interest interest) {
    if (selectedInterestsIdList.isEmpty && resource != null) {
      for (var interestId in resource.interests!) {
        if (interest.interestId == interestId) {
          selectedInterests.add(interest);
        }
      }
    }
    return MultiSelectDialogItem<Interest>(interest, interest.name);
  }).toList();

  return MultiSelectDialog<Interest>(
    items: interestItems,
    initialSelectedValues: selectedInterests,
  );
}
