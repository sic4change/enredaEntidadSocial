import 'package:enreda_empresas/app/models/personalDocumentType.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/services/database.dart';

import '../../../../models/documentCategory.dart';
import '../../../../models/personalDocument.dart';
import '../../../../utils/functions.dart';
import '../../../../utils/responsive.dart';
import '../../../../values/strings.dart';
import '../../../../values/values.dart';

class DocumentCategoryTile extends StatelessWidget {
  const DocumentCategoryTile({
    Key? key,
    required this.documentCategory,
    required this.participantUser,
  }) : super(key: key);
  final DocumentCategory documentCategory;
  final UserEnreda participantUser;

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<List<PersonalDocumentType>>(
              stream: database.personalDocumentTypeByIdStream(documentCategory.documentCategoryId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Container();
                if (snapshot.hasData){
                  List<PersonalDocumentType> personalDocTypeByCategoryList =  snapshot.data!;
                  return ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: personalDocTypeByCategoryList.map((participantDocument) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: Responsive.isMobile(context) ? const EdgeInsets.symmetric(horizontal: 25.0, vertical: 0.0) :
                            const EdgeInsets.symmetric(horizontal: 50.0, vertical: 0.0),
                            child: InkWell(
                              onTap: (){
                                _showSaveDialog(context, participantUser, participantDocument);
                              },
                              child: Row(
                                children: [
                                  CustomTextSmall(text: participantDocument.title),
                                  Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      _showSaveDialog(context, participantUser, participantDocument);
                                    },
                                    icon: Icon(Icons.more_horiz), color: AppColors.greyTxtAlt, iconSize: 20,),
                                ],
                              ),
                            ),
                          ),
                          Divider(thickness: 1, color: AppColors.greyDropMenuBorder,),
                        ],
                      );
                    }).toList(),
                  );
                }
                return Container();
              }
          ),
        ],
      ),
    );
  }

  Future<void> _showSaveDialog(BuildContext context, UserEnreda participantUser, PersonalDocumentType participantDocument) async{
    showDialog(
        context: context,
        builder: (context){
          TextEditingController newDocument = TextEditingController();
          GlobalKey<FormState> addDocumentKey = GlobalKey<FormState>();
          return AlertDialog(
            title: CustomTextBoldCenter(title: StringConst.SET_DOCUMENT_NAME + '${participantDocument.title}', color: AppColors.primary900,),
            content: Form(
              key: addDocumentKey,
              child: TextFormField(
                  controller: newDocument,
                  validator: (value){
                    bool used = false;
                    if(value!.isEmpty) return StringConst.FORM_GENERIC_ERROR;
                    // _userDocuments.forEach((element) {
                    //   if(element.name.toUpperCase() == value.toUpperCase()){
                    //     used = true;
                    //   }
                    // });
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
                          document: PersonalDocument(name: newDocument.text, order: participantDocument.order, document: ''),
                          user: participantUser);
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