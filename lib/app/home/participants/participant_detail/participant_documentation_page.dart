import 'dart:io';
import 'dart:ui_web';

import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/models/personalDocument.dart';
import 'package:enreda_empresas/app/models/personalDocumentType.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/functions.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'package:path/path.dart' as p;
import 'package:pdf/widgets.dart' as pw;

class ParticipantDocumentationPage extends StatefulWidget {
  ParticipantDocumentationPage({required this.participantUser, super.key});

  final UserEnreda participantUser;

  @override
  State<ParticipantDocumentationPage> createState() => _ParticipantDocumentationPageState();
}

class _ParticipantDocumentationPageState extends State<ParticipantDocumentationPage> {
  List<PersonalDocument> _userDocuments = [];

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    late int documentsCount = 0;

    return StreamBuilder<UserEnreda>(
        stream: database.userEnredaStreamByUserId(widget.participantUser.userId),
        builder: (context, snapshot) {
            if(snapshot.hasData){
              _userDocuments = snapshot.data!.personalDocuments;
            }
            return StreamBuilder<List<PersonalDocumentType>>(
                stream: database.personalDocumentTypeStream(),
                builder: (context, snapshot) {
                  if(snapshot.hasData){

                    snapshot.data!.forEach((element) {
                      bool containsDocument = false;
                      _userDocuments.forEach((item) {
                        if(item.name == element.title){
                          containsDocument = true;
                        }
                      });
                      if(!containsDocument){
                        _userDocuments.add(PersonalDocument(name: element.title, order: snapshot.data!.indexOf(element), document: ''));
                      }

                    });
                    _userDocuments.sort((a, b) {
                      return a.order.compareTo(b.order);
                    },);

                    documentsCount = _userDocuments.length;

                  }
                  return Padding(
                      padding: EdgeInsets.symmetric(horizontal: Responsive.isDesktop(context)? 50.0: 20.0, vertical: 30),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: AppColors.greyBorder)
                        ),
                        child:
                        Column(
                            children: [
                              if (Responsive.isDesktop(context) && !Responsive.isDesktopS(context))
                                _buildHeaderDesktop(() => _showSaveDialog(documentsCount++)),
                              if (!Responsive.isDesktop(context) || Responsive.isDesktopS(context))
                                _buildHeaderMobile(() => _showSaveDialog(documentsCount++)),
                              Divider(
                                color: AppColors.greyBorder,
                                height: 0,
                              ),
                              Column(
                                  children: [
                                    for( var document in _userDocuments)
                                      _documentTile(context, document, widget.participantUser),
                                  ]
                              )
                            ]
                        ),
                      )
                  );
                }
            );
          }
      );
  }

  Widget _buildHeaderDesktop(VoidCallback onTap) {
    return Padding(
        padding: EdgeInsets.only(left: 50.0, top: 15.0, bottom: 15.0, right: 20.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextBoldTitle(title: StringConst.PERSONAL_DOCUMENTATION.toUpperCase()),
              Row(
                  children: [
                    InkWell(
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_circle_outlined,
                              color: AppColors.turquoiseBlue,
                              size: 24,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                StringConst.ADD_DOCUMENTS,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: GoogleFonts.outfit().fontFamily,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: onTap,
                    )
                  ]
              ),
            ]
        )
    );
  }

  Widget _buildHeaderMobile(VoidCallback onTap) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextBoldTitle(title: StringConst.PERSONAL_DOCUMENTATION.toUpperCase()),
              SpaceH8(),
              InkWell(
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle_outlined,
                      color: AppColors.turquoiseBlue,
                      size: 24,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        StringConst.ADD_DOCUMENTS,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: GoogleFonts.outfit().fontFamily,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: onTap,
              ),
            ]
        )
    );
  }

  Widget _documentTile(BuildContext context, PersonalDocument document, UserEnreda user){
    bool paridad  = _userDocuments.indexOf(document) % 2 == 0;
    final database = Provider.of<Database>(context, listen: false);

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: paridad ? AppColors.greySearch : AppColors.white,
        borderRadius: _userDocuments.indexOf(document) == _userDocuments.length-1 ?
        BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)) :
        BorderRadius.all(Radius.circular(0)),
        //border: Border.all(color: AppColors.greyBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: Responsive.isDesktop(context)? 50.0: 16.0),
              child: Text(
                document.name,
                style: TextStyle(
                  fontFamily: GoogleFonts.inter().fontFamily,
                  fontWeight: FontWeight.w500,
                  fontSize: Responsive.isDesktop(context)? 16:12,
                  color: AppColors.chatDarkGray,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: document.document != '' ? Row(
              children: [
                IconButton(
                  icon: Image.asset(
                    ImagePath.PERSONAL_DOCUMENTATION_DELETE,
                    width: 20,
                    height: 20,
                  ),
                  onPressed: (){
                    setPersonalDocument(context: context, document: PersonalDocument(name: document.name, order: -1, document: ''), user: user);
                    setState(() {

                    });
                  },
                ),
                SpaceW8(),
                IconButton(
                  icon: Image.asset(
                    ImagePath.PERSONAL_DOCUMENTATION_VIEW,
                    width: 20,
                    height: 20,
                  ),
                  onPressed: () async {
                    var data = await http.get(Uri.parse(document.document));
                    var pdfData = data.bodyBytes;
                    var extension = p.extension(document.document).substring(0,4);
                    print(extension);
                    if(extension != '.pdf'){
                      _printNotPDF(document.document);
                    }
                    else {
                      await Printing.layoutPdf(
                          onLayout: (PdfPageFormat format) async => pdfData);
                    }
                  },
                ),
                SpaceW8(),
                IconButton(
                  icon: Image.asset(
                    ImagePath.PERSONAL_DOCUMENTATION_DOWNLOAD,
                    width: 20,
                    height: 20,
                  ),
                  onPressed: () async {
                    final ref = FirebaseStorage.instance.refFromURL(document.document);
                    if(kIsWeb){
                      html.AnchorElement anchorElement = html.AnchorElement(href: document.document);
                      anchorElement.download = document.name;
                      anchorElement.click();
                    }else{
                      final dir = await getApplicationDocumentsDirectory();
                      final file = File('${dir.path}/${ref.name}');
                      await ref.writeToFile(file);
                    }
                  },
                ),
              ],
            ) :
            IconButton(
              icon: Image.asset(
                ImagePath.PERSONAL_DOCUMENTATION_ADD,
                width: 20,
                height: 20,
              ),
              onPressed: () async {
                PlatformFile? pickedFile;

                var result;
                if(kIsWeb){
                  result = await FilePickerWeb.platform.pickFiles();
                }else{
                  result = await FilePicker.platform.pickFiles();
                }
                if(result == null) return;
                pickedFile = result.files.first;
                Uint8List fileBytes = pickedFile!.bytes!;
                String fileName = pickedFile.name;

                await database.uploadPersonalDocument(
                  user,
                  fileBytes,
                  fileName,
                  document,
                  user.personalDocuments.indexOf(document),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Future<void> _printNotPDF(String path) async{
    final doc = pw.Document();
    final netImage = await networkImage(path);
    doc.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Image(netImage),
        );

      })
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }

  Future<void> _showSaveDialog(int order) async{
    showDialog(
        context: context,
        builder: (context){
          TextEditingController newDocument = TextEditingController();
          GlobalKey<FormState> addDocumentKey = GlobalKey<FormState>();
          return AlertDialog(
            title: Text(StringConst.SET_DOCUMENT_NAME),
            content: Form(
              key: addDocumentKey,
              child: TextFormField(
                controller: newDocument,
                validator: (value){
                  bool used = false;
                  if(value!.isEmpty) return StringConst.FORM_GENERIC_ERROR;
                  _userDocuments.forEach((element) {
                    if(element.name.toUpperCase() == value.toUpperCase()){
                      used = true;
                    }
                  });
                  return used ? StringConst.NAME_IN_USE : null;
                }
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                  onPressed: () => Navigator.of(context).pop((false)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(StringConst.CANCEL,
                        style: TextStyle(
                            color: AppColors.black,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                            fontSize: 14)),
                  )),
              ElevatedButton(
                  onPressed: (){
                    if(addDocumentKey.currentState!.validate()){
                      setPersonalDocument(
                          context: context,
                          document: PersonalDocument(name: newDocument.text, order: order, document: ''),
                          user: widget.participantUser);
                      Navigator.of(context).pop((true));
                    }},
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(StringConst.ADD,
                        style: TextStyle(
                            color: AppColors.black,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                            fontSize: 14)),
                  )),
            ],
          );
        }
    );
  }
}
