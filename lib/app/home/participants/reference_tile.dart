import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/models/certificationRequest.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

class ReferenceTile extends StatelessWidget {
  const ReferenceTile({Key? key, required this.certificationRequest})
      : super(key: key);
  final CertificationRequest certificationRequest;

  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 15, md: 14);
    return Row(
      children: [
        if (certificationRequest.referenced == true)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            CustomTextBold(title: '${certificationRequest.certifierName}'),
            SpaceH4(),
            RichText(
              text: TextSpan(
                  text: '${certificationRequest.certifierPosition.toUpperCase()} -',
                  style: textTheme.bodyText1?.copyWith(
                    color: AppColors.greyAlt,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: ' ${certificationRequest.certifierCompany}',
                      style: textTheme.bodyText1?.copyWith(
                        color: AppColors.greyAlt,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ]),
            ),

            Row(
              children: [
                Icon(
                  Icons.mail,
                  color: AppColors.greyDark,
                  size: 12.0,
                ),
                SpaceW4(),
                CustomTextSmall(text: '${certificationRequest.email}'),
              ],
            ),
            certificationRequest.phone != "" ? Row(
              children: [
                Icon(
                  Icons.phone,
                  color: AppColors.greyDark,
                  size: 12.0,
                ),
                SpaceW4(),
                CustomTextSmall(text: '${certificationRequest.phone}')
              ],
            ) : Container(),
          ]
        ),
        SpaceH8(),
      ],
    );
  }
}
