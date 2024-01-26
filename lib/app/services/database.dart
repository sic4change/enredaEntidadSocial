import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enreda_empresas/app/models/ability.dart';
import 'package:enreda_empresas/app/models/certificationRequest.dart';
import 'package:enreda_empresas/app/models/city.dart';
import 'package:enreda_empresas/app/models/competency.dart';
import 'package:enreda_empresas/app/models/contact.dart';
import 'package:enreda_empresas/app/models/country.dart';
import 'package:enreda_empresas/app/models/dedication.dart';
import 'package:enreda_empresas/app/models/education.dart';
import 'package:enreda_empresas/app/models/experience.dart';
import 'package:enreda_empresas/app/models/gamificationFlags.dart';
import 'package:enreda_empresas/app/models/gender.dart';
import 'package:enreda_empresas/app/models/interest.dart';
import 'package:enreda_empresas/app/models/ipilEntry.dart';
import 'package:enreda_empresas/app/models/organization.dart';
import 'package:enreda_empresas/app/models/socialEntitiesType.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/models/socialEntityUser.dart';
import 'package:enreda_empresas/app/models/province.dart';
import 'package:enreda_empresas/app/models/resource.dart';
import 'package:enreda_empresas/app/models/resourceCategory.dart';
import 'package:enreda_empresas/app/models/resourceInvitation.dart';
import 'package:enreda_empresas/app/models/resourcetype.dart';
import 'package:enreda_empresas/app/models/scope.dart';
import 'package:enreda_empresas/app/models/size.dart';
import 'package:enreda_empresas/app/models/specificinterest.dart';
import 'package:enreda_empresas/app/models/timeSearching.dart';
import 'package:enreda_empresas/app/models/timeSpentWeekly.dart';
import 'package:enreda_empresas/app/models/unemployedUser.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/api_path.dart';
import 'package:enreda_empresas/app/services/firestore_service.dart';
import 'package:enreda_empresas/app/models/resourcePicture.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class Database {
     Stream<List<Resource>> resourcesStream();
     Stream<List<Resource>> limitResourcesStream(int i);
     Stream<Resource> resourceStream(String? resourceId);
     Stream<List<Resource>> myResourcesStream(String socialEntityId);
     Stream<List<Resource>> myLimitResourcesStream(String socialEntityId, int i);
     Stream<List<Resource>> participantsResourcesStream(String? userId, String? organizerId);
     Stream<List<UserEnreda>> getParticipantsBySocialEntityStream(String socialEntityId);
     Stream<List<SocialEntity>> socialEntitiesStream();
     Stream<List<SocialEntity>> filterSocialEntityStream(String socialEntityId);
     Stream<SocialEntity> socialEntityStream(String? socialEntityId);
     Stream<UserEnreda> mentorStream(String mentorId);
     Stream<UserEnreda?> userStreamByEmail(String? email);
     Stream<List<Country>> countriesStream();
     Stream<List<Country>> countryFormatedStream();
     Stream<Country> countryStream(String? countryId);
     Stream<List<Province>> provincesStream();
     Stream<Province> provinceStream(String? provinceId);
     Stream<List<Province>> provincesCountryStream(String? countryId);
     Stream<List<City>> citiesStream();
     Stream<City> cityStream(String? cityId);
     Stream<ResourcePicture> resourcePictureStream(String? resourcePictureId);
     Stream<List<ResourcePicture>> resourcePicturesStream();
     Stream<List<City>> citiesProvinceStream(String? provinceId);
     Stream<List<UserEnreda>> userStream(String? email);
     Stream<List<UserEnreda>> userParticipantsStream(List<String?> resourceIdList);
     Stream<List<Resource>> resourcesParticipantsStream(List<String?> participantsIdList);
     Stream<List<Interest>> resourcesInterestsStream(List<String?> interestsIdList);
     Stream<List<UserEnreda>> participantsByResourceStream(String resourceId);
     Stream<SocialEntity> socialEntityStreamById(String? socialEntityId);
     Stream<Organization> organizationStreamById(String organizationId);
     Stream<UserEnreda> userEnredaStreamByUserId(String? userId);
     Stream<ResourceType> resourceTypeStreamById(String? resourceTypeId);
     Stream<ResourceCategory> resourceCategoryStreamById(String? resourceCategoryId);
     Stream<List<Scope>> scopeStream();
     Stream<List<SizeOrg>> sizeStream();
     Stream<List<Ability>> abilityStream();
     Stream<List<ResourceCategory>> resourceCategoryStream();
     Stream<List<Education>> educationStream();
     Stream<List<ResourceType>> resourceTypeStream();
     Stream<List<Interest>> interestStream();
     Stream<List<Interest>> interestsStream(String? interestId);
     Stream<List<SpecificInterest>> specificInterestsStream();
     Stream<List<SpecificInterest>> specificInterestStream(String? interestId);
     Stream<List<UserEnreda>> checkIfUserEmailRegistered(String email);
     Stream<List<Experience>> myExperiencesStream(String userId);
     Stream<List<Competency>> competenciesStream();
     Stream<List<CertificationRequest>> myCertificationRequestStream(String userId);
     Stream<List<SocialEntitiesType>> socialEntitiesTypeStream();
     Future<void> setUserEnreda(UserEnreda userEnreda);
     Future<void> deleteUser(UserEnreda userEnreda);
     Future<void> uploadUserAvatar(String userId, Uint8List data);
     Future<void> addContact(Contact contact);
     Future<void> setResource(Resource resource);
     Future<void> deleteResource(Resource resource);
     Future<void> addSocialEntityUser(SocialEntityUser socialEntityUser);
     Future<void> addSocialEntity(SocialEntity socialEntity);
     Future<void> addResource(Resource resource);
     Future<void> addResourceInvitation(ResourceInvitation resourceInvitation);
     Future<void> updateCertificationRequest(CertificationRequest certificationRequest, bool certified, bool referenced );
     Stream<List<GamificationFlag>> gamificationFlagsStream();
     Future<void> addUnemployedUser(UnemployedUser unemployedUser);
     Stream<List<Dedication>> dedicationStream();
     Stream<List<Gender>> genderStream();
     Stream<List<TimeSpentWeekly>> timeSpentWeeklyStream();
     Stream<List<TimeSearching>> timeSearchingStream();
     Stream<List<IpilEntry>> getIpilEntriesByUserStream(String userId);
     Future<void> addIpilEntry(IpilEntry ipilEntry);
     Future<void> updateIpilEntryContent(IpilEntry ipilEntry, String content);
     Future<void> updateIpilEntryDate(IpilEntry ipilEntry, DateTime date);
     Future<void> deleteIpilEntry(IpilEntry ipilEntry);
}

