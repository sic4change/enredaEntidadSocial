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

  void _preloadCreatorPhotos(
      Database database, List<DocumentationParticipant> documents) {
    for (final document in documents) {
      final createdBy = document.createdBy;
      if (createdBy == null || createdBy.isEmpty) continue;
      if (_creatorPhotoById.containsKey(createdBy) ||
          _loadingCreatorIds.contains(createdBy)) continue;
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
            final documentSubCategories = LocationCache
                .instance.personalDocumentTypes
                .where((dt) =>
                    dt.documentCategoryId ==
                    widget.documentCategory.documentCategoryId)
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
                      padding: Responsive.isMobile(context)
                          ? const EdgeInsets.only(left: 0.0, right: 0.0)
                          : const EdgeInsets.symmetric(
                              horizontal: 55.0, vertical: 0.0),
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
                                        builder: (context) {
                                          return AddDocumentsForm(
                                            documentSubCategory:
                                                documentSubCategory,
                                            participantUser:
                                                widget.participantUser,
                                          );
                                        });
                                  },
                                  child: Image.asset(
                                    ImagePath.ICON_PLUS,
                                    height:
                                        Responsive.isMobile(context) ? 25 : 30,
                                  )),
                            ],
                          ),
                          SizedBox(height: 10),
                          documentationParticipantBySubCategory(
                              documentSubCategory, widget.participantUser),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: AppColors.greyDropMenuBorder,
                    ),
                  ],
                );
              },
            );
          })(),
        ],
      ),
    );
  }

  Widget documentationParticipantBySubCategory(
      PersonalDocumentType documentSubCategory, UserEnreda participantUser) {
    final database = Provider.of<Database>(context, listen: false);
    final DateFormat formatter = Responsive.isMobile(context)
        ? DateFormat('dd/MM')
        : DateFormat('dd/MM/yyyy');
    return StreamBuilder<List<DocumentationParticipant>>(
      stream: database.documentationParticipantBySubCategoryStream(
          documentSubCategory, participantUser),
      builder: (context, documentationParticipantSnapshot) {
        if (!documentationParticipantSnapshot.hasData) return Container();
        if (documentationParticipantSnapshot.hasData) {
          final documents = documentationParticipantSnapshot.data!;
          _preloadCreatorPhotos(database, documents);
          return ListItemBuilder<DocumentationParticipant>(
            emptyTitle: 'Sin documentos',
            emptyMessage: 'Aún no se ha agreado ningún documento',
            snapshot: documentationParticipantSnapshot,
            itemBuilder: (context, documentParticipant) {
              return _DocumentItemTile(
                documentParticipant: documentParticipant,
                formatter: formatter,
                documentSubCategory: documentSubCategory,
                participantUser: participantUser,
                creatorPhoto:
                    _creatorPhotoById[documentParticipant.createdBy] ?? '',
              );
            },
          );
        }
        ;
        return Container();
      },
    );
  }
}

class _DocumentItemTile extends StatefulWidget {
  const _DocumentItemTile({
    required this.documentParticipant,
    required this.formatter,
    required this.documentSubCategory,
    required this.participantUser,
    required this.creatorPhoto,
  });

  final DocumentationParticipant documentParticipant;
  final DateFormat formatter;
  final PersonalDocumentType documentSubCategory;
  final UserEnreda participantUser;
  final String creatorPhoto;

  @override
  State<_DocumentItemTile> createState() => _DocumentItemTileState();
}

class _DocumentItemTileState extends State<_DocumentItemTile> {
  bool _showObservations = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                Icons.file_copy_outlined,
                color: AppColors.greyAlt,
                size: 20.0,
              ),
              SizedBox(width: 10),
              Container(
                  alignment: Alignment.centerLeft,
                  width: Responsive.isMobile(context)
                      ? 150
                      : Responsive.isDesktopS(context)
                          ? 200
                          : 350,
                  height: 30,
                  child: CustomTextSmall(
                    text: widget.documentParticipant.name,
                    height: 1,
                  )),
              Spacer(),
              Container(
                  width: Responsive.isMobile(context) ? 50 : 85,
                  child: CustomTextSmall(
                    text: widget.formatter
                        .format(widget.documentParticipant.createDate),
                    color: AppColors.primary900,
                  )),
              const SizedBox(width: 15),
              widget.documentParticipant.renovationDate == null
                  ? Container(width: Responsive.isMobile(context) ? 50 : 85)
                  : Container(
                      width: Responsive.isMobile(context) ? 50 : 85,
                      child: CustomTextSmall(
                        text: widget.formatter
                            .format(widget.documentParticipant.renovationDate!),
                        color: AppColors.primary900,
                      ),
                    ),
              const SizedBox(width: 25),
              Responsive.isMobile(context)
                  ? Container()
                  : Container(
                      width: 25,
                      height: 25,
                      child: _DocumentCreatedByIcon(
                        photoUrl: widget.creatorPhoto,
                      ),
                    ),
              Spacer(),
              Container(
                width: 30,
                alignment: Alignment.center,
                child: widget.documentParticipant.observations != null &&
                        widget.documentParticipant.observations!.trim().isNotEmpty
                    ? InkWell(
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            _showObservations = !_showObservations;
                          });
                        },
                        child: Image.asset(
                          ImagePath.ICON_OBSERVATIONS_BUBBLE,
                          width: 18,
                          height: 18,
                          color: _showObservations ? const Color(0xFF18C5C1) : const Color(0xFF535A5F),
                        ),
                      )
                    : const SizedBox(),
              ),
              const SizedBox(width: 10),
              Container(
                alignment: Alignment.center,
                width: Responsive.isMobile(context) ? 25 : 30,
                child: PopupMenuButton<MenuItem>(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  surfaceTintColor: Colors.white,
                  iconColor: AppColors.primary900,
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.more_horiz,
                    color: AppColors.primary900,
                  ),
                  offset: Offset.fromDirection(0.6, 100),
                  iconSize: 30,
                  tooltip: widget.documentParticipant.name,
                  onSelected: (item) => onSelected(
                      context,
                      item,
                      widget.documentSubCategory,
                      widget.participantUser,
                      widget.documentParticipant),
                  itemBuilder: (context) => [
                    CustomPopupMenuEntry(
                        child: null,
                        documentationParticipant: widget.documentParticipant),
                    ...MenuItems.getItemOpen(context).map(buildItem).toList(),
                    ...MenuItems.getItemDownload(context)
                        .map(buildItem)
                        .toList(),
                    ...MenuItems.getItemEdit(context).map(buildItem).toList(),
                    ...MenuItems.getItemDelete(context)
                        .map(buildItemRed)
                        .toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_showObservations &&
            widget.documentParticipant.observations != null &&
            widget.documentParticipant.observations!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
                left: 0.0, top: 4.0, bottom: 8.0, right: 30.0),
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.greyLetter,
                      height: 1.4,
                    ),
                children: [
                  TextSpan(
                    text: 'Observaciones: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary900,
                    ),
                  ),
                  TextSpan(
                    text: widget.documentParticipant.observations!,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
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
