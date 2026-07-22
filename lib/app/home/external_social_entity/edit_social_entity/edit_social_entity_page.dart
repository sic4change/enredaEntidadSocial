import 'package:cached_network_image/cached_network_image.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:enreda_empresas/app/common_widgets/alert_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/custom_chip.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/custom_drop_down_button_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/custom_phone_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/enreda_button.dart';
import 'package:enreda_empresas/app/common_widgets/flex_row_column.dart';
import 'package:enreda_empresas/app/common_widgets/show_exception_alert_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/common_widgets/text_form_field.dart';
import 'package:enreda_empresas/app/home/resources/validating_form_controls/stream_builder_province.dart';
import 'package:enreda_empresas/app/home/external_social_entity/entity_detail/entity_detail_page.dart';
import 'package:enreda_empresas/app/models/addressUser.dart';
import 'package:enreda_empresas/app/models/city.dart';
import 'package:enreda_empresas/app/models/country.dart';
import 'package:enreda_empresas/app/models/socialEntitiesType.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/models/province.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/external_entities_cache.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
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

import '../../../models/externalSocialEntity.dart';
import '../entity_directory_page.dart';
import 'package:enreda_empresas/app/models/interest.dart';
import 'package:enreda_empresas/app/models/scope_action.dart';
import 'package:enreda_empresas/app/home/resources/validating_form_controls/stream_builder_interests_create.dart';
import 'package:enreda_empresas/app/home/resources/validating_form_controls/stream_builder_scope_action_create.dart';
import 'package:enreda_empresas/app/sign_up/validating_form_controls/multi_select_button.dart';

const double contactBtnWidthLg = 200.0;
const double contactBtnWidthSm = 100.0;
const double contactBtnWidthMd = 140.0;

class EditSocialEntity extends StatefulWidget {
  EditSocialEntity({Key? key, required this.socialEntityId}) : super(key: key);
  final String? socialEntityId;

  @override
  State<EditSocialEntity> createState() => _EditSocialEntityState();
}

class _EditSocialEntityState extends State<EditSocialEntity> {
  late ExternalSocialEntity externalSocialEntity;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  int currentStep = 0;
  late String _externalSocialEntityId;
  String? _socialEntityName;
  List<String> _socialEntityActionScope = [];
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
  String? _offeredServices;
  String? _kolType;
  bool _trust = false;
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
  List<String> subCategories = [
    'Financiación',
    'Cooperación técnica',
    'Posicionamiento y reputación',
    'Asociados'
  ];
  List<String> geographicZone = ['Global', 'Regional', 'Local'];
  List<String> choiceGrade = ['Alto', 'Intermedio', 'Bajo'];
  List<String> yesNo = ['Si', 'No'];
  List<String> kolTypes = [
    'Financiación',
    'Cooperación Técnica',
    'Posicionamiento y Reputación',
    'Asociados'
  ];
  final ImagePicker _imagePicker = ImagePicker();
  DateTime? _createdAt;
  String? _createdBy;

  TextEditingController textEditingControllerActionScope =
      TextEditingController();
  List<TextEditingController> _phoneControllers = [];
  // Each reference person = one name controller + one phone controller.
  List<(TextEditingController, TextEditingController)> _referenceControllers = [];
  Set<Interest> selectedInterests = {};
  Set<ScopeAction> selectedScopeActions = {};
  late TextTheme textTheme;