class FirestoreDatabase implements Database {
  FirestoreDatabase();

  final _service = FirestoreService.instance;

  @override
  Future<void> setResource(Resource resource) => _service.updateData(
      path: APIPath.resource(resource.resourceId!), data: resource.toMap());

  @override
  Future<void> deleteResource(Resource resource) =>
      _service.deleteData(path: APIPath.resource(resource.resourceId!));

    @override
    Stream<List<Resource>> myResourcesStream(String socialEntityId) =>
        _service.collectionStream(
          path: APIPath.resources(),
          queryBuilder: (query) =>
              query.where('organizer', isEqualTo: socialEntityId),
          builder: (data, documentId) => Resource.fromMap(data, documentId),
          sort: (rhs, lhs) => lhs.createdate.compareTo(rhs.createdate),
        );

    @override
    Stream<List<Resource>> myLimitResourcesStream(String socialEntityId, int limit) =>
      _service.collectionStream(
        path: APIPath.resources(),
        queryBuilder: (query) => query
            .where('organizer', isEqualTo: socialEntityId)
            .limit(limit),
        builder: (data, documentId) => Resource.fromMap(data, documentId),
        sort: (rhs, lhs) => lhs.createdate.compareTo(rhs.createdate),
      );

    @override
    Stream<List<Resource>> participantsResourcesStream(String? userId, String? organizerId) =>
      _service.collectionStream(
        path: APIPath.resources(),
        queryBuilder: (query) {
              query = query.where('participants', arrayContains: userId).where('organizer', isEqualTo: organizerId);
              return query;
            },
        builder: (data, documentId) => Resource.fromMap(data, documentId),
        sort: (rhs, lhs) => lhs.createdate.compareTo(rhs.createdate),
      );

