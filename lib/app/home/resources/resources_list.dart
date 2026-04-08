import 'package:enreda_empresas/app/common_widgets/no_resources_illustration.dart';
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

  List<Resource> _filteredResources() {
    final all = LocationCache.instance.resources;
    final query = widget.searchText.trim().toLowerCase();
    if (query.isEmpty) return all;
    return all
        .where((r) =>
            r.title.toLowerCase().contains(query) ||
            (r.cityName ?? '').toLowerCase().contains(query) ||
            (r.provinceName ?? '').toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: _buildContents(context),
    );
  }

  Widget _buildContents(BuildContext context) {
    if (_isLoading || _user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final socialEntity = LocationCache.instance.socialEntitiesCache[_user!.socialEntityId!];

    return StreamBuilder<void>(
      stream: LocationCache.instance.resourceUpdates,
      builder: (context, _) {
        if (LocationCache.instance.resources.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(Sizes.kDefaultPaddingDouble),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final resources = _filteredResources();
        if (resources.isEmpty) {
          return NoResourcesIllustration(
            title: StringConst.NO_RESOURCES_TITLE,
            subtitle: StringConst.NO_RESOURCES_DESCRIPTION,
            imagePath: ImagePath.FAVORITES_ILLUSTRATION,
          );
        }

        final double extent = Responsive.isMobile(context) ? 191.0 : 248;
        return GridView.builder(
          padding: Responsive.isMobile(context) ? EdgeInsets.zero : const EdgeInsets.all(4.0),
          itemCount: resources.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 520,
            mainAxisExtent: extent,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
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
                  MyResourcesListPage.selectedIndex.value = 2;
                }),
              ),
            );
          },
        );
      },
    );
  }
}
