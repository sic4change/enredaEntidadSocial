import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../common_widgets/custom_drop_down_button_form_field_title.dart';
import '../../../../common_widgets/custom_text.dart';
import '../../../../common_widgets/custom_text_form_field_long.dart';
import '../../../../models/interest.dart';
import '../../../../services/database.dart';
import '../../../../services/location_cache.dart';
import '../../../../values/strings.dart';
import '../../../../values/values.dart';

/// Bloque de preguntas de seguimiento a las 4 semanas o a los 6 meses
/// tras la finalización del Informe Inicial.
class IpilFollowUpSection extends StatefulWidget {
  const IpilFollowUpSection({
    super.key,
    required this.isFourWeeks,
    required this.situation,
    required this.employmentTypeId,
    required this.satisfaction,
    required this.impact,
    required this.improvement,
    required this.onSituationChanged,
    required this.onEmploymentTypeChanged,
    required this.onSatisfactionChanged,
    required this.onImpactChanged,
    required this.onImprovementChanged,
  });

  final bool isFourWeeks;
  final String? situation;
  final String? employmentTypeId;
  final int? satisfaction;
  final int? impact;
  final String? improvement;

  final ValueChanged<String?> onSituationChanged;
  final ValueChanged<String?> onEmploymentTypeChanged;
  final ValueChanged<int?> onSatisfactionChanged;
  final ValueChanged<int?> onImpactChanged;
  final ValueChanged<String?> onImprovementChanged;

  @override
  State<IpilFollowUpSection> createState() => _IpilFollowUpSectionState();
}

class _IpilFollowUpSectionState extends State<IpilFollowUpSection> {
  Stream<List<Interest>>? _interestsStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_interestsStream == null && LocationCache.instance.interests.isEmpty) {
      final database = Provider.of<Database>(context, listen: false);
      _interestsStream = database.interestStream();
    }
  }

  @override
  Widget build(BuildContext context) {
    final situationOptions = widget.isFourWeeks
        ? StringConst.IPIL_FOUR_WEEKS_SITUATIONS
        : StringConst.IPIL_SIX_MONTHS_SITUATIONS;

    final isEmployment = widget.situation == StringConst.IPIL_SITUATION_EMPLOYMENT;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.primary010.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: AppColors.primary100, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título principal con la misma fuente que los apartados
          Row(
            children: [
              Expanded(
                child: CustomTextBold(
                  title: StringConst.IPIL_FOLLOW_UP_PENDING,
                  color: AppColors.primary900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary900,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.isFourWeeks
                      ? StringConst.IPIL_FOLLOW_UP_FOUR_WEEKS
                      : StringConst.IPIL_FOLLOW_UP_SIX_MONTHS,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pregunta 1: Situación actual
          CustomDropDownButtonFormFieldTittle(
            labelText: StringConst.IPIL_FOLLOW_UP_SITUATION,
            value: widget.situation,
            hintText: StringConst.IPIL_FOLLOW_UP_SELECT,
            source: situationOptions.map((opt) {
              return DropdownMenuItem<String>(
                value: opt,
                child: Text(opt, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (val) {
              widget.onSituationChanged(val);
            },
          ),

          // Si la opción es "Obtienen empleo", se abren Tipo de empleo y Satisfacción
          if (isEmployment) ...[
            const SizedBox(height: 16),
            _buildEmploymentTypeSelector(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: CustomTextBold(
                title: StringConst.IPIL_FOLLOW_UP_SATISFACTION,
                color: AppColors.primary900,
              ),
            ),
            _RatingNumberRow(
              count: 4,
              selectedValue: widget.satisfaction,
              onChanged: widget.onSatisfactionChanged,
            ),
          ],

          const SizedBox(height: 18),

          // Pregunta 2: Impacto percibido (1 a 6)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: CustomTextBold(
              title: StringConst.IPIL_FOLLOW_UP_IMPACT,
              color: AppColors.primary900,
            ),
          ),
          _RatingNumberRow(
            count: 6,
            selectedValue: widget.impact,
            onChanged: widget.onImpactChanged,
          ),

          const SizedBox(height: 18),

          // Pregunta 3: Cómo mejorar el acompañamiento (campo libre)
          CustomTextFormFieldLong(
            labelText: StringConst.IPIL_FOLLOW_UP_IMPROVEMENT,
            initialValue: widget.improvement,
            onSaved: (val) => widget.onImprovementChanged(val),
            onChanged: (val) => widget.onImprovementChanged(val),
          ),
        ],
      ),
    );
  }

  Widget _buildEmploymentTypeSelector() {
    List<Interest> interests = LocationCache.instance.interests;
    if (interests.isNotEmpty) {
      return _renderEmploymentTypeDropdown(interests);
    }

    return StreamBuilder<List<Interest>>(
      stream: _interestsStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          interests = snapshot.data!;
          LocationCache.instance.interests = interests;
        }
        return _renderEmploymentTypeDropdown(interests);
      },
    );
  }

  Widget _renderEmploymentTypeDropdown(List<Interest> interests) {
    String? currentValue = widget.employmentTypeId;
    final match = interests.where((e) => (e.interestId ?? e.name) == currentValue).firstOrNull;
    if (match == null && currentValue != null && currentValue.isNotEmpty) {
      currentValue = null;
    }

    return CustomDropDownButtonFormFieldTittle(
      labelText: StringConst.IPIL_FOLLOW_UP_EMPLOYMENT_TYPE,
      value: currentValue,
      hintText: StringConst.IPIL_FOLLOW_UP_SELECT,
      source: interests.map((e) {
        final id = e.interestId ?? e.name;
        return DropdownMenuItem<String>(
          value: id,
          child: Text(e.name, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: (val) {
        widget.onEmploymentTypeChanged(val);
      },
    );
  }
}

/// Selector horizontal de números del 1 al [count] con la estética de Enreda.
class _RatingNumberRow extends StatelessWidget {
  const _RatingNumberRow({
    required this.count,
    required this.selectedValue,
    required this.onChanged,
  });

  final int count;
  final int? selectedValue;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(count, (index) {
        final number = index + 1;
        final isSelected = selectedValue == number;

        return InkWell(
          borderRadius: BorderRadius.circular(8.0),
          onTap: () {
            onChanged(isSelected ? null : number);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary900 : Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: isSelected ? AppColors.primary900 : AppColors.greyBorder,
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: [
                if (!isSelected)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
              ],
            ),
            child: Text(
              '$number',
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primary900,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        );
      }),
    );
  }
}
