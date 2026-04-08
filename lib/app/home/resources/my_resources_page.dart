
import 'package:enreda_empresas/app/home/resources/resources_list.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/custom_text.dart';
import '../../services/auth.dart';
import '../../services/database.dart';
import '../../services/location_cache.dart';
import '../external_social_entity/filter_text_field_row.dart';
import 'global.dart' as globals;

class MyResourcesPage extends StatefulWidget {
  const MyResourcesPage({Key? key}) : super(key: key);

  @override
  _MyResourcesPageState createState() => _MyResourcesPageState();
}

class _MyResourcesPageState extends State<MyResourcesPage> {
  String searchText = "";
  final _searchTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool focused = false;
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

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && !FocusScope.of(context).hasPrimaryFocus) {
      FocusScope.of(context).requestFocus();
    }

    if (_isLoading || _user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        _buildFilterRow(),
        Container(
          margin: const EdgeInsets.only(top: 70),
          child: StreamBuilder<void>(
            stream: LocationCache.instance.resourceUpdates,
            builder: (context, _) {
              final count = LocationCache.instance.resources.length;
              final label = count == 1
                  ? '$count recurso creado por ${globals.currentUserSocialEntity?.name}'
                  : '$count recursos creados por ${globals.currentUserSocialEntity?.name}';
              return CustomTextBoldTitle(title: label);
            },
          ),
        ),
        Container(
            margin: const EdgeInsets.only(top: 120),
            child: ResourcesList(searchText: searchText,)),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterTextFieldRow(
          searchTextController: _searchTextController,
          onPressed: () => setState(() {
            searchText = _searchTextController.text;
          }),
          onFieldSubmitted: (value) => setState(() {
            searchText = _searchTextController.text;
          }),
          clearFilter: () => _clearFilter(),
          hintText: 'Busca recurso por nombre o ubicación...',
        ),
      ],
    );
  }

  void _clearFilter() {
    setStateIfMounted(() {
      _searchTextController.clear();
      searchText = '';
    });
  }

}


