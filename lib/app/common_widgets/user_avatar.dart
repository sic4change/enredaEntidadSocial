
import 'package:cached_network_image/cached_network_image.dart';
import 'package:enreda_empresas/app/common_widgets/precached_avatar.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Widget userAvatar(BuildContext context, String profilePic) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          !kIsWeb ?
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(60)),
            child:
            Center(
              child:
              profilePic == "" ?
              Container(
                color:  Colors.transparent,
                height: 40,
                width: 40,
                child: Image.asset(ImagePath.USER_DEFAULT),
              ):
              CachedNetworkImage(
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  imageUrl: profilePic),
            ),
          ):
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(60)),
            child:
            profilePic == "" ?
            Container(
              color:  Colors.transparent,
              height: 40,
              width: 40,
              child: Image.asset(ImagePath.USER_DEFAULT),
            ):
            PrecacheAvatarCard(
              imageUrl: profilePic,
              width: 35,
              height: 35,
            ),
          )
        ],
      ),
    ],
  );
}