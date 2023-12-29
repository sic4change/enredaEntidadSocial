import 'package:enreda_empresas/app/common_widgets/rounded_container.dart';
import 'package:enreda_empresas/app/common_widgets/spaces.dart';
import 'package:enreda_empresas/app/home/participants/participant_detail/participant_detail_page.dart';
import 'package:enreda_empresas/app/home/participants/participants_item_builder.dart';
import 'package:enreda_empresas/app/home/participants/participants_tile.dart';
import 'package:enreda_empresas/app/models/gamificationFlags.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/auth.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ParticipantsListPage extends StatefulWidget {
  const ParticipantsListPage({super.key});

  @override
  State<ParticipantsListPage> createState() => _ParticipantsListPageState();
}

class _ParticipantsListPageState extends State<ParticipantsListPage> {
  Widget? _currentPage;
  late UserEnreda socialEntityUser;

  @override
  void initState() {
    _currentPage = _buildParticipantsList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
        child: Align(
        alignment: Alignment.topLeft,
        child: SingleChildScrollView(
          child: _currentPage!,
        ),
      ),
    );
  }

  Widget _buildParticipantsList() {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);

    return StreamBuilder<UserEnreda>(
      stream: database.userEnredaStreamByUserId(auth.currentUser!.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        socialEntityUser = snapshot.data!;
        return StreamBuilder<List<UserEnreda>>(
          stream: database.getParticipantsBySocialEntityStream(socialEntityUser.socialEntityId!),
          builder: (context, userSnapshot) {
            if(userSnapshot.hasData) {
              return StreamBuilder(
                stream: database.socialEntityStreamById(socialEntityUser.socialEntityId!),
                builder: (context, socialEntitySnapshot) {
                  if (socialEntitySnapshot.hasData) {
                    return StreamBuilder<List<GamificationFlag>>(
                        stream: database.gamificationFlagsStream(),
                        builder: (context, gamificationSnapshot) {
                          if (gamificationSnapshot.hasData) {
                            final textTheme = Theme.of(context).textTheme;
                            final users = userSnapshot.data!;
                            final myParticipants = users.where((u) =>
                            u.assignedEntityId == socialEntityUser.socialEntityId!
                                && u.assignedById == socialEntityUser.userId).toList();
                            final allOtherParticipants = users.where((u) =>
                            u.assignedEntityId == socialEntityUser.socialEntityId!
                                && u.assignedById != socialEntityUser.userId).toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(StringConst.PARTICIPANTS,
                                  style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.turquoiseBlue),),
                                SpaceH40(),
                                Text(StringConst.MY_PARTICIPANTS,
                                  style: textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.turquoiseBlue),),
                                SpaceH20(),
                                ParticipantsItemBuilder(
                                    usersList: myParticipants,
                                    emptyMessage: 'No hay participantes gestionados por ti',
                                    itemBuilder: (context, user) {
                                      return ParticipantsListTile(
                                          user: user,
                                          totalGamificationFlags: gamificationSnapshot.data!.length - 2,
                                          onTap: () => setState(() {
                                            _currentPage =  ParticipantDetailPage(
                                              user: user,
                                              socialEntityUser: socialEntityUser,
                                              onBack: () => setState(() {
                                                _currentPage = _buildParticipantsList();
                                              }),
                                            );
                                          })
                                      );
                                    }
                                ),
                                SpaceH40(),
                                Text(StringConst.allParticipants(socialEntitySnapshot.data!.name),
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.turquoiseBlue,),),
                                SpaceH20(),
                                ParticipantsItemBuilder(
                                    usersList: allOtherParticipants,
                                    emptyMessage: 'No hay participantes gestionados por tu entidad',
                                    itemBuilder: (context, user) {
                                      return ParticipantsListTile(
                                          user: user,
                                          totalGamificationFlags: gamificationSnapshot.data!.length - 2,
                                          onTap: () => setState(() {
                                            _currentPage =  ParticipantDetailPage(
                                              user: user,
                                              socialEntityUser: socialEntityUser,
                                              onBack: () => setState(() {
                                                _currentPage = _buildParticipantsList();
                                              }),
                                            );
                                          })
                                      );
                                    }
                                ),
                              ],
                            );
                          } else {
                            return const Center(child: CircularProgressIndicator());
                          }
                        }
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                }
              );
            }
            return const Center(child: CircularProgressIndicator());
        });
    });
  }

}
