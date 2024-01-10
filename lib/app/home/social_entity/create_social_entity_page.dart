import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enreda_empresas/app/common_widgets/alert_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/custom_chip.dart';
import 'package:enreda_empresas/app/common_widgets/custom_drop_down_button_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/custom_phone_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/enreda_button.dart';
import 'package:enreda_empresas/app/common_widgets/flex_row_column.dart';
import 'package:enreda_empresas/app/common_widgets/rounded_container.dart';
import 'package:enreda_empresas/app/common_widgets/show_exception_alert_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/web_home.dart';
import 'package:enreda_empresas/app/models/socialEntitiesType.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CreateSocialEntityPage extends StatefulWidget {
  const CreateSocialEntityPage({Key? key}) : super(key: key);

  @override
  _CreateSocialEntityPageState createState() => _CreateSocialEntityPageState();
}

class _CreateSocialEntityPageState extends State<CreateSocialEntityPage> {
  final _formKey = GlobalKey<FormState>();
  final _formKeyContactPerson = GlobalKey<FormState>();

  String? _entityName, _actionScope;
  late List<String> _entityTypes;
  String? _category, _subCategory;
  String? _entityPhone, _entityMobilePhone, _contactPhone, _contactMobilePhone;
  String? _geographicZone, _subGeographicZone;
  String? _url;
  String? _email, _linkedin, _twitter, _otherSocialMedia;
  String? _contactName, _contactEmail, _contactPosition, _contactChoiceGrade, _contactKOL, _contactProject;

  //Country codes for phone numbers
  String entityPhoneCode = '+34';
  String entityMobilePhoneCode = '+34';
  String contactDeskPhoneCode = '+34';
  String contactMobilePhoneCode = '+34';


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

  late TextTheme textTheme;

  @override
  void initState() {
    super.initState();

    //New values
    _entityName = '';
    _actionScope = '';
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
  }

