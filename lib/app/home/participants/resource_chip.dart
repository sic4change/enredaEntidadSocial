
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../common_widgets/custom_chip.dart';
import '../../models/city.dart';
import '../../models/country.dart';
import '../../models/province.dart';
import '../../models/resource.dart';
import '../../services/database.dart';
import '../../values/values.dart';

class ResourceChip extends StatelessWidget {
  final Resource resource;
  final Database database;
  final TextTheme textTheme;
  final bool isSelected;
  final VoidCallback onSelected;

  const ResourceChip({
    required this.resource,
    required this.database,
    required this.textTheme,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Country>(
      stream: database.countryStream(resource.country),
      builder: (context, countrySnapshot) {
        final country = countrySnapshot.data;
        resource.countryName = country?.name ?? '';

        return StreamBuilder<Province>(
          stream: database.provinceStream(resource.province),
          builder: (context, provinceSnapshot) {
            final province = provinceSnapshot.data;
            resource.provinceName = province?.name ?? '';

            return StreamBuilder<City>(
              stream: database.cityStream(resource.city),
              builder: (context, citySnapshot) {
                final city = citySnapshot.data;
                resource.cityName = city?.name ?? '';

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
              },
            );
          },
        );
      },
    );
  }
}