import 'package:enreda_empresas/app/common_widgets/edit_rounded_shape.dart';
import 'package:enreda_empresas/app/home/participants/edit_participant/edit_participant_info_page.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/participant_control_panel_page.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/documentation/participant_documentation_page.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/ipils/participant_ipil_page.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/participant_social_reports_page.dart';
import 'package:enreda_empresas/app/common_widgets/add_yellow_button.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/common_widgets/alert_dialog.dart';
import 'package:enreda_empresas/app/home/participants/show_invitation_diaglog.dart';
import 'package:enreda_empresas/app/models/city.dart';
import 'package:enreda_empresas/app/models/closureReport.dart';
import 'package:enreda_empresas/app/models/documentationParticipant.dart';
import 'package:enreda_empresas/app/models/initialReport.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:enreda_empresas/app/home/resources/global.dart' as globals;

class ParticipantDetailPage extends StatefulWidget {
  const ParticipantDetailPage({
    super.key,
  });

  static bool isEditing = false;

  @override
  State<ParticipantDetailPage> createState() => _ParticipantDetailPageState();
}

class _ParticipantDetailPageState extends State<ParticipantDetailPage> {
  List<String> _menuOptions = [
    StringConst.CONTROL_PANEL,
    StringConst.SOCIAL_REPORTS,
    StringConst.IPIL,
    StringConst.PERSONAL_DOCUMENTATION,
    StringConst.QUESTIONNAIRES
  ];
  String? _value;
  late UserEnreda participantUser, socialEntityUser;

  String? techNameComplete;

  Database? _db;
  Stream<UserEnreda>? _participantStream;
  Stream<ClosureReport?>? _closureReportStream;
  String? _closureReportId;
  final ScrollController _webScrollController = ScrollController();

  // Cached future for _buildDniWidget to avoid re-creating on every build
  Future<InitialReport?>? _dniInitialReportFuture;
  String? _dniUserId;

