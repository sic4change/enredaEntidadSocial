import 'package:enreda_empresas/app/common_widgets/alert_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/enreda_button.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/informs/closure_report_participant.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/informs/derivation_report_participant.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/informs/follow_report_participant.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/informs/initial_report_participant.dart';
import 'package:enreda_empresas/app/home/participants/pdf_generator/pdf_closure_follow_preview.dart';
import 'package:enreda_empresas/app/home/participants/pdf_generator/pdf_initial_derivation_preview.dart';
import 'package:enreda_empresas/app/home/participants/pdf_generator/pdf_initial_follow_preview.dart';
import 'package:enreda_empresas/app/home/participants/pdf_generator/pdf_initial_report_preview.dart';
import 'package:enreda_empresas/app/models/closureReport.dart';
import 'package:enreda_empresas/app/models/derivationReport.dart';
import 'package:enreda_empresas/app/models/followReport.dart';
import 'package:enreda_empresas/app/models/initialReport.dart';
import 'package:enreda_empresas/app/models/socialItineraryCycle.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:enreda_empresas/app/home/resources/global.dart' as globals;

import '../../../common_widgets/empty-list.dart';

enum SampleItem { itemOne, itemTwo, itemThree, itemFour }

class ParticipantSocialReportPage extends StatefulWidget {
  ParticipantSocialReportPage({required this.participantUser, super.key, required this.context});
  static ValueNotifier<int> selectedIndexInforms = ValueNotifier(0);
  final UserEnreda participantUser;
  final BuildContext context;

  @override
  State<ParticipantSocialReportPage> createState() => _ParticipantSocialReportPageState();
}

class _ParticipantSocialReportPageState extends State<ParticipantSocialReportPage> {
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  int totalReports = 1;
  late UserEnreda user;
  late Widget currentPage;
  String? participantAssignedUserId;
  late InitialReport initialReport = InitialReport();
  bool? noneAreSet;
  bool _isArchiving = false;
  Database? _database;
  Stream<UserEnreda>? _participantStream;

  // Active-cycle streams keyed by the report document id. When a report id
  // is null/empty the stream emits null (handled inside the Database impl).
  String? _cachedInitialReportId;
  String? _cachedClosureReportId;
  String? _cachedFollowReportId;
  String? _cachedDerivationReportId;
  Stream<InitialReport?>? _initialReportStream;
  Stream<ClosureReport?>? _closureReportStream;
  Stream<FollowReport?>? _followReportStream;
  Stream<DerivationReport?>? _derivationReportStream;

  @override
  void initState() {
    ParticipantSocialReportPage.selectedIndexInforms.value = 0;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _database ??= Provider.of<Database>(context, listen: false);
    _participantStream ??= _database!.userEnredaStreamByUserId(widget.participantUser.userId);
  }

  void _ensureReportStreams(UserEnreda u) {
    if (_database == null) return;
    if (_initialReportStream == null || _cachedInitialReportId != u.initialReportId) {
      _cachedInitialReportId = u.initialReportId;
      _initialReportStream = _database!.initialReportStreamById(u.initialReportId);
    }
    if (_closureReportStream == null || _cachedClosureReportId != u.closureReportId) {
      _cachedClosureReportId = u.closureReportId;
      _closureReportStream = _database!.closureReportStreamById(u.closureReportId);
    }
    if (_followReportStream == null || _cachedFollowReportId != u.followReportId) {
      _cachedFollowReportId = u.followReportId;
      _followReportStream = _database!.followReportStreamById(u.followReportId);
    }
    if (_derivationReportStream == null || _cachedDerivationReportId != u.derivationReportId) {
      _cachedDerivationReportId = u.derivationReportId;
      _derivationReportStream = _database!.derivationReportStreamById(u.derivationReportId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: ParticipantSocialReportPage.selectedIndexInforms,
        builder: (context, selectedIndex, child) {
          return SingleChildScrollView(
            child: Container(
                child: _buildPageByIndex(selectedIndex)),
          );
        }
    );
    //return currentPage;
  }

  Widget _buildPageByIndex(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return selectionPage();
      case 1:
        return InitialReportForm(user: widget.participantUser);
      case 2:
        return FollowReportForm(user: widget.participantUser);
      case 3:
        return DerivationReportForm(user: widget.participantUser);
      case 4:
        return ClosureReportForm(user: widget.participantUser);
      default:
        return selectionPage();
    }
  }

