import 'package:enreda_empresas/app/common_widgets/add_yellow_button.dart';
import 'package:enreda_empresas/app/common_widgets/add_yellow_button_small.dart';
import 'package:enreda_empresas/app/common_widgets/enreda_button.dart';
import 'package:enreda_empresas/app/common_widgets/gamification_slider.dart';
import 'package:enreda_empresas/app/common_widgets/precached_avatar.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/participants/show_invitation_diaglog.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ParticipantsListTile extends StatefulWidget {
  const ParticipantsListTile({
    Key? key,
    required this.user,
    required this.socialEntityUserId,
    this.onTap})
      : super(key: key);
  final UserEnreda user;
  final String socialEntityUserId;
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
    final gamificationFlagsCount = widget.user.gamificationFlags.length;

    return InkWell(
      onTap: widget.onTap,
      child: Container(
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
                        GamificationSlider(
                            value: gamificationFlagsCount,
                        ),
                        SpaceH8(),
                        widget.user.photo != null && widget.user.photo!.isNotEmpty?
                        PrecacheAvatarCard(
                          imageUrl: widget.user.photo!,
                          height: 80,
                          width: 80,
                        ):
                        ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(60)),
                          child: Container(
                            height: 80,
                            width: 80,
                            color: AppColors.pink600,
                            child: Center(child: Text(
                              '${(widget.user.firstName??'-').substring(0, 1)} '
                              '${(widget.user.lastName??'-').substring(0, 1)}',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),),
                          ),
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
                        AddYellowButtonSmall(
                          text: StringConst.INVITE_RESOURCE,
                          onPressed: () => showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  ShowInvitationDialog(
                                    user: widget.user,
                                    organizerId: widget.socialEntityUserId,
                                  )),
                          height: 40,
                          circleHeight: 41,
                          circleWidth: 41,
                        ),
                        SpaceH30(),
                        _buildContactRow(textTheme),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: widget.onTap,
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
          ),
    );
  }

  Widget _buildContactRow(TextTheme textTheme) {
    bool hasPhone = widget.user.phone != null && widget.user.phone!.isNotEmpty;
    bool hasEmail = widget.user.email.isNotEmpty;

    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: InkWell(
            onTap: hasEmail? () => _sendEmail(widget.user.email): null,
            child: Container(
              decoration: hasEmail? BoxDecoration(
                border: Border.all(
                    color: AppColors.greyBlue, width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ): null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mail_outline_outlined, color: hasEmail? AppColors.turquoiseBlue: AppColors.greyBlue,),
                  SpaceW8(),
                  Text(
                    StringConst.EMAIL,
                    style: textTheme.bodyMedium?.copyWith(
                      color: hasEmail? AppColors.turquoiseBlue: AppColors.darkGray,
                    ),
                  ),
                ],
              ),
            ),
          )),
          const VerticalDivider(color: AppColors.greyBlue,),
          Expanded(child: InkWell(
            onTap: hasPhone? () => _call(widget.user.phone??""): null,
            child: Container(
              decoration: hasPhone? BoxDecoration(
                border: Border.all(
                    color: AppColors.greyBlue, width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ): null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone, color: hasPhone? AppColors.turquoiseBlue: AppColors.greyBlue,),
                  SpaceW8(),
                  Text(
                    StringConst.CALL,
                    style: textTheme.bodyMedium?.copyWith(
                      color: hasPhone? AppColors.turquoiseBlue: AppColors.darkGray,
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  void _sendEmail(String email) {
    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries
          .map((MapEntry<String, String> e) =>
      '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
    }

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: encodeQueryParameters(<String, String>{
        'subject': 'Asunto',
      }),
    );
    launchUrl(emailLaunchUri);
  }

  void _call(String phone) {
    final Uri emailLaunchUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    launchUrl(emailLaunchUri);
  }
}
