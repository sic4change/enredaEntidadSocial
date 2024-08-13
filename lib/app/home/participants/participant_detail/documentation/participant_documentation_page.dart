
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/documentation/expandable_document_category.dart';
import 'package:enreda_empresas/app/home/resources/list_item_builder.dart';
import 'package:enreda_empresas/app/models/documentCategory.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ParticipantDocumentationPage extends StatefulWidget {
  ParticipantDocumentationPage({required this.participantUser, super.key});

  final UserEnreda participantUser;

  @override
  State<ParticipantDocumentationPage> createState() => _ParticipantDocumentationPageState();
}

class _ParticipantDocumentationPageState extends State<ParticipantDocumentationPage> {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<UserEnreda>(
        stream: database.userEnredaStreamByUserId(widget.participantUser.userId),
        builder: (context, snapshot) {
            return Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                    border: Border.all(color: AppColors.greyBorder)
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: Responsive.isMobile(context) ? EdgeInsets.only(left: 20.0 , top: 10)
                          : EdgeInsets.only(left: 50, top: 15, bottom: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomTextBoldTitle(title: StringConst.PERSONAL_DOCUMENTATION.toUpperCase()),
                        ],
                      ),
                    ),
                    Divider(color: AppColors.greyBorder, height: 0,),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: Responsive.isMobile(context) ? EdgeInsets.only(left: 20.0, top: 10, bottom: 10)
                            : EdgeInsets.only(left: 50, top: 10, bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                width: Responsive.isMobile(context) ? 170 : Responsive.isDesktopS(context) ? 220 : 370,
                                child: CustomTextSmallIcon(text: 'Nombre del documento')),
                            Spacer(),
                            Container(
                                width: 85,
                                child: CustomTextSmallIcon(text: 'Creado el')),
                            Spacer(),
                            Container(
                                width: 88,
                                child: CustomTextSmallIcon(text: 'Renovar el')),
                            Spacer(),
                            Container(
                                width: 94,
                                child: CustomTextSmallIcon(text: 'Creado por')),
                            Spacer(),
                            Container(
                              width: Responsive.isMobile(context) ? 25 : 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(color: AppColors.greyBorder, height: 0,),
                    documentCategoriesList(widget.participantUser),
                  ],
                ));
          }
      );
  }

  Widget documentCategoriesList(UserEnreda participantUser) {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<List<DocumentCategory>>(
      stream: database.documentCategoriesStream(),
      builder: (context, documentCategoriesSnapshot) {
        if (!documentCategoriesSnapshot.hasData) return Container();
        return ListItemBuilder<DocumentCategory>(
          snapshot: documentCategoriesSnapshot,
          itemBuilder: (context, documentCategory) {
            return ExpandableDocCategoryTile(documentCategory: documentCategory, participantUser: participantUser);
          },
        );
      },
    );
  }
}
