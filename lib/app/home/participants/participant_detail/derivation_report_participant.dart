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
import 'package:enreda_empresas/app/models/derivationReport.dart';
import 'package:enreda_empresas/app/models/formationReport.dart';
import 'package:enreda_empresas/app/models/languageReport.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/auth.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DerivationReportForm extends StatefulWidget {
  const DerivationReportForm({super.key, required this.user, this.derivationReport});

  final UserEnreda user;
  final DerivationReport? derivationReport;

  @override
  State<DerivationReportForm> createState() => _DerivationReportFormState();
}

class _DerivationReportFormState extends State<DerivationReportForm> {

  late Widget currentPage;
  final ValueNotifier<String> _techNameNotifier =
  ValueNotifier<String>('');
  final ValueNotifier<String> _disabilityStateNotifier =
  ValueNotifier<String>('');
  final ValueNotifier<String> _grantedNotifier =
  ValueNotifier<String>('');
  final ValueNotifier<List<LanguageReport>> _languagesNotifier =
  ValueNotifier<List<LanguageReport>>([LanguageReport(name: '', level: '')]);
  final ValueNotifier<String> _laborSituationNotifier =
  ValueNotifier<String>('');
  final ValueNotifier<String> _adminStateNotifier =
  ValueNotifier<String>('');
  final ValueNotifier<String> _adminTempNotifier =
  ValueNotifier<String>('');
  final ValueNotifier<String> _adminJuridicFigureNotifier =
  ValueNotifier<String>('');
  final ValueNotifier<String> _ownershipTypeNotifier =
  ValueNotifier<String>('');
  final ValueNotifier<String> _ownershipTypeConcreteNotifier =
  ValueNotifier<String>('');
  final ValueNotifier<String> _homelessnessSituationNotifier =
  ValueNotifier<String>('');
  final ValueNotifier<String> _subsidyBeneficiaryNotifier =
  ValueNotifier<String>('');
  final ValueNotifier<String> _socialExclusionCertificateNotifier =
  ValueNotifier<String>('');
  final ValueNotifier<List<FormationReport>> _formationsNotifier =
  ValueNotifier<List<FormationReport>>([FormationReport(name: '', type: '', certification: '')]);
  final ValueNotifier<String> _postLaborAccompanimentNotifier =
  ValueNotifier<String>('');
  final ValueNotifier<int> _totalDaysNotifier =
  ValueNotifier<int>(0);

  final ValueNotifier<bool> _allow1Notifier =
  ValueNotifier<bool>(true);
  final ValueNotifier<bool> _allow1_1Notifier =
  ValueNotifier<bool>(true);
  final ValueNotifier<bool> _allow2Notifier =
  ValueNotifier<bool>(true);
  final ValueNotifier<bool> _allow2_1Notifier =
  ValueNotifier<bool>(true);
  final ValueNotifier<bool> _allow2_2Notifier =
  ValueNotifier<bool>(true);
  final ValueNotifier<bool> _allow2_3Notifier =
  ValueNotifier<bool>(true);
  final ValueNotifier<bool> _allow2_4Notifier =
  ValueNotifier<bool>(true);
  final ValueNotifier<bool> _allow3Notifier =
  ValueNotifier<bool>(true);
  final ValueNotifier<bool> _allow4Notifier =
  ValueNotifier<bool>(true);
  final ValueNotifier<bool> _allow5Notifier =
  ValueNotifier<bool>(true);
  final ValueNotifier<bool> _allow6Notifier =
  ValueNotifier<bool>(true);
  final ValueNotifier<bool> _allow7Notifier =
  ValueNotifier<bool>(true);
  final ValueNotifier<bool> _allow8Notifier =
  ValueNotifier<bool>(true);
  final ValueNotifier<bool> _allow9Notifier =
  ValueNotifier<bool>(true);
  final ValueNotifier<bool> _allow9_2Notifier =
  ValueNotifier<bool>(true);
  final ValueNotifier<bool> _allow9_3Notifier =
  ValueNotifier<bool>(true);
  final ValueNotifier<bool> _allow9_4Notifier =
  ValueNotifier<bool>(true);
  final ValueNotifier<bool> _allow9_5Notifier =
  ValueNotifier<bool>(true);
  final ValueNotifier<bool> _allow9_6Notifier =
  ValueNotifier<bool>(true);

  final TextEditingController _techPersonController = TextEditingController();
  final TextEditingController _totalDaysController = TextEditingController();

