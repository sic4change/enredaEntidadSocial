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
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../utils/adaptative.dart';
import '../../../utils/responsive.dart';

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

  final TextEditingController _techPersonController = TextEditingController();

  InitialReport initialReportSaved = InitialReport();

  @override
  void initState() {
    //currentPage = initialReport(context, widget.user);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //return currentPage;
    return initialReport(context, widget.user);
  }

  // void setStateMenuPage() {
  //   setState(() {
  //     currentPage = ParticipantSocialReportPage(
  //         participantUser: widget.user, context: context);
  //   });
  // }

  void _addLanguage(){
    final newLanguages = List<LanguageReport>.from(_languagesNotifier.value)..add(LanguageReport(name: '', level: ''));
    _languagesNotifier.value = newLanguages;
  }

  Widget initialReport(BuildContext context, UserEnreda user) {
    final database = Provider.of<Database>(context, listen: false);

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.greyBorder)),
          child: Column(children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 50, vertical: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
        ));
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

  Widget completeInitialForm(BuildContext context, InitialReport report) {
    final database = Provider.of<Database>(context, listen: false);
    final _formKey = GlobalKey<FormState>();
    final textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 13, 20, md: 16);
    double fontSizeSubTitle = responsiveSize(context, 14, 18, md: 15);
    bool _finished = report.finished ?? false;

    //Pre-Selection
    String? _subsidy = report.subsidy ?? '';
    String? _techPerson = report.techPerson ?? widget.user.assignedById;

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
            informSectionTitle(StringConst.INITIAL_TITLE1_ITINERARY),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              initialValue: _orientation1,
              onChanged: (value) {
                _orientation1 = value ?? '';
              },
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
              ),
              childRight: CustomTextFormFieldTitle(
                labelText: StringConst.INITIAL_RECEPTION_RESOURCES,
                initialValue: _receptionResources,
                onChanged: (value) {
                  _receptionResources = value ?? '';
                },
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
                    initialValue: _adminNoThrough,
                    onChanged: (value) {
                      _adminNoThrough = value;
                    },
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
                      ),
                      childRight: CustomDatePickerTitle(
                        labelText: StringConst.INITIAL_DATE_RESOLUTION,
                        initialValue: _adminDateResolution,
                        onChanged: (value) {
                          _adminDateResolution = value;
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
              childLeft: _adminResidenceType == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_RESIDENCE_TYPE,
                source: StringConst.ADMIN_RESIDENCE_TYPE_SELECTION,
                onChanged: _finished
                    ? null
                    : (value) {
                  _adminResidenceType = value!;
                },
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
              initialValue: _orientation2,
              onChanged: (value) {
                _orientation2 = value;
              },
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
                    ),
              childRight: CustomDatePickerTitle(
                labelText: StringConst.INITIAL_EXPIRATION_DATE,
                initialValue: _expirationDate,
                onChanged: (value) {
                  _expirationDate = value;
                },
                enabled: !_finished,
              ),
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_MEDICATION,
              initialValue: _medication,
              onChanged: (value) {
                _medication = value;
              },
              enabled: !_finished,
            ),
            //Subsection 2.1
            informSubSectionTitle(StringConst.INITIAL_TITLE_2_1_MENTAL_HEALTH),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              initialValue: _orientation2_1,
              onChanged: (value) {
                _orientation2_1 = value;
              },
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

            //Subsection 2.2
            informSubSectionTitle(StringConst.INITIAL_TITLE_2_2_DISABILITY),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              initialValue: _orientation2_2,
              onChanged: (value) {
                _orientation2_2 = value;
              },
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
                   /*   validator: (value) =>
                          value != null ? null : StringConst.FORM_GENERIC_ERROR,*/
                    ),
            ),

            //Subsection 2.3
            informSubSectionTitle(StringConst.INITIAL_TITLE_2_3_DEPENDENCE),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              initialValue: _orientation2_3,
              onChanged: (value) {
                _orientation2_3 = value;
              },
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
                    ),
              childRight: _dependenceGrade == ''
                  ? CustomDropDownButtonFormFieldTittle(
                labelText: StringConst.INITIAL_DEPENDENCE_GRADE,
                source: StringConst.DEPENDENCE_GRADE_SELECTION,
                onChanged: _finished
                    ? null
                    : (value) {
                  _dependenceGrade = value;
                },
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
              ),
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_REFERENCE_PROFESSIONAL,
              initialValue: _referenceProfessionalDependence,
              onChanged: (value) {
                _referenceProfessionalDependence = value;
              },
              enabled: !_finished,
            ),

            //Subsection 2.4
            informSubSectionTitle(StringConst.INITIAL_TITLE_2_4_ADDICTIONS),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              initialValue: _orientation2_4,
              onChanged: (value) {
                _orientation2_4 = value;
              },
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
              ),
              childRight: CustomTextFormFieldTitle(
                labelText: StringConst.INITIAL_MOTIVE,
                initialValue: _motive,
                onChanged: (value) {
                  _motive = value;
                },
                enabled: !_finished,
              ),
            ),

            //Section 3
            informSectionTitle(StringConst.INITIAL_TITLE_3_LEGAL_SITUATION),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              initialValue: _orientation3,
              onChanged: (value) {
                _orientation3 = value;
              },
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
                    ),
              childRight: CustomDatePickerTitle(
                labelText: StringConst.INITIAL_DERIVATION_DATE,
                initialValue: _internalDerivationDate,
                onChanged: (value) {
                  _internalDerivationDate = value;
                },
                enabled: !_finished,
              ),
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_MOTIVE,
              initialValue: _internalDerivationMotive,
              onChanged: (value) {
                _internalDerivationMotive = value;
              },
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
              ),
              childRight: CustomDatePickerTitle(
                labelText: StringConst.INITIAL_DERIVATION_DATE,
                initialValue: _psychosocialDerivationDate,
                onChanged: (value) {
                  _psychosocialDerivationDate = value;
                },
                enabled: !_finished,
              ),
            ),
            SpaceH12(), //TODO check values saved
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_MOTIVE,
              initialValue: _psychosocialDerivationMotive,
              onChanged: (value) {
                _psychosocialDerivationMotive = value;
              },
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
              ),
              childRight: CustomDatePickerTitle(
                labelText: StringConst.INITIAL_DERIVATION_DATE,
                initialValue: _externalDerivationDate,
                onChanged: (value) {
                  _externalDerivationDate = value;
                },
                enabled: !_finished,
              ),
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_MOTIVE,
              initialValue: _externalDerivationMotive,
              onChanged: (value) {
                _externalDerivationMotive = value;
              },
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
              enabled: !_finished,
            ),

            //Section 4
            informSectionTitle(StringConst.INITIAL_TITLE_4_HOUSE_SITUATION),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              initialValue: _orientation4,
              onChanged: (value) {
                _orientation4 = value;
              },
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
                          initialValue: _ownershipTypeOpen,
                          onChanged: (value) {
                            _ownershipTypeOpen = value;
                          },
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
                enabled: !_finished,
              ),
              childRight: CustomTextFormFieldTitle(
                labelText: StringConst.INITIAL_CENTER_CONTACT,
                initialValue: _centerContact,
                onChanged: (value) {
                  _centerContact = value;
                },
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
              enabled: !_finished,
            ),
            SpaceH12(),
            Align(
                alignment: Alignment.centerLeft,
                child: CustomMultiSelectionCheckBoxList(
                    options: StringConst.OPTIONS_SECTION_4,
                    selections: _hostingObservations,
                    enabled: !_finished)),

            //Section 5
            informSectionTitle(StringConst.INITIAL_TITLE_5_SUPPORT),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              initialValue: _orientation5,
              onChanged: (value) {
                _orientation5 = value;
              },
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
                enabled: !_finished,
              ),
              childRight: CustomTextFormFieldTitle(
                labelText: StringConst.INITIAL_FAMILY_CONCILIATION,
                initialValue: _familyConciliation,
                onChanged: (value) {
                  _familyConciliation = value;
                },
                enabled: !_finished,
              ),
            ),

            //Section 6
            informSectionTitle(StringConst.INITIAL_TITLE_6_LANGUAGES),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              initialValue: _orientation7,
              onChanged: (value) {
                _orientation7 = value;
              },
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
                                ),
                                childRight: CustomTextFormFieldTitle(
                                  labelText:
                                  StringConst.INITIAL_LANGUAGE_LEVEL,
                                  initialValue: language.level,
                                  onChanged: (value) {
                                    _languagesNotifier.value[_languagesNotifier
                                        .value.indexOf(language)].level = value;
                                  },
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

            //Section 7
            informSectionTitle(StringConst.INITIAL_TITLE_7_SOCIAL_ATTENTION),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              initialValue: _orientation9,
              onChanged: (value) {
                _orientation9 = value;
              },
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_CENTER_TS,
              initialValue: _centerTSReference,
              onChanged: (value) {
                _centerTSReference = value;
              },
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
                    initialValue: _subsidyName,
                    onChanged: (value) {
                      _subsidyName = value;
                    },
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
                          childRight: CustomDatePickerTitle(
                            labelText: StringConst.INITIAL_DATE,
                            initialValue: _socialExclusionCertificateDate,
                            onChanged: (value) {
                              _socialExclusionCertificateDate = value;
                            },
                            enabled: !_finished,
                          ),
                          childLeft: CustomTextFormFieldTitle(
                            labelText: StringConst.INITIAL_SOCIAL_EXCLUSION_OBSERVATIONS,
                            initialValue: _socialExclusionCertificateObservations,
                            onChanged: (value) {
                              _socialExclusionCertificateObservations = value;
                            },
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
              initialValue: _orientation12,
              onChanged: (value) {
                _orientation12 = value;
              },
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomMultiSelectionCheckBoxList(
                options: StringConst.OPTIONS_SECTION_12,
                selections: _vulnerabilityOptions,
                enabled: !_finished),

            //Section 9
            informSectionTitle(StringConst.INITIAL_TITLE_9_WORK),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              initialValue: _orientation13,
              onChanged: (value) {
                _orientation13 = value;
              },
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
            ),
            informSubSectionTitle(StringConst.INITIAL_TITLE_9_2_WORK_SITUATION),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_OBSERVATIONS,
              initialValue: _orientation13_2,
              onChanged: (value) {
                _orientation13_2 = value;
              },
              enabled: !_finished,
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
                  ),
                ) :
                Container();
              }
            ),

            informSubSectionTitle(StringConst.INITIAL_TITLE_9_3_TRAJECTORY),
            CustomTextFormFieldTitle(
              labelText:
                  StringConst.INITIAL_COMPETENCIES,
              initialValue: _competencies,
              onChanged: (value) {
                _competencies = value ?? '';
              },
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_CONTEXTUALIZATION,
              initialValue: _contextualization,
              onChanged: (value) {
                _contextualization = value ?? '';
              },
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_CONNEXION,
              initialValue: _connexion,
              onChanged: (value) {
                _connexion = value ?? '';
              },
              enabled: !_finished,
            ),

            informSubSectionTitle(StringConst.INITIAL_TITLE_9_4_EXPECTATIONS),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_SHORT_TERM,
              initialValue: _shortTerm,
              onChanged: (value) {
                _shortTerm = value ?? '';
              },
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_MEDIUM_TERM,
              initialValue: _mediumTerm,
              onChanged: (value) {
                _mediumTerm = value ?? '';
              },
              enabled: !_finished,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: StringConst.INITIAL_LONG_TERM,
              initialValue: _longTerm,
              onChanged: (value) {
                _longTerm = value ?? '';
              },
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
                              database.setInitialReport(InitialReport(
                                userId: report.userId,
                                initialReportId: report.initialReportId,
                                subsidy: _subsidy,
                                techPerson: _techPerson,
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
                                finished: false,
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
                                          database.setInitialReport(
                                              InitialReport(
                                            userId: report.userId,
                                            initialReportId:
                                                report.initialReportId,
                                            subsidy: _subsidy,
                                            techPerson: _techPerson,
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
                                            finished: true,
                                            completedDate: DateTime.now(),
                                          ));
                                          Navigator.of(context).pop();
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