  @override
  Widget build(BuildContext context) {
    textTheme = Theme.of(context).textTheme;

    return RoundedContainer(
        child: SingleChildScrollView(
          controller: ScrollController(),
          scrollDirection: Axis.vertical,
          child: Container(
            height: 2000,
            width: 1000,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(Sizes.MARGIN_44),
                child: Text(
                  StringConst.NEW_PROFILE,
                  style: textTheme.titleMedium!.copyWith(
                    color: AppColors.turquoiseBlue,
                    fontWeight: FontWeight.w300,
                    // Fix the bug with Google Fonts that doesn't allow change the fontWeight with copyWith method
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return _buildCompleteForm(context);
                  }
                ),
              ),
            ],
                  ),
          ),
        ),
    );
  }

  Widget _buildCompleteForm(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormNewEntity(context),
        Padding(
          padding: const EdgeInsets.all(Sizes.MARGIN_44),
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
        _buildFormContactPerson(context),
        SpaceH50(),
        Center(
          child: EnredaButton(
            buttonTitle: 'Guardar',
            buttonColor: AppColors.turquoise,
            titleColor: Colors.white,
            height: 50.0,
            width: 160,
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
            onPressed: () async {
              // Validate returns true if the form is valid, or false otherwise.
              if (_formKey.currentState!.validate() && _formKeyContactPerson.currentState!.validate()) {
                _formKey.currentState!.save();
                _formKeyContactPerson.currentState!.save();

                SocialEntity finalSocialEntity = SocialEntity(
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
                );

                try {
                  final database = Provider.of<Database>(context, listen: false);
                  await database.addSocialEntity(finalSocialEntity);
                  await showAlertDialog(
                  context,
                  title: StringConst.CREATE_PARTICIPANT_SUCCESS,
                  content: "",
                  defaultActionText: StringConst.FORM_ACCEPT,
                  );
                  WebHome.goToControlPanel();
                } on FirebaseException catch (e) {
                  showExceptionAlertDialog(context,
                      title: StringConst.FORM_ERROR, exception: e).then((value) => Navigator.pop(context));
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFormNewEntity(BuildContext context){
    final database = Provider.of<Database>(context, listen: false);
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 16, md: 15);
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.MARGIN_44),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextFormFieldTitle(
              labelText: 'Nombre de la entidad',
              onChanged: (value){
                setState(() {
                  _entityName = value;
                });
              },
              validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
            ),
            SpaceH24(),
            CustomTextFormFieldTitle(
              labelText: 'Ambito de actuación',
              onChanged: (value){
                setState(() {
                  _actionScope = value;
                });
              },
              validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
            ),
            SpaceH24(),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Sectores/Campos/Etiquetas/Ecosistemas',
                style: textTheme.button?.copyWith(
                  height: 1.5,
                  color: AppColors.greyDark,
                  fontWeight: FontWeight.w700,
                  fontSize: fontSize,
                ),
              ),
            ),
            chipContainer(),
            SpaceH24(),
            CustomFlexRowColumn(
                contentPadding: EdgeInsets.zero,
                separatorSize: 20,
                childLeft: CustomTextFormFieldTitle(
                  labelText: 'Categoria',
                  hintText: 'Tercer sector',
                  enabled: false,
                  onSaved: (value){
                    setState(() {
                      _category = value;
                    });
                  },
                  validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
                  initialValue: 'Tercer sector',
                ),
                childRight: CustomDropDownButtonFormFieldTittle(
                  labelText: 'Sub-categoría',
                  source: subCategories,
                  onChanged: (value){
                    setState(() {
                      _subCategory = value;
                    });
                  },
                  validator: (value) => value != null ? null : StringConst.FORM_GENERIC_ERROR,
                )
            ),
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
                  labelText: 'Teléfono fijo',
                  phoneCode: entityPhoneCode,
                  onCountryChange: (code){
                    entityPhoneCode = code.toString();
                  },
                  validator: (value) =>
                    value!.isNotEmpty ? null : StringConst.PHONE_ERROR,
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
                  validator: (value) =>
                    value!.isNotEmpty ? null : StringConst.PHONE_ERROR,
                  onSaved: (value) => _entityMobilePhone = entityMobilePhoneCode +' '+ value!,
                ),
                childRight: CustomTextFormFieldTitle(
                  labelText: 'Linkedin',
                  onChanged: (value){
                    _linkedin = value;
                  },
                  //validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
                )
            ),
            SpaceH24(),
            CustomFlexRowColumn(
                contentPadding: EdgeInsets.zero,
                separatorSize: 20,
                childLeft: CustomTextFormFieldTitle(
                  labelText: 'Twitter',
                  onChanged: (value){
                    _twitter = value;
                  },
                  //validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
                ),
                childRight: CustomTextFormFieldTitle(
                  labelText: 'Otra red social',
                  onChanged: (value){
                    _otherSocialMedia = value;
                  },
                  //validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
                )
            )

          ],
        ),
      ),
    );
  }

  Widget _buildFormContactPerson(BuildContext context){
    final database = Provider.of<Database>(context, listen: false);
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 16, md: 15);
    return Form(
      key: _formKeyContactPerson,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.MARGIN_44),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextFormFieldTitle(
              labelText: 'Nombre completo de la técnico de referencia',
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
                  validator: (value) =>
                    value!.isNotEmpty ? null : StringConst.PHONE_ERROR,
                  onSaved: (value) => _contactPhone = contactDeskPhoneCode +' '+ value!,
                ),
                childRight: CustomPhoneFormFieldTitle(
                  labelText: 'Teléfono móvil',
                  phoneCode: contactMobilePhoneCode,
                  onCountryChange: (code){
                    contactMobilePhoneCode = code.toString();
                  },
                  validator: (value) =>
                  value!.isNotEmpty ? null : StringConst.PHONE_ERROR,
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
                  validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
                ),
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
                  validator: (value) => value != null ? null : StringConst.FORM_GENERIC_ERROR,
                ),
                childRight: CustomDropDownButtonFormFieldTittle(
                    labelText: '¿Se considera un KOL (Key Opinion Leader)?',
                    source: yesNo,
                    onChanged: (value){
                      _contactKOL = value;
                    },
                  validator: (value) => value != null ? null : StringConst.FORM_GENERIC_ERROR,
                )
            ),
            SpaceH24(),
            CustomFlexRowColumn(
                contentPadding: EdgeInsets.zero,
                separatorSize: 20,
                childLeft: CustomTextFormFieldTitle(
                  labelText: 'Acuerdos firmados',
                  enabled: false,
                ),
                childRight: CustomTextFormFieldTitle(
                  labelText: 'Proyecto o programa',
                  onChanged: (value){
                    _contactProject = value;
                  },
                  validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
                )
            ),
          ],
        ),
      ),
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

  Widget chipContainer(){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.greyUltraLight,
        )
      ),
      height: 180,
      child: Center(child: chipFilter()),
    );
  }

}