    @override
    Stream<Resource> resourceStream(String? resourceId) =>
        _service.documentStream<Resource>(
          path: APIPath.resource(resourceId!),
          builder: (data, documentId) => Resource.fromMap(data, documentId),
        );

    @override
    Stream<List<Resource>> resourcesStream() => _service.collectionStream(
      path: APIPath.resources(),
      queryBuilder: (query) => query.where('organizerType', isEqualTo: "Entidad Social"),
      builder: (data, documentId) => Resource.fromMap(data, documentId),
      sort: (lhs, rhs) => lhs.createdate.compareTo(rhs.createdate),
    );

  @override
  Stream<List<Resource>> limitResourcesStream(int limit) =>
      _service.collectionStream(
        path: APIPath.resources(),
        queryBuilder: (query) => query
            .where('organizerType', isEqualTo: "Entidad Social")
            .limit(limit),
        builder: (data, documentId) => Resource.fromMap(data, documentId),
        sort: (rhs, lhs) => lhs.createdate.compareTo(rhs.createdate),
      );

    @override
    Stream<List<SocialEntity>> socialEntitiesStream() => _service.collectionStream(
      path: APIPath.socialEntities(),
      queryBuilder: (query) => query.where('trust', isEqualTo: true),
      builder: (data, documentId) => SocialEntity.fromMap(data, documentId),
      sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
    );

    @override
    Stream<List<SocialEntity>> filterSocialEntityStream(String socialEntityId) =>
        _service.collectionStream(
          path: APIPath.socialEntities(),
          builder: (data, documentId) => SocialEntity.fromMap(data, documentId),
          queryBuilder: (query) =>
              query.where('socialEntityId', isEqualTo: socialEntityId),
          sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
        );

    @override
    Stream<SocialEntity> socialEntityStream(String? socialEntityId) =>
        _service.documentStream<SocialEntity>(
          path: APIPath.socialEntity(socialEntityId!),
          builder: (data, documentId) => SocialEntity.fromMap(data, documentId),
        );

    @override
    Stream<UserEnreda> mentorStream(String mentorId) =>
        _service.documentStream<UserEnreda>(
          path: APIPath.user(mentorId),
          builder: (data, documentId) => UserEnreda.fromMap(data, documentId),
        );

    Stream<UserEnreda?> userStreamByEmail(String? email) {
      return _service.nullableDocumentStreamByField(
        path: APIPath.users(),
        builder: (data, documentId) => UserEnreda.fromMap(data, documentId),
        queryBuilder: (query) => query.where('email', isEqualTo: email),
      );
    }

    @override
    Stream<List<Country>> countriesStream() => _service.collectionStream(
      path: APIPath.countries(),
      queryBuilder: (query) => query.where('coutryId', isNotEqualTo: null),
      builder: (data, documentId) => Country.fromMap(data, documentId),
      sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
    );

    @override
    Stream<List<Country>> countryFormatedStream() => _service.collectionStream(
      path: APIPath.countries(),
      queryBuilder: (query) => query.where('name', isNotEqualTo: 'Online'),
      builder: (data, documentId) => Country.fromMap(data, documentId),
      sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
    );

    @override
    Stream<Country> countryStream(String? countryId) =>
          _service.documentStream<Country>(
            path: APIPath.country(countryId),
            builder: (data, documentId) => Country.fromMap(data, documentId),
          );

    @override
    Stream<List<Province>> provincesStream() => _service.collectionStream(
      path: APIPath.provinces(),
      queryBuilder: (query) => query.where('provinceId', isNotEqualTo: null),
      builder: (data, documentId) => Province.fromMap(data, documentId),
      sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
    );

