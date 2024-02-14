import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:enreda_empresas/app/common_widgets/alert_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/custom_drop_down_button_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/custom_phone_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/custom_stepper.dart';
import 'package:enreda_empresas/app/common_widgets/custom_stepper_button.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/enreda_button.dart';
import 'package:enreda_empresas/app/common_widgets/flex_row_column.dart';
import 'package:enreda_empresas/app/common_widgets/show_exception_alert_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/text_form_field.dart';
import 'package:enreda_empresas/app/home/resources/my_resources_list_page.dart';
import 'package:enreda_empresas/app/home/resources/validating_form_controls/stream_builder_competencies.dart';
import 'package:enreda_empresas/app/home/resources/validating_form_controls/stream_builder_competencies_categories.dart';
import 'package:enreda_empresas/app/home/resources/validating_form_controls/stream_builder_competencies_sub_categories.dart';
import 'package:enreda_empresas/app/home/resources/validating_form_controls/stream_builder_interests.dart';
import 'package:enreda_empresas/app/home/resources/validating_form_controls/stream_builder_social_entities.dart';
import 'package:enreda_empresas/app/home/resources/validating_form_controls/stream_builder_province.dart';
import 'package:enreda_empresas/app/home/resources/validating_form_controls/stream_builder_resource_category.dart';
import 'package:enreda_empresas/app/home/social_entity/entity_directory_page.dart';
import 'package:enreda_empresas/app/models/addressUser.dart';
import 'package:enreda_empresas/app/models/city.dart';
import 'package:enreda_empresas/app/models/competency.dart';
import 'package:enreda_empresas/app/models/competencyCategory.dart';
import 'package:enreda_empresas/app/models/competencySubCategory.dart';
import 'package:enreda_empresas/app/models/country.dart';
import 'package:enreda_empresas/app/models/interest.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/models/resource.dart';
import 'package:enreda_empresas/app/models/resourceCategory.dart';
import 'package:enreda_empresas/app/models/province.dart';
import 'package:enreda_empresas/app/models/resourcePicture.dart';
import 'package:enreda_empresas/app/models/resourcetype.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/home/resources/validating_form_controls/stream_builder_city.dart';
import 'package:enreda_empresas/app/home/resources/validating_form_controls/stream_builder_country.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:enreda_empresas/app/home/resources/global.dart' as globals;

const double contactBtnWidthLg = 200.0;
const double contactBtnWidthSm = 100.0;
const double contactBtnWidthMd = 140.0;

class EditSocialEntity extends StatefulWidget {
  EditSocialEntity(
      {Key? key}) : super(key: key);

  @override
  State<EditSocialEntity> createState() => _EditSocialEntityState();
}

class _EditSocialEntityState extends State<EditSocialEntity> {
  late SocialEntity socialEntity;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  int currentStep = 0;
  // String? _resourceId;
  String? _socialEntityName;
  String? _socialEntityActionScope;
  String? _category;
  String? _subCategory;
  String? _geographicZone;
  String? _subGeographicZone;
  String? _website;
  String? _email;
  String? _entityLandlinePhone;
  String? _entityMobilePhone;
  String? _linkedin;
  String? _twitter;
  String? _otherSocialMedia;
  String? _contactName;
  String? _contactPhone;
  String? _contactMobilePhone;
  String? _contactEmail;
  String? _contactPosition;
  String? _contactChoiceGrade;
  String? _contactKOL;
  String? _contactProject;
  String _entityLandlinePhoneCode = '+34';
  String _entityMobilePhoneCode = '+34';
  String _contactLandlinePhoneCode = '+34';
  String _contactMobilePhoneCode = '+34';

  // String? _countryId;
  // String? _provinceId;
  // String? _cityId;
  // String? _resourceTypeId;
  // String? _resourceCategoryId;
  // DateTime? _start;
  // DateTime? _end;
  // DateTime? _max;
  // DateTime? _createdate;
  // String? _modality;
  // String? _resourcePictureId;
  // String? _assistants;
  // String? _status;
  // String? interestsNamesString;
  // String? competenciesNames;
  // String? competenciesCategoriesNames;
  // String? competenciesSubCategoriesNames;
  //
  // List<String> interests = [];
  // List<String> _interests = [];
  // List<String> _competencies = [];
  // List<String> _competenciesCategories = [];
  // List<String> _competenciesSubCategories = [];
  // List<String> _participants = [];
  // Set<Interest> selectedInterestsSet = {};
  // Set<Competency> selectedCompetenciesSet = {};
  // Set<CompetencyCategory> selectedCompetenciesCategoriesSet = {};
  // Set<CompetencySubCategory> selectedCompetenciesSubCategoriesSet = {};
  // ResourceCategory? selectedResourceCategory;
  // ResourcePicture? selectedResourcePicture;
  // SocialEntity? selectedSocialEntity;
  //
  // ResourceType? selectedResourceType;
  // Country? selectedCountry;
  // Province? selectedProvince;
  // City? selectedCity;
  //
  // int? resourceCategoryValue;
  // String? organizationId;
  //
  // TextEditingController? textEditingControllerInterests = TextEditingController();
  // TextEditingController textEditingControllerCompetencies = TextEditingController();
  // TextEditingController textEditingControllerCompetenciesCategories = TextEditingController();
  // TextEditingController textEditingControllerCompetenciesSubCategories = TextEditingController();