  @override
  void initState() {
    _value = _menuOptions[0];
    participantUser = globals.currentParticipant!;
    socialEntityUser = globals.currentSocialEntityUser!;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_db == null) {
      _db = Provider.of<Database>(context, listen: false);
      _participantStream =
          _db!.userEnredaStreamByUserId(participantUser.userId);
    }
  }

  @override
  void dispose() {
    _webScrollController.dispose();
    super.dispose();
  }

  void _ensureDniStreams(String? userId) {
    if (_db == null || userId == null || userId.isEmpty || _dniUserId == userId)
      return;
    _dniUserId = userId;
    _dniInitialReportFuture = _db!.getInitialReport(userId);
  }

  Widget _buildCurrentPage(BuildContext context, UserEnreda currentUser) {
    if (ParticipantDetailPage.isEditing) {
      return EditParticipantInfoPage(
        participant: currentUser,
        onSaved: () {
          setState(() {
            ParticipantDetailPage.isEditing = false;
          });
        },
        onCancel: () {
          setState(() {
            ParticipantDetailPage.isEditing = false;
          });
        },
      );
    }
    
    int index = _menuOptions.indexOf(_value!);
    switch (index) {
      case 0:
        return ParticipantControlPanelPage(participantUser: currentUser);
      case 1:
        return ParticipantSocialReportPage(participantUser: currentUser, context: context);
      case 2:
        return ParticipantIPILPage(participantUser: currentUser);
      case 3:
        return ParticipantDocumentationPage(participantUser: currentUser);
      case 4:
        return Container();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserEnreda>(
        stream: _participantStream,
        builder: (context, participantSnapshot) {
          UserEnreda currentUser = participantSnapshot.data ?? participantUser;
          _ensureClosureReportStream(currentUser.closureReportId);

          return FutureBuilder<UserEnreda?>(
            future: currentUser.assignedById != null
                ? LocationCache.instance
                    .getUser(_db!, currentUser.assignedById!)
                : Future.value(null),
            builder: (context, snapshot) {
              String? techNameComplete;
              if (snapshot.hasData && snapshot.data != null) {
                String techName = snapshot.data!.firstName ?? '';
                String techLastName = snapshot.data!.lastName ?? '';
                techNameComplete = '$techName $techLastName';
              }
              return Responsive.isDesktop(context)
                  ? _buildParticipantWeb(context, currentUser, techNameComplete)
                  : _buildParticipantMobile(
                      context, currentUser, techNameComplete);
            },
          );
        });
  }

  void _ensureClosureReportStream(String? closureReportId) {
    if (_db == null) return;
    if (_closureReportId == closureReportId) return;
    _closureReportId = closureReportId;
    _closureReportStream = _db!.closureReportStreamById(closureReportId);
  }

  Widget _buildParticipantWeb(
      BuildContext context, UserEnreda user, String? techNameComplete) {
    return SingleChildScrollView(
      controller: _webScrollController,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Responsive.isDesktop(context)
                ? _buildHeaderWeb(context, user, techNameComplete)
                : _buildHeaderMobile(context, user, techNameComplete),
            SpaceH20(),
            Divider(
              indent: 0,
              endIndent: 0,
              color: AppColors.greyBorder,
              thickness: 1,
              height: 1,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40.0, 22.0, 0.0, 22.0),
              child: _buildMenuSelectorChips(context, user),
            ),
            Divider(
              indent: 0,
              endIndent: 0,
              color: AppColors.greyBorder,
              thickness: 1,
              height: 0,
            ),
            SpaceH24(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 40.0, vertical: 0.0),
              child: _buildCurrentPage(context, user),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantMobile(
      BuildContext context, UserEnreda? user, String? techNameComplete) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderMobile(context, user!, techNameComplete),
          SpaceH20(),
          _buildMenuSelectorChips(context, user),
          SpaceH20(),
          _buildCurrentPage(context, user),
        ],
      ),
    );
  }

  Widget _buildMenuSelectorChips(BuildContext context, UserEnreda user) {
    return Wrap(
      spacing: 20.0,
      runSpacing: 20.0,
      children: List<Widget>.generate(
        5,
        (int index) {
          return ChoiceChip(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25)),
                side: BorderSide(
                    color: _value == _menuOptions[index]
                        ? Colors.transparent
                        : AppColors.violet)),
            disabledColor: Colors.white,
            selectedColor: AppColors.yellow,
            labelStyle: TextStyle(
              fontSize: Responsive.isMobile(context) ? 12.0 : 16.0,
              fontWeight: _value == _menuOptions[index]
                  ? FontWeight.w700
                  : FontWeight.w400,
              color: _value == _menuOptions[index]
                  ? AppColors.turquoiseBlue
                  : AppColors.greyTxtAlt,
            ),
            label: Text(_menuOptions[index]),
            selected: _value == _menuOptions[index],
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            showCheckmark: false,
            onSelected: (bool selected) async {
              if ((_value != _menuOptions[index]) &&
                  (ParticipantDetailPage.isEditing ||
                      ParticipantSocialReportPage.isEditingReport)) {
                final leave = await showAlertDialog(
                  context,
                  title: '¿Estás seguro que quieres salir?',
                  content: 'Si sales, los cambios no guardados se perderán.',
                  defaultActionText: 'Salir',
                  cancelActionText: 'Cancelar',
                );
                if (leave != true) return;
                // Reset report state so no stale flag lingers
                ParticipantSocialReportPage.isEditingReport = false;
                ParticipantSocialReportPage.selectedIndexInforms.value = 0;
              }

              setState(() {
                ParticipantDetailPage.isEditing = false;
                _value = _menuOptions[index];
              });
            },
          );
        },
      ).toList(),
    );
  }

  Widget _buildHeaderWeb(
      BuildContext context, UserEnreda user, String? techNameComplete) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(left: Sizes.kDefaultPaddingDouble * 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30, right: 20, bottom: 30),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(160),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(160)),
                child: Center(
                  child: user.photo == ""
                      ? Container(
                          color: Colors.transparent,
                          height: 160,
                          width: 160,
                          child: Image.asset(ImagePath.USER_DEFAULT),
                        )
                      : FadeInImage.assetNetwork(
                          placeholder: ImagePath.USER_DEFAULT,
                          width: 160,
                          height: 160,
                          fit: BoxFit.cover,
                          image: user.photo ?? "",
                        ),
                ),
              ),
            ),
          ),
          //Personal data
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '${user.firstName} ${user.lastName}',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.chatDarkGray,
                            fontFamily: GoogleFonts.outfit().fontFamily,
                            fontSize: 30,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!ParticipantDetailPage.isEditing) _buildEditInfoButton(context, user),
                          if (!ParticipantDetailPage.isEditing) SpaceH8(),
                          AddYellowButton(
                            text: StringConst.INVITE_RESOURCE,
                            onPressed: () => showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    ShowInvitationDialog(
                                      user: user,
                                      organizerId:
                                          socialEntityUser.socialEntityId!,
                                    )),
                          ),
                        ],
                      ),
                      SpaceW40(),
                    ],
                  ),
                  SpaceH8(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (techNameComplete != null)
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CustomTextSmallColor(
                                  text: 'Persona de referencia:',
                                  color: AppColors.primary900,
                                  height: 0.5,
                                ),
                                SpaceW8(),
                                CustomTextSmallBold(
                                  title: '$techNameComplete',
                                  color: AppColors.primary900,
                                  height: 0.5,
                                ),
                              ],
                            )
                          : _bottomAddTech(socialEntityUser),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CustomTextSmallColor(
                            text: 'Estado de itinerario:',
                            color: AppColors.primary900,
                            height: 0.5,
                          ),
                          SpaceW8(),
                          Builder(
                            builder: (context) {
                              DateTime? startDateItinerary =
                                  user.startDateItinerary;
                              if (startDateItinerary == null) {
                                return CustomTextSmallBold(
                                  title: 'No iniciado',
                                  color: AppColors.primary900,
                                  height: 0.5,
                                );
                              }
                              return StreamBuilder<ClosureReport?>(
                                stream: _closureReportStream,
                                builder: (context, snapshotClosure) {
                                  final closure = snapshotClosure.data;
                                  final isClosed = closure != null &&
                                      closure.completedDate != null &&
                                      closure.finished == true;
                                  if (isClosed) {
                                    return CustomTextSmallBold(
                                      title:
                                          'CERRADO: ${DateFormat('dd/MM/yyyy').format(startDateItinerary)} - ${DateFormat('dd/MM/yyyy').format(closure.completedDate!)}',
                                      color: AppColors.redClose,
                                      height: 0.5,
                                    );
                                  }
                                  return CustomTextSmallBold(
                                    title:
                                        'ACTIVO: ${DateFormat('dd/MM/yyyy').format(startDateItinerary)}',
                                    color: AppColors.primary900,
                                    height: 0.5,
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                  SpaceH20(),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.mail,
                            color: AppColors.darkGray,
                            size: 22.0,
                          ),
                          const SpaceW4(),
                          CustomTextSmall(
                            text: user.email,
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.phone,
                              color: AppColors.darkGray,
                              size: 22.0,
                            ),
                            const SpaceW4(),
                            CustomTextSmall(
                              text: user.phone ?? '',
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.assignment_ind,
                              color: AppColors.darkGray,
                              size: 22.0,
                            ),
                            const SpaceW4(),
                            _buildDniWidget(context, user),
                          ],
                        ),
                      ),
                      _buildMyLocation(context, user),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomAddTech(UserEnreda tech) {
    final database = Provider.of<Database>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () async {
              setState(() {
                participantUser.assignedById = tech.userId;
              });
              await database.setUserEnreda(participantUser);
            },
            child: CustomTextBold(
              title: 'Asignarme este participante',
              color: AppColors.turquoiseButton2,
            ),
          ),
          SpaceW4(),
          InkWell(
            onTap: () async {
              setState(() {
                participantUser.assignedById = tech.userId;
              });
              await database.setUserEnreda(participantUser);
            },
            child: Icon(
              Icons.add_circle,
              color: AppColors.turquoiseButton2,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderMobile(
      BuildContext context, UserEnreda user, String? techNameComplete) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(60)),
          child: user.photo == ""
              ? Container(
                  color: Colors.transparent,
                  height: Responsive.isMobile(context) ? 90 : 120,
                  width: Responsive.isMobile(context) ? 90 : 120,
                  child: Image.asset(ImagePath.USER_DEFAULT),
                )
              : FadeInImage.assetNetwork(
                  placeholder: ImagePath.USER_DEFAULT,
                  width: Responsive.isMobile(context) ? 90 : 120,
                  height: Responsive.isMobile(context) ? 90 : 120,
                  fit: BoxFit.cover,
                  image: user.photo ?? "",
                ),
        ),
        SpaceH30(),
        Text(
          '${user.firstName} ${user.lastName}',
          maxLines: 2,
          style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary900,
              overflow: TextOverflow.ellipsis),
        ),
        SpaceH8(),
        Text(
          '${user.educationName}'.toUpperCase(),
          maxLines: 2,
          style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary900,
              overflow: TextOverflow.ellipsis),
        ),
        SpaceH12(),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (techNameComplete != null)
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomTextSmallColor(
                        text: 'Persona de referencia:',
                        color: AppColors.primary900,
                        height: 0.2,
                      ),
                      SpaceW8(),
                      CustomTextSmallBold(
                        title: '$techNameComplete',
                        color: AppColors.primary900,
                        height: 0.2,
                      ),
                    ],
                  )
                : _bottomAddTech(socialEntityUser),
            user.startDateItinerary != null
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomTextSmallColor(
                        text: 'Estado de itinerario:',
                        color: AppColors.primary900,
                        height: 0.2,
                      ),
                      SpaceW8(),
                      CustomTextSmallBold(
                        title:
                            'ACTIVO: ${DateFormat('dd/MM/yyyy').format(user.startDateItinerary!)}',
                        color: AppColors.primary900,
                        height: 0.2,
                      ),
                    ],
                  )
                : CustomTextSmallColor(
                    text: 'No iniciado',
                    color: AppColors.primary900,
                    height: 0.2,
                  ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.mail,
              color: AppColors.darkGray,
              size: 14.0,
            ),
            const SpaceW4(),
            CustomTextSmall(
              text: user.email,
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.phone,
              color: AppColors.darkGray,
              size: 14.0,
            ),
            const SpaceW4(),
            CustomTextSmall(
              text: user.phone ?? '',
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.assignment_ind,
              color: AppColors.darkGray,
              size: 14.0,
            ),
            const SpaceW4(),
            _buildDniWidget(context, user),
          ],
        ),
        _buildMyLocation(context, user),
        SpaceH40(),
        if (!ParticipantDetailPage.isEditing) Center(child: _buildEditInfoButton(context, user)),
        if (!ParticipantDetailPage.isEditing) SpaceH12(),
        Center(
          child: AddYellowButton(
            text: StringConst.INVITE_RESOURCE,
            onPressed: () => showDialog(
                context: context,
                builder: (BuildContext context) => ShowInvitationDialog(
                      user: user,
                      organizerId: socialEntityUser.socialEntityId!,
                    )),
          ),
        ),
        SpaceH20(),
      ],
    );
  }

  Widget _buildEditInfoButton(BuildContext context, UserEnreda user) {
    return InkWell(
      onTap: () {
        setState(() {
          ParticipantDetailPage.isEditing = true;
        });
      },
      child: Container(
        height: 50,
        width: 235,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          border: Border.all(color: AppColors.turquoiseBlue, width: 1.5),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: RoundedEditShape(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 40.0),
                child: Text(
                  'Editar información',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.turquoiseBlue,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDniWidget(BuildContext context, UserEnreda user) {
    _ensureDniStreams(user.userId);
    if (_dniInitialReportFuture == null) return const SizedBox.shrink();

    return FutureBuilder<InitialReport?>(
      future: _dniInitialReportFuture,
      builder: (context, snapshotReport) {
        // 1. Check InitialReport.dniParticipant first
        final dniFromReport = snapshotReport.data?.dniParticipant;
        if (dniFromReport != null && dniFromReport.trim().isNotEmpty) {
          return CustomTextSmall(text: dniFromReport);
        }

        // 2. Fall back to user.dni stored in user object
        if (user.dni != null && user.dni!.trim().isNotEmpty) {
          return CustomTextSmall(text: user.dni!);
        }

        // No DNI in the report or the user doc -> show nothing. (There used
        // to be a fallback to the latest uploaded document's NAME, which
        // surfaced garbage like "Prueba Google play" as if it were a DNI.)
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMyLocation(BuildContext context, UserEnreda? user) {
    if (user?.address?.city == null || user!.address!.city!.isEmpty) {
      return _buildLocationRow(context, '');
    }

    final database = Provider.of<Database>(context, listen: false);

    return FutureBuilder<City?>(
      future: LocationCache.instance.getCity(database, user.address!.city!),
      builder: (context, snapshot) {
        String city = snapshot.data?.name ?? '';
        return _buildLocationRow(context, city);
      },
    );
  }

  Widget _buildLocationRow(BuildContext context, String cityName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.location_on,
          color: Colors.black.withOpacity(0.7),
          size: Responsive.isDesktop(context) && !Responsive.isDesktopS(context)
              ? 22
              : 14,
        ),
        const SpaceW4(),
        CustomTextSmall(text: cityName),
      ],
    );
  }
}