    @override
    Stream<Province> provinceStream(String? provinceId) =>
        _service.documentStream<Province>(
          path: APIPath.province(provinceId),
          builder: (data, documentId) => Province.fromMap(data, documentId),
        );

    @override
    Stream<List<Province>> provincesCountryStream(String? countryId) {

      if (countryId == null) {
        return const Stream<List<Province>>.empty();
      }

      return _service.collectionStream(
        path: APIPath.provinces(),
        builder: (data, documentId) => Province.fromMap(data, documentId),
        queryBuilder: (query) => query.where('countryId', isEqualTo: countryId),
        sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
      );
    }

    @override
    Stream<List<City>> citiesStream() => _service.collectionStream(
      path: APIPath.cities(),
      queryBuilder: (query) => query.where('cityId', isNotEqualTo: null),
      builder: (data, documentId) => City.fromMap(data, documentId),
      sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
    );

    @override
    Stream<City> cityStream(String? cityId) => _service.documentStream<City>(
        path: APIPath.city(cityId),
        builder: (data, documentId) => City.fromMap(data, documentId),
      );

    @override
    Stream<List<City>> citiesProvinceStream(String? provinceId) =>
        _service.collectionStream(
          path: APIPath.cities(),
          builder: (data, documentId) => City.fromMap(data, documentId),
          queryBuilder: (query) =>
              query.where('provinceId', isEqualTo: provinceId),
          sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
        );

    @override
    Stream<ResourcePicture> resourcePictureStream(String? resourcePictureId) =>
        _service.documentStream<ResourcePicture>(
          path: APIPath.resourcePicture(resourcePictureId),
          builder: (data, documentId) =>
              ResourcePicture.fromMap(data, documentId),
        );

    @override
    Stream<List<ResourcePicture>> resourcePicturesStream() =>
      _service.collectionStream(
        path: APIPath.resourcePictures(),
        queryBuilder: (query) => query.where('role', isEqualTo: "Super Admin"),
        builder: (data, documentId) => ResourcePicture.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
      );

    @override
    Stream<List<UserEnreda>> userStream(String? email) {
      return _service.collectionStream<UserEnreda>(
        path: APIPath.users(),
        queryBuilder: (query) => query.where('email', isEqualTo: email),
        builder: (data, documentId) => UserEnreda.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.email.compareTo(rhs.email),
      );
    }

  @override
  Stream<List<UserEnreda>> userParticipantsStream(List<String?> resourceIdList) {
    return _service.collectionStream<UserEnreda>(
      path: APIPath.users(),
      queryBuilder: (query) {

        return query.where('resources', arrayContainsAny: resourceIdList);
      },
      builder: (data, documentId) => UserEnreda.fromMap(data, documentId),
      sort: (lhs, rhs) => lhs.email.compareTo(rhs.email),
      );
    }

  @override
  Stream<List<UserEnreda>> getParticipantsBySocialEntityStream(String socialEntityId) {
    return _service.collectionStream<UserEnreda>(
      path: APIPath.users(),
      queryBuilder: (query) => query.where('assignedEntityId', isEqualTo: socialEntityId),
      builder: (data, documentId) => UserEnreda.fromMap(data, documentId),
      sort: (lhs, rhs) => (lhs.firstName??"").compareTo(rhs.firstName??""),
    );
  }


  @override
  Stream<List<UserEnreda>> participantsByResourceStream(String? resourceId) {
    return _service.collectionStream<UserEnreda>(
      path: APIPath.users(),
      queryBuilder: (query) => query.where('resources', arrayContains: resourceId),
      builder: (data, documentId) => UserEnreda.fromMap(data, documentId),
      sort: (lhs, rhs) => lhs.email.compareTo(rhs.email),
    );
  }

