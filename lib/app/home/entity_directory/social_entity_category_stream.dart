import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/home/resources/resource_detail_dialog.dart';
import 'package:enreda_empresas/app/home/resources/wrap_builder_list.dart';
import 'package:enreda_empresas/app/models/interest.dart';
import 'package:enreda_empresas/app/models/socialEntitiesType.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TypesBySocialEntity extends StatelessWidget {
  const TypesBySocialEntity({super.key, required this.typesIdList});

  final List<String?> typesIdList;

  @override
  Widget build(BuildContext context) {
    return _buildContents(context);
  }

  Widget _buildContents(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<List<SocialEntitiesType>>(
        stream: database.socialEntitiesTypeStream(),
        builder: (context, snapshot) {
          return snapshot.hasData && snapshot.data!.isNotEmpty
              ? WrapBuilderList<SocialEntitiesType>(
            emptyTitle: 'Sin sectores',
            emptyMessage: 'La entidad social no tiene sectores',
            snapshot: snapshot,
            itemBuilder: (context, socialEntityType) {
              for (var socialEntityTypeId in typesIdList) {
                if (socialEntityType.id == socialEntityTypeId) {
                  return Container(
                      key: Key(
                          'socialEntityType-${socialEntityType.id}'),
                      child: Container(
                          margin: const EdgeInsets.only(left: 0, right: 5, top: 5, bottom: 5),
                          decoration: BoxDecoration(
                            color: AppColors.turquoiseBlue,
                            border: Border.all(
                                color: AppColors.turquoiseBlue.withOpacity(0.2),
                                width: 1),
                            borderRadius:
                            BorderRadius.circular(
                                Consts.padding),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                            child: Text(
                                socialEntityType.name, style: TextStyle(color: Colors.white, fontSize: 14),),
                          )));
                }

              }
              return Container();
            },

          )
              : snapshot.connectionState == ConnectionState.active
              ? const CustomTextTitle(
              title: '¡La entidad social aun no tiene sectores!')
              : const Center(child: CircularProgressIndicator());
          ;
        });
  }

}
