
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/utils/functions.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

class EnredaMethodologyPage extends StatelessWidget {
  const EnredaMethodologyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Container(
              margin: const EdgeInsets.only(top: 10.0),
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.rectangle,
                border: Border.all(color: AppColors.greyLight2.withOpacity(0.3), width: 1),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
                    child: CustomTextBoldTitle(title: StringConst.ENREDA_METHODOLOGY.toUpperCase(),),
                  ),
                  Divider(color: AppColors.greyLight2.withOpacity(0.3),),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
                    child: InkWell(
                      onTap: () => launchURL(StringConst.MANUAL_METHODOLOGY_PDF),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: AppColors.greyLight,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 20.0,),
                            CustomTextSmall(text: StringConst.MANUAL_METHODOLOGY),
                            Spacer(),
                            Icon(Icons.remove_red_eye_outlined, color: AppColors.greyDark2,),
                            SizedBox(width: 20.0,),
                          ],
                        ),

                      ),
                    ),
                  ),
                ],
              )),
        ),
      ],
    );
  }

}
