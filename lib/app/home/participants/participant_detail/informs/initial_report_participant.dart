import 'package:enreda_empresas/app/common_widgets/alert_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/custom_date_picker_title.dart';
import 'package:enreda_empresas/app/common_widgets/custom_drop_down_button_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/custom_multi_selection_radio_list.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/flex_row_column.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/participant_social_reports_page.dart';
import 'package:enreda_empresas/app/models/initialReport.dart';
import 'package:enreda_empresas/app/models/languageReport.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/notifier_initi.dart';
import 'package:enreda_empresas/app/models/program.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../common_widgets/custom_date_picker_open.dart';
import '../../../../utils/adaptative.dart';
import '../../../../utils/responsive.dart';

class InitialReportForm extends StatefulWidget {
  const InitialReportForm({super.key, required this.user});

  final UserEnreda user;

  @override
  State<InitialReportForm> createState() => _InitialReportFormState();
}

class _InitialReportFormState extends State<InitialReportForm> {
  late Widget currentPage;
  final ValueNotifier<String> _techNameNotifier =
    ValueNotifier<String>('');
  final ValueNotifier<String> _disabilityStateNotifier =
      ValueNotifier<String>('');
  final ValueNotifier<String> _grantedNotifier =
    ValueNotifier<String>('');
  final _languagesInit = NotifierInit<LanguageReport>(
    [LanguageReport(name: '', level: '', accreditation: '')],
  );
  final ValueNotifier<String> _laborSituationNotifier =
    ValueNotifier<String>('');
  final ValueNotifier<String> _adminStateNotifier =
    ValueNotifier<String>('');
  final ValueNotifier<String> _adminTempNotifier =
    ValueNotifier<String>('');
  String? _selectedProgramId;
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

  final TextEditingController _techPersonController = TextEditingController();

  InitialReport initialReportSaved = InitialReport();

  late final Map<String, TextEditingController> _controllers;
  late Map<String, DateTime?> _dateValues;
  late final Map<String, List<String>> _listValues;

  @override
  void initState() {
    _controllers = {
      'subsidy': TextEditingController(),
      'techPerson': TextEditingController(),
      'dniParticipant': TextEditingController(),
      'orientation1': TextEditingController(),
      'receptionResources': TextEditingController(),
      'administrativeExternalResources': TextEditingController(),
      'adminResidenceWork': TextEditingController(),
      'adminResidenceType': TextEditingController(),
      'adminOther': TextEditingController(),
      'orientation2': TextEditingController(),
      'healthCard': TextEditingController(),
      'medication': TextEditingController(),
      'orientation2_1': TextEditingController(),
      'adminNoThrough': TextEditingController(),
      'rest': TextEditingController(),
      'diagnosis': TextEditingController(),
      'treatment': TextEditingController(),
      'tracking': TextEditingController(),
      'orientation2_2': TextEditingController(),
      'referenceProfessionalDisability': TextEditingController(),
      'disabilityGrade': TextEditingController(),
      'disabilityType': TextEditingController(),
      'orientation2_3': TextEditingController(),
      'dependenceState': TextEditingController(),
      'referenceProfessionalDependence': TextEditingController(),
      'dependenceGrade': TextEditingController(),
      'orientation2_4': TextEditingController(),
      'externalDerivation': TextEditingController(),
      'motive': TextEditingController(),
      'orientation3': TextEditingController(),
      'internalDerivationLegal': TextEditingController(),
      'internalDerivationMotive': TextEditingController(),
      'externalDerivationLegal': TextEditingController(),
      'externalDerivationMotive': TextEditingController(),
      'psychosocialDerivationLegal': TextEditingController(),
      'psychosocialDerivationMotive': TextEditingController(),
      'legalRepresentation': TextEditingController(),
      'orientation4': TextEditingController(),
      'ownershipTypeOpen': TextEditingController(),
      'homelessnessSituationOpen': TextEditingController(),
      'livingUnit': TextEditingController(),
      'location': TextEditingController(),
      'centerContact': TextEditingController(),
      'orientation5': TextEditingController(),
      'informationNetworks': TextEditingController(),
      'institutionNetworks': TextEditingController(),
      'familyConciliation': TextEditingController(),
      'orientation7': TextEditingController(),
      'subsidyName': TextEditingController(),
      'socialExclusionCertificateObservations': TextEditingController(),
      'orientation9': TextEditingController(),
      'centerTSReference': TextEditingController(),
      'orientation12': TextEditingController(),
      'orientation13': TextEditingController(),
      'orientation13_2': TextEditingController(),
      'educationLevel': TextEditingController(),
      'homologation': TextEditingController(),
      'laborOtherConsiderations': TextEditingController(),
      'tempLabor': TextEditingController(),
      'workingDayLabor': TextEditingController(),
      'competencies': TextEditingController(),
      'contextualization': TextEditingController(),
      'connexion': TextEditingController(),
      'shortTerm': TextEditingController(),
      'mediumTerm': TextEditingController(),
      'longTerm': TextEditingController(),
    };
    _selectedProgramId = widget.user.programId;
    _dateValues = {
      'arriveDate': null,
      'completedDate': widget.user.startDateItinerary ?? DateTime.now(),
      'adminDateAsk': null,
      'adminDateResolution': null,
      'adminDateConcession': null,
      'adminDateRenovation': null,
      'expirationDate': null,
      'revisionDate': null,
      'internalDerivationDate': null,
      'externalDerivationDate': null,
      'psychosocialDerivationDate': null,
      'socialExclusionCertificateDate': null,
    };
    _listValues = {
      'hostingObservations': [],
      'vulnerabilityOptions': [],
    };
    super.initState();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return initialReport(context, widget.user);
  }

  void _addLanguage(){
    final newLanguages = List<LanguageReport>.from(_languagesInit.notifier.value)..add(LanguageReport(name: '', level: '', accreditation: ''));
    _languagesInit.notifier.value = newLanguages;
  }

