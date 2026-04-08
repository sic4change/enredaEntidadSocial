import 'package:enreda_empresas/app/models/ability.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:flutter/material.dart';

import 'multi_select_button.dart';

Widget streamBuilderDropdownAbilities (BuildContext context, Set<Ability> selectedAbilities) {
  final abilityItems = LocationCache.instance.abilities
      .map((Ability ability) => MultiSelectDialogItem<Ability>(ability, ability.name))
      .toList();

  return MultiSelectDialog<Ability>(
    items: abilityItems,
    initialSelectedValues: selectedAbilities,
  );
}