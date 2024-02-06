
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

class WorkflowPage extends StatelessWidget {
  const WorkflowPage({Key? key}) : super(key: key);

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
                    child: CustomTextBoldTitle(title: StringConst.WORKFLOW.toUpperCase(),),
                  ),
                  Divider(color: AppColors.greyLight2.withOpacity(0.3),),
                  Container(),
                ],
              )),
        ),
      ],
    );
  }

}
