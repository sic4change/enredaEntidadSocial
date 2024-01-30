import 'package:enreda_empresas/app/common_widgets/build_share_button.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/models/resource.dart';
import 'package:enreda_empresas/app/services/auth.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResourceListTile extends StatefulWidget {
  const ResourceListTile({Key? key, required this.resource, this.onTap})
      : super(key: key);
  final Resource resource;
  final VoidCallback? onTap;

  @override
  State<ResourceListTile> createState() => _ResourceListTileState();
}

class _ResourceListTileState extends State<ResourceListTile> {
  String? codeDialog;
  String? valueText;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 12, 17, md: 15);
    double fontSizeS = responsiveSize(context, 12, 14, md: 13);
    double sidePadding = responsiveSize(context, 15, 20, md: 17);
    final auth = Provider.of<AuthBase>(context, listen: false);
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          margin: const EdgeInsets.all(5.0),
          child: InkWell(
            mouseCursor: MaterialStateMouseCursor.clickable,
            onTap: widget.onTap,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyLight2.withOpacity(0.3), width: 1),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.greyAlt.withOpacity(0.15),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: const Offset(1, 1), // changes position of shadow
                  ),
                ],
              ),
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            topLeft: Radius.circular(10)),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: sidePadding, right: sidePadding, top: sidePadding),
                                child: Text(
                                  widget.resource.resourceCategoryName!.toUpperCase(),
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: textTheme.labelMedium?.copyWith(
                                    color: AppColors.lilac,
                                    letterSpacing: 0.5,
                                    height: 1.5,
                                    fontWeight: FontWeight.w600,
                                    fontSize: fontSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  topLeft: Radius.circular(10)),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: sidePadding, right: sidePadding, top: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  widget.resource.organizerImage == null ||
                                          widget.resource.organizerImage!.isEmpty
                                      ? Container()
                                      : LayoutBuilder(
                                          builder: (context, constraints) {
                                          return CircleAvatar(
                                            radius: 15,
                                            backgroundColor: AppColors.white,
                                            backgroundImage: NetworkImage(
                                                widget.resource.organizerImage!),
                                          );
                                        }),
                                  widget.resource.organizerImage == null ||
                                          widget.resource.organizerImage!.isEmpty
                                      ? Container()
                                      : const SizedBox(
                                          width: 5,
                                        ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.resource.promotor != null
                                          ? widget.resource.promotor != ""
                                              ? widget.resource.promotor!
                                              : widget.resource.organizerName!
                                          : widget.resource.organizerName!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: AppColors.greyDark,
                                          height: 1.5,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.place,
                                            color: AppColors.greyDark,
                                            size: 12,
                                          ),
                                          Container(
                                            width: Responsive.isDesktop(context) ? 300 : 250,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                              child: Text(
                                                getLocationText(widget.resource),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    textTheme.bodySmall?.copyWith(
                                                  color: AppColors.greyDark,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SpaceH4(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const SpaceH4(),
                              Padding(
                                padding: EdgeInsets.only(
                                    right: sidePadding, left: sidePadding),
                                child: Text(
                                  widget.resource.title.toUpperCase(),
                                  textAlign: TextAlign.left,
                                  maxLines: 2,
                                  style: textTheme.labelMedium?.copyWith(
                                    color: AppColors.turquoiseBlue,
                                    letterSpacing: 0.5,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                    fontSize: fontSize,
                                  ),
                                ),
                              ),
                              const SpaceH8(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                        color: AppColors.white,
                      ),
                      child: Row(
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColors.greyLight2.withOpacity(0.2),
                                    width: 1),
                                borderRadius: BorderRadius.circular(Sizes.mainPadding),
                              ),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8.0),
                              margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 8,
                                    width: 8,
                                    decoration: BoxDecoration(
                                      color: widget.resource.status == "No disponible" ? Colors.red : Colors.lightGreenAccent,
                                      borderRadius: BorderRadius.circular(Sizes.mainPadding),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                      widget.resource.status!,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: AppColors.greyAlt,
                                        fontSize: fontSizeS,
                                      ),),
                                ],
                              )),
                          Spacer(),
                          Container(
                              margin: const EdgeInsets.only(left: 15.0),
                              child: buildShare(context, widget.resource, AppColors.greyAlt)
                          ),
                          SizedBox(width: 15,)
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
    );
  }

  String getLocationText(Resource resource) {
    switch (resource.modality) {
      case StringConst.FACE_TO_FACE:
      case StringConst.BLENDED:
        {
          if (resource.cityName != null) {
            return '${resource.cityName}, ${resource.provinceName}, ${resource.countryName}';
          }

          if (resource.cityName == null && resource.provinceName != null) {
            return '${resource.provinceName}, ${resource.countryName}';
          }

          if (resource.provinceName == null && resource.countryName != null) {
            return resource.countryName!;
          }

          if (resource.provinceName != null) {
            return resource.provinceName!;
          } else if (resource.countryName != null) {
            return resource.countryName!;
          }
          return resource.modality!;
        }

      case StringConst.ONLINE_FOR_COUNTRY:
      /*return StringConst.ONLINE_FOR_COUNTRY
            .replaceAll('país', resource.countryName!);*/

      case StringConst.ONLINE_FOR_PROVINCE:
      /*return StringConst.ONLINE_FOR_PROVINCE.replaceAll(
            'provincia', '${resource.provinceName!}, ${resource.countryName!}');*/

      case StringConst.ONLINE_FOR_CITY:
      /*return StringConst.ONLINE_FOR_CITY.replaceAll('ciudad',
            '${resource.cityName!}, ${resource.provinceName!}, ${resource.countryName!}');*/

      case StringConst.ONLINE:
        return StringConst.ONLINE;

      default:
        return resource.modality!;
    }
  }


}
