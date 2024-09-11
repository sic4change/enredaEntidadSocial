import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {

  const CustomDialog({Key? key,  required this.child, this.width });
  final Widget child;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      surfaceTintColor: AppColors.primary050,
      backgroundColor: AppColors.primary050,
      child: CupertinoScrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          primary: true,
          child: Container(
            width: width,
            child: Column (
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  Expanded(child: Container()),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, right: 20),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.clear, color: AppColors.greyAlt,),
                    ),
                  )
                ],),
                child
              ],
            ),
          ),
        ),
      ),
    );
  }
}