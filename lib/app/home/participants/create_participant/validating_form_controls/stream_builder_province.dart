import 'package:enreda_empresas/app/models/country.dart';
import 'package:enreda_empresas/app/models/province.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


Widget streamBuilderForProvince (BuildContext context, Country? selectedCountry, Province? selectedProvince,  functionToWriteBackThings ) {
  final database = Provider.of<Database>(context, listen: false);
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);
  return StreamBuilder<List<Province>>(
      stream: database.provincesCountryStream(selectedCountry?.countryId),
      builder: (context, snapshotProvinces) {

        List<DropdownMenuItem<Province>> provinceItems = [];
        if (snapshotProvinces.hasData && selectedCountry != null) {
          provinceItems = snapshotProvinces.data!.map((Province p) =>
              DropdownMenuItem<Province>(
                value: p,
                child: Text(p.name),
              )
          ).toList();
        }

        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  StringConst.FORM_PROVINCE,
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
                  value: selectedProvince,
                  items: provinceItems,
                  onChanged: (value) => functionToWriteBackThings(value),
                  validator: (value) => selectedProvince != null ?
                    null : StringConst.PROVINCE_ERROR,
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
  );
}

// import 'package:enreda_empresas/app/models/country.dart';
// import 'package:enreda_empresas/app/models/region.dart';
// import 'package:enreda_empresas/app/services/database.dart';
// import 'package:enreda_empresas/app/utils/adaptative.dart';
// import 'package:enreda_empresas/app/values/strings.dart';
// import 'package:enreda_empresas/app/values/values.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
//
// Widget streamBuilderForProvince (BuildContext context, Country? selectedCountry, Region? selectedProvince,  functionToWriteBackThings ) {
//   final database = Provider.of<Database>(context, listen: false);
//   TextTheme textTheme = Theme.of(context).textTheme;
//   double fontSize = responsiveSize(context, 14, 16, md: 15);
//   return StreamBuilder<List<Region>>(
//       stream: selectedCountry != null ? database.regionStreamByCountry(selectedCountry.countryId) : null,
//       builder: (context, snapshotProvinces) {
//
//         List<DropdownMenuItem<Region>> provinceItems = [];
//         if (snapshotProvinces.hasData) {
//           provinceItems = snapshotProvinces.data!.map((Region p) =>
//               DropdownMenuItem<Region>(
//                 value: p,
//                 child: Text(p.name),
//               )
//           ).toList();
//         }
//
//         return DropdownButtonFormField<Region>(
//           hint: Text(StringConst.FORM_PROVINCE),
//           isExpanded: true,
//           value: selectedProvince,
//           items: provinceItems,
//           validator: (value) => selectedProvince != null ? null : StringConst.PROVINCE_ERROR,
//           onChanged: selectedCountry != null ? (value) => functionToWriteBackThings(value) : null,
//           iconDisabledColor: AppColors.greyDark,
//           iconEnabledColor: AppColors.primaryColor,
//           decoration: InputDecoration(
//             labelStyle: textTheme.button?.copyWith(
//               height: 1.5,
//               color: AppColors.greyDark,
//               fontWeight: FontWeight.w400,
//               fontSize: fontSize,
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(5.0),
//               borderSide: BorderSide(
//                 color: AppColors.greyUltraLight,
//               ),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(5.0),
//               borderSide: BorderSide(
//                 color: AppColors.greyUltraLight,
//                 width: 1.0,
//               ),
//             ),
//           ),
//           style: textTheme.button?.copyWith(
//             height: 1.5,
//             fontWeight: FontWeight.w400,
//             color: AppColors.greyDark,
//             fontSize: fontSize,
//           ),
//         );
//       }
//   );
// }

