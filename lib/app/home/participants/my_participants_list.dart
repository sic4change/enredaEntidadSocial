
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/rounded_container.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/participants/participants_page.dart';
import 'package:enreda_empresas/app/home/participants/participants_tile.dart';
import 'package:enreda_empresas/app/home/web_home.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/auth.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/utils/my_custom_scroll_behavior.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enreda_empresas/app/home/resources/global.dart' as globals;

class MyParticipantsScrollPage extends StatefulWidget {
  const MyParticipantsScrollPage({Key? key}) : super(key: key);

  @override
  State<MyParticipantsScrollPage> createState() => _MyParticipantsScrollPageState();
}

class _MyParticipantsScrollPageState extends State<MyParticipantsScrollPage> {
  bool _isLoading = true;
  UserEnreda? _socialEntityUser;
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      final database = Provider.of<Database>(context, listen: false);

      final user = await LocationCache.instance.getUser(database, auth.currentUser!.uid);
      if (user != null) {
        _socialEntityUser = user;
        globals.currentSocialEntityUser = user;

        final socialEntity = await LocationCache.instance.getSocialEntity(database, user.socialEntityId!);
        if (socialEntity != null) {
          await LocationCache.instance.loadAllParticipants(
            database,
            user.socialEntityId!,
            socialEntity.programs ?? [],
          );
        }
      }
    } catch (e) {
      print('Error in MyParticipantsScrollPage._initData: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
      color: Colors.white,
      borderWith: 1,
      borderColor: AppColors.greyLight2.withOpacity(0.3),
      contentPadding: Responsive.isMobile(context) || Responsive.isDesktopS(context) ? EdgeInsets.all(10.0) : EdgeInsets.all(20.0),
      margin: Responsive.isMobile(context) || Responsive.isDesktopS(context) ? EdgeInsets.all(0) : EdgeInsets.only(left: 30, right: 10, bottom: 10, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomTextBoldTitle(title: StringConst.MY_PARTICIPANTS),
          SpaceH4(),
          _buildContent(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_socialEntityUser == null) {
      return const Center(child: Text('No se pudo cargar el usuario'));
    }

    var scrollJump = Responsive.isDesktopS(context) ? 350 : 410;

    return StreamBuilder<void>(
      stream: LocationCache.instance.paginationUpdates,
      builder: (context, _) {
        // "Mis Participantes" must be scoped to participants whose
        // `assignedById` matches the logged-in técnico's userId — not the
        // entire social entity. LocationCache.allParticipants is entity-wide
        // (loaded via getParticipantsByEntityPaginated), so we filter it
        // client-side. Legacy participants with no assignedById are excluded
        // (they need to be reassigned via a separate UI).
        final myUserId = globals.currentSocialEntityUser?.userId
            ?? _socialEntityUser?.userId;
        final participants = LocationCache.instance.allParticipants;
        final myParticipants = (myUserId == null || myUserId.isEmpty)
            ? const <UserEnreda>[]
            : participants
                .where((u) => (u.assignedById ?? '').isNotEmpty
                    && u.assignedById == myUserId)
                .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 382,
              color: Colors.white,
              child: ScrollConfiguration(
                behavior: MyCustomScrollBehavior(),
                child: ListView.builder(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: myParticipants.length,
                  itemBuilder: (context, index) {
                    final user = myParticipants[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ParticipantsListTile(
                          user: user,
                          socialEntityUserId: _socialEntityUser!.socialEntityId!,
                          onTap: () => setState(() {
                            globals.currentParticipant = user;
                            WebHome.goToParticipants();
                            ParticipantsListPage.selectedIndex.value = 1;
                          })
                      ),
                    );
                  },
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    if (_horizontalScrollController.position.pixels >=
                        _horizontalScrollController.position.minScrollExtent)
                      _horizontalScrollController.animateTo(
                          _horizontalScrollController.position.pixels - scrollJump,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.ease);
                  },
                  child: Image.asset(
                    ImagePath.ARROW_BACK,
                    width: 36.0,
                  ),
                ),
                SpaceW12(),
                InkWell(
                  onTap: () {
                    if (_horizontalScrollController.position.pixels <=
                        _horizontalScrollController.position.maxScrollExtent)
                      _horizontalScrollController.animateTo(
                          _horizontalScrollController.position.pixels + scrollJump,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.ease);
                  },
                  child: Image.asset(
                    ImagePath.ARROW_FORWARD,
                    width: 36.0,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
