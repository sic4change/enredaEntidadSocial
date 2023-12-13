import 'package:cached_network_image/cached_network_image.dart';
import 'package:enreda_empresas/app/common_widgets/enreda_button.dart';
import 'package:enreda_empresas/app/common_widgets/precached_avatar.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ParticipantsListTile extends StatefulWidget {
  const ParticipantsListTile({Key? key, required this.user, this.onTap})
      : super(key: key);
  final UserEnreda user;
  final VoidCallback? onTap;

  @override
  State<ParticipantsListTile> createState() => _ParticipantsListTileState();
}

class _ParticipantsListTileState extends State<ParticipantsListTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
        width: 240.0,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          border: Border.all(
              color: AppColors.greyLight2.withOpacity(0.3), width: 1),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.greyAlt.withOpacity(0.15),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(1, 1), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: Sizes.kDefaultPaddingDouble,
                      horizontal: Sizes.kDefaultPaddingDouble/2
                  ),
                  child: Column(
                    children: [
                      Text(
                        StringConst.GAMIFICATION,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.seaBlue,
                        ),
                      ),
                      // TODO: Gamification Bar
                      Slider(value: 0.5, onChanged: null),
                      PrecacheAvatarCard(
                        imageUrl: widget.user.photo?? ImagePath.USER_DEFAULT,
                        height: 80,
                        width: 80,
                      ),
                      Text(
                        '${widget.user.firstName!} ${widget.user.lastName!}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.greyDark2,
                        ),
                      ),
                      SpaceH20(),
                      // TODO: Improve button style
                      EnredaButton(
                        buttonColor: AppColors.turquoise,
                        buttonTitle: StringConst.INVITE_RESOURCE,
                        titleColor: Colors.white,
                        height: 40.0,
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        onPressed: () {},
                      ),
                      SpaceH20(),
                      _buildContactRow(textTheme),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    // TODO
                  },
                  child: Container(
                    height: 50.0,
                    width: double.infinity,
                    color: AppColors.turquoiseBlue,
                    child: Center(
                      child: Text(StringConst.GO_PROFILE,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),),
                    ),
                    ),
                )
              ],
            ),
        );
  }

  Widget _buildContactRow(TextTheme textTheme) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: InkWell(
            onTap: () {
              // TODO
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mail_outline_outlined, color: AppColors.greyBlue,),
                SpaceW8(),
                Text(
                  StringConst.EMAIL,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
          )),
          const VerticalDivider(color: AppColors.greyBlue,),
          Expanded(child: InkWell(
            onTap: () {
              // TODO
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone, color: AppColors.greyBlue,),
                SpaceW8(),
                Text(
                  StringConst.CALL,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
