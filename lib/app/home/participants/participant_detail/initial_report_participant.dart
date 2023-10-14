import 'package:enreda_empresas/app/common_widgets/custom_date_picker_title.dart';
import 'package:enreda_empresas/app/common_widgets/custom_drop_down_button_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/enreda_button.dart';
import 'package:enreda_empresas/app/common_widgets/flex_row_column.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/common_widgets/text_form_field.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/auth.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

Widget initialReport(BuildContext context, UserEnreda user){
  final database = Provider.of<Database>(context, listen: false);
  final auth = Provider.of<AuthBase>(context, listen: false);

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
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Informe inicial'.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.bluePetrol,
                      fontSize: 35,
                      fontFamily: GoogleFonts.outfit().fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: AppColors.greyBorder,),
            completeInitialForm(context),
          ]
        ),
    )
  );
}

Widget informSectionTitle(String title){
  return Padding(
    padding: const EdgeInsets.only(top: 30, bottom: 15),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        fontFamily: GoogleFonts.outfit().fontFamily,
        color: AppColors.penBlue,
      ),
    ),
  );
}

Widget informSubSectionTitle(String title){
  return Padding(
    padding: const EdgeInsets.only(top: 30, bottom: 15),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: GoogleFonts.outfit().fontFamily,
        color: AppColors.penBlue,
      ),
    ),
  );
}

Widget multiSelectionList(List<String> options){
  return Wrap(
    alignment: WrapAlignment.spaceEvenly,
    direction: Axis.horizontal,

    children: <Widget>[
      for(var option in options)
        SizedBox(
          width: 300, //TODO make responsive
          child: RadioListTile(
            title: Text(option),
            value: null,
            groupValue: null,
            onChanged: (Null? value) {  },
            dense: true,
          ),
        )
    ],
  );
}