  @override
  Stream<List<Resource>> resourcesParticipantsStream(List<String?> participantsIdList) {
    return _service.collectionStream<Resource>(
      path: APIPath.resources(),
      queryBuilder: (query) => query.where('participants', arrayContainsAny: participantsIdList),
      builder: (data, documentId) => Resource.fromMap(data, documentId),
      sort: (lhs, rhs) => lhs.title.compareTo(rhs.title),
    );
  }

  @override
  Stream<List<Interest>> resourcesInterestsStream(List<String?> interestsIdList) {
    return _service.collectionStream<Interest>(
      path: APIPath.interests(),
      queryBuilder: (query) => query.where('interestId', whereIn: interestsIdList),
      builder: (data, documentId) => Interest.fromMap(data, documentId),
      sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
    );
  }


  @override
  Stream<SocialEntity> socialEntityStreamById(String? socialEntityId) =>
      _service.documentStream<SocialEntity>(
        path: APIPath.socialEntity(socialEntityId!),
        builder: (data, documentId) =>
            SocialEntity.fromMap(data, documentId),
      );

  @override
  Stream<Organization> organizationStreamById(String? organizationId) =>
      _service.documentStream<Organization>(
        path: APIPath.organization(organizationId!),
        builder: (data, documentId) =>
            Organization.fromMap(data, documentId),
      );

  @override
  Stream<ResourceType> resourceTypeStreamById(String? resourceTypeId) =>
      _service.documentStream<ResourceType>(
        path: APIPath.resourceType(resourceTypeId!),
        builder: (data, documentId) =>
            ResourceType.fromMap(data, documentId),
      );

  @override
  Stream<ResourceCategory> resourceCategoryStreamById(String? resourceCategoryId) =>
      _service.documentStream<ResourceCategory>(
        path: APIPath.resourceCategory(resourceCategoryId!),
        builder: (data, documentId) =>
            ResourceCategory.fromMap(data, documentId),
      );

  @override
  Stream<UserEnreda> userEnredaStreamByUserId(String? userId) {
    return _service.documentStreamByField(
      path: APIPath.users(),
      builder: (data, documentId) => UserEnreda.fromMap(data, documentId),
      queryBuilder: (query) => query.where('userId', isEqualTo: userId),
    );
  }

    @override
    Stream<List<CertificationRequest>> myCertificationRequestStream(String userId) =>
        _service.collectionStream(
          path: APIPath.certificationsRequests(),
          queryBuilder: (query) => query.where('unemployedRequesterId', isEqualTo: userId),
          builder: (data, documentId) => CertificationRequest.fromMap(data, documentId),
          sort: (lhs, rhs) => lhs.certifierName.compareTo(rhs.certifierName),
        );

    @override
    Stream<List<SocialEntitiesType>> socialEntitiesTypeStream() => _service.collectionStream(
      path: APIPath.socialEntitiesType(),
      queryBuilder: (query) => query.where('id', isNotEqualTo: null),
      builder: (data, documentId) => SocialEntitiesType.fromMap(data, documentId),
      sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
    );

    @override
    Future<void> setUserEnreda(UserEnreda userEnreda) {
      return _service.updateData(
          path: APIPath.user(userEnreda.userId!), data: userEnreda.toMap());
    }

    @override
    Future<void> deleteUser(UserEnreda userEnreda) {
      return _service.deleteData(path: APIPath.user(userEnreda.userId!));
    }

  @override
  Future<void> updateCertificationRequest(CertificationRequest certificationRequest, bool certified, bool referenced) {
    return _service.updateData(
        path: APIPath.certificationRequest(certificationRequest.certificationRequestId!), data: {
      "certified": certified, 'referenced': referenced});
  }

    @override
    Stream<List<Interest>> interestStream() => _service.collectionStream(
      path: APIPath.interests(),
      queryBuilder: (query) => query.where('name', isNotEqualTo: null),
      builder: (data, documentId) => Interest.fromMap(data, documentId),
      sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
    );

  @override
  Stream<List<Interest>> interestsStream(String? interestId) =>
      _service.collectionStream(
        path: APIPath.interests(),
        queryBuilder: (query) =>
            query.where('interestId', isEqualTo: interestId),
        builder: (data, documentId) =>
            Interest.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
      );

