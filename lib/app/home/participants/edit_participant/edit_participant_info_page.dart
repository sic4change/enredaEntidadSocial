import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:enreda_empresas/app/common_widgets/alert_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/custom_date_picker_title.dart';
import 'package:enreda_empresas/app/common_widgets/custom_phone_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/enreda_button.dart';
import 'package:enreda_empresas/app/common_widgets/flex_row_column.dart';
import 'package:enreda_empresas/app/common_widgets/rounded_container.dart';
import 'package:enreda_empresas/app/common_widgets/show_exception_alert_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/participants/create_participant/validating_form_controls/stream_builder_city.dart';
import 'package:enreda_empresas/app/home/participants/create_participant/validating_form_controls/stream_builder_country.dart';
import 'package:enreda_empresas/app/home/participants/create_participant/validating_form_controls/stream_builder_education.dart';
import 'package:enreda_empresas/app/home/participants/create_participant/validating_form_controls/stream_builder_gender.dart';
import 'package:enreda_empresas/app/home/participants/create_participant/validating_form_controls/stream_builder_nation.dart';
import 'package:enreda_empresas/app/home/participants/create_participant/validating_form_controls/stream_builder_province.dart';
import 'package:enreda_empresas/app/models/addressUser.dart';
import 'package:enreda_empresas/app/models/city.dart';
import 'package:enreda_empresas/app/models/country.dart';
import 'package:enreda_empresas/app/models/education.dart';
import 'package:enreda_empresas/app/models/gender.dart';
import 'package:enreda_empresas/app/models/province.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Widget inline (sin Scaffold) para editar la información general de un participante.
/// Se muestra en el área de contenido de ParticipantDetailPage.
class EditParticipantInfoPage extends StatefulWidget {
  final UserEnreda participant;
  /// Llamado cuando se guarda con éxito, para volver a la vista anterior.
  final VoidCallback onSaved;
  /// Llamado cuando el usuario cancela la edición.
  final VoidCallback onCancel;

  const EditParticipantInfoPage({
    Key? key,
    required this.participant,
    required this.onSaved,
    required this.onCancel,
  }) : super(key: key);

  @override
  _EditParticipantInfoPageState createState() => _EditParticipantInfoPageState();
}

class _EditParticipantInfoPageState extends State<EditParticipantInfoPage> {
  final _formKey = GlobalKey<FormState>();

  String? _firstName;
  String? _lastName;
  String? _phone;
  DateTime? _birthday;
  String? _postalCode;
  String? _nationality;

  Country? selectedCountry;
  Province? selectedProvince;
  City? selectedCity;
  Education? selectedEducation;
  Gender? selectedGender;
  String? selectedNationality;

  String _country = '';
  String _province = '';
  String _city = '';
  String genderName = '';
  String educationName = '';
  String? educationId;

  String phoneCode = '+34';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.participant;

    _firstName = p.firstName ?? '';
    _lastName = p.lastName ?? '';
    _phone = _extractPhoneNumber(p.phone);
    phoneCode = _extractPhoneCode(p.phone);
    _birthday = p.birthday;
    _postalCode = p.address?.postalCode ?? '';
    _nationality = p.nationality ?? '';
    selectedNationality = (p.nationality != null && p.nationality!.isNotEmpty)
        ? p.nationality
        : null;

    _country = p.address?.country ?? '';
    _province = p.address?.province ?? '';
    _city = p.address?.city ?? '';
    genderName = p.gender ?? '';
    educationName = p.educationName ?? '';
    educationId = p.educationId;

    // Pre-cargar objetos desde caché
    final cache = LocationCache.instance;
    selectedCountry = _country.isNotEmpty ? cache.countryById(_country) : null;
    selectedProvince = _province.isNotEmpty ? cache.provinceById(_province) : null;
    selectedCity = _city.isNotEmpty ? cache.cityById(_city) : null;

    // Buscar género por nombre
    if (genderName.isNotEmpty) {
      try {
        selectedGender = cache.genders.firstWhere((g) => g.name == genderName);
      } catch (_) {
        selectedGender = null;
      }
    }

