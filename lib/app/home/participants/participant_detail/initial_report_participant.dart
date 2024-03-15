import 'package:enreda_empresas/app/common_widgets/custom_date_picker_title.dart';
import 'package:enreda_empresas/app/common_widgets/custom_drop_down_button_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/custom_multi_selection_radio_list.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/enreda_button.dart';
import 'package:enreda_empresas/app/common_widgets/flex_row_column.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/common_widgets/text_form_field.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/participant_social_reports_page.dart';
import 'package:enreda_empresas/app/models/followReport.dart';
import 'package:enreda_empresas/app/models/initialReport.dart';
import 'package:enreda_empresas/app/models/languageReport.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/auth.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class InitialReportForm extends StatefulWidget {
  const InitialReportForm({super.key, required this.user});

  final UserEnreda user;

  @override
  State<InitialReportForm> createState() => _InitialReportFormState();
}

class _InitialReportFormState extends State<InitialReportForm> {

  late Widget currentPage;
  late String? _disabilityState = '';
  late String? _granted = '';
  late List<LanguageReport>? _languages = null;
  late String? _laborSituation = '';
  late String? _activeLabor = '';
  late String? _occupiedLabor = '';

  @override
  void initState() {
    currentPage = initialReport(context, widget.user);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return currentPage;
  }

  void setStateMenuPage() {
    setState(() {
      currentPage = ParticipantSocialReportPage(
          participantUser: widget.user, context: context);
    });
  }

  void setStateGranted(String value){
    setState(() {
      //To refresh the page
      currentPage = initialReport(context, widget.user);
      _disabilityState = value;
    });
  }

  void setStateDefinitive(String value){
    setState(() {
      //To refresh the page
      currentPage = initialReport(context, widget.user);
      _granted = value;
    });
  }

  void setStateAddLanguage(List<LanguageReport> value){
    setState(() {
      //To refresh the page
      currentPage = initialReport(context, widget.user);
      List<LanguageReport> addition = value;
      addition.add(LanguageReport(name: '', level: ''));
      _languages = addition;
    });
  }

  void setStateLaborSituation(String value){
    setState(() {
      //To refresh the page
      currentPage = initialReport(context, widget.user);
      _laborSituation = value;
    });
  }

  void setStateActiveLabor(String value){
    setState(() {
      //To refresh the page
      currentPage = initialReport(context, widget.user);
      _activeLabor = value;
    });
  }

  void setStateOccupiedLabor(String value){
    setState(() {
      //To refresh the page
      currentPage = initialReport(context, widget.user);
      _occupiedLabor = value;
    });
  }


