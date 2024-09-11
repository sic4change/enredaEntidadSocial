import 'package:enreda_empresas/app/common_widgets/alert_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/custom_raised_button.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/show_exception_alert_dialog.dart';
import 'package:enreda_empresas/app/home/participants/resource_chip.dart';
import 'package:enreda_empresas/app/models/resource.dart';
import 'package:enreda_empresas/app/models/resourceInvitation.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/adaptative.dart';

class ParticipantResourcesList extends StatefulWidget {
  const ParticipantResourcesList({super.key, required this.participant, required this.organizerId});

  final UserEnreda participant;
  final String organizerId;

  @override
  State<ParticipantResourcesList> createState() => _ParticipantResourcesListState();
}

class _ParticipantResourcesListState extends State<ParticipantResourcesList> {
   late List<Resource> resourcesList;
   late Resource resource;
   bool? certification = false;
   bool? _isSelected = false;
   bool? _buttonDisabled = false;
   bool isLoading = false;
   String? codeDialog;
   String? valueText;
   int? _selectedCertify;
   Color _buttonColor = AppColors.primaryColor;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20.0),
          const CustomTextSmall(text: 'Elegir el recurso que desea invitar:', color: AppColors.primary900),
          SizedBox(height: Sizes.mainPadding * 1.5),
          _buildContents(context),
          SizedBox(height: Sizes.mainPadding / 2),
          isLoading ? const Padding(
            padding: EdgeInsets.all(30.0),
            child: Center(child: CircularProgressIndicator()),
          ) :
          CustomButton(
              text: 'Invitar recurso',
              color: _buttonColor,
              onPressed: _buttonDisabled == false ? () async {
                if (_isSelected == true) {
                  final resourceInvitation = ResourceInvitation(
                    resourceId: resource.resourceId!,
                    resourceTitle: resource.title,
                    resourceDescription: '${resource.resourceCategoryName!} en ${resource.cityName!}, ${resource.provinceName!}, ${resource.countryName!}',
                    unemployedId: widget.participant.userId!,
                    unemployedName: '${widget.participant.firstName!} ${widget.participant.lastName}',
                    unemployedEmail: widget.participant.email,
                  );
                  try {
                    final database = Provider.of<Database>(context, listen: false);
                    setState(() => isLoading = true);
                    await database.addResourceInvitation(resourceInvitation);
                    setState(() {
                      isLoading = false;
                      _buttonColor = AppColors.grey350;
                      _buttonDisabled = true;
                    });
                    showAlertDialog(
                      context,
                      title: '¡Recurso: ${resourcesList[_selectedCertify!].title}',
                      content: '¡Ha sido enviada la invitación con éxito!',
                      defaultActionText: 'Aceptar',
                    );
                  } on FirebaseException catch (e) {
                    showExceptionAlertDialog(context,
                        title: 'Error al enviar la invitación, intenta de nuevo.', exception: e).then((value) => Navigator.pop(context));
                  }
                }
              } : null
          ),
        ],
      ),
    );
  }

  Widget _buildContents(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<List<Resource>>(
        stream: database.myResourcesStream(widget.organizerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Sin recursos'));
          } 
          resourcesList = snapshot.data!;
          return Wrap(
            direction: Axis.horizontal,
            spacing: 5.0,
            children: resourcesList.map((resource) =>
              ResourceChip(
                resource: resource,
                database: database,
                textTheme: Theme.of(context).textTheme,
                isSelected: _selectedCertify == resourcesList.indexOf(resource),
                onSelected: () {
                  setState(() {
                    _selectResource(resourcesList.indexOf(resource));
                    _isSelected = true;
                    this.resource = resource;
                    resource.setResourceCategoryName();
                  });
                },
              )
            ).toList(),
          );
        },
      );
  }


  void _selectResource(int choice) {
    setState(() {
      _selectedCertify = choice;
    });
  }

}
