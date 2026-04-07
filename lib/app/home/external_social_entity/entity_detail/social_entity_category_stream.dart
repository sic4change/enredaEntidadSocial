import 'package:enreda_empresas/app/services/location_cache.dart';
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
    final socialEntityTypes = LocationCache.instance.socialEntitiesTypes;
    
    final filteredTypes = socialEntityTypes.where((type) => typesIdList.contains(type.id)).toList();

    if (filteredTypes.isEmpty) {
      if (socialEntityTypes.isEmpty) {
        // Fallback or loading
        return const Center(child: CircularProgressIndicator());
      }
      return const CustomTextTitle(title: '¡La entidad social aun no tiene sectores!');
    }

    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: filteredTypes.map((type) => Container(
          key: Key('socialEntityType-${type.id}'),
          decoration: BoxDecoration(
            color: AppColors.turquoiseBlue,
            border: Border.all(
                color: AppColors.turquoiseBlue.withOpacity(0.2),
                width: 1),
            borderRadius: BorderRadius.circular(Consts.padding),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Text(
                type.name, style: TextStyle(color: Colors.white, fontSize: 14),),
          ))).toList(),
    );
  }

}