  @override
  Stream<List<SpecificInterest>> specificInterestsStream() => _service.collectionStream(
    path: APIPath.specificInterests(),
    queryBuilder: (query) => query.where('name', isNotEqualTo: null),
    builder: (data, documentId) => SpecificInterest.fromMap(data, documentId),
    sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
  );

  @override
  Stream<List<SpecificInterest>> specificInterestStream(String? interestId) =>
      _service.collectionStream(
        path: APIPath.specificInterests(),
        queryBuilder: (query) =>
            query.where('interestId', isEqualTo: interestId),
        builder: (data, documentId) =>
            SpecificInterest.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
      );

  @override
  Stream<List<Ability>> abilityStream() => _service.collectionStream(
    path: APIPath.abilities(),
    queryBuilder: (query) => query.where('name', isNotEqualTo: null),
    builder: (data, documentId) => Ability.fromMap(data, documentId),
    sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
  );

    @override
    Stream<List<Scope>> scopeStream() => _service.collectionStream(
      path: APIPath.scopes(),
      queryBuilder: (query) => query.where('label', isNotEqualTo: null),
      builder: (data, documentId) => Scope.fromMap(data, documentId),
      sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
    );

    @override
    Stream<List<SizeOrg>> sizeStream() => _service.collectionStream(
      path: APIPath.sizes(),
      queryBuilder: (query) => query.where('label', isNotEqualTo: null),
      builder: (data, documentId) => SizeOrg.fromMap(data, documentId),
      sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
    );

    @override
    Stream<List<ResourceCategory>> resourceCategoryStream() => _service.collectionStream(
      path: APIPath.resourcesCategories(),
      queryBuilder: (query) => query.where('name', isNotEqualTo: null),
      builder: (data, documentId) => ResourceCategory.fromMap(data, documentId),
      sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
    );

      @override
      Stream<List<Education>> educationStream() => _service.collectionStream(
        path: APIPath.education(),
        queryBuilder: (query) => query.where('label', isNotEqualTo: null),
        builder: (data, documentId) => Education.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
      );

      @override
      Stream<List<ResourceType>> resourceTypeStream() => _service.collectionStream(
        path: APIPath.resourcesTypes(),
        queryBuilder: (query) => query.where('name', isNotEqualTo: null),
        builder: (data, documentId) => ResourceType.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
      );

    @override
      Future<void> uploadUserAvatar(String userId, Uint8List data) async {
        var firebaseStorageRef =
        FirebaseStorage.instance.ref().child('users/$userId/profilePic');
        UploadTask uploadTask = firebaseStorageRef.putData(data);
        TaskSnapshot taskSnapshot = await uploadTask;
        taskSnapshot.ref.getDownloadURL().then(
              (value) => {
            //print("Done: $value")
            _service.updateData(path: APIPath.photoUser(userId), data: {
              "profilePic": {
                'src': '$value',
                'title': 'photo.jpg',
              }
            })
          },
        );
      }

    @override
    Future<void> addContact(Contact contact) =>
        _service.addData(path: APIPath.contacts(), data: contact.toMap());

  @override
  Future<void> addSocialEntity(SocialEntity socialEntity) => _service.addData(
      path: APIPath.socialEntities(), data: socialEntity.toMap());

  @override
  Future<void> addSocialEntityUser(SocialEntityUser socialEntityUser) =>
      _service.addData(path: APIPath.users(), data: socialEntityUser.toMap());

  @override
  Future<void> addResourceInvitation(ResourceInvitation resourceInvitation) =>
      _service.addData(path: APIPath.resourcesInvitations(), data: resourceInvitation.toMap());

  @override
  Future<void> addResource(Resource resource) =>
      _service.addData(path: APIPath.resources(), data: resource.toMap());