  Widget initialReport(BuildContext context, UserEnreda user) {
    final database = Provider.of<Database>(context, listen: false);

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.greyBorder)
          ),
          child:
          Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: setStateMenuPage,
                        icon: Icon(Icons.arrow_back_rounded),
                        iconSize: 30,
                        color: AppColors.turquoiseBlue,
                      ),
                      SpaceW8(),
                      CustomTextBoldTitle(
                          title: 'Informe inicial'.toUpperCase()
                      ),
                    ],
                  ),
                ),
                Divider(color: AppColors.greyBorder,),
                StreamBuilder(
                  stream: database.userEnredaStreamByUserId(user.userId),
                  builder: (context, snapshotUser){
                    UserEnreda userStream = user;
                    if(snapshotUser.hasData){
                      userStream = snapshotUser.data!;
                    }
                  return StreamBuilder<InitialReport>(
                      stream: database.initialReportsStreamByUserId(user.userId),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          InitialReport initialReportSaved = snapshot.data!;
                          return completeInitialForm(context, initialReportSaved);
                        }
                        else {
                          if (userStream.initialReportId == null) {
                            database.addInitialReport(InitialReport(
                              userId: user.userId,
                            ));
                          }
                          return Container(
                            height: 300,
                          );
                        }
                      }
                    );
                  }
                ),
              ]
          ),
        )
    );
  }

  Widget informSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 15),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: GoogleFonts
              .outfit()
              .fontFamily,
          color: AppColors.bluePetrol,
        ),
      ),
    );
  }

  Widget informSubSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 15),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: GoogleFonts
              .outfit()
              .fontFamily,
          color: AppColors.bluePetrol,
        ),
      ),
    );
  }

  Widget multiSelectionList(List<String> options,
      void Function(String? value)? onChanged, List<String> selected) {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      direction: Axis.horizontal,

      children: <Widget>[
        for(var option in options)
          SizedBox(
            width: 300, //TODO make responsive
            child: RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: null,
              onChanged: onChanged,
              dense: true,
            ),
          )
      ],
    );
  }

  Widget multiSelectionListTitle(BuildContext context, List<String> options,
      String title) {
    final textTheme = Theme
        .of(context)
        .textTheme;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              title,
              style: textTheme.button?.copyWith(
                height: 1.5,
                color: AppColors.greyDark,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            height: 50,
            child: Center(child:
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for(var option in options)
                  SizedBox(
                    width: 110, //TODO make responsive
                    child: RadioListTile(
                      title: Text(option),
                      value: null,
                      groupValue: null,
                      onChanged: (Null? value) {},
                      dense: true,
                    ),
                  )
              ],
            )
            ),
          ),
        ]
    );
  }

  Widget addLanguageButton(){
    return InkWell(
      child: Row(
        children: [
          Icon(
            Icons.add_circle_outline,
            color: AppColors.turquoiseBlue,
          ),
          SpaceW8(),
          Text(
            'Añadir idioma',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.turquoiseBlue,
            ),
          ),
        ],
      ),
      onTap: (){
        setStateAddLanguage(_languages!);
      }
    );
  }

  Widget completeInitialForm(BuildContext context, InitialReport report) {
    final database = Provider.of<Database>(context, listen: false);
    final _formKey = GlobalKey<FormState>();

    bool _finished = report.finished ?? false;

    List<DropdownMenuItem<String>> _yesNoSelection = ['Si', 'No'].map<
        DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();

    List<DropdownMenuItem<String>> _subsidySelection = [
      '529760_MEDICOS DEL MUNDO_EMPLEANDO_SUEÑOS',
      '529775_SICFCH - Acompañamiento, tecnología y colaboración: 3 claves en el camino hacia el empleo joven',
    ].map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();

    //Pre-Selection
    String? _subsidy = report.subsidy ?? '';

    //Section 1
    String _orientation1 = report.orientation1 ?? '';
    DateTime? _arriveDate = report.arriveDate;
    String _receptionResources = report.receptionResources ?? '';
    String _administrativeSituation = report.administrativeSituation ?? '';

    List<DropdownMenuItem<String>> _arriveTypeSelection = ['Segura', 'Insegura']
        .map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();

    //Section 2
    DateTime? _expirationDate = report.expirationDate;
    String? _orientation2 = report.orientation2 ?? '';
    String? _healthCard = report.healthCard ?? '';
    String? _medication = report.medication ?? '';
    List<DropdownMenuItem<String>> _healthCardSelection = [
      'Si',
      'No',
      'Caducidad'
    ].map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();

    //Subsection 2.1
    String? _orientation2_1 = report.orientation2_1 ?? '';
    String? _rest = report.rest ?? '';
    String? _diagnosis = report.diagnosis ?? '';
    String? _treatment = report.treatment ?? '';
    String? _tracking = report.tracking ?? '';
    String? _psychosocial = report.psychosocial ?? '';

    //Subsection 2.2
    String? _orientation2_2 = report.orientation2_2 ?? '';
    _disabilityState == '' ? _disabilityState = report.disabilityState : _disabilityState = _disabilityState;
    String? _referenceProfessionalDisability = report.referenceProfessionalDisability ?? '';
    String? _disabilityGrade = report.disabilityGrade ?? '';
    _granted == '' ? _granted = report.granted : _granted = _granted;
    DateTime? _revisionDate = report.revisionDate;
    String? _disabilityType = report.disabilityType ?? '';
    List<DropdownMenuItem<String>> _stateSelection = ['En trámite', 'Concedida', 'No aplica']
        .map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
    List<DropdownMenuItem<String>> _grantedSelection = ['Revisable', 'Definitiva']
        .map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
    List<DropdownMenuItem<String>> _disabilityGradeSelection = [
      '1',
      '2',
      '3',
      '4',
      '5'
    ].map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
    List<DropdownMenuItem<String>> _disabilityTypeSelection = [
      'Sensorial', 'Intelectual', 'Psíquica'
    ].map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();

    //Subsection 2.3
    String? _orientation2_3 = report.orientation2_3 ?? '';
    String? _dependenceState = report.dependenceState ?? '';
    String? _referenceProfessionalDependence = report
        .referenceProfessionalDependence ?? '';
    String? _dependenceGrade = report.dependenceGrade ?? '';
    List<DropdownMenuItem<String>> _dependencyGradeSelection = ['I', 'II', 'III']
        .map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();

    //Subsection 2.4
    String? _orientation2_4 = report.orientation2_4 ?? '';
    String? _externalDerivation = report.externalDerivation ?? '';

    //Section 3
    String? _orientation3 = report.orientation3 ?? '';
    String? _internalDerivationLegal = report.internalDerivationLegal ?? '';
    String? _externalDerivationLegal = report.externalDerivationLegal ?? '';
    String? _legalRepresentation = report.legalRepresentation ?? '';

    //Section 4
    String? _orientation4 = report.orientation4 ?? '';
    String? _ownershipType = report.ownershipType ?? '';
    String? _location = report.location ?? '';
    String? _centerContact = report.centerContact ?? '';
    List<String>? _hostingObservations = report.hostingObservations ?? [];

    List<DropdownMenuItem<String>> _ownershipTypeSelection = ['Hogar', 'Sin hogar']
        .map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();

    const List<String> _optionsSectionFour = [
      'Luz',
      'Gas',
      'Hacinamiento',
      'Accesibilidad',
      'Agua corriente',
      'Baño',
      'Agua caliente',
      'Mobiliario básico'
    ];

    //Section 5
    String? _orientation5 = report.orientation5 ?? '';
    String? _informationNetworks = report.informationNetworks ?? '';
    String? _institutionNetworks = report.institutionNetworks ?? '';
    String? _familyConciliation = report.familyConciliation ?? '';

    //Section 7
    String? _orientation7 = report.orientation7 ?? '';
    _languages == null ? _languages = report.languages : _languages = _languages;

    //Section 9
    String? _orientation9 = report.orientation9 ?? '';
    String? _centerTSReference = report.centerTSReference ?? '';
    String? _subsidyBeneficiary = report.subsidyBeneficiary ?? '';
    String? _socialServicesUser = report.socialServicesUser ?? '';
    String? _socialExclusionCertificate = report.socialExclusionCertificate ??
        '';

    //Section 12
    String? _orientation12 = report.orientation12 ?? '';
    List<String>? _vulnerabilityOptions = report.vulnerabilityOptions ?? [];

    List<String> _optionsSectionTwelve = [
      'Barrera ideomática',
      'Situación sinhogarismo',
      'Colectivo LGTBI',
      'Salud mental grave',
      'Joven ex tutelado/a',
      'Responsabilidades familiares',
      'Madre monomarental',
      'Minoría étnica',
      'Falta de red de apoyo',
      'Violencia de Género',
      'Adicciones',
      'Rularidad'
    ];

    //Section 13
    String? _orientation13 = report.orientation13 ?? '';
    String? _educationLevel = report.educationLevel ?? '';
    _laborSituation == '' ? _laborSituation = report.laborSituation : _laborSituation = _laborSituation;
    _activeLabor == '' ? _activeLabor = report.activeLabor : _activeLabor = _activeLabor;
    _occupiedLabor == '' ? _occupiedLabor = report.occupiedLabor : _occupiedLabor = _occupiedLabor;
    String? _tempLabor = report.tempLabor ?? '';
    String? _workingDayLabor = report.workingDayLabor ?? '';
    String? _competencies = report.competencies ?? '';
    String? _contextualization = report.contextualization ?? '';
    String? _connexion = report.connexion ?? '';
    String? _shortTerm = report.shortTerm ?? '';
    String? _mediumTerm = report.mediumTerm ?? '';
    String? _longTerm = report.longTerm ?? '';

    List<DropdownMenuItem<String>> _educationalLevelSelection = [
      '1er ciclo 2ria (Max CINE 0-2)',
      '2do ciclo 2ria (CINE 3) o postsecundaria (CINE 4)',
      'Superior o 3ria (CINE 5 a 8)',
    ].map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();

    List<DropdownMenuItem<String>> _laborSituationSelection = [
      'Activa',
      'Inactiva',
    ].map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();

    List<DropdownMenuItem<String>> _activeSelection = [
      'Ocupada',
      'Desempleada de larga duración (12 meses o más)',
      'Desempleada (menos de 12 meses)'
    ].map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();

    List<DropdownMenuItem<String>> _occupiedSelection = [
      'Cuenta propia',
      'Cuenta ajena',
    ].map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();

    List<DropdownMenuItem<String>> _tempSelection = [
      'Contrato indefinido',
      'Contrato temporal',
    ].map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();

    List<DropdownMenuItem<String>> _workDaySelection = [
      'Completa',
      'Parcial/Voluntaria',
      'Parcial/Involuntaria'
    ].map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();


    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 30),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SpaceH20(),
            _subsidy == '' ? CustomDropDownButtonFormFieldTittle(
              labelText: 'Subvención a la que el/la participante está imputado/a',
              source: _subsidySelection,
              onChanged: _finished ? null : (value) {
                _subsidy = value;
              },
              validator: (value) =>
              value != null ? null : StringConst.FORM_GENERIC_ERROR,
            ) :
            CustomDropDownButtonFormFieldTittle(
              labelText: 'Subvención a la que el/la participante está imputado/a',
              source: _subsidySelection,
              value: _subsidy,
              onChanged: _finished ? null : (value) {
                _subsidy = value;
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
            ),

            //Section 1
            informSectionTitle('1. Itinerario en España'),
            CustomTextFormFieldTitle(
              labelText: 'Orientaciones',
              initialValue: _orientation1,
              onChanged: (value) {
                _orientation1 = value ?? '';
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: CustomDatePickerTitle(
                labelText: 'Fecha de llegada a España',
                initialValue: _arriveDate,
                onChanged: (value) {
                  _arriveDate = value;
                },
                enabled: !_finished,
                validator: (value) =>
                (value != null) ? null : StringConst.FORM_GENERIC_ERROR,
              ),

              childRight: CustomTextFormFieldTitle(
                labelText: 'Recursos de Acogida',
                initialValue: _receptionResources,
                onChanged: (value) {
                  _receptionResources = value ?? '';
                },
                validator: (value) =>
                (value!.isNotEmpty || value != '')
                    ? null
                    : StringConst.FORM_GENERIC_ERROR,
                enabled: !_finished,
              ),
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: 'Situación administrativa',
              hintText: 'Ley de asilo, arraigo, ex-menor tutelado...',
              initialValue: _administrativeSituation,
              onChanged: (value) {
                _administrativeSituation = value ?? '';
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),

            //Section 2
            informSectionTitle('2. Situación Sanitaria'),
            CustomTextFormFieldTitle(
              labelText: 'Orientaciones',
              initialValue: _orientation2,
              onChanged: (value) {
                _orientation2 = value;
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: _healthCard == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: 'Tarjeta sanitaria',
                source: _healthCardSelection,
                onChanged: _finished ? null : (value) {
                  _healthCard = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              )
                  :
              CustomDropDownButtonFormFieldTittle(
                labelText: 'Tarjeta sanitaria',
                value: _healthCard,
                source: _healthCardSelection,
                onChanged: _finished ? null : (value) {
                  _healthCard = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              ),
              childRight: CustomDatePickerTitle(
                labelText: 'Fecha de caducidad',
                initialValue: _expirationDate,
                onChanged: (value) {
                  _expirationDate = value;
                },
                enabled: !_finished,
                validator: (value) =>
                (value != null) ? null : StringConst.FORM_GENERIC_ERROR,
              ),
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: 'Medicación/Tratamiento',
              initialValue: _medication,
              onChanged: (value) {
                _medication = value;
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            //Subsection 2.1
            informSubSectionTitle('2.1 Salud mental'),
            CustomTextFormFieldTitle(
              labelText: 'Orientaciones',
              initialValue: _orientation2_1,
              onChanged: (value) {
                _orientation2_1 = value;
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: CustomTextFormFieldTitle(
                labelText: 'Sueño y descanso',
                initialValue: _rest,
                onChanged: (value) {
                  _rest = value;
                },
                validator: (value) =>
                (value!.isNotEmpty || value != '')
                    ? null
                    : StringConst.FORM_GENERIC_ERROR,
                enabled: !_finished,
              ),
              childRight: _diagnosis == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: 'Diagnóstico',
                source: _yesNoSelection,
                onChanged: _finished ? null : (value) {
                  _diagnosis = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              )
                  :
              CustomDropDownButtonFormFieldTittle(
                labelText: 'Diagnóstico',
                source: _yesNoSelection,
                value: _diagnosis,
                onChanged: _finished ? null : (value) {
                  _diagnosis = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              ),
            ),
            SpaceH12(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: CustomTextFormFieldTitle(
                labelText: 'Tratamiento',
                initialValue: _treatment,
                onChanged: (value) {
                  _treatment = value;
                },
                validator: (value) =>
                (value!.isNotEmpty || value != '')
                    ? null
                    : StringConst.FORM_GENERIC_ERROR,
                enabled: !_finished,
              ),
              childRight: CustomTextFormFieldTitle(
                labelText: 'Seguimiento',
                initialValue: _tracking,
                onChanged: (value) {
                  _tracking = value;
                },
                validator: (value) =>
                (value!.isNotEmpty || value != '')
                    ? null
                    : StringConst.FORM_GENERIC_ERROR,
                enabled: !_finished,
              ),
            ),
            SpaceH12(),
            _psychosocial == '' ? CustomDropDownButtonFormFieldTittle(
              labelText: 'Derivación interna al área psicosocial',
              source: _yesNoSelection,
              onChanged: _finished ? null : (value) {
                _psychosocial = value;
              },
              validator: (value) =>
              value != null ? null : StringConst.FORM_GENERIC_ERROR,
            ) :
            CustomDropDownButtonFormFieldTittle(
              labelText: 'Derivación interna al área psicosocial',
              source: _yesNoSelection,
              value: _psychosocial,
              onChanged: _finished ? null : (value) {
                _psychosocial = value;
              },
              validator: (value) =>
              value != null ? null : StringConst.FORM_GENERIC_ERROR,
            ),

            //Subsection 2.2
            informSubSectionTitle('2.2 Discapacidad'),
            CustomTextFormFieldTitle(
              labelText: 'Orientaciones',
              initialValue: _orientation2_2,
              onChanged: (value) {
                _orientation2_2 = value;
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            _disabilityState == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: 'Estado',
                source: _stateSelection,
                onChanged: _finished ? null : (value) {
                  setStateGranted(value!);
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              )
                  :
              CustomDropDownButtonFormFieldTittle(
                labelText: 'Estado',
                source: _stateSelection,
                value: _disabilityState,
                onChanged: _finished ? null : (value) {
                  setStateGranted(value!);
                  if(value != 'Concedida'){
                    _granted = '';
                    _revisionDate = null;
                  }
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              ),
            SpaceH12(),

            _disabilityState == 'Concedida'
                ? CustomFlexRowColumn(
                  contentPadding: EdgeInsets.zero,
                  separatorSize: 20,

                  //Granted selection
                  childLeft: _granted == ''
                      ? CustomDropDownButtonFormFieldTittle(
                    labelText: 'Concedida',
                    source: _grantedSelection,
                    onChanged: _finished ? null : (value) {
                      setStateDefinitive(value!);
                    },
                    validator: (value) =>
                    value != null ? null : StringConst.FORM_GENERIC_ERROR,
                  )
                      :
                  CustomDropDownButtonFormFieldTittle(
                    labelText: 'Concedida',
                    source: _grantedSelection,
                    value: _granted,
                    onChanged: _finished ? null : (value) {
                      setStateDefinitive(value!);
                    },
                    validator: (value) =>
                    value != null ? null : StringConst.FORM_GENERIC_ERROR,
                  ),

                  //Date selection if revisable
                  childRight: _granted == 'Revisable' ?
                    CustomDatePickerTitle(
                      labelText: 'Fecha',
                      initialValue: _revisionDate,
                      onChanged: (value) {
                        _revisionDate = value;
                      },
                      enabled: !_finished,
                      validator: (value) =>
                      (value != null) ? null : StringConst.FORM_GENERIC_ERROR,
                    ) : Container(),
            ) :
                Container(),

            _disabilityState == 'Concedida' ? SpaceH12() : Container(),

            CustomTextFormFieldTitle(
                labelText: 'Profesional de referencia',
                initialValue: _referenceProfessionalDisability,
                onChanged: (value) {
                  _referenceProfessionalDisability = value;
                },
                validator: (value) =>
                (value!.isNotEmpty || value != '')
                    ? null
                    : StringConst.FORM_GENERIC_ERROR,
                enabled: !_finished,
              ),

            SpaceH12(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: _disabilityGrade == '' ?
                CustomDropDownButtonFormFieldTittle(
                  labelText: 'Grado de discapacidad',
                  source: _disabilityGradeSelection,
                  onChanged: _finished ? null : (value) {
                    _disabilityGrade = value;
                  },
                  validator: (value) =>
                  value != null ? null : StringConst.FORM_GENERIC_ERROR,
                ) :
                CustomDropDownButtonFormFieldTittle(
                  labelText: 'Grado de discapacidad',
                  source: _disabilityGradeSelection,
                  value: _disabilityGrade,
                  onChanged: _finished ? null : (value) {
                    _disabilityGrade = value;
                  },
                  validator: (value) =>
                  value != null ? null : StringConst.FORM_GENERIC_ERROR,
                ),
              childRight: _disabilityType == '' ?
                CustomDropDownButtonFormFieldTittle(
                  labelText: 'Tipo de discapacidad',
                  source: _disabilityTypeSelection,
                  onChanged: _finished ? null : (value) {
                    _disabilityType = value;
                  },
                  validator: (value) =>
                  value != null ? null : StringConst.FORM_GENERIC_ERROR,
                ) :
                CustomDropDownButtonFormFieldTittle(
                  labelText: 'Tipo de discapacidad',
                  source: _disabilityTypeSelection,
                  value: _disabilityType,
                  onChanged: _finished ? null : (value) {
                    _disabilityType = value;
                  },
                  validator: (value) =>
                  value != null ? null : StringConst.FORM_GENERIC_ERROR,
                ),
            ),

            //Subsection 2.3
            informSubSectionTitle('2.3 Dependencia'),
            CustomTextFormFieldTitle(
              labelText: 'Orientaciones',
              initialValue: _orientation2_3,
              onChanged: (value) {
                _orientation2_3 = value;
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: _dependenceState == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: 'Estado',
                source: _stateSelection,
                onChanged: _finished ? null : (value) {
                  _dependenceState = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              )
                  :
              CustomDropDownButtonFormFieldTittle(
                labelText: 'Estado',
                source: _stateSelection,
                value: _dependenceState,
                onChanged: _finished ? null : (value) {
                  _dependenceState = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              ),
              childRight: CustomTextFormFieldTitle(
                labelText: 'Profesional de referencia',
                initialValue: _referenceProfessionalDependence,
                onChanged: (value) {
                  _referenceProfessionalDependence = value;
                },
                validator: (value) =>
                (value!.isNotEmpty || value != '')
                    ? null
                    : StringConst.FORM_GENERIC_ERROR,
                enabled: !_finished,
              ),
            ),
            SpaceH12(),
            _dependenceGrade == '' ? CustomDropDownButtonFormFieldTittle(
              labelText: 'Grado de dependencia',
              source: _dependencyGradeSelection,
              onChanged: _finished ? null : (value) {
                _dependenceGrade = value;
              },
              validator: (value) =>
              value != null ? null : StringConst.FORM_GENERIC_ERROR,
            ) :
            CustomDropDownButtonFormFieldTittle(
              labelText: 'Grado de dependencia',
              source: _dependencyGradeSelection,
              value: _dependenceGrade,
              onChanged: _finished ? null : (value) {
                _dependenceGrade = value;
              },
              validator: (value) =>
              value != null ? null : StringConst.FORM_GENERIC_ERROR,
            ),

            //Subsection 2.4
            informSubSectionTitle('2.4 Adicciones'),
            CustomTextFormFieldTitle(
              labelText: 'Orientaciones',
              initialValue: _orientation2_4,
              onChanged: (value) {
                _orientation2_4 = value;
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: 'Derivación externa',
              initialValue: _externalDerivation,
              onChanged: (value) {
                _externalDerivation = value;
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),

            //Section 3
            informSectionTitle('3. Situación legal'),
            CustomTextFormFieldTitle(
              labelText: 'Orientaciones',
              initialValue: _orientation3,
              onChanged: (value) {
                _orientation3 = value;
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: _internalDerivationLegal == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: 'Derivación interna',
                source: _yesNoSelection,
                onChanged: _finished ? null : (value) {
                  _internalDerivationLegal = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              )
                  :
                CustomDropDownButtonFormFieldTittle(
                  labelText: 'Derivación interna',
                  source: _yesNoSelection,
                  value: _internalDerivationLegal,
                  onChanged: _finished ? null : (value) {
                    _internalDerivationLegal = value;
                  },
                  validator: (value) =>
                  value != null ? null : StringConst.FORM_GENERIC_ERROR,
                ),
              childRight: CustomTextFormFieldTitle(
                labelText: 'Derivación externa',
                initialValue: _externalDerivationLegal,
                onChanged: (value) {
                  _externalDerivationLegal = value;
                },
                validator: (value) =>
                (value!.isNotEmpty || value != '')
                    ? null
                    : StringConst.FORM_GENERIC_ERROR,
                enabled: !_finished,
              ),
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: 'Representación legal',
              hintText: 'De oficio, privada, datos de contacto',
              initialValue: _legalRepresentation,
              onChanged: (value) {
                _legalRepresentation = value;
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),

            //Section 4
            informSectionTitle('4. Situación alojativa'),
            CustomTextFormFieldTitle(
              labelText: 'Orientaciones',
              initialValue: _orientation4,
              onChanged: (value) {
                _orientation4 = value;
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: _ownershipType == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: 'Tipo de tenencia',
                source: _ownershipTypeSelection,
                onChanged: _finished ? null : (value) {
                  _ownershipType = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              )
                  :
              CustomDropDownButtonFormFieldTittle(
                labelText: 'Tipo de tenencia',
                source: _ownershipTypeSelection,
                value: _ownershipType,
                onChanged: _finished ? null : (value) {
                  _ownershipType = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              ),
              childRight: CustomTextFormFieldTitle(
                labelText: 'Ubicación actual de la persona',
                initialValue: _location,
                onChanged: (value) {
                  _location = value;
                },
                validator: (value) =>
                (value!.isNotEmpty || value != '')
                    ? null
                    : StringConst.FORM_GENERIC_ERROR,
                enabled: !_finished,
              ),
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: 'Datos de contacto del centro y persona de referencia',
              initialValue: _centerContact,
              onChanged: (value) {
                _centerContact = value;
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            Align(
                alignment: Alignment.center,
                child: CustomMultiSelectionRadioList(
                    options: _optionsSectionFour,
                    selections: _hostingObservations,
                    enabled: !_finished)),

            //Section 5
            informSectionTitle('5. Redes de apoyo'),
            CustomTextFormFieldTitle(
              labelText: 'Orientaciones',
              initialValue: _orientation5,
              onChanged: (value) {
                _orientation5 = value;
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: 'Redes de apoyo personales y familiares',
              initialValue: _informationNetworks,
              hintText: 'Asociación vecinal, grupo de facebook, whatsap, etc',
              onChanged: (value) {
                _informationNetworks = value;
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomFlexRowColumn(
              separatorSize: 20,
              contentPadding: EdgeInsets.zero,
              childLeft: CustomTextFormFieldTitle(
                labelText: 'Redes de apoyo institucionales',
                initialValue: _institutionNetworks,
                onChanged: (value) {
                  _institutionNetworks = value;
                },
                validator: (value) =>
                (value!.isNotEmpty || value != '')
                    ? null
                    : StringConst.FORM_GENERIC_ERROR,
                enabled: !_finished,
              ),
              childRight: CustomTextFormFieldTitle(
                labelText: 'Conciliación familiar',
                initialValue: _familyConciliation,
                onChanged: (value) {
                  _familyConciliation = value;
                },
                validator: (value) =>
                (value!.isNotEmpty || value != '')
                    ? null
                    : StringConst.FORM_GENERIC_ERROR,
                enabled: !_finished,
              ),
            ),

            //Section 7
            informSectionTitle('6. Idiomas'),
            CustomTextFormFieldTitle(
              labelText: 'Orientaciones',
              initialValue: _orientation7,
              onChanged: (value) {
                _orientation7 = value;
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            StreamBuilder<List<String>>(
                stream: database.languagesStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  final _languagesStream = snapshot.data;
                  final _languageOptions = _languagesStream!.map<
                      DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList();
                  return Column(
                    children: [
                      for(LanguageReport language in _languages!)
                      Column(
                        children: [
                          CustomFlexRowColumn(
                            contentPadding: EdgeInsets.zero,
                            separatorSize: 20,
                            childLeft: language.name == ''
                                ? CustomDropDownButtonFormFieldTittle(
                              labelText: 'Idioma',
                              source: _languageOptions,
                              onChanged: _finished ? null : (value) {
                                language.name = value!;
                              },
                              validator: (value) =>
                              value != null ? null : StringConst.FORM_GENERIC_ERROR,
                            )
                                :
                            CustomDropDownButtonFormFieldTittle(
                              labelText: 'Idioma',
                              value: language.name,
                              source: _languageOptions,
                              onChanged: _finished ? null : (value) {
                                language.name = value!;
                              },
                              validator: (value) =>
                              value != null ? null : StringConst.FORM_GENERIC_ERROR,
                            ),
                            childRight: CustomTextFormFieldTitle(
                              labelText: 'Reconocimiento / acreditación - nivel',
                              initialValue: language.level,
                              onChanged: (value) {
                                language.level = value;
                              },
                              validator: (value) =>
                              (value!.isNotEmpty || value != '')
                                  ? null
                                  : StringConst.FORM_GENERIC_ERROR,
                              enabled: !_finished,
                            ),
                          ),
                          SpaceH12(),
                        ],
                      ),
                    ],
                  );
                }
            ),
            addLanguageButton(),

            //Section 9
            informSectionTitle('7. Atención social integral'),
            CustomTextFormFieldTitle(
              labelText: 'Orientaciones',
              initialValue: _orientation9,
              onChanged: (value) {
                _orientation9 = value;
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: 'Centro y TS de referencia',
              initialValue: _centerTSReference,
              onChanged: (value) {
                _centerTSReference = value;
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: CustomTextFormFieldTitle(
                labelText: 'Destinataria de subvención y/o programa de apoyo',
                initialValue: _subsidyBeneficiary,
                onChanged: (value) {
                  _subsidyBeneficiary = value;
                },
                validator: (value) =>
                (value!.isNotEmpty || value != '')
                    ? null
                    : StringConst.FORM_GENERIC_ERROR,
                enabled: !_finished,
              ),
              childRight: _socialServicesUser == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: 'Usuaria',
                source: _yesNoSelection,
                onChanged: _finished ? null : (value) {
                  _socialServicesUser = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              )
                  :
              CustomDropDownButtonFormFieldTittle(
                labelText: 'Usuaria',
                source: _yesNoSelection,
                value: _socialServicesUser,
                onChanged: _finished ? null : (value) {
                  _socialServicesUser = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              ),
            ),
            SpaceH12(),
            _socialExclusionCertificate == ''
                ? CustomDropDownButtonFormFieldTittle(
              labelText: 'Certificado de Exclusión Social',
              source: _yesNoSelection,
              onChanged: _finished ? null : (value) {
                _socialExclusionCertificate = value;
              },
              validator: (value) =>
              value != null ? null : StringConst.FORM_GENERIC_ERROR,
            )
                :
            CustomDropDownButtonFormFieldTittle(
              labelText: 'Certificado de Exclusión Social',
              source: _yesNoSelection,
              value: _socialExclusionCertificate,
              onChanged: _finished ? null : (value) {
                _socialExclusionCertificate = value;
              },
              validator: (value) =>
              value != null ? null : StringConst.FORM_GENERIC_ERROR,
            ),

            //Section 12
            informSectionTitle('8. Situación de Vulnerabilidad'),
            CustomTextFormFieldTitle(
              labelText: 'Orientaciones',
              initialValue: _orientation12,
              onChanged: (value) {
                _orientation12 = value;
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomMultiSelectionRadioList(options: _optionsSectionTwelve,
                selections: _vulnerabilityOptions,
                enabled: !_finished),

            //Section 13
            informSectionTitle('9. Itinerario formativo laboral'),
            CustomTextFormFieldTitle(
              labelText: 'Orientaciones',
              initialValue: _orientation13,
              onChanged: (value) {
                _orientation13 = value;
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: _educationLevel == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: 'Nivel educativo',
                source: _educationalLevelSelection,
                onChanged: _finished ? null : (value) {
                  _educationLevel = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              )
                  :
              CustomDropDownButtonFormFieldTittle(
                labelText: 'Nivel educativo',
                source: _educationalLevelSelection,
                value: _educationLevel,
                onChanged: _finished ? null : (value) {
                  _educationLevel = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              ),
              childRight: _laborSituation == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: 'Situación laboral',
                source: _laborSituationSelection,
                onChanged: _finished ? null : (value) {
                  setStateLaborSituation(value!);
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              )
                  :
              CustomDropDownButtonFormFieldTittle(
                labelText: 'Situación laboral',
                source: _laborSituationSelection,
                value: _laborSituation,
                onChanged: _finished ? null : (value) {
                  setStateLaborSituation(value!);
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              ),
            ),

            SpaceH12(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: _laborSituation == 'Activa' ? Container(
                child: _activeLabor == ''
                    ? CustomDropDownButtonFormFieldTittle(
                  labelText: 'Activa',
                  source: _activeSelection,
                  onChanged: _finished ? null : (value) {
                    setStateActiveLabor(value!);
                  },
                  validator: (value) =>
                  value != null ? null : StringConst.FORM_GENERIC_ERROR,
                )
                    :
                CustomDropDownButtonFormFieldTittle(
                  labelText: 'Activa',
                  source: _activeSelection,
                  value: _activeLabor,
                  onChanged: _finished ? null : (value) {
                    setStateActiveLabor(value!);
                  },
                  validator: (value) =>
                  value != null ? null : StringConst.FORM_GENERIC_ERROR,
                ),
              ) : Container(),
              childRight: _activeLabor == 'Ocupada' ? Container(
                child: _occupiedLabor == ''
                    ? CustomDropDownButtonFormFieldTittle(
                  labelText: 'Ocupada',
                  source: _occupiedSelection,
                  onChanged: _finished ? null : (value) {
                    setStateOccupiedLabor(value!);
                  },
                  validator: (value) =>
                  value != null ? null : StringConst.FORM_GENERIC_ERROR,
                )
                    :
                CustomDropDownButtonFormFieldTittle(
                  labelText: 'Ocupada',
                  source: _occupiedSelection,
                  value: _occupiedLabor,
                  onChanged: _finished ? null : (value) {
                    setStateOccupiedLabor(value!);
                  },
                  validator: (value) =>
                  value != null ? null : StringConst.FORM_GENERIC_ERROR,
                ),
              ) : Container(),
            ),

            SpaceH12(),
            _occupiedLabor == 'Cuenta ajena' ? CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: _tempLabor == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: 'Temporalidad',
                source: _tempSelection,
                onChanged: _finished ? null : (value) {
                  _tempLabor = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              )
                  :
              CustomDropDownButtonFormFieldTittle(
                labelText: 'Temporalidad',
                source: _tempSelection,
                value: _tempLabor,
                onChanged: _finished ? null : (value) {
                  _tempLabor = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              ),
              childRight: _workingDayLabor == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: 'Jornada laboral',
                source: _workDaySelection,
                onChanged: _finished ? null : (value) {
                  _workingDayLabor = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              )
                  :
              CustomDropDownButtonFormFieldTittle(
                labelText: 'Jornada laboral',
                source: _workDaySelection,
                value: _workingDayLabor,
                onChanged: _finished ? null : (value) {
                  _workingDayLabor = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              ),
            ) : Container(),

            informSubSectionTitle('9.2 Trayectoria B.A.E previa'),
            CustomTextFormFieldTitle(
              labelText: 'Competencias (competencias específicas, competencias prelaborales y competencias digitales)',
              initialValue: _competencies,
              onChanged: (value) {
                _competencies = value ?? '';
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: 'Contextualización del territorio',
              initialValue: _contextualization,
              onChanged: (value) {
                _contextualization = value ?? '';
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: 'Conexión del entorno',
              initialValue: _connexion,
              onChanged: (value) {
                _connexion = value ?? '';
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),

            informSubSectionTitle('9.3 Deseos y expectativas laborales'),
            CustomTextFormFieldTitle(
              labelText: 'Corto plazo',
              initialValue: _shortTerm,
              onChanged: (value) {
                _shortTerm = value ?? '';
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: 'Medio plazo',
              initialValue: _mediumTerm,
              onChanged: (value) {
                _mediumTerm = value ?? '';
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: 'Largo plazo',
              initialValue: _longTerm,
              onChanged: (value) {
                _longTerm = value ?? '';
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),


            _finished ? Container() : Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 30),
              child: Center(
                child: Container(
                  height: 50,
                  width: 250,
                  child: ElevatedButton(
                      onPressed: () async {
                        database.setInitialReport(
                            InitialReport(
                              userId: report.userId,
                              initialReportId: report.initialReportId,
                              subsidy: _subsidy,
                              orientation1: _orientation1,
                              arriveDate: _arriveDate,
                              receptionResources: _receptionResources,
                              administrativeSituation: _administrativeSituation,
                              expirationDate: _expirationDate,
                              orientation2: _orientation2,
                              healthCard: _healthCard,
                              medication: _medication,
                              orientation2_1: _orientation2_1,
                              rest: _rest,
                              diagnosis: _diagnosis,
                              treatment: _treatment,
                              tracking: _tracking,
                              psychosocial: _psychosocial,
                              orientation2_2: _orientation2_2,
                              disabilityState: _disabilityState,
                              referenceProfessionalDisability: _referenceProfessionalDisability,
                              disabilityGrade: _disabilityGrade,
                              disabilityType: _disabilityType,
                              granted: _granted,
                              revisionDate: _revisionDate,
                              orientation2_3: _orientation2_3,
                              dependenceState: _dependenceState,
                              referenceProfessionalDependence: _referenceProfessionalDependence,
                              dependenceGrade: _dependenceGrade,
                              orientation2_4: _orientation2_4,
                              externalDerivation: _externalDerivation,
                              orientation3: _orientation3,
                              internalDerivationLegal: _internalDerivationLegal,
                              externalDerivationLegal: _externalDerivationLegal,
                              legalRepresentation: _legalRepresentation,
                              orientation4: _orientation4,
                              ownershipType: _ownershipType,
                              location: _location,
                              centerContact: _centerContact,
                              hostingObservations: _hostingObservations,
                              orientation5: _orientation5,
                              informationNetworks: _informationNetworks,
                              institutionNetworks: _institutionNetworks,
                              familyConciliation: _familyConciliation,
                              orientation7: _orientation7,
                              languages: _languages,
                              orientation9: _orientation9,
                              centerTSReference: _centerTSReference,
                              subsidyBeneficiary: _subsidyBeneficiary,
                              socialServicesUser: _socialServicesUser,
                              socialExclusionCertificate: _socialExclusionCertificate,
                              orientation12: _orientation12,
                              vulnerabilityOptions: _vulnerabilityOptions,
                              orientation13: _orientation13,
                              educationLevel: _educationLevel,
                              laborSituation: _laborSituation,
                              activeLabor: _activeLabor,
                              occupiedLabor: _occupiedLabor,
                              tempLabor: _tempLabor,
                              workingDayLabor: _workingDayLabor,
                              competencies: _competencies,
                              contextualization: _contextualization,
                              connexion: _connexion,
                              shortTerm: _shortTerm,
                              mediumTerm: _mediumTerm,
                              longTerm: _longTerm,
                              finished: false,
                            )
                        );
                        showDialog(
                            context: context,
                            builder: (context) =>
                                AlertDialog(
                                    title: Text('Se ha guardado con exito',
                                        style: TextStyle(
                                          color: AppColors.greyDark,
                                          height: 1.5,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        )),
                                    actions: <Widget>[
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            setStateMenuPage();
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('Ok',
                                                style: TextStyle(
                                                    color: AppColors.black,
                                                    height: 1.5,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14)),
                                          )),
                                    ]
                                )
                        );
                      },
                      child: Text(
                        'Guardar y seguir más tarde',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.turquoiseButton,
                        shadowColor: Colors.transparent,
                      )
                  ),
                ),
              ),
            ),

            _finished ? Container() : Center(
              child: Container(
                height: 50,
                width: 160,
                child: ElevatedButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                AlertDialog(
                                  title: Text('Aún quedan campos por completar',
                                      style: TextStyle(
                                        color: AppColors.greyDark,
                                        height: 1.5,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      )),
                                  actions: <Widget>[
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('Ok',
                                              style: TextStyle(
                                                  color: AppColors.black,
                                                  height: 1.5,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14)),
                                        )),
                                  ],
                                )
                        );
                        return;
                      }
                      showDialog(
                          context: context,
                          builder: (context) =>
                              AlertDialog(
                                  title: Text(
                                      '¿Está seguro de que desea finalizar el informe inicial? \nNo podra volver a modifiar ningun campo',
                                      style: TextStyle(
                                        color: AppColors.greyDark,
                                        height: 1.5,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      )),
                                  actions: <Widget>[
                                    ElevatedButton(
                                        onPressed: () async {
                                          database.setInitialReport(
                                              InitialReport(
                                                userId: report.userId,
                                                initialReportId: report
                                                    .initialReportId,
                                                subsidy: _subsidy,
                                                orientation1: _orientation1,
                                                arriveDate: _arriveDate,
                                                receptionResources: _receptionResources,
                                                administrativeSituation: _administrativeSituation,
                                                expirationDate: _expirationDate,
                                                orientation2: _orientation2,
                                                healthCard: _healthCard,
                                                medication: _medication,
                                                orientation2_1: _orientation2_1,
                                                rest: _rest,
                                                diagnosis: _diagnosis,
                                                treatment: _treatment,
                                                tracking: _tracking,
                                                psychosocial: _psychosocial,
                                                orientation2_2: _orientation2_2,
                                                disabilityState: _disabilityState,
                                                referenceProfessionalDisability: _referenceProfessionalDisability,
                                                disabilityGrade: _disabilityGrade,
                                                disabilityType: _disabilityType,
                                                granted: _granted,
                                                revisionDate: _revisionDate,
                                                orientation2_3: _orientation2_3,
                                                dependenceState: _dependenceState,
                                                referenceProfessionalDependence: _referenceProfessionalDependence,
                                                dependenceGrade: _dependenceGrade,
                                                orientation2_4: _orientation2_4,
                                                externalDerivation: _externalDerivation,
                                                orientation3: _orientation3,
                                                internalDerivationLegal: _internalDerivationLegal,
                                                externalDerivationLegal: _externalDerivationLegal,
                                                legalRepresentation: _legalRepresentation,
                                                orientation4: _orientation4,
                                                ownershipType: _ownershipType,
                                                location: _location,
                                                centerContact: _centerContact,
                                                hostingObservations: _hostingObservations,
                                                orientation5: _orientation5,
                                                informationNetworks: _informationNetworks,
                                                institutionNetworks: _institutionNetworks,
                                                familyConciliation: _familyConciliation,
                                                orientation7: _orientation7,
                                                languages: _languages,
                                                orientation9: _orientation9,
                                                centerTSReference: _centerTSReference,
                                                subsidyBeneficiary: _subsidyBeneficiary,
                                                socialServicesUser: _socialServicesUser,
                                                socialExclusionCertificate: _socialExclusionCertificate,
                                                orientation12: _orientation12,
                                                vulnerabilityOptions: _vulnerabilityOptions,
                                                orientation13: _orientation13,
                                                educationLevel: _educationLevel,
                                                laborSituation: _laborSituation,
                                                activeLabor: _activeLabor,
                                                occupiedLabor: _occupiedLabor,
                                                tempLabor: _tempLabor,
                                                workingDayLabor: _workingDayLabor,
                                                competencies: _competencies,
                                                contextualization: _contextualization,
                                                connexion: _connexion,
                                                shortTerm: _shortTerm,
                                                mediumTerm: _mediumTerm,
                                                longTerm: _longTerm,
                                                finished: true,
                                                completedDate: DateTime.now(),
                                              )
                                          );
                                          Navigator.of(context).pop();
                                          setStateMenuPage();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('Si',
                                              style: TextStyle(
                                                  color: AppColors.black,
                                                  height: 1.5,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14)),
                                        )),
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('No',
                                              style: TextStyle(
                                                  color: AppColors.black,
                                                  height: 1.5,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14)),
                                        )),
                                  ]
                              )
                      );
                    },
                    child: Text(
                      'Finalizar',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.turquoiseButton,
                      shadowColor: Colors.transparent,
                    )
                ),
              ),
            ),


            SpaceH40(),


          ],
        ),
      ),
    );
  }
}