import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/participants/pdf_generator/ipils_print/pdf_ipil_preview.dart';
import 'package:enreda_empresas/app/models/initialReport.dart';
import 'package:enreda_empresas/app/models/ipilEntry.dart';
import 'package:enreda_empresas/app/models/ipilObjectives.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common_widgets/alert_dialog.dart';
import '../../../../common_widgets/empty-list.dart';
import '../../../../common_widgets/enreda_button.dart';
import 'create_ipil_form.dart';
import 'expandable_ipil.dart';

class ParticipantIPILPage extends StatefulWidget {
  ParticipantIPILPage({required this.participantUser, super.key});
  static ValueNotifier<int> selectedIndexIpils = ValueNotifier(0);
  final UserEnreda participantUser;

  @override
  State<ParticipantIPILPage> createState() => _ParticipantIPILPageState();
}

class _ParticipantIPILPageState extends State<ParticipantIPILPage> {
  String? techNameComplete;
  List<String> _menuOptions = [StringConst.IPIL_FOLLOW, StringConst.FORM_GOALS];
  String? _value;
  List<IpilEntry> ipilEntriesPage = [];
  IpilEntry? selectedIpil;

  late Stream<List<IpilEntry>> _ipilEntriesStream;
  late Stream<InitialReport?> _initialReportStream;
  late Stream<IpilObjectives> _ipilObjectivesStream;
  late Database _database;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _database = Provider.of<Database>(context, listen: false);
    _ipilEntriesStream =
        _database.getIpilEntriesByUserStream(widget.participantUser.userId!);
    _initialReportStream =
        _database.initialReportStreamById(widget.participantUser.initialReportId);
    _ipilObjectivesStream =
        _database.ipilObjectivesStreamByUserId(widget.participantUser.userId!);
    ParticipantIPILPage.selectedIndexIpils.value = 0;
    _value = _menuOptions[0];

    // Load the assigned tech user name for downloads
    final assignedId = widget.participantUser.assignedById;
    if (assignedId != null && assignedId.isNotEmpty) {
      LocationCache.instance.getUser(_database, assignedId).then((user) {
        if (mounted && user != null) {
          setState(() {
            techNameComplete =
                '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
          });
        }
      });
    }

