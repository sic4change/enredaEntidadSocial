import 'package:cached_network_image/cached_network_image.dart';
import 'package:enreda_empresas/app/common_widgets/alert_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/enreda_button.dart';
import 'package:enreda_empresas/app/common_widgets/precached_avatar.dart';
import 'package:enreda_empresas/app/common_widgets/show_custom_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/participants/experience_tile.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/curriculum/add_educational_level.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/curriculum/experience_form_update.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/curriculum/formation_form.dart';
import 'package:enreda_empresas/app/home/participants/reference_tile.dart';
import 'package:enreda_empresas/app/home/resources/global.dart' as globals;
import 'package:enreda_empresas/app/models/certificationRequest.dart';
import 'package:enreda_empresas/app/models/city.dart';
import 'package:enreda_empresas/app/models/competency.dart';
import 'package:enreda_empresas/app/models/country.dart';
import 'package:enreda_empresas/app/models/education.dart';
import 'package:enreda_empresas/app/models/experience.dart';
import 'package:enreda_empresas/app/models/language.dart';
import 'package:enreda_empresas/app/models/province.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/utils/functions.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

class MyCurriculumPage extends StatefulWidget {
  const MyCurriculumPage({super.key, this.mini = false, this.onPreview, this.user});

  final bool mini;
  final VoidCallback? onPreview;
  final UserEnreda? user;

  @override
  State<MyCurriculumPage> createState() => _MyCurriculumPageState();
}

class _MyCurriculumPageState extends State<MyCurriculumPage> {
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
  List<Language> myCustomLanguages = [];
  List<int> mySelectedLanguages = [];
  double speakingLevel = 1.0;
  double writingLevel = 1.0;
  final ImagePicker _imagePicker = ImagePicker();
  String _photo = '';

  Stream<List<Experience>>? _experiencesStream;
  Stream<List<UserEnreda>>? _userStream;
  Stream<Country>? _countryStream;
  Stream<Province>? _provinceStream;
  Stream<City>? _cityStream;

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void initState() {
    super.initState();
    final database = Provider.of<Database>(context, listen: false);
    LocationCache.instance.warmUpAll(database).then((_) {
      if (mounted) setState(() {});
    });

    if (LocationCache.instance.competencies.isEmpty) {
      database.getCompetencies().then((comps) {
        LocationCache.instance.competencies = comps;
        if (mounted) setState(() {});
      }).catchError((_) {});
    }

    final currentUser = widget.user ?? globals.currentParticipant;
    final userId = currentUser?.userId ?? '';
    final email = currentUser?.email ?? '';

    _experiencesStream = database.myExperiencesStream(userId);
    _userStream = database.userStream(email);
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);

    return StreamBuilder<List<UserEnreda>>(
      stream: _userStream,
      builder: (context, su) {
        if (su.hasData && su.connectionState == ConnectionState.active && su.data!.isNotEmpty) {
          user = su.data!.first;
        } else {
          user = widget.user ?? globals.currentParticipant;
        }

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final addr = user?.address;
        if (_countryStream == null && (addr?.country ?? '').isNotEmpty) {
          _countryStream = database.countryStream(addr!.country);
        }
        if (_provinceStream == null && (addr?.province ?? '').isNotEmpty) {
          _provinceStream = database.provinceStream(addr!.province);
        }
        if (_cityStream == null && (addr?.city ?? '').isNotEmpty) {
          _cityStream = database.cityStream(addr!.city);
        }

        _photo = user?.profilePic?.src ?? "";

        return StreamBuilder<List<Experience>>(
          stream: _experiencesStream,
          builder: (context, expSnapshot) {
            if (!expSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final allExp = expSnapshot.data!;
            myEducation = allExp.where((e) => e.type == 'Formativa').toList();
            mySecondaryEducation = allExp.where((e) => e.type == 'Complementaria').toList();
            myExperiences = allExp.where((e) => e.type == 'Profesional').toList();
            myPersonalExperiences = allExp.where((e) => e.type == 'Personal').toList();

            final competenciesMap = user?.competencies ?? {};
            final competenciesIds = competenciesMap.keys.toList();
            final competenciesList = LocationCache.instance.competencies;
            final filtered = competenciesList
                .where((c) => c.id != null && competenciesIds.contains(c.id))
                .toList();

            competenciesNames.clear();
            for (final c in filtered) {
              if (c.id == null) continue;
              final status = competenciesMap[c.id] ?? StringConst.BADGE_EMPTY;
              if (c.name.isNotEmpty &&
                  status != StringConst.BADGE_EMPTY &&
                  status != StringConst.BADGE_IDENTIFIED) {
                if (!competenciesNames.contains(c.name)) {
                  competenciesNames.add(c.name);
                }
              }
            }

            myCustomAboutMe = user?.aboutMe ?? "";
            myCustomEmail = user?.email ?? "";
            myCustomPhone = user?.phone ?? "";

            myCustomCompetencies = competenciesNames.toList();
            mySelectedCompetencies = List.generate(myCustomCompetencies.length, (i) => i);

            final myDataOfInterest = user?.dataOfInterest ?? [];
            myCustomDataOfInterest = myDataOfInterest.toList();
            mySelectedDataOfInterest = List.generate(myCustomDataOfInterest.length, (i) => i);

            final myLanguages = user?.languagesLevels ?? [];
            myCustomLanguages = myLanguages.toList();
            mySelectedLanguages = List.generate(myCustomLanguages.length, (i) => i);

            if (widget.mini) {
              return _myCurriculumMini(context, user, _photo, competenciesNames, allExp);
            } else {
              return Responsive.isDesktop(context)
                  ? _myCurriculumWeb(context, user, _photo, competenciesNames, allExp)
                  : _myCurriculumMobile(context, user, _photo, competenciesNames, allExp);
            }
          },
        );
      },
    );
  }

