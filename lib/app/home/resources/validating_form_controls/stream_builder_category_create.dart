import 'package:enreda_empresas/app/models/resourceCategory.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:flutter/material.dart';
import '../../../values/strings.dart';
import '../../../values/values.dart';

Widget streamBuilderDropdownResourceCategoryCreate (BuildContext context, ResourceCategory? selectedResourceCategory,  functionToWriteBackThings ) {
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);

  final resourceCategoryItems = LocationCache.instance.resourceCategories.map((ResourceCategory resourceCategory) {
    return DropdownMenuItem<ResourceCategory>(
      value: resourceCategory,
      child: Text(resourceCategory.name),
    );
  }).toList();

  return DropdownButtonFormField<ResourceCategory>(
    hint: const Text(StringConst.FORM_RESOURCE_CATEGORY),
    value: selectedResourceCategory,
    items: resourceCategoryItems,
    validator: (value) => selectedResourceCategory != null ? null : StringConst.FORM_MOTIVATION_ERROR,
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
        borderSide: BorderSide(color: AppColors.greyUltraLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: BorderSide(color: AppColors.greyUltraLight, width: 1.0),
      ),
    ),
    style: textTheme.bodySmall?.copyWith(
      height: 1.5,
      color: AppColors.greyDark,
      fontWeight: FontWeight.w400,
      fontSize: fontSize,
    ),
  );
}
