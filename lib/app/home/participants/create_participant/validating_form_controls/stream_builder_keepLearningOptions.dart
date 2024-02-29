import 'package:enreda_empresas/app/models/keepLearningOption.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:flutter/material.dart';
import 'package:enreda_empresas/app/models/interest.dart';
import 'package:provider/provider.dart';

import 'multi_select_button.dart';

Widget streamBuilderDropdownKeepLearningOptions (BuildContext context, Set<KeepLearningOption> selectedInterests) {
  final database = Provider.of<Database>(context, listen: false);
  return StreamBuilder<List<KeepLearningOption>>(
      stream: database.keepLearningOptionsStream(),
      builder: (context, snapshotInterests){

        List<MultiSelectDialogItem<KeepLearningOption>> options = [];
        if (snapshotInterests.hasData) {
          options = snapshotInterests.data!.map( (KeepLearningOption option) =>
              MultiSelectDialogItem<KeepLearningOption>(
                  option,
                  option.title,
              ))
              .toList();
        }

        return MultiSelectDialog<KeepLearningOption>(
          items: options,
          initialSelectedValues: selectedInterests,
        );
      });
}