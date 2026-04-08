import 'dart:html';

import 'package:enreda_empresas/app/home/participants/participant_detail/documentation/popup_menu_actions.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/documentation/user_profile_picture.dart';
import 'package:enreda_empresas/app/models/personalDocumentType.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/home/resources/list_item_builder.dart';
import '../../../../models/documentCategory.dart';
import '../../../../models/documentationParticipant.dart';
import '../../../../services/auth.dart';
import '../../../../utils/responsive.dart';
import '../../../../values/values.dart';
import '../../../resources/list_item_builder.dart';
import 'add_documents_form.dart';
import 'custom_menu_entry.dart';
import 'menu_item.dart';
import 'menu_items.dart';

class DocumentCategoryTile extends StatefulWidget {
  const DocumentCategoryTile({
    Key? key,
    required this.documentCategory,
    required this.participantUser,
  }) : super(key: key);
  final DocumentCategory documentCategory;
  final UserEnreda participantUser;

  @override
  State<DocumentCategoryTile> createState() => _DocumentCategoryTileState();
}

class _DocumentCategoryTileState extends State<DocumentCategoryTile> {
  final Map<String, String> _creatorPhotoById = {};
  final Set<String> _loadingCreatorIds = <String>{};

  void _preloadCreatorPhotos(Database database, List<DocumentationParticipant> documents) {
    for (final document in documents) {
      final createdBy = document.createdBy;
      if (createdBy == null || createdBy.isEmpty) continue;
      if (_creatorPhotoById.containsKey(createdBy) || _loadingCreatorIds.contains(createdBy)) continue;
      _loadingCreatorIds.add(createdBy);
      LocationCache.instance.getUser(database, createdBy).then((user) {
        if (!mounted) return;
        setState(() {
          _creatorPhotoById[createdBy] = user?.photo ?? '';
          _loadingCreatorIds.remove(createdBy);
        });
      }).catchError((_) {
        _loadingCreatorIds.remove(createdBy);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (() {
            final documentSubCategories = LocationCache.instance.personalDocumentTypes
                .where((dt) => dt.documentCategoryId == widget.documentCategory.documentCategoryId)
                .toList();
            if (documentSubCategories.isEmpty) return Container();
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: documentSubCategories.length,
              itemBuilder: (context, index) {
                final documentSubCategory = documentSubCategories[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: Responsive.isMobile(context) ? const EdgeInsets.only(left: 0.0, right: 0.0) :
                      const EdgeInsets.symmetric(horizontal: 55.0, vertical: 0.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CustomTextSmall(text: documentSubCategory.title),
                              Spacer(),
                              InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context){
                                        return AddDocumentsForm(
                                          documentSubCategory: documentSubCategory,
                                          participantUser: widget.participantUser,);
                                      }
                                  );
                                },
                                child: Image.asset(
                                  ImagePath.ICON_PLUS,
                                  height: Responsive.isMobile(context) ? 25 : 30,)),
                            ],
                          ),
                          SizedBox(height: 10),
                          documentationParticipantBySubCategory(documentSubCategory, widget.participantUser),
                        ],
                      ),
                    ),
                    Divider(thickness: 1, color: AppColors.greyDropMenuBorder,),
                  ],
                );
              },
            );
          })(),
        ],
      ),
    );
  }

  Widget documentationParticipantBySubCategory(PersonalDocumentType documentSubCategory, UserEnreda participantUser) {
    final database = Provider.of<Database>(context, listen: false);
    final DateFormat formatter = Responsive.isMobile(context) ? DateFormat('dd/MM') : DateFormat('dd/MM/yyyy');
    return StreamBuilder<List<DocumentationParticipant>>(
      stream: database.documentationParticipantBySubCategoryStream(documentSubCategory, participantUser),
      builder: (context, documentationParticipantSnapshot) {
        if (!documentationParticipantSnapshot.hasData) return Container();
        if(documentationParticipantSnapshot.hasData) {
          final documents = documentationParticipantSnapshot.data!;
          _preloadCreatorPhotos(database, documents);
          return ListItemBuilder<DocumentationParticipant>(
            emptyTitle: 'Sin documentos',
            emptyMessage: 'Aún no se ha agreado ningún documento',
            snapshot: documentationParticipantSnapshot,
            itemBuilder: (context, documentParticipant) {
              return Container(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.file_copy_outlined, color: AppColors.greyAlt, size: 20.0,),
                    Container(
                        alignment: Alignment.centerLeft,
                        width: Responsive.isMobile(context) ? 150 : Responsive.isDesktopS(context) ? 200 : 350,
                        height: 30,
                        child: CustomTextSmall(text: documentParticipant.name, height: 1,)),
                    Spacer(),
                    Container(
                        width: Responsive.isMobile(context) ? 50 : 85,
                        child: CustomTextSmall(text: formatter.format(documentParticipant.createDate), color: AppColors.primary900,)),
                    Spacer(),
                    documentParticipant.renovationDate == null ? Container(width: Responsive.isMobile(context) ? 50 : 85) :
                      CustomTextSmall(text: formatter.format(documentParticipant.renovationDate!), color: AppColors.primary900,),
                    Spacer(),
                    Responsive.isMobile(context) ? Container() : _DocumentCreatedByIcon(
                      photoUrl: _creatorPhotoById[documentParticipant.createdBy] ?? '',
                    ),
                    Spacer(),
                    Container(
                      alignment: Alignment.center,
                      width: Responsive.isMobile(context) ? 25 : 30,
                      child: PopupMenuButton<MenuItem>(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        surfaceTintColor: Colors.white,
                        iconColor: AppColors.primary900,
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.more_horiz, color: AppColors.primary900,),
                        offset: Offset.fromDirection(0.6, 100),
                        iconSize: 30,
                        tooltip: documentParticipant.name,
                        onSelected: (item) => onSelected(context, item, documentSubCategory, participantUser, documentParticipant),
                        itemBuilder: (context) => [
                          CustomPopupMenuEntry(child: null, documentationParticipant: documentParticipant),
                          ...MenuItems.getItemOpen(context).map(buildItem).toList(),
                          ...MenuItems.getItemDownload(context).map(buildItem).toList(),
                          ...MenuItems.getItemEdit(context).map(buildItem).toList(),
                          ...MenuItems.getItemDelete(context).map(buildItemRed).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        };
        return Container();
      },
    );
  }
}

class _DocumentCreatedByIcon extends StatelessWidget {
  final String photoUrl;

  const _DocumentCreatedByIcon({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    if (photoUrl.isEmpty) return Container(width: 25, height: 25);
    return UserProfilePicture(context, photoUrl);
  }
}
