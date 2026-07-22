
import 'package:cached_network_image/cached_network_image.dart';
import 'package:enreda_empresas/app/models/addressUser.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/utils/functions.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

import '../../models/externalSocialEntity.dart';

class EntityListTile extends StatefulWidget {
  const EntityListTile({Key? key, required this.socialEntity, required this.onTap, this.onEdit}) : super(key: key);
  final ExternalSocialEntity? socialEntity;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  @override
  State<EntityListTile> createState() => _EntityListTileState();
}

class _EntityListTileState extends State<EntityListTile> {
  @override
  Widget build(BuildContext context) {
    return _buildEntityContainer(widget.socialEntity!);
  }

  Widget _buildEntityContainer(ExternalSocialEntity currentSocialEntity){
    String name = currentSocialEntity.name;
    String email = currentSocialEntity.email ?? '';
    String phone = currentSocialEntity.entityPhone ?? '';
    String web = currentSocialEntity.website ?? '';
    Address fullLocation = currentSocialEntity.address ?? Address();
    // Resolve city/country from the warmed LocationCache instead of opening a
    // realtime stream per tile (hundreds of listeners → reads + scroll jank).
    final cityName =
        LocationCache.instance.cityById(fullLocation.city)?.name ?? '';
    final countryName =
        LocationCache.instance.countryById(fullLocation.country)?.name ?? '';
    String location = '';
    if (countryName != '') {
      location = countryName;
    } else if (cityName != '') {
      location = cityName;
    }
    if (cityName != '' && countryName != '') {
      location = location + ', ' + cityName;
    }
    return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    InkWell(
                      mouseCursor: MaterialStateMouseCursor.clickable,
                      onTap: widget.onTap,
                      child: Container(
                        height: 276,
                        width: 335,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(17),
                            border: Border.all(
                              color: AppColors.greyBorder,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 5,
                              )],
                            color: Colors.white
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 12, right: 12),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  tooltip: StringConst.EDIT_CONTACT,
                                  onPressed: widget.onEdit,
                                  icon: const Icon(
                                    Icons.mode_edit_outlined,
                                    size: 20,
                                    color: AppColors.turquoiseBlue,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 40, bottom: 10, left: 5, right: 5),
                              child: Container(
                                height: 40,
                                alignment:  Alignment.center,
                                child: Text(
                                  name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            //Email
                            Padding(
                              padding: const EdgeInsets.only(left: 25, right: 25),
                              child: email != '' ? Row(
                                children: [
                                  Icon(
                                    Icons.email,
                                    color: AppColors.bluePetrol,
                                    size: 20,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(
                                        email,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ) :
                              Container(),
                            ),
                            //Phone
                            Padding(
                              padding: const EdgeInsets.only(left: 25, right: 25, top: 8),
                              child: phone != '' ? Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    color: AppColors.bluePetrol,
                                    size: 20,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(
                                        phone,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ) :
                              Container(),
                            ),
                            //Location
                            Padding(
                              padding: const EdgeInsets.only(left: 25, right: 25, top: 8, bottom: 18),
                              child: location != '' ? Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: AppColors.bluePetrol,
                                    size: 20,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(
                                        location,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ) :
                              Container(),
                            ),
                            //Button
                            web != '' ? Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: Container(
                                width: 290,
                                padding: const EdgeInsets.only(left: 8, right: 8),
                                child: OutlinedButton(
                                    onPressed: (){
                                      launchURL(web);
                                    },
                                    child: Text(
                                      web,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.greyLetter
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(width: 1, color: AppColors.greyBorder),
                                    )
                                ),
                              ),
                            ) :
                            Container(),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: -27,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary020,
                            )
                        ),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(60)),
                          child: Center(
                            child: (currentSocialEntity.photo == null ||
                                    currentSocialEntity.photo!.isEmpty)
                                ? Container(
                                    color: Colors.transparent,
                                    height: 100,
                                    width: 100,
                                    child: Image.asset(
                                        ImagePath.IMAGE_DEFAULT),
                                  )
                                : CachedNetworkImage(
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.fitWidth,
                                    imageUrl: currentSocialEntity.photo!,
                                    placeholder: (context, url) =>
                                        Image.asset(ImagePath.IMAGE_DEFAULT),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(ImagePath.IMAGE_DEFAULT),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
  }


}