  Widget _myCurriculumMini(BuildContext context, UserEnreda? user,
      String profilePic, List<String> compNames, List<Experience> allExp) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 400,
          padding: EdgeInsets.all(Sizes.mainPadding * 2),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                AppColors.primary400.withValues(alpha: 0.15),
                AppColors.primary020.withValues(alpha: 0.13),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(60)),
                      child: profilePic == ""
                          ? Image.asset(ImagePath.USER_DEFAULT, width: 120, height: 120)
                          : CachedNetworkImage(
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              imageUrl: profilePic,
                            ),
                    ),
                  ],
                ),
              ),
              const SpaceH20(),
              _buildPersonalData(context, user),
              const SpaceH20(),
              _buildAboutMe(context, user),
              const SpaceH20(),
              _buildMyDataOfInterest(context, user),
              const SpaceH20(),
              _buildMyLanguages(context, user),
              const SpaceH20(),
              _buildMyReferences(context, user),
            ],
          ),
        ),
        const SpaceW20(),
        SizedBox(
          width: 600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SpaceH50(),
              Text(
                '${user?.firstName} ${user?.lastName}',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: Responsive.isDesktop(context) ? 45.0 : 32.0,
                  color: AppColors.primary900,
                ),
              ),
              const SpaceH30(),
              _buildMyEducation(context, user),
              const SpaceH30(),
              _buildMySecondaryEducation(context, user),
              const SpaceH30(),
              _buildMyExperiences(context, user),
              const SpaceH30(),
              _buildFinalCheck(context, user),
              const SpaceH30(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _myCurriculumWeb(BuildContext context, UserEnreda? user,
      String profilePic, List<String> compNames, List<Experience> allExp) {
    return Padding(
      padding: EdgeInsets.all(Sizes.mainPadding),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: Container(
                  width: Responsive.isDesktop(context)
                      ? MediaQuery.of(context).size.width * 0.3
                      : Responsive.isDesktopS(context)
                          ? MediaQuery.of(context).size.width * 0.2
                          : 200,
                  padding: EdgeInsets.only(
                    left: Sizes.mainPadding * 2,
                    top: Sizes.mainPadding * 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.white,
                        AppColors.primary020.withValues(alpha: 0.13),
                        AppColors.primary400.withValues(alpha: 0.15),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 50.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMyProfilePhoto(user),
                        const SpaceH20(),
                        _buildPersonalData(context, user),
                        const SpaceH20(),
                        _buildAboutMe(context, user),
                        const SpaceH20(),
                        _buildMyDataOfInterest(context, user),
                        const SpaceH20(),
                        _buildMyLanguages(context, user),
                        const SpaceH20(),
                        _buildMyReferences(context, user),
                      ],
                    ),
                  ),
                ),
              ),
              const SpaceW40(),
              Flexible(
                fit: FlexFit.loose,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: Sizes.mainPadding * 2,
                    top: Sizes.mainPadding * 2,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCVHeader(context, user, profilePic, compNames),
                      const SpaceH30(),
                      _buildMyEducation(context, user),
                      const SpaceH30(),
                      _buildMySecondaryEducation(context, user),
                      const SpaceH30(),
                      _buildMyExperiences(context, user),
                      const SpaceH30(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SpaceH30(),
          _buildFinalCheck(context, user),
        ],
      ),
    );
  }

  Widget _myCurriculumMobile(BuildContext context, UserEnreda? user,
      String profilePic, List<String> compNames, List<Experience> allExp) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildDownloadCV(),
            ],
          ),
          const SpaceH16(),
          _buildMyProfilePhoto(user),
          const SpaceH12(),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${user?.firstName} ${user?.lastName}',
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.primary900,
                  ),
                ),
              ),
            ],
          ),
          const SpaceH24(),
          _buildPersonalData(context, user),
          const Divider(color: AppColors.greyBorder, thickness: 1, height: 40),
          _buildAboutMe(context, user),
          const Divider(color: AppColors.greyBorder, thickness: 1, height: 40),
          _buildMyEducation(context, user),
          const SpaceH24(),
          _buildMySecondaryEducation(context, user),
          const SpaceH24(),
          _buildMyExperiences(context, user),
          const SpaceH24(),
          _buildMyDataOfInterest(context, user),
          const SpaceH24(),
          _buildMyLanguages(context, user),
          const SpaceH24(),
          _buildMyReferences(context, user),
          const SpaceH24(),
          _buildFinalCheck(context, user),
          const SpaceH24(),
        ],
      ),
    );
  }

  Widget _buildCVHeader(BuildContext context, UserEnreda? user,
      String profilePic, List<String> compNames) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDownloadCV(),
        const SpaceH20(),
        SizedBox(
          width: Responsive.isDesktopS(context) ? 200.0 : 300.0,
          child: Text(
            '${user?.firstName} ${user?.lastName}',
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: Responsive.isDesktopS(context) ? 30.0 : 40.0,
              color: AppColors.primary900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadCV() {
    return EnredaButton(
      borderRadius: const BorderRadius.all(Radius.circular(25)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      buttonTitle: "Previsualizar y descargar",
      width: 0,
      onPressed: () async {
        final checkAgreeDownload = user?.checkAgreeCV ?? false;
        if (!checkAgreeDownload) {
          showAlertDialog(
            context,
            title: 'Aviso',
            content: 'Para continuar debe autorizar el uso de sus datos personales.',
            defaultActionText: 'Aceptar',
          );
          return;
        }
        await _hasEnoughExperiences(context);
        if (widget.onPreview != null) {
          widget.onPreview!();
        }
      },
    );
  }

  Widget _buildMyProfilePhoto(UserEnreda? userEnreda) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Sizes.mainPadding),
      width: double.infinity,
      child: Stack(
        children: [
          Theme(
            data: ThemeData(
              iconTheme: const IconThemeData(color: AppColors.white),
            ),
            child: InkWell(
              mouseCursor: WidgetStateMouseCursor.clickable,
              onTap: () => !kIsWeb
                  ? _displayPickImageDialog()
                  : _onImageButtonPressed(ImageSource.gallery),
              child: SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(120),
                      ),
                      child: !kIsWeb
                          ? ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(60)),
                              child: Center(
                                child: _photo == ""
                                    ? Image.asset(ImagePath.USER_DEFAULT, width: 120, height: 120)
                                    : CachedNetworkImage(
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        imageUrl: _photo,
                                      ),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(60)),
                              child: Center(
                                child: _photo == ""
                                    ? Image.asset(ImagePath.USER_DEFAULT, width: 120, height: 120)
                                    : PrecacheAvatarCard(
                                        imageUrl: _photo,
                                        height: 120,
                                        width: 120,
                                      ),
                              ),
                            ),
                    ),
                    Positioned(
                      left: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary900, width: 1.0),
                        ),
                        child: const Icon(
                          Icons.mode_edit_outlined,
                          size: 22,
                          color: AppColors.primary900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _displayPickImageDialog() async {
    final textTheme = Theme.of(context).textTheme;
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150,
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 24.0),
            child: Row(
              children: <Widget>[
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera, color: Colors.indigo, size: 30),
                      onPressed: () {
                        _onImageButtonPressed(ImageSource.camera);
                        Navigator.of(context).pop();
                      },
                    ),
                    Text('Cámara', style: textTheme.bodySmall?.copyWith(fontSize: 12.0)),
                  ],
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo, color: Colors.indigo, size: 30),
                      onPressed: () {
                        _onImageButtonPressed(ImageSource.gallery);
                        Navigator.of(context).pop();
                      },
                    ),
                    Text('Galería', style: textTheme.bodySmall?.copyWith(fontSize: 12.0)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<XFile?> _cropImage({required XFile imageFile}) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        WebUiSettings(
          context: context,
          presentStyle: WebPresentStyle.dialog,
          viewwMode: WebViewMode.mode_1,
          dragMode: WebDragMode.move,
          size: CropperSize(
            width: 420,
            height: (heightOfScreen(context) * 0.5).round(),
          ),
          cropBoxMovable: true,
          cropBoxResizable: true,
          movable: true,
          toggleDragModeOnDblclick: true,
          translations: const WebTranslations(
            title: 'Recortar imagen',
            rotateLeftTooltip: 'Rotar 90 grados a la izquierda',
            rotateRightTooltip: 'Rotar 90 grados a la derecha',
            cancelButton: 'Cancelar',
            cropButton: 'Recortar',
          ),
        ),
        AndroidUiSettings(
          toolbarTitle: 'Recortar imagen',
          toolbarColor: AppColors.white,
          toolbarWidgetColor: AppColors.primary900,
          activeControlsWidgetColor: AppColors.primaryColor,
          initAspectRatio: CropAspectRatioPreset.original,
          hideBottomControls: false,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Recortar imagen',
          doneButtonTitle: 'Listo',
          cancelButtonTitle: 'Cancelar',
          resetAspectRatioEnabled: true,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
          ],
        ),
      ],
    );
    if (croppedImage == null) return null;
    return XFile(croppedImage.path);
  }

  Future<void> _onImageButtonPressed(ImageSource source) async {
    try {
      XFile? pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        pickedFile = await _cropImage(imageFile: pickedFile);
        if (pickedFile != null) {
          final database = Provider.of<Database>(context, listen: false);
          final targetUserId = user?.userId ?? '';
          await database.uploadUserAvatar(targetUserId, await pickedFile.readAsBytes());
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Widget _buildMyCareer(BuildContext context, UserEnreda? user) {
    final database = Provider.of<Database>(context, listen: false);

    return StreamBuilder<List<Education>>(
      stream: database.educationStream(),
      builder: (context, snapshotEducations) {
        if (snapshotEducations.hasData) {
          final educations = snapshotEducations.data!;

          if (user?.educationId != null && user!.educationId!.isNotEmpty) {
            myMaxEducation = educations.firstWhere(
              (e) => e.educationId == user.educationId,
              orElse: () => Education(label: "", value: "", order: 0),
            );
            return CustomTextBody(text: myMaxEducation?.label ?? "");
          } else {
            final myEducationalExperiencies = (myExperiences ?? [])
                .where((experience) => experience.type == 'Formativa')
                .toList();
            if (myEducationalExperiencies.isNotEmpty) {
              final areEduactions = myEducationalExperiencies
                  .any((exp) => exp.education != null && exp.education!.isNotEmpty);
              if (areEduactions) {
                final myEducations = educations
                    .where((edu) => myEducationalExperiencies.any((exp) => exp.education == edu.label))
                    .toList();
                myEducations.sort((a, b) => a.order.compareTo(b.order));
                if (myEducations.isNotEmpty) {
                  myMaxEducation = myEducations.first;
                } else {
                  myMaxEducation = Education(label: "", value: "", order: 0);
                }
              } else {
                myMaxEducation = Education(label: "", value: "", order: 0);
              }
              return CustomTextBody(text: myMaxEducation?.label ?? "");
            }
            return const SizedBox.shrink();
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAboutMe(BuildContext context, UserEnreda? user) {
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;
    var isEditable = false;
    final textController = TextEditingController();
    final focusNode = FocusNode();
    textController.text = user?.aboutMe ?? '';

    return StatefulBuilder(builder: (context, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextTitle(title: StringConst.ABOUT_ME.toUpperCase()),
              ),
              InkWell(
                onTap: () async {
                  if (isEditable) {
                    await database.setUserEnreda(
                      user!.copyWith(aboutMe: textController.text),
                    );
                  }
                  setState(() {
                    isEditable = !isEditable;
                    if (isEditable) focusNode.requestFocus();
                  });
                },
                child: Icon(
                  isEditable ? Icons.save : Icons.edit_outlined,
                  size: Responsive.isDesktop(context) ? 18 : 15.0,
                  color: AppColors.greyDark,
                ),
              ),
            ],
          ),
          if (!isEditable)
            CustomTextBody(
              text: user?.aboutMe != null && user!.aboutMe!.isNotEmpty
                  ? user.aboutMe!
                  : 'Aún no has añadido información adicional sobre ti',
            ),
          if (isEditable)
            TextField(
              controller: textController,
              focusNode: focusNode,
              minLines: 1,
              maxLines: null,
              style: textTheme.bodySmall?.copyWith(),
            )
        ],
      );
    });
  }

  Widget _buildPersonalData(BuildContext context, UserEnreda? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextTitle(
          title: StringConst.PERSONAL_DATA.toUpperCase(),
          color: AppColors.primary900,
        ),
        const SpaceH8(),
        Row(
          children: [
            const Icon(Icons.mail, color: AppColors.greyDark, size: 16.0),
            const SpaceW4(),
            Flexible(child: CustomTextSmall(text: user?.email ?? '')),
          ],
        ),
        const SpaceH8(),
        Row(
          children: [
            const Icon(Icons.phone, color: AppColors.greyDark, size: 16.0),
            const SpaceW4(),
            Flexible(child: CustomTextSmall(text: user?.phone ?? '')),
          ],
        ),
        const SpaceH8(),
        _buildMyLocation(context, user),
      ],
    );
  }

  Widget _buildMyLocation(BuildContext context, UserEnreda? user) {
    final textTheme = Theme.of(context).textTheme;

    return StreamBuilder<Country>(
      stream: _countryStream,
      builder: (context, snapshotCountry) {
        final myCountry = snapshotCountry.data;
        return StreamBuilder<Province>(
          stream: _provinceStream,
          builder: (context, snapshotProvince) {
            final myProvince = snapshotProvince.data;
            return StreamBuilder<City>(
              stream: _cityStream,
              builder: (context, snapshotCity) {
                final myCity = snapshotCity.data;

                myLocation = '${myCity?.name ?? ''}, ${myProvince?.name ?? ''}, ${myCountry?.name ?? ''}';
                city = myCity?.name ?? '';
                province = myProvince?.name ?? '';
                country = myCountry?.name ?? '';

                myCustomCity = city!;
                myCustomProvince = province!;
                myCustomCountry = country!;

                return Row(
                  crossAxisAlignment: Responsive.isMobile(context)
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, color: AppColors.greyDark, size: 16),
                    const SpaceW4(),
                    Responsive.isMobile(context)
                        ? CustomTextSmall(text: myLocation ?? '')
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(city ?? '', style: textTheme.bodySmall?.copyWith()),
                              Text(province ?? '', style: textTheme.bodySmall?.copyWith()),
                              Text(country ?? '', style: textTheme.bodySmall?.copyWith()),
                            ],
                          ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }



  Widget _buildFinalCheck(BuildContext context, UserEnreda? user) {
    final database = Provider.of<Database>(context, listen: false);
    final bool checkFinal = user?.checkAgreeCV ?? false;
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 12, 14, md: 13);
    return Row(
      children: [
        IconButton(
          icon: Icon(checkFinal ? Icons.check_box : Icons.crop_square),
          color: AppColors.primary900,
          iconSize: 20.0,
          onPressed: () {
            showAlertDialog(
              context,
              title: 'Aviso',
              content: 'Se ha guardado la autorización de uso de datos.',
              defaultActionText: 'Aceptar',
            );
            database.setUserEnreda(user!.copyWith(checkAgreeCV: !checkFinal));
          },
        ),
        Flexible(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: StringConst.FORM_ACCORDING,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.primary900,
                    height: 1.5,
                    fontSize: fontSize,
                  ),
                ),
                TextSpan(
                  text: StringConst.PERSONAL_DATA_LAW,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.primary900,
                    height: 1.5,
                    fontSize: fontSize,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchURL(StringConst.PERSONAL_DATA_LAW_PDF);
                    },
                ),
                TextSpan(
                  text: StringConst.PERSONAL_DATA_LAW_TEXT,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.primary900,
                    height: 1.5,
                    fontSize: fontSize,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildMyEducation(BuildContext context, UserEnreda? user) {
    final database = Provider.of<Database>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextTitle(title: StringConst.EDUCATIONAL_LEVEL.toUpperCase()),
            const SpaceW8(),
            _addButton(() {
              showDialog(
                context: context,
                builder: (context) => AddEducationalLevel(
                  selectedEducation: myMaxEducation,
                  onSaved: (selectedEducation) {
                    database.setUserEnreda(
                      user!.copyWith(educationId: selectedEducation?.educationId ?? ""),
                    );
                  },
                ),
              );
            }),
          ],
        ),
        _buildMyCareer(context, user),
        const Divider(color: AppColors.greyBorder, thickness: 1, height: 40),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextTitle(title: StringConst.EDUCATION.toUpperCase(), color: AppColors.primary900),
            const SpaceW8(),
            _addButton(() {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  content: FormationForm(
                    isMainEducation: true,
                    userId: user?.userId,
                  ),
                ),
              );
            }),
          ],
        ),
        const SpaceH4(),
        () {
          myEducation = (myExperiences ?? []).where((e) => e.type == 'Formativa').toList();
          myCustomEducation = myEducation!.toList();
          mySelectedEducation = List.generate(myCustomEducation.length, (i) => i);
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              color: Colors.white,
            ),
            child: myEducation!.isNotEmpty
                ? Wrap(
                    children: myEducation!
                        .map((e) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SpaceH12(),
                                SizedBox(
                                  width: double.infinity,
                                  child: ExperienceTile(experience: e, type: e.type),
                                ),
                                const Divider(color: AppColors.greyBorder),
                              ],
                            ))
                        .toList(),
                  )
                : CustomTextBody(text: StringConst.NO_EDUCATION),
          );
        }(),
      ],
    );
  }

  Widget _buildMySecondaryEducation(BuildContext context, UserEnreda? user) {
    return Column(
      children: [
        Row(
          children: [
            CustomTextTitle(title: StringConst.SECONDARY_EDUCATION.toUpperCase(), color: AppColors.primary900),
            const SpaceW8(),
            _addButton(() {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  content: FormationForm(
                    isMainEducation: false,
                    userId: user?.userId,
                  ),
                ),
              );
            }),
          ],
        ),
        const SpaceH4(),
        () {
          mySecondaryEducation = (myExperiences ?? []).where((e) => e.type == 'Complementaria').toList();
          mySecondaryCustomEducation = mySecondaryEducation!.toList();
          mySecondarySelectedEducation = List.generate(mySecondaryCustomEducation.length, (i) => i);
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              color: Colors.white,
            ),
            child: mySecondaryEducation!.isNotEmpty
                ? Wrap(
                    children: mySecondaryEducation!
                        .map((e) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SpaceH12(),
                                SizedBox(
                                  width: double.infinity,
                                  child: ExperienceTile(experience: e, type: e.type),
                                ),
                                const Divider(color: AppColors.greyBorder),
                              ],
                            ))
                        .toList(),
                  )
                : CustomTextBody(text: StringConst.NO_EDUCATION),
          );
        }(),
      ],
    );
  }

  Widget _buildProfesionalExperience(BuildContext context, UserEnreda? user) {
    return Column(
      children: [
        Row(
          children: [
            CustomTextSubTitle(title: StringConst.MY_PROFESIONAL_EXPERIENCES.toUpperCase()),
            const SpaceW8(),
            _addButton(() {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  content: ExperienceFormUpdate(
                    isProfesional: true,
                    userId: user?.userId,
                  ),
                ),
              );
            }),
          ],
        ),
        const SpaceH4(),
        () {
          final myProfExperiences = (myExperiences ?? []).where((e) => e.type == 'Profesional').toList();
          myCustomExperiences = myProfExperiences.toList();
          mySelectedExperiences = List.generate(myCustomExperiences.length, (i) => i);
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              color: Colors.white,
            ),
            child: myProfExperiences.isNotEmpty
                ? Wrap(
                    children: myProfExperiences
                        .map((e) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SpaceH4(),
                                SizedBox(
                                  width: double.infinity,
                                  child: ExperienceTile(experience: e, type: e.type),
                                ),
                                const Divider(color: AppColors.greyBorder),
                              ],
                            ))
                        .toList(),
                  )
                : CustomTextBody(text: StringConst.NO_EXPERIENCE),
          );
        }(),
      ],
    );
  }

  Widget _buildPersonalExperience(BuildContext context, UserEnreda? user) {
    return Column(
      children: [
        Row(
          children: [
            CustomTextSubTitle(title: StringConst.MY_PERSONAL_EXPERIENCES.toUpperCase()),
            const SpaceW8(),
            _addButton(() {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  content: ExperienceFormUpdate(
                    isProfesional: false,
                    userId: user?.userId,
                  ),
                ),
              );
            }),
          ],
        ),
        const SpaceH4(),
        () {
          myPersonalExperiences = (myExperiences ?? []).where((e) => e.type == 'Personal').toList();
          myPersonalCustomExperiences = myPersonalExperiences!.toList();
          myPersonalSelectedExperiences = List.generate(myPersonalCustomExperiences.length, (i) => i);
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              color: Colors.white,
            ),
            child: myPersonalExperiences!.isNotEmpty
                ? Wrap(
                    children: myPersonalExperiences!
                        .map((e) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SpaceH4(),
                                SizedBox(
                                  width: double.infinity,
                                  child: ExperienceTile(experience: e, type: e.type),
                                ),
                                const Divider(color: AppColors.greyBorder),
                              ],
                            ))
                        .toList(),
                  )
                : CustomTextBody(text: StringConst.NO_EXPERIENCE),
          );
        }(),
      ],
    );
  }

  Widget _buildMyExperiences(BuildContext context, UserEnreda? user) {
    return Column(
      children: [
        Row(
          children: [
            CustomTextTitle(title: StringConst.MY_EXPERIENCES.toUpperCase(), color: AppColors.primary900),
            const SpaceW8(),
            _addButton(() {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  content: ExperienceFormUpdate(
                    isProfesional: false,
                    general: true,
                    userId: user?.userId,
                  ),
                ),
              );
            }),
          ],
        ),
        const SpaceH4(),
        _buildProfesionalExperience(context, user),
        const SpaceH4(),
        _buildPersonalExperience(context, user),
      ],
    );
  }

  Widget _buildMyDataOfInterest(BuildContext context, UserEnreda? user) {
    final database = Provider.of<Database>(context, listen: false);
    final myDataOfInterest = user?.dataOfInterest ?? [];

    return Column(
      children: [
        Row(
          children: [
            CustomTextTitle(title: StringConst.DATA_OF_INTEREST.toUpperCase()),
            const SpaceW8(),
            _addButton(() {
              _showDataOfInterestDialog(context, '');
            }),
          ],
        ),
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
                              const SpaceH12(),
                              SizedBox(
                                height: 20.0,
                                child: Row(
                                  children: [
                                    Expanded(child: CustomTextBody(text: d)),
                                    const SpaceW12(),
                                    InkWell(
                                      onTap: () => _showDataOfInterestDialog(context, d),
                                      child: const Icon(Icons.edit_outlined, color: AppColors.greyDark, size: 18.0),
                                    ),
                                    const SpaceW12(),
                                    InkWell(
                                      onTap: () {
                                        user!.dataOfInterest.remove(d);
                                        database.setUserEnreda(user);
                                      },
                                      child: Image.asset(ImagePath.ICON_TRASH, width: 18.0),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ))
                      .toList(),
                )
              : CustomTextBody(text: StringConst.NO_DATA_OF_INTEREST),
        ),
      ],
    );
  }

  Widget _buildMyLanguages(BuildContext context, UserEnreda? user) {
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;
    final myLanguages = user?.languagesLevels ?? [];

    return Column(
      children: [
        Row(
          children: [
            CustomTextTitle(title: StringConst.LANGUAGES.toUpperCase()),
            const SpaceW8(),
            _addButton(() => _showLanguagesDialog(context, null)),
          ],
        ),
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
                              const SpaceH12(),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      l.name,
                                      style: textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => _showLanguagesDialog(context, l),
                                    child: const Icon(Icons.edit_outlined, color: AppColors.greyDark, size: 18.0),
                                  ),
                                  const SpaceW12(),
                                  InkWell(
                                    onTap: () {
                                      user!.languagesLevels.remove(l);
                                      database.setUserEnreda(user);
                                    },
                                    child: Image.asset(ImagePath.ICON_TRASH, width: 18.0),
                                  ),
                                ],
                              ),
                              const SpaceH12(),
                              _buildSpeakingLevelRow(
                                value: l.speakingLevel.toDouble(),
                                textTheme: textTheme,
                                iconSize: 15.0,
                                onValueChanged: null,
                              ),
                              const SpaceH12(),
                              _buildWritingLevelRow(
                                value: l.writingLevel.toDouble(),
                                textTheme: textTheme,
                                iconSize: 15.0,
                                onValueChanged: null,
                              ),
                            ],
                          ))
                      .toList(),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
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
            const SpaceW12(),
          ],
        ),
        const SpaceH4(),
        StreamBuilder<List<CertificationRequest>>(
          stream: database.myCertificationRequestStream(user?.userId ?? ''),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.connectionState == ConnectionState.active) {
              myReferences = snapshot.data!
                  .where((r) => r.referenced == true)
                  .toList();
              myCustomReferences = myReferences!.toList();
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SpaceH12(),
                                    SizedBox(
                                      width: double.infinity,
                                      child: Row(
                                        children: [
                                          ReferenceTile(certificationRequest: e),
                                          const Spacer(),
                                          InkWell(
                                            onTap: () => _showReferencesDialog(context, e),
                                            child: const Icon(Icons.edit_outlined, color: AppColors.greyDark, size: 18.0),
                                          ),
                                          const SpaceW12(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ))
                            .toList(),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(child: CustomTextSmall(text: StringConst.NO_REFERENCES)),
                      ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ],
    );
  }

  Future<void> _showDataOfInterestDialog(BuildContext context, String currentText) async {
    final database = Provider.of<Database>(context, listen: false);
    final controller = TextEditingController();
    final textTheme = Theme.of(context).textTheme;
    final formKey = GlobalKey<FormState>();
    if (currentText.isNotEmpty) {
      controller.text = currentText;
    }
    await showCustomDialog(
      context,
      content: Card(
        elevation: 0,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                StringConst.NEW_DATA_OF_INTEREST,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
              const SpaceH12(),
              Form(
                key: formKey,
                child: TextFormField(
                  controller: controller,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.normal,
                    fontSize: 14.0,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo no puede estar vacío';
                    }
                    return null;
                  },
                ),
              )
            ],
          ),
        ),
      ),
      defaultActionText: StringConst.FORM_ACCEPT,
      cancelActionText: StringConst.CANCEL,
      dismissible: true,
      onDefaultActionPressed: (context) {
        if (formKey.currentState!.validate()) {
          if (currentText.isNotEmpty) {
            user!.dataOfInterest.remove(currentText);
          }
          user!.dataOfInterest.add(controller.text);
          database.setUserEnreda(user!);
          Navigator.of(context).pop();
        }
      },
    );
  }

  void _showReferencesDialog(BuildContext context, CertificationRequest certificationRequest) {
    final database = Provider.of<Database>(context, listen: false);
    final controllerName = TextEditingController();
    final controllerPosition = TextEditingController();
    final controllerCompany = TextEditingController();
    final textTheme = Theme.of(context).textTheme;
    if (certificationRequest.certifierName.isNotEmpty) {
      controllerName.text = certificationRequest.certifierName;
    }
    if (certificationRequest.certifierPosition.isNotEmpty) {
      controllerPosition.text = certificationRequest.certifierPosition;
    }
    if (certificationRequest.certifierCompany.isNotEmpty) {
      controllerCompany.text = certificationRequest.certifierCompany;
    }
    showCustomDialog(
      context,
      content: Card(
        elevation: 0,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                StringConst.NEW_REFERENCE,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
              const SpaceH16(),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controllerName,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.normal,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controllerPosition,
                      decoration: const InputDecoration(labelText: 'Cargo'),
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.normal,
                        fontSize: 14.0,
                      ),
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controllerCompany,
                      decoration: const InputDecoration(labelText: 'Empresa'),
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.normal,
                        fontSize: 14.0,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
      defaultActionText: StringConst.FORM_ACCEPT,
      onDefaultActionPressed: (context) {
        final index = myReferences?.indexWhere((element) =>
            element.certifierName == certificationRequest.certifierName);
        if (index != null && index >= 0) {
          final updated = myReferences![index].copyWith(
            certifierName: controllerName.text,
            certifierPosition: controllerPosition.text,
            certifierCompany: controllerCompany.text,
          );
          database.setCertificationRequest(updated);
        }
        Navigator.of(context).pop();
      },
    );
  }

  void _showLanguagesDialog(BuildContext context, Language? language) {
    final database = Provider.of<Database>(context, listen: false);
    final controller = TextEditingController();
    final textTheme = Theme.of(context).textTheme;
    final formKey = GlobalKey<FormState>();
    if (language != null) {
      controller.text = language.name;
      speakingLevel = language.speakingLevel.toDouble();
      writingLevel = language.writingLevel.toDouble();
    }
    showCustomDialog(
      context,
      content: StatefulBuilder(builder: (context, setState) {
        return Form(
          key: formKey,
          child: Card(
            elevation: 0,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    StringConst.NEW_LANGUAGE,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                  const SpaceH12(),
                  TextFormField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.normal,
                      fontSize: 14.0,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'El nombre del idioma no puede estar vacío';
                      if (language != null &&
                          language.name != value &&
                          user!.languagesLevels.any((l) => l.name == value)) {
                        return 'Este idioma ya ha sido añadido';
                      }
                      return null;
                    },
                  ),
                  const SpaceH12(),
                  _buildSpeakingLevelRow(
                    value: speakingLevel,
                    textTheme: textTheme,
                    onValueChanged: (v) {
                      setState(() {
                        speakingLevel = v;
                      });
                    },
                  ),
                  const SpaceH12(),
                  _buildWritingLevelRow(
                    value: writingLevel,
                    textTheme: textTheme,
                    onValueChanged: (v) {
                      setState(() {
                        writingLevel = v;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      defaultActionText: StringConst.FORM_ACCEPT,
      cancelActionText: StringConst.CANCEL,
      dismissible: true,
      onDefaultActionPressed: (context) {
        if (formKey.currentState!.validate()) {
          if (language != null) {
            user!.languagesLevels.remove(language);
          }
          user!.languagesLevels.add(Language(
            name: controller.text,
            speakingLevel: speakingLevel.toInt(),
            writingLevel: writingLevel.toInt(),
          ));
          database.setUserEnreda(user!);
          Navigator.of(context).pop();
        }
      },
    );
  }

  Widget _buildWritingLevelRow({
    required TextTheme textTheme,
    required double value,
    double iconSize = 20.0,
    dynamic Function(double)? onValueChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Expresión escrita',
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.normal,
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
          color: AppColors.primary900,
          borderColor: AppColors.primary900,
          spacing: 5.0,
        )
      ],
    );
  }

  Widget _buildSpeakingLevelRow({
    required TextTheme textTheme,
    required double value,
    double iconSize = 20.0,
    dynamic Function(double)? onValueChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Expresión oral',
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.normal,
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
          color: AppColors.primary900,
          borderColor: AppColors.primary900,
          spacing: 5.0,
        )
      ],
    );
  }

  Future<void> _hasEnoughExperiences(BuildContext context) async {
    if ((myExperiences?.length ?? 0) < 2) {
      await showCustomDialog(
        context,
        content: CustomTextBody(text: StringConst.ADD_MORE_EXPERIENCES_SUGGESTION),
        defaultActionText: StringConst.FORM_ACCEPT,
        onDefaultActionPressed: (dialogContext) => Navigator.of(dialogContext).pop(true),
      );
    }
  }

  Widget _addButton(Function() onPress) {
    return CircleAvatar(
      radius: 10,
      backgroundColor: AppColors.primary900,
      child: InkWell(
        onTap: onPress,
        child: const Icon(Icons.add, size: 14, color: Colors.white),
      ),
    );
  }
}
