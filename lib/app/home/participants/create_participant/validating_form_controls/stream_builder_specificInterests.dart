import 'package:enreda_empresas/app/models/interest.dart';
import 'package:enreda_empresas/app/models/specificinterest.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'multi_select_list_button.dart';

Widget streamBuilderDropdownSpecificInterests (BuildContext context, Set<Interest> selectedInterests, Set<SpecificInterest> selectedSpecificInterests) {
  if (selectedInterests.isEmpty) {
    return AlertDialog(
      content: Text(StringConst.FORM_INTEREST_EMPTY),
      actions: <Widget>[
        ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(StringConst.FORM_ACCEPT, style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold))
        ),
      ],
    );
  }

  final allSpecificInterests = LocationCache.instance.specificInterests;
  Set<List<MultiSelectDialogItem<SpecificInterest>>> specificInterestSet = {};

  for (var interest in selectedInterests) {
    final matchingSpecificInterests = allSpecificInterests.where((s) => s.interestId == interest.interestId).toList();
    if (matchingSpecificInterests.isNotEmpty) {
      final specificInterestItems = matchingSpecificInterests.map((specificInterest) =>
          MultiSelectDialogItem<SpecificInterest>(
              specificInterest,
              specificInterest.name,
              interest.name
          ))
          .toList();
      specificInterestSet.add(specificInterestItems);
    }
  }

  return MultiSelectListDialog<SpecificInterest>(
    itemsSet: specificInterestSet,
    initialSelectedValuesSet: selectedSpecificInterests,
  );
}