  List<String> subCategories = ['Financiación', 'Cooperación técnica', 'Posicionamiento y reputación', 'Asociados'];
  List<String> geographicZone = ['Global', 'Regional', 'Local'];
  List<String> choiceGrade = ['Alto', 'Intermedio', 'Bajo'];
  List<String> yesNo = ['Si', 'No'];

  @override
  void initState() {
    super.initState();
    socialEntity = globals.currentSocialEntity!;
    // _resourceId = globals.currentResource?.resourceId;
    // _interests = globals.currentResource?.interests ?? [];
    // _competencies = globals.currentResource?.competencies ?? [];
    _socialEntityName = globals.currentSocialEntity?.name;
    // _duration = globals.currentResource?.duration ?? '';
    // _temporality = globals.currentResource?.temporality ?? '';
    _socialEntityActionScope = globals.currentSocialEntity?.actionScope;
    // _modality = globals.currentResource?.modality;
    // _start = globals.currentResource?.start ?? DateTime.now();
    // _end = globals.currentResource?.end ?? DateTime.now();
    // _max = globals.currentResource?.maximumDate ?? DateTime.now();
    // _resourceTypeId = globals.currentResource?.resourceType ?? '';
    // _resourceCategoryId = globals.currentResource?.resourceCategory ?? '';
    // _contractType = globals.currentResource?.contractType ?? '';
    // _salary = globals.currentResource?.salary ?? '';
    _category = globals.currentSocialEntity?.category ?? '';
    _subCategory = globals.currentSocialEntity?.category ?? '';
    _geographicZone = globals.currentSocialEntity?.geographicZone ?? '';
    _subGeographicZone = globals.currentSocialEntity?.subGeographicZone ?? '';
    _website = globals.currentSocialEntity?.website ?? '';
    _website = globals.currentSocialEntity?.website ?? '';
    _entityLandlinePhone = globals.currentSocialEntity?.entityPhone ?? '';
    _entityMobilePhone = globals.currentSocialEntity?.entityMobilePhone ?? '';
    _contactPhone = globals.currentSocialEntity?.contactPhone ?? '';
    _contactMobilePhone = globals.currentSocialEntity?.contactMobilePhone ?? '';
    _entityLandlinePhoneCode = globals.currentSocialEntity?.entityPhone == null || globals.currentSocialEntity?.entityPhone == '' ? '+34' : '${globals.currentSocialEntity?.entityPhone?[0]}${globals.currentSocialEntity?.entityPhone?[1]}${globals.currentSocialEntity?.entityPhone?[2]}';
    _entityMobilePhoneCode = globals.currentSocialEntity?.entityMobilePhone == null || globals.currentSocialEntity?.entityMobilePhone == '' ? '+34' : '${globals.currentSocialEntity?.entityMobilePhone?[0]}${globals.currentSocialEntity?.entityMobilePhone?[1]}${globals.currentSocialEntity?.entityMobilePhone?[2]}';
    _contactLandlinePhoneCode = globals.currentSocialEntity?.contactPhone == null || globals.currentSocialEntity?.contactPhone == '' ? '+34' : '${globals.currentSocialEntity?.contactPhone?[0]}${globals.currentSocialEntity?.contactPhone?[1]}${globals.currentSocialEntity?.contactPhone?[2]}';
    _contactMobilePhoneCode = globals.currentSocialEntity?.contactMobilePhone == null || globals.currentSocialEntity?.contactMobilePhone == ''? '+34' : '${globals.currentSocialEntity?.contactMobilePhone?[0]}${globals.currentSocialEntity?.contactMobilePhone?[1]}${globals.currentSocialEntity?.contactMobilePhone?[2]}';
    // _place = globals.currentResource?.address?.place ?? '';
    // _street = globals.currentResource?.street ?? '';
    // _capacity = globals.currentResource?.capacity ?? 0;
    // _countryId = globals.currentResource?.address?.country ?? '';
    // _provinceId = globals.currentResource?.address?.province ?? '';
    // _provinceId = globals.currentResource?.address?.province ?? '';
    // _cityId = globals.currentResource?.address?.city ?? '';
    // _organizerText = globals.currentResource?.promotor ?? '';
    // _link = globals.currentResource?.link ?? '';
    // _phone = globals.currentResource?.contactPhone ?? '';
    _email = globals.currentSocialEntity?.email ?? '';
    _linkedin = globals.currentSocialEntity?.linkedin ?? '';
    _twitter = globals.currentSocialEntity?.twitter ?? '';
    _otherSocialMedia = globals.currentSocialEntity?.otherSocialMedia ?? '';
    _contactName = globals.currentSocialEntity?.contactName ?? '';
    _contactEmail = globals.currentSocialEntity?.contactEmail ?? '';
    _contactPosition = globals.currentSocialEntity?.contactPosition ?? '';
    _contactChoiceGrade = globals.currentSocialEntity?.contactChoiceGrade ?? '';
    _contactKOL = globals.currentSocialEntity?.contactKOL ?? '';
    _contactProject = globals.currentSocialEntity?.contactProject ?? '';
    // _resourcePictureId = globals.currentResource?.resourcePictureId ?? '';
    // _notExpire = globals.currentResource?.notExpire ?? false;
    // _createdate = globals.currentResource?.createdate;
    // _organizer = globals.currentResource?.organizer;
    // _organizerType = globals.currentResource?.organizerType ?? '';
    // _resourceLink = globals.currentResource?.resourceLink ?? '';
    // _participants = globals.currentResource?.participants ?? [];
    // _assistants = globals.currentResource?.assistants ?? '';
    // _status = globals.currentResource?.status ?? '';
    // interestsNamesString = globals.interestsNamesCurrentResource!;
    // selectedInterestsSet = globals.selectedInterestsCurrentResource;
    // competenciesNames = globals.competenciesNamesCurrentResource!;
    // selectedCompetenciesSet = globals.selectedCompetenciesCurrentResource;
    // selectedSocialEntity = globals.organizerCurrentResource;
    // textEditingControllerInterests = TextEditingController(text: globals.interestsNamesCurrentResource!);
    // textEditingControllerCompetencies = TextEditingController(text: globals.competenciesNamesCurrentResource!);
    // textEditingControllerCompetenciesCategories = TextEditingController();
    // textEditingControllerCompetenciesSubCategories = TextEditingController();
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    double contactBtnWidth = responsiveSize(
      context,
      contactBtnWidthSm,
      contactBtnWidthLg,
      md: contactBtnWidthMd,
    );
    return Center(
      child: Container(
        height: Responsive.isMobile(context) ||
            Responsive.isTablet(context)
            ? MediaQuery.of(context).size.height
            : MediaQuery.of(context).size.height * 0.80,
        width: Responsive.isMobile(context) ||
            Responsive.isTablet(context)
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.width * 0.80,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(
              Sizes.kDefaultPaddingDouble / 2),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildForm(context),
              Container(
                height: Sizes.kDefaultPaddingDouble * 2,
                margin: const EdgeInsets.only(top: Sizes.kDefaultPaddingDouble * 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (currentStep == 0)
                      EnredaButton(
                        buttonTitle: StringConst.CANCEL,
                        width: contactBtnWidth,
                        onPressed: onStepCancel,
                        padding: EdgeInsets.all(0.0),
                      ),
                    const SizedBox(width: Sizes.kDefaultPaddingDouble),
                    isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                            color: AppColors.primary300,
                          ))
                        : EnredaButton(
                            buttonTitle: StringConst.FORM_UPDATE,
                            width: contactBtnWidth,
                            buttonColor: AppColors.primaryColor,
                            titleColor: AppColors.white,
                            onPressed: onStepContinue,
                            padding: EdgeInsets.all(4.0),
                          ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CustomFlexRowColumn(
              childLeft: customTextFormField(context, _socialEntityName!,
                  StringConst.FORM_NAME_ENTITY, StringConst.FORM_COMPANY_ERROR, nameSetState),
              childRight: customTextFormField(
                  context,
                  _socialEntityActionScope!,
                  StringConst.ACTION_SCOPE,
                  StringConst.FORM_COMPANY_ERROR,
                  socialEntityActionScopeSetState),
            ),
            CustomFlexRowColumn(
              childLeft: customTextFormField(context, _category!,
                  StringConst.CATEGORY, StringConst.FORM_COMPANY_ERROR, categorySetState),
              childRight: customTextFormStringList(
                  context,
                  subCategories,
                  _subCategory!,
                  StringConst.SUB_CATEGORY,
                  StringConst.FORM_COMPANY_ERROR,
                  subCategorySetState),
            ),
            CustomFlexRowColumn(
              childLeft: customTextFormStringList(
                  context,
                  geographicZone,
                  _geographicZone!,
                  StringConst.ZONE,
                  StringConst.FORM_COMPANY_ERROR,
                  geographicZoneSetState),
              childRight: customTextFormField(
                  context,
                  _subGeographicZone!,
                  StringConst.SUB_ZONE,
                  StringConst.FORM_COMPANY_ERROR,
                  subGeographicZoneSetState),
            ),
            CustomFlexRowColumn(
              childLeft: customTextFormField(context, _website!,
                  StringConst.FORM_WEBSITE, StringConst.FORM_ERROR, websiteSetState),
              childRight: customTextFormField(context, _email!,
              StringConst.EMAIL, StringConst.FORM_COMPANY_ERROR, emailSetState),
            ),
            CustomFlexRowColumn(
              childLeft: customTextFormPhone(
                context,
                _entityLandlinePhone!,
                _entityLandlinePhoneCode,
                StringConst.FORM_LANDLINE,
                StringConst.FORM_COMPANY_ERROR,
                _onCountryChangeEntityLandline,
              ),
              childRight: customTextFormPhone(
                context,
                _entityMobilePhone!,
                _entityMobilePhoneCode,
                StringConst.FORM_MOBILE_PHONE,
                StringConst.FORM_COMPANY_ERROR,
                _onCountryChangeMobilePhone,
              ),
            ),
            CustomFlexRowColumn(
              childLeft: customTextFormFieldNotValidator(context, _linkedin!,
                  StringConst.FORM_LINKEDIN, linkedinSetState),
              childRight: customTextFormFieldNotValidator(context, _twitter!,
                  StringConst.FORM_TWITTER, twitterSetState),
            ),
            CustomFlexRowColumn(
              childLeft: customTextFormFieldNotValidator(context, _otherSocialMedia!,
                  StringConst.FORM_OTHER_SOCIAL_MEDIA, otherSocialMediaSetState),
              childRight: Container(),
            ),
            SizedBox(height: 20.0,),
            CustomTextMediumBold(text: StringConst.CONTACT_INFORMATION.toUpperCase(),),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: customTextFormField(
                  context,
                  _contactName!,
                  StringConst.FORM_CONTACT_TEC_NAME,
                  StringConst.FORM_COMPANY_ERROR,
                  contactNameSetState),
            ),
            CustomFlexRowColumn(
              childLeft: customTextFormPhone(
                context,
                _contactPhone!,
                _contactLandlinePhoneCode,
                StringConst.FORM_LANDLINE,
                StringConst.FORM_COMPANY_ERROR,
                _onCountryChangeContactLandline,
              ),
              childRight: customTextFormPhone(
                context,
                _contactMobilePhone!,
                _contactMobilePhoneCode,
                StringConst.FORM_MOBILE_PHONE,
                StringConst.FORM_COMPANY_ERROR,
                _onCountryChangeContactMobilePhone,
              ),
            ),
            CustomFlexRowColumn(
              childLeft: customTextFormField(
                  context,
                  _contactEmail!,
                  StringConst.FORM_EMAIL,
                  StringConst.FORM_COMPANY_ERROR,
                  contactEmailSetState),
              childRight: customTextFormField(
                  context,
                  _contactPosition!,
                  StringConst.FORM_CONTACT_POSITION,
                  StringConst.FORM_COMPANY_ERROR,
                  contactPositionSetState),
            ),
            CustomFlexRowColumn(
              childLeft: customTextFormStringList(
                  context,
                  choiceGrade,
                  _contactChoiceGrade!,
                  StringConst.CONTACT_CHOICE_GRADE,
                  StringConst.FORM_COMPANY_ERROR,
                  contactChoiceGradeSetState),
              childRight: customTextFormStringList(
                  context,
                  yesNo,
                  _contactKOL!,
                  StringConst.CONTACT_OPINION_LEADER,
                  StringConst.FORM_COMPANY_ERROR,
                  contactKOLSetState),
            ),
            CustomFlexRowColumn(
              childLeft: customTextFormField(context, _contactProject!,
                  StringConst.FORM_CONTACT_PROJECT, StringConst.FORM_COMPANY_ERROR, contactProjectSetState),
              childRight: customTextFormField(context, _contactProject!,
                  StringConst.FORM_CONTACT_PROJECT, StringConst.FORM_COMPANY_ERROR, contactProjectSetState),
            ),
          ]),
    );
  }

  void nameSetState(String? val) {
    setState(() => _socialEntityName = val!);
  }

  void socialEntityActionScopeSetState(String? val) {
    setState(() => _socialEntityActionScope = val!);
  }

  void categorySetState(String? val) {
    setState(() => _category = val!);
  }

  void subCategorySetState(String? val) {
    setState(() => _subCategory = val!);
  }

  void geographicZoneSetState(String? val) {
    setState(() => _geographicZone = val!);
  }

  void subGeographicZoneSetState(String? val) {
    setState(() => _subGeographicZone = val!);
  }

  void websiteSetState(String? val) {
    setState(() => _website = val!);
  }

  void emailSetState(String? val) {
    setState(() => _email = val!);
  }

  void _onCountryChangeEntityLandline(CountryCode countryCode) {
    _entityLandlinePhoneCode = countryCode.toString();
  }

  void _onCountryChangeMobilePhone(CountryCode countryCode) {
    _entityMobilePhoneCode = countryCode.toString();
  }
  void _onCountryChangeContactLandline(CountryCode countryCode) {
    _contactLandlinePhoneCode = countryCode.toString();
  }
  void _onCountryChangeContactMobilePhone(CountryCode countryCode) {
    _contactMobilePhoneCode = countryCode.toString();
  }

  void linkedinSetState(String? val) {
    setState(() => _linkedin = val!);
  }

  void twitterSetState(String? val) {
    setState(() => _twitter = val!);
  }

  void otherSocialMediaSetState(String? val) {
    setState(() => _otherSocialMedia = val!);
  }

  void contactNameSetState(String? val) {
    setState(() => _contactName = val!);
  }

  void contactEmailSetState(String? val) {
    setState(() => _contactEmail = val!);
  }

  void contactPositionSetState(String? val) {
    setState(() => _contactPosition = val!);
  }

  void contactChoiceGradeSetState(String? val) {
    setState(() => _contactChoiceGrade = val!);
  }

  void contactKOLSetState(String? val) {
    setState(() => _contactKOL = val!);
  }

  void contactProjectSetState(String? val) {
    setState(() => _contactProject = val!);
  }

  onStepContinue() async {
    if (currentStep == 0 && !_validateAndSaveForm()) {
      return;
    }
    _submit();
  }

  onStepCancel() {
    setState(() {
      EntityDirectoryPage.selectedIndex.value = 2;
    });
  }

  Future<void> _submit() async {
  //   final address = Address(
  //     country: _countryId,
  //     province: _provinceId,
  //     city: _cityId,
  //     place: _place,
  //   );
  //   final newResource = Resource(
  //     resourceId: _resourceId,
  //     title: _resourceTitle!,
  //     description: _resourceDescription!,
  //     resourceType: _resourceTypeId,
  //     resourceCategory: _resourceCategoryId,
  //     interests: _interests,
  //     competencies: _competencies,
  //     duration: _duration!,
  //     temporality: _temporality,
  //     notExpire: _notExpire,
  //     start: _start!,
  //     end: _end!,
  //     maximumDate: _max!,
  //     modality: _modality!,
  //     address: address,
  //     capacity: _capacity,
  //     organizer: _organizer!,
  //     promotor: _organizerText,
  //     link: _link,
  //     contactEmail: _email,
  //     contactPhone: _phone,
  //     contractType: _contractType,
  //     salary: _salary,
  //     degree: _degree,
  //     resourcePictureId: selectedResourcePicture?.id ?? resource.resourcePictureId,
  //     createdate: _createdate!,
  //     resourceLink: _resourceLink,
  //     organizerType: _organizerType,
  //     participants: _participants,
  //     assistants: _assistants,
  //     status: _status,
  //     street: _street,
  //   );
  //   try {
  //     final database = Provider.of<Database>(context, listen: false);
  //     setState(() => isLoading = true);
  //     await database.setResource(newResource);
  //     setState(() => isLoading = false);
  //     showAlertDialog(
  //       context,
  //       title: StringConst.FORM_SUCCESS,
  //       content: StringConst.FORM_SUCCESS_UPDATED,
  //       defaultActionText: StringConst.FORM_ACCEPT,
  //     ).then((value) {
  //       setState(() {
  //         MyResourcesListPage.selectedIndex.value = 2;
  //       });
  //     },
  //     );
  //   } on FirebaseException catch (e) {
  //     showExceptionAlertDialog(context,
  //         title: StringConst.FORM_ERROR, exception: e)
  //         .then((value) {
  //       setState(() {
  //         MyResourcesListPage.selectedIndex.value = 2;
  //       });
  //     });
  //   }
  }
}
