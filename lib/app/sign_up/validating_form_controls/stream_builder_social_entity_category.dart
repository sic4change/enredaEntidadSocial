import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/socialEntitiesCategories.dart';
import '../../values/strings.dart';
import '../../values/values.dart';

Widget streamBuilderDropdownSocialEntityCategory (BuildContext context, SocialEntityCategory? selectedSocialEntityCategory,  functionToWriteBackThings ) {
  final database = Provider.of<Database>(context, listen: false);
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);
  return StreamBuilder<List<SocialEntityCategory>>(
      stream: database.socialEntitiesCategoriesStream(),
      builder: (context, snapshotResourceCategory){

        List<DropdownMenuItem<SocialEntityCategory>> resourceCategoryItems = [];
        if (snapshotResourceCategory.hasData) {
          resourceCategoryItems = snapshotResourceCategory.data!.map((SocialEntityCategory resourceCategory) {
            return DropdownMenuItem<SocialEntityCategory>(
              value: resourceCategory,
              child: Text(resourceCategory.name),
            );
          })
              .toList();
        }

        return DropdownButtonFormField<SocialEntityCategory>(
          value: selectedSocialEntityCategory,
          items: resourceCategoryItems,
          validator: (value) => selectedSocialEntityCategory != null ? null : StringConst.FORM_GENERIC_ERROR,
          onChanged: (value) => functionToWriteBackThings(value),
          iconDisabledColor: AppColors.greyDark,
          iconEnabledColor: AppColors.primaryColor,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelStyle: textTheme.bodySmall?.copyWith(
              height: 1.5,
              color: AppColors.greyDark,
              fontWeight: FontWeight.w400,
              fontSize: fontSize,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: BorderSide(
                color: AppColors.greyUltraLight,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: BorderSide(
                color: AppColors.greyUltraLight,
                width: 1.0,
              ),
            ),
          ),
          style: textTheme.bodySmall?.copyWith(
            height: 1.5,
            color: AppColors.greyDark,
            fontWeight: FontWeight.w400,
            fontSize: fontSize,
          ),
        );
      });
}