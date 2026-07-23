import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enreda_empresas/app/common_widgets/alert_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/custom_chip.dart';
import 'package:enreda_empresas/app/common_widgets/custom_drop_down_button_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/custom_phone_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/enreda_button.dart';
import 'package:enreda_empresas/app/common_widgets/flex_row_column.dart';
import 'package:enreda_empresas/app/common_widgets/show_exception_alert_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/common_widgets/text_form_field.dart';
import 'package:enreda_empresas/app/home/web_home.dart';
import 'package:enreda_empresas/app/models/addressUser.dart';
import 'package:enreda_empresas/app/models/city.dart';
import 'package:enreda_empresas/app/models/country.dart';
import 'package:enreda_empresas/app/models/externalSocialEntity.dart';
import 'package:enreda_empresas/app/models/province.dart';
import 'package:enreda_empresas/app/models/socialEntitiesType.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/external_entities_cache.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/sign_up/validating_form_controls/stream_builder_city.dart';
import 'package:enreda_empresas/app/sign_up/validating_form_controls/stream_builder_country.dart';
import 'package:enreda_empresas/app/sign_up/validating_form_controls/stream_builder_province.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../common_widgets/custom_drop_down.dart';
import '../../../services/auth.dart';
import '../entity_directory_page.dart';
import 'package:enreda_empresas/app/models/interest.dart';
import 'package:enreda_empresas/app/models/scope_action.dart';
import 'package:enreda_empresas/app/home/resources/validating_form_controls/stream_builder_interests_create.dart';
import 'package:enreda_empresas/app/home/resources/validating_form_controls/stream_builder_scope_action_create.dart';
import 'package:enreda_empresas/app/sign_up/validating_form_controls/multi_select_button.dart';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../widgets/signed_agreement_dialog.dart';

class CreateExternalSocialEntityPage extends StatefulWidget {
  const CreateExternalSocialEntityPage({Key? key, required this.socialEntityId}) : super(key: key);
  final String? socialEntityId;

  @override
  _CreateExternalSocialEntityPageState createState() => _CreateExternalSocialEntityPageState();
}

class _CreateExternalSocialEntityPageState extends State<CreateExternalSocialEntityPage> {
  final _formKey = GlobalKey<FormState>();

  String? _entityName;
  List<String> _actionScope = [];
  late List<String> _entityTypes;
  String? _category, _subCategory;
  String? _entityPhone, _entityMobilePhone, _contactPhone, _contactMobilePhone;
  String? _geographicZone, _subGeographicZone;
  String? _url;
  String? _email, _linkedin, _twitter, _otherSocialMedia;
  String? _contactName, _contactEmail, _contactPosition, _contactChoiceGrade, _contactKOL, _contactProject, _signedAgreements;
  Uint8List? _signedAgreementBytes;
  String? _signedAgreementFileName;
  DateTime? _signedAgreementsDate;
  String? _offeredServices, _kolType;
  Country? selectedCountry;
  Province? selectedProvince;
  City? selectedCity;
  String? _countryId;
  String? _provinceId;
  String? _cityId;
  String? _postalCode;
  late String countryName;
  late String provinceName;
  late String cityName;
  String? createdBy;

  TextEditingController textEditingControllerActionScope = TextEditingController();
  Set<Interest> selectedInterests = {};
  Set<ScopeAction> selectedScopeActions = {};

  //Country codes for phone numbers
  String entityPhoneCode = '+34';
  String entityMobilePhoneCode = '+34';
  String contactDeskPhoneCode = '+34';
  String contactMobilePhoneCode = '+34';


