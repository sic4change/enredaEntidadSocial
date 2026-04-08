import 'package:enreda_empresas/app/home/resources/list_item_builder_grid.dart';
import 'package:enreda_empresas/app/home/resources/my_resources_list_page.dart';
import 'package:enreda_empresas/app/home/resources/resource_list_tile.dart';
import 'package:enreda_empresas/app/home/web_home.dart';
import 'package:enreda_empresas/app/models/resource.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/auth.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'global.dart' as globals;

class CollapsedResourcesList extends StatefulWidget {
  const CollapsedResourcesList({Key? key, required this.itemsNumber}) : super(key: key);
  final int itemsNumber;

  @override
  State<CollapsedResourcesList> createState() => _CollapsedResourcesListState();
}

class _CollapsedResourcesListState extends State<CollapsedResourcesList> {
  bool _isLoading = true;
  UserEnreda? _user;

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
      });
      if (user?.socialEntityId != null) {
        LocationCache.instance.initResourcesStream(database, user!.socialEntityId!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _user == null) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.28,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final socialEntity = LocationCache.instance.socialEntitiesCache[_user!.socialEntityId!];

    return Container(
      height: MediaQuery.of(context).size.height * 0.28,
      child: StreamBuilder<void>(
        stream: LocationCache.instance.resourceUpdates,
        builder: (context, _) {
          final allResources = LocationCache.instance.resources;
          if (allResources.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final resources = allResources.take(widget.itemsNumber).toList();
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 520,
              mainAxisExtent: Responsive.isMobile(context) ? 180.0 : 248,
            ),
            itemCount: resources.length,
            itemBuilder: (context, index) {
              final resource = resources[index];
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
                    WebHome.goResources();
                    MyResourcesListPage.selectedIndex.value = 2;
                  }),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
