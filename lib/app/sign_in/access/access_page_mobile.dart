import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../common_widgets/spaces.dart';
import '../../common_widgets/stores_buttons.dart';
import '../../utils/responsive.dart';
import '../../values/strings.dart';
import '../../values/values.dart';
import '../email_sign_in_form_change_notifier.dart';

class AccessPageMobile extends StatefulWidget {
  @override
  _AccessPageMobileState createState() => _AccessPageMobileState();
}

class _AccessPageMobileState extends State<AccessPageMobile> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Container(
        color: AppColors.primary100,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              SpaceW20(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    ImagePath.LOGO,
                    height: Responsive.isMobile(context) ? Sizes.HEIGHT_50 : Sizes.HEIGHT_60,
                  ),
                  SpaceH30(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      StringConst.LOOKING_FOR_OPPORTUNITIES,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary900,
                      ),
                    ),
                  ),
                  SpaceH30(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: EmailSignInFormChangeNotifier.create(context),
                  ),
                  SpaceH20(),
                  kIsWeb ? buildStoresButtons(context) : Container(),
                  SpaceH4(),
                  kIsWeb ? Text(
                    StringConst.BETTER_FROM_APPS,
                    style: textTheme.bodySmall?.copyWith(
                      height: 1.5,
                      color: AppColors.primary900,
                    ),
                  ) : Container(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
