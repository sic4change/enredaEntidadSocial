import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:enreda_empresas/app/common_widgets/alert_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/flex_row_column.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/curriculum/stream_builder_professionsActivities.dart';
import 'package:enreda_empresas/app/models/activity.dart';
import 'package:enreda_empresas/app/models/choice.dart';
import 'package:enreda_empresas/app/models/experience.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:enreda_empresas/app/home/resources/global.dart' as globals;

class ExperienceFormUpdate extends StatefulWidget {
  const ExperienceFormUpdate({
    Key? key,
    this.experience,
    required this.isProfesional,
    this.general,
    this.userId,
    this.onComingBack,
  }) : super(key: key);

  final Experience? experience;
  final bool isProfesional;
  final bool? general;
  final String? userId;
  final void Function(bool isProfesional)? onComingBack;

  @override
  State<ExperienceFormUpdate> createState() => _ExperienceFormUpdateState();
}

class _ExperienceFormUpdateState extends State<ExperienceFormUpdate> {
  bool _isProfesional = true;
  bool _general = false;
  Choice? _type, _subtype, _activity, _role, _level;
  List<Choice> _experienceTypes = [],
      _experienceSubtypes = [],
      _experienceActivities = [],
      _experienceRoles = [],
      _experienceLevels = [];
  final _organizationController = TextEditingController();
  final _positionController = TextEditingController();
  final _locationController = TextEditingController();
  Timestamp? _startDate, _endDate;
  String? _workType, _context, _contextPlace;
  final _formKey = GlobalKey<FormState>();
  bool _experienceIsLoaded = false;

  final TextEditingController _textEditingControllerProfessionsActivities = TextEditingController();
  Set<Activity> selectedProfessionActivities = {};
  List<String> professionActivities = [];
  String? _professionActivityId;

  List<String>? activitiesIds = [];
  String _otherText = "";
  List<Activity> _allProffesionActivities = [];

  late Future<void> _warmUpFuture;

  @override
  void initState() {
    super.initState();
    final database = Provider.of<Database>(context, listen: false);
    _warmUpFuture = LocationCache.instance.warmUpAll(database);

    final exp = widget.experience;
    _isProfesional = widget.isProfesional;
    if (widget.general != null) {
      _general = widget.general!;
    }
    if (exp != null) {
      _startDate = exp.startDate;
      _endDate = exp.endDate;
      _organizationController.text = exp.organization ?? '';
      _positionController.text = exp.position ?? '';
      _locationController.text = exp.location;
      _textEditingControllerProfessionsActivities.text = exp.professionActivitiesText ?? '';
      _otherText = exp.otherProfessionActivityString ?? "";

      if (StringConst.EXPERIENCE_WORK_TYPES.contains(exp.workType)) {
        _workType = exp.workType;
      } else {
        _workType = null;
      }

      if (StringConst.EXPERIENCE_CONTEXT.contains(exp.context)) {
        _context = exp.context;
      } else {
        _context = null;
      }

      if (StringConst.EXPERIENCE_CONTEXT_PLACES.contains(exp.contextPlace)) {
        _contextPlace = exp.contextPlace;
      } else {
        _contextPlace = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _warmUpFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        return StatefulBuilder(builder: (context, setState) {
          _allProffesionActivities = LocationCache.instance.activities;

          _experienceTypes = LocationCache.instance.experienceTypes
              .where((choice) => choice.name == 'Profesional' || choice.name == 'Personal')
              .toList();

          _experienceSubtypes = !_isProfesional ? LocationCache.instance.experienceSubtypes : [];

          if (_isProfesional && _type == null && !_general && _experienceTypes.isNotEmpty) {
            _type = _experienceTypes.firstWhere((element) => element.name == 'Profesional');
          }
          if (!_isProfesional && _type == null && !_general && _experienceTypes.isNotEmpty) {
            _type = _experienceTypes.firstWhere((element) => element.name == 'Personal');
          }

          if (widget.experience != null && !_experienceIsLoaded) {
            if (_type == null && _experienceTypes.isNotEmpty) {
              try {
                _type = _experienceTypes.firstWhere((element) => element.name == widget.experience!.type);
              } catch (_) {}
            }
            if (_subtype == null && _experienceSubtypes.isNotEmpty) {
              try {
                _subtype = _experienceSubtypes.firstWhere((element) => element.name == widget.experience!.subtype);
              } catch (_) {}
            }
          }

          if (_type != null) {
            if (_type?.name == 'Personal') {
              _experienceActivities = LocationCache.instance.activityChoices
                  .where((choice) => choice.typeId == _type?.id && choice.subtypeId == _subtype?.id)
                  .toList();
            } else {
              _experienceActivities = LocationCache.instance.professions;
            }
          } else {
            _experienceActivities = [];
          }

          _experienceRoles = (_type != null && _subtype != null)
              ? LocationCache.instance.activityRoleChoices
                  .where((choice) => choice.typeId == _type?.id && choice.subtypeId == _subtype?.id)
                  .toList()
              : [];

          _experienceLevels = (_type != null && _subtype != null && _subtype!.name == 'Deporte')
              ? LocationCache.instance.activityLevelChoices
                  .where((choice) => choice.typeId == _type?.id && choice.subtypeId == _subtype?.id)
                  .toList()
              : [];

          if (widget.experience != null && !_experienceIsLoaded) {
            _loadDropdowns();
            _experienceIsLoaded = true;
          }

          return Card(
            elevation: 0,
            color: Colors.white,
            child: _buildForm(context, setState),
          );
        });
      },
    );
  }

