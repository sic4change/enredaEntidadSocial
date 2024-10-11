import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/empty-list.dart';
import 'package:enreda_empresas/app/common_widgets/enreda_button.dart';
import 'package:enreda_empresas/app/common_widgets/no_resources_illustration.dart';
import 'package:enreda_empresas/app/home/resources/list_item_builder_grid.dart';
import 'package:enreda_empresas/app/home/resources/my_resources_list_page.dart';
import 'package:enreda_empresas/app/home/resources/resource_list_tile.dart';
import 'package:enreda_empresas/app/models/city.dart';
import 'package:enreda_empresas/app/models/country.dart';
import 'package:enreda_empresas/app/models/province.dart';
import 'package:enreda_empresas/app/models/resource.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/auth.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../values/strings.dart';
import 'global.dart' as globals;

class ResourcesList extends StatefulWidget {
  const ResourcesList({Key? key, required this.searchText}) : super(key: key);
  final String searchText;

  @override
  State<ResourcesList> createState() => _ResourcesListState();
}

class _ResourcesListState extends State<ResourcesList> {
  late List<Resource> resources;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildResourcesList(context);
  }

  Widget _buildResourcesList(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.8,
        child: _buildContents(context));
  }

  Widget _buildContents(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<UserEnreda>(
        stream: database.userEnredaStreamByUserId(auth.currentUser!.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            var user = snapshot.data!;
            return StreamBuilder<List<Resource>>(
                stream: database.filteredMyResourcesStream(user.socialEntityId!, widget.searchText),
                builder: (context, snapshot) {
                  if(snapshot.hasData && snapshot.data!.isNotEmpty) {
                    resources = snapshot.data!;
                  }
                  return snapshot.hasData && snapshot.data!.isNotEmpty ?
                  ListItemBuilderGrid<Resource>(
                        snapshot: snapshot,
                        fitSmallerLayout: false,
                        mainAxisExtentValue : Responsive.isMobile(context)? 191.0 : 248,
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
                            return StreamBuilder<Country>(
                                stream: database.countryStream(resource.country),
                                builder: (context, snapshot) {
                                  final country = snapshot.data;
                                  resource.countryName = country == null ? '' : country.name;
                                  return StreamBuilder<Province>(
                                      stream: database.provinceStream(resource.province),
                                      builder: (context, snapshot) {
                                        final province = snapshot.data;
                                        resource.provinceName = province == null ? '' : province.name;
                                        return StreamBuilder<City>(
                                            stream: database.cityStream(resource.city),
                                            builder: (context, snapshot) {
                                              final city = snapshot.data;
                                              resource.cityName = city == null ? '' : city.name;
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
                                            });
                                      });
                                });
                          },
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                                            },
                                            emptyTitle: 'Sin recursos',
                                            emptyMessage: 'Aún no has creado ningún recurso',
                                          ) :
                  snapshot.connectionState == ConnectionState.waiting ?
                  Padding(
                    padding: EdgeInsets.all(Sizes.kDefaultPaddingDouble),
                    child: Center(child: CircularProgressIndicator(),),
                  ) :
                  NoResourcesIllustration(
                    title: StringConst.NO_RESOURCES_TITLE,
                    subtitle: StringConst.NO_RESOURCES_DESCRIPTION,
                    imagePath: ImagePath.FAVORITES_ILLUSTRATION,
                  );
                });
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

}
