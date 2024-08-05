import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/models/documentCategory.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import '../../../../utils/responsive.dart';
import '../../../../values/values.dart';
import 'documentCategoryTile.dart';

class ExpandableDocCategoryTile extends StatefulWidget {
  const ExpandableDocCategoryTile({
    Key? key,
    required this.documentCategory,
  }) : super(key: key);
  final DocumentCategory documentCategory;

  @override
  State<ExpandableDocCategoryTile> createState() =>
      _ExpandableDocCategoryTileState();
}

class _ExpandableDocCategoryTileState extends State<ExpandableDocCategoryTile> {
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
    List<DocumentCategory> documentCategories = [];
    documentCategories.add(widget.documentCategory);
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
                color: AppColors.greySearch,
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
              header: CustomTextBold(title: '${(widget.documentCategory.name)}', color: AppColors.primary900),
              expanded: DocumentCategoryTile(
                documentCategory: widget.documentCategory,
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
                ],
              )),
        ],
      ),
    );
  }
}
