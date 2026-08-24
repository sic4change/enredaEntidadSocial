import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:enreda_empresas/app/common_widgets/alert_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/flex_row_column.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/models/education.dart';
import 'package:enreda_empresas/app/models/experience.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:enreda_empresas/app/home/resources/global.dart' as globals;

class FormationForm extends StatefulWidget {
  const FormationForm({
    Key? key,
    this.experience,
    required this.isMainEducation,
    this.userId,
    this.onComingBack,
  }) : super(key: key);

  final Experience? experience;
  final bool isMainEducation;
  final String? userId;
  final VoidCallback? onComingBack;

  @override
  State<FormationForm> createState() => _FormationFormState();
}

class _FormationFormState extends State<FormationForm> {
  late String _type;
  final _nameFormationController = TextEditingController();
  final _organizationController = TextEditingController();
  String? _institution;
  Timestamp? _startDate, _endDate;
  List<DropdownMenuItem<Education>> educationItems = [];
  final _locationController = TextEditingController();
  final _extraDataController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final exp = widget.experience;
    if (widget.isMainEducation) {
      _type = 'Formativa';
    } else {
      _type = 'Complementaria';
    }
    if (exp != null) {
      _nameFormationController.text = exp.nameFormation ?? '';
      _organizationController.text = exp.organization ?? '';
      _institution = exp.institution ?? '';
      _startDate = exp.startDate;
      _endDate = exp.endDate;
      _locationController.text = exp.location;
      _extraDataController.text = exp.extraData ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);

