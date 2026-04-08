import 'package:enreda_empresas/app/models/interest.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:flutter/material.dart';
import '../../../sign_up/validating_form_controls/multi_select_button.dart';

Widget streamBuilderDropdownInterestsCreate (BuildContext context, Set<Interest> selectedInterests) {
  final interestItems = LocationCache.instance.interests
      .map((Interest interest) => MultiSelectDialogItem<Interest>(interest, interest.name))
      .toList();

  return MultiSelectDialog<Interest>(
    items: interestItems,
    initialSelectedValues: selectedInterests,
  );
}
