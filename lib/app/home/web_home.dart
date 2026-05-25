import 'package:enreda_empresas/app/common_widgets/alert_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/enreda_button.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/account/personal_data.dart';
import 'package:enreda_empresas/app/home/participants/create_participant/create_participant_page.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/participant_detail_page.dart';
import 'package:enreda_empresas/app/home/side_bar_widget.dart';
import 'package:enreda_empresas/app/home/control_panel/control_panel_page.dart';
import 'package:enreda_empresas/app/home/participants/participants_page.dart';
import 'package:enreda_empresas/app/home/resources/my_resources_list_page.dart';
import 'package:enreda_empresas/app/home/sesiones/sesiones_page.dart';
import 'package:enreda_empresas/app/home/tool_box/tool_box_page.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/auth.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/sign_in/access/access_page.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/utils/functions.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:enreda_empresas/app/home/resources/global.dart' as globals;

import 'external_social_entity/entity_directory_page.dart';


class WebHome extends StatefulWidget {
  const WebHome({Key? key})
      : super(key: key);

  static final SidebarXController controller = SidebarXController(selectedIndex: 0, extended: true);
  static ValueNotifier<int> selectedIndex = ValueNotifier(2);

  // ── Sidebar index mapping ─────────────────────────────────────────────
  //   0 → Panel de control
  //   1 → Participantes
  //   2 → Sesiones      (moved up — sits directly below Participantes)
  //   3 → Recursos
  //   4 → Caja de herramientas
  //   5 → Agenda de contactos (Entities)
  // ──────────────────────────────────────────────────────────────────────

  static goToControlPanel() {
    WebHome.selectedIndex.value = 2; // Select empty Container
    WebHome.controller.selectIndex(0);
  }

  static goToParticipants() {
    WebHome.selectedIndex.value = 2; // Select empty Container
    WebHome.controller.selectIndex(1);
    ParticipantsListPage.selectedIndex.value = 0;
  }

  static goToSesiones() {
    WebHome.selectedIndex.value = 2; // Select empty Container
    WebHome.controller.selectIndex(2);
  }

  static goResources() {
    WebHome.selectedIndex.value = 2; // Select empty Container
    WebHome.controller.selectIndex(3);
    MyResourcesListPage.selectedIndex.value = 0;
  }

  static goToolBox() {
    WebHome.selectedIndex.value = 2; // Select empty Container
    WebHome.controller.selectIndex(4);
  }

  static goToEntities() {
    WebHome.selectedIndex.value = 2; // Select empty Container
    WebHome.controller.selectIndex(5);
    EntityDirectoryPage.selectedIndex.value = 0;
  }

  @override
  State<WebHome> createState() => _WebHomeState();
}

class _WebHomeState extends State<WebHome> {
  bool _warmUpStarted = false;