  Widget selectionPage() {
    if (_participantStream == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<UserEnreda>(
      stream: _participantStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          user = snapshot.data!;
        } else {
          user = widget.participantUser;
        }
        participantAssignedUserId = user.assignedById ?? '';
        totalReports = 1;
        if (user.followReportId != null) totalReports++;
        if (user.closureReportId != null) totalReports++;
        if (user.derivationReportId != null) totalReports++;
        noneAreSet = [
          user.initialReportId,
          user.followReportId,
          user.derivationReportId,
          user.closureReportId
        ].every((id) => id == null);

        _ensureReportStreams(user);

        return StreamBuilder<InitialReport?>(
          stream: _initialReportStream,
          builder: (context, initialSnap) {
            final InitialReport initialReportUser =
                initialSnap.data ?? InitialReport();
            if (initialSnap.data != null) {
              globals.currentInitialReportUser = initialSnap.data!;
            }
            return StreamBuilder<ClosureReport?>(
              stream: _closureReportStream,
              builder: (context, closureSnap) {
                final ClosureReport closureReportUser =
                    closureSnap.data ?? ClosureReport();
                if (closureSnap.data != null) {
                  globals.currentClosureReportUser = closureSnap.data!;
                }
                return StreamBuilder<FollowReport?>(
                  stream: _followReportStream,
                  builder: (context, followSnap) {
                    final FollowReport followReportUser =
                        followSnap.data ?? FollowReport();
                    if (followSnap.data != null) {
                      globals.currentFollowReportUser = followSnap.data!;
                    }
                    return StreamBuilder<DerivationReport?>(
                      stream: _derivationReportStream,
                      builder: (context, derivationSnap) {
                        final DerivationReport derivationReportUser =
                            derivationSnap.data ?? DerivationReport();
                        if (derivationSnap.data != null) {
                          globals.currentDerivationReportUser =
                              derivationSnap.data!;
                        }

                        final bool isActiveClosed =
                            closureSnap.data != null &&
                                closureSnap.data!.completedDate != null &&
                                closureSnap.data!.finished == true;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Single page-level title (matches mockup).
                            _buildPageHeader(
                              user: user,
                              initialReport: initialReportUser,
                              followReport: followReportUser,
                              derivationReport: derivationReportUser,
                              closureReport: closureReportUser,
                              suppressAddMenu: isActiveClosed,
                            ),
                            const SpaceH16(),
                            // History cycles first (oldest → newest). Each one
                            // renders as its own closed-state box.
                            ...user.socialItineraryHistory
                                .map((cycle) => Padding(
                                      padding: const EdgeInsets.only(bottom: 20),
                                      child: _buildHistoryCycleCard(cycle),
                                    )),
                            // Active cycle. Always rendered: when it has reports
                            // (post re-apertura) it shows "ABIERTO" + the new
                            // rows in a new box below the history. When empty
                            // (no cycle started yet) the EmptyList CTA prompts
                            // the entity user to create the first Informe
                            // Inicial.
                            _buildActiveCycleCard(
                              user: user,
                              initialReportUser: initialReportUser,
                              followReportUser: followReportUser,
                              derivationReportUser: derivationReportUser,
                              closureReportUser: closureReportUser,
                              isActiveClosed: isActiveClosed,
                            ),
                            if (isActiveClosed)
                              _buildReaperturaBlock(user, closureReportUser),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildActiveCycleCard({
    required UserEnreda user,
    required InitialReport initialReportUser,
    required FollowReport followReportUser,
    required DerivationReport derivationReportUser,
    required ClosureReport closureReportUser,
    required bool isActiveClosed,
  }) {
    // The banner counts as a row for bottom-rounded-corner computation.
    final bool bannerVisible = isActiveClosed || noneAreSet == false;
    final int bannerOffset = bannerVisible ? 1 : 0;
    final int activeTotalRows = totalReports + bannerOffset;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Column(
        children: [
          if (isActiveClosed)
            _buildClosedStatusBannerRow(
              startDate: user.startDateItinerary,
              closureDate: closureReportUser.completedDate,
              isFirstRow: true,
            )
          else if (noneAreSet == false)
            _buildOpenStatusBannerRow(
              startDate: user.startDateItinerary,
              isFirstRow: true,
            ),
          if (noneAreSet == true)
            globals.currentSocialEntityUser?.userId ==
                    participantAssignedUserId
                ? EmptyList(
                    title: StringConst.NO_REPORT_ENTRY,
                    subtitle: StringConst.ADD_REPORT_ENTRY,
                    imagePath: ImagePath.EMPTY_LiST_ICON,
                    onPressed: () {
                      ParticipantSocialReportPage
                          .selectedIndexInforms.value = 1;
                    },
                  )
                : EmptyList(
                    title: StringConst.NO_REPORT_ENTRY,
                    subtitle: StringConst.ADD_REPORT_ENTRY,
                    imagePath: ImagePath.EMPTY_LiST_ICON,
                    onPressed: () {
                      if (widget.participantUser.assignedById == null ||
                          widget.participantUser.assignedById == '') {
                        showAlertDialog(
                          context,
                          title: StringConst.FORM_WARNING,
                          content: StringConst.REPORT_WARNING_TECHNICAL,
                          defaultActionText: StringConst.FORM_ACCEPT,
                        );
                        return;
                      }
                    },
                  ),
          if (user.initialReportId != null)
            _documentTile(
              context,
              'INFORME INICIAL',
              formatter.format(
                  initialReportUser.completedDate ?? DateTime.now()),
              bannerOffset,
              () {
                setState(() {
                  ParticipantSocialReportPage.selectedIndexInforms.value = 1;
                });
              },
              () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyInitialReport(
                      user: user,
                      initialReport: globals.currentInitialReportUser,
                    ),
                  ),
                );
              },
              initialReportUser.finished ?? false,
              totalOverride: activeTotalRows,
            ),
          if (user.followReportId != null)
            _documentTile(
              context,
              'INFORME DE SEGUIMIENTO',
              formatter.format(
                  followReportUser.completedDate ?? DateTime.now()),
              bannerOffset + 1,
              () {
                setState(() {
                  ParticipantSocialReportPage.selectedIndexInforms.value = 2;
                });
              },
              () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyFollowReport(
                      user: user,
                      followReport: followReportUser,
                    ),
                  ),
                );
              },
              followReportUser.finished ?? false,
              totalOverride: activeTotalRows,
            ),
          if (user.derivationReportId != null)
            _documentTile(
              context,
              'INFORME DE DERIVACIÓN',
              formatter.format(
                  derivationReportUser.completedDate ?? DateTime.now()),
              bannerOffset + (user.followReportId == null ? 1 : 2),
              () {
                setState(() {
                  ParticipantSocialReportPage.selectedIndexInforms.value = 3;
                });
              },
              () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyDerivationReport(
                      user: user,
                      derivationReport: derivationReportUser,
                    ),
                  ),
                );
              },
              derivationReportUser.finished ?? false,
              totalOverride: activeTotalRows,
            ),
          if (user.closureReportId != null)
            _documentTile(
              context,
              'INFORME DE CIERRE',
              formatter
                  .format(closureReportUser.completedDate ?? DateTime.now()),
              bannerOffset + _closureReportNumber(),
              () {
                setState(() {
                  ParticipantSocialReportPage.selectedIndexInforms.value = 4;
                });
              },
              () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyClosureReport(
                      user: user,
                      closureReport: closureReportUser,
                    ),
                  ),
                );
              },
              closureReportUser.finished ?? false,
              totalOverride: activeTotalRows,
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryCycleCard(SocialItineraryCycle cycle) {
    // Count how many reports exist in this cycle to compute bottom-radius row.
    int historyTotal = 1; // banner row occupies index 0
    if (cycle.initialReportId != null) historyTotal++;
    if (cycle.followReportId != null) historyTotal++;
    if (cycle.derivationReportId != null) historyTotal++;
    if (cycle.closureReportId != null) historyTotal++;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Column(
        children: [
          _buildClosedStatusBannerRow(
            startDate: cycle.startDate,
            closureDate: cycle.closureDate,
            isFirstRow: true,
          ),
          if (cycle.initialReportId != null)
            _buildHistoryReportRow<InitialReport>(
              title: 'INFORME INICIAL',
              order: 1,
              totalRows: historyTotal,
              stream: _database!.initialReportStreamById(cycle.initialReportId),
              completedDateSelector: (r) => r.completedDate,
              onView: (report) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyInitialReport(
                    user: user,
                    initialReport: report,
                  ),
                ),
              ),
            ),
          if (cycle.followReportId != null)
            _buildHistoryReportRow<FollowReport>(
              title: 'INFORME DE SEGUIMIENTO',
              order: (cycle.initialReportId != null ? 2 : 1),
              totalRows: historyTotal,
              stream: _database!.followReportStreamById(cycle.followReportId),
              completedDateSelector: (r) => r.completedDate,
              onView: (report) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyFollowReport(
                    user: user,
                    followReport: report,
                  ),
                ),
              ),
            ),
          if (cycle.derivationReportId != null)
            _buildHistoryReportRow<DerivationReport>(
              title: 'INFORME DE DERIVACIÓN',
              order: (cycle.initialReportId != null ? 1 : 0) +
                  (cycle.followReportId != null ? 1 : 0) +
                  1,
              totalRows: historyTotal,
              stream: _database!
                  .derivationReportStreamById(cycle.derivationReportId),
              completedDateSelector: (r) => r.completedDate,
              onView: (report) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyDerivationReport(
                    user: user,
                    derivationReport: report,
                  ),
                ),
              ),
            ),
          if (cycle.closureReportId != null)
            _buildHistoryReportRow<ClosureReport>(
              title: 'INFORME DE CIERRE',
              order: (cycle.initialReportId != null ? 1 : 0) +
                  (cycle.followReportId != null ? 1 : 0) +
                  (cycle.derivationReportId != null ? 1 : 0) +
                  1,
              totalRows: historyTotal,
              stream:
                  _database!.closureReportStreamById(cycle.closureReportId),
              completedDateSelector: (r) => r.completedDate,
              onView: (report) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyClosureReport(
                    user: user,
                    closureReport: report,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryReportRow<T>({
    required String title,
    required int order,
    required int totalRows,
    required Stream<T?> stream,
    required DateTime? Function(T) completedDateSelector,
    required void Function(T) onView,
  }) {
    return StreamBuilder<T?>(
      stream: stream,
      builder: (context, snapshot) {
        final report = snapshot.data;
        final date = report != null
            ? completedDateSelector(report)
            : null;
        return _documentTile(
          context,
          title,
          date != null ? formatter.format(date) : '',
          order,
          () {
            if (report != null) onView(report);
          },
          () {},
          date != null,
          totalOverride: totalRows,
        );
      },
    );
  }

  Widget _buildClosedStatusBannerRow({
    required DateTime? startDate,
    required DateTime? closureDate,
    bool isFirstRow = false,
  }) {
    final closedText = (startDate != null && closureDate != null)
        ? 'CERRADO: ${formatter.format(startDate)} - ${formatter.format(closureDate)}'
        : 'CERRADO';
    return _buildStatusBannerRow(
      valueText: closedText,
      valueColor: AppColors.redClose,
      isFirstRow: isFirstRow,
    );
  }

  Widget _buildOpenStatusBannerRow({
    required DateTime? startDate,
    bool isFirstRow = false,
  }) {
    final openText = startDate != null
        ? 'ABIERTO desde ${formatter.format(startDate)}'
        : 'ABIERTO';
    return _buildStatusBannerRow(
      valueText: openText,
      valueColor: AppColors.turquoiseBlue,
      isFirstRow: isFirstRow,
    );
  }

  Widget _buildStatusBannerRow({
    required String valueText,
    required Color valueColor,
    bool isFirstRow = false,
  }) {
    final labelStyle = TextStyle(
      fontFamily: GoogleFonts.inter().fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: Responsive.isDesktop(context) ? 16 : 13,
      color: AppColors.chatDarkGray,
    );
    return Container(
      width: double.infinity,
      padding: Responsive.isMobile(context)
          ? const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14)
          : const EdgeInsets.symmetric(horizontal: 50.0, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: isFirstRow
            ? const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              )
            : BorderRadius.zero,
        border: Border(
          bottom: BorderSide(color: AppColors.greyBorder, width: 1),
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: labelStyle,
          children: [
            const TextSpan(text: 'ESTADO DEL ITINERARIO: '),
            TextSpan(
              text: valueText,
              style: labelStyle.copyWith(color: valueColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReaperturaBlock(UserEnreda user, ClosureReport closureReport) {
    final bool canReopen =
        globals.currentSocialEntityUser?.userId == participantAssignedUserId;
    final String closureDateStr = closureReport.completedDate != null
        ? formatter.format(closureReport.completedDate!)
        : '';
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Column(
        children: [
          CustomTextBold(
            title:
                'El itinerario de este participante está cerrado desde el $closureDateStr.',
            color: AppColors.primary900,
          ),
          const SpaceH8(),
          CustomTextBold(
            title:
                'Si necesitas continuar el acompañamiento, crea un nuevo informe de re-apertura.',
            color: AppColors.primary900,
          ),
          const SpaceH20(),
          if (canReopen)
            _ReaperturaButton(
              isLoading: _isArchiving,
              onPressed: () => _handleReapertura(user, closureReport),
            ),
        ],
      ),
    );
  }

  Future<void> _handleReapertura(
      UserEnreda user, ClosureReport closureReport) async {
    if (_isArchiving || _database == null) return;
    setState(() {
      _isArchiving = true;
    });
    try {
      await _database!.archiveItinerary(user, closureReport);
      // The participant stream will emit the updated UserEnreda with cleared
      // pointers; `_ensureReportStreams` will then rebind each report stream
      // based on the id-diff. No manual stream reset is needed here — doing so
      // could trigger extra subscribes on stale stream instances.
      //
      // Navigate straight into the new Informe Inicial so the new cycle starts
      // immediately. When the user saves and returns, the list will show the
      // archived cycle on top and the new active box (ABIERTO + Informe
      // Inicial) right below it.
      if (mounted) {
        ParticipantSocialReportPage.selectedIndexInforms.value = 1;
      }
    } catch (e) {
      if (mounted) {
        showAlertDialog(
          context,
          title: 'Error',
          content: 'No se pudo reabrir el itinerario. Inténtalo de nuevo.',
          defaultActionText: 'Aceptar',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isArchiving = false;
        });
      }
    }
  }

  int _closureReportNumber(){
    int result = 1;
    if(user.derivationReportId != null){
      result++;
    }
    if(user.followReportId != null){
      result++;
    }
    return result;
  }

  Widget _buildPageHeader({
    required UserEnreda user,
    required InitialReport initialReport,
    required FollowReport followReport,
    required DerivationReport derivationReport,
    required ClosureReport closureReport,
    bool suppressAddMenu = false,
  }) {
    SampleItem? selectedItem;
    final bool showAddMenu = !suppressAddMenu &&
        globals.currentSocialEntityUser?.userId == participantAssignedUserId;
    return Padding(
        padding: Responsive.isMobile(context)
            ? const EdgeInsets.symmetric(horizontal: 8.0)
            : const EdgeInsets.only(
                left: 4.0, top: 4.0, bottom: 4.0, right: 4.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextBoldTitle(
                  title: StringConst.SOCIAL_REPORTS.toUpperCase()),
              !showAddMenu ? Container() :
              Theme(
                data: Theme.of(context).copyWith(
                  dividerTheme: DividerThemeData(
                    color: AppColors.greyDropMenuBorder,
                  )
                ),
                child: PopupMenuButton<SampleItem>(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  enableFeedback: false,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: AppColors.greyDropMenuBorder,),
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                  ),
                  icon: Icon(
                    Icons.add_circle_outlined,
                    color: AppColors.turquoiseBlue,
                    size: 24,
                  ),
                  initialValue: selectedItem,
                  onSelected: (SampleItem item) {
                    setState(() {
                      selectedItem = item;
                    });
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
                    PopupMenuItem<SampleItem>(
                      value: SampleItem.itemOne,
                      enabled: false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextTitle(title: 'Crear Nuevo Informe', color: AppColors.primary900),
                          Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.turquoiseBlue,
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(
                      height: 1,
                    ),
                    PopupMenuItem<SampleItem>(
                        value: SampleItem.itemTwo,
                        child: CustomTextTitle(title: 'INFORME INICIAL', color: AppColors.primary900),
                        onTap: (){
                          if(user.initialReportId != null){
                            showAlertDialog(
                              context,
                              title: 'Aviso',
                              content: 'Este participante ya tiene un Informe Inicial.',
                              defaultActionText: 'Aceptar',
                            );
                            return;
                          }
                          setState(() {
                            ParticipantSocialReportPage.selectedIndexInforms.value = 1;
                          });
                        }
                    ),
                    PopupMenuItem<SampleItem>(
                      value: SampleItem.itemTwo,
                      child: CustomTextTitle(title: 'INFORME DE SEGUIMIENTO', color: AppColors.primary900),
                      onTap: (){
                        if(user.followReportId != null){
                          showAlertDialog(
                            context,
                            title: 'Aviso',
                            content: 'Este participante ya tiene un Informe de Seguimiento.',
                            defaultActionText: 'Aceptar',
                          );
                          return;
                        }
                        if(user.initialReportId != null){
                          if(initialReport.completedDate == null){
                            showAlertDialog(
                              context,
                              title: 'Aviso',
                              content: 'El Informe Inicial aún no se ha completado.',
                              defaultActionText: 'Aceptar',
                            );
                            return;
                          }
                        }
                        if(user.initialReportId == null){
                          showAlertDialog(
                            context,
                            title: 'Aviso',
                            content: 'El Informe Inicial aún no se ha completado.',
                            defaultActionText: 'Aceptar',
                          );
                          return;
                        }
                        /*if(user.initialReportId != null){
                          if(initialReport.completedDate!.add(Duration(days: 180)).isBefore(DateTime.now()) == false){
                            showAlertDialog(
                              context,
                              title: 'Aviso',
                              content: 'Inicie el Informe de Seguimiento transcurridos los 6 meses del Informe Inicial.',
                              defaultActionText: 'Aceptar',
                            );
                            return;
                          }
                        }*/
                        setState(() {
                          ParticipantSocialReportPage.selectedIndexInforms.value = 2;
                        });

                      }
                    ),
                    PopupMenuItem<SampleItem>(
                      value: SampleItem.itemThree,
                      enabled: true,
                      child: CustomTextTitle(title: 'INFORME DE DERIVACIÓN', color: AppColors.primary900),
                      onTap: (){
                        if(user.derivationReportId != null){
                          showAlertDialog(
                            context,
                            title: 'Aviso',
                            content: 'Este participante ya tiene un Informe de Derivación.',
                            defaultActionText: 'Aceptar',
                          );
                          return;
                        }
                        if(initialReport.completedDate == null){
                          showAlertDialog(
                            context,
                            title: 'Aviso',
                            content: 'El Informe Inicial aún no se ha completado.',
                            defaultActionText: 'Aceptar',
                          );
                          return;
                        }
                        setState(() {
                          ParticipantSocialReportPage.selectedIndexInforms.value = 3;
                        });
                      },
                    ),
                    PopupMenuItem<SampleItem>(
                      value: SampleItem.itemFour,
                      child: CustomTextTitle(title: 'INFORME DE CIERRE', color: AppColors.primary900),
                        onTap: (){
                          if(user.closureReportId != null){
                            showAlertDialog(
                              context,
                              title: 'Aviso',
                              content: 'Este participante ya tiene un Informe de Cierre',
                              defaultActionText: 'Aceptar',
                            );
                            return;
                          }
                          if(initialReport.completedDate == null){
                            showAlertDialog(
                              context,
                              title: 'Aviso',
                              content: 'El Informe Inicial aún no se ha completado.',
                              defaultActionText: 'Aceptar',
                            );
                            return;
                          }
                          /*if(followReport.completedDate == null && !initialReport.completedDate!.isAfter(DateTime.now().add(Duration(days: -180)))){
                            showAlertDialog(
                              context,
                              title: 'Aviso',
                              content: 'El Informe de Seguimiento aún no se ha completado.',
                              defaultActionText: 'Aceptar',
                            );
                            return;
                          }
                          if(derivationReport.completedDate == null && !initialReport.completedDate!.isAfter(DateTime.now().add(Duration(days: -180)))){
                            showAlertDialog(
                              context,
                              title: 'Aviso',
                              content: 'El Informe de Derivación aún no se ha completado.',
                              defaultActionText: 'Aceptar',
                            );
                            return;
                          }*/
                          setState(() {
                            ParticipantSocialReportPage.selectedIndexInforms.value = 4;
                          });
                        },
                    ),
                  ],
                ),
              )
            ]
          )
      );
  }

  Widget _documentTile(
      BuildContext context,
      String title,
      String date,
      int order,
      VoidCallback onView,
      VoidCallback onDownload,
      bool visibleDownload,
      {int? totalOverride}) {
    bool paridad = order % 2 == 0;
    final int effectiveTotal = totalOverride ?? totalReports;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: paridad ? AppColors.greySearch : AppColors.white,
        borderRadius: order == effectiveTotal - 1 ?
        BorderRadius.only(
            bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)) :
        BorderRadius.all(Radius.circular(0)),
      ),
      padding: Responsive.isMobile(context) ? const EdgeInsets.symmetric(horizontal: 20.0) : const EdgeInsets.symmetric(horizontal: 50.0),
      child: Row(
        children: [
          Flex(
            direction: Responsive.isMobile(context) ? Axis.vertical : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: GoogleFonts
                      .inter()
                      .fontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: Responsive.isDesktop(context) ? 16 : 13,
                  color: AppColors.chatDarkGray,
                ),
              ),
              visibleDownload ? Text(
                ' - ' + date,
                style: TextStyle(
                  fontFamily: GoogleFonts
                      .inter()
                      .fontFamily,
                  fontWeight: FontWeight.w500,
                  fontSize: Responsive.isDesktop(context) ? 16 : 13,
                  color: AppColors.chatDarkGray,
                ),
              ) : globals.currentSocialEntityUser?.userId == participantAssignedUserId ?
              InkWell(
                onTap: onView,
                child: Text(
                  ' - Seguir y finalizar',
                  style: TextStyle(
                    fontFamily: GoogleFonts
                        .inter()
                        .fontFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: Responsive.isDesktop(context) ? 16 : 13,
                    color: AppColors.turquoiseButton2,
                  ),
                ),
              ) :
              Text(
                ' - En proceso',
                style: TextStyle(
                  fontFamily: GoogleFonts.inter().fontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize:
                      Responsive.isDesktop(context) ? 16 : 13,
                  color: AppColors.turquoiseButton2,
                ),
              ),
            ],
          ),
          Spacer(),
          visibleDownload ? IconButton(
            icon: Image.asset(
              ImagePath.PERSONAL_DOCUMENTATION_VIEW,
              width: 20,
              height: 20,
            ),
            onPressed: onView,
          ) : Container(),
          SpaceW8(),
          visibleDownload ? IconButton(
            icon: Image.asset(
              ImagePath.PERSONAL_DOCUMENTATION_DOWNLOAD,
              width: 20,
              height: 20,
            ),
            onPressed: onDownload
          ) : Container(),
        ],
      ),
    );
  }

}

class _ReaperturaButton extends StatelessWidget {
  const _ReaperturaButton({
    required this.onPressed,
    required this.isLoading,
  });

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 48,
        width: 48,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return EnredaButton(
      buttonTitle: 'Crear informe de re-apertura',
      width: 260,
      height: 48,
      buttonColor: AppColors.turquoiseBlue,
      titleColor: AppColors.white,
      onPressed: onPressed,
    );
  }
}

