import 'package:enreda_empresas/app/models/certificationRequest.dart';
import 'package:enreda_empresas/app/models/experience.dart';
import 'package:enreda_empresas/app/models/language.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:enreda_empresas/app/home/participants/pdf_generator/cv_print/my_cv_multiple_pages.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Paso 1 del flujo de Currículum: el técnico elige qué datos incluir en el PDF.
/// - Selección de foto, email, teléfono, localización, nivel educativo, resumen.
/// - Checkbox por experiencia/formación individual.
/// - "Volver" llama [onBack] para volver al Paso 0.
/// - "Siguiente >" hace Navigator.push a [MyCvMultiplePages] (página completa).
class ParticipantCvModelsPage extends StatefulWidget {
  const ParticipantCvModelsPage({
    Key? key,
    required this.user,
    required this.city,
    required this.province,
    required this.country,
    required this.myCustomAboutMe,
    required this.myCustomEmail,
    required this.myCustomPhone,
    required this.myExperiences,
    required this.myCustomExperiences,
    required this.mySelectedExperiences,
    required this.myPersonalExperiences,
    required this.myPersonalCustomExperiences,
    required this.myPersonalSelectedExperiences,
    required this.myEducation,
    required this.myCustomEducation,
    required this.mySelectedEducation,
    required this.mySecondaryEducation,
    required this.mySecondaryCustomEducation,
    required this.mySecondarySelectedEducation,
    required this.competenciesNames,
    required this.myCustomCompetencies,
    required this.mySelectedCompetencies,
    required this.myCustomDataOfInterest,
    required this.mySelectedDataOfInterest,
    required this.myCustomLanguages,
    required this.mySelectedLanguages,
    required this.myCustomCity,
    required this.myCustomProvince,
    required this.myCustomCountry,
    required this.myReferences,
    required this.myCustomReferences,
    required this.mySelectedReferences,
    required this.myMaxEducation,
    this.onBack,
  }) : super(key: key);

  final VoidCallback? onBack;
  final UserEnreda? user;
  final String? city;
  final String? province;
  final String? country;
  final String myCustomCity;
  final String myCustomProvince;
  final String myCustomCountry;
  final String myCustomAboutMe;
  final String myCustomEmail;
  final String myCustomPhone;
  final String myMaxEducation;
  final List<Experience>? myExperiences;
  final List<Experience> myCustomExperiences;
  final List<int> mySelectedExperiences;
  final List<Experience>? myPersonalExperiences;
  final List<Experience> myPersonalCustomExperiences;
  final List<int> myPersonalSelectedExperiences;
  final List<Experience>? myEducation;
  final List<Experience> myCustomEducation;
  final List<int> mySelectedEducation;
  final List<Experience>? mySecondaryEducation;
  final List<Experience> mySecondaryCustomEducation;
  final List<int> mySecondarySelectedEducation;
  final List<String> competenciesNames;
  final List<String> myCustomCompetencies;
  final List<int> mySelectedCompetencies;
  final List<String> myCustomDataOfInterest;
  final List<int> mySelectedDataOfInterest;
  final List<Language> myCustomLanguages;
  final List<int> mySelectedLanguages;
  final List<CertificationRequest>? myReferences;
  final List<CertificationRequest> myCustomReferences;
  final List<int> mySelectedReferences;

  @override
  State<ParticipantCvModelsPage> createState() => _ParticipantCvModelsPageState();
}

class _ParticipantCvModelsPageState extends State<ParticipantCvModelsPage> {
  // ── Section toggles ──────────────────────────────────────────────────────
  bool _isSelectedAboutMe = true;
  bool _isSelectedEmail = true;
  bool _isSelectedPhone = true;
  bool _isSelectedMyCity = true;
  bool _isSelectedMyProvince = true;
  bool _isSelectedMyCountry = true;
  bool _isSelectedPhoto = true;
  bool _isSelectedMaxEducation = true;
  String _myMaxEducation = '';

  // Mutable copies of the selection state (managed locally so we can toggle)
  late List<Experience> _customExperiences;
  late List<int> _selectedExperiences;
  late List<Experience> _personalCustomExperiences;
  late List<int> _personalSelectedExperiences;
  late List<Experience> _customEducation;
  late List<int> _selectedEducation;
  late List<Experience> _secondaryCustomEducation;
  late List<int> _secondarySelectedEducation;
  late List<String> _customCompetencies;
  late List<int> _selectedCompetencies;
  late List<String> _customDataOfInterest;
  late List<int> _selectedDataOfInterest;
  late List<Language> _customLanguages;
  late List<int> _selectedLanguages;
  late List<CertificationRequest> _customReferences;
  late List<int> _selectedReferences;
  late String _customAboutMe;
  late String _customEmail;
  late String _customPhone;
  late String _customCity;
  late String _customProvince;
  late String _customCountry;