    return StatefulBuilder(builder: (context, setState) {
      return Card(
        elevation: 0,
        color: Colors.white,
        child: StreamBuilder<List<Education>>(
          stream: database.educationStream(),
          builder: (context, snapshotEducation) {
            if (snapshotEducation.hasData) {
              educationItems = snapshotEducation.data!
                  .map((Education education) => DropdownMenuItem<Education>(
                        value: education,
                        child: Text(education.label),
                      ))
                  .toList();
            }

            return _buildForm(context, setState);
          },
        ),
      );
    });
  }

  Form _buildForm(BuildContext context, StateSetter setState) {
    final textTheme = Theme.of(context).textTheme;
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            formFieldCustom(CustomTextTitle(
              title: widget.isMainEducation
                  ? StringConst.EDUCATION.toUpperCase()
                  : StringConst.SECONDARY_EDUCATION.toUpperCase(),
            )),
            formFieldCustom(
              TextFormField(
                controller: _nameFormationController,
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  label: Text(
                    'Nombre de la formación',
                    style: textTheme.bodyMedium,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre de la formación es un campo obligatorio';
                  }
                  return null;
                },
              ),
            ),
            formFieldCustom(
              DropdownButtonFormField<String>(
                hint: Text(
                  'Institución educativa',
                  style: textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                isExpanded: true,
                isDense: false,
                value: _institution == '' ? null : _institution,
                items: const [
                  'Colegio',
                  'Instituto',
                  'Universidad',
                  'Centro de Formación',
                  'Empresa',
                  'Fundación'
                ]
                    .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  _institution = value ?? _institution;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecciona un valor';
                  }
                  return null;
                },
              ),
            ),
            formFieldCustom(
              TextFormField(
                controller: _organizationController,
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  label: Text(
                    'Nombre institución educativa',
                    style: textTheme.bodyMedium,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre de la institución educativa es obligatorio';
                  }
                  return null;
                },
              ),
            ),
            CustomFlexRowColumn(
              childLeft: DateTimeField(
                initialValue: _startDate?.toDate(),
                format: DateFormat('yyyy'),
                decoration: InputDecoration(
                  labelText: 'Año de inicio',
                  labelStyle: textTheme.bodyMedium,
                  suffixIcon: const Icon(Icons.event),
                ),
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                    context: context,
                    confirmText: StringConst.FORM_CONFIRM,
                    initialDatePickerMode: DatePickerMode.year,
                    locale: const Locale('es', 'ES'),
                    firstDate: DateTime(DateTime.now().year - 100),
                    initialDate: currentValue ?? _endDate?.toDate() ?? DateTime.now(),
                    lastDate: _endDate?.toDate() ?? DateTime.now(),
                    initialEntryMode: DatePickerEntryMode.calendarOnly,
                  );
                },
                onChanged: (dateTime) {
                  if (dateTime != null) {
                    setState(() => _startDate = Timestamp.fromDate(dateTime));
                  }
                },
                validator: (value) {
                  if (value == null || value.toString().isEmpty) {
                    return 'El año de inicio es un campo obligatorio';
                  }
                  return null;
                },
              ),
              childRight: DateTimeField(
                initialValue: _endDate?.toDate(),
                format: DateFormat('yyyy'),
                decoration: InputDecoration(
                  labelText: 'Año de fin',
                  labelStyle: textTheme.bodyMedium,
                  suffixIcon: const Icon(Icons.event),
                ),
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                    context: context,
                    confirmText: StringConst.FORM_CONFIRM,
                    initialDatePickerMode: DatePickerMode.year,
                    locale: const Locale('es', 'ES'),
                    firstDate: _startDate?.toDate() ?? DateTime(DateTime.now().year - 100),
                    initialDate: currentValue ?? DateTime.now(),
                    lastDate: DateTime.now(),
                    initialEntryMode: DatePickerEntryMode.calendarOnly,
                  );
                },
                onChanged: (dateTime) {
                  if (dateTime != null) {
                    setState(() => _endDate = Timestamp.fromDate(dateTime));
                  }
                },
              ),
            ),
            formFieldCustom(
              TextFormField(
                controller: _locationController,
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  label: Text(
                    'Municipio, ciudad, región o país',
                    style: textTheme.bodyMedium,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El Municipio, ciudad, región o país es un campo obligatorio';
                  }
                  return null;
                },
              ),
            ),
            formFieldCustom(
              TextFormField(
                controller: _extraDataController,
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  label: Text(
                    'Datos de interés sobre la formación',
                    style: textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
            SpaceH24(),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        StringConst.CANCEL,
                        style: textTheme.bodyMedium,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                SpaceW24(),
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(AppColors.primary900),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        StringConst.SAVE,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        saveExperience();
                      }
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget formFieldCustom(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble / 2),
      child: SizedBox(
        width: Responsive.isMobile(context)
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.width / 3,
        child: child,
      ),
    );
  }

  Future<void> saveExperience() async {
    final database = Provider.of<Database>(context, listen: false);
    final targetUserId = widget.userId ?? globals.currentParticipant?.userId ?? '';

    if (widget.experience == null) {
      final experience = Experience(
        userId: targetUserId,
        type: _type,
        subtype: '',
        activity: '',
        activityRole: '',
        activityLevel: '',
        startDate: _startDate!,
        endDate: _endDate,
        organization: _organizationController.text,
        location: _locationController.text,
        workType: '',
        context: '',
        contextPlace: '',
        professionActivities: [],
        position: '',
        professionActivitiesText: '',
        nameFormation: _nameFormationController.text,
        education: '',
        institution: _institution,
        extraData: _extraDataController.text,
      );

      await database.addExperience(experience);
      if (!mounted) return;
      Navigator.of(context).pop();
      await showAlertDialog(
        context,
        title: 'Información guardada',
        content: 'La información ha sido guardada en el CV correctamente',
        defaultActionText: 'Ok',
      );
      if (widget.onComingBack != null) {
        widget.onComingBack!();
      }
    } else {
      final experience = Experience(
        id: widget.experience!.id,
        userId: widget.experience!.userId,
        type: _type,
        subtype: '',
        activity: '',
        activityRole: '',
        activityLevel: '',
        startDate: _startDate!,
        endDate: _endDate,
        organization: _organizationController.text,
        location: _locationController.text,
        workType: '',
        context: '',
        contextPlace: '',
        position: '',
        professionActivitiesText: '',
        nameFormation: _nameFormationController.text,
        education: '',
        institution: _institution,
        extraData: _extraDataController.text,
      );

      await database.updateExperience(experience);
      if (!mounted) return;
      Navigator.of(context).pop();
      await showAlertDialog(
        context,
        title: 'Información guardada',
        content: 'La información ha sido guardada en el CV correctamente',
        defaultActionText: 'Ok',
      );
    }
  }
}
