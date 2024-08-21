import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../values/values.dart';

Widget streamBuilderDropdownSocialEntities (BuildContext context, SocialEntity? selectedSocialEntity, String socialEntityId, functionToWriteBackThings ) {
  final database = Provider.of<Database>(context, listen: false);
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);
  return StreamBuilder<List<SocialEntity>>(
      stream: database.socialEntityByIdStream(socialEntityId),
      builder: (context, snapshotSocialEntities){

        List<DropdownMenuItem<SocialEntity>> socialEntityItems = [];
        if(snapshotSocialEntities.hasData) {
          socialEntityItems = snapshotSocialEntities.data!.map((SocialEntity socialEntity) =>
              DropdownMenuItem<SocialEntity>(
                value: socialEntity,
                child: Text(socialEntity.name),
              ))
              .toList();
        }

        return DropdownButtonFormField<SocialEntity>(
          hint: const Text(StringConst.FORM_PROMOTOR),
          isExpanded: true,
          value: selectedSocialEntity,
          items: socialEntityItems,
          validator: (value) => selectedSocialEntity != null ? null : StringConst.FORM_COMPANY_ERROR,
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
              borderSide: const BorderSide(
                color: AppColors.greyUltraLight,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: const BorderSide(
                color: AppColors.greyUltraLight,
                width: 1.0,
              ),
            ),
          ),
          style: textTheme.bodySmall?.copyWith(
            height: 1.5,
            fontWeight: FontWeight.w400,
            color: AppColors.greyDark,
            fontSize: fontSize,
          ),
        );
      });
}