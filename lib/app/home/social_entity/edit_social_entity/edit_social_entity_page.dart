import 'package:cached_network_image/cached_network_image.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:enreda_empresas/app/common_widgets/alert_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/custom_chip.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/enreda_button.dart';
import 'package:enreda_empresas/app/common_widgets/flex_row_column.dart';
import 'package:enreda_empresas/app/common_widgets/show_exception_alert_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/text_form_field.dart';
import 'package:enreda_empresas/app/home/resources/validating_form_controls/stream_builder_province.dart';
import 'package:enreda_empresas/app/home/social_entity/entity_directory_page.dart';
import 'package:enreda_empresas/app/models/addressUser.dart';
import 'package:enreda_empresas/app/models/city.dart';
import 'package:enreda_empresas/app/models/country.dart';
import 'package:enreda_empresas/app/models/socialEntitiesType.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/models/province.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/home/resources/validating_form_controls/stream_builder_city.dart';
import 'package:enreda_empresas/app/home/resources/validating_form_controls/stream_builder_country.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final _formKeyLogo = GlobalKey<FormState>();
  bool isLoading = false;
  int currentStep = 0;
  String? _socialEntityId;
  String? _socialEntityName;
  String? _socialEntityActionScope;
  String? _photo;
  String? _category;
  String? _subCategory;
  String? _geographicZone;
  String? _subGeographicZone;
  String? _website;
  String? _email;
  String? _entityPhone;
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
  String? _signedAgreements;
  String _entityLandlinePhoneCode = '+34';
  String _entityMobilePhoneCode = '+34';
  String _contactLandlinePhoneCode = '+34';
  String _contactMobilePhoneCode = '+34';
  late List<String> _entityTypes;
  String? _countryId;
  String? _provinceId;
  String? _cityId;
  String? _postalCode;
  Country? selectedCountry;
  Province? selectedProvince;
  City? selectedCity;
  bool? _trust;
  List<String> subCategories = ['Financiación', 'Cooperación técnica', 'Posicionamiento y reputación', 'Asociados'];
  List<String> geographicZone = ['Global', 'Regional', 'Local'];
  List<String> choiceGrade = ['Alto', 'Intermedio', 'Bajo'];
  List<String> yesNo = ['Si', 'No'];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    socialEntity = globals.currentSocialEntity!;
    _socialEntityId = globals.currentSocialEntity?.socialEntityId;
    _socialEntityName = globals.currentSocialEntity?.name;
    _socialEntityActionScope = globals.currentSocialEntity?.actionScope;
    _photo = globals.currentSocialEntity?.photo;
    _category = globals.currentSocialEntity?.category ?? '';
    _subCategory = globals.currentSocialEntity?.subCategory ?? '';
    _geographicZone = globals.currentSocialEntity?.geographicZone ?? '';
    _subGeographicZone = globals.currentSocialEntity?.subGeographicZone ?? '';
    _website = globals.currentSocialEntity?.website ?? '';
    _website = globals.currentSocialEntity?.website ?? '';
    _entityPhone = globals.currentSocialEntity?.entityPhone ?? '';
    _entityMobilePhone = globals.currentSocialEntity?.entityMobilePhone ?? '';
    _contactPhone = globals.currentSocialEntity?.contactPhone ?? '';
    _contactMobilePhone = globals.currentSocialEntity?.contactMobilePhone ?? '';
    _entityLandlinePhoneCode = globals.currentSocialEntity?.entityPhone == null || globals.currentSocialEntity?.entityPhone == '' ? '+34' : '${globals.currentSocialEntity?.entityPhone?[0]}${globals.currentSocialEntity?.entityPhone?[1]}${globals.currentSocialEntity?.entityPhone?[2]}';
    _entityMobilePhoneCode = globals.currentSocialEntity?.entityMobilePhone == null || globals.currentSocialEntity?.entityMobilePhone == '' ? '+34' : '${globals.currentSocialEntity?.entityMobilePhone?[0]}${globals.currentSocialEntity?.entityMobilePhone?[1]}${globals.currentSocialEntity?.entityMobilePhone?[2]}';
    _contactLandlinePhoneCode = globals.currentSocialEntity?.contactPhone == null || globals.currentSocialEntity?.contactPhone == '' ? '+34' : '${globals.currentSocialEntity?.contactPhone?[0]}${globals.currentSocialEntity?.contactPhone?[1]}${globals.currentSocialEntity?.contactPhone?[2]}';
    _contactMobilePhoneCode = globals.currentSocialEntity?.contactMobilePhone == null || globals.currentSocialEntity?.contactMobilePhone == ''? '+34' : '${globals.currentSocialEntity?.contactMobilePhone?[0]}${globals.currentSocialEntity?.contactMobilePhone?[1]}${globals.currentSocialEntity?.contactMobilePhone?[2]}';
    _postalCode = globals.currentSocialEntity?.address?.postalCode ?? '';
    _countryId = globals.currentSocialEntity?.address?.country ?? '';
    _provinceId = globals.currentSocialEntity?.address?.province ?? '';
    _cityId = globals.currentSocialEntity?.address?.city ?? '';
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
    _signedAgreements = globals.currentSocialEntity?.signedAgreements ?? '';
    _entityTypes = globals.currentSocialEntity?.types ?? [];
    _trust = globals.currentSocialEntity?.trust ?? false;
  }

  @override
  void dispose() {
    super.dispose();
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
              _buildLogo(context),
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

  Widget _buildLogo(BuildContext context) {
    return Form(
      key: _formKeyLogo,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: InkWell(
            mouseCursor: MaterialStateMouseCursor.clickable,
            onTap: () => !kIsWeb
                ? _displayPickImageDialog()
                : _onImageButtonPressed(ImageSource.gallery),
            child: Container(
              width: 100,
              height: 100,
              color: Colors.transparent,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(120),
                    ),
                    child: !kIsWeb
                        ? ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(60)),
                            child: Center(
                              child: _photo == ""
                                  ? Container(
                                      color: Colors.transparent,
                                      height: 100,
                                      width: 100,
                                      child:
                                          Image.asset(ImagePath.IMAGE_DEFAULT),
                                    )
                                  : CachedNetworkImage(
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      alignment: Alignment.center,
                                      imageUrl: _photo!),
                            ),
                          )
                        : ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(60)),
                            child: Center(
                              child: _photo == ""
                                  ? Container(
                                      color: Colors.transparent,
                                      height: 100,
                                      width: 100,
                                      child:
                                          Image.asset(ImagePath.IMAGE_DEFAULT),
                                    )
                                  : FadeInImage.assetNetwork(
                                      placeholder: ImagePath.IMAGE_DEFAULT,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      image: _photo!,
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
                        border: Border.all(color: AppColors.turquoiseBlue, width: 1.0),
                      ),
                      child: const Icon(
                        Icons.mode_edit_outlined,
                        size: 22,
                        color: AppColors.turquoiseBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: CustomTextBold(title: StringConst.FORM_ENTITY_LABELS,),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: chipContainer(),
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
                _entityPhone!,
                _entityLandlinePhoneCode,
                StringConst.FORM_PHONE,
                StringConst.FORM_COMPANY_ERROR,
                _onCountryChangeEntityLandline,
                _onSavedPhone,
              ),
              childRight: customTextFormPhone(
                context,
                _entityMobilePhone!,
                _entityMobilePhoneCode,
                StringConst.FORM_MOBILE_PHONE,
                StringConst.FORM_COMPANY_ERROR,
                _onChangeMobilePhone,
                _onSavedMobilePhone,
              ),
            ),
            CustomFlexRowColumn(
              childLeft: streamBuilderForCountry(context, selectedCountry,
                  buildCountryStreamBuilderSetState, socialEntity),
              childRight: streamBuilderForProvince(
                  context,
                  selectedCountry == null
                      ? socialEntity.address?.country
                      : selectedCountry?.countryId,
                  selectedProvince,
                  buildProvinceStreamBuilderSetState,
                  socialEntity)),
            CustomFlexRowColumn(
              childLeft: streamBuilderForCity(
                  context,
                  selectedCountry == null
                      ? socialEntity.address?.country
                      : selectedCountry?.countryId,
                  selectedProvince == null
                      ? socialEntity.address?.province
                      : selectedProvince?.provinceId,
                  selectedCity,
                  buildCityStreamBuilderSetState,
                  socialEntity),
              childRight: customTextFormFieldNotValidator(context, _postalCode!,
                  StringConst.FORM_POSTAL_CODE, postalCodeSetState),
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
                _onChangeContactPhoneCode,
                _onSavedContactPhone
              ),
              childRight: customTextFormPhone(
                context,
                _contactMobilePhone!,
                _contactMobilePhoneCode,
                StringConst.FORM_MOBILE_PHONE,
                StringConst.FORM_COMPANY_ERROR,
                _onChangeContactMobileCode,
                _onSavedContactMobilePhone
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
              childLeft: customTextFormField(context, _signedAgreements!,
                  StringConst.FORM_ENTITY_SIGNED_AGREEMENTS, StringConst.FORM_COMPANY_ERROR, contactProjectSetState),
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
  void postalCodeSetState(String? val) {
    setState(() => _postalCode = val!);
  }

  void _onCountryChangeEntityLandline(CountryCode countryCode) {
    _entityLandlinePhoneCode = countryCode.toString();
  }

  void _onSavedPhone(String? value) {
    setState(() {
      this._entityPhone = _entityLandlinePhoneCode + ' ' + value!;
    });
  }
  void _onChangeMobilePhone(CountryCode countryCode) {
    _entityMobilePhoneCode = countryCode.toString();
  }

  void _onSavedMobilePhone(String? value) {
    setState(() {
      this._entityMobilePhone = _entityMobilePhoneCode + ' ' + value!;
    });
  }

  void _onChangeContactPhoneCode(CountryCode countryCode) {
    _contactLandlinePhoneCode = countryCode.toString();
  }
  void _onSavedContactPhone(String? value) {
    setState(() {
      this._contactPhone = _contactLandlinePhoneCode + ' ' + value!;
    });
  }

  void _onChangeContactMobileCode(CountryCode countryCode) {
    _contactMobilePhoneCode = countryCode.toString();
  }
  void _onSavedContactMobilePhone(String? value) {
    setState(() {
      this._contactMobilePhone = _contactMobilePhoneCode + ' ' + value!;
    });
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

  void buildCountryStreamBuilderSetState(Country? country) {
    setState(() {
      selectedProvince = null;
      selectedCity = null;
      selectedCountry = country;
    });
    _countryId = country?.countryId;
  }

  void buildProvinceStreamBuilderSetState(Province? province) {
    setState(() {
      selectedCity = null;
      selectedProvince = province;
    });
    _provinceId = province?.provinceId;
  }

  void buildCityStreamBuilderSetState(City? city) {
    setState(() {
      selectedCity = city;
    });
    _cityId = city?.cityId;
  }

  Future<void> _displayPickImageDialog() async {
    final textTheme = Theme.of(context).textTheme;
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 150,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 24.0),
              child: Row(
                children: <Widget>[
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.camera,
                          color: Colors.indigo,
                          size: 30,
                        ),
                        onPressed: () {
                          _onImageButtonPressed(ImageSource.camera);
                          Navigator.canPop(context);
                        },
                      ),
                      Text(
                        StringConst.FORM_CAMERA,
                        style: textTheme.bodyMedium?.copyWith(fontSize: 12.0),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Column(children: [
                    IconButton(
                        icon: const Icon(
                          Icons.photo,
                          color: Colors.indigo,
                          size: 30,
                        ),
                        onPressed: () {
                          _onImageButtonPressed(ImageSource.gallery);
                          Navigator.canPop(context);
                        }),
                    Text(
                      StringConst.FORM_GALLERY,
                      style: textTheme.bodyMedium?.copyWith(fontSize: 12.0),
                    ),
                  ]),
                ],
              ),
            ),
          );
        });
  }

  Future<void> _onImageButtonPressed(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
      );
      if (pickedFile != null) {
        setState(() async {
          final database = Provider.of<Database>(context, listen: false);
          await database.uploadLogoAvatar(
              _socialEntityId!, await pickedFile.readAsBytes());
        });
      }
    } catch (e) {
      setState(() {
        //_pickImageError = e;
      });
    }
  }

  Widget chipContainer(){
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: AppColors.greyUltraLight,
          )
      ),
      height: Responsive.isMobile(context) ? 350 : Responsive.isDesktopS(context) ? 200 : 150,
      child: Center(child: chipFilter()),
    );
  }

  Widget chipFilter(){
    final database = Provider.of<Database>(context, listen: false);
    List<SocialEntitiesType> socialEntityTypes = [];
    return StreamBuilder<List<SocialEntitiesType>>(
        stream: database.socialEntitiesTypeStream(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) return Container();
          socialEntityTypes.clear();
          snapshot.data!.toList().forEach((element) {
            socialEntityTypes.add(element);
          });
          return ChipsChoice<String>.multiple(
            padding: EdgeInsets.all(5),
            wrapped: true,
            value: _entityTypes,
            onChanged: (val){
              setState(() => _entityTypes = val);
            },
            choiceItems: C2Choice.listFrom<String, SocialEntitiesType>(
              source: socialEntityTypes,
              value: (i, v) => v.id,
              label: (i, v) => v.name,
            ),
            choiceBuilder: (item, i) => CustomChip(
              label: item.label,
              borderRadius: 17.0,
              backgroundColor: AppColors.greyChip,
              selectedBackgroundColor: AppColors.bluePetrol,
              textColor: AppColors.greyLetter,
              selected: item.selected,
              onSelect: item.select!,
            ),
          );
        }
    );
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
    final address = Address(
      country: _countryId,
      province: _provinceId,
      city: _cityId,
      place: _postalCode,
    );
    final editedSocialEntity = SocialEntity(
      socialEntityId: _socialEntityId,
      name: _socialEntityName!,
      actionScope: _socialEntityActionScope,
      category: _category!,
      subCategory: _subCategory,
      geographicZone: _geographicZone!,
      subGeographicZone: _subGeographicZone,
      website: _website,
      linkedin: _linkedin,
      twitter: _twitter,
      otherSocialMedia: _otherSocialMedia,
      contactName: _contactName!,
      contactEmail: _contactEmail!,
      contactPosition: _contactPosition!,
      contactChoiceGrade: _contactChoiceGrade!,
      contactKOL: _contactKOL!,
      contactProject: _contactProject!,
      types: _entityTypes,
      address: address,
      email: _email,
      entityPhone: _entityPhone,
      entityMobilePhone: _entityMobilePhone,
      contactPhone: _contactPhone,
      contactMobilePhone: _contactMobilePhone,
      signedAgreements: _signedAgreements,
      trust: _trust
    );
    try {
      final database = Provider.of<Database>(context, listen: false);
      setState(() => isLoading = true);
      await database.setSocialEntity(editedSocialEntity);
      setState(() => isLoading = false);
      showAlertDialog(
        context,
        title: StringConst.FORM_SUCCESS,
        content: StringConst.FORM_ENTITY_UPDATED,
        defaultActionText: StringConst.FORM_ACCEPT,
      ).then((value) {
        setState(() {
          EntityDirectoryPage.selectedIndex.value = 2;
        });
      },
      );
    } on FirebaseException catch (e) {
      showExceptionAlertDialog(context,
          title: StringConst.FORM_ERROR, exception: e)
          .then((value) {
        setState(() {
          EntityDirectoryPage.selectedIndex.value = 2;
        });
      });
    }
  }
}