  List<DropdownMenuItem<String>> categories = ['Organizaciones sociales', 'Administración pública', 'Empresas /Asociaciones empresariales/Clúster'].map<DropdownMenuItem<String>>((String value){
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList();

  List<DropdownMenuItem<String>> subCategories = ['Financiación', 'Cooperación técnica', 'Posicionamiento y reputación', 'Asociados'].map<DropdownMenuItem<String>>((String value){
    return DropdownMenuItem<String>(
    value: value,
    child: Text(value),
    );
    }).toList();

  List<DropdownMenuItem<String>> geographicZone = ['Global', 'Regional', 'Local'].map<DropdownMenuItem<String>>((String value){
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList();

  List<DropdownMenuItem<String>> choiceGrade = ['Alto', 'Intermedio', 'Bajo'].map<DropdownMenuItem<String>>((String value){
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList();

  List<DropdownMenuItem<String>> yesNo = ['Si', 'No'].map<DropdownMenuItem<String>>((String value){
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList();

  List<DropdownMenuItem<String>> kolTypes = ['Financiación', 'Cooperación Técnica', 'Posicionamiento y Reputación', 'Asociados'].map<DropdownMenuItem<String>>((String value){
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList();

  late TextTheme textTheme;

  @override
  void initState() {
    super.initState();
    _entityName = '';
    _actionScope = [];
    _entityTypes = [];
    _category = '';
    _subCategory = '';
    _entityPhone = '';
    _entityMobilePhone = '';
    _contactMobilePhone = '';
    _contactPhone = '';
    _geographicZone = '';
    _subGeographicZone = '';
    _url = '';
    _email = '';
    _linkedin = '';
    _twitter = '';
    _otherSocialMedia = '';
    _contactName = '';
    _contactEmail = '';
    _contactPosition = '';
    _contactChoiceGrade = '';
    _contactKOL = '';
    _contactProject = '';
    _signedAgreements = '';
    _offeredServices = '';
    _kolType = '';
    _countryId = null;
    _provinceId = null;
    _cityId = null;
    countryName = "";
    provinceName = "";
    cityName = "";
    _postalCode = "";
  }

  @override
  Widget build(BuildContext context) {
    textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      controller: ScrollController(),
      scrollDirection: Axis.vertical,
      child: Container(
        width: Responsive.isMobile(context) ||
            Responsive.isTablet(context)
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.width * 0.80,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return _buildCompleteForm(context);
            }
          ),
        ],),
      ),
    );
  }

  Widget _buildCompleteForm(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Sizes.MARGIN_20),
          child: Text(
            'Datos de la entidad externa',
            style: textTheme.titleMedium!.copyWith(
              color: AppColors.turquoiseBlue,
              fontWeight: FontWeight.w300,
              // Fix the bug with Google Fonts that doesn't allow change the fontWeight with copyWith method
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
          ),
        ),
        _buildForm(context),
        SpaceH50(),
        Center(
          child: EnredaButton(
            buttonTitle: 'Guardar',
            buttonColor: AppColors.turquoise,
            titleColor: Colors.white,
            height: 50.0,
            width: 160,
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
            onPressed: _submit,
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final database = Provider.of<Database>(context, listen: false);
    final auth = Provider.of<AuthBase>(context, listen: false);
    if (_validateAndSaveForm() == false) {
      await showAlertDialog(context,
          title: StringConst.FORM_ENTITY_ERROR,
          content: StringConst.FORM_ENTITY_CHECK,
          defaultActionText: StringConst.CLOSE);
    }

    if (_validateAndSaveForm()) {

      _formKey.currentState!.save();

      final address = Address(
        city: _cityId,
        country: _countryId,
        province: _provinceId,
        postalCode: _postalCode,
      );

      String? agreementUrl = _signedAgreements;
      String? newEntityId;

      if (_signedAgreementBytes != null) {
        newEntityId = FirebaseFirestore.instance.collection('externalSocialEntities').doc().id;
        agreementUrl = await database.uploadSignedAgreement(newEntityId, _signedAgreementBytes!);
      }

      ExternalSocialEntity externalSocialEntity = ExternalSocialEntity(
          externalSocialEntityId: newEntityId,
          associatedSocialEntityId: widget.socialEntityId!,
          createdBy: auth.currentUser!.uid,
          name: _entityName!,
          actionScope: _actionScope,
          types: _entityTypes,
          category: _category,
          subCategory: _subCategory,
          entityPhone: _entityPhone,
          entityMobilePhone: _entityMobilePhone,
          geographicZone: _geographicZone,
          subGeographicZone: _subGeographicZone,
          website: _url,
          email: _email,
          linkedin: _linkedin,
          twitter: _twitter,
          otherSocialMedia: _otherSocialMedia,
          contactName: _contactName,
          contactEmail: _contactEmail,
          contactPhone: _contactPhone,
          contactMobilePhone: _contactMobilePhone,
          contactPosition: _contactPosition,
          contactChoiceGrade: _contactChoiceGrade,
          contactKOL: _contactKOL,
          contactProject: _contactProject,
          signedAgreements: agreementUrl,
          signedAgreementsDate: _signedAgreementsDate,
          offeredServices: _offeredServices,
          kolType: _kolType,
          trust: true, //TODO asignarlo de otra forma
          address: address,
          createdAt: DateTime.now(),
      );

      try {
        if (newEntityId != null) {
          await database.setExternalSocialEntity(externalSocialEntity);
        } else {
          await database.addExternalSocialEntity(externalSocialEntity);
        }
        ExternalEntitiesCache.instance.invalidate();
        await showAlertDialog(
          context,
          title: StringConst.CREATE_ENTITY,
          content: StringConst.CREATE_PARTICIPANT_SUCCESS,
          defaultActionText: StringConst.FORM_ACCEPT,
        );
        EntityDirectoryPage.selectedIndex.value = 0;
      } on FirebaseException catch (e) {
        showExceptionAlertDialog(context,
            title: StringConst.FORM_ERROR, exception: e).then((value) => Navigator.pop(context));
      }

    }
  }

  bool _validateAndSaveForm() {
    if (_formKey.currentState != null &&
        _formKey.currentState!.validate()) {
        _formKey.currentState?.save();
      return true;
    }
    return false;
  }

  Widget _buildForm(BuildContext context){
    double fontSize = responsiveSize(context, 14, 16, md: 15);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextFormFieldTitle(
            labelText: 'Nombre de la entidad externa',
            onChanged: (value){
              setState(() {
                _entityName = value;
              });
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
          SpaceH24(),
          CustomDropDownButtonFormFieldTittle(
            labelText: 'Categoria',
            source: categories,
            onChanged: (value){
              setState(() {
                _category = value;
                _actionScope = [];
                textEditingControllerActionScope.text = '';
                selectedScopeActions.clear();
                selectedInterests.clear();
              });
            },
            validator: (value) => value != null ? null : StringConst.FORM_GENERIC_ERROR,
          ),
          SpaceH24(),
          CustomTextFormFieldTitle(
            controller: textEditingControllerActionScope,
            labelText: 'Ámbito de actuación',
            onTap: () {
              if (_category == 'Empresas /Asociaciones empresariales/Clúster') {
                _showMultiSelectActionScopeInterests(context);
              } else if (_category == 'Organizaciones sociales' || _category == 'Administración pública') {
                _showMultiSelectActionScope(context);
              }
            },
            readOnly: true,
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
          SpaceH24(),
          CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Acuerdos firmados',
                    style: textTheme.bodySmall?.copyWith(
                      height: 1.5,
                      color: AppColors.greyDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final result = await SignedAgreementDialog.show(
                        context: context,
                        currentDate: _signedAgreementsDate,
                      );
                      if (result != null) {
                        setState(() {
                          if (result.isDeleted) {
                            _signedAgreementBytes = null;
                            _signedAgreementFileName = null;
                            _signedAgreementsDate = null;
                            _signedAgreements = null;
                          } else {
                            _signedAgreementBytes = result.fileBytes;
                            _signedAgreementFileName = result.fileName;
                            _signedAgreementsDate = result.renovationDate;
                          }
                        });
                      }
                    },
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(color: AppColors.greyUltraLight, width: 1.0),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _signedAgreementBytes != null ? Icons.picture_as_pdf : Icons.upload_file,
                            color: _signedAgreementBytes != null ? Colors.red : AppColors.turquoiseBlue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _signedAgreementBytes != null
                                  ? '${_signedAgreementFileName ?? "Acuerdo firmado"} (${_signedAgreementsDate != null ? DateFormat('dd/MM/yyyy').format(_signedAgreementsDate!) : ''})'
                                  : 'Adjuntar acuerdo firmado (PDF)',
                              style: textTheme.bodySmall?.copyWith(
                                color: _signedAgreementBytes != null ? AppColors.greyDark : AppColors.greyLetter,
                                fontSize: responsiveSize(context, 14, 16, md: 15),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              childRight: CustomTextFormFieldTitle(
                labelText: '¿Qué iniciativas o servicios ofrece?',
                onChanged: (value){
                  _offeredServices = value;
                },
              )
          ),
          SpaceH24(),
          CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: CustomDropDownButtonFormFieldTittle(
                labelText: 'Grado de decisión',
                source: choiceGrade,
                onChanged: (value){
                  _contactChoiceGrade = value;
                },
              ),
              childRight: CustomDropDownButtonFormFieldTittle(
                labelText: '¿Se considera un KOL (Key Opinion Leader)?',
                source: yesNo,
                onChanged: (value){
                  setState(() {
                    _contactKOL = value;
                    if (_contactKOL != 'Si') {
                      _kolType = '';
                    }
                  });
                },
              )
          ),
          if (_contactKOL == 'Si') ...[
            SpaceH24(),
            CustomDropDownButtonFormFieldTittle(
              labelText: 'Tipo de KOL',
              source: kolTypes,
              onChanged: (value) {
                _kolType = value;
              },
            ),
          ],
          SpaceH24(),
          CustomFlexRowColumn(
            contentPadding: EdgeInsets.zero,
            separatorSize: 20,
            childLeft: CustomDropDownButtonFormFieldTittle(
              labelText: 'Zona geográfica de influencia',
              source: geographicZone,
              onChanged: (value){
                _geographicZone = value;
              },
              validator: (value) => value != null ? null : StringConst.FORM_GENERIC_ERROR,
            ),
            childRight: CustomTextFormFieldTitle(
              labelText: 'Sub Zona geográfica de influencia',
              onChanged: (value){
                _subGeographicZone = value;
              },
              validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
            )
          ),
          SpaceH24(),
          CustomTextFormFieldTitle(
            labelText: 'Url de la página web',
            onChanged: (value){
              _url = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
          SpaceH24(),
          CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: CustomTextFormFieldTitle(
                labelText: 'Email',
                onChanged: (value){
                  _email = value;
                },
                validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
              ),
              childRight: CustomPhoneFormFieldTitle(
                labelText: 'Teléfono fijo de la organización',
                phoneCode: entityPhoneCode,
                onCountryChange: (code){
                  entityPhoneCode = code.toString();
                },
                onSaved: (value) => _entityPhone = entityPhoneCode +' '+ value!,
              )
          ),
          SpaceH24(),
          CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: CustomPhoneFormFieldTitle(
                labelText: 'Teléfono móvil',
                phoneCode: entityMobilePhoneCode,
                onCountryChange: (code){
                  entityMobilePhoneCode = code.toString();
                },
                onSaved: (value) => _entityMobilePhone = entityMobilePhoneCode +' '+ value!,
              ),
              childRight: CustomTextFormFieldTitle(
                labelText: 'Linkedin',
                onChanged: (value){
                  _linkedin = value;
                },
              )
          ),
          SpaceH24(),
          CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: CustomTextFormFieldTitle(
                labelText: 'X',
                onChanged: (value){
                  _twitter = value;
                },
              ),
              childRight: CustomTextFormFieldTitle(
                labelText: 'Otra red social',
                onChanged: (value){
                  _otherSocialMedia = value;
                },
              )
          ),
          SpaceH24(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Sizes.MARGIN_20),
            child: Text(
              'Datos de la persona de contacto',
              style: textTheme.titleMedium!.copyWith(
                color: AppColors.turquoiseBlue,
                fontWeight: FontWeight.w300,
                // Fix the bug with Google Fonts that doesn't allow change the fontWeight with copyWith method
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),
            ),
          ),
          CustomTextFormFieldTitle(
            labelText: 'Nombre completo de la persona de referencia',
            onChanged: (value){
              _contactName = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
          SpaceH24(),
          CustomFlexRowColumn(
            contentPadding: EdgeInsets.zero,
            separatorSize: 20,
            childLeft: CustomPhoneFormFieldTitle(
              labelText: 'Teléfono fijo',
              phoneCode: contactDeskPhoneCode,
              onCountryChange: (code){
                contactDeskPhoneCode = code.toString();
              },
              onSaved: (value) => _contactPhone = contactDeskPhoneCode +' '+ value!,
            ),
            childRight: CustomPhoneFormFieldTitle(
              labelText: 'Teléfono móvil',
              phoneCode: contactMobilePhoneCode,
              onCountryChange: (code){
                contactMobilePhoneCode = code.toString();
              },
              onSaved: (value) => _contactMobilePhone = contactMobilePhoneCode +' '+ value!,
            ),
          ),
          SpaceH24(),
          CustomFlexRowColumn(
            contentPadding: EdgeInsets.zero,
            separatorSize: 20,
            childLeft: CustomTextFormFieldTitle(
              labelText: 'Email',
              onChanged: (value){
                _contactEmail = value;
              },
              validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
            ),
              childRight: CustomTextFormFieldTitle(
                labelText: 'Cargo de la persona de contacto',
                onChanged: (value){
                  _contactPosition = value;
                },
              ),
          ),
        ],
      ),
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
          }
      );
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

  void buildCountryStreamBuilderSetState(Country? country) {
    setState(() {
      selectedProvince = null;
      selectedCity = null;
      selectedCountry = country;
      countryName = country != null ? country.name : "";
    });
    _countryId = country?.countryId;
  }

  void buildProvinceStreamBuilderSetState(Province? province) {
    setState(() {
      selectedCity = null;
      selectedProvince = province;
      provinceName = province != null ? province.name : "";
    });
    _provinceId = province?.provinceId;
  }

  void buildCityStreamBuilderSetState(City? city) {
    setState(() {
      selectedCity = city;
      cityName = city != null ? city.name : "";
    });
    _cityId = city?.cityId;
  }

  void addressSetState(String? val) {
    setState(() => _postalCode = val!);
  }

  void _showMultiSelectActionScope(BuildContext context) async {
    final selectedValues = await showDialog<Set<ScopeAction>>(
      context: context,
      builder: (BuildContext context) {
        return streamBuilderDropdownScopeActionCreate(context, selectedScopeActions);
      },
    );
    if (selectedValues != null) {
      setState(() {
        selectedScopeActions = selectedValues;
        _actionScope = selectedValues.map((e) => e.id ?? '').toList();
        textEditingControllerActionScope.text = selectedValues.map((e) => e.name).join(', ');
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
        _actionScope = selectedValues.map((e) => e.interestId ?? '').toList();
        textEditingControllerActionScope.text = selectedValues.map((e) => e.name).join(', ');
      });
    }
  }

}