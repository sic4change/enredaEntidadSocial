
import 'package:enreda_empresas/app/home/resources/resources_list.dart';
import 'package:enreda_empresas/app/models/resource.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/custom_text.dart';
import '../../services/auth.dart';
import '../../services/database.dart';
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

  @override
  void initState() {
    super.initState();
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
    final database = Provider.of<Database>(context, listen: false);
    final auth = Provider.of<AuthBase>(context, listen: false);
    if (kIsWeb && !FocusScope.of(context).hasPrimaryFocus) {
      FocusScope.of(context).requestFocus();
    }
    return Stack(
      children: [
        _buildFilterRow(),
        Container(
          margin: const EdgeInsets.only(top: 70),
          child: StreamBuilder<UserEnreda>(
            stream: database.userEnredaStreamByUserId(auth.currentUser!.uid),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (userSnapshot.hasData && userSnapshot.data != null) {
                var user = userSnapshot.data!;
                return StreamBuilder<List<Resource>>(
                  stream: database.myResourcesStream(user.socialEntityId!),
                  builder: (context, resourceSnapshot) {
                    if (resourceSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (resourceSnapshot.hasData) {
                      List<Resource> resources = resourceSnapshot.data!;
                      if (resources.isNotEmpty) {
                        return CustomTextBoldTitle(
                          title: resources.length == 1
                              ? '${resources.length} recurso creado por ${globals.currentUserSocialEntity?.name}'
                              : '${resources.length} recursos creados por ${globals.currentUserSocialEntity?.name}',
                        );
                      }
                    }
                    return CustomTextBoldTitle(title: '0 recursos creados por ${globals.currentUserSocialEntity?.name}');
                  },
                );
              }
              return const CustomTextBoldTitle(title: 'No hay datos disponibles');
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


