import 'package:enreda_empresas/app/models/country.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

Widget streamBuilderForCountry (BuildContext context, Country? selectedCountry,  functionToWriteBackThings, String title ) {
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);

  final countryItems = LocationCache.instance.countries
      .map((Country c) => DropdownMenuItem<Country>(value: c, child: Text(c.name)))
      .toList();

        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  title,
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
                  value: selectedCountry,
                  items: countryItems,
                  onChanged: (value) => functionToWriteBackThings(value),
                  validator: (value) => selectedCountry != null ? null : StringConst.COUNTRY_ERROR,
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