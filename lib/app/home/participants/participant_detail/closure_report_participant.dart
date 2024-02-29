import 'package:enreda_empresas/app/common_widgets/custom_date_picker_title.dart';
import 'package:enreda_empresas/app/common_widgets/custom_drop_down_button_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/custom_multi_selection_radio_list.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/enreda_button.dart';
import 'package:enreda_empresas/app/common_widgets/flex_row_column.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/common_widgets/text_form_field.dart';
import 'package:enreda_empresas/app/models/closureReport.dart';
import 'package:enreda_empresas/app/models/initialReport.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/auth.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'participant_social_reports_page.dart';

class ClosureReportForm extends StatefulWidget {
  const ClosureReportForm({super.key, required this.user});

  final UserEnreda user;

  @override
  State<ClosureReportForm> createState() => _ClosureReportFormState();
}

class _ClosureReportFormState extends State<ClosureReportForm> {

  late Widget currentPage;

  @override
  void initState() {
    currentPage = closureReport(context, widget.user);
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


  Widget closureReport(BuildContext context, UserEnreda user) {
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
                      CustomTextBoldTitle(
                          title: 'Informe de cierre de caso'.toUpperCase()),
                    ],
                  ),
                ),
                Divider(color: AppColors.greyBorder,),
                StreamBuilder<ClosureReport>(
                    stream: database.closureReportsStreamByUserId(user.userId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        ClosureReport closureReportSaved = snapshot.data!;
                        return completeClosureForm(
                            context, closureReportSaved, user);
                      }
                      else {
                        if (user.closureReportId == null) {
                          database.addClosureReport(ClosureReport(
                            userId: user.userId,
                          ));
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

  Widget personalDataLine(String title, String content) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          title + ': ',
          style: TextStyle(
            fontFamily: GoogleFonts
                .inter()
                .fontFamily,
            fontWeight: FontWeight.w400,
            color: AppColors.greyAlt,
            fontSize: 14,
          ),
        ),
        Text(
          content,
          style: TextStyle(
            fontFamily: GoogleFonts
                .inter()
                .fontFamily,
            fontWeight: FontWeight.w600,
            color: AppColors.turquoiseBlue,
            fontSize: 14,
          ),
        ),
      ],
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
          color: AppColors.penBlue,
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
          color: AppColors.penBlue,
        ),
      ),
    );
  }

  Widget completeClosureForm(BuildContext context, ClosureReport report,
      UserEnreda user) {
    final database = Provider.of<Database>(context, listen: false);
    final _formKey = GlobalKey<FormState>();

    String _userName = '${user.firstName} ${user.lastName}';
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    String _userBirthDate = formatter.format(user.birthday!);
    String _userGender = user.gender!;
    String _userNationality = user.nationality ?? '';

    bool _finished = report.finished ?? false;

    String _background = report.background ?? '';
    String _initialDiagnosis = report.initialDiagnosis ?? '';
    String _closureReasons = report.closureReasons ?? '';
    String _itineraryFollowed = report.itineraryFollowed ?? '';

    List<DropdownMenuItem<String>> _closureReasonsOptions = [
      'Por éxito de inserción',
      'Por desvinculación de la usuaria',
      'Por mudanza',
      'Porque ha conseguido empleo por sus propios medios'
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

            informSectionTitle('1. Datos personales'),
            personalDataLine('Nombres y Apellidos', _userName),
            SpaceH4(),
            personalDataLine('Fecha de nacimiento', _userBirthDate),
            SpaceH4(),
            _userNationality != '' ? personalDataLine(
                'Nacionalidad', _userNationality) : Container(),
            _userNationality != '' ? SpaceH4() : Container(),
            personalDataLine('Sexo/Género', _userGender),
            //SpaceH4(),
            //personalDataLine('Estado Civil', ''),

            informSectionTitle('2. Historial'),
            CustomTextFormFieldTitle(
              labelText: 'Antecedentes',
              initialValue: _background,
              onChanged: (value) {
                _background = value;
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
              hintText: 'Cómo la usuaria llega a enREDa y descripción inicial de la situación',
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: 'Diagnóstico incial',
              initialValue: _initialDiagnosis,
              onChanged: (value) {
                _initialDiagnosis = value;
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
              hintText: 'Descripción resumida del diagnóstico inicial donde se detallan las decisiones tomadas en conjunto y las acciones llevadas a cabo para responder a sus necesidades',
            ),
            SpaceH12(),
            _closureReasons == '' ? CustomDropDownButtonFormFieldTittle(
              labelText: 'Motivos del cierre del caso',
              source: _closureReasonsOptions,
              onChanged: _finished ? null : (value) {
                _closureReasons = value!;
              },
              validator: (value) =>
              value != null ? null : StringConst.FORM_GENERIC_ERROR,
            ) :
            CustomDropDownButtonFormFieldTittle(
              labelText: 'Motivos del cierre del caso',
              source: _closureReasonsOptions,
              onChanged: _finished ? null : (value) {
                _closureReasons = value!;
              },
              value: _closureReasons,
              validator: (value) =>
              value != null ? null : StringConst.FORM_GENERIC_ERROR,
            ),
            SpaceH12(),
            CustomTextFormFieldTitle(
              labelText: 'Itinerario realizado',
              initialValue: _itineraryFollowed,
              onChanged: (value) {
                _itineraryFollowed = value;
              },
              validator: (value) =>
              (value!.isNotEmpty || value != '')
                  ? null
                  : StringConst.FORM_GENERIC_ERROR,
              enabled: !_finished,
              hintText: 'Todas las acciones llevadas a cabo para lograr la inserción, en caso de que se haya cumplido, talleres, acompañamientos, formaciones, intermediaciones, etcétera.',
            ),

            _finished ? Container() : Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 30),
              child: Center(
                child: Container(
                  height: 50,
                  width: 250,
                  child: ElevatedButton(
                      onPressed: () async {
                        database.setClosureReport(
                            ClosureReport(
                              userId: report.userId,
                              closureReportId: report.closureReportId,
                              background: _background,
                              initialDiagnosis: _initialDiagnosis,
                              closureReasons: _closureReasons,
                              itineraryFollowed: _itineraryFollowed,
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
                                          database.setClosureReport(
                                              ClosureReport(
                                                userId: report.userId,
                                                closureReportId: report
                                                    .closureReportId,
                                                background: _background,
                                                initialDiagnosis: _initialDiagnosis,
                                                closureReasons: _closureReasons,
                                                itineraryFollowed: _itineraryFollowed,
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