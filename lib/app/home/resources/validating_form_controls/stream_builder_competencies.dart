import 'package:enreda_empresas/app/models/competency.dart';
import 'package:enreda_empresas/app/models/competencySubCategory.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/database.dart';
import 'multi_select_list_button.dart';

Widget streamBuilderDropdownCompetencies (BuildContext context, Set<CompetencySubCategory> selectedCompetenciesSubCategories, Set<Competency> selectedCompetencies) {
  final database = Provider.of<Database>(context, listen: false);
  Set<List<MultiSelectDialogItem<Competency>>> competenciesSet = {};
  List<MultiSelectDialogItem<Competency>> competenciesItems = [];
  if (selectedCompetenciesSubCategories.isNotEmpty)
    return ListView(
      children: <Widget> [
        for (var competencySubCategory in selectedCompetenciesSubCategories) ...[
          Center(
              child: StreamBuilder<List<Competency>>(
                  stream: database.competenciesBySubCategoryId(competencySubCategory.competencySubCategoryId),
                  builder: (context, snapshot){
                    if (snapshot.hasData) {
                      competenciesItems = snapshot.data!.map((Competency competency) =>
                          MultiSelectDialogItem<Competency>(
                              competency,
                              competency.name,
                              competencySubCategory.name
                          ))
                          .toList();
                    }
                    if (competenciesItems.length > 0) competenciesSet.add(competenciesItems);
                    if(competenciesSet.length == selectedCompetenciesSubCategories.length){
                      return MultiSelectListDialog<Competency>(
                        itemsSet: competenciesSet,
                        initialSelectedValuesSet: selectedCompetencies,
                      );
                    }
                    return Container();
                  })
          )
        ]
      ],
    );
  return AlertDialog(
    content: Text(StringConst.FORM_SUB_CATEGORIES_EMPTY),
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