  Widget initialReport(BuildContext context, UserEnreda user) {
    final database = Provider.of<Database>(context, listen: true);

    return Container(
      padding: Responsive.isMobile(context) ? EdgeInsets.zero : EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.greyBorder)),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SpaceW8(),
            IconButton(
              onPressed: () => setState(() {
                ParticipantSocialReportPage.selectedIndexInforms.value = 0;
              }),
              icon: Icon(Icons.arrow_back_rounded),
              iconSize: 30,
              color: AppColors.turquoiseBlue,
            ),
            SpaceW8(),
            CustomTextBoldTitle(title: 'Informe inicial'.toUpperCase()),
          ],
        ),
        Divider(
          color: AppColors.greyBorder,
        ),
        StreamBuilder(
            stream: database.userEnredaStreamByUserId(user.userId),
            builder: (context, snapshotUser) {
              if (snapshotUser.hasData) {
                UserEnreda userStream = snapshotUser.data!;
                return StreamBuilder<InitialReport>(
                    stream: database.initialReportsStreamByUserId(user.userId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        initialReportSaved = snapshot.data!;
                        return completeInitialForm(
                            context, initialReportSaved);
                      }
                      else {
                        if (userStream.initialReportId == null) {
                          database.addInitialReport(InitialReport(
                            userId: user.userId,
                          ));
                          if(initialReportSaved.userId != null){
                            setState(() {
                              widget.user.initialReportId = initialReportSaved.initialReportId;
                            });
                            database.setUserEnreda(widget.user);
                          }
                        }
                        return Container(
                          height: 300,
                        );
                      }
                    });
              }
              return Container(
                height: 300,
              );
            }),
      ]),
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
          fontFamily: GoogleFonts.outfit().fontFamily,
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
          fontFamily: GoogleFonts.outfit().fontFamily,
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
        for (var option in options)
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

  Widget multiSelectionListTitle(
      BuildContext context, List<String> options, String title) {
    final textTheme = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          title,
          style: textTheme.bodySmall?.copyWith(
            height: 1.5,
            color: AppColors.greyDark,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      Container(
        height: 50,
        child: Center(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (var option in options)
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
        )),
      ),
    ]);
  }

  Widget addLanguageButton() {
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
        onTap: () {
          _addLanguage();
        });
  }

  void sanitizeLanguageLevels() {
    final current = _languagesInit.notifier.value;
    bool modified = false;

    final updated = List<LanguageReport>.from(current);
    for (int i = 0; i < updated.length; i++) {
      if (!StringConst.LANGUAGE_LEVEL_SELECTION.any((item) => item.value == updated[i].level)) {
        updated[i] = updated[i].copyWith(level: '');
        modified = true;
      }
    }

    if (modified) {
      _languagesInit.notifier.value = updated;
    }
  }

  Widget completeInitialForm(BuildContext context, InitialReport report) {
    final database = Provider.of<Database>(context, listen: false);
    final _formKey = GlobalKey<FormState>();
    final textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 13, 20, md: 16);
    double fontSizeSubTitle = responsiveSize(context, 14, 18, md: 15);
    bool _finished = report.finished ?? false;

    //Pre-Selection
    if (_controllers['subsidy']!.text.trim().isEmpty) {
      _controllers['subsidy']!.text = report.subsidy ?? '';
    }
    if (_selectedProgramId == null && widget.user.programId != null) {
      _selectedProgramId = widget.user.programId;
    }
    if (_controllers['techPerson']!.text.trim().isEmpty) {
      _controllers['techPerson']!.text = report.techPerson ?? widget.user.assignedById ?? '';
    } 
    if (_dateValues['completedDate'] == null) {
      _dateValues['completedDate'] = report.completedDate ?? widget.user.startDateItinerary ?? DateTime.now();
    } 
    if (_controllers['dniParticipant']!.text.trim().isEmpty) {
      _controllers['dniParticipant']!.text = report.dniParticipant ?? '';
    }

    //Section 1
    if (_controllers['orientation1']!.text.trim().isEmpty) {
      _controllers['orientation1']!.text = report.orientation1 ?? '';
    }
    if (_dateValues['arriveDate'] == null) {
      _dateValues['arriveDate'] = report.arriveDate;
    }
    if (_controllers['receptionResources']!.text.trim().isEmpty) {
      _controllers['receptionResources']!.text = report.receptionResources ?? '';
    }
    if (_controllers['administrativeExternalResources']!.text.trim().isEmpty) {
      _controllers['administrativeExternalResources']!.text = report.administrativeExternalResources ?? '';
    }


    //Section 1.1
    if (_adminStateNotifier.value == '' &&
        report.adminState != null) {
      _adminStateNotifier.value = report.adminState!;
    }
    if (_controllers['adminNoThrough']!.text.trim().isEmpty) {
      _controllers['adminNoThrough']!.text = report.adminNoThrough ?? '';
    }
    if (_dateValues['adminDateAsk'] == null) {
      _dateValues['adminDateAsk'] = report.adminDateAsk;
    }
    if (_dateValues['adminDateResolution'] == null) {
      _dateValues['adminDateResolution'] = report.adminDateResolution;
    }
    if (_dateValues['adminDateConcession'] == null) {
      _dateValues['adminDateConcession'] = report.adminDateConcession;
    }
    if (_adminTempNotifier.value == '' &&
        report.adminTemp != null) {
      _adminTempNotifier.value = report.adminTemp!;
    }
    if (_adminJuridicFigureNotifier.value == '' &&
        report.adminJuridicFigure != null) {
      _adminJuridicFigureNotifier.value = report.adminJuridicFigure!;
    }
    if (_controllers['adminResidenceWork']!.text.trim().isEmpty) {
      _controllers['adminResidenceWork']!.text = report.adminResidenceWork ?? '';
    }
    if (_dateValues['adminDateRenovation'] == null) {
      _dateValues['adminDateRenovation'] = report.adminDateRenovation;
    }
    if (_controllers['adminResidenceType']!.text.trim().isEmpty) {
      _controllers['adminResidenceType']!.text = report.adminResidenceType ?? '';
    }
    if (_controllers['adminOther']!.text.trim().isEmpty) {
      _controllers['adminOther']!.text = report.adminOther ?? '';
    }

    // Sección 2
    if (_dateValues['expirationDate'] == null) {
      _dateValues['expirationDate'] = report.expirationDate;
    }
    if (_controllers['orientation2']!.text.trim().isEmpty) {
      _controllers['orientation2']!.text = report.orientation2 ?? '';
    }
    if (_controllers['healthCard']!.text.trim().isEmpty) {
      _controllers['healthCard']!.text = report.healthCard ?? '';
    }
    if (_controllers['medication']!.text.trim().isEmpty) {
      _controllers['medication']!.text = report.medication ?? '';
    }

    // Subsección 2.1
    if (_controllers['orientation2_1']!.text.trim().isEmpty) {
      _controllers['orientation2_1']!.text = report.orientation2_1 ?? '';
    }
    if (_controllers['rest']!.text.trim().isEmpty) {
      _controllers['rest']!.text = report.rest ?? '';
    }
    if (_controllers['diagnosis']!.text.trim().isEmpty) {
      _controllers['diagnosis']!.text = report.diagnosis ?? '';
    }
    if (_controllers['treatment']!.text.trim().isEmpty) {
      _controllers['treatment']!.text = report.treatment ?? '';
    }
    if (_controllers['tracking']!.text.trim().isEmpty) {
      _controllers['tracking']!.text = report.tracking ?? '';
    }

    //Subsection 2.2
    if (_controllers['orientation2_2']!.text.trim().isEmpty) {
      _controllers['orientation2_2']!.text = report.orientation2_2 ?? '';
    }
    if (_disabilityStateNotifier.value == '' &&
        report.disabilityState != null) {
      _disabilityStateNotifier.value = report.disabilityState!;
    }
    if (_controllers['referenceProfessionalDisability']!.text.trim().isEmpty) {
      _controllers['referenceProfessionalDisability']!.text = report.referenceProfessionalDisability ?? '';
    }
    if (_controllers['disabilityGrade']!.text.trim().isEmpty) {
      _controllers['disabilityGrade']!.text = report.disabilityGrade ?? '';
    }
    if (_grantedNotifier.value == '' &&
        report.granted != null) {
      _grantedNotifier.value = report.granted!;
    }
    if (_dateValues['revisionDate'] == null) {
      _dateValues['revisionDate'] = report.revisionDate;
    }
    if (_controllers['disabilityType']!.text.trim().isEmpty) {
      _controllers['disabilityType']!.text = report.disabilityType ?? '';
    }

    //Subsection 2.3
    if (_controllers['orientation2_3']!.text.trim().isEmpty) {
      _controllers['orientation2_3']!.text = report.orientation2_3 ?? '';
    }
    if (_controllers['dependenceState']!.text.trim().isEmpty) {
      _controllers['dependenceState']!.text = report.dependenceState ?? '';
    }
    if (_controllers['referenceProfessionalDependence']!.text.trim().isEmpty) {
      _controllers['referenceProfessionalDependence']!.text = report.referenceProfessionalDependence ?? '';
    }
    if (_controllers['dependenceGrade']!.text.trim().isEmpty) {
      _controllers['dependenceGrade']!.text = report.dependenceGrade ?? '';
    }

    //Subsection 2.4
    if (_controllers['orientation2_4']!.text.trim().isEmpty) {
      _controllers['orientation2_4']!.text = report.orientation2_4 ?? '';
    }
    if (_controllers['externalDerivation']!.text.trim().isEmpty) {
      _controllers['externalDerivation']!.text = report.externalDerivation ?? '';
    }
    if (_controllers['motive']!.text.trim().isEmpty) {
      _controllers['motive']!.text = report.motive ?? '';
    }

    //Section 3
    if (_controllers['orientation3']!.text.trim().isEmpty) {
      _controllers['orientation3']!.text = report.orientation3 ?? '';
    }
    if (_controllers['internalDerivationLegal']!.text.trim().isEmpty) {
      _controllers['internalDerivationLegal']!.text = report.internalDerivationLegal ?? '';
    }
    if (_dateValues['internalDerivationDate'] == null) {
      _dateValues['internalDerivationDate'] = report.internalDerivationDate;
    }
    if (_controllers['internalDerivationMotive']!.text.trim().isEmpty) {
      _controllers['internalDerivationMotive']!.text = report.internalDerivationMotive ?? '';
    }
    if (_controllers['externalDerivationLegal']!.text.trim().isEmpty) {
      _controllers['externalDerivationLegal']!.text = report.externalDerivationLegal ?? '';
    }
    if (_dateValues['externalDerivationDate'] == null) {
      _dateValues['externalDerivationDate'] = report.externalDerivationDate;
    }
    if (_controllers['externalDerivationMotive']!.text.trim().isEmpty) {
      _controllers['externalDerivationMotive']!.text = report.externalDerivationMotive ?? '';
    }
    if (_controllers['psychosocialDerivationLegal']!.text.trim().isEmpty) {
      _controllers['psychosocialDerivationLegal']!.text = report.psychosocialDerivationLegal ?? '';
    }
    if (_dateValues['psychosocialDerivationDate'] == null) {
      _dateValues['psychosocialDerivationDate'] = report.psychosocialDerivationDate;
    }
    if (_controllers['psychosocialDerivationMotive']!.text.trim().isEmpty) {
      _controllers['psychosocialDerivationMotive']!.text = report.psychosocialDerivationMotive ?? '';
    }
    if (_controllers['legalRepresentation']!.text.trim().isEmpty) {
      _controllers['legalRepresentation']!.text = report.legalRepresentation ?? '';
    }

    //Section 4
    if (_controllers['orientation4']!.text.trim().isEmpty) {
      _controllers['orientation4']!.text = report.orientation4 ?? '';
    }
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
    if (_controllers['ownershipTypeOpen']!.text.trim().isEmpty) {
      _controllers['ownershipTypeOpen']!.text = report.ownershipTypeOpen ?? '';
    }
    if (_controllers['homelessnessSituationOpen']!.text.trim().isEmpty) {
      _controllers['homelessnessSituationOpen']!.text = report.homelessnessSituationOpen ?? '';
    }
    if (_controllers['livingUnit']!.text.trim().isEmpty) {
      _controllers['livingUnit']!.text = report.livingUnit ?? '';
    }


    if (_controllers['location']!.text.trim().isEmpty) {
      _controllers['location']!.text = report.location ?? '';
    }
    if (_controllers['centerContact']!.text.trim().isEmpty) {
      _controllers['centerContact']!.text = report.centerContact ?? '';
    }
    if (_listValues['hostingObservations'] == null || _listValues['hostingObservations']!.isEmpty) {
        _listValues['hostingObservations'] = List<String>.from(report.hostingObservations ?? []);
    }
    //Section 5
    if (_controllers['orientation5']!.text.trim().isEmpty) {
      _controllers['orientation5']!.text = report.orientation5 ?? '';
    }
    if (_controllers['informationNetworks']!.text.trim().isEmpty) {
      _controllers['informationNetworks']!.text = report.informationNetworks ?? '';
    }
    if (_controllers['institutionNetworks']!.text.trim().isEmpty) {
      _controllers['institutionNetworks']!.text = report.institutionNetworks ?? '';
    }
    if (_controllers['familyConciliation']!.text.trim().isEmpty) {
      _controllers['familyConciliation']!.text = report.familyConciliation ?? '';
    }

    //Section 7
    if (_controllers['orientation7']!.text.trim().isEmpty) {
      _controllers['orientation7']!.text = report.orientation7 ?? '';
    }
    _languagesInit.initOnce(report.languages, fallback: [LanguageReport(name: '', level: '', accreditation: '')]);
    sanitizeLanguageLevels();

    //Section 9
    if (_subsidyBeneficiaryNotifier.value == '' &&
        report.subsidyBeneficiary != null) {
      _subsidyBeneficiaryNotifier.value = report.subsidyBeneficiary!;
    }
    if (_socialExclusionCertificateNotifier.value == '' &&
        report.socialExclusionCertificate != null) {
      _socialExclusionCertificateNotifier.value = report.socialExclusionCertificate!;
    }
    if (_controllers['subsidyName']!.text.trim().isEmpty) {
      _controllers['subsidyName']!.text = report.subsidyName ?? '';
    }
    if (_dateValues['socialExclusionCertificateDate'] == null) {
      _dateValues['socialExclusionCertificateDate'] = report.socialExclusionCertificateDate;
    }
    if (_controllers['socialExclusionCertificateObservations']!.text.trim().isEmpty) {
      _controllers['socialExclusionCertificateObservations']!.text = report.socialExclusionCertificateObservations ?? '';
    }
    if (_controllers['orientation9']!.text.trim().isEmpty) {
      _controllers['orientation9']!.text = report.orientation9 ?? '';
    }
    if (_controllers['centerTSReference']!.text.trim().isEmpty) {
      _controllers['centerTSReference']!.text = report.centerTSReference ?? '';
    }

    //Section 12
    if (_controllers['orientation12']!.text.trim().isEmpty) {
      _controllers['orientation12']!.text = report.orientation12 ?? '';
    }
    if (_listValues['vulnerabilityOptions'] == null || _listValues['vulnerabilityOptions']!.isEmpty) {
      _listValues['vulnerabilityOptions'] = List<String>.from(report.vulnerabilityOptions ?? []);
    }



    //Section 13
    if (_controllers['orientation13']!.text.trim().isEmpty) {
      _controllers['orientation13']!.text = report.orientation13 ?? '';
    }
    if (_controllers['orientation13_2']!.text.trim().isEmpty) {
      _controllers['orientation13_2']!.text = report.orientation13_2 ?? '';
    }
    if (_controllers['educationLevel']!.text.trim().isEmpty) {
      _controllers['educationLevel']!.text = report.educationLevel ?? '';
    }
    if (_controllers['homologation']!.text.trim().isEmpty) {
      _controllers['homologation']!.text = report.homologation ?? '';
    }
    if (_laborSituationNotifier.value == '' &&
        report.laborSituation != null) {
      _laborSituationNotifier.value = report.laborSituation!;
    }
    if (_controllers['laborOtherConsiderations']!.text.trim().isEmpty) {
      _controllers['laborOtherConsiderations']!.text = report.laborOtherConsiderations ?? '';
    }
    if (_controllers['tempLabor']!.text.trim().isEmpty) {
      _controllers['tempLabor']!.text = report.tempLabor ?? '';
    }
    if (_controllers['workingDayLabor']!.text.trim().isEmpty) {
      _controllers['workingDayLabor']!.text = report.workingDayLabor ?? '';
    }
    if (_controllers['competencies']!.text.trim().isEmpty) {
      _controllers['competencies']!.text = report.competencies ?? '';
    }
    if (_controllers['contextualization']!.text.trim().isEmpty) {
      _controllers['contextualization']!.text = report.contextualization ?? '';
    }
    if (_controllers['connexion']!.text.trim().isEmpty) {
      _controllers['connexion']!.text = report.connexion ?? '';
    }
    if (_controllers['shortTerm']!.text.trim().isEmpty) {
      _controllers['shortTerm']!.text = report.shortTerm ?? '';
    }
    if (_controllers['mediumTerm']!.text.trim().isEmpty) {
      _controllers['mediumTerm']!.text = report.mediumTerm ?? '';
    }
    if (_controllers['longTerm']!.text.trim().isEmpty) {
      _controllers['longTerm']!.text = report.longTerm ?? '';
    }

    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 30),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SpaceH20(),
            StreamBuilder<List<Program>>(
              stream: database.programsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }
                final programs = snapshot.data!;
                final items = programs.map((program) {
                  final display = '${program.code} - ${program.name}';
                  return DropdownMenuItem<String>(
                    value: program.programId,
                    child: Text(display),
                  );
                }).toList();

                return CustomDropDownButtonFormFieldTittle(
                  labelText: StringConst.INITIAL_SUBSIDY,
                  source: items,
                  value: _selectedProgramId,
                  onChanged: _finished
                      ? null
                      : (value) {
                          setState(() {
                            _selectedProgramId = value;
                            // Also store the human-readable name for the report's subsidy field
                            final selected = programs.firstWhere(
                              (p) => p.programId == value,
                              orElse: () => programs.first,
                            );
                            _controllers['subsidy']!.text =
                                '${selected.code} - ${selected.name}';
                          });
                        },
                );
              },
            ),
            SpaceH12(),
            CustomFlexRowColumn(
              childRight: StreamBuilder<UserEnreda>(
                stream: database.userEnredaStreamByUserId(_controllers['techPerson']!.text),
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
              childLeft: CustomDatePickerTitleOpen(
                labelText: StringConst.DATE,
                enabled: !_finished,
                color: AppColors.primary900,
                initialValue: _dateValues['completedDate'],
                onChanged: (value) {
                  if(value != null && value.isAfter(DateTime.now())){
                    showAlertDialog(context, title: StringConst.DATE_ERROR, content: StringConst.INITIAL_DATE_ERROR, defaultActionText: StringConst.FORM_CONFIRM);
                    setState(() {
                      _dateValues['completedDate'] = DateTime.now();
                    });
                    return;
                  }
                  setState(() {
                    _dateValues['completedDate'] = value ?? DateTime.now();
                  });
                },
              ),
            ),

            CustomTextFormFieldTitle(
              labelText: StringConst.DNI_PARTICIPANT,
              controller: _controllers['dniParticipant']!,
              hintText: "Escribe el n° de documentación personal vigente del participante",
              
              enabled: !_finished,
            ),

            //Section 1
            informSectionTitle(StringConst.INITIAL_TITLE1_ITINERARY),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              controller: _controllers['orientation1']!,
              
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: CustomDatePickerTitleOpen(
                labelText: StringConst.INITIAL_ARRIVE_DATE,
                initialValue: _dateValues['arriveDate'],
                onChanged: (value) {
                  _dateValues['arriveDate'] = value;
                },
                enabled: !_finished,
              ),
              childRight: CustomTextFormFieldTitle(
                labelText: StringConst.INITIAL_RECEPTION_RESOURCES,
                controller: _controllers['receptionResources']!,
                
                enabled: !_finished,
              ),
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_EXTERNAL_RESOURCES,
              controller: _controllers['administrativeExternalResources']!,
              
              enabled: !_finished,
            ),

            //Section 1.1
            informSubSectionTitle(StringConst.INITIAL_TITLE_1_1_ADMINISTRATIVE_SITUATION),
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
              ),
              childRight: ValueListenableBuilder(
                valueListenable: _adminStateNotifier,
                builder: (context, value, child){
                  return _adminStateNotifier.value == 'Sin tramitar' ?
                  CustomTextFormFieldTitle(
                    labelText: 'Motivo',
                    controller: _controllers['adminNoThrough']!,
                    
                    enabled: !_finished,
                  ) : //Open Field
                      _adminStateNotifier.value == 'Concedida' ?
                      CustomDatePickerTitleOpen(
                        labelText: StringConst.INITIAL_DATE_CONCESSION,
                        initialValue: _dateValues['adminDateConcession'],
                        onChanged: (value) {
                          _dateValues['adminDateConcession'] = value;
                        },
                        enabled: !_finished,
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
                      childLeft: CustomDatePickerTitleOpen(
                        labelText: StringConst.INITIAL_DATE_ASK,
                        initialValue: _dateValues['adminDateAsk'],
                        onChanged: (value) {
                          _dateValues['adminDateAsk'] = value;
                        },
                        enabled: !_finished,
                      ),
                      childRight: CustomDatePickerTitleOpen(
                        labelText: StringConst.INITIAL_DATE_RESOLUTION,
                        initialValue: _dateValues['adminDateResolution'],
                        onChanged: (value) {
                          _dateValues['adminDateResolution'] = value;
                        },
                        enabled: !_finished,
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
              ),
              childRight: ValueListenableBuilder(
                valueListenable: _adminTempNotifier,
                builder: (context, value, child){
                  return _adminTempNotifier.value == 'Inicial' || _adminTempNotifier.value == 'Temporal' ?
                  CustomDatePickerTitleOpen(
                    labelText: StringConst.INITIAL_DATE_RENOVATION,
                    initialValue: _dateValues['adminDateRenovation'],
                    onChanged: (value) {
                      _dateValues['adminDateRenovation'] = value;
                    },
                    enabled: !_finished
                    /*validator: (value) => (value != null)
                        ? null
                        : StringConst.FORM_GENERIC_ERROR,*/
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
              ),
              childLeft: _controllers['adminResidenceType']!.text == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_RESIDENCE_TYPE,
                source: StringConst.ADMIN_RESIDENCE_TYPE_SELECTION,
                onChanged: _finished
                    ? null
                    : (value) {
                  _controllers['adminResidenceType']!.text = value!;
                },
              )
                  : CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_RESIDENCE_TYPE,
                value: _controllers['adminResidenceType']!.text,
                source: StringConst.ADMIN_RESIDENCE_TYPE_SELECTION,
                onChanged: _finished
                    ? null
                    : (value) {
                  _controllers['adminResidenceType']!.text = value!;
                },
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
                      controller: _controllers['adminOther']!,
                      
                      enabled: !_finished,
                    ),
                  ],
                ) : Container();
              }
            ),


            //Section 2
            informSectionTitle(StringConst.INITIAL_TITLE2_SANITARY),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              controller: _controllers['orientation2']!,
              
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: _controllers['healthCard']!.text == ''
                  ? CustomDropDownButtonFormFieldTittle(
                      labelText: StringConst.INITIAL_HEALTH_CARD,
                      source: StringConst.HEALTH_CARD_SELECTION,
                      onChanged: _finished
                          ? null
                          : (value) {
                              _controllers['healthCard']!.text = value!;
                            },
                    )
                  : CustomDropDownButtonFormFieldTittle(
                      labelText: StringConst.INITIAL_HEALTH_CARD,
                      value: _controllers['healthCard']!.text,
                      source: StringConst.HEALTH_CARD_SELECTION,
                      onChanged: _finished
                          ? null
                          : (value) {
                              _controllers['healthCard']!.text = value!;
                            },
                    ),
              childRight: CustomDatePickerTitleOpen(
                labelText: StringConst.INITIAL_EXPIRATION_DATE,
                initialValue: _dateValues['expirationDate'],
                onChanged: (value) {
                  _dateValues['expirationDate'] = value;
                },
                enabled: !_finished,
              ),
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_MEDICATION,
              controller: _controllers['medication']!,
              
              enabled: !_finished,
            ),
            //Subsection 2.1
            informSubSectionTitle(StringConst.INITIAL_TITLE_2_1_MENTAL_HEALTH),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              controller: _controllers['orientation2_1']!,
              
              enabled: !_finished,
            ),
            /*SpaceH12(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: CustomTextFormFieldTitle(
                labelText: StringConst.INITIAL_REST,
                initialValue: _rest,
                onChanged: (value) {
                  _rest = value;
                },
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
                enabled: !_finished,
              ),
              childRight: CustomTextFormFieldTitle(
                labelText: StringConst.INITIAL_TRACKING,
                initialValue: _tracking,
                onChanged: (value) {
                  _tracking = value;
                },
              /*  validator: (value) => (value!.isNotEmpty || value != '')
                    ? null
                    : StringConst.FORM_GENERIC_ERROR,
                enabled: !_finished,*/
              ),
            ),
            */
            SpaceH12(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: _controllers['psychosocialDerivationLegal']!.text == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_PSYCHOSOCIAL_DERIVATION,
                source: StringConst.YES_NO_SELECTION,
                onChanged: _finished
                    ? null
                    : (value) {
                  _controllers['psychosocialDerivationLegal']!.text = value!;
                },
              )
                  : CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_PSYCHOSOCIAL_DERIVATION,
                source: StringConst.YES_NO_SELECTION,
                value: _controllers['psychosocialDerivationLegal']!.text,
                onChanged: _finished
                    ? null
                    : (value) {
                  _controllers['psychosocialDerivationLegal']!.text = value!;
                },
              ),
              childRight: CustomDatePickerTitleOpen(
                labelText: StringConst.INITIAL_DERIVATION_DATE,
                initialValue: _dateValues['psychosocialDerivationDate'],
                onChanged: (value) {
                  _dateValues['psychosocialDerivationDate'] = value;
                },
                enabled: !_finished,
              ),
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_MOTIVE,
              controller: _controllers['psychosocialDerivationMotive']!,
              onChanged: (value) {
                _controllers['psychosocialDerivationMotive']!.text = value;
              },
              enabled: !_finished,
            ),

            //Subsection 2.2
            informSubSectionTitle(StringConst.INITIAL_TITLE_2_2_DISABILITY),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              controller: _controllers['orientation2_2']!,
              
            /*  validator: (value) => (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,*/
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
                                        _dateValues['revisionDate'] = null;
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
                                  ? CustomDatePickerTitleOpen(
                                      labelText: StringConst.INITIAL_DATE,
                                      initialValue: _dateValues['revisionDate'],
                                      onChanged: (value) {
                                        _dateValues['revisionDate'] = value;
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
              controller: _controllers['referenceProfessionalDisability']!,
              
              enabled: !_finished,
            ),

            SpaceH12(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: _controllers['disabilityGrade']!.text == ''
                  ? CustomDropDownButtonFormFieldTittle(
                      labelText: StringConst.INITIAL_DISABILITY_GRADE,
                      source: StringConst.DISABILITY_GRADE_SELECTION,
                      onChanged: _finished
                          ? null
                          : (value) {
                              _controllers['disabilityGrade']!.text = value!;
                            },
                    )
                  : CustomDropDownButtonFormFieldTittle(
                      labelText: StringConst.INITIAL_DISABILITY_GRADE,
                      source: StringConst.DISABILITY_GRADE_SELECTION,
                      value: _controllers['disabilityGrade']!.text,
                      onChanged: _finished
                          ? null
                          : (value) {
                              _controllers['disabilityGrade']!.text = value!;
                            },
                    ),
              childRight: _controllers['disabilityType']!.text == ''
                  ? CustomDropDownButtonFormFieldTittle(
                      labelText: StringConst.INITIAL_DISABILITY_TYPE,
                      source: StringConst.DISABILITY_TYPE_SELECTION,
                      onChanged: _finished
                          ? null
                          : (value) {
                              _controllers['disabilityType']!.text = value!;
                            },
                    )
                  : CustomDropDownButtonFormFieldTittle(
                      labelText: StringConst.INITIAL_DISABILITY_TYPE,
                      source: StringConst.DISABILITY_TYPE_SELECTION,
                      value: _controllers['disabilityType']!.text,
                      onChanged: _finished
                          ? null
                          : (value) {
                              _controllers['disabilityType']!.text = value!;
                            },
                   /*   validator: (value) =>
                          value != null ? null : StringConst.FORM_GENERIC_ERROR,*/
                    ),
            ),

            //Subsection 2.3
            informSubSectionTitle(StringConst.INITIAL_TITLE_2_3_DEPENDENCE),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              controller: _controllers['orientation2_3']!,
              
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: _controllers['dependenceState']!.text == ''
                  ? CustomDropDownButtonFormFieldTittle(
                      labelText: StringConst.INITIAL_STATE,
                      source: StringConst.DEPENDENCE_STATE_SELECTION,
                      onChanged: _finished
                          ? null
                          : (value) {
                              _controllers['dependenceState']!.text = value!;
                            },
                    )
                  : CustomDropDownButtonFormFieldTittle(
                      labelText: StringConst.INITIAL_STATE,
                      source: StringConst.DEPENDENCE_STATE_SELECTION,
                      value: _controllers['dependenceState']!.text,
                      onChanged: _finished
                          ? null
                          : (value) {
                              _controllers['dependenceState']!.text = value!;
                            },
                    ),
              childRight: _controllers['dependenceGrade']!.text == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_DEPENDENCE_GRADE,
                source: StringConst.DEPENDENCE_GRADE_SELECTION,
                onChanged: _finished
                    ? null
                    : (value) {
                  _controllers['dependenceGrade']!.text = value!;
                },
              )
                  : CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_DEPENDENCE_GRADE,
                source: StringConst.DEPENDENCE_GRADE_SELECTION,
                value: _controllers['dependenceGrade']!.text,
                onChanged: _finished
                    ? null
                    : (value) {
                  _controllers['dependenceGrade']!.text = value!;
                },
              ),
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_REFERENCE_PROFESSIONAL,
              controller: _controllers['referenceProfessionalDependence']!,
              
              enabled: !_finished,
            ),

            //Subsection 2.4
            informSubSectionTitle(StringConst.INITIAL_TITLE_2_4_ADDICTIONS),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              controller: _controllers['orientation2_4']!,
              
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: _controllers['externalDerivation']!.text == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_EXTERNAL_DERIVATION,
                source: StringConst.YES_NO_SELECTION,
                onChanged: _finished
                    ? null
                    : (value) {
                  _controllers['externalDerivation']!.text = value!;
                },
              )
                  : CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_EXTERNAL_DERIVATION,
                source: StringConst.YES_NO_SELECTION,
                value: _controllers['externalDerivation']!.text,
                onChanged: _finished
                    ? null
                    : (value) {
                  _controllers['externalDerivation']!.text = value!;
                },
              ),
              childRight: CustomTextFormFieldTitle(
                labelText: StringConst.INITIAL_MOTIVE,
                controller: _controllers['motive']!,
                
                enabled: !_finished,
              ),
            ),

            //Section 3
            informSectionTitle(StringConst.INITIAL_TITLE_3_LEGAL_SITUATION),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              controller: _controllers['orientation3']!,
              
              enabled: !_finished,
            ),
            SpaceH12(),
            //Internal derivation
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: _controllers['internalDerivationLegal']!.text == ''
                  ? CustomDropDownButtonFormFieldTittle(
                      labelText: StringConst.INITIAL_INTERNAL_DERIVATION,
                      source: StringConst.YES_NO_SELECTION,
                      onChanged: _finished
                          ? null
                          : (value) {
                              _controllers['internalDerivationLegal']!.text = value!;
                            },
                    )
                  : CustomDropDownButtonFormFieldTittle(
                      labelText: StringConst.INITIAL_INTERNAL_DERIVATION,
                      source: StringConst.YES_NO_SELECTION,
                      value: _controllers['internalDerivationLegal']!.text,
                      onChanged: _finished
                          ? null
                          : (value) {
                              _controllers['internalDerivationLegal']!.text = value!;
                            },
                    ),
              childRight: CustomDatePickerTitleOpen(
                labelText: StringConst.INITIAL_DERIVATION_DATE,
                initialValue: _dateValues['internalDerivationDate'],
                onChanged: (value) {
                  _dateValues['internalDerivationDate'] = value;
                },
                enabled: !_finished,
              ),
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_MOTIVE,
              controller: _controllers['internalDerivationMotive']!,
              
              enabled: !_finished,
            ),
            SpaceH12(),
            //Psychosocial derivation
            CustomFlexRowColumn(
              contentPadding: EdgeInsets.zero,
              separatorSize: 20,
              childLeft: _controllers['externalDerivationLegal']!.text == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_EXTERNAL_DERIVATION,
                source: StringConst.YES_NO_SELECTION,
                onChanged: _finished
                    ? null
                    : (value) {
                  _controllers['externalDerivationLegal']!.text = value!;
                },
              )
                  : CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_EXTERNAL_DERIVATION,
                source: StringConst.YES_NO_SELECTION,
                value: _controllers['externalDerivationLegal']!.text,
                onChanged: _finished
                    ? null
                    : (value) {
                  _controllers['externalDerivationLegal']!.text = value!;
                },
              ),
              childRight: CustomDatePickerTitleOpen(
                labelText: StringConst.INITIAL_DERIVATION_DATE,
                initialValue: _dateValues['externalDerivationDate'],
                onChanged: (value) {
                  _dateValues['externalDerivationDate'] = value;
                },
                enabled: !_finished,
              ),
            ),
            SpaceH12(), //TODO check values saved
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_MOTIVE,
              controller: _controllers['externalDerivationMotive']!,
              
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_LEGAL_REPRESENTATION,
              hintText: StringConst.INITIAL_HINT_LEGAL,
              controller: _controllers['legalRepresentation']!,
              
              enabled: !_finished,
            ),

            //Section 4
            informSectionTitle(StringConst.INITIAL_TITLE_4_HOUSE_SITUATION),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              controller: _controllers['orientation4']!,
              
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
                          controller: _controllers['ownershipTypeOpen']!,
                          
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
                        controller: _controllers['homelessnessSituationOpen']!,
                        
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
                controller: _controllers['livingUnit']!,
                
                enabled: !_finished,
              ),
              childRight: CustomTextFormFieldTitle(
                labelText: StringConst.INITIAL_CENTER_CONTACT,
                controller: _controllers['centerContact']!,
                onChanged: (value) {
                  _controllers['centerContact']!.text = value;
                },
                enabled: !_finished,
              ),
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_LOCATION,
              controller: _controllers['location']!,
              
              enabled: !_finished,
            ),
            informSubSectionTitle(StringConst.HABITABILITY_CONDITIONS),
            Align(
                alignment: Alignment.centerLeft,
                child: CustomMultiSelectionCheckBoxList(
                    options: StringConst.OPTIONS_SECTION_4,
                    selections: _listValues['hostingObservations']!,
                    enabled: !_finished)),

            //Section 5
            informSectionTitle(StringConst.INITIAL_TITLE_5_SUPPORT),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              controller: _controllers['orientation5']!,
              
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_INFORMATION_NETWORKS,
              controller: _controllers['informationNetworks']!,
              hintText: StringConst.INITIAL_INFORMATION_NETWORKS_HINT,
              
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomFlexRowColumn(
              separatorSize: 20,
              contentPadding: EdgeInsets.zero,
              childLeft: CustomTextFormFieldTitle(
                labelText: StringConst.INITIAL_INSTITUTION_NETWORKS,
                controller: _controllers['institutionNetworks']!,
                
                enabled: !_finished,
              ),
              childRight: CustomTextFormFieldTitle(
                labelText: StringConst.INITIAL_FAMILY_CONCILIATION,
                controller: _controllers['familyConciliation']!,
                
                enabled: !_finished,
              ),
            ),

            //Section 6
            informSectionTitle(StringConst.INITIAL_TITLE_6_LANGUAGES),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              controller: _controllers['orientation7']!,
              
              enabled: !_finished,
            ),
            SpaceH12(),
            StreamBuilder<List<String>>(
  stream: database.languagesStream(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return Container();
    }

    final _languageOptions = snapshot.data!
        .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList();

    return ValueListenableBuilder<List<LanguageReport>>(
      valueListenable: _languagesInit.notifier,
      builder: (context, languages, child) {
        return Column(
          children: [
            for (int index = 0; index < languages.length; index++)
              Builder(
                builder: (context) {
                  final language = languages[index];

                  return Column(
                    children: [
                      CustomFlexRowColumn(
                        contentPadding: EdgeInsets.zero,
                        separatorSize: 20,
                        childLeft: CustomDropDownButtonFormFieldTittle(
                          labelText: StringConst.INITIAL_LANGUAGE,
                          value: language.name.isNotEmpty ? language.name : null,
                          source: _languageOptions,
                          onChanged: _finished
                              ? null
                              : (value) {
                                  final updated = List<LanguageReport>.from(languages);
                                  updated[index] = language.copyWith(name: value);
                                  _languagesInit.notifier.value = updated;
                                },
                        ),
                        childRight: CustomDropDownButtonFormFieldTittle(
                          labelText: StringConst.INITIAL_LANGUAGE_LEVEL,
                          value: language.level.isNotEmpty ? language.level : null,
                          source: StringConst.LANGUAGE_LEVEL_SELECTION,
                          onChanged: _finished
                              ? null
                              : (value) {
                                  final updated = List<LanguageReport>.from(languages);
                                  updated[index] = language.copyWith(level: value);
                                  _languagesInit.notifier.value = updated;
                                },
                        ),
                      ),
                      SpaceH12(),
                      CustomTextFormFieldTitle(
                        labelText: StringConst.INITIAL_LANGUAGE_ACCREDITATION,
                        initialValue: language.accreditation,
                        onChanged: (value) {
                          final updated = List<LanguageReport>.from(languages);
                          updated[index] = language.copyWith(accreditation: value);
                          _languagesInit.notifier.value = updated;
                        },
                        enabled: !_finished,
                      ),
                      SpaceH12(),
                    ],
                  );
                },
              ),
          ],
        );
      },
    );
  },
),
            addLanguageButton(),

            //Section 7
            informSectionTitle(StringConst.INITIAL_TITLE_7_SOCIAL_ATTENTION),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              controller: _controllers['orientation9']!,
              
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_CENTER_TS,
              controller: _controllers['centerTSReference']!,
              
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
              ),
              childRight: ValueListenableBuilder(
                valueListenable: _subsidyBeneficiaryNotifier,
                builder: (context, value, child){
                  return _subsidyBeneficiaryNotifier.value == 'Si' ?
                  CustomTextFormFieldTitle(
                    labelText: StringConst.INITIAL_NAME_TYPE,
                    controller: _controllers['subsidyName']!,
                    
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
                          childRight: CustomDatePickerTitleOpen(
                            labelText: StringConst.INITIAL_DATE,
                            initialValue: _dateValues['socialExclusionCertificateDate'],
                            onChanged: (value) {
                              _dateValues['socialExclusionCertificateDate'] = value;
                            },
                            enabled: !_finished,
                          ),
                          childLeft: CustomTextFormFieldTitle(
                            labelText: StringConst.INITIAL_SOCIAL_EXCLUSION_OBSERVATIONS,
                            controller: _controllers['socialExclusionCertificateObservations']!,
                            
                            enabled: !_finished,
                          ),
                        ),
                      ],
                    ) :
                    Container();
              }
            ),
            //Section 8
            informSectionTitle(StringConst.INITIAL_TITLE_8_VULNERABILITY),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              controller: _controllers['orientation12']!,
              
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomMultiSelectionCheckBoxList(
                options: StringConst.OPTIONS_SECTION_12,
                selections: _listValues['vulnerabilityOptions']!,
                enabled: !_finished),

            //Section 9
            informSectionTitle(StringConst.INITIAL_TITLE_9_WORK),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              controller: _controllers['orientation13']!,
              
              enabled: !_finished,
            ),
            SpaceH12(),
            _controllers['educationLevel']!.text == ''
                ? CustomDropDownButtonFormFieldTittle(
              labelText: StringConst.INITIAL_EDUCATION_LEVEL,
              source: StringConst.EDUCATIONAL_LEVEL_SELECTION,
              onChanged: _finished
                  ? null
                  : (value) {
                _controllers['educationLevel']!.text = value!;
              },
            )
                : CustomDropDownButtonFormFieldTittle(
              labelText: StringConst.INITIAL_EDUCATION_LEVEL,
              source: StringConst.EDUCATIONAL_LEVEL_SELECTION,
              value: _controllers['educationLevel']!.text,
              onChanged: _finished
                  ? null
                  : (value) {
                _controllers['educationLevel']!.text = value!;
              },
            ),
            SpaceH12(),
            _controllers['homologation']!.text == ''
                ? CustomDropDownButtonFormFieldTittle(
              labelText: StringConst.HOMOLOGATION,
              source: StringConst.HOMOLOGATION_SELECTION,
              onChanged: _finished
                  ? null
                  : (value) {
                _controllers['homologation']!.text = value!;
              },
            )
                : CustomDropDownButtonFormFieldTittle(
              labelText: StringConst.HOMOLOGATION,
              source: StringConst.HOMOLOGATION_SELECTION,
              value: _controllers['homologation']!.text,
              onChanged: _finished
                  ? null
                  : (value) {
                _controllers['homologation']!.text = value!;
              },
            ),
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
                return  _laborSituationNotifier.value == 'Ocupada cuenta ajena' || _laborSituationNotifier.value == 'Ocupada cuenta propia' ? Column(
                  children: [
                    CustomFlexRowColumn(
                      contentPadding: EdgeInsets.zero,
                      separatorSize: 20,
                      childLeft: _controllers['tempLabor']!.text == ''
                          ? CustomDropDownButtonFormFieldTittle(
                        labelText: StringConst.INITIAL_TEMP,
                        source: StringConst.TEMP_SELECTION,
                        onChanged: _finished
                            ? null
                            : (value) {
                          _controllers['tempLabor']!.text = value!;
                        },
                      )
                          : CustomDropDownButtonFormFieldTittle(
                        labelText: StringConst.INITIAL_TEMP,
                        source: StringConst.TEMP_SELECTION,
                        value: _controllers['tempLabor']!.text,
                        onChanged: _finished
                            ? null
                            : (value) {
                          _controllers['tempLabor']!.text = value!;
                        },
                      ),
                      childRight: _controllers['workingDayLabor']!.text == ''
                          ? CustomDropDownButtonFormFieldTittle(
                        labelText: StringConst.INITIAL_LABOR_TYPE,
                        source: StringConst.WORK_DAY_SELECTION,
                        onChanged: _finished
                            ? null
                            : (value) {
                          _controllers['workingDayLabor']!.text = value!;
                        },
                      )
                          : CustomDropDownButtonFormFieldTittle(
                        labelText: StringConst.INITIAL_LABOR_TYPE,
                        source: StringConst.WORK_DAY_SELECTION,
                        value: _controllers['workingDayLabor']!.text,
                        onChanged: _finished
                            ? null
                            : (value) {
                          _controllers['workingDayLabor']!.text = value!;
                        },
                      ),
                    ),
                    SpaceH12(),
                    CustomTextFormFieldTitle(
                      labelText: StringConst.LABOR_OTHER_CONSIDERATIONS,
                      controller: _controllers['laborOtherConsiderations']!,
                      
                      enabled: !_finished,
                    ),
                  ],
                ) :
                Container();
              }
            ),

            informSubSectionTitle(StringConst.INITIAL_TITLE_9_3_TRAJECTORY),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              controller: _controllers['orientation13_2']!,
              
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText:
                  StringConst.INITIAL_COMPETENCIES,
              controller: _controllers['competencies']!,
              
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_CONTEXTUALIZATION,
              controller: _controllers['contextualization']!,
              
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_CONNEXION,
              controller: _controllers['connexion']!,
              
              enabled: !_finished,
            ),

            informSubSectionTitle(StringConst.INITIAL_TITLE_9_4_EXPECTATIONS),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_SHORT_TERM,
              controller: _controllers['shortTerm']!,
              
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_MEDIUM_TERM,
              controller: _controllers['mediumTerm']!,
              
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_LONG_TERM,
              controller: _controllers['longTerm']!,
              
              enabled: !_finished,
            ),
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
                      color: AppColors.primary900,
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
                              setState(() {
                                widget.user.startDateItinerary = _dateValues['completedDate'];
                                widget.user.initialReportId = initialReportSaved.initialReportId;
                                widget.user.programId = _selectedProgramId;
                              });
                              database.setUserEnreda(widget.user);
                              database.setInitialReport(InitialReport(
                                userId: report.userId,
                                initialReportId: report.initialReportId,
                                subsidy: _controllers['subsidy']!.text,
                                techPerson: _controllers['techPerson']!.text,
                                dniParticipant: _controllers['dniParticipant']!.text,
                                orientation1: _controllers['orientation1']!.text,
                                arriveDate: _dateValues['arriveDate'],
                                receptionResources: _controllers['receptionResources']!.text,
                                administrativeExternalResources: _controllers['administrativeExternalResources']!.text,
                                expirationDate: _dateValues['expirationDate'],
                                adminState: _adminStateNotifier.value,
                                adminNoThrough: _controllers['adminNoThrough']!.text,
                                adminDateAsk: _dateValues['adminDateAsk'],
                                adminDateResolution: _dateValues['adminDateResolution'],
                                adminDateConcession: _dateValues['adminDateConcession'],
                                adminTemp: _adminTempNotifier.value,
                                adminResidenceWork: _controllers['adminResidenceWork']!.text,
                                adminDateRenovation: _dateValues['adminDateRenovation'],
                                adminResidenceType: _controllers['adminResidenceType']!.text,
                                adminJuridicFigure: _adminJuridicFigureNotifier.value,
                                adminOther: _controllers['adminOther']!.text,
                                orientation2: _controllers['orientation2']!.text,
                                healthCard: _controllers['healthCard']!.text,
                                medication: _controllers['medication']!.text,
                                orientation2_1: _controllers['orientation2_1']!.text,
                                rest: _controllers['rest']!.text,
                                diagnosis: _controllers['diagnosis']!.text,
                                treatment: _controllers['treatment']!.text,
                                tracking: _controllers['tracking']!.text,
                                orientation2_2: _controllers['orientation2_2']!.text,
                                disabilityState: _disabilityStateNotifier.value,
                                referenceProfessionalDisability:
                                    _controllers['referenceProfessionalDisability']!.text,
                                disabilityGrade: _controllers['disabilityGrade']!.text,
                                disabilityType: _controllers['disabilityType']!.text,
                                granted: _grantedNotifier.value,
                                revisionDate: _dateValues['revisionDate'],
                                orientation2_3: _controllers['orientation2_3']!.text,
                                dependenceState: _controllers['dependenceState']!.text,
                                referenceProfessionalDependence:
                                    _controllers['referenceProfessionalDependence']!.text,
                                dependenceGrade: _controllers['dependenceGrade']!.text,
                                orientation2_4: _controllers['orientation2_4']!.text,
                                externalDerivation: _controllers['externalDerivation']!.text,
                                motive: _controllers['motive']!.text,
                                orientation3: _controllers['orientation3']!.text,
                                internalDerivationLegal:
                                    _controllers['internalDerivationLegal']!.text,
                                internalDerivationDate: _dateValues['internalDerivationDate'],
                                internalDerivationMotive: _controllers['internalDerivationMotive']!.text,
                                externalDerivationLegal: _controllers['externalDerivationLegal']!.text,
                                externalDerivationDate: _dateValues['externalDerivationDate'],
                                externalDerivationMotive: _controllers['externalDerivationMotive']!.text,
                                psychosocialDerivationLegal: _controllers['psychosocialDerivationLegal']!.text,
                                psychosocialDerivationDate: _dateValues['psychosocialDerivationDate'],
                                psychosocialDerivationMotive: _controllers['psychosocialDerivationMotive']!.text,
                                legalRepresentation: _controllers['legalRepresentation']!.text,
                                orientation4: _controllers['orientation4']!.text,
                                ownershipType: _ownershipTypeNotifier.value,
                                location: _controllers['location']!.text,
                                centerContact: _controllers['centerContact']!.text,
                                hostingObservations: _listValues['hostingObservations']!,
                                ownershipTypeOpen: _controllers['ownershipTypeOpen']!.text,
                                homelessnessSituation: _homelessnessSituationNotifier.value,
                                homelessnessSituationOpen: _controllers['homelessnessSituationOpen']!.text,
                                livingUnit: _controllers['livingUnit']!.text,
                                ownershipTypeConcrete: _ownershipTypeConcreteNotifier.value,
                                orientation5: _controllers['orientation5']!.text,
                                informationNetworks: _controllers['informationNetworks']!.text,
                                institutionNetworks: _controllers['institutionNetworks']!.text,
                                familyConciliation: _controllers['familyConciliation']!.text,
                                orientation7: _controllers['orientation7']!.text,
                                languages: _languagesInit.notifier.value,
                                orientation9: _controllers['orientation9']!.text,
                                centerTSReference: _controllers['centerTSReference']!.text,
                                subsidyBeneficiary: _subsidyBeneficiaryNotifier.value,
                                socialExclusionCertificate:
                                    _socialExclusionCertificateNotifier.value,
                                subsidyName: _controllers['subsidyName']!.text,
                                socialExclusionCertificateDate: _dateValues['socialExclusionCertificateDate'],
                                socialExclusionCertificateObservations: _controllers['socialExclusionCertificateObservations']!.text,
                                orientation12: _controllers['orientation12']!.text,
                                vulnerabilityOptions: _listValues['vulnerabilityOptions']!,
                                orientation13: _controllers['orientation13']!.text,
                                orientation13_2: _controllers['orientation13_2']!.text,
                                educationLevel: _controllers['educationLevel']!.text,
                                homologation: _controllers['homologation']!.text,
                                laborSituation: _laborSituationNotifier.value,
                                laborOtherConsiderations: _controllers['laborOtherConsiderations']!.text,
                                tempLabor: _controllers['tempLabor']!.text,
                                workingDayLabor: _controllers['workingDayLabor']!.text,
                                competencies: _controllers['competencies']!.text,
                                contextualization: _controllers['contextualization']!.text,
                                connexion: _controllers['connexion']!.text,
                                shortTerm: _controllers['shortTerm']!.text,
                                mediumTerm: _controllers['mediumTerm']!.text,
                                longTerm: _controllers['longTerm']!.text,
                                finished: false,
                                completedDate: _dateValues['completedDate'],
                                techPersonName: _techPersonController.text,
                              ));
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                      backgroundColor: AppColors.primary050,
                                      titlePadding:
                                      Responsive.isMobile(context) ? const EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0, bottom: 10.0) :
                                      const EdgeInsets.only(top: 50.0, left: 50.0, right: 50.0, bottom: 10.0),
                                      contentPadding:
                                      Responsive.isMobile(context) ? const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0) :
                                      const EdgeInsets.only(left: 50.0, right: 50.0, bottom: 30.0),
                                          title: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text('Se ha guardado con exito',
                                                  style: textTheme.titleLarge?.copyWith(
                                                    color: AppColors.primary900,
                                                    fontSize: fontSize,
                                                    height: 1.5,
                                                  )),
                                            ],
                                          ),
                                          actions: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.all(20.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                        ParticipantSocialReportPage.selectedIndexInforms.value = 0;
                                                        //setStateMenuPage();
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Text('Aceptar',
                                                            style: TextStyle(
                                                                color: AppColors.white,
                                                                height: 1.5,
                                                                fontWeight: FontWeight.w400,
                                                                fontSize: 14)),
                                                      ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: AppColors.primaryColor,
                                                        shadowColor: Colors.transparent,
                                                      )
                                                  ),
                                                ],
                                              ),
                                            ),
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
                                    backgroundColor: AppColors.primary050,
                                    titlePadding:
                                    Responsive.isMobile(context) ? const EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0, bottom: 10.0) :
                                    const EdgeInsets.only(top: 50.0, left: 50.0, right: 50.0, bottom: 10.0),
                                    contentPadding:
                                    Responsive.isMobile(context) ? const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0) :
                                    const EdgeInsets.only(left: 50.0, right: 50.0, bottom: 30.0),
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                            'Aún quedan campos por completar',
                                            style: textTheme.titleLarge?.copyWith(
                                                color: AppColors.primary900,
                                                height: 1.5,
                                                fontSize: fontSizeSubTitle)),
                                      ],
                                    ),
                                    content: Text('Rellena los campos marcados en rojo.',
                                        style: textTheme.headlineLarge?.copyWith(
                                            color: AppColors.primary900,
                                            height: 1.5,
                                            fontSize: fontSizeSubTitle)),
                                    actions: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 20.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text('Aceptar',
                                                      style: TextStyle(
                                                          color: AppColors.white,
                                                          height: 1.5,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14)),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppColors.primaryColor,
                                                  shadowColor: Colors.transparent,
                                                )
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ));
                              return;
                            }
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: AppColors.primary050,
                                  titlePadding:
                                    Responsive.isMobile(context) ? const EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0, bottom: 10.0) :
                                    const EdgeInsets.only(top: 50.0, left: 50.0, right: 50.0, bottom: 10.0),
                                  contentPadding:
                                    Responsive.isMobile(context) ? const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0) :
                                    const EdgeInsets.only(left: 50.0, right: 50.0, bottom: 30.0),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('¿Está seguro de que desea finalizar el Informe Inicial?',
                                          style: textTheme.titleLarge?.copyWith(
                                            color: AppColors.primary900,
                                            fontSize: fontSize,
                                            height: 1.5,
                                          )),
                                    ],
                                  ),
                                    content: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('No podrá volver a modificar ningún campo.',
                                            style: textTheme.headlineLarge?.copyWith(
                                                color: AppColors.primary900,
                                                height: 1.5,
                                                fontSize: fontSizeSubTitle)),
                                      ],
                                    ),
                                  actions: <Widget>[
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.all(8.0),
                                          child: Text('Cancelar',
                                              style: TextStyle(
                                                  color: AppColors.white,
                                                  height: 1.5,
                                                  fontWeight:
                                                  FontWeight.w400,
                                                  fontSize: 14)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryColor,
                                          shadowColor: Colors.transparent,
                                        )),
                                    ElevatedButton(
                                        onPressed: () async {
                                          setState(() {
                                            widget.user.startDateItinerary = _dateValues['completedDate'];
                                            widget.user.initialReportId = initialReportSaved.initialReportId;
                                            widget.user.programId = _selectedProgramId;
                                          });
                                          database.setUserEnreda(widget.user);
                                          database.setInitialReport(InitialReport(
                                            userId: report.userId,
                                            initialReportId: report.initialReportId,
                                            subsidy: _controllers['subsidy']!.text,
                                            techPerson: _controllers['techPerson']!.text,
                                            completedDate: _dateValues['completedDate'],
                                            dniParticipant: _controllers['dniParticipant']!.text,
                                            orientation1: _controllers['orientation1']!.text,
                                            arriveDate: _dateValues['arriveDate'],
                                            receptionResources: _controllers['receptionResources']!.text,
                                            administrativeExternalResources: _controllers['administrativeExternalResources']!.text,
                                            expirationDate: _dateValues['expirationDate'],
                                            adminState: _adminStateNotifier.value,
                                            adminNoThrough: _controllers['adminNoThrough']!.text,
                                            adminDateAsk: _dateValues['adminDateAsk'],
                                            adminDateResolution: _dateValues['adminDateResolution'],
                                            adminDateConcession: _dateValues['adminDateConcession'],
                                            adminTemp: _adminTempNotifier.value,
                                            adminResidenceWork: _controllers['adminResidenceWork']!.text,
                                            adminDateRenovation: _dateValues['adminDateRenovation'],
                                            adminResidenceType: _controllers['adminResidenceType']!.text,
                                            adminJuridicFigure: _adminJuridicFigureNotifier.value,
                                            adminOther: _controllers['adminOther']!.text,
                                            orientation2: _controllers['orientation2']!.text,
                                            healthCard: _controllers['healthCard']!.text,
                                            medication: _controllers['medication']!.text,
                                            orientation2_1: _controllers['orientation2_1']!.text,
                                            rest: _controllers['rest']!.text,
                                            diagnosis: _controllers['diagnosis']!.text,
                                            treatment: _controllers['treatment']!.text,
                                            tracking: _controllers['tracking']!.text,
                                            orientation2_2: _controllers['orientation2_2']!.text,
                                            disabilityState: _disabilityStateNotifier.value,
                                            referenceProfessionalDisability:
                                                _controllers['referenceProfessionalDisability']!.text,
                                            disabilityGrade: _controllers['disabilityGrade']!.text,
                                            disabilityType: _controllers['disabilityType']!.text,
                                            granted: _grantedNotifier.value,
                                            revisionDate: _dateValues['revisionDate'],
                                            orientation2_3: _controllers['orientation2_3']!.text,
                                            dependenceState: _controllers['dependenceState']!.text,
                                            referenceProfessionalDependence:
                                                _controllers['referenceProfessionalDependence']!.text,
                                            dependenceGrade: _controllers['dependenceGrade']!.text,
                                            orientation2_4: _controllers['orientation2_4']!.text,
                                            externalDerivation: _controllers['externalDerivation']!.text,
                                            motive: _controllers['motive']!.text,
                                            orientation3: _controllers['orientation3']!.text,
                                            internalDerivationLegal:
                                                _controllers['internalDerivationLegal']!.text,
                                            internalDerivationDate: _dateValues['internalDerivationDate'],
                                            internalDerivationMotive: _controllers['internalDerivationMotive']!.text,
                                            externalDerivationLegal: _controllers['externalDerivationLegal']!.text,
                                            externalDerivationDate: _dateValues['externalDerivationDate'],
                                            externalDerivationMotive: _controllers['externalDerivationMotive']!.text,
                                            psychosocialDerivationLegal: _controllers['psychosocialDerivationLegal']!.text,
                                            psychosocialDerivationDate: _dateValues['psychosocialDerivationDate'],
                                            psychosocialDerivationMotive: _controllers['psychosocialDerivationMotive']!.text,
                                            legalRepresentation: _controllers['legalRepresentation']!.text,
                                            orientation4: _controllers['orientation4']!.text,
                                            ownershipType: _ownershipTypeNotifier.value,
                                            location: _controllers['location']!.text,
                                            centerContact: _controllers['centerContact']!.text,
                                            hostingObservations: _listValues['hostingObservations']!,
                                            ownershipTypeOpen: _controllers['ownershipTypeOpen']!.text,
                                            homelessnessSituation: _homelessnessSituationNotifier.value,
                                            homelessnessSituationOpen: _controllers['homelessnessSituationOpen']!.text,
                                            livingUnit: _controllers['livingUnit']!.text,
                                            ownershipTypeConcrete: _ownershipTypeConcreteNotifier.value,
                                            orientation5: _controllers['orientation5']!.text,
                                            informationNetworks: _controllers['informationNetworks']!.text,
                                            institutionNetworks:
                                                _controllers['institutionNetworks']!.text,
                                            familyConciliation: _controllers['familyConciliation']!.text,
                                            orientation7: _controllers['orientation7']!.text,
                                            languages: _languagesInit.notifier.value,
                                            orientation9: _controllers['orientation9']!.text,
                                            centerTSReference:
                                                _controllers['centerTSReference']!.text,
                                            subsidyBeneficiary: _subsidyBeneficiaryNotifier.value,
                                            socialExclusionCertificate:
                                            _socialExclusionCertificateNotifier.value,
                                            subsidyName: _controllers['subsidyName']!.text,
                                            socialExclusionCertificateDate: _dateValues['socialExclusionCertificateDate'],
                                            socialExclusionCertificateObservations: _controllers['socialExclusionCertificateObservations']!.text,
                                            orientation12: _controllers['orientation12']!.text,
                                            vulnerabilityOptions:
                                                _listValues['vulnerabilityOptions']!,
                                            orientation13: _controllers['orientation13']!.text,
                                            orientation13_2: _controllers['orientation13_2']!.text,
                                            educationLevel: _controllers['educationLevel']!.text,
                                            homologation: _controllers['homologation']!.text,
                                            laborSituation:
                                              _laborSituationNotifier.value,
                                            laborOtherConsiderations: _controllers['laborOtherConsiderations']!.text,
                                            tempLabor: _controllers['tempLabor']!.text,
                                            workingDayLabor:
                                                _controllers['workingDayLabor']!.text,
                                            competencies: _controllers['competencies']!.text,
                                            contextualization: _controllers['contextualization']!.text,
                                            connexion: _controllers['connexion']!.text,
                                            shortTerm: _controllers['shortTerm']!.text,
                                            mediumTerm: _controllers['mediumTerm']!.text,
                                            longTerm: _controllers['longTerm']!.text,
                                            finished: true,
                                            techPersonName: _techPersonController.text,
                                          ));
                                          Navigator.of(context).pop();
                                          ParticipantSocialReportPage.selectedIndexInforms.value = 0;
                                          //setStateMenuPage();
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.all(8.0),
                                          child: Text('Finalizar',
                                              style: TextStyle(
                                                  color: AppColors.white,
                                                  height: 1.5,
                                                  fontWeight:
                                                      FontWeight.w400,
                                                  fontSize: 14)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryColor,
                                          shadowColor: Colors.transparent,
                                        )
                                    ),
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
