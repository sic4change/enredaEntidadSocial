import 'package:cached_network_image/cached_network_image.dart';
import 'package:enreda_empresas/app/common_widgets/precached_avatar.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/models/resourcePicture.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Widget streamBuilderDropdownResourcePicture (BuildContext context, ResourcePicture? selectedResourcePicture, functionToWriteBackThings, genericType ) {
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);

  final resourcePictureItems = LocationCache.instance.resourcePictures.map((ResourcePicture resourcePicture) {
    if (selectedResourcePicture == null && resourcePicture.id == genericType.resourcePictureId) {
      selectedResourcePicture = resourcePicture;
    }
    if (selectedResourcePicture != null) {
      selectedResourcePicture = selectedResourcePicture;
    }

    return DropdownMenuItem<ResourcePicture>(
      value: resourcePicture,
      child: Row(
        children: [
          !kIsWeb
              ? ClipRRect(
                  child: resourcePicture.resourcePhoto == ""
                      ? Container(
                          color: Colors.transparent,
                          height: 35,
                          width: 35,
                          child: Image.asset(ImagePath.USER_DEFAULT),
                        )
                      : CachedNetworkImage(
                          width: 35,
                          fit: BoxFit.cover,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  Image.asset(ImagePath.IMAGE_DEFAULT),
                          alignment: Alignment.center,
                          imageUrl: resourcePicture.resourcePhoto),
                )
              : ClipRRect(
                  child: resourcePicture.resourcePhoto == ""
                      ? Container(
                          color: Colors.transparent,
                          height: 35,
                          width: 35,
                          child: Image.asset(ImagePath.IMAGE_DEFAULT),
                        )
                      : PrecacheResourcePicture(
                          imageUrl: resourcePicture.resourcePhoto,
                          width: 35,
                          height: 35,
                        ),
                ),
          const SpaceW20(),
          Text(resourcePicture.name),
        ],
      ),
    );
  }).toList();

  return DropdownButtonFormField<ResourcePicture>(
    hint: const Text(StringConst.FORM_RESOURCE_PICTURE),
    isExpanded: true,
    value: selectedResourcePicture,
    items: resourcePictureItems,
    validator: (value) => selectedResourcePicture != null ? null : StringConst.COUNTRY_ERROR,
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
