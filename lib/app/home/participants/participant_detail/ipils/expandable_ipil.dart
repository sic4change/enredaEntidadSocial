import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/models/initialReport.dart';
import 'package:enreda_empresas/app/models/ipilEntry.dart';
import 'package:enreda_empresas/app/services/auth.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../models/userEnreda.dart';
import '../../../../utils/responsive.dart';
import '../../../../values/values.dart';
import '../../pdf_generator/ipils_print/pdf_ipil_preview.dart';
import 'ipil_entry_tile.dart';

class ExpandableIpilEntryTile extends StatefulWidget {
  const ExpandableIpilEntryTile({
    Key? key,
    required this.ipilEntry,
    required this.techNameComplete,
    required this.participantUser,
    required this.editIpilEntry,
  }) : super(key: key);
  final IpilEntry ipilEntry;
  final String? techNameComplete;
  final UserEnreda participantUser;
  final GestureDoubleTapCallback editIpilEntry;

  @override
  State<ExpandableIpilEntryTile> createState() =>
      _ExpandableIpilEntryTileState();
}

class _ExpandableIpilEntryTileState extends State<ExpandableIpilEntryTile> {
  final controller = ExpandableController();
  String imagePath = ImagePath.ARROW_DOWN;

  @override
  void initState() {
    controller.addListener(() {
      setState(() {
        imagePath =
        controller.expanded ? ImagePath.ARROW_UP : ImagePath.ARROW_DOWN;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final auth = Provider.of<AuthBase>(context, listen: false);
    String dateEntry = formatter.format(widget.ipilEntry.lastUpdateDate!);
    List<IpilEntry> ipilEntries = [];
    final database = Provider.of<Database>(context, listen: false);
    int subsidy = 0;
    ipilEntries.add(widget.ipilEntry);
    return InkWell(
      onTap: () {
        controller.toggle();
      },
      child: Stack(
        children: [
          Container(
            margin: Responsive.isMobile(context) ? const EdgeInsets.only(bottom: 20) : const EdgeInsets.only(
                top: 4.0, left: 4.0, right: 4.0, bottom: 10),
            padding: Responsive.isMobile(context) ?
            const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10) :
            const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 0.0,
                    offset: Offset(0.0, 1.0),
                  ),
                ]),
            child: ExpandablePanel(
              controller: controller,
              header: Row(
                children: [
                  CustomTextBold(title: 'IPIL/'),
                  CustomTextBold(title: '${(widget.participantUser.firstName?.toUpperCase() ?? '').substring(0, 1)}'
                      '${(widget.participantUser.lastName?.toUpperCase() ?? '').substring(0, 1)} - '),
                  CustomTextSmall(text: dateEntry),
                ],
              ),
              expanded: IpilEntryTile(
                ipilEntry: widget.ipilEntry,
                techNameComplete: widget.techNameComplete,
                onDelete: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext ctx) {
                      return AlertDialog(
                        title: Text(StringConst.FORM_WARNING),
                        content: const Text('¿Estás seguro? Vas a borrar este Ipil para usuario. Una vez borrado no se podrá recuperar.'),
                        actions: [
                          TextButton(
                            child: Text(StringConst.CANCEL),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                          TextButton(
                            child: const Text('Sí, borrar'),
                            onPressed: () async {
                              Navigator.of(ctx).pop();
                              await database.deleteIpilEntry(widget.ipilEntry);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              collapsed: Container(),
              theme: const ExpandableThemeData(
                hasIcon: false,
              ),
            ),
          ),
          Positioned(
              bottom: Responsive.isMobile(context) ? 25 : 15,
              right: Responsive.isMobile(context) ?  10 : 40,
              child: Row(
                children: [
                  Container(
                      width: 30,
                      height: 30,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          border: Border.all(color: AppColors.greyBorder, width: 1),
                          color: Colors.white,
                          shape: BoxShape.circle),
                      child: Image.asset(
                        imagePath,
                        color: AppColors.primary900,
                      )),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  StreamBuilder<InitialReport>(
                              stream: database.initialReportsStreamByUserId(widget.participantUser.userId),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data!.finished ?? false) {
                                    subsidy = StringConst.getSubsidyIndex(snapshot.data!.subsidy);
                                  }
                                }
                                return MyIpilEntries(
                                  user: widget.participantUser,
                                  ipilEntries: ipilEntries,
                                  techName: widget.techNameComplete ?? '',
                                  subsidy: subsidy,
                                );
                              }
                            )),
                        );
                      },
                      child: Image.asset(
                        ImagePath.PERSONAL_DOCUMENTATION_DOWNLOAD,
                        scale: 2,
                    )),
                  ),
                if (auth.currentUser!.uid == widget.ipilEntry.techId) ...[
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: InkWell(
                      onTap: widget.editIpilEntry,
                      child: Image.asset(
                        ImagePath.PERSONAL_DOCUMENTATION_EDIT,
                        scale: 2,
                    )),
                  ),
                ]
                ],
              )),
        ],
      ),
    );
  }
}
