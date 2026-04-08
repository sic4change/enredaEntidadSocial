
import 'package:flutter/material.dart';

import '../../common_widgets/custom_chip.dart';
import '../../models/resource.dart';
import '../../services/location_cache.dart';
import '../../values/values.dart';

class ResourceChip extends StatelessWidget {
  final Resource resource;
  final TextTheme textTheme;
  final bool isSelected;
  final VoidCallback onSelected;

  const ResourceChip({
    required this.resource,
    required this.textTheme,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    resource.countryName = LocationCache.instance.countryById(resource.country)?.name ?? '';
    resource.provinceName = LocationCache.instance.provinceById(resource.province)?.name ?? '';
    resource.cityName = LocationCache.instance.cityById(resource.city)?.name ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: CustomChip(
        backgroundColor: Colors.white,
        label: resource.title,
        selected: isSelected,
        selectedBackgroundColor: AppColors.primary900,
        textColor: AppColors.primary900,
        onSelect: (_) => onSelected(),
      ),
    );
  }
}
