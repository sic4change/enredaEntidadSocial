import 'package:enreda_empresas/app/models/resourcetype.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:flutter/material.dart';
import '../../../values/values.dart';

Widget streamBuilderDropdownResourceTypeCreate (BuildContext context, ResourceType? selectedResourceType, functionToWriteBackThings ) {
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);

  final resourceTypeItems = LocationCache.instance.resourceTypes.map((ResourceType resourceType) {
    return DropdownMenuItem<ResourceType>(
      value: resourceType,
      child: Text(resourceType.name),
    );
  }).toList();

  return DropdownButtonFormField<ResourceType>(
    hint: const Text(StringConst.FORM_RESOURCE_TYPE),
    isExpanded: true,
    value: selectedResourceType,
    items: resourceTypeItems,
    validator: (value) => selectedResourceType != null ? null : StringConst.FORM_RESOURCE_TYPE_ERROR,
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
        borderSide: const BorderSide(color: AppColors.greyUltraLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: const BorderSide(color: AppColors.greyUltraLight, width: 1.0),
      ),
    ),
    style: textTheme.bodySmall?.copyWith(
      height: 1.5,
      fontWeight: FontWeight.w400,
      color: AppColors.greyDark,
      fontSize: fontSize,
    ),
  );
}
