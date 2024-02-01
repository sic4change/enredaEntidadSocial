
import 'package:cached_network_image/cached_network_image.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/home/web_home.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

import '../common_widgets/precached_avatar.dart';
import '../common_widgets/spaces.dart';
import '../values/strings.dart';

class SideBarWidget extends StatefulWidget {
  const SideBarWidget({
    Key? key,
    required SidebarXController controller,
    required this.profilePic,
    required this.userName,
    required this.keyWebHome}) : _controller = controller, super(key: key);
  final SidebarXController _controller;
  final String profilePic;
  final String userName;
  final GlobalKey<ScaffoldState> keyWebHome;

  @override
  State<SideBarWidget> createState() => _SideBarWidgetState();
}

class _SideBarWidgetState extends State<SideBarWidget> {
  void _setSelectedIndexToOne() {
    setState(() {
      WebHome.selectedIndex.value = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return SidebarX(
      controller: widget._controller,
      headerDivider: Container(
          height: 40, child: Divider(color: AppColors.turquoiseUltraLight, height: 1.5)),
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: AppColors.primary050,
        hoverTextStyle: const TextStyle(color: AppColors.greyDark, fontWeight: FontWeight.w600),
        textStyle: const TextStyle(color: AppColors.turquoiseBlue, fontWeight: FontWeight.w800),
        selectedTextStyle: const TextStyle(color: AppColors.turquoiseBlue, fontWeight: FontWeight.w800),
        itemTextPadding: const EdgeInsets.only(left: 10),
        selectedItemTextPadding: const EdgeInsets.only(left: 10),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: WebHome.selectedIndex.value == 0 ? Colors.transparent : AppColors.primary100,
          ),
          color: WebHome.selectedIndex.value == 0 ? Colors.transparent : AppColors.primary100,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.turquoiseBlue,
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: AppColors.turquoiseBlue,
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(
        width: 200,
        decoration: BoxDecoration(
          color: AppColors.white,
        ),
      ),
      footerDivider: Divider(color: Colors.grey.withOpacity(0.5), height: 1),
      showToggleButton: false,
      headerBuilder: (context, extended) {
        return isSmallScreen ?
        Container(
          height: 240,
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SpaceH20(),
                Image.asset(
                  ImagePath.LOGO,
                  height: 20,
                ),
                SpaceH30(),
                Column(
                  children: [
                    _buildMyUserPhoto(context, widget.profilePic),
                    CustomTextBoldCenter(title: widget.userName),
                  ],
                ),
              ],
            ),
          ),
        ) : Container(
          height: 200,
          margin: const EdgeInsets.only(top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildMyUserPhoto(context, widget.profilePic),
              CustomTextBoldCenter(title: widget.userName),
            ],
          ),
        );
      },
      items: [
        SidebarXItem(icon: Icons.add_circle_outlined, label: StringConst.NEW_PROFILE, onTap: _setSelectedIndexToOne),
        SidebarXItem(icon: Icons.view_quilt, label: 'Panel de control', onTap: _setSelectedIndexToOne),
        SidebarXItem(icon: Icons.supervisor_account, label: 'Participantes', onTap: _setSelectedIndexToOne),
        SidebarXItem(icon: Icons.card_travel, label: 'Mis recursos' , onTap: _setSelectedIndexToOne),
        SidebarXItem(icon: Icons.calendar_month, label: 'Directorio Entidades', onTap: _setSelectedIndexToOne)
      ],
    );
  }

  Widget _buildMyUserPhoto(BuildContext context, String profilePic) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return InkWell(
      onTap: () {
        setState(() {
          widget.keyWebHome.currentState?.closeDrawer();
          WebHome.selectedIndex.value = 0;
        });
      },
      child: Column(
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
                    height: isSmallScreen ? 80 : 100,
                    width: isSmallScreen ? 80 : 100,
                    child: Image.asset(ImagePath.USER_DEFAULT),
                  ):
                  CachedNetworkImage(
                      width: isSmallScreen ? 80 : 100,
                      height: isSmallScreen ? 80 : 100,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      imageUrl: profilePic),
                ),
              ) :
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(60)),
                child:
                profilePic == "" ?
                Container(
                  color:  Colors.transparent,
                  height: isSmallScreen ? 80 : 100,
                  width: isSmallScreen ? 80 : 100,
                  child: Image.asset(ImagePath.USER_DEFAULT),
                ):
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.turquoiseUltraLight,
                    )
                  ),
                  child: PrecacheAvatarCard(
                    imageUrl: profilePic,
                    width: isSmallScreen ? 80 : 100,
                    height: isSmallScreen ? 80 : 100,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}