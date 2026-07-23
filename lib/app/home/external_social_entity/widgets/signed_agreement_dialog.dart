import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../../../common_widgets/alert_dialog.dart';
import '../../../common_widgets/custom_date_picker_open.dart';
import '../../../common_widgets/custom_text.dart';
import '../../../services/database.dart';
import '../../../utils/functions.dart';
import '../../../utils/responsive.dart';
import '../../../values/values.dart';

class SignedAgreementResult {
  final bool isDeleted;
  final Uint8List? fileBytes;
  final String? fileName;
  final DateTime? renovationDate;

  SignedAgreementResult({
    this.isDeleted = false,
    this.fileBytes,
    this.fileName,
    this.renovationDate,
  });
}

class SignedAgreementDialog extends StatefulWidget {
  const SignedAgreementDialog({
    Key? key,
    this.currentUrl,
    this.currentDate,
    this.contactId,
  }) : super(key: key);

  final String? currentUrl;
  final DateTime? currentDate;
  final String? contactId;

  static Future<SignedAgreementResult?> show({
    required BuildContext context,
    String? currentUrl,
    DateTime? currentDate,
    String? contactId,
  }) {
    return showDialog<SignedAgreementResult>(
      context: context,
      builder: (context) => SignedAgreementDialog(
        currentUrl: currentUrl,
        currentDate: currentDate,
        contactId: contactId,
      ),
    );
  }

  @override
  State<SignedAgreementDialog> createState() => _SignedAgreementDialogState();
}

class _SignedAgreementDialogState extends State<SignedAgreementDialog> {
  DateTime? _renovationDate;
  Uint8List? _pickedFileBytes;
  String? _pickedFileName;
  String? _existingUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _existingUrl = widget.currentUrl;
    _renovationDate = widget.currentDate;
  }

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      Uint8List? bytes = file.bytes;
      if (bytes == null && file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      }
      if (bytes != null) {
        setState(() {
          _pickedFileBytes = bytes;
          _pickedFileName = file.name;
        });
      }
    }
  }

  Future<void> _deleteAgreement() async {
    final confirm = await showAlertDialog(
      context,
      title: 'Borrar acuerdo firmado',
      content: '¿Estás seguro de que deseas borrar este acuerdo firmado?',
      cancelActionText: 'Cancelar',
      defaultActionText: 'Borrar',
    );

    if (confirm == true) {
      if (widget.contactId != null && widget.contactId!.isNotEmpty) {
        setState(() => _isLoading = true);
        try {
          final database = Provider.of<Database>(context, listen: false);
          await database.deleteSignedAgreement(widget.contactId!);
        } catch (_) {}
        setState(() => _isLoading = false);
      }
      Navigator.of(context).pop(SignedAgreementResult(isDeleted: true));
    }
  }

  void _save() {
    if (_renovationDate == null) {
      showAlertDialog(
        context,
        title: 'Fecha requerida',
        content: 'Por favor, selecciona una fecha de renovación.',
        defaultActionText: 'Aceptar',
      );
      return;
    }

    if (_pickedFileBytes == null && (_existingUrl == null || _existingUrl!.isEmpty)) {
      showAlertDialog(
        context,
        title: 'Archivo PDF requerido',
        content: 'Por favor, adjunta un archivo PDF del acuerdo firmado.',
        defaultActionText: 'Aceptar',
      );
      return;
    }

    Navigator.of(context).pop(
      SignedAgreementResult(
        isDeleted: false,
        fileBytes: _pickedFileBytes,
        fileName: _pickedFileName,
        renovationDate: _renovationDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasExistingFile = _existingUrl != null && _existingUrl!.isNotEmpty;
    final hasNewFile = _pickedFileBytes != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Column(
        children: [
          CustomTextBoldCenter(
            title: 'Acuerdo firmado',
            color: AppColors.primary900,
          ),
          const SizedBox(height: 4),
          Text(
            'Adjunta la fecha de renovación y el documento PDF',
            style: textTheme.bodySmall?.copyWith(color: AppColors.greyDark),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: _isLoading
          ? const SizedBox(
              height: 200,
              width: 400,
              child: Center(child: CircularProgressIndicator()),
            )
          : SizedBox(
              width: Responsive.isMobile(context) ? MediaQuery.of(context).size.width * 0.9 : 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  CustomDatePickerTitleOpen(
                    labelText: 'Fecha de renovación',
                    initialValue: _renovationDate,
                    onChanged: (value) {
                      setState(() {
                        _renovationDate = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Documento PDF',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.greyDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (hasNewFile) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.greyUltraLight.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primaryColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.picture_as_pdf, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _pickedFileName ?? 'Nuevo_acuerdo.pdf',
                              style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: AppColors.turquoiseBlue),
                            tooltip: 'Cambiar archivo',
                            onPressed: _pickPDF,
                          ),
                        ],
                      ),
                    ),
                  ] else if (hasExistingFile) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.greyUltraLight.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.greyUltraLight),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.picture_as_pdf, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Acuerdo_firmado.pdf',
                                  style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Documento almacenado',
                                  style: textTheme.bodySmall?.copyWith(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.download, color: AppColors.turquoiseBlue),
                            tooltip: 'Descargar PDF',
                            onPressed: () => launchURL(_existingUrl!),
                          ),
                          IconButton(
                            icon: const Icon(Icons.upload_file, color: AppColors.turquoiseBlue),
                            tooltip: 'Reemplazar PDF',
                            onPressed: _pickPDF,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    OutlinedButton.icon(
                      onPressed: _pickPDF,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        side: const BorderSide(color: AppColors.turquoiseBlue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.upload_file, color: AppColors.turquoiseBlue),
                      label: const Text(
                        'Seleccionar archivo PDF',
                        style: TextStyle(color: AppColors.turquoiseBlue),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (hasExistingFile || hasNewFile)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _deleteAgreement,
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        label: const Text(
                          'Borrar acuerdo firmado',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                ],
              ),
            ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0, right: 12.0, left: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
                onPressed: _save,
                child: const Text('Guardar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
