import 'package:cached_network_image/cached_network_image.dart';
import 'package:enreda_empresas/app/common_widgets/show_custom_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/participants/experience_tile.dart';
import 'package:enreda_empresas/app/home/participants/my_cv_model_page.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/competency_tile.dart';
import 'package:enreda_empresas/app/home/participants/reference_tile.dart';
import 'package:enreda_empresas/app/models/certificationRequest.dart';
import 'package:enreda_empresas/app/models/city.dart';
import 'package:enreda_empresas/app/models/competency.dart';
import 'package:enreda_empresas/app/models/country.dart';
import 'package:enreda_empresas/app/models/education.dart';
import 'package:enreda_empresas/app/models/experience.dart';
import 'package:enreda_empresas/app/models/province.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/auth.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/my_custom_scroll_behavior.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import '../../../common_widgets/custom_text.dart';
import '../../../common_widgets/precached_avatar.dart';
import '../../../values/values.dart';

class MyCurriculumPage extends StatelessWidget {
  MyCurriculumPage({Key? key, required this.user}): super(key: key);
  UserEnreda? user;

  String? myLocation;

  String? city;

  String? province;

  String? country;

  String myCustomCity = "";

  String myCustomProvince = "";

  String myCustomCountry = "";

  String myCustomAboutMe = "";

  String myCustomEmail = "";

  String myCustomPhone = "";

  Education? myMaxEducation;

  List<Competency>? myCompetencies = [];

  List<Experience>? myExperiences = [];

  List<Experience> myCustomExperiences = [];

  List<int> mySelectedExperiences = [];

  List<Experience>? myPersonalExperiences = [];

  List<Experience> myPersonalCustomExperiences = [];

  List<int> myPersonalSelectedExperiences = [];

  List<Experience>? myEducation = [];

  List<Experience> myCustomEducation = [];

  List<int> mySelectedEducation = [];

  List<Experience>? mySecondaryEducation = [];

  List<Experience> mySecondaryCustomEducation = [];

  List<int> mySecondarySelectedEducation = [];

  List<CertificationRequest>? myReferences = [];

  List<CertificationRequest> myCustomReferences = [];

  List<int> mySelectedReferences = [];

  List<String> competenciesNames = [];

  List<String> myCustomCompetencies = [];

  List<int> mySelectedCompetencies = [];

  List<String> myCustomDataOfInterest = [];

  List<int> mySelectedDataOfInterest = [];

  List<String> myCustomLanguages = [];

  List<int> mySelectedLanguages = [];

