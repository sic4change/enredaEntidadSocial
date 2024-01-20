library globals;

import 'package:enreda_empresas/app/models/resource.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';

import '../../models/interest.dart';

Resource? currentResource;
SocialEntity? organizerCurrentResource;
String? interestsNamesCurrentResource;
Set<Interest> selectedInterestsCurrentResource = {};
List<String> interestsCurrentResource = [];