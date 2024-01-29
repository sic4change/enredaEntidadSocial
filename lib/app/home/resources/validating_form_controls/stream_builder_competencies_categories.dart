import 'package:enreda_empresas/app/models/competencyCategory.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../sign_up/validating_form_controls/multi_select_button.dart';

Widget streamBuilderDropdownCompetenciesCategoriesCreate (BuildContext context, Set<CompetencyCategory> selectedCompetenciesCategories) {
  final database = Provider.of<Database>(context, listen: false);
  return StreamBuilder<List<CompetencyCategory>>(
      stream: database.competenciesCategoriesStream(),
      builder: (context, snapshotCompetenciesCategories){

        List<MultiSelectDialogItem<CompetencyCategory>> competenciesItems = [];
        if (snapshotCompetenciesCategories.hasData) {
          competenciesItems = snapshotCompetenciesCategories.data!.map( (CompetencyCategory competency) =>
              MultiSelectDialogItem<CompetencyCategory>(
                  competency,
                  competency.name
              ))
              .toList();
        }

        return MultiSelectDialog<CompetencyCategory>(
          items: competenciesItems,
          initialSelectedValues: selectedCompetenciesCategories,
        );
      });
}