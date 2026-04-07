import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget streamBuilderForNation (BuildContext context, String? selectedCountry,  functionToWriteBackThings, String title ) {
  final cache = LocationCache.instance;
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);

  // If nations are already in memory (loaded lazily on first use), render synchronously
  if (cache.nations.isNotEmpty) {
    return _buildNationDropdown(context, textTheme, fontSize, selectedCountry, cache.nations, functionToWriteBackThings, title);
  }

  // Otherwise fetch from Firestore, write back to cache, and show dropdown
  final database = Provider.of<Database>(context, listen: false);
  return StreamBuilder<List<String>>(
      stream: database.nationsSpanishStream(),
      builder: (context, snapshotCountries) {
        if (snapshotCountries.hasData && snapshotCountries.data!.isNotEmpty) {
          // Cache for subsequent uses within this session
          cache.nations = snapshotCountries.data!;
        }
        final countries = snapshotCountries.data ?? [];
        return _buildNationDropdown(context, textTheme, fontSize, selectedCountry, countries, functionToWriteBackThings, title);
      });
}

Widget _buildNationDropdown(BuildContext context, TextTheme textTheme, double fontSize, String? selectedCountry, List<String> countries, functionToWriteBackThings, String title) {
  final countryItems = countries.map((String c) =>
      DropdownMenuItem<String>(
        value: c,
        child: Text(c),
      ))
      .toList();

  if(selectedCountry == null || countries.contains(selectedCountry)) {
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
                    isExpanded: true,
                    onChanged: (value) => functionToWriteBackThings(value),
                    validator: (value) =>
                    selectedCountry != null
                        ? null
                        : StringConst.COUNTRY_ERROR,
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
        }else{
          return Container();
        }
}