  @override
  void initState() {
    super.initState();
    externalSocialEntity = globals.currentExternalSocialEntity!;
    _externalSocialEntityId =
        globals.currentExternalSocialEntity?.externalSocialEntityId ?? '';
    _socialEntityName = globals.currentExternalSocialEntity?.name;
    _socialEntityActionScope =
        globals.currentExternalSocialEntity?.actionScope ?? [];
    _category = globals.currentExternalSocialEntity?.category ?? '';
    _subCategory = globals.currentExternalSocialEntity?.subCategory ?? '';
    _geographicZone = globals.currentExternalSocialEntity?.geographicZone ?? '';
    _subGeographicZone =
        globals.currentExternalSocialEntity?.subGeographicZone ?? '';
    _website = globals.currentExternalSocialEntity?.website ?? '';
    _entityPhone = globals.currentExternalSocialEntity?.entityPhone ?? '';
    _entityMobilePhone =
        globals.currentExternalSocialEntity?.entityMobilePhone ?? '';
    _contactPhone = globals.currentExternalSocialEntity?.contactPhone ?? '';
    _contactMobilePhone =
        globals.currentExternalSocialEntity?.contactMobilePhone ?? '';
    _entityLandlinePhoneCode = globals
                    .currentExternalSocialEntity?.entityPhone ==
                null ||
            globals.currentExternalSocialEntity?.entityPhone == ''
        ? '+34'
        : '${globals.currentExternalSocialEntity?.entityPhone?[0]}${globals.currentExternalSocialEntity?.entityPhone?[1]}${globals.currentExternalSocialEntity?.entityPhone?[2]}';
    _entityMobilePhoneCode = globals
                    .currentExternalSocialEntity?.entityMobilePhone ==
                null ||
            globals.currentExternalSocialEntity?.entityMobilePhone == ''
        ? '+34'
        : '${globals.currentExternalSocialEntity?.entityMobilePhone?[0]}${globals.currentExternalSocialEntity?.entityMobilePhone?[1]}${globals.currentExternalSocialEntity?.entityMobilePhone?[2]}';
    _contactLandlinePhoneCode = globals
                    .currentExternalSocialEntity?.contactPhone ==
                null ||
            globals.currentExternalSocialEntity?.contactPhone == ''
        ? '+34'
        : '${globals.currentExternalSocialEntity?.contactPhone?[0]}${globals.currentExternalSocialEntity?.contactPhone?[1]}${globals.currentExternalSocialEntity?.contactPhone?[2]}';
    _contactMobilePhoneCode = globals
                    .currentExternalSocialEntity?.contactMobilePhone ==
                null ||
            globals.currentExternalSocialEntity?.contactMobilePhone == ''
        ? '+34'
        : '${globals.currentExternalSocialEntity?.contactMobilePhone?[0]}${globals.currentExternalSocialEntity?.contactMobilePhone?[1]}${globals.currentExternalSocialEntity?.contactMobilePhone?[2]}';
    _postalCode =
        globals.currentExternalSocialEntity?.address?.postalCode ?? '';
    _countryId = globals.currentExternalSocialEntity?.address?.country ?? '';
    _provinceId = globals.currentExternalSocialEntity?.address?.province ?? '';
    _cityId = globals.currentExternalSocialEntity?.address?.city ?? '';
    _email = globals.currentExternalSocialEntity?.email ?? '';
    _linkedin = globals.currentExternalSocialEntity?.linkedin ?? '';
    _twitter = globals.currentExternalSocialEntity?.twitter ?? '';
    _otherSocialMedia =
        globals.currentExternalSocialEntity?.otherSocialMedia ?? '';
    _contactName = globals.currentExternalSocialEntity?.contactName ?? '';
    _contactEmail = globals.currentExternalSocialEntity?.contactEmail ?? '';
    _contactPosition =
        globals.currentExternalSocialEntity?.contactPosition ?? '';
    _contactChoiceGrade =
        globals.currentExternalSocialEntity?.contactChoiceGrade ?? '';
    _contactKOL = globals.currentExternalSocialEntity?.contactKOL ?? '';
    _contactProject = globals.currentExternalSocialEntity?.contactProject ?? '';
    _signedAgreements =
        globals.currentExternalSocialEntity?.signedAgreements ?? '';
    _offeredServices =
        globals.currentExternalSocialEntity?.offeredServices ?? '';
    _kolType = globals.currentExternalSocialEntity?.kolType ?? '';
    _entityTypes = globals.currentExternalSocialEntity?.types ?? [];
    _phoneControllers = (globals.currentExternalSocialEntity?.phones ?? [])
        .map((p) => TextEditingController(text: p))
        .toList();
    _referenceControllers =
        (globals.currentExternalSocialEntity?.referencePeople ?? [])
            .map((r) => (
                  TextEditingController(text: r.name),
                  TextEditingController(text: r.phone),
                ))
            .toList();
    _trust = globals.currentExternalSocialEntity?.trust ?? false;
    _createdAt =
        globals.currentExternalSocialEntity?.createdAt ?? DateTime.now();
    _createdBy = globals.currentExternalSocialEntity?.createdBy ?? '';

    _initActionScope();
  }