  void _ensureWarmUp(Database database) {
    if (_warmUpStarted) return;
    _warmUpStarted = true;
    LocationCache.instance.warmUpAll(database);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<User?>(
              stream: Provider.of<AuthBase>(context).authStateChanges(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const AccessPage();
                if (snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.active) {
                  return StreamBuilder<UserEnreda>(
                      stream: database.userEnredaStreamByUserId(auth.currentUser!.uid),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return _buildErrorPage(context, snapshot.error.toString());
                        }
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                        if (snapshot.hasData){
                          var user = snapshot.data!;
                          var userName = '${user.firstName ?? ""} ${user.lastName ?? ""}';
                          var profilePic = user.photo ?? "";
                          if (user.role != 'Entidad Social') {
                            _unemployedSignOut(context);
                            return Container();
                          }
                          if (user.socialEntityId == null || user.socialEntityId!.isEmpty) {
                            return _buildErrorPage(context, "No se ha encontrado una entidad asociada a tu usuario.");
                          }
                          return StreamBuilder<SocialEntity>(
                              stream: database.socialEntityStreamById(user.socialEntityId!),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return _buildErrorPage(context, snapshot.error.toString());
                                }
                                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                                if (snapshot.hasData) {
                                  var socialEntity = snapshot.data!;
                                  final socialEntityId = socialEntity.socialEntityId;
                                  if (socialEntityId != null && socialEntityId.isNotEmpty) {
                                    LocationCache.instance.socialEntitiesCache[socialEntityId] = socialEntity;
                                  }
                                  _ensureWarmUp(database);
                                  globals.currentUserSocialEntity = socialEntity;
                                  return _WebHomeContent(
                                    socialEntity: socialEntity,
                                    user: user,
                                    profilePic: profilePic,
                                    userName: userName,
                                  );
                                }
                                return const Center(child: CircularProgressIndicator());
                              });
                        }
                        return const Center(child: CircularProgressIndicator());
                      }
                  );
                } return const Center(child: CircularProgressIndicator());
        });
  }

  Widget _buildErrorPage(BuildContext context, String error) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SpaceH20(),
              const Text(
                'Ha ocurrido un error al cargar tus datos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SpaceH12(),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SpaceH20(),
              EnredaButton(
                buttonTitle: 'Cerrar sesión',
                onPressed: () async {
                  await auth.signOut();
                  GoRouter.of(context).go(StringConst.PATH_HOME);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebHomeContent extends StatefulWidget {
  final SocialEntity socialEntity;
  final UserEnreda user;
  final String profilePic;
  final String userName;

  const _WebHomeContent({
    Key? key,
    required this.socialEntity,
    required this.user,
    required this.profilePic,
    required this.userName,
  }) : super(key: key);

  @override
  State<_WebHomeContent> createState() => _WebHomeContentState();
}

class _WebHomeContentState extends State<_WebHomeContent> {
  var bodyWidget = [];
  final _key = GlobalKey<ScaffoldState>();
  int _lastConfirmedIndex = 0;
  int _lastConfirmedMajorIndex = 2;
  bool _isHandlingSidebarChange = false;
  bool _isHandlingMajorChange = false;

  @override
  void initState() {
    bodyWidget = [
      const PersonalData(),
      const CreateParticipantPage(),
      Container(),
    ];
    super.initState();
    _lastConfirmedIndex = WebHome.controller.selectedIndex;
    _lastConfirmedMajorIndex = WebHome.selectedIndex.value;
    WebHome.controller.addListener(_handleSidebarChange);
    WebHome.selectedIndex.addListener(_handleMajorIndexChange);
  }

  void _handleMajorIndexChange() async {
    if (_isHandlingMajorChange) return;

    int newIndex = WebHome.selectedIndex.value;
    if (newIndex != _lastConfirmedMajorIndex) {
      if (ParticipantDetailPage.isEditing) {
        _isHandlingMajorChange = true;
        // Revert immediately so the new page doesn't render
        WebHome.selectedIndex.value = _lastConfirmedMajorIndex;

        final leave = await showAlertDialog(
          context,
          title: '¿Estás seguro que quieres dejar de editar?',
          content: 'Si sales, los cambios no guardados se perderán.',
          defaultActionText: 'Salir',
          cancelActionText: 'Cancelar',
        );

        if (leave == true) {
          ParticipantDetailPage.isEditing = false;
          setState(() {
            _lastConfirmedMajorIndex = newIndex;
          });
          WebHome.selectedIndex.value = newIndex;
        }
        _isHandlingMajorChange = false;
      } else {
        setState(() {
          _lastConfirmedMajorIndex = newIndex;
        });
      }
    }
  }

  void _handleSidebarChange() async {
    if (_isHandlingSidebarChange) return;

    int newIndex = WebHome.controller.selectedIndex;
    if (newIndex != _lastConfirmedIndex) {
      if (ParticipantDetailPage.isEditing) {
        _isHandlingSidebarChange = true;
        // Revert immediately so the new page doesn't render
        WebHome.controller.selectIndex(_lastConfirmedIndex);
        
        final leave = await showAlertDialog(
          context,
          title: '¿Estás seguro que quieres dejar de editar?',
          content: 'Si sales, los cambios no guardados se perderán.',
          defaultActionText: 'Salir',
          cancelActionText: 'Cancelar',
        );

        if (leave == true) {
          ParticipantDetailPage.isEditing = false;
          setState(() {
            _lastConfirmedIndex = newIndex;
          });
          WebHome.controller.selectIndex(newIndex);
        }
        _isHandlingSidebarChange = false;
      } else {
        setState(() {
          _lastConfirmedIndex = newIndex;
        });
      }
    }
  }

  @override
  void dispose() {
    WebHome.controller.removeListener(_handleSidebarChange);
    WebHome.selectedIndex.removeListener(_handleMajorIndexChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return ValueListenableBuilder<int>(
        valueListenable: WebHome.selectedIndex,
        builder: (context, selectedIndex, child) {
          final isSmallScreen = MediaQuery.of(context).size.width < 600;
          return Scaffold(
            key: _key,
            appBar: AppBar(
              toolbarHeight: 80,
              elevation: 0.4,
              backgroundColor: AppColors.white,
              leading: isSmallScreen ? IconButton(
                onPressed: () {
                  _key.currentState?.openDrawer();
                },
                icon: const Icon(Icons.menu),
              ) : Container(),
              title: Transform(
                transform:  Responsive.isMobile(context) ? Matrix4.translationValues(0.0, 0.0, 0.0) : Matrix4.translationValues(-40.0, 0.0, 0.0),
                child: Row(
                  children: [
                    Image.asset(
                      ImagePath.LOGO,
                      height: Responsive.isMobile(context) ? 35 : 50,
                    ),
                    !isSmallScreen ? _buildMyCompanyName(context, widget.socialEntity) : Container(),
                  ],
                ),
              ),
              actions: <Widget>[
                const SizedBox(width: 10),
                if (!auth.isNullUser)
                  SizedBox(
                    width: 35,
                    child: InkWell(
                      onTap: () => _confirmSignOut(context),
                      child: Image.asset(
                        ImagePath.LOGOUT,
                        height: Sizes.ICON_SIZE_30,
                      ),),
                  ),
                const SizedBox(width: 50,)
              ],
            ),
            drawer: SideBarWidget(controller: WebHome.controller, profilePic: widget.profilePic, userName: widget.userName, keyWebHome: _key,),
            body: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1600),
                child: Padding(
                  padding: Responsive.isMobile(context) ? const EdgeInsets.all(0.0) : const EdgeInsets.only(left: 20.0),
                  child: Row(
                    children: [
                      if(!isSmallScreen) SideBarWidget(controller: WebHome.controller, profilePic: widget.profilePic, userName: widget.userName, keyWebHome: _key,),
                      if (_lastConfirmedMajorIndex == 0) Expanded(child: Center(child: bodyWidget[0]))
                      else if (_lastConfirmedMajorIndex == 1) Expanded(child: Center(child: bodyWidget[1]))
                      else Expanded(child: Center(child: AnimatedBuilder(
                        animation: WebHome.controller,
                        builder: (context, child){
                          switch(_lastConfirmedIndex){
                            // 0 → Panel de control
                            case 0: _key.currentState?.closeDrawer();
                            return ControlPanelPage(socialEntity: widget.socialEntity, user: widget.user,);
                            // 1 → Participantes
                            case 1: _key.currentState?.closeDrawer();
                            return const ParticipantsListPage();
                            // 2 → Sesiones (now sits directly below Participantes)
                            case 2: _key.currentState?.closeDrawer();
                            return SesionesPage(socialEntity: widget.socialEntity);
                            // 3 → Recursos
                            case 3: _key.currentState?.closeDrawer();
                            return MyResourcesListPage(socialEntity: widget.socialEntity);
                            // 4 → Caja de herramientas
                            case 4: _key.currentState?.closeDrawer();
                            return ToolBoxPage();
                            // 5 → Agenda de contactos
                            case 5: _key.currentState?.closeDrawer();
                            return EntityDirectoryPage(socialEntity: widget.socialEntity);
                            default:
                              return MyResourcesListPage(socialEntity: widget.socialEntity);
                          }
                        },
                      ),))
                    ],
                  ),
                ),
              ),
            ),

          );
        });
  }

  Widget _buildMyCompanyName(BuildContext context, SocialEntity socialEntity) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(' &  ${socialEntity.name}',
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary900,
                fontSize: 16.0,)
          ),
        ),
      ],
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final didRequestSignOut = await showAlertDialog(context,
        title: 'Cerrar sesión',
        content: '¿Estás seguro que quieres cerrar sesión?',
        cancelActionText: 'Cancelar',
        defaultActionText: 'Cerrar');
    if (didRequestSignOut == true) {
      await auth.signOut();
      GoRouter.of(context).go(StringConst.PATH_HOME);
    }
  }
}


