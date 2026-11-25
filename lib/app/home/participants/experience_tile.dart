import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/models/experience.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExperienceTile extends StatelessWidget {
  const ExperienceTile({Key? key, required this.experience, this.onTap, required this.type})
      : super(key: key);
  final Experience experience;
  final VoidCallback? onTap;
  final String type;

  bool get _isEducation =>
      experience.type == 'Formativa' || experience.type == 'Complementaria';

  static String _clean(String? value) => (value ?? '').trim();

  /// Título: misma lógica que las plantillas del PDF del CV.
  String _cvTitle() {
    final activity = _clean(experience.activity);
    if (_isEducation) {
      final institution = _clean(experience.institution);
      final nameFormation = _clean(experience.nameFormation);
      if (institution.isNotEmpty && nameFormation.isNotEmpty) {
        return '$institution - $nameFormation';
      }
      return institution.isNotEmpty ? institution : nameFormation;
    }
    if (experience.type == 'Personal') {
      final subtype = _clean(experience.subtype);
      final role = _clean(experience.activityRole);
      if (subtype == 'Responsabilidades familiares' ||
          subtype == 'Compromiso social') return subtype;
      if (activity.isEmpty) return '';
      return [subtype, role, activity].where((e) => e.isNotEmpty).join(' - ');
    }
    return activity;
  }

  /// Subtítulo: "puesto - organización" (experiencias) u organización (formaciones).
  String _cvSubtitle() {
    final organization = _clean(experience.organization);
    if (_isEducation) return organization;
    final position = _clean(experience.position);
    return [position, organization].where((e) => e.isNotEmpty).join(' - ');
  }

  /// Actividades realizadas (solo experiencias profesionales, como en el PDF).
  List<String> _cvActivities() {
    if (experience.type != 'Profesional') return [];
    final text = _clean(experience.professionActivitiesText);
    final items = text.isNotEmpty
        ? text.split(' / ')
        : experience.professionActivities;
    return items.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final DateFormat formatter = DateFormat('yyyy');
    String startDate = experience.startDate != null ? formatter.format(experience.startDate!.toDate()) : '-';
    String endDate = experience.endDate != null ? formatter.format(experience.endDate!.toDate()) : 'Actualmente';
    final title = _cvTitle();
    final subtitle = _cvSubtitle();
    final location = _clean(experience.location);
    final activities = _cvActivities();
    final bodyStyle = textTheme.bodySmall?.copyWith(fontSize: 14.0);
    final boldStyle = bodyStyle?.copyWith(fontWeight: FontWeight.bold);

    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                if (title.isNotEmpty) ...[
                  Text(title.toUpperCase(), style: boldStyle),
                  SpaceH4(),
                ],
                if (subtitle.isNotEmpty) ...[
                  Text(subtitle, style: boldStyle),
                  SpaceH4(),
                ],
                Text('$startDate / $endDate', style: bodyStyle),
                if (location.isNotEmpty) ...[
                  SpaceH4(),
                  Text(location, style: bodyStyle),
                ],
                if (activities.isNotEmpty) ...[
                  SpaceH8(),
                  Text('Actividades realizadas:', style: boldStyle),
                  SpaceH4(),
                  ...activities.map((a) => Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: Text('• $a', style: bodyStyle),
                      )),
                ],
                SpaceH8(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
