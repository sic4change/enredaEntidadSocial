import 'package:enreda_empresas/app/models/city.dart';
import 'package:enreda_empresas/app/models/country.dart';
import 'package:enreda_empresas/app/models/province.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


Widget streamBuilderForCity (BuildContext context, Country? selectedCountry, Province? selectedProvince, City? selectedCity,  functionToWriteBackThings ) {
  final database = Provider.of<Database>(context, listen: false);
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);
  return StreamBuilder<List<City>>(
      stream: database.citiesProvinceStream(selectedProvince?.provinceId),
      builder: (context, snapshotCities){

        List<DropdownMenuItem<City>> cityItems = [];
        if (snapshotCities.hasData && selectedProvince != null) {
          cityItems = snapshotCities.data!.map((City c) =>
              DropdownMenuItem<City>(
                value: c,
                child: Text(c.name),
              )
          ).toList();
        }
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  StringConst.FORM_CITY,
                  style: textTheme.button?.copyWith(
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
                  value: selectedCity,
                  items: cityItems,
                  onChanged: (value) => functionToWriteBackThings(value),
                  validator: (value) => selectedCity != null ?
                    null : StringConst.CITY_ERROR,
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
                  style: textTheme.button?.copyWith(
                    height: 1.4,
                    color: AppColors.greyDark,
                    fontWeight: FontWeight.w400,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ]
        );
      });
}