  double speakingLevel = 1.0;
  double writingLevel = 1.0;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);

    return StreamBuilder<List<Competency>>(
            stream: database.competenciesStream(),
            builder: (context, snapshot) {
              var profilePic = user?.profilePic?.src ?? "";
              if (!snapshot.hasData) return Container();
              if (snapshot.hasError)
                return Center(child: Text('Ocurrió un error'));
              List<Competency> competencies = snapshot.data!;
              final competenciesIds = user!.competencies.keys.toList();
              competencies = competencies
                  .where((competency) => competenciesIds.any((id) => competency.id == id))
                  .toList();
              competencies.forEach((competency) {
                final status =
                    user?.competencies[competency.id] ?? StringConst.BADGE_EMPTY;
                if (competency.name !="" && status != StringConst.BADGE_EMPTY && status != StringConst.BADGE_IDENTIFIED ) {
                  final index1 = competenciesNames.indexWhere((element) => element == competency.name);
                  if (index1 == -1) competenciesNames.add(competency.name);
                }
              });

              final myAboutMe = user?.aboutMe ?? "";
              myCustomAboutMe = myAboutMe;

              final myEmail = user?.email ?? "";
              myCustomEmail = myEmail;

              final myPhone = user?.phone ?? "";
              myCustomPhone = myPhone;

              myCustomCompetencies = competenciesNames.map((element) => element).toList();
              mySelectedCompetencies = List.generate(myCustomCompetencies.length, (i) => i);

              final myDataOfInterest = user?.dataOfInterest ?? [];
              myCustomDataOfInterest = myDataOfInterest.map((element) => element).toList();
              mySelectedDataOfInterest = List.generate(myCustomDataOfInterest.length, (i) => i);

              final myLanguages = user?.languagesLevels ?? [];
              myCustomLanguages = myLanguages.map((element) => element.name).toList();
              mySelectedLanguages = List.generate(myCustomLanguages.length, (i) => i);

              return Responsive.isDesktop(context)
                  ? _myCurriculumWeb(context, user, profilePic, competenciesNames )
                  : _myCurriculumMobile(context, user, profilePic, competenciesNames);
            });
  }

  Widget _myCurriculumWeb(BuildContext context, UserEnreda? user, String profilePic, List<String> competenciesNames){
    return Container(
      margin: EdgeInsets.only(
          top: 60.0, left: 4.0, right: 4.0, bottom: 4.0),
      padding: const EdgeInsets.only(
          left: 48.0, top: 72.0, right: 48.0, bottom: 48.0),
      decoration: BoxDecoration(
        color: AppColors.lightLilac,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(0.0, 1.0),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              padding: EdgeInsets.only(
                  top: 20.0, bottom: 20, right: 5, left: 20),
              width: Responsive.isDesktop(context) ? 330 : Responsive.isDesktopS(context) ? 290.0 : 290,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.rectangle,
                border: Border.all(color: AppColors.lilac, width: 1),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: SingleChildScrollView(
                controller: ScrollController(),
                child: Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: Responsive.isMobile(context)
                            ? const EdgeInsets.all(8.0)
                            : const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            !kIsWeb ?
                            ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(60)),
                              child:
                              Center(
                                child:
                                profilePic == "" ?
                                Container(
                                  color:  Colors.transparent,
                                  height: 120,
                                  width: 120,
                                  child: Image.asset(ImagePath.USER_DEFAULT),
                                ):
                                CachedNetworkImage(
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
                                    imageUrl: profilePic),
                              ),
                            ):
                            ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(60)),
                              child:
                              profilePic == "" ?
                              Container(
                                color:  Colors.transparent,
                                height: 120,
                                width: 120,
                                child: Image.asset(ImagePath.USER_DEFAULT),
                              ):
                              PrecacheAvatarCard(
                                imageUrl: profilePic,
                                height: 120,
                                width: 120,
                              ),
                            )
                          ],
                        ),
                      ),
                      SpaceH20(),
                      _buildPersonalData(context),
                      SpaceH20(),
                      _buildAboutMe(context),
                      SpaceH20(),
                      _buildMyDataOfInterest(context),
                      SpaceH20(),
                      _buildMyLanguages(context),
                      SpaceH20(),
                      _buildMyReferences(context, user),
                    ],
                  ),
                ),
              )),
          SpaceW40(),
          Expanded(
              child: SingleChildScrollView(
                controller: ScrollController(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCVHeader(context, user, profilePic, competenciesNames),
                    //_buildMyCareer(context),
                    SpaceH30(),
                    _buildMyEducation(context, user),
                    SpaceH30(),
                    _buildMySecondaryEducation(context, user),
                    SpaceH30(),
                    _buildMyExperiences(context, user),
                    SpaceH30(),
                    _buildMyCompetencies(context, user),
                  ],
                ),
              ))
        ],
      ),
    );
  }

  Widget _myCurriculumMobile(BuildContext context, UserEnreda? user, String profilePic, List<String> competenciesNames) {
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      child: Container(
        margin: Responsive.isTablet(context) ? EdgeInsets.only(top: 30, bottom: Sizes.mainPadding * 3 ) : EdgeInsets.symmetric(vertical: 0.0),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.greyUltraLight, width: 1),
          borderRadius: BorderRadius.all(Radius.circular(40.0)),
          color: AppColors.lightLilac,
        ),
        child: Padding(
          padding: EdgeInsets.all(Sizes.mainPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: SizedBox(width: Responsive.isTablet(context) || Responsive.isMobile(context) ? 26: 50,)),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () async {
                        final checkAgreeDownload = user?.checkAgreeCV ?? false;
                        /*if(!checkAgreeDownload){
                          showAlertDialog(context,
                              title: 'Error',
                              content: 'Por favor, acepta las condiciones antes de continuar',
                              defaultActionText: 'Ok'
                          );
                          return;
                        }*/
                        if (await _hasEnoughExperiences(context))
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    MyCvModelsPage(
                                      user: user!,
                                      city: city!,
                                      province: province!,
                                      country: country!,
                                      myCustomAboutMe: myCustomAboutMe,
                                      myCustomEmail: myCustomEmail,
                                      myCustomPhone: myCustomPhone,
                                      myExperiences: myExperiences!,
                                      myCustomExperiences: myCustomExperiences,
                                      mySelectedExperiences: mySelectedExperiences,
                                      myPersonalExperiences: myPersonalExperiences,
                                      myPersonalSelectedExperiences: myPersonalSelectedExperiences,
                                      myPersonalCustomExperiences: myPersonalCustomExperiences,
                                      myEducation: myEducation!,
                                      myCustomEducation: myCustomEducation,
                                      mySelectedEducation: mySelectedEducation,
                                      mySecondaryEducation: mySecondaryEducation,
                                      mySecondaryCustomEducation: mySecondaryCustomEducation,
                                      mySecondarySelectedEducation: mySecondarySelectedEducation,
                                      competenciesNames: competenciesNames,
                                      myCustomCompetencies: myCustomCompetencies,
                                      mySelectedCompetencies: mySelectedCompetencies,
                                      myCustomDataOfInterest: myCustomDataOfInterest,
                                      mySelectedDataOfInterest: mySelectedDataOfInterest,
                                      myCustomLanguages: myCustomLanguages,
                                      mySelectedLanguages: mySelectedLanguages,
                                      myCustomCity: myCustomCity,
                                      myCustomProvince: myCustomProvince,
                                      myCustomCountry: myCustomCountry,
                                      myReferences: myReferences!,
                                      myCustomReferences: myCustomReferences,
                                      mySelectedReferences: mySelectedReferences,
                                      myMaxEducation: myMaxEducation?.label??"",
                                    )),
                          );
                      },
                      child: Image.asset(
                        ImagePath.DOWNLOAD,
                        height: Responsive.isTablet(context) || Responsive.isMobile(context) ? Sizes.ICON_SIZE_30 : Sizes.ICON_SIZE_50,
                      ),),
                  ),
                ],
              ),
              SpaceH20(),
              Padding(
                padding: Responsive.isMobile(context)
                    ? const EdgeInsets.all(8.0)
                    : const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    !kIsWeb ?
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(60)),
                      child:
                      Center(
                        child:
                        profilePic == "" ?
                        Container(
                          color:  Colors.transparent,
                          height: 120,
                          width: 120,
                          child: Image.asset(ImagePath.USER_DEFAULT),
                        ):
                        CachedNetworkImage(
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            imageUrl: profilePic),
                      ),
                    ):
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(60)),
                      child:
                      Center(
                        child: profilePic == "" ?
                        Container(
                          color:  Colors.transparent,
                          height: 120,
                          width: 120,
                          child: Image.asset(ImagePath.USER_DEFAULT),
                        ):
                        FadeInImage.assetNetwork(
                          placeholder: ImagePath.USER_DEFAULT,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          image: profilePic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Responsive.isMobile(context) ? SpaceH12() : SpaceH24(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${user?.firstName} ${user?.lastName}',
                    style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.isDesktop(context) ? 45.0 : 32.0,
                        color: AppColors.penBlue),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SpaceH24(),
              CustomTextTitle(title: StringConst.PERSONAL_DATA.toUpperCase()),
              Row(
                children: [
                  Icon(
                    Icons.mail,
                    color: Colors.black.withOpacity(0.7),
                    size: 16,
                  ),
                  SpaceW4(),
                  CustomTextSmall(text: user?.email ?? ''),
                ],
              ),
              SpaceH8(),
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    color: AppColors.darkGray,
                    size: 12.0,
                  ),
                  SpaceW4(),
                  Text(
                    user?.phone ?? '',
                    style: textTheme.bodyText1?.copyWith(
                        fontSize: Responsive.isDesktop(context) ? 16 : 14.0,
                        color: AppColors.darkGray),
                  ),
                ],
              ),
              SpaceH8(),
              _buildMyLocation(context, user),
              SpaceH24(),
              _buildMyEducation(context, user),
              SpaceH24(),
              _buildMySecondaryEducation(context, user),
              SpaceH24(),
              _buildMyExperiences(context, user),
              SpaceH24(),
              _buildMyCompetencies(context, user),
              SpaceH24(),
              _buildAboutMe(context),
              SpaceH24(),
              _buildMyDataOfInterest(context),
              SpaceH24(),
              _buildMyLanguages(context),
              SpaceH24(),
              _buildMyReferences(context, user),
              SpaceH24(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCVHeader(BuildContext context, UserEnreda? user, String profilePic, List<String> competenciesNames) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              onTap: () async {
                final checkAgreeDownload = user?.checkAgreeCV ?? false;
                /*if(!checkAgreeDownload){
                  showAlertDialog(context,
                      title: 'Error',
                      content: 'Por favor, acepta las condiciones antes de continuar',
                      defaultActionText: 'Ok'
                  );
                  return;
                }*/
                if (await _hasEnoughExperiences(context))
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MyCvModelsPage(
                              user: user!,
                              city: city!,
                              province: province!,
                              country: country!,
                              myCustomAboutMe: myCustomAboutMe,
                              myCustomEmail: myCustomEmail,
                              myCustomPhone: myCustomPhone,
                              myExperiences: myExperiences!,
                              myCustomExperiences: myCustomExperiences,
                              mySelectedExperiences: mySelectedExperiences,
                              myPersonalExperiences: myPersonalExperiences,
                              myPersonalSelectedExperiences: myPersonalSelectedExperiences,
                              myPersonalCustomExperiences: myPersonalCustomExperiences,
                              myEducation: myEducation!,
                              myCustomEducation: myCustomEducation,
                              mySelectedEducation: mySelectedEducation,
                              mySecondaryEducation: mySecondaryEducation,
                              mySecondaryCustomEducation: mySecondaryCustomEducation,
                              mySecondarySelectedEducation: mySecondarySelectedEducation,
                              competenciesNames: competenciesNames,
                              myCustomCompetencies: myCustomCompetencies,
                              mySelectedCompetencies: mySelectedCompetencies,
                              myCustomDataOfInterest: myCustomDataOfInterest,
                              mySelectedDataOfInterest: mySelectedDataOfInterest,
                              myCustomLanguages: myCustomLanguages,
                              mySelectedLanguages: mySelectedLanguages,
                              myCustomCity: myCustomCity,
                              myCustomProvince: myCustomProvince,
                              myCustomCountry: myCustomCountry,
                              myReferences: myReferences!,
                              myCustomReferences: myCustomReferences,
                              mySelectedReferences: mySelectedReferences,
                              myMaxEducation: myMaxEducation?.label??"",
                            )),
                  );
              },
              child: Image.asset(
                ImagePath.DOWNLOAD,
                height:
                Responsive.isTablet(context) || Responsive.isMobile(context)
                    ? Sizes.ICON_SIZE_26
                    : Sizes.ICON_SIZE_50,
              ),
            ),
            SpaceW8(),
          ],
        ),
        SpaceH20(),
        Text(
          '${user?.firstName} ${user?.lastName}',
          style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: Responsive.isDesktop(context) ? 45.0 : 32.0,
              color: AppColors.penBlue),
        ),
      ],
    );
  }

  Widget _buildMyCareer(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);

    return StreamBuilder(
        stream: database.educationStream(),
        builder: (context, snapshotEducations) {
          if (snapshotEducations.hasData) {
            final educations = snapshotEducations.data!;

            if (user!.educationId!.isNotEmpty) {
              myMaxEducation = educations.firstWhere((e) => e.educationId == user!.educationId, orElse: () => Education(label: "", value: "", order: 0));
              return CustomTextBody(text: myMaxEducation?.label??"");
            } else {
              return StreamBuilder(
                  stream: database.myExperiencesStream(user?.userId ?? ''),
                  builder: (context, snapshotExperiences) {
                    if (snapshotEducations.hasData && snapshotExperiences.hasData) {
                      final myEducationalExperiencies = snapshotExperiences.data!
                          .where((experience) => experience.type == 'Formativa')
                          .toList();
                      if (myEducationalExperiencies.isNotEmpty) {
                        final areEduactions = myEducationalExperiencies.any((exp) => exp.education != null && exp.education!.isNotEmpty);
                        if (areEduactions) {
                          final myEducations = educations.where((edu) => myEducationalExperiencies.any((exp) => exp.education == edu.label)).toList();
                          myEducations.sort((a, b) => a.order.compareTo(b.order));
                          if(myEducations.isNotEmpty){
                            myMaxEducation = myEducations.first;
                          } else {
                            myMaxEducation = Education(label: "", value: "", order: 0);
                          }
                        } else {
                          myMaxEducation = Education(label: "", value: "", order: 0);
                        }
                        return CustomTextBody(text: myMaxEducation?.label??"");
                      } else {
                        return Container();
                      }
                    } else {
                      return Container();
                    }
                  });
            }
          } else {
            return Container();
          }
        });
    return StreamBuilder(
      stream: database.myExperiencesStream(user?.userId ?? ''),
      builder: (context, snapshotExperiences) {
        return StreamBuilder(
          stream: database.educationStream(),
          builder: (context, snapshotEducations) {

            if (snapshotEducations.hasData && snapshotExperiences.hasData) {
              final myEducationalExperiencies = snapshotExperiences.data!
                  .where((experience) => experience.type == 'Formativa')
                  .toList();
              if (myEducationalExperiencies.isNotEmpty) {
                final educations = snapshotEducations.data!;
                final areEduactions = myEducationalExperiencies.any((exp) => exp.education != null && exp.education!.isNotEmpty);
                if (areEduactions) {
                  final myEducations = educations.where((edu) => myEducationalExperiencies.any((exp) => exp.education == edu.label)).toList();
                  myEducations.sort((a, b) => a.order.compareTo(b.order));
                  myMaxEducation = myEducations.first;
                } else {
                  myMaxEducation = educations.firstWhere((e) => e.educationId == user!.educationId, orElse: () => Education(label: "", value: "", order: 0));
                }

                return CustomTextBody(text: myMaxEducation?.label??"");
              } else {
                return Container();
              }
            } else {
              return Container();
            }
          }
        );
      }
    );
  }

  Widget _buildAboutMe(BuildContext context) {
    final textController = TextEditingController();
    textController.text = user?.aboutMe ?? '';

    return StatefulBuilder(builder: (context, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextTitle(title: StringConst.ABOUT_ME.toUpperCase()),
          SpaceH20(),
          CustomTextBody(
            text: user?.aboutMe != null && user!.aboutMe!.isNotEmpty
                ? user!.aboutMe!
                : 'Aún no has añadido información adicional sobre ti'),
        ],
      );
    });
  }

  Widget _buildPersonalData(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConst.PERSONAL_DATA.toUpperCase(),
          style: textTheme.bodyText1?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: Responsive.isDesktop(context) ? 18 : 14.0,
            color: AppColors.darkLilac,
          ),
        ),
        SpaceH20(),
        Row(
          children: [
            Icon(
              Icons.mail,
              color: AppColors.darkGray,
              size: 12.0,
            ),
            SpaceW4(),
            Flexible(
              child: Text(
                user?.email ?? '',
                style: textTheme.bodyText1?.copyWith(
                    fontSize: Responsive.isDesktop(context) ? 14 : 11.0,
                    color: AppColors.darkGray),
              ),
            ),
          ],
        ),
        SpaceH8(),
        Row(
          children: [
            Icon(
              Icons.phone,
              color: AppColors.darkGray,
              size: 12.0,
            ),
            SpaceW4(),
            Text(
              user?.phone ?? '',
              style: textTheme.bodyText1?.copyWith(
                  fontSize: Responsive.isDesktop(context) ? 14 : 11.0,
                  color: AppColors.darkGray),
            ),
          ],
        ),
        SpaceH8(),
        _buildMyLocation(context, user),
      ],
    );
  }

  Widget _buildMyLocation(BuildContext context, UserEnreda? user) {
    final database = Provider.of<Database>(context, listen: false);

    Country? myCountry;
    Province? myProvince;
    City? myCity;

    return StreamBuilder<Country>(
        stream: database.countryStream(user?.address?.country),
        builder: (context, snapshot) {
          myCountry = snapshot.data;
          return StreamBuilder<Province>(
              stream: database.provinceStream(user?.address?.province),
              builder: (context, snapshot) {
                myProvince = snapshot.data;

                return StreamBuilder<City>(
                    stream: database.cityStream(user?.address?.city),
                    builder: (context, snapshot) {
                      myCity = snapshot.data;

                      myLocation =
                          '${myCity?.name ?? ''}, ${myProvince?.name ?? ''}, ${myCountry?.name ?? ''}';
                      city = '${myCity?.name ?? ''}';
                      province = '${myProvince?.name ?? ''}';
                      country = '${myCountry?.name ?? ''}';

                      myCustomCity = city!;
                      myCustomProvince = province!;
                      myCustomCountry = country!;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.black.withOpacity(0.7),
                            size: 16,
                          ),
                          SpaceW4(),
                          Responsive.isMobile(context) ? Expanded(child: CustomTextSmall(text: myLocation ?? '')) :
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextSmall(text: city ?? ''),
                              CustomTextSmall(text: province ?? ''),
                              CustomTextSmall(text: country ?? ''),
                            ],
                          ),
                        ],
                      );
                    });
              });
        });
  }

  Widget _buildMyCompetencies(BuildContext context, UserEnreda? user) {
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;
    final controller = ScrollController();
    var scrollJump = 137.5;
    return StreamBuilder<List<Competency>>(
      stream: database.competenciesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.active) {
          final competenciesIds = user!.competencies.keys.toList();
          myCompetencies = snapshot.data!
              .where((competency) => competenciesIds.any((id) => competency.id == id &&
                (user.competencies[id] == StringConst.BADGE_VALIDATED ||
                user.competencies[id] == StringConst.BADGE_CERTIFIED) ))
              .toList();
          return Container(
            width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                border: Border.all(color: AppColors.lilac, width: 1),
                borderRadius: BorderRadius.circular(20.0),
              ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        StringConst.COMPETENCIES.toUpperCase(),
                        style: TextStyle(
                            color: AppColors.darkLilac,
                            fontWeight: FontWeight.w600,
                            fontSize: 18.0),
                      ),
                    ],
                  ),
                ),
                myCompetencies!.isNotEmpty
                    ? Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InkWell(
                        onTap: () {
                          if (controller.position.pixels >=
                              controller.position.minScrollExtent)
                            controller.animateTo(
                                controller.position.pixels - scrollJump,
                                duration: Duration(milliseconds: 500),
                                curve: Curves.ease);
                        },
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.penBlue,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 180.0,
                        color: Colors.white,
                        child: ScrollConfiguration(
                          behavior: MyCustomScrollBehavior(),
                          child: ListView(
                            controller: controller,
                            scrollDirection: Axis.horizontal,
                            children: myCompetencies!.map((competency) {
                              final status =
                                  user.competencies[competency.id] ??
                                      StringConst.BADGE_EMPTY;
                              return Column(
                                children: [
                                  CompetencyTile(
                                    competency: competency,
                                    status: status,
                                    mini: true,
                                  ),
                                  SpaceH12(),
                                  Text(
                                      status ==
                                              StringConst
                                                  .BADGE_VALIDATED
                                          ? 'EVALUADA'
                                          : 'CERTIFICADA',
                                      style: textTheme.bodyText1
                                          ?.copyWith(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.turquoise)),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 10.0),
                      child: InkWell(
                        onTap: () {
                          if (controller.position.pixels <=
                              controller.position.maxScrollExtent)
                            controller.animateTo(
                                controller.position.pixels + scrollJump,
                                duration: Duration(milliseconds: 500),
                                curve: Curves.ease);
                        },
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.penBlue,
                        ),
                      ),
                    ),
                  ],
                )
                    : Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                          child: Text(
                            'Aquí aparecerán las competencias evaluadas a través de los microtests',
                            style: textTheme.bodyText1,
                          )),
                    ),
              ],
            )
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildMyEducation(BuildContext context, UserEnreda? user) {
    final database = Provider.of<Database>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomTextTitle(title: StringConst.EDUCATION.toUpperCase()),
          ],
        ),
        SpaceH4(),
        Row(
          children: [
            CustomTextSubTitle(title: StringConst.EDUCATIONAL_LEVEL.toUpperCase()),
          ],
        ),
        _buildMyCareer(context),
        SpaceH4(),
        StreamBuilder<List<Experience>>(
            stream: database.myExperiencesStream(user?.userId ?? ''),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.active) {
                myEducation = snapshot.data!
                    .where((experience) => experience.type == 'Formativa')
                    .toList();
                myCustomEducation = myEducation!.map((element) => element).toList();
                mySelectedEducation = List.generate(myCustomEducation.length, (i) => i);
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: AppColors.lightLilac,
                  ),
                  child: myEducation!.isNotEmpty
                      ? Wrap(
                          children: myEducation!
                              .map((e) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SpaceH12(),
                                      Container(
                                        width: double.infinity,
                                        child: ExperienceTile(experience: e, type: e.type),
                                      ),
                                      Divider(),
                                    ],
                                  ))
                              .toList(),
                        )
                      : CustomTextBody(text: StringConst.NO_EDUCATION),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
      ],
    );
  }
  Widget _buildMySecondaryEducation(BuildContext context, UserEnreda? user) {
    final database = Provider.of<Database>(context, listen: false);
    bool dismissible = true;
    return Column(
      children: [
        Row(
          children: [
            CustomTextTitle(title: StringConst.SECONDARY_EDUCATION.toUpperCase()),
          ],
        ),
        SpaceH4(),
        StreamBuilder<List<Experience>>(
            stream: database.myExperiencesStream(user?.userId ?? ''),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.active) {
                mySecondaryEducation = snapshot.data!
                    .where((experience) => experience.type == 'Complementaria')
                    .toList();
                mySecondaryCustomEducation = mySecondaryEducation!.map((element) => element).toList();
                mySecondarySelectedEducation = List.generate(mySecondaryCustomEducation.length, (i) => i);
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: AppColors.lightLilac,
                  ),
                  child: mySecondaryEducation!.isNotEmpty
                      ? Wrap(
                    children: mySecondaryEducation!
                        .map((e) => Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        SpaceH12(),
                        Container(
                          width: double.infinity,
                          child: ExperienceTile(experience: e, type: e.type),
                        ),
                        Divider(),
                      ],
                    ))
                        .toList(),
                  )
                      : CustomTextBody(text: StringConst.NO_EDUCATION),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
      ],
    );
  }

  Widget _buildProfesionalExperience(BuildContext context, UserEnreda? user) {
    final database = Provider.of<Database>(context, listen: false);
    bool dismissible = true;
    return Column(
      children: [
        Row(
          children: [
            CustomTextSubTitle(title: StringConst.MY_PROFESIONAL_EXPERIENCES.toUpperCase()),
          ],
        ),
        SpaceH4(),
        StreamBuilder<List<Experience>>(
            stream: database.myExperiencesStream(user?.userId ?? ''),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.active) {
                myExperiences = snapshot.data!
                    .where((experience) => experience.type == 'Profesional')
                    .toList();
                myCustomExperiences = myExperiences!.map((element) => element).toList();
                mySelectedExperiences = List.generate(myCustomExperiences.length, (i) => i);
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: AppColors.lightLilac,
                  ),
                  child: myExperiences!.isNotEmpty
                      ? Wrap(
                    children: myExperiences!
                        .map((e) => Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        SpaceH12(),
                        Container(
                          width: double.infinity,
                          child: ExperienceTile(experience: e, type: e.type),
                        ),
                        Divider(),
                      ],
                    ))
                        .toList(),
                  )
                      : CustomTextBody(text: StringConst.NO_EXPERIENCE),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
      ],
    );
  }

  Widget _buildPersonalExperience(BuildContext context, UserEnreda? user) {
    final database = Provider.of<Database>(context, listen: false);
    bool dismissible = true;
    return Column(
      children: [
        Row(
          children: [
            CustomTextSubTitle(title: StringConst.MY_PERSONAL_EXPERIENCES.toUpperCase()),
          ],
        ),
        SpaceH4(),
        StreamBuilder<List<Experience>>(
            stream: database.myExperiencesStream(user?.userId ?? ''),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.active) {
                myPersonalExperiences = snapshot.data!
                    .where((experience) => experience.type == 'Personal')
                    .toList();
                myPersonalCustomExperiences = myPersonalExperiences!.map((element) => element).toList();
                myPersonalSelectedExperiences = List.generate(myPersonalCustomExperiences.length, (i) => i);
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: AppColors.lightLilac,
                  ),
                  child: myPersonalExperiences!.isNotEmpty
                      ? Wrap(
                    children: myPersonalExperiences!
                        .map((e) => Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        SpaceH12(),
                        Container(
                          width: double.infinity,
                          child: ExperienceTile(experience: e, type: e.type,),
                        ),
                        Divider(),
                      ],
                    ))
                        .toList(),
                  )
                      : CustomTextBody(text: StringConst.NO_EXPERIENCE),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
      ],
    );
  }

  Widget _buildMyExperiences(BuildContext context, UserEnreda? user) {
    final database = Provider.of<Database>(context, listen: false);
    bool dismissible = true;
    return Column(
      children: [
        Row(
          children: [
            CustomTextTitle(title: StringConst.MY_EXPERIENCES.toUpperCase()),
            SpaceW8(),
          ],
        ),

        SpaceH4(),
        _buildProfesionalExperience(context, user),
        SpaceH4(),
        _buildPersonalExperience(context, user),
      ],
    );
  }

  Widget _buildMyDataOfInterest(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final myDataOfInterest = user?.dataOfInterest ?? [];

    return Column(
      children: [
        Row(
          children: [
            CustomTextTitle(title: StringConst.DATA_OF_INTEREST.toUpperCase()),
          ],
        ),
        SpaceH4(),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Colors.transparent,
          ),
          child: myDataOfInterest.isNotEmpty
              ? Wrap(
                  children: myDataOfInterest
                      .map((d) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SpaceH12(),
                              Container(
                                height: 40.0,
                                child: Row(
                                  children: [
                                    Expanded(child: CustomTextBody(text: d)),
                                  ],
                                ),
                              ),
                              Divider(),
                            ],
                          ))
                      .toList(),
                )
              : CustomTextBody(text: StringConst.NO_DATA_OF_INTEREST),
        ),
      ],
    );
  }

  Widget _buildMyLanguages(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;
    final myLanguages = user?.languagesLevels ?? [];

    return Column(
      children: [
        Row(
          children: [
            CustomTextTitle(title: StringConst.LANGUAGES.toUpperCase()),
          ],
        ),
        SpaceH4(),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Colors.transparent,
          ),
          child: myLanguages.isNotEmpty
              ? Wrap(
                  children: myLanguages
                      .map((l) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SpaceH12(),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      l.name,
                                      style: textTheme.bodyText1?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SpaceH12(),
                              _buildSpeakingLevelRow(
                                value: l.speakingLevel.toDouble(),
                                textTheme: textTheme,
                                iconSize: 15.0,
                                onValueChanged: null,),
                              SpaceH12(),
                              _buildWritingLevelRow(
                                value: l.writingLevel.toDouble(),
                                textTheme: textTheme,
                                iconSize: 15.0,
                                onValueChanged: null,),
                              Divider(),
                            ],
                          ))
                      .toList(),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(child: CustomTextSmall(text: StringConst.NO_LANGUAGES)),
                ),
        ),
      ],
    );
  }

  Widget _buildMyReferences(BuildContext context, UserEnreda? user) {
    final database = Provider.of<Database>(context, listen: false);

    return Column(
      children: [
        Row(
          children: [
            CustomTextTitle(title: StringConst.PERSONAL_REFERENCES.toUpperCase()),
            SpaceW12(),
          ],
        ),
        SpaceH4(),
        StreamBuilder<List<CertificationRequest>>(
            stream: database.myCertificationRequestStream(user?.userId ?? ''),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.active) {
                myReferences = snapshot.data!
                    .where((certificationRequest) => certificationRequest.referenced == true)
                    .toList();
                myCustomReferences = myReferences!.map((element) => element).toList();
                mySelectedReferences = List.generate(myCustomReferences.length, (i) => i);
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: myReferences!.isNotEmpty
                      ? Wrap(
                    children: myReferences!
                        .map((e) => Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        SpaceH12(),
                        Container(
                          width: double.infinity,
                          child: Row(
                            children: [
                              ReferenceTile(certificationRequest: e),
                            ],
                          ),
                        ),
                        Divider(),
                      ],
                    )).toList(),
                  )
                      : Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(child: CustomTextSmall(text: StringConst.NO_REFERENCES)),
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
      ],
    );
  }

  Widget _buildWritingLevelRow({
    required TextTheme textTheme,
    required double value,
    double iconSize = 20.0,
    dynamic Function(double)? onValueChanged
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Expresión escrita',
            style: textTheme.bodyText1?.copyWith(
              fontWeight: FontWeight.normal,
              fontSize: 14.0,
            ),
          ),
        ),
        SmoothStarRating(
            allowHalfRating: false,
            onRatingChanged: onValueChanged,
            starCount: 3,
            rating: value,
            size: iconSize,
            filledIconData: Icons.circle,
            defaultIconData: Icons.circle_outlined,
            color: AppColors.greyViolet,
            borderColor: AppColors.greyViolet,
            spacing: 5.0
        )
      ],
    );
  }

  Widget _buildSpeakingLevelRow({
        required TextTheme textTheme,
        required double value,
        double iconSize = 20.0,
        dynamic Function(double)? onValueChanged
      }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Expresión oral',
            style: textTheme.bodyText1?.copyWith(
              fontWeight: FontWeight.normal,
              fontSize: 14.0,
            ),
          ),
        ),
        SmoothStarRating(
            allowHalfRating: false,
            onRatingChanged: onValueChanged,
            starCount: 3,
            rating: value,
            size: iconSize,
            filledIconData: Icons.circle,
            defaultIconData: Icons.circle_outlined,
            color: AppColors.greyViolet,
            borderColor: AppColors.greyViolet,
            spacing: 5.0
        )
      ],
    );
  }

  Future<bool> _hasEnoughExperiences(BuildContext context) async {
    if (myCompetencies!.length < 3 || myExperiences!.length < 2) {
      showCustomDialog(context,
          content: CustomTextBody(text: StringConst.ADD_MORE_EXPERIENCES),
          defaultActionText: StringConst.OK,
          onDefaultActionPressed: (context) => Navigator.of(context).pop(true));
      return false;
    } else {
      return true;
    }
  }

}
