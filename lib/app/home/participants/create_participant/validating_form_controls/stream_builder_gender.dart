import 'package:enreda_empresas/app/models/gender.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

Widget streamBuilder_Dropdown_Genders (BuildContext context, Gender? selectedGender,  functionToWriteBackThings ) {
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);

  final genderItems = LocationCache.instance.genders
      .map((Gender gender) => DropdownMenuItem<Gender>(value: gender, child: Text(gender.name)))
      .toList();

        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  StringConst.FORM_GENDER,
                  style: textTheme.bodySmall?.copyWith(
                    height: 1.5,
                    color: AppColors.greyDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                height: 50,
                child: DropdownButtonFormField(
                  value: selectedGender,
                  items: genderItems,
                  onChanged: (value) => functionToWriteBackThings(value),
                  validator: (value) => selectedGender != null ? null : StringConst.FORM_GENDER_ERROR,
                  decoration: InputDecoration(
                    errorStyle: TextStyle(height: 0.01),
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
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: AppColors.greyUltraLight,
                        width: 1.0,
                      ),
                    ),
                  ),
                  style: textTheme.bodySmall?.copyWith(
                    height: 1.4,
                    color: AppColors.greyDark,
                    fontWeight: FontWeight.w400,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ]
        );
}