  Form _buildForm(BuildContext context, StateSetter setState) {
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 15, 16, md: 15);
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextTitle(title: StringConst.MY_EXPERIENCES.toUpperCase()),
            SpaceW12(),
            CustomFlexRowColumn(
              childLeft: _buildTypeDropdown(database, setState),
              childRight: Visibility(
                visible: !_general,
                child: _isProfesional
                    ? _buildActivityDropdown(database, setState)
                    : _buildSubtypeDropdown(database, setState),
              ),
            ),
            !_isProfesional && !_general && _type?.name == 'Personal' && (_subtype?.name == 'Deporte' || _subtype?.name == 'Ocio')
                ? CustomFlexRowColumn(
                    childLeft: _buildActivityDropdown(database, setState),
                    childRight: _buildRoleDropdown(setState),
                  )
                : Container(),
            !_general && _type?.name == 'Personal' && _subtype?.name == 'Deporte'
                ? Padding(
                    padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble / 2),
                    child: _buildLevelDropdown(setState),
                  )
                : Container(),
            !_general
                ? Padding(
                    padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble / 2),
                    child: TextFormField(
                      controller: _organizationController,
                      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        label: Text(
                          'Empresa, organización...',
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  )
                : Container(),
            !_general
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Sizes.kDefaultPaddingDouble / 2),
                    child: TextFormField(
                      controller: _locationController,
                      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        label: Text(
                          'Municipio, ciudad, región o país *',
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
                  )
                : Container(),
            !_general
                ? CustomFlexRowColumn(
                    childLeft: DateTimeField(
                      initialValue: _startDate?.toDate(),
                      format: DateFormat('yyyy'),
                      decoration: InputDecoration(
                        labelText: 'Año inicio *',
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
                        labelText: 'Año fin',
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
                  )
                : Container(),
            (!_general && _type?.name == 'Profesional')
                ? Padding(
                    padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble / 2),
                    child: TextFormField(
                      controller: _textEditingControllerProfessionsActivities,
                      decoration: InputDecoration(
                        label: Text(
                          'Tareas que realizaste *',
                          style: textTheme.bodyMedium,
                        ),
                        labelStyle: textTheme.bodyMedium?.copyWith(
                          color: AppColors.greyDark,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                          fontSize: fontSize,
                        ),
                      ),
                      onTap: () => _showMultiSelectProfessionActivities(context),
                      validator: (value) {
                        if (value == null || value == "") return 'Selecciona un valor';
                        return null;
                      },
                      onSaved: (value) => value = _professionActivityId,
                      readOnly: true,
                      style: textTheme.bodySmall?.copyWith(
                        height: 1.5,
                        color: AppColors.greyDark,
                        fontWeight: FontWeight.w400,
                        fontSize: fontSize,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                : Container(),
            !_general
                ? Padding(
                    padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble / 2),
                    child: TextFormField(
                      controller: _positionController,
                      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        label: Text(
                          'Indica tu cargo...',
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  )
                : Container(),
            SpaceH36(),
            !_general ? CustomTextTitle(title: StringConst.ALL_COMPETENCIES.toUpperCase()) : Container(),
            !_general
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Sizes.kDefaultPaddingDouble / 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿Cómo desarrollaste tu actividad?',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            height: 1.5,
                            color: AppColors.greyDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          isExpanded: true,
                          isDense: true,
                          value: _workType,
                          items: StringConst.EXPERIENCE_WORK_TYPES
                              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (value) {
                            _workType = value ?? _workType;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Selecciona un valor';
                            return null;
                          },
                        ),
                      ],
                    ),
                  )
                : Container(),
            SpaceH20(),
            !_general
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Sizes.kDefaultPaddingDouble / 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿Esta experiencia te supuso un cambio de domicilio?',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            height: 1.5,
                            color: AppColors.greyDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          isDense: true,
                          isExpanded: true,
                          value: _contextPlace,
                          items: StringConst.EXPERIENCE_CONTEXT_PLACES
                              .map((e) => DropdownMenuItem<String>(
                                    value: e,
                                    child: Text(e, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            _contextPlace = value ?? _contextPlace;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Selecciona un valor';
                            return null;
                          },
                        ),
                      ],
                    ),
                  )
                : Container(),
            SpaceH20(),
            !_general
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Sizes.kDefaultPaddingDouble / 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿Esta experiencia te supuso hacer cosas que no solías hacer antes?',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            height: 1.5,
                            color: AppColors.greyDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          isExpanded: true,
                          isDense: true,
                          value: _context,
                          items: StringConst.EXPERIENCE_CONTEXT
                              .map((e) => DropdownMenuItem<String>(
                                    value: e,
                                    child: Text(e, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            _context = value ?? _context;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Selecciona un valor';
                            return null;
                          },
                        ),
                      ],
                    ),
                  )
                : Container(),
            SpaceH24(),
            !_general
                ? Row(
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
                : Container(),
          ],
        ),
      ),
    );
  }

  void _loadDropdowns() {
    if (_type == null && _experienceTypes.isNotEmpty && widget.experience != null) {
      try {
        _type = _experienceTypes.firstWhere((element) => element.name == widget.experience!.type);
      } catch (_) {}
    }

    if (_subtype == null && _experienceSubtypes.isNotEmpty && widget.experience != null) {
      try {
        _subtype = _experienceSubtypes.firstWhere((element) => element.name == widget.experience!.subtype);
      } catch (_) {}
    }

    if (_activity == null && _experienceActivities.isNotEmpty && widget.experience != null) {
      try {
        _activity = _experienceActivities.firstWhere((element) => element.name == widget.experience!.activity);
        activitiesIds = _activity?.activities;
        if (activitiesIds != null && activitiesIds!.isNotEmpty) {
          activitiesIds!.add("30twSwwnuVmpIp3MoE6e");
        }
        selectedProfessionActivities.addAll(
            _allProffesionActivities.where((a) => widget.experience!.professionActivities.contains(a.id)));
      } catch (_) {}
    }

    if (_role == null && _experienceRoles.isNotEmpty && widget.experience != null) {
      try {
        _role = _experienceRoles.firstWhere((element) => element.name == widget.experience!.activityRole);
      } catch (_) {}
    }

    if (_level == null && _experienceLevels.isNotEmpty && widget.experience != null) {
      try {
        _level = _experienceLevels.firstWhere((element) => element.name == widget.experience!.activityLevel);
      } catch (_) {}
    }
  }

  Widget _buildTypeDropdown(Database database, void Function(void Function()) setState) {
    final textTheme = Theme.of(context).textTheme;

    return DropdownButtonFormField<Choice>(
      hint: Text('Tipo *', style: textTheme.bodyMedium),
      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      isExpanded: true,
      isDense: false,
      items: _experienceTypes
          .map((e) => DropdownMenuItem<Choice>(
                value: e,
                child: Text(e.name, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              ))
          .toList(),
      value: _type,
      onChanged: (_type != null && _type!.name.isNotEmpty)
          ? null
          : (newType) {
              setState(() {
                _type = newType;
                _subtype = null;
                _activity = null;
                _role = null;
                _level = null;
                _general = false;

                if (_type?.name == 'Profesional') {
                  _isProfesional = true;
                } else {
                  _isProfesional = false;
                }
              });
            },
      validator: (value) {
        if (value == null || value.name.isEmpty) return 'Selecciona un valor';
        return null;
      },
    );
  }

  Widget _buildSubtypeDropdown(Database database, void Function(void Function()) setState) {
    final textTheme = Theme.of(context).textTheme;

    return DropdownButtonFormField<Choice>(
      hint: Text('Subtipo', style: textTheme.bodyMedium),
      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      isExpanded: true,
      isDense: false,
      items: _experienceSubtypes
          .map((e) => DropdownMenuItem<Choice>(
                value: e,
                child: Text(e.name, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              ))
          .toList(),
      value: _subtype,
      onChanged: (newSubtype) {
        setState(() {
          _subtype = newSubtype;
          _activity = null;
          _role = null;
          _level = null;
        });
      },
    );
  }

  Widget _buildActivityDropdown(Database database, void Function(void Function()) setState) {
    final textTheme = Theme.of(context).textTheme;

    return DropdownButtonFormField<Choice>(
      hint: Text('Actividad', style: textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      isExpanded: true,
      isDense: false,
      items: _experienceActivities
          .map((e) => DropdownMenuItem<Choice>(
                value: e,
                child: Text(e.name, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              ))
          .toList(),
      value: _activity,
      onChanged: (newActivity) {
        setState(() {
          if (_activity?.id != newActivity?.id) {
            selectedProfessionActivities.clear();
            _textEditingControllerProfessionsActivities.clear();
          }
          _activity = newActivity;
          activitiesIds = _activity?.activities;
          if (activitiesIds != null && activitiesIds!.isNotEmpty) {
            activitiesIds!.add("30twSwwnuVmpIp3MoE6e");
          }
        });
      },
    );
  }

  void _showMultiSelectProfessionActivities(BuildContext context) async {
    final textTheme = Theme.of(context).textTheme;
    var selectedValues = await showDialog<Set<Activity>>(
      context: context,
      builder: (BuildContext context) {
        if (_activity == null) {
          return AlertDialog(
            content: Text(
              StringConst.FORM_ACTIVITIES_EMPTY,
              style: textTheme.bodyMedium,
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary900),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  StringConst.FORM_ACCEPT,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        } else {
          return streamBuilderDropdownProfessionActivities(
            context,
            _activity,
            activitiesIds ?? [],
            selectedProfessionActivities,
            (text) => _otherText = text,
            _otherText,
          );
        }
      },
    );
    if (selectedValues != null) {
      getValuesFromKeyProfessionActivities(selectedValues);
    }
  }

  void getValuesFromKeyProfessionActivities(Set<Activity> selectedValues) {
    var concatenate = StringBuffer();
    List<String> actIds = [];
    for (var item in selectedValues) {
      String text = item.name;
      if (item.id == '30twSwwnuVmpIp3MoE6e') {
        text = '${item.name}: $_otherText';
      }
      concatenate.write('$text / ');
      if (item.id != null) {
        actIds.add(item.id!);
      }
    }

    setState(() {
      _textEditingControllerProfessionsActivities.text = concatenate.toString();
      professionActivities = actIds;
      selectedProfessionActivities = selectedValues;
    });
  }

  Widget _buildRoleDropdown(void Function(void Function()) setState) {
    final textTheme = Theme.of(context).textTheme;

    return DropdownButtonFormField<Choice>(
      hint: Text('Rol', style: textTheme.bodyMedium),
      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      isExpanded: true,
      isDense: false,
      items: _experienceRoles
          .map((e) => DropdownMenuItem<Choice>(
                value: e,
                child: Text(e.name, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              ))
          .toList(),
      value: _role,
      onChanged: (newRole) {
        setState(() {
          _role = newRole;
        });
      },
    );
  }

  Widget _buildLevelDropdown(void Function(void Function()) setState) {
    final textTheme = Theme.of(context).textTheme;

    return DropdownButtonFormField<Choice>(
      hint: Text('Nivel', style: textTheme.bodyMedium),
      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      items: _experienceLevels
          .map((e) => DropdownMenuItem<Choice>(
                value: e,
                child: Text(e.name, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              ))
          .toList(),
      value: _level,
      onChanged: (newLevel) {
        setState(() {
          _level = newLevel;
        });
      },
    );
  }

  Future<void> saveExperience() async {
    final database = Provider.of<Database>(context, listen: false);
    final targetUserId = widget.userId ?? globals.currentParticipant?.userId ?? '';

    if (widget.experience == null) {
      final experience = Experience(
        userId: targetUserId,
        type: _type!.name,
        subtype: _subtype?.name,
        activity: _activity?.name,
        activityRole: _role?.name,
        activityLevel: _level?.name,
        startDate: _startDate!,
        endDate: _endDate,
        organization: _organizationController.text,
        location: _locationController.text,
        workType: _workType!,
        context: _context!,
        contextPlace: _contextPlace!,
        professionActivities: professionActivities,
        position: _positionController.text,
        professionActivitiesText: _textEditingControllerProfessionsActivities.text,
        otherProfessionActivityString: _otherText,
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
        widget.onComingBack!(_isProfesional);
      }
    } else {
      final experience = Experience(
        id: widget.experience!.id,
        userId: widget.experience!.userId,
        type: _type!.name,
        subtype: _subtype?.name,
        activity: _activity?.name,
        activityRole: _role?.name,
        activityLevel: _level?.name,
        startDate: _startDate!,
        endDate: _endDate,
        organization: _organizationController.text,
        location: _locationController.text,
        workType: _workType!,
        context: _context!,
        contextPlace: _contextPlace!,
        professionActivities: professionActivities,
        position: _positionController.text,
        professionActivitiesText: _textEditingControllerProfessionsActivities.text,
        otherProfessionActivityString: _otherText,
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
