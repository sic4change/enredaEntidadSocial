import 'dart:html' as html;
import 'dart:io';
import 'dart:math';
import 'package:enreda_empresas/app/home/participants/participant_detail/participant_control_panel_page.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/participant_ipil_page.dart';
import 'package:http/http.dart' as http;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:enreda_empresas/app/common_widgets/add_yellow_button.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_form_field_long.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text_form_field_title.dart';
import 'package:enreda_empresas/app/common_widgets/gamification_item.dart';
import 'package:enreda_empresas/app/common_widgets/gamification_slider.dart';
import 'package:enreda_empresas/app/common_widgets/rounded_container.dart';
import 'package:enreda_empresas/app/common_widgets/show_custom_dialog.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/common_widgets/text_form_field.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/competency_tile.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/my_curriculum_page.dart';
import 'package:enreda_empresas/app/home/participants/pdf_generator/pdf_ipil_preview.dart';
import 'package:enreda_empresas/app/home/participants/resources_participants.dart';
import 'package:enreda_empresas/app/home/participants/show_invitation_diaglog.dart';
import 'package:enreda_empresas/app/models/ability.dart';
import 'package:enreda_empresas/app/models/city.dart';
import 'package:enreda_empresas/app/models/competency.dart';
import 'package:enreda_empresas/app/models/country.dart';
import 'package:enreda_empresas/app/models/education.dart';
import 'package:enreda_empresas/app/models/interest.dart';
import 'package:enreda_empresas/app/models/ipilEntry.dart';
import 'package:enreda_empresas/app/models/personalDocument.dart';
import 'package:enreda_empresas/app/models/personalDocumentType.dart';
import 'package:enreda_empresas/app/models/province.dart';
import 'package:enreda_empresas/app/models/resource.dart';
import 'package:enreda_empresas/app/models/specificinterest.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/auth.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/adaptative.dart';
import 'package:enreda_empresas/app/utils/my_custom_scroll_behavior.dart';
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
import 'package:enreda_empresas/app/home/resources/global.dart' as globals;

class ParticipantDetailPage extends StatefulWidget {
  const ParticipantDetailPage({super.key,});

  @override
  State<ParticipantDetailPage> createState() => _ParticipantDetailPageState();
}

class _ParticipantDetailPageState extends State<ParticipantDetailPage> {
  List<String> _menuOptions = ['Panel de control', 'Informes sociales', 'IPIL', 'Documentación personal', 'Cuestionarios'];
  Widget? _currentPage;
  String? _value;
  late UserEnreda participantUser, socialEntityUser;

  List<PersonalDocument> _userDocuments = [];
  String? techNameComplete;

  @override
  void initState() {
    _value = _menuOptions[0];
    participantUser = globals.currentParticipant!;
    socialEntityUser = globals.currentSocialEntityUser!;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    if (_currentPage == null) {
      _currentPage =  ParticipantControlPanelPage(participantUser: participantUser);
    }

    return Responsive.isDesktop(context)? _buildParticipantWeb(context, participantUser):
      _buildParticipantMobile(context, participantUser);
  }

