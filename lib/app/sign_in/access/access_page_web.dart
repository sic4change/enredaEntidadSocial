import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../common_widgets/spaces.dart';
import '../../common_widgets/stores_buttons.dart';
import '../../utils/adaptative.dart';
import '../../utils/responsive.dart';
import '../../values/strings.dart';
import '../../values/values.dart';
import '../email_sign_in_form_change_notifier.dart';

class AccessPageWeb extends StatefulWidget {
  @override
  State<AccessPageWeb> createState() => _AccessPageWebState();
}

class _AccessPageWebState extends State<AccessPageWeb> {
  @override
  Widget build(BuildContext context) {
    final double largeHeight = 900;
    return Scaffold(
        body: LayoutBuilder(
            builder: (context, constraints) {
              return constraints.maxHeight > largeHeight
                  ? _buildLargeBody(context)
                  : _buildSmallBody(context);
            }
        )
    );
  }

  Widget _buildLargeBody(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final double widthSize = MediaQuery.of(context).size.width;
    final double heightSize = MediaQuery.of(context).size.height;
    double fontSize = responsiveSize(context, 20, 30, md: 22);
    return Stack(
      children: [
        Center(
          child: Container(
            height: heightSize * 0.80,
            width: widthSize * 0.80,
            child: Card(
              color: AppColors.primary100,
              elevation: 5,
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Image.asset(
                      height: heightSize * 0.85,
                      ImagePath.ACCESS_PHOTO,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                      flex: 5,
                      child: Container()),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: Responsive.isDesktopS(context) ? 70 : 100,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
                padding: EdgeInsets.only(left: 4, right: 25),
                height: heightSize * 0.70,
                width: widthSize * 0.80,
                child: Image.asset(ImagePath.ACCESS_VECTOR)),
          ),
        ),
        Center(
          child: Container(
            color: Colors.transparent,
            height: heightSize * 0.80,
            width: widthSize * 0.80,
            child: Card(
              color: Colors.transparent,
              elevation: 0,
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                  Expanded(
                      flex: 5,
                      child: Padding(
                        padding: EdgeInsets.only(left: Sizes.mainPadding,
                            right: Sizes.mainPadding, bottom: Sizes.mainPadding,
                            top: Sizes.mainPadding * 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              color: Colors.transparent,
                              height: 50,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(child: Container()),
                                  Image.asset(
                                    ImagePath.LOGO,
                                    height: Sizes.HEIGHT_100,
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          StringConst.LOOKING_FOR_OPPORTUNITIES,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 3,
                                          style: textTheme.bodyLarge?.copyWith(
                                            height: 1.5,
                                            color: AppColors.primary900,
                                            fontWeight: FontWeight.w400,
                                            fontSize: fontSize,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SpaceH12(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                  child: EmailSignInFormChangeNotifier.create(context),
                                ),
                                SpaceH4(),
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
                            Spacer(),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallBody(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final double widthSize = MediaQuery.of(context).size.width;
    final double heightSize = MediaQuery.of(context).size.height;
    double fontSize = responsiveSize(context, 20, 30, md: 22);
    return Stack(
      children: [
        Center(
          child: Container(
            height: heightSize * 0.80,
            width: widthSize * 0.85,
            child: Card(
              color: AppColors.primary100,
              elevation: 5,
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Image.asset(
                      height: 750,
                      ImagePath.ACCESS_PHOTO,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                      flex: 5,
                      child: Container()),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 70,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
                padding: EdgeInsets.only(left: 4, right: 30, top: 50),
                width: widthSize * 0.85,
                child: Image.asset(ImagePath.ACCESS_VECTOR)),
          ),
        ),
        Center(
          child: Container(
            height: heightSize * 0.80,
            width: widthSize * 0.85,
            child: Card(
              color: Colors.transparent,
              elevation: 0,
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                  Expanded(
                      flex: 5,
                      child: Padding(
                        padding: EdgeInsets.all(Sizes.mainPadding),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0, top: 50),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Image.asset(
                                    ImagePath.LOGO,
                                    height: Sizes.HEIGHT_74,
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 34,
                                    ),
                                    Spacer(),
                                    Text(
                                      StringConst.LOOKING_FOR_OPPORTUNITIES,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                      style: textTheme.bodyLarge?.copyWith(
                                        height: 1.5,
                                        color: AppColors.primary900,
                                        fontWeight: FontWeight.w400,
                                        fontSize: fontSize,
                                      ),
                                    ),
                                    Spacer(),
                                  ],
                                ),
                                SpaceH12(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                  child: EmailSignInFormChangeNotifier.create(context),
                                ),
                                SpaceH4(),
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
                            Spacer(),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

