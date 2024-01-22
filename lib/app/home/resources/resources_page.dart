import 'package:cached_network_image/cached_network_image.dart';
import 'package:enreda_empresas/app/common_widgets/alert_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/build_share_button.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/enreda_button.dart';
import 'package:enreda_empresas/app/common_widgets/precached_avatar.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/resources/edit_resource/edit_resource.dart';
import 'package:enreda_empresas/app/home/resources/list_item_builder.dart';
import 'package:enreda_empresas/app/home/resources/list_item_builder_grid.dart';
import 'package:enreda_empresas/app/home/resources/my_resources_list_page.dart';
import 'package:enreda_empresas/app/home/resources/resource_detail_dialog.dart';
import 'package:enreda_empresas/app/home/resources/resource_interests_stream.dart';
import 'package:enreda_empresas/app/home/resources/resource_list_tile.dart';
import 'package:enreda_empresas/app/models/city.dart';
import 'package:enreda_empresas/app/models/country.dart';
import 'package:enreda_empresas/app/models/interest.dart';
import 'package:enreda_empresas/app/models/province.dart';
import 'package:enreda_empresas/app/models/resource.dart';
import 'package:enreda_empresas/app/models/resourcePicture.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/auth.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'global.dart' as globals;

class ResourcesListPage extends StatefulWidget {
  const ResourcesListPage({Key? key}) : super(key: key);

  @override
  State<ResourcesListPage> createState() => _ResourcesListPageState();
}

class _ResourcesListPageState extends State<ResourcesListPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildResourcesList(context);
  }

  Widget _buildResourcesList(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    return Flex(
      direction: Axis.vertical,
      children: [
        Expanded(
          flex: 2,
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: Sizes.mainPadding * 3),
                child: StreamBuilder<UserEnreda>(
                    stream: database.userEnredaStreamByUserId(auth.currentUser!.uid),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasData) {
                        var user = snapshot.data!;
                        return StreamBuilder<List<Resource>>(
                            stream: database.myResourcesStream(user.socialEntityId!),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasData) {
                                return ListItemBuilderGrid<Resource>(
                                  snapshot: snapshot,
                                  fitSmallerLayout: false,
                                  itemBuilder: (context, resource) {
                                    if (!snapshot.hasData) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }
                                    if (snapshot.hasData) {
                                      return StreamBuilder<SocialEntity>(
                                        stream: database.socialEntityStreamById(user.socialEntityId!),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return const Center(
                                                child: CircularProgressIndicator());
                                          }
                                          final SocialEntity? socialEntity = snapshot.data;
                                          resource.organizerName = socialEntity == null ? '' : socialEntity.name;
                                          resource.organizerImage = socialEntity == null ? '' : socialEntity.photo;
                                          resource.setResourceTypeName();
                                          resource.setResourceCategoryName();
                                          return Container(
                                            key: Key('resource-${resource.resourceId}'),
                                            child: ResourceListTile(
                                              resource: resource,
                                              onTap: () =>
                                                  setState(() {
                                                    globals.currentResource = resource;
                                                    MyResourcesListPage.selectedIndex.value = 2;
                                                  }),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                    return const Center(child: CircularProgressIndicator());
                                  },
                                  emptyTitle: 'Sin recursos',
                                  emptyMessage: 'Aún no has creado ningún recurso',
                                );
                              }
                              return const Center(child: CircularProgressIndicator());
                            });
                      }
                      return const Center(child: CircularProgressIndicator());
                    }),
              ),
              Row(
                children: [
                  CustomTextBoldTitle(title: 'Recursos creados'),
                  Spacer(),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: Sizes.mainPadding),
        Expanded(
          flex: 2,
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: Sizes.mainPadding * 3),
                child: StreamBuilder<List<Resource>>(
                    stream: database.resourcesStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      if (snapshot.hasData) {
                        return ListItemBuilderGrid<Resource>(
                          snapshot: snapshot,
                          fitSmallerLayout: false,
                          itemBuilder: (context, resource) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (snapshot.hasData) {
                              return StreamBuilder<SocialEntity>(
                                stream: database.socialEntityStreamById(resource.organizer),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  final SocialEntity? socialEntity = snapshot.data;
                                  resource.organizerName = socialEntity == null ? '' : socialEntity.name;
                                  resource.organizerImage = socialEntity == null ? '' : socialEntity.photo;
                                  resource.setResourceTypeName();
                                  resource.setResourceCategoryName();
                                  return Stack(
                                    children: [
                                      Container(
                                        key: Key('resource-${resource.resourceId}'),
                                        child: ResourceListTile(
                                          resource: resource,
                                          onTap: () =>
                                              setState(() {
                                                globals.currentResource = resource;
                                                MyResourcesListPage.selectedIndex.value = 2;
                                              }),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                            return const Center(child: CircularProgressIndicator());
                          },
                          emptyTitle: 'Sin recursos',
                          emptyMessage: 'Aún no has creado ningún recurso',
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    }),
              ),
              Row(
                children: [
                  CustomTextBoldTitle(title: 'Todos los recursos'),
                  Spacer(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

}