  @override
  Stream<List<UserEnreda>> checkIfUserEmailRegistered(String email) {
    return _service.collectionStream(
      path: APIPath.users(),
      builder: (data, documentId) => UserEnreda.fromMap(data, documentId),
      queryBuilder: (query) => query.where('email', isEqualTo: email),
      sort: (lhs, rhs) => lhs.email.compareTo(rhs.email),
    );
  }

  @override
  Stream<List<Experience>> myExperiencesStream(String userId) =>
      _service.collectionStream(
        path: APIPath.experiences(),
        queryBuilder: (query) =>
            query.where('userId', isEqualTo: userId),
        builder: (data, documentId) => Experience.fromMap(data, documentId),
        sort: (lhs, rhs) => rhs.startDate.compareTo(lhs.startDate),
      );

  @override
  Stream<List<Competency>> competenciesStream() => _service.collectionStream(
    path: APIPath.competencies(),
    builder: (data, documentId) => Competency.fromMap(data, documentId),
    queryBuilder: (query) => query,
    sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
  );

  @override
  Stream<List<GamificationFlag>> gamificationFlagsStream() => _service.collectionStream(
    path: APIPath.gamificationFlags(),
    queryBuilder: (query) => query.where('id', isNotEqualTo: null),
    builder: (data, documentId) => GamificationFlag.fromMap(data, documentId),
    sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
  );

  @override
  Future<void> addUnemployedUser(UnemployedUser unemployedUser) =>
      _service.addData(path: APIPath.users(), data: unemployedUser.toMap());

  @override
  Stream<List<Dedication>> dedicationStream() => _service.collectionStream(
    path: APIPath.dedications(),
    queryBuilder: (query) => query.where('label', isNotEqualTo: null),
    builder: (data, documentId) => Dedication.fromMap(data, documentId),
    sort: (lhs, rhs) => lhs.value.compareTo(rhs.value),
  );

  @override
  Stream<List<Gender>> genderStream() => _service.collectionStream(
    path: APIPath.genders(),
    queryBuilder: (query) => query.where('name', isNotEqualTo: null),
    builder: (data, documentId) => Gender.fromMap(data, documentId),
    sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
  );

  @override
  Stream<List<TimeSpentWeekly>> timeSpentWeeklyStream() =>
      _service.collectionStream(
        path: APIPath.timeSpentWeekly(),
        queryBuilder: (query) => query.where('label', isNotEqualTo: null),
        builder: (data, documentId) =>
            TimeSpentWeekly.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.value.compareTo(rhs.value),
      );

  @override
  Stream<List<TimeSearching>> timeSearchingStream() =>
      _service.collectionStream(
        path: APIPath.timeSearching(),
        queryBuilder: (query) => query.where('label', isNotEqualTo: null),
        builder: (data, documentId) => TimeSearching.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.value.compareTo(rhs.value),
      );

  @override
  Stream<List<IpilEntry>> getIpilEntriesByUserStream(String userId) {
    return _service.collectionStream<IpilEntry>(
      path: APIPath.ipilEntry(),
      queryBuilder: (query) => query.where('userId', isEqualTo: userId),
      builder: (data, documentId) => IpilEntry.fromMap(data, documentId),
      sort: (lhs, rhs) => (rhs.date).compareTo(lhs.date),
    );
  }

  @override
  Future<void> addIpilEntry(IpilEntry ipilEntry) =>
      _service.addData(path: APIPath.ipilEntry(), data: ipilEntry.toMap());

  @override
  Future<void> updateIpilEntryContent(IpilEntry ipilEntry, String content) {
    return _service.updateData(
        path: APIPath.ipilEntryById(ipilEntry.ipilId!), data: {
      "content": content});
  }

  @override
  Future<void> updateIpilEntryDate(IpilEntry ipilEntry, DateTime date) {
    return _service.updateData(
        path: APIPath.ipilEntryById(ipilEntry.ipilId!), data: {
      'date': date});
  }

  @override
  Future<void> deleteIpilEntry(IpilEntry ipilEntry) =>
      _service.deleteData(path: APIPath.ipilEntryById(ipilEntry.ipilId!));
}


