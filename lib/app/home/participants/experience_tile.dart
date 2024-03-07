import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/models/experience.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ExperienceTile extends StatelessWidget {
  const ExperienceTile({Key? key, required this.experience, this.onTap, required this.type})
      : super(key: key);
  final Experience experience;
  final VoidCallback? onTap;
  final String type;

  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;
    final DateFormat formatter = DateFormat('yyyy');
    bool dismissible = true;
    String startDate = experience.startDate != null ? formatter.format(experience.startDate!.toDate()) : '-';
    String endDate = experience.endDate != null ? formatter.format(experience.endDate!.toDate()) : 'Actualmente';

    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
            if (experience.activity != null && experience.activityRole != null && experience.type != 'Formativa' && experience.type != 'Complementaria')
              RichText(
                text: TextSpan(
                    text: '${experience.activityRole!.toUpperCase()} -',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 14.0,
                    ),
                    children: [
                      TextSpan(
                        text: ' ${experience.activity!.toUpperCase()}',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.normal,
                        ),
                      )
                    ]),
              ),


            if((experience.type == 'Formativa' || experience.type == 'Complementaria') && experience.institution != '' && experience.nameFormation != '')
              RichText(
                text: TextSpan(
                    text: '${experience.institution!.toUpperCase()} -',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 14.0,
                    ),
                    children: [
                      TextSpan(
                        text: ' ${experience.nameFormation!.toUpperCase()}',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.normal,
                        ),
                      )
                    ]),
              ),
            if(experience.subtype == 'Responsabilidades familiares' || experience.subtype == 'Compromiso social')
              Text(
                '${experience.subtype}',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 14.0,
                ),
              ),
            if(experience.subtype == 'Otro')
              Text(
                '${experience.position}',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 14.0,
                ),
              ),
            if (experience.activity != null && experience.activityRole == null)
              Text( experience.position == null || experience.position == "" ? '${experience.activity}' : '${experience.position}',
                  style: textTheme.bodySmall
                      ?.copyWith(fontSize: 14.0, fontWeight: FontWeight.normal)),
            if (experience.position != null || experience.activity != null) SpaceH8(),
            if (experience.organization != null && experience.organization != "") Column(
              children: [
                Text(
                  experience.organization!,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.normal,
                    fontSize: 14.0,
                  ),
                ),
                SpaceH8()
              ],
            ),
            Text(
              '$startDate / $endDate',
              style: textTheme.bodySmall?.copyWith(
                fontSize: 14.0,
              ),
            ),
            SpaceH8(),

            if((experience.type == 'Formativa' || experience.type == 'Complementaria') && experience.extraData != '')
              Column(
                children: [
                  Text(
                    experience.extraData!,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 14.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SpaceH8(),
                ],
              ),

            Text(
              experience.location,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 14.0,
              ),
            ),
        ],
      ),
          ),
        ],
      ),
    );
  }
}
