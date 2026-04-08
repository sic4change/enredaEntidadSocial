import 'package:enreda_empresas/app/models/dedication.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

Widget streamBuilderDropdownDedication (BuildContext context, Dedication? selectedDedication,  functionToWriteBackThings ) {
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);

  final dedicationItems = LocationCache.instance.dedications
      .map((Dedication dedication) => DropdownMenuItem<Dedication>(value: dedication, child: Text(dedication.label)))
      .toList();

        return DropdownButtonFormField<Dedication>(
          hint: Text(StringConst.FORM_DEDICATION, maxLines: 2, overflow: TextOverflow.ellipsis),
          isDense: true,
          isExpanded: true,
          value: selectedDedication,
          items: dedicationItems,
          validator: (value) => selectedDedication != null ? null : StringConst.FORM_MOTIVATION_ERROR,
          onChanged: (value) => functionToWriteBackThings(value),
          iconDisabledColor: AppColors.greyDark,
          iconEnabledColor: AppColors.primaryColor,
          decoration: InputDecoration(
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
}