  // ── ID-based selection for the PDF builder ───────────────────────────────
  List<String> _idSelectedDateEducation = [];
  List<String> _idSelectedDateSecondaryEducation = [];
  List<String> _idSelectedDateExperience = [];
  List<String> _idSelectedDatePersonalExperience = [];

  static const Color _teal = Color(0xFF005B5B);

  @override
  void initState() {
    super.initState();
    _myMaxEducation = widget.myMaxEducation;
    _customAboutMe = widget.myCustomAboutMe;
    _customEmail = widget.myCustomEmail;
    _customPhone = widget.myCustomPhone;
    _customCity = widget.myCustomCity;
    _customProvince = widget.myCustomProvince;
    _customCountry = widget.myCustomCountry;

    _customExperiences = List.from(widget.myCustomExperiences);
    _selectedExperiences = List.from(widget.mySelectedExperiences);
    _personalCustomExperiences = List.from(widget.myPersonalCustomExperiences);
    _personalSelectedExperiences = List.from(widget.myPersonalSelectedExperiences);
    _customEducation = List.from(widget.myCustomEducation);
    _selectedEducation = List.from(widget.mySelectedEducation);
    _secondaryCustomEducation = List.from(widget.mySecondaryCustomEducation);
    _secondarySelectedEducation = List.from(widget.mySecondarySelectedEducation);
    _customCompetencies = List.from(widget.myCustomCompetencies);
    _selectedCompetencies = List.from(widget.mySelectedCompetencies);
    _customDataOfInterest = List.from(widget.myCustomDataOfInterest);
    _selectedDataOfInterest = List.from(widget.mySelectedDataOfInterest);
    _customLanguages = List.from(widget.myCustomLanguages);
    _selectedLanguages = List.from(widget.mySelectedLanguages);
    _customReferences = List.from(widget.myCustomReferences);
    _selectedReferences = List.from(widget.mySelectedReferences);

    // Populate ID lists from initial selections
    for (final i in _selectedEducation) {
      final id = widget.myEducation?.elementAt(i).id;
      if (id != null) _idSelectedDateEducation.add(id);
    }
    for (final i in _secondarySelectedEducation) {
      final id = widget.mySecondaryEducation?.elementAt(i).id;
      if (id != null) _idSelectedDateSecondaryEducation.add(id);
    }
    for (final i in _selectedExperiences) {
      final id = widget.myExperiences?.elementAt(i).id;
      if (id != null) _idSelectedDateExperience.add(id);
    }
    for (final i in _personalSelectedExperiences) {
      final id = widget.myPersonalExperiences?.elementAt(i).id;
      if (id != null) _idSelectedDatePersonalExperience.add(id);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Responsive.isDesktop(context)
        ? _buildWeb(context)
        : _buildMobile(context);
  }

  // ── ACTION BUTTONS ────────────────────────────────────────────────────────

  Widget _buildBackButton() => OutlinedButton.icon(
        onPressed: widget.onBack,
        icon: const Icon(Icons.arrow_back_ios, size: 16, color: AppColors.primary900),
        label: Text(
          'Volver atrás',
          style: TextStyle(
            color: AppColors.primary900,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary900),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      );

  Widget _buildNextButton() => ElevatedButton(
        onPressed: _navigateToPreview,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary900,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        ),
        child: const Text('Siguiente >', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );

  void _navigateToPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MyCvMultiplePages(
          user: widget.user!,
          myPhoto: _isSelectedPhoto,
          city: _customCity,
          province: _customProvince,
          country: _customCountry,
          myExperiences: _customExperiences,
          myPersonalExperiences: _personalCustomExperiences,
          myEducation: _customEducation,
          mySecondaryEducation: _secondaryCustomEducation,
          idSelectedDateEducation: _idSelectedDateEducation,
          idSelectedDateSecondaryEducation: _idSelectedDateSecondaryEducation,
          idSelectedDateExperience: _idSelectedDateExperience,
          idSelectedDatePersonalExperience: _idSelectedDatePersonalExperience,
          competenciesNames: _customCompetencies,
          aboutMe: _customAboutMe,
          languagesNames: _customLanguages,
          myDataOfInterest: _customDataOfInterest,
          myCustomEmail: _customEmail,
          myCustomPhone: _customPhone,
          myCustomReferences: _customReferences,
          myMaxEducation: _myMaxEducation,
        ),
      ),
    );
  }

  // ── WEB LAYOUT ────────────────────────────────────────────────────────────

  Widget _buildWeb(BuildContext context) {
    var profilePic = widget.user?.profilePic?.src ?? '';

    return SingleChildScrollView(
      controller: ScrollController(),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Previsualización del Currículum',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Elige qué información mostrar en el currículum.',
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildBackButton(),
                    const SizedBox(width: 16),
                    _buildNextButton(),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Body: name + photo toggle
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.greyBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.user?.firstName?.toUpperCase() ?? ''}',
                              style: GoogleFonts.outfit(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: _teal,
                                height: 0.9,
                              ),
                            ),
                            Text(
                              '${widget.user?.lastName?.toUpperCase() ?? ''}',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.normal,
                                color: _teal,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildAboutMeToggle(context),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Photo toggle
                      GestureDetector(
                        onTap: () => setState(() => _isSelectedPhoto = !_isSelectedPhoto),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: _teal, width: 2),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: profilePic.isEmpty
                                    ? AssetImage(ImagePath.USER_DEFAULT) as ImageProvider
                                    : NetworkImage(profilePic),
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: Icon(
                                _isSelectedPhoto ? Icons.check_circle : Icons.radio_button_unchecked,
                                color: _teal,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 40, thickness: 1, color: Color(0xFFE0E0E0)),
                  // Two-column body
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.22,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPersonalDataToggles(context),
                            const Divider(height: 32, thickness: 1, color: Color(0xFFE0E0E0)),
                            if (widget.myMaxEducation.isNotEmpty) ...[
                              _buildMaxEducationToggle(context),
                              const Divider(height: 32, thickness: 1, color: Color(0xFFE0E0E0)),
                            ],
                            _buildCompetenciesToggle(context),
                            const Divider(height: 32, thickness: 1, color: Color(0xFFE0E0E0)),
                            _buildDataOfInterestToggle(context),
                            const Divider(height: 32, thickness: 1, color: Color(0xFFE0E0E0)),
                            _buildLanguagesToggle(context),
                            const Divider(height: 32, thickness: 1, color: Color(0xFFE0E0E0)),
                            _buildReferencesToggle(context),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      // Right column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildExperienceList(context),
                            const Divider(height: 32, thickness: 1, color: Color(0xFFE0E0E0)),
                            _buildPersonalExperienceList(context),
                            const Divider(height: 32, thickness: 1, color: Color(0xFFE0E0E0)),
                            _buildEducationList(context),
                            const Divider(height: 32, thickness: 1, color: Color(0xFFE0E0E0)),
                            _buildSecondaryEducationList(context),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── MOBILE LAYOUT ─────────────────────────────────────────────────────────

  Widget _buildMobile(BuildContext context) {
    var profilePic = widget.user?.profilePic?.src ?? '';
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBackButton(),
                _buildNextButton(),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Icon(Icons.info_outline, size: 18, color: AppColors.primary900),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Elige qué información mostrar en el currículum.',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1, color: Color(0xFFE0E0E0)),
            // Photo toggle
            GestureDetector(
              onTap: () => setState(() => _isSelectedPhoto = !_isSelectedPhoto),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _teal, width: 2),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: profilePic.isEmpty
                            ? AssetImage(ImagePath.USER_DEFAULT) as ImageProvider
                            : NetworkImage(profilePic),
                      ),
                    ),
                  ),
                  Icon(
                    _isSelectedPhoto ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: _teal,
                    size: 24,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${widget.user?.firstName} ${widget.user?.lastName}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: AppColors.primary900,
              ),
            ),
            const Divider(height: 32, thickness: 1, color: Color(0xFFE0E0E0)),
            _buildPersonalDataToggles(context),
            const Divider(height: 32, thickness: 1, color: Color(0xFFE0E0E0)),
            _buildAboutMeToggle(context),
            if (widget.myMaxEducation.isNotEmpty) ...[
              const Divider(height: 32, thickness: 1, color: Color(0xFFE0E0E0)),
              _buildMaxEducationToggle(context),
            ],
            const Divider(height: 32, thickness: 1, color: Color(0xFFE0E0E0)),
            _buildEducationList(context),
            const Divider(height: 32, thickness: 1, color: Color(0xFFE0E0E0)),
            _buildSecondaryEducationList(context),
            const Divider(height: 32, thickness: 1, color: Color(0xFFE0E0E0)),
            _buildExperienceList(context),
            const Divider(height: 32, thickness: 1, color: Color(0xFFE0E0E0)),
            _buildPersonalExperienceList(context),
            const Divider(height: 32, thickness: 1, color: Color(0xFFE0E0E0)),
            _buildCompetenciesToggle(context),
            const Divider(height: 32, thickness: 1, color: Color(0xFFE0E0E0)),
            _buildDataOfInterestToggle(context),
            const Divider(height: 32, thickness: 1, color: Color(0xFFE0E0E0)),
            _buildLanguagesToggle(context),
            const Divider(height: 32, thickness: 1, color: Color(0xFFE0E0E0)),
            _buildReferencesToggle(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── SECTION TOGGLES ───────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: _teal,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
            color: _teal,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutMeToggle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(StringConst.ABOUT_ME, _isSelectedAboutMe, () {
          setState(() {
            _isSelectedAboutMe = !_isSelectedAboutMe;
            _customAboutMe = _isSelectedAboutMe ? (widget.user?.aboutMe ?? '') : '';
          });
        }),
        const SizedBox(height: 8),
        Text(
          widget.user?.aboutMe?.isNotEmpty == true
              ? widget.user!.aboutMe!
              : 'Sin descripción personal',
          style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildPersonalDataToggles(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConst.PERSONAL_DATA.toUpperCase(),
          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: _teal),
        ),
        const SizedBox(height: 12),
        _buildRowToggle(
          icon: Icons.mail_outline,
          text: widget.user?.email ?? '',
          isSelected: _isSelectedEmail,
          onTap: () => setState(() {
            _isSelectedEmail = !_isSelectedEmail;
            _customEmail = _isSelectedEmail ? (widget.user?.email ?? '') : '';
          }),
        ),
        const SizedBox(height: 8),
        _buildRowToggle(
          icon: Icons.phone_outlined,
          text: widget.user?.phone ?? '',
          isSelected: _isSelectedPhone,
          onTap: () => setState(() {
            _isSelectedPhone = !_isSelectedPhone;
            _customPhone = _isSelectedPhone ? (widget.user?.phone ?? '') : '';
          }),
        ),
        const SizedBox(height: 8),
        _buildRowToggle(
          icon: Icons.location_on_outlined,
          text: [
            if ((widget.city ?? '').isNotEmpty) widget.city!,
            if ((widget.province ?? '').isNotEmpty) widget.province!,
            if ((widget.country ?? '').isNotEmpty) widget.country!,
          ].join(', '),
          isSelected: _isSelectedMyCity && _isSelectedMyProvince && _isSelectedMyCountry,
          onTap: () => setState(() {
            final target = !(_isSelectedMyCity && _isSelectedMyProvince && _isSelectedMyCountry);
            _isSelectedMyCity = target;
            _isSelectedMyProvince = target;
            _isSelectedMyCountry = target;
            _customCity = target ? (widget.city ?? '') : '';
            _customProvince = target ? (widget.province ?? '') : '';
            _customCountry = target ? (widget.country ?? '') : '';
          }),
        ),
      ],
    );
  }

  Widget _buildRowToggle({
    required IconData icon,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: _teal, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black54))),
          Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked, color: _teal, size: 18),
        ],
      ),
    );
  }

  Widget _buildMaxEducationToggle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('MÁXIMO NIVEL DE ESTUDIOS', _isSelectedMaxEducation, () {
          setState(() {
            _isSelectedMaxEducation = !_isSelectedMaxEducation;
            _myMaxEducation = _isSelectedMaxEducation ? widget.myMaxEducation : '';
          });
        }),
        const SizedBox(height: 8),
        Text(widget.myMaxEducation, style: const TextStyle(fontSize: 13, color: Colors.black54)),
      ],
    );
  }

  Widget _buildCompetenciesToggle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConst.COMPETENCIES.toUpperCase(),
          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: _teal),
        ),
        const SizedBox(height: 12),
        widget.competenciesNames.isEmpty
            ? const Text('Sin competencias evaluadas', style: TextStyle(fontSize: 13, color: Colors.black54))
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(widget.competenciesNames.length, (i) {
                  final selected = _selectedCompetencies.contains(i);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedCompetencies.remove(i);
                          _customCompetencies.remove(widget.competenciesNames[i]);
                        } else {
                          _selectedCompetencies.add(i);
                          _customCompetencies.add(widget.competenciesNames[i]);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _teal),
                        color: selected ? _teal.withOpacity(0.1) : Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.competenciesNames[i], style: TextStyle(fontSize: 12, color: _teal)),
                          if (selected) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.check, size: 12, color: _teal),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ),
      ],
    );
  }

  Widget _buildDataOfInterestToggle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DATOS DE INTERÉS',
          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: _teal),
        ),
        const SizedBox(height: 8),
        widget.myCustomDataOfInterest.isEmpty
            ? const Text('Sin datos adicionales', style: TextStyle(fontSize: 13, color: Colors.black54))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(widget.myCustomDataOfInterest.length, (i) {
                  final selected = _selectedDataOfInterest.contains(i);
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedDataOfInterest.remove(i);
                          _customDataOfInterest.remove(widget.myCustomDataOfInterest[i]);
                        } else {
                          _selectedDataOfInterest.add(i);
                          _customDataOfInterest.add(widget.myCustomDataOfInterest[i]);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(child: Text(widget.myCustomDataOfInterest[i], style: const TextStyle(fontSize: 13))),
                          Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked, color: _teal, size: 18),
                        ],
                      ),
                    ),
                  );
                }),
              ),
      ],
    );
  }

  Widget _buildLanguagesToggle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConst.LANGUAGES.toUpperCase(),
          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: _teal),
        ),
        const SizedBox(height: 8),
        widget.myCustomLanguages.isEmpty
            ? const Text('Sin idiomas añadidos', style: TextStyle(fontSize: 13, color: Colors.black54))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(widget.myCustomLanguages.length, (i) {
                  final selected = _selectedLanguages.contains(i);
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedLanguages.remove(i);
                          _customLanguages.remove(widget.myCustomLanguages[i]);
                        } else {
                          _selectedLanguages.add(i);
                          _customLanguages.add(widget.myCustomLanguages[i]);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(child: Text(widget.myCustomLanguages[i].name, style: const TextStyle(fontSize: 13))),
                          Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked, color: _teal, size: 18),
                        ],
                      ),
                    ),
                  );
                }),
              ),
      ],
    );
  }

  Widget _buildReferencesToggle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REFERENCIAS',
          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: _teal),
        ),
        const SizedBox(height: 8),
        widget.myCustomReferences.isEmpty
            ? const Text('Sin referencias', style: TextStyle(fontSize: 13, color: Colors.black54))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(widget.myCustomReferences.length, (i) {
                  final selected = _selectedReferences.contains(i);
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedReferences.remove(i);
                          _customReferences.remove(widget.myCustomReferences[i]);
                        } else {
                          _selectedReferences.add(i);
                          _customReferences.add(widget.myCustomReferences[i]);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(child: Text('${widget.myCustomReferences[i].certifierName}', style: const TextStyle(fontSize: 13))),
                          Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked, color: _teal, size: 18),
                        ],
                      ),
                    ),
                  );
                }),
              ),
      ],
    );
  }

  // ── EXPERIENCE / EDUCATION LISTS ─────────────────────────────────────────

  Widget _buildExperienceList(BuildContext context) {
    final formatter = DateFormat('yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConst.MY_PROFESIONAL_EXPERIENCES.toUpperCase(),
          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: _teal),
        ),
        const SizedBox(height: 12),
        widget.myExperiences?.isEmpty != false
            ? const Text('Sin experiencias profesionales', style: TextStyle(fontSize: 13, color: Colors.black54))
            : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.myExperiences!.length,
                itemBuilder: (ctx, i) {
                  final exp = widget.myExperiences![i];
                  final selected = _selectedExperiences.contains(i);
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedExperiences.remove(i);
                          if (exp.id != null) _idSelectedDateExperience.remove(exp.id!);
                          _customExperiences.removeWhere((e) => e.id == exp.id);
                        } else {
                          _selectedExperiences.add(i);
                          if (exp.id != null) _idSelectedDateExperience.add(exp.id!);
                          _customExperiences.add(exp);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16, right: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${exp.startDate != null ? formatter.format(exp.startDate!.toDate()) : '-'} / ${exp.endDate != null ? formatter.format(exp.endDate!.toDate()) : 'Actualmente'}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  exp.position?.isNotEmpty == true ? exp.position! : (exp.organization ?? ''),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87),
                                ),
                                if (exp.organization?.isNotEmpty == true)
                                  Text(exp.organization!, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                              ],
                            ),
                          ),
                          Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked, color: _teal, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildPersonalExperienceList(BuildContext context) {
    final formatter = DateFormat('yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConst.MY_PERSONAL_EXPERIENCES.toUpperCase(),
          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: _teal),
        ),
        const SizedBox(height: 12),
        widget.myPersonalExperiences?.isEmpty != false
            ? const Text('Sin experiencias personales', style: TextStyle(fontSize: 13, color: Colors.black54))
            : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.myPersonalExperiences!.length,
                itemBuilder: (ctx, i) {
                  final exp = widget.myPersonalExperiences![i];
                  final selected = _personalSelectedExperiences.contains(i);
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _personalSelectedExperiences.remove(i);
                          if (exp.id != null) _idSelectedDatePersonalExperience.remove(exp.id!);
                          _personalCustomExperiences.removeWhere((e) => e.id == exp.id);
                        } else {
                          _personalSelectedExperiences.add(i);
                          if (exp.id != null) _idSelectedDatePersonalExperience.add(exp.id!);
                          _personalCustomExperiences.add(exp);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16, right: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${exp.startDate != null ? formatter.format(exp.startDate!.toDate()) : '-'} / ${exp.endDate != null ? formatter.format(exp.endDate!.toDate()) : 'Actualmente'}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  exp.subtype ?? exp.activity ?? '',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked, color: _teal, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildEducationList(BuildContext context) {
    final formatter = DateFormat('yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConst.EDUCATION.toUpperCase(),
          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: _teal),
        ),
        const SizedBox(height: 12),
        widget.myEducation?.isEmpty != false
            ? const Text('Sin formación añadida', style: TextStyle(fontSize: 13, color: Colors.black54))
            : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.myEducation!.length,
                itemBuilder: (ctx, i) {
                  final edu = widget.myEducation![i];
                  final selected = _selectedEducation.contains(i);
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedEducation.remove(i);
                          if (edu.id != null) _idSelectedDateEducation.remove(edu.id!);
                          _customEducation.removeWhere((e) => e.id == edu.id);
                        } else {
                          _selectedEducation.add(i);
                          if (edu.id != null) _idSelectedDateEducation.add(edu.id!);
                          _customEducation.add(edu);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16, right: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${edu.startDate != null ? formatter.format(edu.startDate!.toDate()) : '-'} / ${edu.endDate != null ? formatter.format(edu.endDate!.toDate()) : 'Actualmente'}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(edu.nameFormation ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
                                if (edu.institution != null)
                                  Text(edu.institution!, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                              ],
                            ),
                          ),
                          Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked, color: _teal, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildSecondaryEducationList(BuildContext context) {
    final formatter = DateFormat('yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConst.SECONDARY_EDUCATION.toUpperCase(),
          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: _teal),
        ),
        const SizedBox(height: 12),
        widget.mySecondaryEducation?.isEmpty != false
            ? const Text('Sin formación complementaria', style: TextStyle(fontSize: 13, color: Colors.black54))
            : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.mySecondaryEducation!.length,
                itemBuilder: (ctx, i) {
                  final edu = widget.mySecondaryEducation![i];
                  final selected = _secondarySelectedEducation.contains(i);
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _secondarySelectedEducation.remove(i);
                          if (edu.id != null) _idSelectedDateSecondaryEducation.remove(edu.id!);
                          _secondaryCustomEducation.removeWhere((e) => e.id == edu.id);
                        } else {
                          _secondarySelectedEducation.add(i);
                          if (edu.id != null) _idSelectedDateSecondaryEducation.add(edu.id!);
                          _secondaryCustomEducation.add(edu);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16, right: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${edu.startDate != null ? formatter.format(edu.startDate!.toDate()) : '-'} / ${edu.endDate != null ? formatter.format(edu.endDate!.toDate()) : 'Actualmente'}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(edu.nameFormation ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
                                if (edu.institution != null)
                                  Text(edu.institution!, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                              ],
                            ),
                          ),
                          Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked, color: _teal, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }
}