Widget multiSelectionListTitle(BuildContext context, List<String> options, String title){
  final textTheme = Theme.of(context).textTheme;
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
                    onChanged: (Null? value) {  },
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

Widget completeInitialForm(BuildContext context){

  List<DropdownMenuItem<String>> _yesNoSelection = ['Si', 'No'].map<DropdownMenuItem<String>>((String value){
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList();

  List<DropdownMenuItem<String>> _subsidySelection = ['xxxxxx1', 'xxxxxx2', 'xxxxxx3', 'xxxxxx4', 'xxxxxx5', 'xxxxxx6'].map<DropdownMenuItem<String>>((String value){
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList();

  //Section 1
  String _orientation, _arriveDate, _receptionResources, _externalResources, _administrativeSituation;
  List<DropdownMenuItem<String>> _arriveTypeSelection = ['Segura', 'Insegura'].map<DropdownMenuItem<String>>((String value){
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList();

  //Section 2
  List<DropdownMenuItem<String>> _healthCardSelection = ['Si', 'No', 'Caducidad'].map<DropdownMenuItem<String>>((String value){
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList();

  //Subsection 2.2
  List<DropdownMenuItem<String>> _stateSelection = ['En trámite', 'Concedida'].map<DropdownMenuItem<String>>((String value){
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList();
  List<DropdownMenuItem<String>> _disabilityGradeSelection = ['1', '2', '3', '4', '5'].map<DropdownMenuItem<String>>((String value){
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList();

  //Subsection 2.3
  List<DropdownMenuItem<String>> _dependencyGradeSelection = ['1', '2', '3'].map<DropdownMenuItem<String>>((String value){
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList();

  //Section 4
  List<String> _optionsSectionFour = ['Habitabilidad', 'Luz', 'Gas', 'Hacinamiento', 'Accesibilidad', 'Agua corriente', 'Baño', 'Comodidad o ausencia de ella', 'Agua caliente', 'Mobiliario básico'];

  //Section 10
  List<DropdownMenuItem<String>> _digitalSkillsSelection = ['Bajo', 'Medio', 'Alto'].map<DropdownMenuItem<String>>((String value){
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList();

  //Section 12
  List<String> _optionsSectionTwelve = ['Barrera ideomática', 'Situación sinhogarismo', 'Colectivo LGTBI', 'Salud mental grave', 'Joven ex tutelado/a', 'Responsabilidades familiares',
    'Madre monomarental', 'Minoría étnica', 'Falta de red de apoyo', 'Violencia de Género', 'Adicciones', 'Rularidad'];

  //Section 13
  List<DropdownMenuItem<String>> _educationalLevelSelection = ['1er ciclo 2ria (Max CINE 0-2)', '2do ciclo 2ria (CINE 3) o postsecundaria (CINE 4)', 'Superior o 3ria (CINE 5 a 8)',].map<DropdownMenuItem<String>>((String value){
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList();

  List<DropdownMenuItem<String>> _laborSituationSelection = ['Ocupada', 'Desempleada de larga duración (12 meses o más)', 'Desempleada (menos de 12 meses)',].map<DropdownMenuItem<String>>((String value){
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList();


  return Padding(
    padding: const EdgeInsets.only(left: 50, right: 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SpaceH20(),
        CustomDropDownButtonFormFieldTittle(
          labelText: 'Subvención a la que el/la participante está imputado/a',
          source: _subsidySelection,
          onChanged: (value){

          },
          validator: (value) => value != null ? null : StringConst.FORM_GENERIC_ERROR,
        ),

        //Section 1
        informSectionTitle('1. Itinerario en España'),
        CustomTextFormFieldTitle(
          labelText: 'Orientaciones',
          onChanged: (value){
            _orientation = value;
          },
          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
        ),
        SpaceH12(),
        CustomFlexRowColumn(
            contentPadding: EdgeInsets.zero,
            separatorSize: 20,
            childLeft: CustomDatePickerTitle(
              labelText: 'Fecha de llegada a España',
            ),

            childRight: CustomTextFormFieldTitle(
              labelText: 'Recursos de Acogida',
              onChanged: (value){
                _orientation = value;
              },
              validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
            ),
        ),
        SpaceH12(),
        CustomFlexRowColumn(
            contentPadding: EdgeInsets.zero,
            separatorSize: 20,
            childLeft: CustomTextFormFieldTitle(
              labelText: 'Recursos externos de apoyo',
              onChanged: (value){
                _orientation = value;
              },
              validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
            ),

            childRight: CustomTextFormFieldTitle(
              labelText: 'Situación administrativa',
              hintText: 'Ley de asilo, arraigo, ex-menor tutelado...',
              onChanged: (value){
                _orientation = value;
              },
              validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
            ),
        ),

        //Section 2
        informSectionTitle('2. Situación Sanitaria'),
        CustomTextFormFieldTitle(
          labelText: 'Orientaciones',
          onChanged: (value){
            _orientation = value;
          },
          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
        ),
        SpaceH12(),
        CustomFlexRowColumn(
          contentPadding: EdgeInsets.zero,
          separatorSize: 20,
          childLeft: CustomDropDownButtonFormFieldTittle(
            labelText: 'Tarjeta sanitaria',
            source: _healthCardSelection,
            onChanged: (value){

            },
            validator: (value) => value != null ? null : StringConst.FORM_GENERIC_ERROR,
          ),
          childRight: CustomDatePickerTitle(
            labelText: 'Fecha de caducidad',
          ),
        ),
        SpaceH12(),
        CustomFlexRowColumn(
          contentPadding: EdgeInsets.zero,
          separatorSize: 20,
          childLeft: CustomTextFormFieldTitle(
            labelText: 'Enfermedad',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
          childRight: CustomTextFormFieldTitle(
            labelText: 'Medicación/Tratamiento',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
        ),

        //Subsection 2.1
        informSubSectionTitle('2.1 Salud mental'),
        CustomTextFormFieldTitle(
          labelText: 'Orientaciones',
          onChanged: (value){
            _orientation = value;
          },
          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
        ),
        SpaceH12(),
        CustomFlexRowColumn(
          contentPadding: EdgeInsets.zero,
          separatorSize: 20,
          childLeft: CustomTextFormFieldTitle(
            labelText: 'Sueño y descanso',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
          childRight: CustomDropDownButtonFormFieldTittle(
            labelText: 'Diagnóstico',
            source: _yesNoSelection,
            onChanged: (value){

            },
            validator: (value) => value != null ? null : StringConst.FORM_GENERIC_ERROR,
          ),
        ),
        SpaceH12(),
        CustomFlexRowColumn(
          contentPadding: EdgeInsets.zero,
          separatorSize: 20,
          childLeft: CustomTextFormFieldTitle(
            labelText: 'Tratamiento',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
          childRight: CustomTextFormFieldTitle(
            labelText: 'Seguimiento',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
        ),
        SpaceH12(),
        CustomDropDownButtonFormFieldTittle(
          labelText: 'Derivación interna al área psicosocial',
          source: _yesNoSelection,
          onChanged: (value){

          },
          validator: (value) => value != null ? null : StringConst.FORM_GENERIC_ERROR,
        ),

        //Subsection 2.2
        informSubSectionTitle('2.2 Discapacidad'),
        CustomTextFormFieldTitle(
          labelText: 'Orientaciones',
          onChanged: (value){
            _orientation = value;
          },
          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
        ),
        SpaceH12(),
        CustomFlexRowColumn(
          contentPadding: EdgeInsets.zero,
          separatorSize: 20,
          childLeft: CustomDropDownButtonFormFieldTittle(
            labelText: 'Estado',
            source: _stateSelection,
            onChanged: (value){

            },
            validator: (value) => value != null ? null : StringConst.FORM_GENERIC_ERROR,
          ),
          childRight: CustomTextFormFieldTitle(
            labelText: 'Profesional de referencia',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
        ),
        SpaceH12(),
        CustomDropDownButtonFormFieldTittle(
          labelText: 'Grado de discapacidad',
          source: _disabilityGradeSelection,
          onChanged: (value){

          },
          validator: (value) => value != null ? null : StringConst.FORM_GENERIC_ERROR,
        ),

        //Subsection 2.3
        informSubSectionTitle('2.3 Dependencia'),
        CustomTextFormFieldTitle(
          labelText: 'Orientaciones',
          onChanged: (value){
            _orientation = value;
          },
          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
        ),
        SpaceH12(),
        CustomFlexRowColumn(
          contentPadding: EdgeInsets.zero,
          separatorSize: 20,
          childLeft: CustomDropDownButtonFormFieldTittle(
            labelText: 'Estado',
            source: _stateSelection,
            onChanged: (value){

            },
            validator: (value) => value != null ? null : StringConst.FORM_GENERIC_ERROR,
          ),
          childRight: CustomTextFormFieldTitle(
            labelText: 'Profesional de referencia',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
        ),
        SpaceH12(),
        CustomFlexRowColumn(
          contentPadding: EdgeInsets.zero,
          separatorSize: 20,
          childLeft: CustomTextFormFieldTitle(
            labelText: 'Servicio de ayuda a domicilio',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
          childRight: CustomTextFormFieldTitle(
            labelText: 'Teleasistencia',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
        ),
        SpaceH12(),
        CustomDropDownButtonFormFieldTittle(
          labelText: 'Grado de dependencia',
          source: _dependencyGradeSelection,
          onChanged: (value){

          },
          validator: (value) => value != null ? null : StringConst.FORM_GENERIC_ERROR,
        ),

        //Subsection 2.4
        informSubSectionTitle('2.4 Adicciones'),
        CustomTextFormFieldTitle(
          labelText: 'Orientaciones',
          onChanged: (value){
            _orientation = value;
          },
          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
        ),
        SpaceH12(),
        CustomFlexRowColumn(
          contentPadding: EdgeInsets.zero,
          separatorSize: 20,
          childLeft: CustomTextFormFieldTitle(
            labelText: 'Derivación externa',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
          childRight: CustomTextFormFieldTitle(
            labelText: 'Nivel de consumo',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
        ),
        SpaceH12(),
        CustomTextFormFieldTitle(
          labelText: 'Tratamiento',
          onChanged: (value){
            _orientation = value;
          },
          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
        ),

        //Section 3
        informSectionTitle('3. Situación legal'),
        CustomTextFormFieldTitle(
          labelText: 'Orientaciones',
          onChanged: (value){
            _orientation = value;
          },
          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
        ),
        SpaceH12(),
        CustomFlexRowColumn(
          contentPadding: EdgeInsets.zero,
          separatorSize: 20,
          childLeft: CustomTextFormFieldTitle(
            labelText: 'Procesos legales abiertos',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
          childRight: CustomTextFormFieldTitle(
            labelText: 'Procesos legales cerrados',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
        ),
        SpaceH12(),
        CustomTextFormFieldTitle(
          labelText: 'Representación legal',
          hintText: 'De oficio, privada, datos de contacto',
          onChanged: (value){
            _orientation = value;
          },
          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
        ),

        //Section 4
        informSectionTitle('4. Situación alojativa'),
        CustomTextFormFieldTitle(
          labelText: 'Orientaciones',
          onChanged: (value){
            _orientation = value;
          },
          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
        ),
        SpaceH12(),
        CustomFlexRowColumn(
          contentPadding: EdgeInsets.zero,
          separatorSize: 20,
          childLeft: CustomTextFormFieldTitle(
            labelText: 'Tipo de tenencia',
            hintText: 'Alquiler, ocupación, compra, etc',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
          childRight: CustomTextFormFieldTitle(
            labelText: 'Ubicación',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
        ),
        SpaceH12(),
        CustomFlexRowColumn(
          contentPadding: EdgeInsets.zero,
          separatorSize: 20,
          childLeft: CustomTextFormFieldTitle(
            labelText: 'Unidad de convivencia',
            hintText: 'Parentesco y relación de convivencia',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
          childRight: CustomTextFormFieldTitle(
            labelText: 'Datos de contacto del centro y persona de referencia',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
        ),
        SpaceH12(),
        multiSelectionList(_optionsSectionFour),

        //Section 5
        informSectionTitle('5. Redes de apoyo'),
        CustomTextFormFieldTitle(
          labelText: 'Orientaciones',
          onChanged: (value){
            _orientation = value;
          },
          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
        ),
        SpaceH12(),
        CustomTextFormFieldTitle(
          labelText: 'Redes informales',
          hintText: 'Asociación vecinal, grupo de facebook, whatsap, etc',
          onChanged: (value){
            _orientation = value;
          },
          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
        ),

        //Section 6
        informSectionTitle('6. Situación social integral'),
        CustomTextFormFieldTitle(
          labelText: 'Orientaciones',
          onChanged: (value){
            _orientation = value;
          },
          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
        ),
        SpaceH12(),
        CustomTextFormFieldTitle(
          labelText: 'Conocimiento de la estructura social',
          hintText: 'Sistema sanitario, sistema educativo',
          onChanged: (value){
            _orientation = value;
          },
          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
        ),
        SpaceH12(),
        CustomFlexRowColumn(
          contentPadding: EdgeInsets.zero,
          separatorSize: 20,
          childLeft: CustomTextFormFieldTitle(
            labelText: 'Nivel de autonomía física y psicológica',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
          childRight: CustomTextFormFieldTitle(
            labelText: 'Habilidades sociales',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
        ),

        //Section 7
        informSectionTitle('7. Idiomas'),
        CustomTextFormFieldTitle(
          labelText: 'Orientaciones',
          onChanged: (value){
            _orientation = value;
          },
          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
        ),
        SpaceH12(),
        CustomFlexRowColumn(
          contentPadding: EdgeInsets.zero,
          separatorSize: 20,
          childLeft: CustomDropDownButtonFormFieldTittle(
            labelText: 'Idioma',
            source: _dependencyGradeSelection, //TODO libreria de idiomas ?
            onChanged: (value){

            },
            validator: (value) => value != null ? null : StringConst.FORM_GENERIC_ERROR,
          ),
          childRight: CustomTextFormFieldTitle(
            labelText: 'Reconocimiento / acreditación - nivel',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
        ),

        //Section 8
        informSectionTitle('8. Economía'),
        CustomTextFormFieldTitle(
          labelText: 'Orientaciones',
          onChanged: (value){
            _orientation = value;
          },
          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
        ),
        SpaceH12(),
        CustomFlexRowColumn(
          contentPadding: EdgeInsets.zero,
          separatorSize: 20,
          childLeft: CustomTextFormFieldTitle(
            labelText: 'Acogida a algún programa de ayuda económica',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
          childRight: CustomTextFormFieldTitle(
            labelText: 'Ayuda familiar',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
        ),
        SpaceH12(),
        CustomTextFormFieldTitle(
          labelText: 'Responsabilidades familiares',
          onChanged: (value){
            _orientation = value;
          },
          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
        ),

        //Section 9
        informSectionTitle('9. Servicios sociales'),
        CustomTextFormFieldTitle(
          labelText: 'Orientaciones',
          onChanged: (value){
            _orientation = value;
          },
          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
        ),
        SpaceH12(),
        CustomFlexRowColumn(
          contentPadding: EdgeInsets.zero,
          separatorSize: 20,
          childLeft: CustomTextFormFieldTitle(
            labelText: 'Acceso a Servicios Sociales',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
          childRight: CustomTextFormFieldTitle(
            labelText: 'Centro y TS de referencia',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
        ),
        SpaceH12(),
        CustomFlexRowColumn(
          contentPadding: EdgeInsets.zero,
          separatorSize: 20,
          childLeft: CustomTextFormFieldTitle(
            labelText: 'Beneficiario de subvención y/o programa de apoyo',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
          childRight: multiSelectionListTitle(context, ['Si', 'No'], 'Usuaria')
        ),
        SpaceH12(),
        multiSelectionListTitle(context, ['Si', 'No'], 'Certificado de Exclusión Social:'),

        //Section 10
        informSectionTitle('10. Tecnología'),
        CustomTextFormFieldTitle(
          labelText: 'Orientaciones',
          onChanged: (value){
            _orientation = value;
          },
          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
        ),
        SpaceH12(),
        CustomDropDownButtonFormFieldTittle(
          labelText: 'Nivel de competencias digitales',
          source: _digitalSkillsSelection,
          onChanged: (value){

          },
          validator: (value) => value != null ? null : StringConst.FORM_GENERIC_ERROR,
        ),

        //Section 11
        informSectionTitle('11. Objetivos de vida y laborales'),
        CustomTextFormFieldTitle(
          labelText: 'Orientaciones',
          onChanged: (value){
            _orientation = value;
          },
          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
        ),
        SpaceH12(),
        CustomFlexRowColumn(
            contentPadding: EdgeInsets.zero,
            separatorSize: 20,
            childLeft: CustomTextFormFieldTitle(
              labelText: 'Intereses en el mercado laboral',
              onChanged: (value){
                _orientation = value;
              },
              validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
            ),
            childRight: CustomTextFormFieldTitle(
              labelText: 'Expectativas laborales',
              onChanged: (value){
                _orientation = value;
              },
              validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
            ),
        ),

        //Section 12
        informSectionTitle('12. Situación de Vulnerabilidad'),
        CustomTextFormFieldTitle(
          labelText: 'Orientaciones',
          onChanged: (value){
            _orientation = value;
          },
          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
        ),
        SpaceH12(),
        multiSelectionList(_optionsSectionTwelve),

        //Section 13
        informSectionTitle('13. Itinerario formativo laboral'),
        CustomTextFormFieldTitle(
          labelText: 'Orientaciones',
          onChanged: (value){
            _orientation = value;
          },
          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
        ),
        SpaceH12(),
        CustomFlexRowColumn(
          contentPadding: EdgeInsets.zero,
          separatorSize: 20,
          childLeft: CustomDropDownButtonFormFieldTittle(
            labelText: 'Nivel educativo',
            source: _educationalLevelSelection,
            onChanged: (value){

            },
            validator: (value) => value != null ? null : StringConst.FORM_GENERIC_ERROR,
          ),
          childRight: CustomDropDownButtonFormFieldTittle(
            labelText: 'Situación laboral',
            source: _laborSituationSelection,
            onChanged: (value){

            },
            validator: (value) => value != null ? null : StringConst.FORM_GENERIC_ERROR,
          ),
        ),
        SpaceH12(),
        CustomTextFormFieldTitle(
          labelText: 'Recursos externos',
          onChanged: (value){
            _orientation = value;
          },
          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
        ),
        SpaceH12(),
        CustomTextFormFieldTitle(
          labelText: 'Valoración educativa',
          hintText: 'Autopercepción, ajuste de expectativas, intereses iniciales y evolución de los mismos, adquisición o reconocimiento de competencias...',
          onChanged: (value){
            _orientation = value;
          },
          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
        ),
        SpaceH12(),
        CustomTextFormFieldTitle(
          labelText: 'Itinerario Formativo',
          hintText: 'Nombre, tipo de formación. Fecha, duración, lugar de realización. Posibilidad de homologación en caso de migrantes.',
          onChanged: (value){
            _orientation = value;
          },
          validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
        ),
        SpaceH12(),
        CustomFlexRowColumn(
          contentPadding: EdgeInsets.zero,
          separatorSize: 20,
          childLeft: CustomTextFormFieldTitle(
            labelText: 'Inserción laboral',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
          childRight: CustomTextFormFieldTitle(
            labelText: 'Acompañamiento post laboral',
            onChanged: (value){
              _orientation = value;
            },
            validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
          ),
        ),
        SpaceH12(),
        CustomDropDownButtonFormFieldTittle(
          labelText: 'Mejora laboral',
          source: _yesNoSelection,
          onChanged: (value){

          },
          validator: (value) => value != null ? null : StringConst.FORM_GENERIC_ERROR,
        ),


        SpaceH40(),



      ],
    ),
  );
}