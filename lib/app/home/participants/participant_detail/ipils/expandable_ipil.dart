import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/models/ipilEntry.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  }) : super(key: key);
  final IpilEntry ipilEntry;
  final String? techNameComplete;
  final UserEnreda participantUser;

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
    String dateEntry = formatter.format(widget.ipilEntry.date);
    List<IpilEntry> ipilEntries = [];
    ipilEntries.add(widget.ipilEntry);
    return InkWell(
      onTap: () {
        controller.toggle();
      },
      child: Stack(
        children: [
          Container(
            margin: Responsive.isMobile(context) ? EdgeInsets.only(bottom: 20) : EdgeInsets.only(
                top: 4.0, left: 4.0, right: 4.0, bottom: 10),
            padding: Responsive.isMobile(context) ?
            EdgeInsets.symmetric(horizontal: 8.0, vertical: 10) :
            EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            decoration: BoxDecoration(
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
              ),
              collapsed: Container(),
              theme: ExpandableThemeData(
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
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          border: Border.all(color: AppColors.greyBorder, width: 1),
                          color: Colors.white,
                          shape: BoxShape.circle),
                      child: Image.asset(
                        imagePath,
                        color: AppColors.primary900,
                      )),
                  SizedBox(width: 20),
                  Container(
                    width: 30,
                    height: 30,
                    child: InkWell(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MyIpilEntries(
                                    user: widget.participantUser,
                                    ipilEntries: ipilEntries,
                                    techName: widget.techNameComplete!,
                                  )),
                        );
                      },
                      child: Image.asset(
                        ImagePath.PERSONAL_DOCUMENTATION_DOWNLOAD,
                        scale: 2,
                    )),
                  )
                ],
              )),
        ],
      ),
    );
  }
}
