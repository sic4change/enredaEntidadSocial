library globals;

import 'package:enreda_empresas/app/models/competency.dart';
import 'package:enreda_empresas/app/models/resource.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';

import '../../models/interest.dart';

Resource? currentResource;
SocialEntity? organizerCurrentResource;
String? interestsNamesCurrentResource;
String? competenciesNamesCurrentResource;
Set<Interest> selectedInterestsCurrentResource = {};
Set<Competency> selectedCompetenciesCurrentResource = {};
List<String> interestsCurrentResource = [];
UserEnreda? currentParticipant;
UserEnreda? currentSocialEntityUser;