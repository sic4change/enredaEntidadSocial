import 'package:enreda_empresas/app/models/keepLearningOption.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:flutter/material.dart';

import 'multi_select_button.dart';

Widget streamBuilderDropdownKeepLearningOptions (BuildContext context, Set<KeepLearningOption> selectedKeepLearningOptions) {
  final options = LocationCache.instance.keepLearningOptions
      .map((KeepLearningOption option) => MultiSelectDialogItem<KeepLearningOption>(option, option.title))
      .toList();

  return MultiSelectDialog<KeepLearningOption>(
    items: options,
    initialSelectedValues: selectedKeepLearningOptions,
  );
}