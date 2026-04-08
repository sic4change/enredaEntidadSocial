import 'package:enreda_empresas/app/common_widgets/no_resources_illustration.dart';
import 'package:enreda_empresas/app/home/resources/list_item_builder_grid.dart';
import 'package:enreda_empresas/app/home/resources/my_resources_list_page.dart';
import 'package:enreda_empresas/app/home/resources/resource_list_tile.dart';
import 'package:enreda_empresas/app/models/resource.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/auth.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
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
  bool _isLoading = true;
  UserEnreda? _user;
  Stream<List<Resource>>? _resourcesStream;
  String? _lastSearchText;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    final user = await LocationCache.instance.getUser(database, auth.currentUser!.uid);
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
        if (user?.socialEntityId != null) {
          _resourcesStream = database.filteredMyResourcesStream(user!.socialEntityId!, widget.searchText);
          _lastSearchText = widget.searchText;
        }
      });
    }
  }

  @override
  void didUpdateWidget(ResourcesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchText != _lastSearchText && _user?.socialEntityId != null) {
      final database = Provider.of<Database>(context, listen: false);
      setState(() {
        _resourcesStream = database.filteredMyResourcesStream(_user!.socialEntityId!, widget.searchText);
        _lastSearchText = widget.searchText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.8,
        child: _buildContents(context));
  }

  Widget _buildContents(BuildContext context) {
    if (_isLoading || _user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final socialEntity = LocationCache.instance.socialEntitiesCache[_user!.socialEntityId!];

    return StreamBuilder<List<Resource>>(
        stream: _resourcesStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListItemBuilderGrid<Resource>(
              snapshot: snapshot,
              fitSmallerLayout: false,
              mainAxisExtentValue: Responsive.isMobile(context) ? 191.0 : 248,
              itemBuilder: (context, resource) {
                resource.organizerName = socialEntity?.name ?? '';
                resource.organizerImage = socialEntity?.photo ?? '';
                resource.setResourceTypeName();
                resource.setResourceCategoryName();
                resource.countryName = LocationCache.instance.countryById(resource.country)?.name ?? '';
                resource.provinceName = LocationCache.instance.provinceById(resource.province)?.name ?? '';
                resource.cityName = LocationCache.instance.cityById(resource.city)?.name ?? '';
                return Container(
                  key: Key('resource-${resource.resourceId}'),
                  child: ResourceListTile(
                    resource: resource,
                    onTap: () => setState(() {
                      globals.currentResource = resource;
                      MyResourcesListPage.selectedIndex.value = 2;
                    }),
                  ),
                );
              },
              emptyTitle: 'Sin recursos',
              emptyMessage: 'Aún no has creado ningún recurso',
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: EdgeInsets.all(Sizes.kDefaultPaddingDouble),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return NoResourcesIllustration(
            title: StringConst.NO_RESOURCES_TITLE,
            subtitle: StringConst.NO_RESOURCES_DESCRIPTION,
            imagePath: ImagePath.FAVORITES_ILLUSTRATION,
          );
        });
  }
}
