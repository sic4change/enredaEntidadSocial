import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/participants/resource_participants_list.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';


class ShowInvitationDialog extends StatefulWidget {
  final UserEnreda user;
  final String organizerId;

  const ShowInvitationDialog({super.key,
    required this.user,
    required this.organizerId
  });

  @override
  State<ShowInvitationDialog> createState() => _ShowInvitationDialogState();
}

class _ShowInvitationDialogState extends State<ShowInvitationDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 0.0,
      backgroundColor: AppColors.primary050,
      content: dialogContent(context, widget.user, widget.organizerId),
      contentPadding: const EdgeInsets.all(20.0),
    );
  }
}

dialogContent(BuildContext context, UserEnreda user, String organizerId) {
  final isSmallScreen = widthOfScreen(context) < 1200;
  final dialogWidth = Responsive.isMobile(context) || isSmallScreen
      ? widthOfScreen(context)
      : widthOfScreen(context) * 0.55;
  final dialogHeight = Responsive.isMobile(context)
      ? heightOfScreen(context) * 0.60
      : heightOfScreen(context) * 0.50;
  TextTheme textTheme = Theme.of(context).textTheme;
  return Container(
    width: dialogWidth,
    height: dialogHeight,
    child: Column(
      children: <Widget>[
        Column(
          children: [
            Row(
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop((false)),
                    child: Icon(
                      Icons.close,
                      color: AppColors.greyTxtAlt,
                      size: widthOfScreen(context) >= 1024 ? 25 : 20,
                    ),
                  ),
                ),
              ],
            ),
            Responsive.isMobile(context) ? Container() : const SpaceH20(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const CustomTextMedium(text: 'Invitar a:'),
                const SizedBox(height: 10.0,),
                CustomTextMediumBold(text: '${user.firstName!} ${user.lastName!}'),
              ],
            ),
          ],
        ),
        ParticipantResourcesList(participant: user, organizerId: organizerId,),
      ],
    ),
  );
}