  Widget _buildParticipantWeb(BuildContext context, UserEnreda user){
    return SingleChildScrollView(
      controller: ScrollController(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: _buildHeader(context, user),
            height: 220,
          ),
          Divider(
            indent: 0,
            endIndent: 0,
            color: AppColors.greyBorder,
            thickness: 1,
            height: 1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 22.0),
            child: _buildMenuSelectorChips(context, user),
          ),
          Divider(
            indent: 0,
            endIndent: 0,
            color: AppColors.greyBorder,
            thickness: 1,
            height: 0,
          ),
          SpaceH24(),

          _currentPage!,
        ],
      ),
    );
  }

  Widget _buildParticipantMobile(BuildContext context, UserEnreda? user) {
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(120),
                    ),
                    child:
                    !kIsWeb ? ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(60)),
                      child:
                      Center(
                        child:
                        user?.photo == "" ?
                        Container(
                          color:  Colors.transparent,
                          height: Responsive.isMobile(context) ? 90 : 120,
                          width: Responsive.isMobile(context) ? 90 : 120,
                          child: Image.asset(ImagePath.USER_DEFAULT),
                        ):
                        CachedNetworkImage(
                            width: Responsive.isMobile(context) ? 90 : 120,
                            height: Responsive.isMobile(context) ? 90 : 120,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            imageUrl: user?.photo ?? ""),
                      ),
                    ):
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(60)),
                      child:
                      Center(
                        child:
                        user?.photo == "" ?
                        Container(
                          color:  Colors.transparent,
                          height: Responsive.isMobile(context) ? 90 : 120,
                          width: Responsive.isMobile(context) ? 90 : 120,
                          child: Image.asset(ImagePath.USER_DEFAULT),
                        ):
                        FadeInImage.assetNetwork(
                          placeholder: ImagePath.USER_DEFAULT,
                          width: Responsive.isMobile(context) ? 90 : 120,
                          height: Responsive.isMobile(context) ? 90 : 120,
                          fit: BoxFit.cover,
                          image: user?.photo ?? "",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user!.firstName} ${user.lastName}',
                        maxLines: 2,
                        style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold, color: AppColors.chatDarkGray, overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(height: 8,),
                      Text(
                        '${user.educationName}'.toUpperCase(),
                        maxLines: 2,
                        style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold, color: AppColors.penBlue, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20,),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () => showDialog(
                    context: context,
                    builder: (BuildContext context) => ShowInvitationDialog(user: user, organizerId: socialEntityUser.socialEntityId!,)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.violet, // Background color
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(StringConst.INVITE_RESOURCE.toUpperCase(),
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.penBlue,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: Responsive.isMobile(context) ? 5 : 20),
                      SizedBox(height: 40, width: 40, child: Image.asset(ImagePath.CREATE_RESOURCE),)
                    ],
                  ),
                ),
              ),
            ],
          ),
          SpaceH20(),
          _buildMenuSelectorChips(context, user),
          SpaceH20(),
          _currentPage!,
          /*Column(
            children: [
              _buildPersonalData(context, user),
              _buildResourcesParticipant(context, user),
              _buildCvParticipant(context, user),
            ],
          ),*/
        ],
      ),
    );
  }

  Widget _buildMenuSelectorChips(BuildContext context, UserEnreda user){
    return Wrap(
      spacing: 5.0,
      runSpacing: 5.0,
      children: List<Widget>.generate(
        5,
            (int index) {
          return ChoiceChip(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25)),
                side: BorderSide(color: _value == _menuOptions[index] ? Colors.transparent : AppColors.violet)),
            disabledColor: Colors.white,
            selectedColor: AppColors.yellow,
            labelStyle: TextStyle(
              fontSize: Responsive.isMobile(context)? 12.0: 16.0,
              fontWeight: _value == _menuOptions[index] ? FontWeight.w700 : FontWeight.w400,
              color: _value == _menuOptions[index] ? AppColors.turquoiseBlue : AppColors.greyTxtAlt,

            ),


            label: Text(_menuOptions[index]),
            selected: _value == _menuOptions[index],
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            showCheckmark: false,
            onSelected: (bool selected) {
              setState(() {
                _value = _menuOptions[index];
                switch (index) {
                  case 0:
                    _currentPage = ParticipantControlPanelPage(participantUser: user);
                    break;
                  case 1:
                    _currentPage = Container();
                    break;
                  case 2:
                    _currentPage = ParticipantIPILPage(participantUser: user);
                    break;
                  case 3:
                    _currentPage = _personalDocumentationPage(context, user);
                    break;
                  case 4:
                    _currentPage = Container();
                    break;
                  default:
                    _currentPage = Container();
                    break;
                }

              });
            },
          );
        },
      ).toList(),
    );
  }

  Widget _personalDocumentationPage(BuildContext context, UserEnreda user){
    final database = Provider.of<Database>(context, listen: false);
    late int documentsCount = 0;
    return
      StreamBuilder<UserEnreda>(
        stream: database.userEnredaStreamByUserId(user.userId),
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
                        padding: const EdgeInsets.only(left: 50, top: 15.0, bottom: 15.0, right: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Documentación personal'.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppColors.bluePetrol,
                                fontSize: 35,
                                fontFamily: GoogleFonts.outfit().fontFamily,
                              ),
                            ),
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
                                          'Añadir Documentos',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: GoogleFonts.outfit().fontFamily,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: (){
                                    showDialog(
                                      context: context,
                                      builder: (context){
                                        TextEditingController newDocument = TextEditingController();
                                        GlobalKey<FormState> addDocumentKey = GlobalKey<FormState>();
                                        return AlertDialog(
                                          title: Text('Introduce el nombre del documento'),
                                          content: Form(
                                            key: addDocumentKey,
                                            child: TextFormField(
                                              controller: newDocument,
                                              validator: (value) => value!.isNotEmpty ? null : StringConst.FORM_GENERIC_ERROR,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            ElevatedButton(
                                                onPressed: () => Navigator.of(context).pop((false)),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text('Cancelar',
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
                                                      document: PersonalDocument(name: newDocument.text, order: documentsCount++, document: ''),
                                                      user: user);
                                                    Navigator.of(context).pop((true));
                                                  }

                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text('Añadir',
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
                                )
                              ]
                            ),
                          ]
                        )
                      ),
                      Divider(
                        color: AppColors.greyBorder,
                        height: 0,
                      ),
                      Column(
                        children: [
                          for( var document in _userDocuments)
                            _documentTile(document, user),
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

  Widget _documentTile(PersonalDocument document, UserEnreda user){
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
          Padding(
            padding: const EdgeInsets.only(left: 50.0),
            child: Text(
              document.name,
              style: TextStyle(
                fontFamily: GoogleFonts.inter().fontFamily,
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: AppColors.chatDarkGray,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: document.document != '' ? Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: AppColors.chatDarkGray,
                    size: 20,
                  ),
                  onPressed: (){
                    setPersonalDocument(context: context, document: PersonalDocument(name: document.name, order: -1, document: ''), user: user);
                    setState(() {

                    });
                  },
                ),
                SpaceW8(),
                IconButton(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: AppColors.chatDarkGray,
                    size: 20,
                  ),
                  onPressed: () async {
                    var data = await http.get(Uri.parse(document.document));
                    var pdfData = data.bodyBytes;
                    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfData);
                  },
                ),
                SpaceW8(),
                IconButton(
                  icon: Icon(
                    Icons.download,
                    color: AppColors.chatDarkGray,
                    size: 20,
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
              icon: Icon(
                Icons.add,
                color: AppColors.chatDarkGray,
                size: 20,
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

  Widget _buildHeader(BuildContext context, UserEnreda user){
    final textTheme = Theme.of(context).textTheme;
    final database = Provider.of<Database>(context, listen: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Photo
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 40, top: 30, right: 20, bottom: 30),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(160),
                  ),
                  child:
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(160)),
                    child:
                    Center(
                      child:
                      user.photo == "" ?
                      Container(
                        color:  Colors.transparent,
                        height: 160,
                        width: 160,
                        child: Image.asset(ImagePath.USER_DEFAULT),
                      ):
                      FadeInImage.assetNetwork(
                        placeholder: ImagePath.USER_DEFAULT,
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                        image: user.photo ?? "",
                      ),
                    ),
                  ),
                ),
              ),


              //Personal data
              StreamBuilder<UserEnreda>(
                stream: database.userEnredaStreamByUserId(user.assignedById),
                builder: (context, snapshot) {
                  String techName = snapshot.data?.firstName ?? '';
                  String techLastName = snapshot.data?.lastName ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(top:50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${user.firstName} ${user.lastName}',
                              style:
                                textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.chatDarkGray,
                                fontFamily: GoogleFonts.outfit().fontFamily,
                                fontSize: 35,
                                ),
                            ),
                            //Invite resource
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 150, right: 30),
                                child: AddYellowButton(
                                  text: 'Invitar a un recurso',
                                  onPressed: () => showDialog(
                                      context: context,
                                      builder: (BuildContext context) => ShowInvitationDialog(user: user, organizerId: socialEntityUser.socialEntityId!,)),
                                ),
                              ),
                            )
                          ],
                        ),
                        SpaceH8(),
                        (techName != '' || techLastName != '') ?
                          Text('Tecnico de referencia: $techName $techLastName') :
                          Container(),
                        SpaceH50(),

                        Row(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.mail,
                                  color: AppColors.darkGray,
                                  size: 22.0,
                                ),
                                const SpaceW4(),
                                CustomTextSmall(text: user.email,),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    color: AppColors.darkGray,
                                    size: 22.0,
                                  ),
                                  const SpaceW4(),
                                  CustomTextSmall(text: user.phone ?? '',)
                                ],
                              ),
                            ),
                            _buildMyLocation(context, user),
                          ],
                        )

                      ],
                    ),
                  );
                }
              ),

            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMyLocation(BuildContext context, UserEnreda? user) {
    final database = Provider.of<Database>(context, listen: false);
    Country? myCountry;
    Province? myProvince;
    City? myCity;
    String? city;
    String? province;
    String? country;

    return StreamBuilder<Country>(
        stream: database.countryStream(user?.address?.country),
        builder: (context, snapshot) {
          myCountry = snapshot.data;
          return StreamBuilder<Province>(
              stream: database.provinceStream(user?.address?.province),
              builder: (context, snapshot) {
                myProvince = snapshot.data;

                return StreamBuilder<City>(
                    stream: database.cityStream(user?.address?.city),
                    builder: (context, snapshot) {
                      myCity = snapshot.data;
                      city = myCity?.name ?? '';
                      province = myProvince?.name ?? '';
                      country = myCountry?.name ?? '';
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.black.withOpacity(0.7),
                            size: 22,
                          ),
                          const SpaceW4(),
                          /*Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextSmall(text: city ?? ''),
                              CustomTextSmall(text: province ?? ''),
                              CustomTextSmall(text: country ?? ''),
                            ],
                          ),*/
                          CustomTextSmall(text: city ?? ''),
                        ],
                      );
                    });
              });
        });
  }

  Widget _buildResourcesParticipant(BuildContext context, UserEnreda user) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: Responsive.isMobile(context) || Responsive.isTablet(context) ? null : 250,
      margin: Responsive.isMobile(context) || Responsive.isTablet(context) ? const EdgeInsets.symmetric(vertical: 20.0) : const EdgeInsets.only(left: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyLight2.withOpacity(0.3), width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
        color: AppColors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            StringConst.RESOURCES_PARTICIPANT,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: Responsive.isDesktop(context) ? 18 : 14.0,
              color: AppColors.penBlue,
            ),
          ),
          const SizedBox(height: 10,),
          ParticipantResourcesList(participantId: user.userId!, organizerId: socialEntityUser.socialEntityId!,),
        ],
      ),
    );
  }
}