  @override
  void initState() {
    currentPage = derivationReport(context, widget.user);
    _totalDaysController.text = '0';
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

  void _addLanguage(){
    final newLanguages = List<LanguageReport>.from(_languagesNotifier.value)..add(LanguageReport(name: '', level: ''));
    _languagesNotifier.value = newLanguages;
  }

  void _addFormation(){
    final newFormations = List<FormationReport>.from(_formationsNotifier.value)..add(FormationReport(name: '', type: '', certification: ''));
    _formationsNotifier.value = newFormations;
  }


  Widget derivationReport(BuildContext context, UserEnreda user) {
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
                    children: [
                      IconButton(
                        onPressed: setStateMenuPage,
                        icon: Icon(Icons.arrow_back_rounded),
                        iconSize: 30,
                        color: AppColors.turquoiseBlue,
                      ),
                      SpaceW8(),
                      CustomTextBoldTitle(
                          title: 'Informe de derivación'.toUpperCase()),
                    ],
                  ),
                ),
                Divider(color: AppColors.greyBorder,),
                StreamBuilder<DerivationReport>(
                    stream: database.derivationReportsStreamByUserId(user.userId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        DerivationReport derivationReportSaved = snapshot.data!;
                        return completeDerivationForm(context, derivationReportSaved);
                      }
                      else {
                        if (user.derivationReportId == null) {
                          database.addDerivationReport(widget.derivationReport!);
                        }
                        return Container(
                          height: 300,
                        );
                      }
                    }
                ),
              ]
          ),
        )
    );
  }

  Widget informSectionTitle(String title, bool showSection, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 15),
      child: Row(
        children: [
          Text(
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
          SpaceW8(),
          IconButton(
            icon: showSection ? Image.asset(
              ImagePath.PERSONAL_DOCUMENTATION_VIEW,
              width: 24,
              height: 24,
            ) : Image.asset(
              ImagePath.PERSONAL_DOCUMENTATION_NOT_VIEW,
              width: 24,
              height: 24,
            ),
            onPressed: (){
              if(showSection){
                var snackBar = SnackBar(content: Text('No se mostrará la sección: $title'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
              else if (!showSection){
                var snackBar = SnackBar(content: Text('Se mostrará la sección: $title'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
              onTap();
            },
          ),
        ],
      ),
    );
  }

  Widget informSubSectionTitle(String title, bool showSection, bool showSubSection, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 15),
      child: Row(
        children: [
          Text(
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
          SpaceW8(),
          showSection ? IconButton(
            icon: showSubSection ? Image.asset(
              ImagePath.PERSONAL_DOCUMENTATION_VIEW,
              width: 24,
              height: 24,
            ) : Image.asset(
              ImagePath.PERSONAL_DOCUMENTATION_NOT_VIEW,
              width: 24,
              height: 24,
            ),
            onPressed: (){
              if(showSubSection){
                var snackBar = SnackBar(content: Text('No se mostrará la sección: $title'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
              else if (!showSubSection){
                var snackBar = SnackBar(content: Text('Se mostrará la sección: $title'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
              onTap();
            },
          ) : Container(),
        ],
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
          _addLanguage();
        }
    );
  }

  Widget addFormationButton(){
    return InkWell(
        child: Row(
          children: [
            Icon(
              Icons.add_circle_outline,
              color: AppColors.turquoiseBlue,
            ),
            SpaceW8(),
            Text(
              'Añadir formación',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.turquoiseBlue,
              ),
            ),
          ],
        ),
        onTap: (){
          _addFormation();
        }
    );
  }

  Widget completeDerivationForm(BuildContext context, DerivationReport report) {
    final database = Provider.of<Database>(context, listen: false);
    final _formKey = GlobalKey<FormState>();

    bool _finished = report.finished ?? false;

    //Pre-Selection
    String? _subsidy = report.subsidy ?? '';
    String? _techPerson = report.techPerson ?? widget.user.assignedById;
    String? _addressedTo = report.addressedTo ?? '';
    String? _objectiveDerivation = report.objectiveDerivation ?? '';
    bool? _fromInitialReport = report.fromInitialReport ?? true;

    //Section 1
    String _orientation1 = report.orientation1 ?? '';
    DateTime? _arriveDate = report.arriveDate;
    String _receptionResources = report.receptionResources ?? '';
    String _administrativeExternalResources = report.administrativeExternalResources ?? '';


    //Section 1.1
    if (_adminStateNotifier.value == '' &&
        report.adminState != null) {
      _adminStateNotifier.value = report.adminState!;
    }
    String? _adminNoThrough = report.adminNoThrough ?? '';
    DateTime? _adminDateAsk = report.adminDateAsk;
    DateTime? _adminDateResolution = report.adminDateResolution;
    DateTime? _adminDateConcession = report.adminDateConcession;
    if (_adminTempNotifier.value == '' &&
        report.adminTemp != null) {
      _adminTempNotifier.value = report.adminTemp!;
    }
    if (_adminJuridicFigureNotifier.value == '' &&
        report.adminJuridicFigure != null) {
      _adminJuridicFigureNotifier.value = report.adminJuridicFigure!;
    }
    String? _adminResidenceWork = report.adminResidenceWork ?? '';
    DateTime? _adminDateRenovation = report.adminDateRenovation;
    String? _adminResidenceType = report.adminResidenceType ?? '';
    String? _adminOther = report.adminOther ?? '';

    //Section 2
    DateTime? _expirationDate = report.expirationDate;
    String? _orientation2 = report.orientation2 ?? '';
    String? _healthCard = report.healthCard ?? '';
    String? _medication = report.medication ?? '';

    //Subsection 2.1
    String? _orientation2_1 = report.orientation2_1 ?? '';
    String? _rest = report.rest ?? '';
    String? _diagnosis = report.diagnosis ?? '';
    String? _treatment = report.treatment ?? '';
    String? _tracking = report.tracking ?? '';

    //Subsection 2.2
    String? _orientation2_2 = report.orientation2_2 ?? '';
    if (_disabilityStateNotifier.value == '' &&
        report.disabilityState != null) {
      _disabilityStateNotifier.value = report.disabilityState!;
    }
    String? _referenceProfessionalDisability =
        report.referenceProfessionalDisability ?? '';
    String? _disabilityGrade = report.disabilityGrade ?? '';
    if (_grantedNotifier.value == '' &&
        report.granted != null) {
      _grantedNotifier.value = report.granted!;
    }
    DateTime? _revisionDate = report.revisionDate;
    String? _disabilityType = report.disabilityType ?? '';

    //Subsection 2.3
    String? _orientation2_3 = report.orientation2_3 ?? '';
    String? _dependenceState = report.dependenceState ?? '';
    String? _referenceProfessionalDependence =
        report.referenceProfessionalDependence ?? '';
    String? _dependenceGrade = report.dependenceGrade ?? '';


    //Subsection 2.4
    String? _orientation2_4 = report.orientation2_4 ?? '';
    String? _externalDerivation = report.externalDerivation ?? '';
    String? _motive = report.motive ?? '';

    //Section 3
    String? _orientation3 = report.orientation3 ?? '';
    String? _internalDerivationLegal = report.internalDerivationLegal ?? '';
    DateTime?  _internalDerivationDate = report.internalDerivationDate;
    String? _internalDerivationMotive = report.internalDerivationMotive ?? '';
    String? _externalDerivationLegal = report.externalDerivationLegal ?? '';
    DateTime? _externalDerivationDate = report.externalDerivationDate;
    String? _externalDerivationMotive = report.externalDerivationMotive ?? '';
    String? _psychosocialDerivationLegal = report.psychosocialDerivationLegal ?? '';
    DateTime? _psychosocialDerivationDate = report.psychosocialDerivationDate;
    String? _psychosocialDerivationMotive = report.psychosocialDerivationMotive ?? '';
    String? _legalRepresentation = report.legalRepresentation ?? '';
    String? _processingBag = report.processingBag ?? '';
    DateTime? _processingBagDate = report.processingBagDate;
    String? _economicAmount = report.economicAmount ?? '';

    //Section 4
    String? _orientation4 = report.orientation4 ?? '';
    if (_ownershipTypeNotifier.value == '' &&
        report.ownershipType != null) {
      _ownershipTypeNotifier.value = report.ownershipType!;
    }
    if (_ownershipTypeConcreteNotifier.value == '' &&
        report.ownershipTypeConcrete != null) {
      _ownershipTypeConcreteNotifier.value = report.ownershipTypeConcrete!;
    }
    if (_homelessnessSituationNotifier.value == '' &&
        report.homelessnessSituation != null) {
      _homelessnessSituationNotifier.value = report.homelessnessSituation!;
    }
    String? _ownershipTypeOpen = report.ownershipTypeOpen ?? '';
    String? _homelessnessSituationOpen = report.homelessnessSituationOpen ?? '';
    String? _livingUnit = report.livingUnit ?? '';


    String? _location = report.location ?? '';
    String? _centerContact = report.centerContact ?? '';
    List<String>? _hostingObservations = report.hostingObservations ?? [];
    //Section 5
    String? _orientation5 = report.orientation5 ?? '';
    String? _informationNetworks = report.informationNetworks ?? '';
    String? _institutionNetworks = report.institutionNetworks ?? '';
    String? _familyConciliation = report.familyConciliation ?? '';

    //Section 7
    String? _orientation7 = report.orientation7 ?? '';
    if(report.languages != null){
      _languagesNotifier.value = report.languages!;
    }

    //Section 9
    if (_subsidyBeneficiaryNotifier.value == '' &&
        report.subsidyBeneficiary != null) {
      _subsidyBeneficiaryNotifier.value = report.subsidyBeneficiary!;
    }
    if (_socialExclusionCertificateNotifier.value == '' &&
        report.socialExclusionCertificate != null) {
      _socialExclusionCertificateNotifier.value = report.socialExclusionCertificate!;
    }
    String? _subsidyName = report.subsidyName ?? '';
    DateTime? _socialExclusionCertificateDate = report.socialExclusionCertificateDate;
    String? _socialExclusionCertificateObservations = report.socialExclusionCertificateObservations ?? '';
    String? _orientation9 = report.orientation9 ?? '';
    String? _centerTSReference = report.centerTSReference ?? '';


    //Section 12
    String? _orientation12 = report.orientation12 ?? '';
    List<String>? _vulnerabilityOptions = report.vulnerabilityOptions ?? [];



    //Section 13
    String? _orientation13 = report.orientation13 ?? '';
    String? _orientation13_2 = report.orientation13_2 ?? '';
    String? _educationLevel = report.educationLevel ?? '';
    if (_laborSituationNotifier.value == '' &&
        report.laborSituation != null) {
      _laborSituationNotifier.value = report.laborSituation!;
    }
    String? _tempLabor = report.tempLabor ?? '';
    String? _workingDayLabor = report.workingDayLabor ?? '';
    String? _competencies = report.competencies ?? '';
    String? _contextualization = report.contextualization ?? '';
    String? _connexion = report.connexion ?? '';
    String? _shortTerm = report.shortTerm ?? '';
    String? _mediumTerm = report.mediumTerm ?? '';
    String? _longTerm = report.longTerm ?? '';

    //Section 9.5
    String? _orientation9_5 = report.orientation9_5 ?? '';
    if(report.formations != null){
      _formationsNotifier.value = report.formations!;
    }
    String? _formationBag = report.formationBag ?? '';
    DateTime? _formationBagDate = report.formationBagDate;
    String? _formationBagMotive = report.formationBagMotive ?? '';
    String? _formationBagEconomic = report.formationBagEconomic ?? '';
    String? _jobObtaining = report.jobObtaining ?? '';
    DateTime? _jobObtainDate = report.jobObtainDate;
    DateTime? _jobFinishDate = report.jobFinishDate;
    String? _jobUpgrade = report.jobUpgrade ?? '';
    String? _upgradeMotive = report.upgradeMotive ?? '';
    DateTime? _upgradeDate = report.upgradeDate;
    String? _orientation9_6 = report.orientation9_6 ?? '';
    if (_postLaborAccompanimentNotifier.value == '' &&
        report.postLaborAccompaniment != null) {
      _postLaborAccompanimentNotifier.value = report.postLaborAccompaniment!;
    }
    String? _postLaborAccompanimentMotive = report.postLaborAccompanimentMotive ?? '';
    DateTime? _postLaborInitialDate = report.postLaborInitialDate;
    DateTime? _postLaborFinalDate = report.postLaborFinalDate;
    if (_totalDaysNotifier.value == 0 &&
        report.postLaborTotalDays != null) {
      _totalDaysNotifier.value = report.postLaborTotalDays!;
      _totalDaysController.text = report.postLaborTotalDays!.toString();
    }
    String? _jobMaintenance = report.jobMaintenance ?? '';

    //Allow see
    if (_allow1Notifier.value == true &&
        report.allow1 != null) {
      _allow1Notifier.value = report.allow1!;
    }
    if (_allow1_1Notifier.value == true &&
        report.allow1_1 != null) {
      _allow1_1Notifier.value = report.allow1_1!;
    }
    if (_allow2Notifier.value == true &&
        report.allow2 != null) {
      _allow2Notifier.value = report.allow2!;
    }
    if (_allow2_1Notifier.value == true &&
        report.allow2_1 != null) {
      _allow2_1Notifier.value = report.allow2_1!;
    }
    if (_allow2_2Notifier.value == true &&
        report.allow2_2 != null) {
      _allow2_2Notifier.value = report.allow2_2!;
    }
    if (_allow2_3Notifier.value == true &&
        report.allow2_3 != null) {
      _allow2_3Notifier.value = report.allow2_3!;
    }
    if (_allow2_4Notifier.value == true &&
        report.allow2_4 != null) {
      _allow2_4Notifier.value = report.allow2_4!;
    }
    if (_allow3Notifier.value == true &&
        report.allow3 != null) {
      _allow3Notifier.value = report.allow3!;
    }
    if (_allow4Notifier.value == true &&
        report.allow4 != null) {
      _allow4Notifier.value = report.allow4!;
    }
    if (_allow5Notifier.value == true &&
        report.allow5 != null) {
      _allow5Notifier.value = report.allow5!;
    }
    if (_allow6Notifier.value == true &&
        report.allow6 != null) {
      _allow6Notifier.value = report.allow6!;
    }
    if (_allow7Notifier.value == true &&
        report.allow7 != null) {
      _allow7Notifier.value = report.allow7!;
    }
    if (_allow8Notifier.value == true &&
        report.allow8 != null) {
      _allow8Notifier.value = report.allow8!;
    }
    if (_allow9Notifier.value == true &&
        report.allow9 != null) {
      _allow9Notifier.value = report.allow9!;
    }
    if (_allow9_2Notifier.value == true &&
        report.allow9_2 != null) {
      _allow9_2Notifier.value = report.allow9_2!;
    }
    if (_allow9_3Notifier.value == true &&
        report.allow9_3 != null) {
      _allow9_3Notifier.value = report.allow9_3!;
    }
    if (_allow9_4Notifier.value == true &&
        report.allow9_4 != null) {
      _allow9_4Notifier.value = report.allow9_4!;
    }
    if (_allow9_5Notifier.value == true &&
        report.allow9_5 != null) {
      _allow9_5Notifier.value = report.allow9_5!;
    }
    if (_allow9_6Notifier.value == true &&
        report.allow9_6 != null) {
      _allow9_6Notifier.value = report.allow9_6!;
    }


    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 30),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SpaceH20(),
            _subsidy == ''
                ? CustomDropDownButtonFormFieldTittle(
              labelText:
              StringConst.INITIAL_SUBSIDY,
              source: StringConst.SUBSIDY_SELECTION,
              onChanged: _finished
                  ? null
                  : (value) {
                _subsidy = value;
              },
              validator: (value) =>
              value != null ? null : StringConst.FORM_GENERIC_ERROR,
            )
                : CustomDropDownButtonFormFieldTittle(
              labelText:
              StringConst.INITIAL_SUBSIDY,
              source: StringConst.SUBSIDY_SELECTION,
              value: _subsidy,
              onChanged: _finished
                  ? null
                  : (value) {
                _subsidy = value;
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.DERIVATION_ADDRESSED,
              initialValue: _addressedTo,
              onChanged: (value) {
                _addressedTo = value ?? '';
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.DERIVATION_OBJECTIVE,
              initialValue: _objectiveDerivation,
              onChanged: (value) {
                _objectiveDerivation = value ?? '';
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),

            StreamBuilder<UserEnreda>(
                stream: database.userEnredaStreamByUserId(_techPerson),
                builder: (context, snapshot) {

                  if(snapshot.hasData && snapshot.connectionState != ConnectionState.waiting){

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _techPersonController.text = '${snapshot.data?.firstName}' + ' ' + '${snapshot.data?.lastName}';
                    });
                  }
                  return CustomTextFormFieldTitle(
                    labelText: StringConst.INITIAL_TECH_PERSON,
                    controller: _techPersonController,
                    enabled: false,
                  );
                }
            ),

            //Section 1
            ValueListenableBuilder(
              valueListenable: _allow1Notifier,
              builder: (context, value, child){
                return informSectionTitle(StringConst.INITIAL_TITLE1_ITINERARY, _allow1Notifier.value, (){_allow1Notifier.value = !_allow1Notifier.value;});
              }
            ),

            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              initialValue: _orientation1,
              onChanged: (value) {
                _orientation1 = value ?? '';
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: CustomDatePickerTitle(
                labelText: StringConst.INITIAL_ARRIVE_DATE,
                initialValue: _arriveDate,
                onChanged: (value) {
                  _arriveDate = value;
                },
                enabled: !_finished,
                validator: (value) =>
                (value != null) ? null : StringConst.FORM_GENERIC_ERROR,
              ),
              childRight: CustomTextFormFieldTitle(
                labelText: StringConst.INITIAL_RECEPTION_RESOURCES,
                initialValue: _receptionResources,
                onChanged: (value) {
                  _receptionResources = value ?? '';
                },
                validator: (value) => (value!.isNotEmpty || value != '')
                    ? null
                    : StringConst.FORM_GENERIC_ERROR,
                enabled: !_finished,
              ),
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_EXTERNAL_RESOURCES,
              initialValue: _administrativeExternalResources,
              onChanged: (value) {
                _administrativeExternalResources = value ?? '';
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),

            //Section 1.1
            ValueListenableBuilder(
                valueListenable: _allow1Notifier,
                builder: (context, value, child){
                  return             ValueListenableBuilder(
                      valueListenable: _allow1_1Notifier,
                      builder: (context, value, child){
                        return informSubSectionTitle(StringConst.INITIAL_TITLE_1_1_ADMINISTRATIVE_SITUATION, _allow1Notifier.value, _allow1_1Notifier.value, (){_allow1_1Notifier.value = !_allow1_1Notifier.value;});
                      }
                  );
                }
            ),

            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: _adminStateNotifier.value == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText:
                StringConst.INITIAL_STATE,
                source: StringConst.ADMIN_STATE_SELECTION,
                onChanged: _finished
                    ? null
                    : (value) {
                  _adminStateNotifier.value = value!;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              )
                  : CustomDropDownButtonFormFieldTittle(
                labelText:
                StringConst.INITIAL_STATE,
                source: StringConst.ADMIN_STATE_SELECTION,
                value: _adminStateNotifier.value,
                onChanged: _finished
                    ? null
                    : (value) {
                  _adminStateNotifier.value = value!;
                },
                validator: (value) => (value!.isNotEmpty || value != '')
                    ? null
                    : StringConst.FORM_GENERIC_ERROR,
              ),
              childRight: ValueListenableBuilder(
                  valueListenable: _adminStateNotifier,
                  builder: (context, value, child){
                    return _adminStateNotifier.value == 'Sin tramitar' ?
                    CustomTextFormFieldTitle(
                      labelText: 'Sin tramitar',
                      initialValue: _adminNoThrough,
                      onChanged: (value) {
                        _adminNoThrough = value;
                      },
                      validator: (value) => (value!.isNotEmpty || value != '')
                          ? null
                          : StringConst.FORM_GENERIC_ERROR,
                      enabled: !_finished,
                    ) : //Open Field
                    _adminStateNotifier.value == 'Concedida' ?
                    CustomDatePickerTitle(
                      labelText: StringConst.INITIAL_DATE_CONCESSION,
                      initialValue: _adminDateConcession,
                      onChanged: (value) {
                        _adminDateConcession = value;
                      },
                      enabled: !_finished,
                      validator: (value) => (value != null)
                          ? null
                          : StringConst.FORM_GENERIC_ERROR,
                    ) : //Fecha concesion
                    Container();
                  }
              ),
            ),
            ValueListenableBuilder(
                valueListenable: _adminStateNotifier,
                builder: (context, value, child){
                  return _adminStateNotifier.value == 'En trámite' ?
                  Column(
                    children: [
                      SpaceH12(),
                      CustomFlexRowColumn(
                        contentPadding: EdgeInsets.zero,
                        separatorSize: 20,
                        childLeft: CustomDatePickerTitle(
                          labelText: StringConst.INITIAL_DATE_ASK,
                          initialValue: _adminDateAsk,
                          onChanged: (value) {
                            _adminDateAsk = value;
                          },
                          enabled: !_finished,
                          validator: (value) => (value != null)
                              ? null
                              : StringConst.FORM_GENERIC_ERROR,
                        ),
                        childRight: CustomDatePickerTitle(
                          labelText: StringConst.INITIAL_DATE_RESOLUTION,
                          initialValue: _adminDateResolution,
                          onChanged: (value) {
                            _adminDateResolution = value;
                          },
                          enabled: !_finished,
                          validator: (value) => (value != null)
                              ? null
                              : StringConst.FORM_GENERIC_ERROR,
                        ),
                      ),
                    ],
                  ) : Container();
                }
            ),
            SpaceH12(),
            CustomFlexRowColumn(
                contentPadding: EdgeInsets.zero,
                separatorSize: 20,
                childLeft: _adminTempNotifier.value == ''
                    ? CustomDropDownButtonFormFieldTittle(
                  labelText: StringConst.INITIAL_TEMP,
                  source: StringConst.ADMIN_TEMP_SELECTION,
                  onChanged: _finished
                      ? null
                      : (value) {
                    _adminTempNotifier.value = value!;
                  },
                  validator: (value) =>
                  value != null ? null : StringConst.FORM_GENERIC_ERROR,
                )
                    : CustomDropDownButtonFormFieldTittle(
                  labelText: StringConst.INITIAL_TEMP,
                  value: _adminTempNotifier.value,
                  source: StringConst.ADMIN_TEMP_SELECTION,
                  onChanged: _finished
                      ? null
                      : (value) {
                    _adminTempNotifier.value = value!;
                  },
                  validator: (value) =>
                  value != null ? null : StringConst.FORM_GENERIC_ERROR,
                ),
                childRight: ValueListenableBuilder(
                  valueListenable: _adminTempNotifier,
                  builder: (context, value, child){
                    return _adminTempNotifier.value == 'Inicial' || _adminTempNotifier.value == 'Temporal' ?
                    CustomDatePickerTitle(
                      labelText: StringConst.INITIAL_DATE_RENOVATION,
                      initialValue: _adminDateRenovation,
                      onChanged: (value) {
                        _adminDateRenovation = value;
                      },
                      enabled: !_finished,
                      validator: (value) => (value != null)
                          ? null
                          : StringConst.FORM_GENERIC_ERROR,
                    ) : Container();
                  },
                )
            ),
            SpaceH12(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childRight: _adminJuridicFigureNotifier.value == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_JURIDIC_FIGURE,
                source: StringConst.ADMIN_JURIDIC_FIGUR_SELECTION,
                onChanged: _finished
                    ? null
                    : (value) {
                  _adminJuridicFigureNotifier.value = value!;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              )
                  : CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_JURIDIC_FIGURE,
                value: _adminJuridicFigureNotifier.value,
                source: StringConst.ADMIN_JURIDIC_FIGUR_SELECTION,
                onChanged: _finished
                    ? null
                    : (value) {
                  _adminJuridicFigureNotifier.value = value!;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              ),
              childLeft: _adminResidenceType == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_RESIDENCE_TYPE,
                source: StringConst.ADMIN_RESIDENCE_TYPE_SELECTION,
                onChanged: _finished
                    ? null
                    : (value) {
                  _adminResidenceType = value!;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              )
                  : CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_RESIDENCE_TYPE,
                value: _adminResidenceType,
                source: StringConst.ADMIN_RESIDENCE_TYPE_SELECTION,
                onChanged: _finished
                    ? null
                    : (value) {
                  _adminResidenceType = value!;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              ),
            ),
            ValueListenableBuilder(
                valueListenable: _adminJuridicFigureNotifier,
                builder: (context, value, child){
                  return _adminJuridicFigureNotifier.value == 'Otros' ? Column(
                    children: [
                      SpaceH12(),
                      CustomTextFormFieldTitle(
                        labelText: StringConst.INITIAL_OTHERS,
                        initialValue: _adminOther,
                        onChanged: (value) {
                          _adminOther = value;
                        },
                        validator: (value) => (value!.isNotEmpty || value != '')
                            ? null
                            : StringConst.FORM_GENERIC_ERROR,
                        enabled: !_finished,
                      ),
                    ],
                  ) : Container();
                }
            ),


            //Section 2
            ValueListenableBuilder(
                valueListenable: _allow2Notifier,
                builder: (context, value, child){
                  return informSectionTitle(StringConst.INITIAL_TITLE2_SANITARY, _allow2Notifier.value, (){_allow2Notifier.value = !_allow2Notifier.value;});
                }
            ),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              initialValue: _orientation2,
              onChanged: (value) {
                _orientation2 = value;
              },
              validator: (value) => (value!.isNotEmpty || value != '')
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
                labelText: StringConst.INITIAL_HEALTH_CARD,
                source: StringConst.HEALTH_CARD_SELECTION,
                onChanged: _finished
                    ? null
                    : (value) {
                  _healthCard = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              )
                  : CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_HEALTH_CARD,
                value: _healthCard,
                source: StringConst.HEALTH_CARD_SELECTION,
                onChanged: _finished
                    ? null
                    : (value) {
                  _healthCard = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              ),
              childRight: CustomDatePickerTitle(
                labelText: StringConst.INITIAL_EXPIRATION_DATE,
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
              labelText: StringConst.INITIAL_MEDICATION,
              initialValue: _medication,
              onChanged: (value) {
                _medication = value;
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            //Subsection 2.1
            ValueListenableBuilder(
                valueListenable: _allow2Notifier,
                builder: (context, value, child){
                  return             ValueListenableBuilder(
                      valueListenable: _allow2_1Notifier,
                      builder: (context, value, child){
                        return informSubSectionTitle(StringConst.INITIAL_TITLE_2_1_MENTAL_HEALTH, _allow2Notifier.value, _allow2_1Notifier.value, (){_allow2_1Notifier.value = !_allow2_1Notifier.value;});
                      }
                  );
                }
            ),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              initialValue: _orientation2_1,
              onChanged: (value) {
                _orientation2_1 = value;
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: CustomTextFormFieldTitle(
                labelText: StringConst.INITIAL_REST,
                initialValue: _rest,
                onChanged: (value) {
                  _rest = value;
                },
                validator: (value) => (value!.isNotEmpty || value != '')
                    ? null
                    : StringConst.FORM_GENERIC_ERROR,
                enabled: !_finished,
              ),
              childRight: _diagnosis == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_DIAGNOSIS,
                source: StringConst.YES_NO_SELECTION,
                onChanged: _finished
                    ? null
                    : (value) {
                  _diagnosis = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              )
                  : CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_DIAGNOSIS,
                source: StringConst.YES_NO_SELECTION,
                value: _diagnosis,
                onChanged: _finished
                    ? null
                    : (value) {
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
                labelText: StringConst.INITIAL_TREATMENT,
                initialValue: _treatment,
                onChanged: (value) {
                  _treatment = value;
                },
                validator: (value) => (value!.isNotEmpty || value != '')
                    ? null
                    : StringConst.FORM_GENERIC_ERROR,
                enabled: !_finished,
              ),
              childRight: CustomTextFormFieldTitle(
                labelText: StringConst.INITIAL_TRACKING,
                initialValue: _tracking,
                onChanged: (value) {
                  _tracking = value;
                },
                validator: (value) => (value!.isNotEmpty || value != '')
                    ? null
                    : StringConst.FORM_GENERIC_ERROR,
                enabled: !_finished,
              ),
            ),

            //Subsection 2.2
            ValueListenableBuilder(
                valueListenable: _allow2Notifier,
                builder: (context, value, child){
                  return             ValueListenableBuilder(
                      valueListenable: _allow2_2Notifier,
                      builder: (context, value, child){
                        return informSubSectionTitle(StringConst.INITIAL_TITLE_2_2_DISABILITY, _allow2Notifier.value, _allow2_2Notifier.value, (){_allow2_2Notifier.value = !_allow2_2Notifier.value;});
                      }
                  );
                }
            ),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              initialValue: _orientation2_2,
              onChanged: (value) {
                _orientation2_2 = value;
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),

            ValueListenableBuilder(
                valueListenable: _disabilityStateNotifier,
                builder: (context, value, child) {
                  return Column(
                    children: [
                      _disabilityStateNotifier.value == ''
                          ? CustomDropDownButtonFormFieldTittle(
                        labelText: StringConst.INITIAL_STATE,
                        source: StringConst.STATE_SELECTION,
                        onChanged: _finished
                            ? null
                            : (value) {
                          _disabilityStateNotifier.value = value!;
                        },
                        validator: (value) => value != null
                            ? null
                            : StringConst.FORM_GENERIC_ERROR,
                      )
                          : CustomDropDownButtonFormFieldTittle(
                        labelText: StringConst.INITIAL_STATE,
                        source: StringConst.STATE_SELECTION,
                        value: _disabilityStateNotifier.value,
                        onChanged: _finished
                            ? null
                            : (value) {
                          _disabilityStateNotifier.value = value!;
                          if (value != 'Concedida') {
                            _grantedNotifier.value = '';
                            _revisionDate = null;
                          }
                        },
                        validator: (value) => value != null
                            ? null
                            : StringConst.FORM_GENERIC_ERROR,
                      ),
                      SpaceH12(),
                      _disabilityStateNotifier.value == 'Concedida'
                          ? ValueListenableBuilder(
                          valueListenable: _grantedNotifier,
                          builder: (context, value, child){
                            return CustomFlexRowColumn(
                              contentPadding: EdgeInsets.zero,
                              separatorSize: 20,

                              //Granted selection
                              childLeft:  _grantedNotifier.value == ''
                                  ? CustomDropDownButtonFormFieldTittle(
                                labelText: StringConst.INITIAL_GRANTED,
                                source: StringConst.GRANTED_SELECTION,
                                onChanged: _finished
                                    ? null
                                    : (value) {
                                  _grantedNotifier.value = value!;
                                },
                                validator: (value) => value != null
                                    ? null
                                    : StringConst.FORM_GENERIC_ERROR,
                              )
                                  : CustomDropDownButtonFormFieldTittle(
                                labelText: StringConst.INITIAL_GRANTED,
                                source: StringConst.GRANTED_SELECTION,
                                value: _grantedNotifier.value,
                                onChanged: _finished
                                    ? null
                                    : (value) {
                                  _grantedNotifier.value = value!;
                                },
                                validator: (value) => value != null
                                    ? null
                                    : StringConst.FORM_GENERIC_ERROR,
                              ),


                              //Date selection if revisable
                              childRight: _grantedNotifier.value == 'Revisable'
                                  ? CustomDatePickerTitle(
                                labelText: StringConst.INITIAL_DATE,
                                initialValue: _revisionDate,
                                onChanged: (value) {
                                  _revisionDate = value;
                                },
                                enabled: !_finished,
                                validator: (value) => (value != null)
                                    ? null
                                    : StringConst.FORM_GENERIC_ERROR,
                              )
                                  : Container(),
                            );
                          }
                      )
                          : Container(),
                      _disabilityStateNotifier.value == 'Concedida'
                          ? SpaceH12()
                          : Container(),
                    ],
                  );
                }),

            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_REFERENCE_PROFESSIONAL,
              initialValue: _referenceProfessionalDisability,
              onChanged: (value) {
                _referenceProfessionalDisability = value;
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),

            SpaceH12(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: _disabilityGrade == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_DISABILITY_GRADE,
                source: StringConst.DISABILITY_GRADE_SELECTION,
                onChanged: _finished
                    ? null
                    : (value) {
                  _disabilityGrade = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              )
                  : CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_DISABILITY_GRADE,
                source: StringConst.DISABILITY_GRADE_SELECTION,
                value: _disabilityGrade,
                onChanged: _finished
                    ? null
                    : (value) {
                  _disabilityGrade = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              ),
              childRight: _disabilityType == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_DISABILITY_TYPE,
                source: StringConst.DISABILITY_TYPE_SELECTION,
                onChanged: _finished
                    ? null
                    : (value) {
                  _disabilityType = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              )
                  : CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_DISABILITY_TYPE,
                source: StringConst.DISABILITY_TYPE_SELECTION,
                value: _disabilityType,
                onChanged: _finished
                    ? null
                    : (value) {
                  _disabilityType = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              ),
            ),

            //Subsection 2.3
            ValueListenableBuilder(
                valueListenable: _allow2Notifier,
                builder: (context, value, child){
                  return             ValueListenableBuilder(
                      valueListenable: _allow2_3Notifier,
                      builder: (context, value, child){
                        return informSubSectionTitle(StringConst.INITIAL_TITLE_2_3_DEPENDENCE, _allow2Notifier.value, _allow2_3Notifier.value, (){_allow2_3Notifier.value = !_allow2_3Notifier.value;});
                      }
                  );
                }
            ),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              initialValue: _orientation2_3,
              onChanged: (value) {
                _orientation2_3 = value;
              },
              validator: (value) => (value!.isNotEmpty || value != '')
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
                labelText: StringConst.INITIAL_STATE,
                source: StringConst.DEPENDENCE_STATE_SELECTION,
                onChanged: _finished
                    ? null
                    : (value) {
                  _dependenceState = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              )
                  : CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_STATE,
                source: StringConst.DEPENDENCE_STATE_SELECTION,
                value: _dependenceState,
                onChanged: _finished
                    ? null
                    : (value) {
                  _dependenceState = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              ),
              childRight: CustomTextFormFieldTitle(
                labelText: StringConst.INITIAL_REFERENCE_PROFESSIONAL,
                initialValue: _referenceProfessionalDependence,
                onChanged: (value) {
                  _referenceProfessionalDependence = value;
                },
                validator: (value) => (value!.isNotEmpty || value != '')
                    ? null
                    : StringConst.FORM_GENERIC_ERROR,
                enabled: !_finished,
              ),
            ),
            SpaceH12(),
            _dependenceGrade == ''
                ? CustomDropDownButtonFormFieldTittle(
              labelText: StringConst.INITIAL_DEPENDENCE_GRADE,
              source: StringConst.DEPENDENCE_GRADE_SELECTION,
              onChanged: _finished
                  ? null
                  : (value) {
                _dependenceGrade = value;
              },
              validator: (value) =>
              value != null ? null : StringConst.FORM_GENERIC_ERROR,
            )
                : CustomDropDownButtonFormFieldTittle(
              labelText: StringConst.INITIAL_DEPENDENCE_GRADE,
              source: StringConst.DEPENDENCE_GRADE_SELECTION,
              value: _dependenceGrade,
              onChanged: _finished
                  ? null
                  : (value) {
                _dependenceGrade = value;
              },
              validator: (value) =>
              value != null ? null : StringConst.FORM_GENERIC_ERROR,
            ),

            //Subsection 2.4
            ValueListenableBuilder(
                valueListenable: _allow2Notifier,
                builder: (context, value, child){
                  return             ValueListenableBuilder(
                      valueListenable: _allow2_4Notifier,
                      builder: (context, value, child){
                        return informSubSectionTitle(StringConst.INITIAL_TITLE_2_4_ADDICTIONS, _allow2Notifier.value, _allow2_4Notifier.value, (){_allow2_4Notifier.value = !_allow2_4Notifier.value;});
                      }
                  );
                }
            ),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              initialValue: _orientation2_4,
              onChanged: (value) {
                _orientation2_4 = value;
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: _externalDerivation == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_EXTERNAL_DERIVATION,
                source: StringConst.YES_NO_SELECTION,
                onChanged: _finished
                    ? null
                    : (value) {
                  _externalDerivation = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              )
                  : CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_EXTERNAL_DERIVATION,
                source: StringConst.YES_NO_SELECTION,
                value: _externalDerivation,
                onChanged: _finished
                    ? null
                    : (value) {
                  _externalDerivation = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              ),
              childRight: CustomTextFormFieldTitle(
                labelText: StringConst.INITIAL_MOTIVE,
                initialValue: _motive,
                onChanged: (value) {
                  _motive = value;
                },
                validator: (value) => (value!.isNotEmpty || value != '')
                    ? null
                    : StringConst.FORM_GENERIC_ERROR,
                enabled: !_finished,
              ),
            ),

            //Section 3
            ValueListenableBuilder(
                valueListenable: _allow3Notifier,
                builder: (context, value, child){
                  return informSectionTitle(StringConst.INITIAL_TITLE_3_LEGAL_SITUATION, _allow3Notifier.value, (){_allow3Notifier.value = !_allow3Notifier.value;});
                }
            ),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              initialValue: _orientation3,
              onChanged: (value) {
                _orientation3 = value;
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            //Internal derivation
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: _internalDerivationLegal == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_INTERNAL_DERIVATION,
                source: StringConst.YES_NO_SELECTION,
                onChanged: _finished
                    ? null
                    : (value) {
                  _internalDerivationLegal = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              )
                  : CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_INTERNAL_DERIVATION,
                source: StringConst.YES_NO_SELECTION,
                value: _internalDerivationLegal,
                onChanged: _finished
                    ? null
                    : (value) {
                  _internalDerivationLegal = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              ),
              childRight: CustomDatePickerTitle(
                labelText: StringConst.INITIAL_DERIVATION_DATE,
                initialValue: _internalDerivationDate,
                onChanged: (value) {
                  _internalDerivationDate = value;
                },
                enabled: !_finished,
                validator: (value) =>
                (value != null) ? null : StringConst.FORM_GENERIC_ERROR,
              ),
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_MOTIVE,
              initialValue: _internalDerivationMotive,
              onChanged: (value) {
                _internalDerivationMotive = value;
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            //Psychosocial derivation
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: _psychosocialDerivationLegal == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_EXTERNAL_DERIVATION,
                source: StringConst.YES_NO_SELECTION,
                onChanged: _finished
                    ? null
                    : (value) {
                  _psychosocialDerivationLegal = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              )
                  : CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_EXTERNAL_DERIVATION,
                source: StringConst.YES_NO_SELECTION,
                value: _psychosocialDerivationLegal,
                onChanged: _finished
                    ? null
                    : (value) {
                  _psychosocialDerivationLegal = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              ),
              childRight: CustomDatePickerTitle(
                labelText: StringConst.INITIAL_DERIVATION_DATE,
                initialValue: _psychosocialDerivationDate,
                onChanged: (value) {
                  _psychosocialDerivationDate = value;
                },
                enabled: !_finished,
                validator: (value) =>
                (value != null) ? null : StringConst.FORM_GENERIC_ERROR,
              ),
            ),
            SpaceH12(), //TODO check values saved
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_MOTIVE,
              initialValue: _psychosocialDerivationMotive,
              onChanged: (value) {
                _psychosocialDerivationMotive = value;
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            //External derivation
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: _externalDerivationLegal == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_PSYCHOSOCIAL_DERIVATION,
                source: StringConst.YES_NO_SELECTION,
                onChanged: _finished
                    ? null
                    : (value) {
                  _externalDerivationLegal = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              )
                  : CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_PSYCHOSOCIAL_DERIVATION,
                source: StringConst.YES_NO_SELECTION,
                value: _externalDerivationLegal,
                onChanged: _finished
                    ? null
                    : (value) {
                  _externalDerivationLegal = value;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              ),
              childRight: CustomDatePickerTitle(
                labelText: StringConst.INITIAL_DERIVATION_DATE,
                initialValue: _externalDerivationDate,
                onChanged: (value) {
                  _externalDerivationDate = value;
                },
                enabled: !_finished,
                validator: (value) =>
                (value != null) ? null : StringConst.FORM_GENERIC_ERROR,
              ),
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_MOTIVE,
              initialValue: _externalDerivationMotive,
              onChanged: (value) {
                _externalDerivationMotive = value;
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_LEGAL_REPRESENTATION,
              hintText: StringConst.INITIAL_HINT_LEGAL,
              initialValue: _legalRepresentation,
              onChanged: (value) {
                _legalRepresentation = value;
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),

            !_fromInitialReport ? Column(
              children: [
                SpaceH12(),
                CustomFlexRowColumn(
                  separatorSize: 20,
                  contentPadding: EdgeInsets.zero,
                  childLeft: CustomTextFormFieldTitle(
                    labelText: StringConst.FOLLOW_PROCESSING_BAG,
                    initialValue: _processingBag,
                    onChanged: (value) {
                      _processingBag = value;
                    },
                    validator: (value) => (value!.isNotEmpty || value != '')
                        ? null
                        : StringConst.FORM_GENERIC_ERROR,
                    enabled: !_finished,
                  ),
                  childRight: CustomDatePickerTitle(
                    labelText: StringConst.INITIAL_DATE,
                    initialValue: _processingBagDate,
                    onChanged: (value) {
                      _processingBagDate = value;
                    },
                    enabled: !_finished,
                    validator: (value) =>
                    (value != null) ? null : StringConst.FORM_GENERIC_ERROR,
                  ),
                ),
                SpaceH12(),
                CustomTextFormFieldTitle(
                  labelText: StringConst.FOLLOW_ECONOMIC_AMOUNT,
                  initialValue: _economicAmount,
                  onChanged: (value) {
                    _economicAmount = value;
                  },
                  validator: (value) => (value!.isNotEmpty || value != '')
                      ? null
                      : StringConst.FORM_GENERIC_ERROR,
                  enabled: !_finished,
                ),
              ],
            ) : Container(),


            //Section 4
            ValueListenableBuilder(
                valueListenable: _allow4Notifier,
                builder: (context, value, child){
                  return informSectionTitle(StringConst.INITIAL_TITLE_4_HOUSE_SITUATION, _allow4Notifier.value, (){_allow4Notifier.value = !_allow4Notifier.value;});
                }
            ),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              initialValue: _orientation4,
              onChanged: (value) {
                _orientation4 = value;
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomFlexRowColumn(
                contentPadding: EdgeInsets.zero,
                separatorSize: 20,
                childLeft: _ownershipTypeNotifier.value == ''
                    ? CustomDropDownButtonFormFieldTittle(
                  labelText: StringConst.INITIAL_HOUSE_SITUATION,
                  source: StringConst.OWNERSHIP_TYPE_SELECTION,
                  onChanged: _finished
                      ? null
                      : (value) {
                    _ownershipTypeNotifier.value = value!;
                  },
                  validator: (value) =>
                  value != null ? null : StringConst.FORM_GENERIC_ERROR,
                )
                    : CustomDropDownButtonFormFieldTittle(
                  labelText: StringConst.INITIAL_HOUSE_SITUATION,
                  source: StringConst.OWNERSHIP_TYPE_SELECTION,
                  value: _ownershipTypeNotifier.value,
                  onChanged: _finished
                      ? null
                      : (value) {
                    _ownershipTypeNotifier.value = value!;
                  },
                  validator: (value) =>
                  value != null ? null : StringConst.FORM_GENERIC_ERROR,
                ),
                childRight: ValueListenableBuilder(
                  valueListenable: _ownershipTypeNotifier,
                  builder: (context, value, child){
                    return _ownershipTypeNotifier.value == 'Con hogar' ?
                    //Tipo de tenencia (Con hogar)
                    _ownershipTypeConcreteNotifier.value == ''
                        ? CustomDropDownButtonFormFieldTittle(
                      labelText: StringConst.INITIAL_OWNERSHIP_TYPE,
                      source: StringConst.OWNERSHIP_TYPE_CONCRETE_SELECTION,
                      onChanged: _finished
                          ? null
                          : (value) {
                        _ownershipTypeConcreteNotifier.value = value!;
                      },
                      validator: (value) =>
                      value != null ? null : StringConst.FORM_GENERIC_ERROR,
                    )
                        : CustomDropDownButtonFormFieldTittle(
                      labelText: StringConst.INITIAL_OWNERSHIP_TYPE,
                      source: StringConst.OWNERSHIP_TYPE_CONCRETE_SELECTION,
                      value: _ownershipTypeConcreteNotifier.value,
                      onChanged: _finished
                          ? null
                          : (value) {
                        _ownershipTypeConcreteNotifier.value = value!;
                      },
                      validator: (value) =>
                      value != null ? null : StringConst.FORM_GENERIC_ERROR,
                    ) : _ownershipTypeNotifier.value == 'Sin hogar' ?
                    //Situación sinhogarismo (Sin hogar)
                    _homelessnessSituationNotifier.value == ''
                        ? CustomDropDownButtonFormFieldTittle(
                      labelText: StringConst.INITIAL_HOMELESS_SITUATION,
                      source: StringConst.HOMELESS_SITUATION_SELECTION,
                      onChanged: _finished
                          ? null
                          : (value) {
                        _homelessnessSituationNotifier.value = value!;
                      },
                      validator: (value) =>
                      value != null ? null : StringConst.FORM_GENERIC_ERROR,
                    )
                        : CustomDropDownButtonFormFieldTittle(
                      labelText: StringConst.INITIAL_HOMELESS_SITUATION,
                      source: StringConst.HOMELESS_SITUATION_SELECTION,
                      value: _homelessnessSituationNotifier.value,
                      onChanged: _finished
                          ? null
                          : (value) {
                        _homelessnessSituationNotifier.value = value!;
                      },
                      validator: (value) =>
                      value != null ? null : StringConst.FORM_GENERIC_ERROR,
                    ) :
                    Container();
                  },
                )
            ),
            ValueListenableBuilder(
                valueListenable: _ownershipTypeConcreteNotifier,
                builder: (context, value, child){
                  return _ownershipTypeConcreteNotifier.value == 'Otros' ?
                  Column(
                    children: [
                      SpaceH12(),
                      CustomTextFormFieldTitle(
                        labelText: StringConst.INITIAL_OTHERS,
                        initialValue: _ownershipTypeOpen,
                        onChanged: (value) {
                          _ownershipTypeOpen = value;
                        },
                        validator: (value) => (value!.isNotEmpty || value != '')
                            ? null
                            : StringConst.FORM_GENERIC_ERROR,
                        enabled: !_finished,
                      ),
                    ],
                  ) :
                  Container();
                }
            ),
            ValueListenableBuilder(
                valueListenable: _homelessnessSituationNotifier,
                builder: (context, value, child){
                  return _homelessnessSituationNotifier.value == 'Otros' ?
                  Column(
                    children: [
                      SpaceH12(),
                      CustomTextFormFieldTitle(
                        labelText: StringConst.INITIAL_OTHERS,
                        initialValue: _homelessnessSituationOpen,
                        onChanged: (value) {
                          _homelessnessSituationOpen = value;
                        },
                        validator: (value) => (value!.isNotEmpty || value != '')
                            ? null
                            : StringConst.FORM_GENERIC_ERROR,
                        enabled: !_finished,
                      ),
                    ],
                  ) :
                  Container();
                }
            ),
            SpaceH12(),
            CustomFlexRowColumn(
              separatorSize: 20,
              contentPadding: EdgeInsets.zero,
              childLeft: CustomTextFormFieldTitle(
                labelText: StringConst.INITIAL_LIVING_UNIT,
                hintText: StringConst.INITIAL_LIVING_UNIT_HINT,
                initialValue: _livingUnit,
                onChanged: (value) {
                  _livingUnit = value;
                },
                validator: (value) => (value!.isNotEmpty || value != '')
                    ? null
                    : StringConst.FORM_GENERIC_ERROR,
                enabled: !_finished,
              ),
              childRight: CustomTextFormFieldTitle(
                labelText: StringConst.INITIAL_CENTER_CONTACT,
                initialValue: _centerContact,
                onChanged: (value) {
                  _centerContact = value;
                },
                validator: (value) => (value!.isNotEmpty || value != '')
                    ? null
                    : StringConst.FORM_GENERIC_ERROR,
                enabled: !_finished,
              ),
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_LOCATION,
              initialValue: _location,
              onChanged: (value) {
                _location = value;
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            Align(
                alignment: Alignment.center,
                child: CustomMultiSelectionRadioList(
                    options: StringConst.OPTIONS_SECTION_4,
                    selections: _hostingObservations,
                    enabled: !_finished)),

            //Section 5
            ValueListenableBuilder(
                valueListenable: _allow5Notifier,
                builder: (context, value, child){
                  return informSectionTitle(StringConst.INITIAL_TITLE_5_SUPPORT, _allow5Notifier.value, (){_allow5Notifier.value = !_allow5Notifier.value;});
                }
            ),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              initialValue: _orientation5,
              onChanged: (value) {
                _orientation5 = value;
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_INFORMATION_NETWORKS,
              initialValue: _informationNetworks,
              hintText: StringConst.INITIAL_INFORMATION_NETWORKS_HINT,
              onChanged: (value) {
                _informationNetworks = value;
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomFlexRowColumn(
              separatorSize: 20,
              contentPadding: EdgeInsets.zero,
              childLeft: CustomTextFormFieldTitle(
                labelText: StringConst.INITIAL_INSTITUTION_NETWORKS,
                initialValue: _institutionNetworks,
                onChanged: (value) {
                  _institutionNetworks = value;
                },
                validator: (value) => (value!.isNotEmpty || value != '')
                    ? null
                    : StringConst.FORM_GENERIC_ERROR,
                enabled: !_finished,
              ),
              childRight: CustomTextFormFieldTitle(
                labelText: StringConst.INITIAL_FAMILY_CONCILIATION,
                initialValue: _familyConciliation,
                onChanged: (value) {
                  _familyConciliation = value;
                },
                validator: (value) => (value!.isNotEmpty || value != '')
                    ? null
                    : StringConst.FORM_GENERIC_ERROR,
                enabled: !_finished,
              ),
            ),

            //Section 7
            ValueListenableBuilder(
                valueListenable: _allow6Notifier,
                builder: (context, value, child){
                  return informSectionTitle(StringConst.INITIAL_TITLE_6_LANGUAGES, _allow6Notifier.value, (){_allow6Notifier.value = !_allow6Notifier.value;});
                }
            ),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              initialValue: _orientation7,
              onChanged: (value) {
                _orientation7 = value;
              },
              validator: (value) => (value!.isNotEmpty || value != '')
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
                  final _languageOptions = _languagesStream!
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList();
                  return ValueListenableBuilder(
                      valueListenable: _languagesNotifier,
                      builder: (context, value, child)
                      {
                        return Column(
                          children: [
                            for (LanguageReport language in _languagesNotifier
                                .value)
                              Column(
                                children: [
                                  CustomFlexRowColumn(
                                    contentPadding: EdgeInsets.zero,
                                    separatorSize: 20,
                                    childLeft: language.name == ''
                                        ? CustomDropDownButtonFormFieldTittle(
                                      labelText: StringConst.INITIAL_LANGUAGE,
                                      source: _languageOptions,
                                      onChanged: _finished
                                          ? null
                                          : (value) {
                                        _languagesNotifier.value[_languagesNotifier
                                            .value.indexOf(language)].name = value!;
                                      },
                                      validator: (value) =>
                                      value != null
                                          ? null
                                          : StringConst.FORM_GENERIC_ERROR,
                                    )
                                        : CustomDropDownButtonFormFieldTittle(
                                      labelText: StringConst.INITIAL_LANGUAGE,
                                      value: language.name,
                                      source: _languageOptions,
                                      onChanged: _finished
                                          ? null
                                          : (value) {
                                        _languagesNotifier.value[_languagesNotifier
                                            .value.indexOf(language)].name = value!;
                                      },
                                      validator: (value) =>
                                      value != null
                                          ? null
                                          : StringConst.FORM_GENERIC_ERROR,
                                    ),
                                    childRight: CustomTextFormFieldTitle(
                                      labelText:
                                      StringConst.INITIAL_LANGUAGE_LEVEL,
                                      initialValue: language.level,
                                      onChanged: (value) {
                                        _languagesNotifier.value[_languagesNotifier
                                            .value.indexOf(language)].level = value;
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
                  );

                }),
            addLanguageButton(),

            //Section 9
            ValueListenableBuilder(
                valueListenable: _allow7Notifier,
                builder: (context, value, child){
                  return informSectionTitle(StringConst.INITIAL_TITLE_7_SOCIAL_ATTENTION, _allow7Notifier.value, (){_allow7Notifier.value = !_allow7Notifier.value;});
                }
            ),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              initialValue: _orientation9,
              onChanged: (value) {
                _orientation9 = value;
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_CENTER_TS,
              initialValue: _centerTSReference,
              onChanged: (value) {
                _centerTSReference = value;
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomFlexRowColumn(
                contentPadding: EdgeInsets.zero,
                separatorSize: 20,
                childLeft: _subsidyBeneficiaryNotifier.value == ''
                    ? CustomDropDownButtonFormFieldTittle(
                  labelText: StringConst.INITIAL_SUBSIDY_BENEFICIARY,
                  source: StringConst.YES_NO_SELECTION,
                  onChanged: _finished
                      ? null
                      : (value) {
                    _subsidyBeneficiaryNotifier.value = value!;
                  },
                  validator: (value) =>
                  value != null ? null : StringConst.FORM_GENERIC_ERROR,
                )
                    : CustomDropDownButtonFormFieldTittle(
                  labelText: StringConst.INITIAL_SUBSIDY_BENEFICIARY,
                  source: StringConst.YES_NO_SELECTION,
                  value: _subsidyBeneficiaryNotifier.value,
                  onChanged: _finished
                      ? null
                      : (value) {
                    _subsidyBeneficiaryNotifier.value = value!;
                  },
                  validator: (value) =>
                  value != null ? null : StringConst.FORM_GENERIC_ERROR,
                ),
                childRight: ValueListenableBuilder(
                  valueListenable: _subsidyBeneficiaryNotifier,
                  builder: (context, value, child){
                    return _subsidyBeneficiaryNotifier.value == 'Si' ?
                    CustomTextFormFieldTitle(
                      labelText: StringConst.INITIAL_NAME_TYPE,
                      initialValue: _subsidyName,
                      onChanged: (value) {
                        _subsidyName = value;
                      },
                      validator: (value) => (value!.isNotEmpty || value != '')
                          ? null
                          : StringConst.FORM_GENERIC_ERROR,
                      enabled: !_finished,
                    ) :
                    Container();
                  },
                )
            ),
            SpaceH12(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: _socialExclusionCertificateNotifier.value == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_SOCIAL_EXCLUSION_CERTIFICATE,
                source: StringConst.YES_NO_SELECTION,
                onChanged: _finished
                    ? null
                    : (value) {
                  _socialExclusionCertificateNotifier.value = value!;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              )
                  : CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_SOCIAL_EXCLUSION_CERTIFICATE,
                source: StringConst.YES_NO_SELECTION,
                value: _socialExclusionCertificateNotifier.value,
                onChanged: _finished
                    ? null
                    : (value) {
                  _socialExclusionCertificateNotifier.value = value!;
                },
                validator: (value) =>
                value != null ? null : StringConst.FORM_GENERIC_ERROR,
              ),
              childRight: Container(),
            ),
            ValueListenableBuilder(
                valueListenable: _socialExclusionCertificateNotifier,
                builder: (context, value, child){
                  return _socialExclusionCertificateNotifier.value == 'Si' ?
                  Column(
                    children: [
                      SpaceH12(),
                      CustomFlexRowColumn(
                        contentPadding: EdgeInsets.zero,
                        separatorSize: 20,
                        childRight: CustomDatePickerTitle(
                          labelText: StringConst.INITIAL_DATE,
                          initialValue: _socialExclusionCertificateDate,
                          onChanged: (value) {
                            _socialExclusionCertificateDate = value;
                          },
                          enabled: !_finished,
                          validator: (value) => (value != null)
                              ? null
                              : StringConst.FORM_GENERIC_ERROR,
                        ),
                        childLeft: CustomTextFormFieldTitle(
                          labelText: StringConst.INITIAL_SOCIAL_EXCLUSION_OBSERVATIONS,
                          initialValue: _socialExclusionCertificateObservations,
                          onChanged: (value) {
                            _socialExclusionCertificateObservations = value;
                          },
                          validator: (value) => (value!.isNotEmpty || value != '')
                              ? null
                              : StringConst.FORM_GENERIC_ERROR,
                          enabled: !_finished,
                        ),
                      ),
                    ],
                  ) :
                  Container();
                }
            ),
            //Section 12
            ValueListenableBuilder(
                valueListenable: _allow8Notifier,
                builder: (context, value, child){
                  return informSectionTitle(StringConst.INITIAL_TITLE_8_VULNERABILITY, _allow8Notifier.value, (){_allow8Notifier.value = !_allow8Notifier.value;});
                }
            ),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              initialValue: _orientation12,
              onChanged: (value) {
                _orientation12 = value;
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomMultiSelectionRadioList(
                options: StringConst.OPTIONS_SECTION_12,
                selections: _vulnerabilityOptions,
                enabled: !_finished),

            //Section 13
            ValueListenableBuilder(
                valueListenable: _allow9Notifier,
                builder: (context, value, child){
                  return informSectionTitle(StringConst.INITIAL_TITLE_9_WORK, _allow9Notifier.value, (){_allow9Notifier.value = !_allow9Notifier.value;});
                }
            ),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              initialValue: _orientation13,
              onChanged: (value) {
                _orientation13 = value;
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            _educationLevel == ''
                ? CustomDropDownButtonFormFieldTittle(
              labelText: StringConst.INITIAL_EDUCATION_LEVEL,
              source: StringConst.EDUCATIONAL_LEVEL_SELECTION,
              onChanged: _finished
                  ? null
                  : (value) {
                _educationLevel = value;
              },
              validator: (value) =>
              value != null ? null : StringConst.FORM_GENERIC_ERROR,
            )
                : CustomDropDownButtonFormFieldTittle(
              labelText: StringConst.INITIAL_EDUCATION_LEVEL,
              source: StringConst.EDUCATIONAL_LEVEL_SELECTION,
              value: _educationLevel,
              onChanged: _finished
                  ? null
                  : (value) {
                _educationLevel = value;
              },
              validator: (value) =>
              value != null ? null : StringConst.FORM_GENERIC_ERROR,
            ),
            ValueListenableBuilder(
                valueListenable: _allow9Notifier,
                builder: (context, value, child){
                  return             ValueListenableBuilder(
                      valueListenable: _allow9_2Notifier,
                      builder: (context, value, child){
                        return informSubSectionTitle(StringConst.INITIAL_TITLE_9_2_WORK_SITUATION, _allow9Notifier.value, _allow9_2Notifier.value, (){_allow9_2Notifier.value = !_allow9_2Notifier.value;});
                      }
                  );
                }
            ),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              initialValue: _orientation13_2,
              onChanged: (value) {
                _orientation13_2 = value;
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),

            _fromInitialReport ?
              Column(
                children: [
                  SpaceH12(),
                  _laborSituationNotifier.value == ''
                      ? CustomDropDownButtonFormFieldTittle(
                    labelText: StringConst.INITIAL_LABOR_SITUATION,
                    source: StringConst.LABOR_SITUATION_SELECTION,
                    onChanged: _finished
                        ? null
                        : (value) {
                      _laborSituationNotifier.value = value!;
                    },
                    validator: (value) =>
                    value != null ? null : StringConst.FORM_GENERIC_ERROR,
                  )
                      : CustomDropDownButtonFormFieldTittle(
                    labelText: StringConst.INITIAL_LABOR_SITUATION,
                    source: StringConst.LABOR_SITUATION_SELECTION,
                    value: _laborSituationNotifier.value,
                    onChanged: _finished
                        ? null
                        : (value) {
                      _laborSituationNotifier.value = value!;
                    },
                    validator: (value) =>
                    value != null ? null : StringConst.FORM_GENERIC_ERROR,
                  ),

                  SpaceH12(),
                  ValueListenableBuilder(
                      valueListenable: _laborSituationNotifier,
                      builder: (context, value, child){
                        return  _laborSituationNotifier.value == 'Ocupada cuenta ajena' || _laborSituationNotifier.value == 'Ocupada cuenta propia' ? CustomFlexRowColumn(
                          contentPadding: EdgeInsets.zero,
                          separatorSize: 20,
                          childLeft: _tempLabor == ''
                              ? CustomDropDownButtonFormFieldTittle(
                            labelText: StringConst.INITIAL_TEMP,
                            source: StringConst.TEMP_SELECTION,
                            onChanged: _finished
                                ? null
                                : (value) {
                              _tempLabor = value;
                            },
                            validator: (value) => value != null
                                ? null
                                : StringConst.FORM_GENERIC_ERROR,
                          )
                              : CustomDropDownButtonFormFieldTittle(
                            labelText: StringConst.INITIAL_TEMP,
                            source: StringConst.TEMP_SELECTION,
                            value: _tempLabor,
                            onChanged: _finished
                                ? null
                                : (value) {
                              _tempLabor = value;
                            },
                            validator: (value) => value != null
                                ? null
                                : StringConst.FORM_GENERIC_ERROR,
                          ),
                          childRight: _workingDayLabor == ''
                              ? CustomDropDownButtonFormFieldTittle(
                            labelText: StringConst.INITIAL_LABOR_TYPE,
                            source: StringConst.WORK_DAY_SELECTION,
                            onChanged: _finished
                                ? null
                                : (value) {
                              _workingDayLabor = value;
                            },
                            validator: (value) => value != null
                                ? null
                                : StringConst.FORM_GENERIC_ERROR,
                          )
                              : CustomDropDownButtonFormFieldTittle(
                            labelText: StringConst.INITIAL_LABOR_TYPE,
                            source: StringConst.WORK_DAY_SELECTION,
                            value: _workingDayLabor,
                            onChanged: _finished
                                ? null
                                : (value) {
                              _workingDayLabor = value;
                            },
                            validator: (value) => value != null
                                ? null
                                : StringConst.FORM_GENERIC_ERROR,
                          ),
                        ) :
                        Container();
                      }
                  ),
                ],
              ) :
              Container(),

            ValueListenableBuilder(
                valueListenable: _allow9Notifier,
                builder: (context, value, child){
                  return             ValueListenableBuilder(
                      valueListenable: _allow9_3Notifier,
                      builder: (context, value, child){
                        return informSubSectionTitle(StringConst.INITIAL_TITLE_9_3_TRAJECTORY, _allow9Notifier.value, _allow9_3Notifier.value, (){_allow9_3Notifier.value = !_allow9_3Notifier.value;});
                      }
                  );
                }
            ),
            CustomTextFormFieldTitle(
              labelText:
              StringConst.INITIAL_COMPETENCIES,
              initialValue: _competencies,
              onChanged: (value) {
                _competencies = value ?? '';
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_CONTEXTUALIZATION,
              initialValue: _contextualization,
              onChanged: (value) {
                _contextualization = value ?? '';
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_CONNEXION,
              initialValue: _connexion,
              onChanged: (value) {
                _connexion = value ?? '';
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),

            ValueListenableBuilder(
                valueListenable: _allow9Notifier,
                builder: (context, value, child){
                  return             ValueListenableBuilder(
                      valueListenable: _allow9_4Notifier,
                      builder: (context, value, child){
                        return informSubSectionTitle(StringConst.INITIAL_TITLE_9_4_EXPECTATIONS, _allow9Notifier.value, _allow9_4Notifier.value, (){_allow9_4Notifier.value = !_allow9_4Notifier.value;});
                      }
                  );
                }
            ),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_SHORT_TERM,
              initialValue: _shortTerm,
              onChanged: (value) {
                _shortTerm = value ?? '';
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_MEDIUM_TERM,
              initialValue: _mediumTerm,
              onChanged: (value) {
                _mediumTerm = value ?? '';
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_LONG_TERM,
              initialValue: _longTerm,
              onChanged: (value) {
                _longTerm = value ?? '';
              },
              validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
            ),

            !_fromInitialReport ? Column(
              children: [
                ValueListenableBuilder(
                    valueListenable: _allow9Notifier,
                    builder: (context, value, child){
                      return             ValueListenableBuilder(
                          valueListenable: _allow9_5Notifier,
                          builder: (context, value, child){
                            return informSubSectionTitle(StringConst.FOLLOW_TITLE_9_5_DEVELOP, _allow9Notifier.value, _allow9_5Notifier.value, (){_allow9_5Notifier.value = !_allow9_5Notifier.value;});
                          }
                      );
                    }
                ),
                CustomTextFormFieldTitle(
                  labelText: StringConst.INITIAL_OBSERVATIONS,
                  initialValue: _orientation9_5,
                  onChanged: (value) {
                    _orientation9_5 = value ?? '';
                  },
                  validator: (value) => (value!.isNotEmpty || value != '')
                      ? null
                      : StringConst.FORM_GENERIC_ERROR,
                  enabled: !_finished,
                ),

                informSubSectionTitle(StringConst.FOLLOW_FORMATIONS, false, false, (){}),

                ValueListenableBuilder(
                    valueListenable: _formationsNotifier,
                    builder: (context, value, child)
                    {
                      return Column(
                        children: [
                          for (FormationReport formation in _formationsNotifier
                              .value)
                            Column(
                              children: [
                                CustomFlexRowColumn(
                                  contentPadding: EdgeInsets.zero,
                                  separatorSize: 20,
                                  childLeft: CustomTextFormFieldTitle(
                                    labelText:
                                    StringConst.FOLLOW_FORMATION_NAME,
                                    initialValue: formation.name,
                                    onChanged: (value) {
                                      _formationsNotifier.value[_formationsNotifier
                                          .value.indexOf(formation)].name = value;
                                    },
                                    validator: (value) =>
                                    (value!.isNotEmpty || value != '')
                                        ? null
                                        : StringConst.FORM_GENERIC_ERROR,
                                    enabled: !_finished,
                                  ),
                                  childRight: formation.type == ''
                                      ? CustomDropDownButtonFormFieldTittle(
                                    labelText: StringConst.FOLLOW_FORMATION_TYPE,
                                    source: StringConst.FORMATION_TYPE_SELECTION,
                                    onChanged: _finished
                                        ? null
                                        : (value) {
                                      _formationsNotifier.value[_formationsNotifier
                                          .value.indexOf(formation)].type = value!;
                                    },
                                    validator: (value) =>
                                    value != null
                                        ? null
                                        : StringConst.FORM_GENERIC_ERROR,
                                  )
                                      : CustomDropDownButtonFormFieldTittle(
                                    labelText: StringConst.FOLLOW_FORMATION_TYPE,
                                    value: formation.type,
                                    source: StringConst.FORMATION_TYPE_SELECTION,
                                    onChanged: _finished
                                        ? null
                                        : (value) {
                                      _formationsNotifier.value[_formationsNotifier
                                          .value.indexOf(formation)].type = value!;
                                    },
                                    validator: (value) =>
                                    value != null
                                        ? null
                                        : StringConst.FORM_GENERIC_ERROR,
                                  ),
                                ),
                                SpaceH12(),
                                formation.certification == ''
                                    ? CustomDropDownButtonFormFieldTittle(
                                  labelText: StringConst.FOLLOW_FORMATION_CERTIFICATION,
                                  source: StringConst.YES_NO_SELECTION,
                                  onChanged: _finished
                                      ? null
                                      : (value) {
                                    _formationsNotifier.value[_formationsNotifier
                                        .value.indexOf(formation)].certification = value!;
                                  },
                                  validator: (value) =>
                                  value != null
                                      ? null
                                      : StringConst.FORM_GENERIC_ERROR,
                                )
                                    : CustomDropDownButtonFormFieldTittle(
                                  labelText: StringConst.FOLLOW_FORMATION_CERTIFICATION,
                                  value: formation.certification,
                                  source: StringConst.YES_NO_SELECTION,
                                  onChanged: _finished
                                      ? null
                                      : (value) {
                                    _formationsNotifier.value[_formationsNotifier
                                        .value.indexOf(formation)].certification = value!;
                                  },
                                  validator: (value) =>
                                  value != null
                                      ? null
                                      : StringConst.FORM_GENERIC_ERROR,
                                ),
                                SpaceH12(),
                              ],
                            ),

                        ],
                      );
                    }
                ),
                addFormationButton(),
                SpaceH12(),

                CustomFlexRowColumn(
                  contentPadding: EdgeInsets.zero,
                  separatorSize: 20,
                  childLeft: _formationBag == ''
                      ? CustomDropDownButtonFormFieldTittle(
                    labelText: StringConst.FOLLOW_FORMATION_BAG,
                    source: StringConst.YES_NO_SELECTION,
                    onChanged: _finished
                        ? null
                        : (value) {
                      _formationBag = value;
                    },
                    validator: (value) =>
                    value != null ? null : StringConst.FORM_GENERIC_ERROR,
                  )
                      : CustomDropDownButtonFormFieldTittle(
                    labelText: StringConst.FOLLOW_FORMATION_BAG,
                    source: StringConst.YES_NO_SELECTION,
                    value: _formationBag,
                    onChanged: _finished
                        ? null
                        : (value) {
                      _formationBag = value;
                    },
                    validator: (value) =>
                    value != null ? null : StringConst.FORM_GENERIC_ERROR,
                  ),
                  childRight: CustomDatePickerTitle(
                    labelText: StringConst.INITIAL_DATE,
                    initialValue: _formationBagDate,
                    onChanged: (value) {
                      _formationBagDate = value;
                    },
                    enabled: !_finished,
                    validator: (value) =>
                    (value != null) ? null : StringConst.FORM_GENERIC_ERROR,
                  ),
                ),
                SpaceH12(),
                CustomTextFormFieldTitle(
                  labelText: StringConst.INITIAL_MOTIVE,
                  initialValue: _formationBagMotive,
                  onChanged: (value) {
                    _formationBagMotive = value ?? '';
                  },
                  validator: (value) => (value!.isNotEmpty || value != '')
                      ? null
                      : StringConst.FORM_GENERIC_ERROR,
                  enabled: !_finished,
                ),
                SpaceH12(),
                CustomTextFormFieldTitle(
                  labelText: StringConst.FOLLOW_ECONOMIC_AMOUNT,
                  initialValue: _formationBagEconomic,
                  onChanged: (value) {
                    _formationBagEconomic = value ?? '';
                  },
                  validator: (value) => (value!.isNotEmpty || value != '')
                      ? null
                      : StringConst.FORM_GENERIC_ERROR,
                  enabled: !_finished,
                ),


                informSubSectionTitle(StringConst.FOLLOW_JOB, false, false, (){}),

                _laborSituationNotifier.value == ''
                    ? CustomDropDownButtonFormFieldTittle(
                  labelText: StringConst.FOLLOW_JOB_ACHIEVEMENT,
                  source: StringConst.LABOR_SITUATION_SELECTION,
                  onChanged: _finished
                      ? null
                      : (value) {
                    _laborSituationNotifier.value = value!;
                  },
                  validator: (value) =>
                  value != null ? null : StringConst.FORM_GENERIC_ERROR,
                )
                    : CustomDropDownButtonFormFieldTittle(
                  labelText: StringConst.FOLLOW_JOB_ACHIEVEMENT,
                  source: StringConst.LABOR_SITUATION_SELECTION,
                  value: _laborSituationNotifier.value,
                  onChanged: _finished
                      ? null
                      : (value) {
                    _laborSituationNotifier.value = value!;
                  },
                  validator: (value) =>
                  value != null ? null : StringConst.FORM_GENERIC_ERROR,
                ),

                SpaceH12(),
                ValueListenableBuilder(
                    valueListenable: _laborSituationNotifier,
                    builder: (context, value, child){
                      return  _laborSituationNotifier.value == 'Ocupada cuenta ajena' || _laborSituationNotifier.value == 'Ocupada cuenta propia' ? CustomFlexRowColumn(
                        contentPadding: EdgeInsets.zero,
                        separatorSize: 20,
                        childLeft: _tempLabor == ''
                            ? CustomDropDownButtonFormFieldTittle(
                          labelText: StringConst.INITIAL_TEMP,
                          source: StringConst.TEMP_SELECTION,
                          onChanged: _finished
                              ? null
                              : (value) {
                            _tempLabor = value;
                          },
                          validator: (value) => value != null
                              ? null
                              : StringConst.FORM_GENERIC_ERROR,
                        )
                            : CustomDropDownButtonFormFieldTittle(
                          labelText: StringConst.INITIAL_TEMP,
                          source: StringConst.TEMP_SELECTION,
                          value: _tempLabor,
                          onChanged: _finished
                              ? null
                              : (value) {
                            _tempLabor = value;
                          },
                          validator: (value) => value != null
                              ? null
                              : StringConst.FORM_GENERIC_ERROR,
                        ),
                        childRight: _workingDayLabor == ''
                            ? CustomDropDownButtonFormFieldTittle(
                          labelText: StringConst.INITIAL_LABOR_TYPE,
                          source: StringConst.WORK_DAY_SELECTION,
                          onChanged: _finished
                              ? null
                              : (value) {
                            _workingDayLabor = value;
                          },
                          validator: (value) => value != null
                              ? null
                              : StringConst.FORM_GENERIC_ERROR,
                        )
                            : CustomDropDownButtonFormFieldTittle(
                          labelText: StringConst.INITIAL_LABOR_TYPE,
                          source: StringConst.WORK_DAY_SELECTION,
                          value: _workingDayLabor,
                          onChanged: _finished
                              ? null
                              : (value) {
                            _workingDayLabor = value;
                          },
                          validator: (value) => value != null
                              ? null
                              : StringConst.FORM_GENERIC_ERROR,
                        ),
                      ) :
                      Container();
                    }
                ),
                SpaceH12(),
                CustomFlexRowColumn(
                  contentPadding: EdgeInsets.zero,
                  separatorSize: 20,
                  childLeft: CustomDatePickerTitle(
                    labelText: StringConst.FOLLOW_OBTAIN_DATE,
                    initialValue: _jobObtainDate,
                    onChanged: (value) {
                      _jobObtainDate = value;
                    },
                    enabled: !_finished,
                    validator: (value) =>
                    (value != null) ? null : StringConst.FORM_GENERIC_ERROR,
                  ),
                  childRight: CustomDatePickerTitle(
                    labelText: StringConst.FOLLOW_FINISH_DATE,
                    initialValue: _jobFinishDate,
                    onChanged: (value) {
                      _jobFinishDate = value;
                    },
                    enabled: !_finished,
                    validator: (value) =>
                    (value != null) ? null : StringConst.FORM_GENERIC_ERROR,
                  ),
                ),
                SpaceH12(),
                CustomFlexRowColumn(
                  contentPadding: EdgeInsets.zero,
                  separatorSize: 20,
                  childLeft: _jobUpgrade == ''
                      ? CustomDropDownButtonFormFieldTittle(
                    labelText: StringConst.FOLLOW_JOB_UPGRADE,
                    source: StringConst.YES_NO_SELECTION,
                    onChanged: _finished
                        ? null
                        : (value) {
                      _jobUpgrade = value;
                    },
                    validator: (value) => value != null
                        ? null
                        : StringConst.FORM_GENERIC_ERROR,
                  )
                      : CustomDropDownButtonFormFieldTittle(
                    labelText: StringConst.FOLLOW_JOB_UPGRADE,
                    source: StringConst.YES_NO_SELECTION,
                    value: _jobUpgrade,
                    onChanged: _finished
                        ? null
                        : (value) {
                      _jobUpgrade = value;
                    },
                    validator: (value) => value != null
                        ? null
                        : StringConst.FORM_GENERIC_ERROR,
                  ),
                  childRight: CustomDatePickerTitle(
                    labelText: StringConst.INITIAL_DATE,
                    initialValue: _upgradeDate,
                    onChanged: (value) {
                      _upgradeDate = value;
                    },
                    enabled: !_finished,
                    validator: (value) =>
                    (value != null) ? null : StringConst.FORM_GENERIC_ERROR,
                  ),
                ),
                SpaceH12(),
                CustomTextFormFieldTitle(
                  labelText: StringConst.FOLLOW_JOB_UPGRADE_MOTIVE,
                  initialValue: _upgradeMotive,
                  onChanged: (value) {
                    _upgradeMotive = value ?? '';
                  },
                  validator: (value) => (value!.isNotEmpty || value != '')
                      ? null
                      : StringConst.FORM_GENERIC_ERROR,
                  enabled: !_finished,
                ),

                ValueListenableBuilder(
                    valueListenable: _allow9Notifier,
                    builder: (context, value, child){
                      return             ValueListenableBuilder(
                          valueListenable: _allow9_6Notifier,
                          builder: (context, value, child){
                            return informSubSectionTitle(StringConst.FOLLOW_TITLE_9_6_POST_LABOR_ACCOMPANIMENT, _allow9Notifier.value, _allow9_6Notifier.value, (){_allow9_6Notifier.value = !_allow9_6Notifier.value;});
                          }
                      );
                    }
                ),
                CustomTextFormFieldTitle(
                  labelText: StringConst.INITIAL_OBSERVATIONS,
                  initialValue: _orientation9_6,
                  onChanged: (value) {
                    _orientation9_6 = value ?? '';
                  },
                  validator: (value) => (value!.isNotEmpty || value != '')
                      ? null
                      : StringConst.FORM_GENERIC_ERROR,
                  enabled: !_finished,
                ),
                SpaceH12(),
                _postLaborAccompanimentNotifier.value == ''
                    ? CustomDropDownButtonFormFieldTittle(
                  labelText: StringConst.FOLLOW_TITLE_POST_LABOR_ACCOMPANIMENT,
                  source: StringConst.YES_NO_SELECTION,
                  onChanged: _finished
                      ? null
                      : (value) {
                    _postLaborAccompanimentNotifier.value = value!;
                  },
                  validator: (value) => value != null
                      ? null
                      : StringConst.FORM_GENERIC_ERROR,
                )
                    : CustomDropDownButtonFormFieldTittle(
                  labelText: StringConst.FOLLOW_TITLE_POST_LABOR_ACCOMPANIMENT,
                  source: StringConst.YES_NO_SELECTION,
                  value: _postLaborAccompanimentNotifier.value,
                  onChanged: _finished
                      ? null
                      : (value) {
                    _postLaborAccompanimentNotifier.value = value!;
                  },
                  validator: (value) => value != null
                      ? null
                      : StringConst.FORM_GENERIC_ERROR,
                ),
                SpaceH12(),
                ValueListenableBuilder(
                    valueListenable: _postLaborAccompanimentNotifier,
                    builder: (context, value, child){
                      return _postLaborAccompanimentNotifier.value == 'No' ? Column(
                        children: [
                          CustomTextFormFieldTitle(
                            labelText: StringConst.INITIAL_MOTIVE,
                            initialValue: _postLaborAccompanimentMotive,
                            onChanged: (value) {
                              _postLaborAccompanimentMotive = value ?? '';
                            },
                            validator: (value) => (value!.isNotEmpty || value != '')
                                ? null
                                : StringConst.FORM_GENERIC_ERROR,
                            enabled: !_finished,
                          ),
                          SpaceH12(),
                        ],
                      ) : Container();
                    }
                ),
                CustomFlexRowColumn(
                  contentPadding: EdgeInsets.zero,
                  separatorSize: 20,
                  childLeft: CustomDatePickerTitle(
                    labelText: StringConst.FOLLOW_INIT_DATE,
                    initialValue: _postLaborInitialDate,
                    onChanged: (value) {
                      _postLaborInitialDate = value;
                      if(_postLaborInitialDate != null && _postLaborFinalDate != null){
                        _totalDaysNotifier.value = _postLaborFinalDate!.difference(_postLaborInitialDate!).inDays;
                        _totalDaysController.text = _totalDaysNotifier.value.toString();
                      }
                    },
                    enabled: !_finished,
                    validator: (value) =>
                    (value != null) ? null : StringConst.FORM_GENERIC_ERROR,
                  ),
                  childRight: CustomDatePickerTitle(
                    labelText: StringConst.FOLLOW_END_DATE,
                    initialValue: _postLaborFinalDate,
                    onChanged: (value) {
                      _postLaborFinalDate = value;
                      if(_postLaborInitialDate != null && _postLaborFinalDate != null){
                        _totalDaysNotifier.value = _postLaborFinalDate!.difference(_postLaborInitialDate!).inDays;
                        _totalDaysController.text = _totalDaysNotifier.value.toString();
                      }
                    },
                    enabled: !_finished,
                    validator: (value) =>
                    (value != null) ? null : StringConst.FORM_GENERIC_ERROR,
                  ),
                ),
                SpaceH12(),
                ValueListenableBuilder(
                    valueListenable: _totalDaysNotifier,
                    builder: (context, value, child){
                      return CustomTextFormFieldTitle(
                        labelText: StringConst.FOLLOW_POST_LABOR_TOTAL_DAYS,
                        controller: _totalDaysController,
                        enabled: false,
                      );
                    }
                ),
                SpaceH12(),
                _jobMaintenance == ''
                    ? CustomDropDownButtonFormFieldTittle(
                  labelText: StringConst.FOLLOW_JOB_MAINTENANCE,
                  source: StringConst.YES_NO_SELECTION,
                  onChanged: _finished
                      ? null
                      : (value) {
                    _jobMaintenance = value;
                  },
                  validator: (value) => value != null
                      ? null
                      : StringConst.FORM_GENERIC_ERROR,
                )
                    : CustomDropDownButtonFormFieldTittle(
                  labelText: StringConst.FOLLOW_JOB_MAINTENANCE,
                  source: StringConst.YES_NO_SELECTION,
                  value: _jobMaintenance,
                  onChanged: _finished
                      ? null
                      : (value) {
                    _jobMaintenance = value;
                  },
                  validator: (value) => value != null
                      ? null
                      : StringConst.FORM_GENERIC_ERROR,
                ),
              ],
            ) : Container(),


            SpaceH12(),
            ValueListenableBuilder(
                valueListenable: _techNameNotifier,
                builder:(context, value, child){
                  return TextFormField(
                    controller: _techPersonController,
                    enabled: false,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      color: AppColors.turquoiseBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: GoogleFonts.inter().fontFamily,
                    ),
                  );
                }
            ),


            _finished
                ? Container()
                : Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 30),
              child: Center(
                child: Container(
                  height: 50,
                  width: 250,
                  child: ElevatedButton(
                      onPressed: () async {
                        database.setDerivationReport(DerivationReport(
                          userId: report.userId,
                          derivationReportId: report.derivationReportId,
                          subsidy: _subsidy,
                          techPerson: _techPerson,
                          addressedTo: _addressedTo,
                          objectiveDerivation: _objectiveDerivation,
                          orientation1: _orientation1,
                          arriveDate: _arriveDate,
                          receptionResources: _receptionResources,
                          administrativeExternalResources:
                          _administrativeExternalResources,
                          expirationDate: _expirationDate,
                          adminState: _adminStateNotifier.value,
                          adminNoThrough: _adminNoThrough,
                          adminDateAsk: _adminDateAsk,
                          adminDateResolution: _adminDateResolution,
                          adminDateConcession: _adminDateConcession,
                          adminTemp: _adminTempNotifier.value,
                          adminResidenceWork: _adminResidenceWork,
                          adminDateRenovation: _adminDateRenovation,
                          adminResidenceType: _adminResidenceType,
                          adminJuridicFigure: _adminJuridicFigureNotifier.value,
                          adminOther: _adminOther,
                          orientation2: _orientation2,
                          healthCard: _healthCard,
                          medication: _medication,
                          orientation2_1: _orientation2_1,
                          rest: _rest,
                          diagnosis: _diagnosis,
                          treatment: _treatment,
                          tracking: _tracking,
                          orientation2_2: _orientation2_2,
                          disabilityState: _disabilityStateNotifier.value,
                          referenceProfessionalDisability:
                          _referenceProfessionalDisability,
                          disabilityGrade: _disabilityGrade,
                          disabilityType: _disabilityType,
                          granted: _grantedNotifier.value,
                          revisionDate: _revisionDate,
                          orientation2_3: _orientation2_3,
                          dependenceState: _dependenceState,
                          referenceProfessionalDependence:
                          _referenceProfessionalDependence,
                          dependenceGrade: _dependenceGrade,
                          orientation2_4: _orientation2_4,
                          externalDerivation: _externalDerivation,
                          motive: _motive,
                          orientation3: _orientation3,
                          internalDerivationLegal:
                          _internalDerivationLegal,
                          internalDerivationDate: _internalDerivationDate,
                          internalDerivationMotive: _internalDerivationMotive,
                          externalDerivationLegal: _externalDerivationLegal,
                          externalDerivationDate: _externalDerivationDate,
                          externalDerivationMotive: _externalDerivationMotive,
                          psychosocialDerivationLegal: _psychosocialDerivationLegal,
                          psychosocialDerivationDate: _psychosocialDerivationDate,
                          psychosocialDerivationMotive: _psychosocialDerivationMotive,
                          legalRepresentation: _legalRepresentation,
                          processingBag: _processingBag,
                          processingBagDate: _processingBagDate,
                          economicAmount: _economicAmount,
                          orientation4: _orientation4,
                          ownershipType: _ownershipTypeNotifier.value,
                          location: _location,
                          centerContact: _centerContact,
                          hostingObservations: _hostingObservations,
                          ownershipTypeOpen: _ownershipTypeOpen,
                          homelessnessSituation: _homelessnessSituationNotifier.value,
                          homelessnessSituationOpen: _homelessnessSituationOpen,
                          livingUnit: _livingUnit,
                          ownershipTypeConcrete: _ownershipTypeConcreteNotifier.value,
                          orientation5: _orientation5,
                          informationNetworks: _informationNetworks,
                          institutionNetworks: _institutionNetworks,
                          familyConciliation: _familyConciliation,
                          orientation7: _orientation7,
                          languages: _languagesNotifier.value,
                          orientation9: _orientation9,
                          centerTSReference: _centerTSReference,
                          subsidyBeneficiary: _subsidyBeneficiaryNotifier.value,
                          socialExclusionCertificate:
                          _socialExclusionCertificateNotifier.value,
                          subsidyName: _subsidyName,
                          socialExclusionCertificateDate: _socialExclusionCertificateDate,
                          socialExclusionCertificateObservations: _socialExclusionCertificateObservations,
                          orientation12: _orientation12,
                          vulnerabilityOptions: _vulnerabilityOptions,
                          orientation13: _orientation13,
                          orientation13_2: _orientation13_2,
                          educationLevel: _educationLevel,
                          laborSituation: _laborSituationNotifier.value,
                          tempLabor: _tempLabor,
                          workingDayLabor: _workingDayLabor,
                          competencies: _competencies,
                          contextualization: _contextualization,
                          connexion: _connexion,
                          shortTerm: _shortTerm,
                          mediumTerm: _mediumTerm,
                          longTerm: _longTerm,
                          orientation9_5: _orientation9_5,
                          formations: _formationsNotifier.value,
                          formationBag: _formationBag,
                          formationBagDate: _formationBagDate,
                          formationBagMotive: _formationBagMotive,
                          formationBagEconomic: _formationBagEconomic,
                          jobObtaining: _jobObtaining,
                          jobObtainDate: _jobObtainDate,
                          jobFinishDate: _jobFinishDate,
                          jobUpgrade: _jobUpgrade,
                          upgradeMotive: _upgradeMotive,
                          upgradeDate: _upgradeDate,
                          orientation9_6: _orientation9_6,
                          postLaborAccompaniment: _postLaborAccompanimentNotifier.value,
                          postLaborAccompanimentMotive: _postLaborAccompanimentMotive,
                          postLaborInitialDate: _postLaborInitialDate,
                          postLaborFinalDate: _postLaborFinalDate,
                          postLaborTotalDays: int.parse(_totalDaysController.text),
                          jobMaintenance: _jobMaintenance,
                          allow1: _allow1Notifier.value,
                          allow1_1: _allow1_1Notifier.value,
                          allow2: _allow2Notifier.value,
                          allow2_1: _allow2_1Notifier.value,
                          allow2_2: _allow2_2Notifier.value,
                          allow2_3: _allow2_3Notifier.value,
                          allow2_4: _allow2_4Notifier.value,
                          allow3: _allow3Notifier.value,
                          allow4: _allow4Notifier.value,
                          allow5: _allow5Notifier.value,
                          allow6: _allow6Notifier.value,
                          allow7: _allow7Notifier.value,
                          allow8: _allow8Notifier.value,
                          allow9: _allow9Notifier.value,
                          allow9_2: _allow9_2Notifier.value,
                          allow9_3: _allow9_3Notifier.value,
                          allow9_4: _allow9_4Notifier.value,
                          allow9_5: _allow9_5Notifier.value,
                          allow9_6: _allow9_6Notifier.value,
                          finished: false,
                        ));
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                title:
                                Text('Se ha guardado con exito',
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
                                        padding:
                                        const EdgeInsets.all(8.0),
                                        child: Text('Ok',
                                            style: TextStyle(
                                                color:
                                                AppColors.black,
                                                height: 1.5,
                                                fontWeight:
                                                FontWeight.w400,
                                                fontSize: 14)),
                                      )),
                                ]));
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
                      )),
                ),
              ),
            ),

            _finished
                ? Container()
                : Center(
              child: Container(
                height: 50,
                width: 160,
                child: ElevatedButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                  'Aún quedan campos por completar',
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
                                      padding:
                                      const EdgeInsets.all(8.0),
                                      child: Text('Ok',
                                          style: TextStyle(
                                              color: AppColors.black,
                                              height: 1.5,
                                              fontWeight:
                                              FontWeight.w400,
                                              fontSize: 14)),
                                    )),
                              ],
                            ));
                        return;
                      }
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
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
                                      database.setDerivationReport(
                                          DerivationReport(
                                            userId: report.userId,
                                            derivationReportId:
                                            report.derivationReportId,
                                            subsidy: _subsidy,
                                            techPerson: _techPerson,
                                            addressedTo: _addressedTo,
                                            objectiveDerivation: _objectiveDerivation,
                                            orientation1: _orientation1,
                                            arriveDate: _arriveDate,
                                            receptionResources:
                                            _receptionResources,
                                            administrativeExternalResources:
                                            _administrativeExternalResources,
                                            expirationDate:
                                            _expirationDate,
                                            adminState: _adminStateNotifier.value,
                                            adminNoThrough: _adminNoThrough,
                                            adminDateAsk: _adminDateAsk,
                                            adminDateResolution: _adminDateResolution,
                                            adminDateConcession: _adminDateConcession,
                                            adminTemp: _adminTempNotifier.value,
                                            adminResidenceWork: _adminResidenceWork,
                                            adminDateRenovation: _adminDateRenovation,
                                            adminResidenceType: _adminResidenceType,
                                            adminJuridicFigure: _adminJuridicFigureNotifier.value,
                                            adminOther: _adminOther,
                                            orientation2: _orientation2,
                                            healthCard: _healthCard,
                                            medication: _medication,
                                            orientation2_1:
                                            _orientation2_1,
                                            rest: _rest,
                                            diagnosis: _diagnosis,
                                            treatment: _treatment,
                                            tracking: _tracking,
                                            orientation2_2:
                                            _orientation2_2,
                                            disabilityState:
                                            _disabilityStateNotifier
                                                .value,
                                            referenceProfessionalDisability:
                                            _referenceProfessionalDisability,
                                            disabilityGrade:
                                            _disabilityGrade,
                                            disabilityType:
                                            _disabilityType,
                                            granted: _grantedNotifier.value,
                                            revisionDate: _revisionDate,
                                            orientation2_3:
                                            _orientation2_3,
                                            dependenceState:
                                            _dependenceState,
                                            referenceProfessionalDependence:
                                            _referenceProfessionalDependence,
                                            dependenceGrade:
                                            _dependenceGrade,
                                            orientation2_4:
                                            _orientation2_4,
                                            externalDerivation:
                                            _externalDerivation,
                                            motive: _motive,
                                            orientation3: _orientation3,
                                            internalDerivationLegal:
                                            _internalDerivationLegal,
                                            internalDerivationDate: _internalDerivationDate,
                                            internalDerivationMotive: _internalDerivationMotive,
                                            externalDerivationLegal: _externalDerivationLegal,
                                            externalDerivationDate: _externalDerivationDate,
                                            externalDerivationMotive: _externalDerivationMotive,
                                            psychosocialDerivationLegal: _psychosocialDerivationLegal,
                                            psychosocialDerivationDate: _psychosocialDerivationDate,
                                            psychosocialDerivationMotive: _psychosocialDerivationMotive,
                                            legalRepresentation:
                                            _legalRepresentation,
                                            processingBag: _processingBag,
                                            processingBagDate: _processingBagDate,
                                            economicAmount: _economicAmount,
                                            orientation4: _orientation4,
                                            ownershipType: _ownershipTypeNotifier.value,
                                            location: _location,
                                            centerContact: _centerContact,
                                            hostingObservations:
                                            _hostingObservations,
                                            ownershipTypeOpen: _ownershipTypeOpen,
                                            homelessnessSituation: _homelessnessSituationNotifier.value,
                                            homelessnessSituationOpen: _homelessnessSituationOpen,
                                            livingUnit: _livingUnit,
                                            ownershipTypeConcrete: _ownershipTypeConcreteNotifier.value,
                                            orientation5: _orientation5,
                                            informationNetworks:
                                            _informationNetworks,
                                            institutionNetworks:
                                            _institutionNetworks,
                                            familyConciliation:
                                            _familyConciliation,
                                            orientation7: _orientation7,
                                            languages: _languagesNotifier.value,
                                            orientation9: _orientation9,
                                            centerTSReference:
                                            _centerTSReference,
                                            subsidyBeneficiary: _subsidyBeneficiaryNotifier.value,
                                            socialExclusionCertificate:
                                            _socialExclusionCertificateNotifier.value,
                                            subsidyName: _subsidyName,
                                            socialExclusionCertificateDate: _socialExclusionCertificateDate,
                                            socialExclusionCertificateObservations: _socialExclusionCertificateObservations,
                                            orientation12: _orientation12,
                                            vulnerabilityOptions:
                                            _vulnerabilityOptions,
                                            orientation13: _orientation13,
                                            orientation13_2: _orientation13_2,
                                            educationLevel:
                                            _educationLevel,
                                            laborSituation:
                                            _laborSituationNotifier.value,
                                            tempLabor: _tempLabor,
                                            workingDayLabor:
                                            _workingDayLabor,
                                            competencies: _competencies,
                                            contextualization:
                                            _contextualization,
                                            connexion: _connexion,
                                            shortTerm: _shortTerm,
                                            mediumTerm: _mediumTerm,
                                            longTerm: _longTerm,
                                            orientation9_5: _orientation9_5,
                                            formations: _formationsNotifier.value,
                                            formationBag: _formationBag,
                                            formationBagDate: _formationBagDate,
                                            formationBagMotive: _formationBagMotive,
                                            formationBagEconomic: _formationBagEconomic,
                                            jobObtaining: _jobObtaining,
                                            jobObtainDate: _jobObtainDate,
                                            jobFinishDate: _jobFinishDate,
                                            jobUpgrade: _jobUpgrade,
                                            upgradeMotive: _upgradeMotive,
                                            upgradeDate: _upgradeDate,
                                            orientation9_6: _orientation9_6,
                                            postLaborAccompaniment: _postLaborAccompanimentNotifier.value,
                                            postLaborAccompanimentMotive: _postLaborAccompanimentMotive,
                                            postLaborInitialDate: _postLaborInitialDate,
                                            postLaborFinalDate: _postLaborFinalDate,
                                            postLaborTotalDays: int.parse(_totalDaysController.text),
                                            jobMaintenance: _jobMaintenance,
                                            allow1: _allow1Notifier.value,
                                            allow1_1: _allow1_1Notifier.value,
                                            allow2: _allow2Notifier.value,
                                            allow2_1: _allow2_1Notifier.value,
                                            allow2_2: _allow2_2Notifier.value,
                                            allow2_3: _allow2_3Notifier.value,
                                            allow2_4: _allow2_4Notifier.value,
                                            allow3: _allow3Notifier.value,
                                            allow4: _allow4Notifier.value,
                                            allow5: _allow5Notifier.value,
                                            allow6: _allow6Notifier.value,
                                            allow7: _allow7Notifier.value,
                                            allow8: _allow8Notifier.value,
                                            allow9: _allow9Notifier.value,
                                            allow9_2: _allow9_2Notifier.value,
                                            allow9_3: _allow9_3Notifier.value,
                                            allow9_4: _allow9_4Notifier.value,
                                            allow9_5: _allow9_5Notifier.value,
                                            allow9_6: _allow9_6Notifier.value,
                                            finished: true,
                                            completedDate: DateTime.now(),
                                          ));
                                      Navigator.of(context).pop();
                                      setStateMenuPage();
                                    },
                                    child: Padding(
                                      padding:
                                      const EdgeInsets.all(8.0),
                                      child: Text('Si',
                                          style: TextStyle(
                                              color: AppColors.black,
                                              height: 1.5,
                                              fontWeight:
                                              FontWeight.w400,
                                              fontSize: 14)),
                                    )),
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Padding(
                                      padding:
                                      const EdgeInsets.all(8.0),
                                      child: Text('No',
                                          style: TextStyle(
                                              color: AppColors.black,
                                              height: 1.5,
                                              fontWeight:
                                              FontWeight.w400,
                                              fontSize: 14)),
                                    )),
                              ]));
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
                    )),
              ),
            ),

            SpaceH40(),
          ],
        ),
      ),
    );
  }
}