import 'package:enreda_empresas/app/models/competencyCategory.dart';
import 'package:enreda_empresas/app/models/competencySubCategory.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/database.dart';
import 'multi_select_list_button.dart';

Widget streamBuilderDropdownCompetenciesSubCategories (BuildContext context, Set<CompetencyCategory> selectedCompetenciesCategories, Set<CompetencySubCategory> selectedCompetencySubCategory) {
  final database = Provider.of<Database>(context, listen: false);
  Set<List<MultiSelectDialogItem<CompetencySubCategory>>> competencySubCategoriesSet = {};
  List<MultiSelectDialogItem<CompetencySubCategory>> competencySubCategoriesItems = [];
  if (selectedCompetenciesCategories.isNotEmpty)
    return ListView(
      children: <Widget> [
        for (var competencyCategory in selectedCompetenciesCategories) ...[
          Center(
              child: StreamBuilder<List<CompetencySubCategory>>(
                  stream: database.subCategoriesCompetenciesById(competencyCategory.competencyCategoryId),
                  builder: (context, snapshotSpecificInterests){
                    if (snapshotSpecificInterests.hasData) {
                      competencySubCategoriesItems = snapshotSpecificInterests.data!.map((CompetencySubCategory competencySubCategory) =>
                          MultiSelectDialogItem<CompetencySubCategory>(
                              competencySubCategory,
                              competencySubCategory.name,
                              competencyCategory.name
                          ))
                          .toList();
                    }
                    if (competencySubCategoriesItems.length > 0) competencySubCategoriesSet.add(competencySubCategoriesItems);
                    if(competencySubCategoriesSet.length == selectedCompetenciesCategories.length){
                      return MultiSelectListDialog<CompetencySubCategory>(
                        itemsSet: competencySubCategoriesSet,
                        initialSelectedValuesSet: selectedCompetencySubCategory,
                      );
                    }
                    return Container();
                  })
          )
        ]
      ],
    );
  return AlertDialog(
    content: Text(StringConst.FORM_CATEGORIES_EMPTY),
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