    super.initState();
  }

  Widget _buildPageByIndex(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return followPage();
      case 1:
        return objectivePage();
      case 2:
        return CreateIpilForm(participantUser: widget.participantUser);
      case 3:
        return CreateIpilForm(
            participantUser: widget.participantUser,
            selectedIpil: selectedIpil);
      default:
        return followPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: ParticipantIPILPage.selectedIndexIpils,
        builder: (context, selectedIndex, child) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.greyBorder)),
            child: Column(
              children: [
                Padding(
                  padding: Responsive.isMobile(context)
                      ? const EdgeInsets.fromLTRB(20, 14, 20, 10)
                      : const EdgeInsets.fromLTRB(44, 22, 44, 12),
                  child: Responsive.isMobile(context)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextBoldTitle(title: StringConst.IPIL),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(children: _buildIplTabs()),
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomTextBoldTitle(title: StringConst.IPIL),
                            const SizedBox(width: 40),
                            Row(children: _buildIplTabs()),
                          ],
                        ),
                ),
                Divider(
                  color: AppColors.greyBorder,
                ),
                SingleChildScrollView(
                  child: Container(child: _buildPageByIndex(selectedIndex)),
                )
              ],
            ),
          );
        });
  }

  List<Widget> _buildIplTabs() {
    return List<Widget>.generate(
      2,
      (int index) {
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: ChoiceChip(
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(38)),
              side: BorderSide(
                color: _value == _menuOptions[index]
                    ? Colors.transparent
                    : AppColors.violet,
              ),
            ),
            backgroundColor: Colors.white,
            disabledColor: Colors.white,
            selectedColor: AppColors.turquoiseBlue,
            labelStyle: TextStyle(
              fontSize: Responsive.isMobile(context) ? 13.0 : 16.0,
              fontWeight: _value == _menuOptions[index]
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: _value == _menuOptions[index]
                  ? AppColors.white
                  : AppColors.greyTxtAlt,
            ),
            label: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(_menuOptions[index]),
            ),
            selected: _value == _menuOptions[index],
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            showCheckmark: false,
            onSelected: (bool selected) {
              setState(() {
                _value = _menuOptions[index];
                ParticipantIPILPage.selectedIndexIpils.value = index;
              });
            },
          ),
        );
      },
    ).toList();
  }

  Widget followPage() {
    return StreamBuilder<List<IpilEntry>>(
        stream: _ipilEntriesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (!snapshot.hasData) return const SizedBox.shrink();
          List<IpilEntry> ipilEntries = snapshot.data!;
          return followPageDetail(ipilEntries);
        });
  }

  Widget followPageDetail(List<IpilEntry> ipilEntries) {
    int subsidy = 0;
    bool isInitialReportFinished = false;
    return StreamBuilder<InitialReport?>(
        stream: _initialReportStream,
        builder: (context, snapshot) {
          final report = snapshot.data;
          if (report != null && (report.finished ?? false)) {
            subsidy = StringConst.getSubsidyIndex(report.subsidy);
            isInitialReportFinished = true;
          }
          return Column(
            children: [
              Padding(
                padding: Responsive.isMobile(context)
                    ? const EdgeInsets.fromLTRB(12, 12, 12, 6)
                    : const EdgeInsets.fromLTRB(40, 24, 40, 14),
                child: Wrap(
                  spacing: 18,
                  runSpacing: 14,
                  children: [
                    EnredaButtonIconSmall(
                      buttonTitle: StringConst.ADD_IPIL_ENTRY,
                      buttonColor: AppColors.greySearch,
                      titleColor: AppColors.primary900,
                      width: null,
                      height: 40,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      titleStyle: TextStyle(
                        color: AppColors.primary900,
                        fontSize: Responsive.isMobile(context) ? 13 : 15,
                        fontWeight: FontWeight.w500,
                      ),
                      widget: Icon(
                        Icons.add_circle,
                        color: AppColors.turquoiseBlue,
                        size: 22,
                      ),
                      onPressed: () {
                        if (widget.participantUser.assignedById == null ||
                            widget.participantUser.assignedById == '') {
                          showAlertDialog(
                            context,
                            title: StringConst.FORM_WARNING,
                            content: StringConst.IPIL_WARNING_TECHNICAL,
                            defaultActionText: StringConst.FORM_ACCEPT,
                          );
                          return;
                        }
                        setState(() {
                          ParticipantIPILPage.selectedIndexIpils.value = 2;
                        });
                      },
                    ),
                    EnredaButtonIconSmall(
                      buttonTitle: StringConst.DOWNLOAD_ALL,
                      buttonColor: AppColors.greySearch,
                      titleColor: AppColors.primary900,
                      width: null,
                      height: 40,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      titleStyle: TextStyle(
                        color: AppColors.primary900,
                        fontSize: Responsive.isMobile(context) ? 13 : 15,
                        fontWeight: FontWeight.w500,
                      ),
                      widget: Image.asset(
                        ImagePath.DOWNLOAD_FILLED,
                        width: 22,
                        height: 22,
                      ),
                      onPressed: () async {
                        if (ipilEntries.isEmpty) {
                          showAlertDialog(
                            context,
                            title: StringConst.FORM_WARNING,
                            content: StringConst.FORM_NO_IPIL,
                            defaultActionText: StringConst.FORM_ACCEPT,
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyIpilEntries(
                                    user: widget.participantUser,
                                    ipilEntries: ipilEntriesPage,
                                    techName: techNameComplete ?? '',
                                    subsidy: subsidy,
                                  )),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Divider(
                color: AppColors.greyBorder,
              ),
              SpaceH8(),
              ipilEntries.isEmpty
                  ? EmptyList(
                      title: StringConst.FORM_NO_IPILS,
                      subtitle: StringConst.ADD_IPIL_ENTRY,
                      imagePath: ImagePath.EMPTY_LiST_ICON,
                      onPressed: () {
                        if (widget.participantUser.assignedById == null ||
                            widget.participantUser.assignedById == '') {
                          showAlertDialog(
                            context,
                            title: StringConst.FORM_WARNING,
                            content: StringConst.IPIL_WARNING_TECHNICAL,
                            defaultActionText: StringConst.FORM_ACCEPT,
                          );
                          return;
                        }
                        setState(() {
                          ParticipantIPILPage.selectedIndexIpils.value = 2;
                        });
                      },
                    )
                  : listIpils(ipilEntries),
              SizedBox(height: 20),
            ],
          );
        });
  }

  Widget listIpils(List<IpilEntry> ipilEntries) {
    ipilEntriesPage = ipilEntries;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ipilEntries.length,
      itemBuilder: (context, index) {
        final ipilEntry = ipilEntries[index];
        return ExpandableIpilEntryWrapper(
          key: ValueKey(ipilEntry.ipilId),
          ipilEntry: ipilEntry,
          participantUser: widget.participantUser,
          editIpilEntry: () {
            setState(() {
              selectedIpil = ipilEntry;
              ParticipantIPILPage.selectedIndexIpils.value = 3;
            });
          },
        );
      },
    );
  }

  Widget objectivePageContent(IpilObjectives ipilObjectives) {
    final database = Provider.of<Database>(context, listen: false);

    TextEditingController short1 =
        TextEditingController(text: ipilObjectives.monthShort1 ?? '');
    TextEditingController short2 =
        TextEditingController(text: ipilObjectives.monthShort2 ?? '');
    TextEditingController short3 =
        TextEditingController(text: ipilObjectives.monthShort3 ?? '');
    TextEditingController medium1 =
        TextEditingController(text: ipilObjectives.monthMedium1 ?? '');
    TextEditingController medium2 =
        TextEditingController(text: ipilObjectives.monthMedium2 ?? '');
    TextEditingController medium3 =
        TextEditingController(text: ipilObjectives.monthMedium3 ?? '');
    TextEditingController long1 =
        TextEditingController(text: ipilObjectives.monthLong1 ?? '');
    TextEditingController long2 =
        TextEditingController(text: ipilObjectives.monthLong2 ?? '');
    TextEditingController long3 =
        TextEditingController(text: ipilObjectives.monthLong3 ?? '');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 40),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleObjectives('Revisión de objetivos de 1-3 meses '),
              SpaceH16(),
              CustomTextFormFieldTitle(
                labelText: 'Corto plazo',
                hintText:
                    'Detalla los objetivos, metas, aspiraciones del participante.',
                controller: short1,
              ),
              SpaceH16(),
              CustomTextFormFieldTitle(
                labelText: 'Medio plazo',
                hintText:
                    'Detalla los objetivos, metas, aspiraciones del participante.',
                controller: medium1,
              ),
              SpaceH16(),
              CustomTextFormFieldTitle(
                labelText: 'Largo plazo',
                hintText:
                    'Detalla los objetivos, metas, aspiraciones del participante.',
                controller: long1,
              ),
              SpaceH50(),
              titleObjectives('Revisión de objetivos de 3-6 meses '),
              SpaceH16(),
              CustomTextFormFieldTitle(
                labelText: 'Corto plazo',
                hintText:
                    'Detalla los objetivos, metas, aspiraciones del participante.',
                controller: short2,
              ),
              SpaceH16(),
              CustomTextFormFieldTitle(
                labelText: 'Medio plazo',
                hintText:
                    'Detalla los objetivos, metas, aspiraciones del participante.',
                controller: medium2,
              ),
              SpaceH16(),
              CustomTextFormFieldTitle(
                labelText: 'Largo plazo',
                hintText:
                    'Detalla los objetivos, metas, aspiraciones del participante.',
                controller: long2,
              ),
              SpaceH50(),
              titleObjectives('Revisión de objetivos de 6-12 meses '),
              SpaceH16(),
              CustomTextFormFieldTitle(
                labelText: 'Corto plazo',
                hintText:
                    'Detalla los objetivos, metas, aspiraciones del participante.',
                controller: short3,
              ),
              SpaceH16(),
              CustomTextFormFieldTitle(
                labelText: 'Medio plazo',
                hintText:
                    'Detalla los objetivos, metas, aspiraciones del participante.',
                controller: medium3,
              ),
              SpaceH16(),
              CustomTextFormFieldTitle(
                labelText: 'Largo plazo',
                hintText:
                    'Detalla los objetivos, metas, aspiraciones del participante.',
                controller: long3,
              ),
            ],
          ),
          SpaceH30(),
          Container(
            height: 50,
            width: 150,
            child: ElevatedButton(
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                              title: Text(StringConst.SAVE_SUCCEED,
                                  style: TextStyle(
                                    color: AppColors.greyDark,
                                    height: 1.5,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  )),
                              actions: <Widget>[
                                ElevatedButton(
                                    onPressed: () {
                                      database.setIpilObjectives(IpilObjectives(
                                        ipilObjectivesId:
                                            ipilObjectives.ipilObjectivesId,
                                        userId: ipilObjectives.userId,
                                        monthShort1: short1.text,
                                        monthShort2: short2.text,
                                        monthShort3: short3.text,
                                        monthMedium1: medium1.text,
                                        monthMedium2: medium2.text,
                                        monthMedium3: medium3.text,
                                        monthLong1: long1.text,
                                        monthLong2: long2.text,
                                        monthLong3: long3.text,
                                      ));
                                      Navigator.of(context).pop();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(StringConst.OK,
                                          style: TextStyle(
                                              color: AppColors.black,
                                              height: 1.5,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14)),
                                    )),
                              ]));
                },
                child: Text(
                  StringConst.SAVE,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.turquoiseButton,
                  shadowColor: Colors.transparent,
                )),
          ),
        ],
      ),
    );
  }

  Widget objectivePage() {
    return StreamBuilder<IpilObjectives>(
        stream: _ipilObjectivesStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            IpilObjectives ipilObjectivesSaved = snapshot.data!;
            return objectivePageContent(ipilObjectivesSaved);
          } else {
            if (widget.participantUser.ipilObjectivesId == null &&
                snapshot.connectionState != ConnectionState.waiting) {
              IpilObjectives ipilObjectivesNew =
                  IpilObjectives(userId: widget.participantUser.userId);
              _database.addIpilObjectives(ipilObjectivesNew);
            }
            return Container(
              height: 300,
            );
          }
        });
  }

  Widget titleObjectives(String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 18,
        color: AppColors.turquoiseBlue,
      ),
    );
  }
}