  void _initActionScope() {
    if (_socialEntityActionScope.isEmpty) {
      textEditingControllerActionScope.text = '';
      return;
    }
    if (_category == 'Empresas /Asociaciones empresariales/Clúster') {
      selectedInterests = _socialEntityActionScope.map((id) {
        try {
          return LocationCache.instance.interests
              .firstWhere((e) => e.interestId == id);
        } catch (_) {
          return Interest(interestId: id, name: '');
        }
      }).toSet();
      textEditingControllerActionScope.text =
          selectedInterests.map((e) => e.name).join(', ');
    } else {
      selectedScopeActions = _socialEntityActionScope.map((id) {
        try {
          return LocationCache.instance.scopeActions
              .firstWhere((e) => e.id == id);
        } catch (_) {
          return ScopeAction(id: id, name: '');
        }
      }).toSet();
      textEditingControllerActionScope.text =
          selectedScopeActions.map((e) => e.name).join(', ');
    }
  }

  @override
  void dispose() {
    for (final c in _phoneControllers) {
      c.dispose();
    }
    for (final r in _referenceControllers) {
      r.$1.dispose();
      r.$2.dispose();
    }
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
    textTheme = Theme.of(context).textTheme;
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    double contactBtnWidth = responsiveSize(
      context,
      contactBtnWidthSm,
      contactBtnWidthLg,
      md: contactBtnWidthMd,
    );
    final database = Provider.of<Database>(context, listen: false);
    return Center(
      child: Container(
        height: Responsive.isMobile(context) || Responsive.isTablet(context)
            ? MediaQuery.of(context).size.height
            : MediaQuery.of(context).size.height * 0.80,
        width: Responsive.isMobile(context) || Responsive.isTablet(context)
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.width * 0.80,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(Sizes.kDefaultPaddingDouble / 2),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<ExternalSocialEntity>(
                  stream: database
                      .externalSocialEntityByIdStream(_externalSocialEntityId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final photoUrl = snapshot.data!.photo;
                    return _buildLogo(context, photoUrl!);
                  }),
              _buildForm(context),
              Container(
                height: Sizes.kDefaultPaddingDouble * 2,
                margin:
                    const EdgeInsets.only(top: Sizes.kDefaultPaddingDouble * 2),
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

  Widget _buildLogo(BuildContext context, String photoUrl) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: InkWell(
          mouseCursor: WidgetStateMouseCursor.clickable,
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
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary020,
                      )),
                  child: !kIsWeb
                      ? ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(60)),
                          child: Center(
                            child: photoUrl == ""
                                ? Container(
                                    color: Colors.transparent,
                                    height: 100,
                                    width: 100,
                                    child: Image.asset(ImagePath.IMAGE_DEFAULT),
                                  )
                                : CachedNetworkImage(
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
                                    imageUrl: photoUrl),
                          ),
                        )
                      : ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(60)),
                          child: Center(
                            child: photoUrl == ""
                                ? Container(
                                    color: Colors.transparent,
                                    height: 100,
                                    width: 100,
                                    child: Image.asset(ImagePath.IMAGE_DEFAULT),
                                  )
                                : FadeInImage.assetNetwork(
                                    placeholder: ImagePath.IMAGE_DEFAULT,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    image: photoUrl,
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
                      border: Border.all(
                          color: AppColors.turquoiseBlue, width: 1.0),
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
    ]);
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: CustomTextFormFieldTitle(
                  initialValue: _socialEntityName!,
                  labelText: StringConst.FORM_NAME_ENTITY,
                  validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_COMPANY_ERROR,
                  onChanged: nameSetState),
              childRight: CustomTextFormFieldTitle(
                controller: textEditingControllerActionScope,
                labelText: 'Ámbito de actuación',
                onTap: () {
                  if (_category == 'Empresas /Asociaciones empresariales/Clúster') {
                    _showMultiSelectActionScopeInterests(context);
                  } else {
                    // Mirrors _initActionScope: any other category (including
                    // CSV-imported ones like 'Tercer Sector') uses scope actions.
                    _showMultiSelectActionScope(context);
                  }
                },
                readOnly: true,
                validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
              ),
            ),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: CustomDropDownButtonFormFieldTittle(
                value: _category == '' ? null : _category,
                labelText: StringConst.CATEGORY,
                source: buildDropdownMenuItems([
                  'Organizaciones sociales',
                  'Administración pública',
                  'Empresas /Asociaciones empresariales/Clúster'
                ], _category),
                onChanged: (val) {
                  categorySetState(val);
                  setState(() {
                    _socialEntityActionScope = [];
                    textEditingControllerActionScope.text = '';
                    selectedScopeActions.clear();
                    selectedInterests.clear();
                  });
                },
              ),
              childRight: CustomDropDownButtonFormFieldTittle(
                value: _subCategory == '' ? null : _subCategory,
                labelText: StringConst.SUB_CATEGORY,
                source: buildDropdownMenuItems(subCategories, _subCategory),
                onChanged: subCategorySetState,
              ),
            ),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: CustomTextFormFieldTitle(
                initialValue: _signedAgreements!,
                labelText: StringConst.FORM_ENTITY_SIGNED_AGREEMENTS,
                onChanged: signedAgreementsSetState,
              ),
              childRight: CustomTextFormFieldTitle(
                initialValue: _offeredServices!,
                labelText: '¿Qué iniciativas o servicios ofrece?',
                onChanged: offeredServicesSetState,
              ),
            ),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: CustomDropDownButtonFormFieldTittle(
                value: _contactChoiceGrade == '' ? null : _contactChoiceGrade,
                labelText: StringConst.CONTACT_CHOICE_GRADE,
                source: buildDropdownMenuItems(choiceGrade, _contactChoiceGrade),
                onChanged: contactChoiceGradeSetState,
              ),
              childRight: CustomDropDownButtonFormFieldTittle(
                value: _contactKOL == '' ? null : _contactKOL,
                labelText: StringConst.CONTACT_OPINION_LEADER,
                source: buildDropdownMenuItems(yesNo, _contactKOL),
                onChanged: (val) {
                  contactKOLSetState(val);
                  setState(() {
                    if (_contactKOL != 'Si') {
                      _kolType = '';
                    }
                  });
                },
              ),
            ),
            if (_contactKOL == 'Si') ...[
              CustomDropDownButtonFormFieldTittle(
                value: _kolType == '' ? null : _kolType,
                labelText: 'Tipo de KOL',
                source: buildDropdownMenuItems(kolTypes, _kolType),
                onChanged: kolTypeSetState,
              ),
            ],
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: CustomDropDownButtonFormFieldTittle(
                value: _geographicZone == '' ? null : _geographicZone,
                labelText: StringConst.ZONE,
                source: buildDropdownMenuItems(geographicZone, _geographicZone),
                onChanged: geographicZoneSetState,
              ),
              childRight: CustomTextFormFieldTitle(
                initialValue: _subGeographicZone!,
                labelText: StringConst.SUB_ZONE,
                onChanged: subGeographicZoneSetState,
              ),
            ),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: CustomTextFormFieldTitle(
                initialValue: _website!,
                labelText: StringConst.FORM_WEBSITE,
                onChanged: websiteSetState,
              ),
              childRight: CustomTextFormFieldTitle(
                initialValue: _email!,
                labelText: StringConst.EMAIL,
                onChanged: emailSetState,
                validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_COMPANY_ERROR,
              ),
            ),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: CustomPhoneFormFieldTitle(
                initialValue: _entityPhone!,
                initialSelection: _entityLandlinePhoneCode == '' ? 'ES' : _entityLandlinePhoneCode,
                phoneCode: _entityLandlinePhoneCode,
                labelText: 'Teléfono fijo de la organización',
                onCountryChange: _onCountryChangeEntityLandline,
                onSaved: _onSavedPhone,
              ),
              childRight: CustomPhoneFormFieldTitle(
                initialValue: _entityMobilePhone!,
                initialSelection: _entityMobilePhoneCode == '' ? 'ES' : _entityMobilePhoneCode,
                phoneCode: _entityMobilePhoneCode,
                labelText: StringConst.FORM_MOBILE_PHONE,
                onCountryChange: _onChangeMobilePhone,
                onSaved: _onSavedMobilePhone,
              ),
            ),
            SpaceH24(),
            _buildPhonesSection(),
            SpaceH24(),
            _buildReferencePeopleSection(),
            SpaceH24(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: CustomTextFormFieldTitle(
                initialValue: _linkedin!,
                labelText: StringConst.FORM_LINKEDIN,
                onChanged: linkedinSetState,
              ),
              childRight: CustomTextFormFieldTitle(
                initialValue: _twitter!,
                labelText: 'X',
                onChanged: twitterSetState,
              ),
            ),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: CustomTextFormFieldTitle(
                initialValue: _otherSocialMedia!,
                labelText: StringConst.FORM_OTHER_SOCIAL_MEDIA,
                onChanged: otherSocialMediaSetState,
              ),
              childRight: Container(),
            ),
            SizedBox(
              height: 20.0,
            ),
            CustomTextMediumBold(
              text: StringConst.CONTACT_INFORMATION.toUpperCase(),
            ),
            SpaceH24(),
            CustomTextFormFieldTitle(
              initialValue: _contactName!,
              labelText: StringConst.FORM_CONTACT_TEC_NAME,
              onChanged: contactNameSetState,
              validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_COMPANY_ERROR,
            ),
            SpaceH24(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: CustomPhoneFormFieldTitle(
                initialValue: _contactPhone!,
                initialSelection: _contactLandlinePhoneCode == '' ? 'ES' : _contactLandlinePhoneCode,
                phoneCode: _contactLandlinePhoneCode,
                labelText: StringConst.FORM_LANDLINE,
                onCountryChange: _onChangeContactPhoneCode,
                onSaved: _onSavedContactPhone,
              ),
              childRight: CustomPhoneFormFieldTitle(
                initialValue: _contactMobilePhone!,
                initialSelection: _contactMobilePhoneCode == '' ? 'ES' : _contactMobilePhoneCode,
                phoneCode: _contactMobilePhoneCode,
                labelText: StringConst.FORM_MOBILE_PHONE,
                onCountryChange: _onChangeContactMobileCode,
                onSaved: _onSavedContactMobilePhone,
              ),
            ),
            SpaceH24(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: CustomTextFormFieldTitle(
                initialValue: _contactEmail!,
                labelText: StringConst.FORM_EMAIL,
                onChanged: contactEmailSetState,
                validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_COMPANY_ERROR,
              ),
              childRight: CustomTextFormFieldTitle(
                initialValue: _contactPosition!,
                labelText: StringConst.FORM_CONTACT_POSITION,
                onChanged: contactPositionSetState,
                validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_COMPANY_ERROR,
              ),
            ),
          ]),
    );
  }

  /// Default country prefix is Spain (+34). Kept as-is if the user typed their
  /// own '+' prefix. Idempotent: a saved '+34 6...' already starts with '+'.
  String _withDefaultPrefix(String raw) {
    final t = raw.trim();
    return t.startsWith('+') ? t : '+34 $t';
  }

  Widget _buildReferencePeopleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextMediumBold(text: StringConst.REFERENCE_PEOPLE),
        SpaceH12(),
        for (int i = 0; i < _referenceControllers.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: CustomTextFormFieldTitle(
                    controller: _referenceControllers[i].$1,
                    labelText: StringConst.REFERENCE_PERSON_NAME,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextFormFieldTitle(
                    controller: _referenceControllers[i].$2,
                    labelText: StringConst.FORM_PHONE,
                    keyboardType: TextInputType.phone,
                  ),
                ),
                IconButton(
                  tooltip: StringConst.DELETE,
                  onPressed: () => setState(() {
                    final removed = _referenceControllers.removeAt(i);
                    removed.$1.dispose();
                    removed.$2.dispose();
                  }),
                  icon: const Icon(Icons.remove_circle_outline,
                      color: AppColors.turquoiseBlue),
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() {
              _referenceControllers
                  .add((TextEditingController(), TextEditingController()));
            }),
            icon: const Icon(Icons.add_circle_outline,
                color: AppColors.turquoiseBlue),
            label: CustomTextMedium(text: StringConst.ADD_REFERENCE_PERSON),
          ),
        ),
      ],
    );
  }

  Widget _buildPhonesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextMediumBold(text: StringConst.ADDITIONAL_PHONES),
        SpaceH12(),
        for (int i = 0; i < _phoneControllers.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextFormFieldTitle(
                    controller: _phoneControllers[i],
                    labelText: '${StringConst.FORM_PHONE} ${i + 1}',
                    keyboardType: TextInputType.phone,
                  ),
                ),
                IconButton(
                  tooltip: StringConst.DELETE,
                  onPressed: () => setState(() {
                    _phoneControllers.removeAt(i).dispose();
                  }),
                  icon: const Icon(Icons.remove_circle_outline,
                      color: AppColors.turquoiseBlue),
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() {
              _phoneControllers.add(TextEditingController());
            }),
            icon: const Icon(Icons.add_circle_outline,
                color: AppColors.turquoiseBlue),
            label: CustomTextMedium(text: StringConst.ADD_PHONE),
          ),
        ),
      ],
    );
  }

  void nameSetState(String? val) {
    setState(() => _socialEntityName = val!);
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

  void offeredServicesSetState(String? val) {
    setState(() => _offeredServices = val!);
  }

  void kolTypeSetState(String? val) {
    setState(() => _kolType = val!);
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
    setState(() {
      _contactKOL = val!;
      if (_contactKOL != 'Si') {
        _kolType = '';
      }
    });
  }

  void contactProjectSetState(String? val) {
    setState(() => _contactProject = val!);
  }

  void signedAgreementsSetState(String? val) {
    setState(() => _signedAgreements = val!);
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
              _externalSocialEntityId, await pickedFile.readAsBytes());
        });
      }
    } catch (e) {
      setState(() {
        //_pickImageError = e;
      });
    }
  }

  Widget chipContainer() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: AppColors.greyUltraLight,
          )),
      height: Responsive.isMobile(context)
          ? 350
          : Responsive.isDesktopS(context)
              ? 200
              : 150,
      child: Center(child: chipFilter()),
    );
  }

  Widget chipFilter() {
    final socialEntityTypes = LocationCache.instance.socialEntitiesTypes;

    if (socialEntityTypes.isEmpty) {
      // Fallback if not warmed up
      final database = Provider.of<Database>(context, listen: false);
      return StreamBuilder<List<SocialEntitiesType>>(
          stream: database.socialEntitiesTypeStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Container();
            return _buildChipsChoice(snapshot.data!);
          });
    }

    return _buildChipsChoice(socialEntityTypes);
  }

  Widget _buildChipsChoice(List<SocialEntitiesType> types) {
    return ChipsChoice<String>.multiple(
      padding: EdgeInsets.all(5),
      wrapped: true,
      value: _entityTypes,
      onChanged: (val) {
        setState(() => _entityTypes = val);
      },
      choiceItems: C2Choice.listFrom<String, SocialEntitiesType>(
        source: types,
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

  void _showMultiSelectActionScope(BuildContext context) async {
    final selectedValues = await showDialog<Set<ScopeAction>>(
      context: context,
      builder: (BuildContext context) {
        return streamBuilderDropdownScopeActionCreate(
            context, selectedScopeActions);
      },
    );
    if (selectedValues != null) {
      setState(() {
        selectedScopeActions = selectedValues;
        _socialEntityActionScope =
            selectedValues.map((e) => e.id ?? '').toList();
        textEditingControllerActionScope.text =
            selectedValues.map((e) => e.name).join(', ');
      });
    }
  }

  void _showMultiSelectActionScopeInterests(BuildContext context) async {
    final selectedValues = await showDialog<Set<Interest>>(
      context: context,
      builder: (BuildContext context) {
        return streamBuilderDropdownInterestsCreate(context, selectedInterests);
      },
    );
    if (selectedValues != null) {
      setState(() {
        selectedInterests = selectedValues;
        _socialEntityActionScope =
            selectedValues.map((e) => e.interestId ?? '').toList();
        textEditingControllerActionScope.text =
            selectedValues.map((e) => e.name).join(', ');
      });
    }
  }

  Future<void> _submit() async {
    final address = Address(
      country: _countryId,
      province: _provinceId,
      city: _cityId,
      place: _postalCode,
    );
    final externalSocialEntity = ExternalSocialEntity(
      externalSocialEntityId: _externalSocialEntityId,
      associatedSocialEntityId: widget.socialEntityId!,
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
      phones: _phoneControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .map(_withDefaultPrefix)
          .toList(),
      referencePeople: _referenceControllers
          .map((r) => ReferencePerson(
                name: r.$1.text.trim(),
                phone: r.$2.text.trim().isEmpty
                    ? ''
                    : _withDefaultPrefix(r.$2.text.trim()),
              ))
          .where((p) => p.name.isNotEmpty || p.phone.isNotEmpty)
          .toList(),
      signedAgreements: _signedAgreements,
      offeredServices: _offeredServices,
      kolType: _kolType,
      trust: _trust,
      createdAt: _createdAt!,
      createdBy: _createdBy!,
    );
    try {
      final database = Provider.of<Database>(context, listen: false);
      setState(() => isLoading = true);
      await database.setExternalSocialEntity(externalSocialEntity);
      ExternalEntitiesCache.instance.invalidate();
      setState(() => isLoading = false);
      showAlertDialog(
        context,
        title: StringConst.FORM_SUCCESS,
        content: StringConst.FORM_ENTITY_UPDATED,
        defaultActionText: StringConst.FORM_ACCEPT,
      ).then(
        (value) {
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

  List<DropdownMenuItem<String>> buildDropdownMenuItems(List<String> listItems,
      [String? currentValue]) {
    // CSV-imported contacts can hold values outside the fixed lists (e.g.
    // 'Tercer Sector'); include them so DropdownButton's value is always valid.
    if (currentValue != null &&
        currentValue.isNotEmpty &&
        !listItems.contains(currentValue)) {
      listItems = [currentValue, ...listItems];
    }
    List<DropdownMenuItem<String>> items = [];
    for (String listItem in listItems) {
      items.add(
        DropdownMenuItem(
          value: listItem,
          child: Text(listItem),
        ),
      );
    }
    return items;
  }
}

