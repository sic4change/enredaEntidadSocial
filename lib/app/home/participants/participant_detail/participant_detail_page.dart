import 'package:enreda_empresas/app/home/participants/participant_detail/participant_control_panel_page.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/documentation/participant_documentation_page.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/ipils/participant_ipil_page.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/participant_social_reports_page.dart';
import 'package:enreda_empresas/app/common_widgets/add_yellow_button.dart';
import 'package:enreda_empresas/app/common_widgets/custom_text.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/participants/show_invitation_diaglog.dart';
import 'package:enreda_empresas/app/models/city.dart';
import 'package:enreda_empresas/app/models/country.dart';
import 'package:enreda_empresas/app/models/derivationReport.dart';
import 'package:enreda_empresas/app/models/documentationParticipant.dart';
import 'package:enreda_empresas/app/models/province.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:enreda_empresas/app/home/resources/global.dart' as globals;

class ParticipantDetailPage extends StatefulWidget {
  const ParticipantDetailPage({super.key,});

  @override
  State<ParticipantDetailPage> createState() => _ParticipantDetailPageState();
}

class _ParticipantDetailPageState extends State<ParticipantDetailPage> {
  List<String> _menuOptions = [
    StringConst.CONTROL_PANEL,
    StringConst.SOCIAL_REPORTS,
    StringConst.IPIL,
    StringConst.PERSONAL_DOCUMENTATION,
    StringConst.QUESTIONNAIRES];
  Widget? _currentPage;
  String? _value;
  late UserEnreda participantUser, socialEntityUser;

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
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<UserEnreda>(
      stream: database.userEnredaStreamByUserId(participantUser.assignedById),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          String techName = snapshot.data?.firstName ?? '';
          String techLastName = snapshot.data?.lastName ?? '';
          techNameComplete = '$techName $techLastName';
          return Responsive.isDesktop(context)? _buildParticipantWeb(context, participantUser, techNameComplete):
          _buildParticipantMobile(context, participantUser, techNameComplete);
        } else {
          return Responsive.isDesktop(context)? _buildParticipantWeb(context, participantUser, techNameComplete):
          _buildParticipantMobile(context, participantUser, techNameComplete);
        }
      },
    );
  }

  Widget _buildParticipantWeb(BuildContext context, UserEnreda user, String? techNameComplete) {
    return SingleChildScrollView(
      controller: ScrollController(),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Responsive.isDesktop(context)? _buildHeaderWeb(context, user, techNameComplete) :
              _buildHeaderMobile(context, user, techNameComplete),
            SpaceH20(),
            Divider(
              indent: 0,
              endIndent: 0,
              color: AppColors.greyBorder,
              thickness: 1,
              height: 1,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40.0, 22.0,0.0,22.0),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 0.0),
              child: _currentPage!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantMobile(BuildContext context, UserEnreda? user, String? techNameComplete) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderMobile(context, user!, techNameComplete),
          SpaceH20(),
          _buildMenuSelectorChips(context, user),
          SpaceH20(),
          _currentPage!,
        ],
      ),
    );
  }

  Widget _buildMenuSelectorChips(BuildContext context, UserEnreda user){
    return Wrap(
      spacing: 20.0,
      runSpacing: 20.0,
      children: List<Widget>.generate(5,
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
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            showCheckmark: false,
            onSelected: (bool selected) {
              setState(() {
                _value = _menuOptions[index];
                switch (index) {
                  case 0:
                    _currentPage = ParticipantControlPanelPage(participantUser: user);
                    break;
                  case 1:
                    _currentPage = ParticipantSocialReportPage(participantUser: user, context: context);
                    break;
                  case 2:
                    _currentPage = ParticipantIPILPage(participantUser: user);
                    break;
                  case 3:
                    _currentPage = ParticipantDocumentationPage(participantUser: user);
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

  Widget _buildHeaderWeb(BuildContext context, UserEnreda user, String? techNameComplete) {
    final textTheme = Theme.of(context).textTheme;
    final database = Provider.of<Database>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(left: Sizes.kDefaultPaddingDouble*2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30, right: 20, bottom: 30),
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top:50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '${user.firstName} ${user.lastName}',
                          style:
                          textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.chatDarkGray,
                            fontFamily: GoogleFonts.outfit().fontFamily,
                            fontSize: 30,
                          ),
                        ),
                      ),
                      AddYellowButton(
                        text: StringConst.INVITE_RESOURCE,
                        onPressed: () => showDialog(
                            context: context,
                            builder: (BuildContext context) => ShowInvitationDialog(user: user, organizerId: socialEntityUser.socialEntityId!,)),
                      ),
                      SpaceW40(),
                    ],
                  ),
                  SpaceH8(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (techNameComplete != null) ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CustomTextSmallColor(text: 'Técnica de referencia:', color: AppColors.primary900, height: 0.5,),
                          SpaceW8(),
                          CustomTextSmallBold(title: '$techNameComplete', color: AppColors.primary900, height: 0.5,),
                        ],
                      ) : _bottomAddTech(socialEntityUser),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CustomTextSmallColor(text: 'Estado de itinerario:', color: AppColors.primary900, height: 0.5,),
                          SpaceW8(),
                          StreamBuilder<UserEnreda>(
                            stream: database.userEnredaStreamByUserId(participantUser.userId),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return CustomTextSmallBold(
                                  title: 'No iniciado',
                                  color: AppColors.primary900,
                                  height: 0.5,
                                );
                              }
                              DateTime? startDateItinerary = snapshot.data?.startDateItinerary;
                              if (startDateItinerary != null) {
                                return StreamBuilder<DerivationReport>(
                                  stream: database.derivationReportsStreamByUserId(participantUser.userId),
                                  builder: (context, snapshotDerivation) {
                                    return StreamBuilder(
                                      stream: database.closureReportsStreamByUserId(participantUser.userId),
                                      builder: (context, snapshotClosure){
                                        if(snapshotDerivation.hasData) {
                                          if(snapshotDerivation.data!.completedDate != null){
                                            return CustomTextSmallBold(
                                              title: 'CERRADO: ${DateFormat('dd/MM/yyyy').format(startDateItinerary)} - ${DateFormat('dd/MM/yyyy').format(snapshotDerivation.data!.completedDate!)}',
                                              color: AppColors.redClose,
                                              height: 0.5,
                                            );
                                          }
                                          else{
                                            if(snapshotClosure.hasData){
                                              if(snapshotClosure.data!.completedDate != null){
                                                return CustomTextSmallBold(
                                                  title: 'CERRADO: ${DateFormat('dd/MM/yyyy').format(startDateItinerary)} - ${DateFormat('dd/MM/yyyy').format(snapshotClosure.data!.completedDate!)}',
                                                  color: AppColors.redClose,
                                                  height: 0.5,
                                                );
                                              }
                                              else{
                                                return CustomTextSmallBold(
                                                  title: 'ACTIVO: ${DateFormat('dd/MM/yyyy').format(startDateItinerary)}',
                                                  color: AppColors.primary900,
                                                  height: 0.5,
                                                );
                                              }
                                            }
                                            else{
                                              return CustomTextSmallBold(
                                                title: 'ACTIVO: ${DateFormat('dd/MM/yyyy').format(startDateItinerary)}',
                                                color: AppColors.primary900,
                                                height: 0.5,
                                              );
                                            }
                                          }
                                        }
                                        else {
                                          return CustomTextSmallBold(
                                            title: 'ACTIVO: ${DateFormat(
                                                'dd/MM/yyyy').format(
                                                startDateItinerary)}',
                                            color: AppColors.primary900,
                                            height: 0.5,
                                          );
                                        }
                                    });
                                  }
                                );
                              } else {
                                return CustomTextSmallBold(
                                  title: 'No iniciado',
                                  color: AppColors.primary900,
                                  height: 0.5,
                                );
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                  SpaceH20(),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomAddTech(UserEnreda tech){
    final database = Provider.of<Database>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () async {
                setState((){
                  participantUser.assignedById = tech.userId;
                });
                await database.setUserEnreda(participantUser);
              },
              child: CustomTextBold(title: 'Asignarme este participante', color: AppColors.turquoiseButton2,),
            ),
            SpaceW4(),
            InkWell(
              onTap: () async {
                setState((){
                  participantUser.assignedById = tech.userId;
                });
                await database.setUserEnreda(participantUser);
              },
              child: Icon(
                Icons.add_circle,
                color: AppColors.turquoiseButton2,
                size: 24,
              ),
            ),
          ],
        ),
    );

  }

  Widget _buildHeaderMobile(BuildContext context, UserEnreda user, String? techNameComplete) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(60)),
          child:
          user.photo == "" ?
          Container(
            color:  Colors.transparent,
            height: Responsive.isMobile(context) ? 90 : 120,
            width: Responsive.isMobile(context) ? 90 : 120,
            child: Image.asset(ImagePath.USER_DEFAULT),
          ) :
          FadeInImage.assetNetwork(
            placeholder: ImagePath.USER_DEFAULT,
            width: Responsive.isMobile(context) ? 90 : 120,
            height: Responsive.isMobile(context) ? 90 : 120,
            fit: BoxFit.cover,
            image: user.photo ?? "",
          ),
        ),
        SpaceH30(),
        Text(
          '${user.firstName} ${user.lastName}',
          maxLines: 2,
          style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold, color: AppColors.primary900, overflow: TextOverflow.ellipsis),
        ),
        SpaceH8(),
        Text(
          '${user.educationName}'.toUpperCase(),
          maxLines: 2,
          style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold, color: AppColors.primary900, overflow: TextOverflow.ellipsis),
        ),
        SpaceH12(),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (techNameComplete != null) ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomTextSmallColor(text: 'Técnica de referencia:', color: AppColors.primary900, height: 0.2,),
                SpaceW8(),
                CustomTextSmallBold(title: '$techNameComplete', color: AppColors.primary900, height: 0.2,),
              ],
            ) : _bottomAddTech(socialEntityUser),
            user.startDateItinerary != null ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomTextSmallColor(text: 'Estado de itinerario:', color: AppColors.primary900, height: 0.2,),
                SpaceW8(),

                CustomTextSmallBold(title: 'ACTIVO: ${DateFormat('dd/MM/yyyy').format(user.startDateItinerary!)}', color: AppColors.primary900, height: 0.2,),
              ],
            ) : CustomTextSmallColor(text: 'No iniciado', color: AppColors.primary900, height: 0.2,),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.mail,
              color: AppColors.darkGray,
              size: 14.0,
            ),
            const SpaceW4(),
            CustomTextSmall(text: user.email,),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.phone,
              color: AppColors.darkGray,
              size: 14.0,
            ),
            const SpaceW4(),
            CustomTextSmall(text: user.phone ?? '',)
          ],
        ),
        _buildMyLocation(context, user),
        SpaceH40(),
        Center(
          child: AddYellowButton(
            text: StringConst.INVITE_RESOURCE,
            onPressed: () => showDialog(
                context: context,
                builder: (BuildContext context) => ShowInvitationDialog(user: user, organizerId: socialEntityUser.socialEntityId!,)),
          ),
        ),
        SpaceH20(),
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
                            size: Responsive.isDesktop(context) && !Responsive.isDesktopS(context)? 22: 14,
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
}