class ExpandableIpilEntryWrapper extends StatefulWidget {
  final IpilEntry ipilEntry;
  final UserEnreda participantUser;
  final VoidCallback editIpilEntry;

  const ExpandableIpilEntryWrapper({
    Key? key,
    required this.ipilEntry,
    required this.participantUser,
    required this.editIpilEntry,
  }) : super(key: key);

  @override
  State<ExpandableIpilEntryWrapper> createState() =>
      _ExpandableIpilEntryWrapperState();
}

class _ExpandableIpilEntryWrapperState
    extends State<ExpandableIpilEntryWrapper> {
  late Future<void> _loadingFuture;
  String? techNameComplete;

  @override
  void initState() {
    super.initState();
    _loadingFuture = _loadData();
  }

  Future<void> _loadData() async {
    final database = Provider.of<Database>(context, listen: false);
    final cache = LocationCache.instance;

    // Resolve labels synchronously from cache
    widget.ipilEntry.reinforcementsText =
        cache.getReinforcementLabels(widget.ipilEntry.reinforcement ?? []);
    widget.ipilEntry.specificSkillsText =
        cache.getSpecificSkillsLabels(widget.ipilEntry.specificSkills ?? []);
    widget.ipilEntry.softSkillsText =
        cache.getSoftSkillsLabels(widget.ipilEntry.softSkills ?? []);
    widget.ipilEntry.digitalSkillsText =
        cache.getDigitalSkillsLabels(widget.ipilEntry.digitalSkills ?? []);
    widget.ipilEntry.laborSkillsText =
        cache.getLaborSkillsLabels(widget.ipilEntry.laborSkills ?? []);
    widget.ipilEntry.contextualizationText = cache
        .getContextualizationLabels(widget.ipilEntry.contextualization ?? []);
    widget.ipilEntry.intermediationsText =
        cache.getIntermediationsLabels(widget.ipilEntry.intermediations ?? []);
    widget.ipilEntry.connectionTerritoryText =
        cache.getConnectionTerritoryLabels(
            widget.ipilEntry.connectionTerritory ?? []);
    widget.ipilEntry.interviewsText =
        cache.getInterviewsLabels(widget.ipilEntry.interviews ?? []);
    widget.ipilEntry.obtainingEmploymentText =
        cache.getObtainingEmploymentLabels(
            widget.ipilEntry.obtainingEmployment ?? []);
    widget.ipilEntry.improvingEmploymentText =
        cache.getImprovingEmploymentLabels(
            widget.ipilEntry.improvingEmployment ?? []);
    widget.ipilEntry.coordinationText =
        cache.getCoordinationLabels(widget.ipilEntry.coordination ?? []);
    widget.ipilEntry.legalText =
        cache.getLegalLabels(widget.ipilEntry.legal ?? []);
    widget.ipilEntry.postWorkSupportText =
        cache.getPostWorkSupportLabels(widget.ipilEntry.postWorkSupport ?? []);
    widget.ipilEntry.economicBagText =
        cache.getEconomicBagLabels(widget.ipilEntry.economicBag ?? []);

    // Tech user lookup (already has a cache inside LocationCache.getUser)
    final techUser =
        await cache.getUser(database, widget.ipilEntry.techId ?? '');
    if (techUser != null) {
      techNameComplete = '${techUser.firstName} ${techUser.lastName}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return ExpandableIpilEntryTile(
          ipilEntry: widget.ipilEntry,
          techNameComplete: techNameComplete,
          participantUser: widget.participantUser,
          editIpilEntry: widget.editIpilEntry,
        );
      },
    );
  }
}
