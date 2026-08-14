import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/curriculum/participant_cv_models_page.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/my_curriculum_page.dart';
import 'package:enreda_empresas/app/models/certificationRequest.dart';
import 'package:enreda_empresas/app/models/education.dart';
import 'package:enreda_empresas/app/models/experience.dart';
import 'package:enreda_empresas/app/models/language.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Contenedor del flujo de Currículum (3 pasos):
///   Paso 0 — [MyCurriculumPage] — visualización/edición del CV
///   Paso 1 — [ParticipantCvModelsPage] — selección de datos a incluir
///   Paso 2 — [MyCvMultiplePages] — se abre como página completa al pulsar "Siguiente >"
///
/// Los pasos 0 y 1 se muestran dentro del contenedor del perfil (mismo estilo
/// que [ParticipantIPILPage]).
class ParticipantCurriculumPage extends StatefulWidget {
  const ParticipantCurriculumPage({Key? key, required this.participantUser}) : super(key: key);

  final UserEnreda participantUser;

  /// Shared index so external code can reset the step if needed.
  static ValueNotifier<int> selectedStep = ValueNotifier(0);

  @override
  State<ParticipantCurriculumPage> createState() => _ParticipantCurriculumPageState();
}

class _ParticipantCurriculumPageState extends State<ParticipantCurriculumPage> {
  // ─── Data captured from MyCurriculumPage to pass forward to step 1 ────────
  // These are populated when the user taps "Previsualizar y descargar" in step 0.
  // They expose the internal selection state of MyCurriculumPage.
  String _city = '';
  String _province = '';
  String _country = '';
  String _aboutMe = '';
  String _email = '';
  String _phone = '';
  String _maxEducation = '';
  List<Experience> _myExperiences = [];
  List<Experience> _myCustomExperiences = [];
  List<int> _mySelectedExperiences = [];
  List<Experience> _myPersonalExperiences = [];
  List<Experience> _myPersonalCustomExperiences = [];
  List<int> _myPersonalSelectedExperiences = [];
  List<Experience> _myEducation = [];
  List<Experience> _myCustomEducation = [];
  List<int> _mySelectedEducation = [];
  List<Experience> _mySecondaryEducation = [];
  List<Experience> _mySecondaryCustomEducation = [];
  List<int> _mySecondarySelectedEducation = [];
  List<String> _competenciesNames = [];
  List<String> _myCustomCompetencies = [];
  List<int> _mySelectedCompetencies = [];
  List<String> _myCustomDataOfInterest = [];
  List<int> _mySelectedDataOfInterest = [];
  List<Language> _myCustomLanguages = [];
  List<int> _mySelectedLanguages = [];
  List<CertificationRequest> _myCustomReferences = [];
  List<int> _mySelectedReferences = [];
  String _myCustomCity = '';
  String _myCustomProvince = '';
  String _myCustomCountry = '';

  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    ParticipantCurriculumPage.selectedStep.value = 0;
    final database = Provider.of<Database>(context, listen: false);
    LocationCache.instance.warmUpAll(database);
    if (LocationCache.instance.competencies.isEmpty) {
      database.getCompetencies().then((comps) {
        LocationCache.instance.competencies = comps;
        if (mounted) setState(() {});
      }).catchError((_) {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _goToStep1() async {
    final user = widget.participantUser;
    final database = Provider.of<Database>(context, listen: false);

    var allCompetencies = LocationCache.instance.competencies;
    if (allCompetencies.isEmpty) {
      try {
        allCompetencies = await database.getCompetencies();
        LocationCache.instance.competencies = allCompetencies;
      } catch (_) {}
    }

    var educations = LocationCache.instance.educations;
    if (educations.isEmpty) {
      try {
        educations = await database.educationStream().first;
        LocationCache.instance.educations = educations;
      } catch (_) {}
    }

    // Location from cache
    final myCountry = LocationCache.instance.countryById(user.address?.country);
    final myProvince = LocationCache.instance.provinceById(user.address?.province);
    final myCity = LocationCache.instance.cityById(user.address?.city);

    _city = myCity?.name ?? '';
    _province = myProvince?.name ?? '';
    _country = myCountry?.name ?? '';
    _aboutMe = user.aboutMe ?? '';
    _email = user.email;
    _phone = user.phone ?? '';

    // Education level
    if (user.educationId?.isNotEmpty == true) {
      final edu = educations.firstWhere(
        (e) => e.educationId == user.educationId,
        orElse: () => Education(label: '', value: '', order: 0),
      );
      _maxEducation = edu.label;
    } else {
      _maxEducation = '';
    }

    final competenciesMap = user.competencies;
    final competenciesIds = competenciesMap.keys.toList();
    final filtered = allCompetencies
        .where((c) => c.id != null && competenciesIds.contains(c.id))
        .toList();
    _competenciesNames = [];
    for (final c in filtered) {
      if (c.id == null) continue;
      final status = competenciesMap[c.id] ?? StringConst.BADGE_EMPTY;
      if (c.name.isNotEmpty &&
          status != StringConst.BADGE_EMPTY &&
          status != StringConst.BADGE_IDENTIFIED) {
        if (!_competenciesNames.contains(c.name)) _competenciesNames.add(c.name);
      }
    }
    _myCustomCompetencies = List.from(_competenciesNames);
    _mySelectedCompetencies = List.generate(_myCustomCompetencies.length, (i) => i);

    final dataOfInterest = user.dataOfInterest;
    _myCustomDataOfInterest = List.from(dataOfInterest);
    _mySelectedDataOfInterest = List.generate(_myCustomDataOfInterest.length, (i) => i);

    final languages = user.languagesLevels;
    _myCustomLanguages = List.from(languages);
    _mySelectedLanguages = List.generate(_myCustomLanguages.length, (i) => i);

    _myCustomCity = _city;
    _myCustomProvince = _province;
    _myCustomCountry = _country;

    // Load experiences
    try {
      final allExp = await database.myExperiencesStream(user.userId ?? '').first;
      if (!mounted) return;
      _myExperiences = allExp.where((e) => e.type == 'Profesional').toList();
      _myPersonalExperiences = allExp.where((e) => e.type == 'Personal').toList();
      _myEducation = allExp.where((e) => e.type == 'Formativa').toList();
      _mySecondaryEducation = allExp.where((e) => e.type == 'Complementaria').toList();

      _myCustomExperiences = List.from(_myExperiences);
      _mySelectedExperiences = List.generate(_myExperiences.length, (i) => i);
      _myPersonalCustomExperiences = List.from(_myPersonalExperiences);
      _myPersonalSelectedExperiences = List.generate(_myPersonalExperiences.length, (i) => i);
      _myCustomEducation = List.from(_myEducation);
      _mySelectedEducation = List.generate(_myEducation.length, (i) => i);
      _mySecondaryCustomEducation = List.from(_mySecondaryEducation);
      _mySecondarySelectedEducation = List.generate(_mySecondaryEducation.length, (i) => i);
    } catch (_) {}

    // Load certification requests for references
    try {
      final refs = await database.myCertificationRequestStream(user.userId ?? '').first;
      if (!mounted) return;
      final referenced = refs.where((r) => r.referenced == true).toList();
      _myCustomReferences = List.from(referenced);
      _mySelectedReferences = List.generate(referenced.length, (i) => i);
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      ParticipantCurriculumPage.selectedStep.value = 1;
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ParticipantCurriculumPage.selectedStep,
      builder: (context, step, _) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.greyBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              Padding(
                padding: Responsive.isMobile(context)
                    ? const EdgeInsets.fromLTRB(20, 14, 20, 10)
                    : const EdgeInsets.fromLTRB(44, 22, 44, 12),
                child: Responsive.isMobile(context)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextBoldTitle(title: StringConst.MY_CV),
                          const SizedBox(height: 8),
                          _buildStepIndicator(step),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomTextBoldTitle(title: StringConst.MY_CV),
                          const SizedBox(width: 24),
                          _buildStepIndicator(step),
                        ],
                      ),
              ),
              const Divider(color: AppColors.greyBorder),
              // ── Step content ──────────────────────────────────────────────
              _buildStep(step),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepIndicator(int step) {
    final steps = ['Currículum', 'Seleccionar datos'];
    return Row(
      children: List.generate(steps.length, (i) {
        final isActive = i == step;
        final isDone = i < step;
        return Row(
          children: [
            if (i > 0)
              Container(
                width: 24,
                height: 1,
                color: isDone ? AppColors.primary900 : AppColors.greyBorder,
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary900 : (isDone ? AppColors.primary900.withValues(alpha: 0.15) : Colors.transparent),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive || isDone ? AppColors.primary900 : AppColors.greyBorder,
                ),
              ),
              child: Text(
                steps[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive
                      ? Colors.white
                      : (isDone ? AppColors.primary900 : AppColors.greyTxtAlt),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStep(int step) {
    switch (step) {
      case 0:
        return MyCurriculumPage(
          key: ValueKey('curriculum_step0_${widget.participantUser.userId}'),
          user: widget.participantUser,
          onPreview: _goToStep1,
        );
      case 1:
        return ParticipantCvModelsPage(
          key: ValueKey('curriculum_step1'),
          user: widget.participantUser,
          city: _city,
          province: _province,
          country: _country,
          myCustomAboutMe: _aboutMe,
          myCustomEmail: _email,
          myCustomPhone: _phone,
          myExperiences: _myExperiences,
          myCustomExperiences: _myCustomExperiences,
          mySelectedExperiences: _mySelectedExperiences,
          myPersonalExperiences: _myPersonalExperiences,
          myPersonalCustomExperiences: _myPersonalCustomExperiences,
          myPersonalSelectedExperiences: _myPersonalSelectedExperiences,
          myEducation: _myEducation,
          myCustomEducation: _myCustomEducation,
          mySelectedEducation: _mySelectedEducation,
          mySecondaryEducation: _mySecondaryEducation,
          mySecondaryCustomEducation: _mySecondaryCustomEducation,
          mySecondarySelectedEducation: _mySecondarySelectedEducation,
          competenciesNames: _competenciesNames,
          myCustomCompetencies: _myCustomCompetencies,
          mySelectedCompetencies: _mySelectedCompetencies,
          myCustomDataOfInterest: _myCustomDataOfInterest,
          mySelectedDataOfInterest: _mySelectedDataOfInterest,
          myCustomLanguages: _myCustomLanguages,
          mySelectedLanguages: _mySelectedLanguages,
          myCustomCity: _myCustomCity,
          myCustomProvince: _myCustomProvince,
          myCustomCountry: _myCustomCountry,
          myReferences: _myCustomReferences,
          myCustomReferences: _myCustomReferences,
          mySelectedReferences: _mySelectedReferences,
          myMaxEducation: _maxEducation,
          onBack: () {
            ParticipantCurriculumPage.selectedStep.value = 0;
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