    // Buscar educación por ID
    if (educationId != null && educationId!.isNotEmpty) {
      try {
        selectedEducation = cache.educations.firstWhere((e) => e.educationId == educationId);
      } catch (_) {
        selectedEducation = null;
      }
    }
  }

  bool _initialLocationLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialLocationLoaded) {
      _initialLocationLoaded = true;
      _loadInitialLocationData();
    }
  }

  Future<void> _loadInitialLocationData() async {
    final database = Provider.of<Database>(context, listen: false);

    if (_country.isNotEmpty && selectedCountry == null) {
      final country = await database.countryStream(_country).first;
      if (mounted) setState(() => selectedCountry = country);
    }

    if (_province.isNotEmpty && selectedProvince == null) {
      final province = await database.provinceStream(_province).first;
      if (mounted) setState(() => selectedProvince = province);
    }

    if (_city.isNotEmpty && selectedCity == null) {
      final city = await database.cityStream(_city).first;
      if (mounted) setState(() => selectedCity = city);
    }
  }

  String _extractPhoneCode(String? phone) {
    if (phone == null || phone.isEmpty) return '+34';
    final parts = phone.split(' ');
    if (parts.length > 1 && parts[0].startsWith('+')) return parts[0];
    return '+34';
  }

  String _extractPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    final parts = phone.split(' ');
    if (parts.length > 1 && parts[0].startsWith('+')) return parts.sublist(1).join(' ');
    return phone;
  }

  void _onCountryChange(CountryCode countryCode) {
    phoneCode = countryCode.toString();
  }

  void _buildCountryStreamBuilder_setState(Country? country) {
    setState(() {
      selectedProvince = null;
      selectedCity = null;
      selectedCountry = country;
    });
    _country = country?.countryId ?? '';
  }

  void _buildNationalityStreamBuilder_setState(String? country) {
    setState(() => selectedNationality = country);
    _nationality = country;
  }

  void _buildProvinceStreamBuilder_setState(Province? province) {
    setState(() {
      selectedCity = null;
      selectedProvince = province;
    });
    _province = province?.provinceId ?? '';
  }

  void _buildCityStreamBuilder_setState(City? city) {
    setState(() => selectedCity = city);
    _city = city?.cityId ?? '';
  }

  void _buildEducationStreamBuilder_setState(Education? education) {
    setState(() {
      selectedEducation = education;
      educationName = education?.label ?? '';
      educationId = education?.educationId;
    });
  }

  void _buildGenderStreamBuilder_setState(Gender? gender) {
    setState(() {
      selectedGender = gender;
      genderName = gender?.name ?? '';
    });
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _save() async {
    if (!_validateAndSaveForm()) return;

    setState(() => _isSaving = true);

    try {
      final database = Provider.of<Database>(context, listen: false);
      final p = widget.participant;

      final phoneValue = _phone != null && _phone!.isNotEmpty
          ? '$phoneCode $_phone'
          : (p.phone ?? '');

      final address = Address(
        country: _country.isNotEmpty ? _country : p.address?.country,
        province: _province.isNotEmpty ? _province : p.address?.province,
        city: _city.isNotEmpty ? _city : p.address?.city,
        postalCode: _postalCode,
      );

      final Map<String, dynamic> fields = {
        'firstName': _firstName,
        'lastName': _lastName,
        'phone': phoneValue,
        'birthday': _birthday,
        'address': address.toMap(),
        'gender': genderName.isNotEmpty ? genderName : p.gender,
        'educationId': educationId ?? p.educationId,
        'nationality': selectedNationality ?? p.nationality,
      };

      await database.updateUserEnredaFields(p.userId!, fields);

      await showAlertDialog(
        context,
        title: '¡Información actualizada!',
        content: 'Los datos del participante han sido guardados con éxito.',
        defaultActionText: StringConst.FORM_ACCEPT,
      );

      widget.onSaved();
    } on FirebaseException catch (e) {
      showExceptionAlertDialog(context, title: StringConst.FORM_ERROR, exception: e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    double contactBtnWidth = responsiveSize(context, 120.0, 200.0, md: 150.0);

    return RoundedContainer(
      borderColor: Responsive.isMobile(context) ? Colors.transparent : AppColors.greyLight,
      margin: EdgeInsets.zero,
      contentPadding: EdgeInsets.all(Sizes.kDefaultPaddingDouble),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera con título y botón de cancelar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                StringConst.FORM_GENERAL_INFO,
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.turquoiseBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  final leave = await showAlertDialog(
                    context,
                    title: '¿Estás seguro que quieres dejar de editar?',
                    content: 'Si sales, los cambios no guardados se perderán.',
                    defaultActionText: 'Salir',
                    cancelActionText: 'Cancelar',
                  );
                  if (leave == true) {
                    widget.onCancel();
                  }
                },
                icon: Icon(Icons.close, size: 18, color: AppColors.greyTxtAlt),
                label: Text(
                  'Cancelar',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.greyTxtAlt),
                ),
              ),
            ],
          ),
          Divider(color: AppColors.greyBorder, height: Sizes.kDefaultPaddingDouble),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre y Apellidos
                CustomFlexRowColumn(
                  contentPadding: EdgeInsets.all(0.0),
                  separatorSize: Sizes.kDefaultPaddingDouble,
                  childLeft: CustomTextFormFieldTitle(
                    labelText: StringConst.FORM_NAME,
                    initialValue: _firstName ?? '',
                    validator: (value) =>
                        value!.isNotEmpty ? null : StringConst.NAME_ERROR,
                    onSaved: (val) => _firstName = val,
                  ),
                  childRight: CustomTextFormFieldTitle(
                    labelText: StringConst.FORM_LASTNAME,
                    initialValue: _lastName ?? '',
                    validator: (value) =>
                        value!.isNotEmpty ? null : StringConst.FORM_LASTNAME_ERROR,
                    onSaved: (val) => _lastName = val,
                  ),
                ),
                SpaceH20(),

                // Fecha de nacimiento y género
                Flex(
                  direction: Responsive.isMobile(context) ? Axis.vertical : Axis.horizontal,
                  children: [
                    Expanded(
                      flex: Responsive.isMobile(context) ? 0 : 1,
                      child: CustomDatePickerTitleClosed(
                        labelText: StringConst.FORM_BIRTHDAY,
                        initialValue: _birthday,
                        onChanged: (value) => setState(() => _birthday = value),
                        validator: (value) =>
                            value != null ? null : StringConst.FORM_BIRTHDAY_ERROR,
                      ),
                    ),
                    if (Responsive.isMobile(context)) SpaceH20(),
                    if (!Responsive.isMobile(context)) SpaceW20(),
                    Expanded(
                      flex: Responsive.isMobile(context) ? 0 : 1,
                      child: streamBuilder_Dropdown_Genders(
                        context,
                        selectedGender,
                        _buildGenderStreamBuilder_setState,
                      ),
                    ),
                  ],
                ),
                SpaceH20(),

                // Nacionalidad
                streamBuilderForNation(
                  context,
                  selectedNationality,
                  _buildNationalityStreamBuilder_setState,
                  'Nacionalidad',
                ),
                SpaceH20(),

                // Teléfono
                CustomPhoneFormFieldTitle(
                  labelText: StringConst.FORM_PHONE,
                  phoneCode: phoneCode,
                  onCountryChange: _onCountryChange,
                  initialValue: _phone,
                  validator: (value) =>
                      value!.isNotEmpty ? null : StringConst.PHONE_ERROR,
                  onSaved: (value) => _phone = value,
                  fontSize: 15,
                ),
                SpaceH20(),

                // País y Provincia
                CustomFlexRowColumn(
                  contentPadding: EdgeInsets.all(0.0),
                  separatorSize: Sizes.kDefaultPaddingDouble,
                  childLeft: streamBuilderForCountry(
                    context,
                    selectedCountry,
                    _buildCountryStreamBuilder_setState,
                    StringConst.FORM_CURRENT_COUNTRY,
                  ),
                  childRight: streamBuilderForProvince(
                    context,
                    selectedCountry,
                    selectedProvince,
                    _buildProvinceStreamBuilder_setState,
                  ),
                ),
                SpaceH20(),

                // Ciudad y Código Postal
                CustomFlexRowColumn(
                  contentPadding: EdgeInsets.all(0.0),
                  separatorSize: Sizes.kDefaultPaddingDouble,
                  childLeft: streamBuilderForCity(
                    context,
                    selectedCountry,
                    selectedProvince,
                    selectedCity,
                    _buildCityStreamBuilder_setState,
                  ),
                  childRight: CustomTextFormFieldTitle(
                    labelText: StringConst.FORM_POSTAL_CODE,
                    initialValue: _postalCode ?? '',
                    onSaved: (val) => _postalCode = val,
                  ),
                ),
                SpaceH20(),

                // Nivel de titulación
                streamBuilderDropdownEducation(
                  context,
                  selectedEducation,
                  _buildEducationStreamBuilder_setState,
                ),
                SpaceH40(),

                // Botón Guardar
                Center(
                  child: _isSaving
                      ? CircularProgressIndicator(color: AppColors.turquoiseBlue)
                      : EnredaButton(
                          buttonTitle: StringConst.SAVE,
                          width: contactBtnWidth,
                          buttonColor: AppColors.primaryColor,
                          titleColor: AppColors.white,
                          onPressed: _save,
                        ),
                ),
                SpaceH20(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