Future<void> _unemployedSignOut(BuildContext context) async {
  String targetWeb = "";
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 18, md: 15);
    await showDialog(
      context: context,
      builder: (BuildContext context) => Center(
        child: AlertDialog(
          insetPadding: const EdgeInsets.all(20),
          contentPadding: const EdgeInsets.only(left: 20, right: 20, top: 30),
          content: SizedBox(
            height: 100,
            width: MediaQuery.of(context).size.width * 0.5,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    ImagePath.LOGO,
                    height: 30,
                  ),
                  const SpaceH20(),
                  Text(StringConst.ARENT_YOU_SOCIAL_ENTITY,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.greyDark,
                        height: 1.5,
                        fontWeight: FontWeight.w800,
                        fontSize: fontSize,
                      )
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: EnredaButton(
                  width: 250.0,
                  buttonTitle: StringConst.GO_YOUNG_WEB,
                  onPressed: () {
                    targetWeb = StringConst.WEB_APP_URL_ACCESS;
                    auth.signOut();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
              child: Center(
                child: EnredaButton(
                  width: 250.0,
                  buttonTitle: StringConst.GO_MAIN_WEB,
                  onPressed: () {
                    targetWeb = StringConst.NEW_WEB_APP_URL;
                    auth.signOut();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ).then((exit) {
      if (exit == null) {
        auth.signOut();
        launchURL(targetWeb);
      }
    });
  });
}