import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enreda_empresas/app/models/ability.dart';
import 'package:enreda_empresas/app/models/certificationRequest.dart';
import 'package:enreda_empresas/app/models/city.dart';
import 'package:enreda_empresas/app/models/closureReport.dart';
import 'package:enreda_empresas/app/models/competency.dart';
import 'package:enreda_empresas/app/models/competencyCategory.dart';
import 'package:enreda_empresas/app/models/competencySubCategory.dart';
import 'package:enreda_empresas/app/models/contact.dart';
import 'package:enreda_empresas/app/models/country.dart';
import 'package:enreda_empresas/app/models/dedication.dart';
import 'package:enreda_empresas/app/models/derivationReport.dart';
import 'package:enreda_empresas/app/models/education.dart';
import 'package:enreda_empresas/app/models/experience.dart';
import 'package:enreda_empresas/app/models/followReport.dart';
import 'package:enreda_empresas/app/models/gamificationFlags.dart';
import 'package:enreda_empresas/app/models/gender.dart';
import 'package:enreda_empresas/app/models/initialReport.dart';
import 'package:enreda_empresas/app/models/interest.dart';
import 'package:enreda_empresas/app/models/ipilConnectionTerritory.dart';
import 'package:enreda_empresas/app/models/ipilContextualization.dart';
import 'package:enreda_empresas/app/models/ipilDigitalSkills.dart';
import 'package:enreda_empresas/app/models/ipilEconomicBag.dart';
import 'package:enreda_empresas/app/models/ipilEntry.dart';
import 'package:enreda_empresas/app/models/ipilIntermediations.dart';
import 'package:enreda_empresas/app/models/ipilInterviews.dart';
import 'package:enreda_empresas/app/models/ipilLaborSkills.dart';
import 'package:enreda_empresas/app/models/ipilLegal.dart';
import 'package:enreda_empresas/app/models/ipilObjectives.dart';
import 'package:enreda_empresas/app/models/ipilPostWorkSupport.dart';
import 'package:enreda_empresas/app/models/ipilReinforcement.dart';
import 'package:enreda_empresas/app/models/ipilResults.dart';
import 'package:enreda_empresas/app/models/ipilSoftSkills.dart';
import 'package:enreda_empresas/app/models/ipilSpecificSkills.dart';
import 'package:enreda_empresas/app/models/keepLearningOption.dart';
import 'package:enreda_empresas/app/models/organization.dart';
import 'package:enreda_empresas/app/models/region.dart';
import 'package:enreda_empresas/app/models/documentationParticipant.dart';
import 'package:enreda_empresas/app/models/personalDocumentType.dart';
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
import 'package:enreda_empresas/app/models/socialItineraryCycle.dart';
import 'package:enreda_empresas/app/models/specificinterest.dart';
import 'package:enreda_empresas/app/models/timeSearching.dart';
import 'package:enreda_empresas/app/models/timeSpentWeekly.dart';
import 'package:enreda_empresas/app/models/unemployedUser.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/models/scope_action.dart';
import 'package:enreda_empresas/app/home/resources/global.dart' as globals;
import 'package:enreda_empresas/app/services/api_path.dart';
import 'package:enreda_empresas/app/services/firestore_service.dart';
import 'package:enreda_empresas/app/services/resources_tracer.dart';
import 'package:enreda_empresas/app/models/resourcePicture.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/documentCategory.dart';
import '../models/externalSocialEntity.dart';
import 'package:enreda_empresas/app/models/program.dart';
import '../models/filterResource.dart';
import '../models/ipilCoordination.dart';
import '../models/ipilImprovementEmployment.dart';
import '../models/ipilObtainingEmployment.dart';
import '../models/socialEntitiesCategories.dart';
import '../models/sesion.dart';
import '../utils/functions.dart';

abstract class Database {
     Stream<List<Resource>> resourcesStream();
     Stream<List<Resource>> limitResourcesStream(int i);
     Stream<Resource> resourceStream(String? resourceId);
     Stream<List<Resource>> myResourcesStream(String socialEntityId);
     Stream<List<Resource>> myLimitResourcesStream(String socialEntityId, int i);
     Stream<List<Resource>> filteredMyResourcesStream(String socialEntityId, String searchText);
     Stream<List<Resource>> participantsResourcesStream(String? userId, String? organizerId);
     Stream<List<UserEnreda>> getParticipantsBySocialEntityStream(String socialEntityId, {int? limit});
     Stream<List<UserEnreda>> getParticipantsByProgramsStream(List<String> programs, {int? limit});
     Stream<List<UserEnreda>> getParticipantsByEntityStream(String socialEntityId);
     Stream<List<SocialEntity>> socialEntitiesStream();
     Stream<List<ExternalSocialEntity>> filteredExternalSocialEntitiesStream(FilterResource filter, String socialEntityId);
     Stream<List<SocialEntity>> socialEntityByIdStream(String socialEntityId);
     Stream<SocialEntity> socialEntityStream(String? socialEntityId);
     Stream<ExternalSocialEntity> externalSocialEntityByIdStream(String externalSocialEntityId);
     Stream<UserEnreda> mentorStream(String mentorId);
     Stream<UserEnreda?> userStreamByEmail(String? email);
     Stream<List<Country>> countriesStream();
     Stream<List<Region>> regionStreamByCountry(String countryId);
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
     Stream<List<Competency>> resourcesCompetenciesStream(List<String?> competenciesIdList);
     Stream<List<UserEnreda>> participantsByResourceStream(String resourceId);
     Stream<List<UserEnreda>> getSocialUsersByEntityId(String socialEntityId);
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
     Stream<List<CompetencySubCategory>> subCategoriesCompetenciesById(String? competencyId);
     Stream<List<Competency>> competenciesBySubCategoryId(String? competencySubCategoryId);
     Stream<List<UserEnreda>> checkIfUserEmailRegistered(String email);
     Stream<List<Experience>> myExperiencesStream(String userId);
     Stream<List<Competency>> competenciesStream();
     Stream<List<CompetencyCategory>> competenciesCategoriesStream();
     Stream<List<CompetencySubCategory>> competenciesSubCategoriesStream();
     Stream<List<CertificationRequest>> myCertificationRequestStream(String userId);
     Stream<List<SocialEntitiesType>> socialEntitiesTypeStream();
     Stream<List<SocialEntityCategory>> socialEntitiesCategoriesStream();
     Stream<List<DocumentCategory>> documentCategoriesStream();
     Stream<List<PersonalDocumentType>> personalDocumentTypeStream();
     Stream<List<PersonalDocumentType>> documentSubCategoriesByCategoryStream(String categoryId);
     Stream<List<DocumentationParticipant>> documentationParticipantBySubCategoryStream(PersonalDocumentType documentSubCategory, UserEnreda user);
     Stream<DocumentationParticipant> documentationParticipantStream(String documentId);
     Stream<List<DocumentationParticipant>> documentationParticipantByUserStream(String userId);
     Stream<List<UserEnreda>> filteredParticipantsStream(String filter, String socialEntityId);
     Stream<List<UserEnreda>> filteredParticipantsByProgramsStream(String filter, List<String> programs);
     Future<(List<UserEnreda>, DocumentSnapshot?)> getParticipantsByEntityPaginated(String socialEntityId, {int limit = 10, DocumentSnapshot? startAfterDocument});
     Future<(List<UserEnreda>, DocumentSnapshot?)> getParticipantsByProgramsPaginated(List<String> programs, {int limit = 10, DocumentSnapshot? startAfterDocument});


     Future<List<IpilReinforcement>> getIpilReinforcements(List<String?> idList);
     Future<List<IpilContextualization>> getIpilContextualizations(List<String?> idList);
     Future<List<IpilConnectionTerritory>> getIpilConnectionTerritories(List<String?> idList);
     Future<List<IpilInterviews>> getIpilInterviews(List<String?> idList);
     Future<List<IpilIntermediations>> getIpilIntermediations(List<String?> idList);
     Future<List<IpilObtainingEmployment>> getIpilObtainingEmployments(List<String?> idList);
     Future<List<IpilImprovingEmployment>> getIpilImprovingEmployments(List<String?> idList);
     Future<List<IpilCoordination>> getIpilCoordinations(List<String?> idList);
     Future<List<IpilLegal>> getIpilLegals(List<String?> idList);
     Future<List<IpilEconomicBag>> getIpilEconomicBags(List<String?> idList);
     Future<List<IpilSpecificSkills>> getIpilSpecificSkills(List<String?> idList);
     Future<List<IpilSoftSkills>> getIpilSoftSkills(List<String?> idList);
     Future<List<IpilDigitalSkills>> getIpilDigitalSkills(List<String?> idList);
     Future<List<IpilLaborSkills>> getIpilLaborSkills(List<String?> idList);
     Future<List<IpilPostWorkSupport>> getIpilPostWorkSupports(List<String?> idList);
     Future<List<IpilResults>> getIpilResults();
     Future<IpilObjectives?> getIpilObjectivesByUserId(String userId);

     Future<List<SpecificInterest>> getSpecificInterests();
     Future<void> setUserEnreda(UserEnreda userEnreda);
     Future<void> updateUserEnredaFields(String userId, Map<String, dynamic> fields);
     Future<void> deleteUser(UserEnreda userEnreda);
     Future<void> uploadUserAvatar(String userId, Uint8List data);
     Future<void> uploadLogoAvatar(String socialEntityId, Uint8List data);
     Future<void> addContact(Contact contact);
     Future<void> setResource(Resource resource);
     Future<void> setExternalSocialEntity(ExternalSocialEntity externalSocialEntity);
     Future<void> deleteResource(Resource resource);
     Future<void> deleteExternalSocialEntity(ExternalSocialEntity externalSocialEntity);
     Future<void> addSocialEntityUser(SocialEntityUser socialEntityUser);
     Future<void> addSocialEntity(SocialEntity socialEntity);
     Future<void> addExternalSocialEntity(ExternalSocialEntity externalSocialEntity);
     Future<void> addResource(Resource resource);
     Future<void> addResourceInvitation(ResourceInvitation resourceInvitation);
     Future<void> updateCertificationRequest(CertificationRequest certificationRequest, bool certified, bool referenced );
     Stream<List<GamificationFlag>> gamificationFlagsStream();
     Future<void> addUnemployedUser(UnemployedUser unemployedUser);
     Stream<List<Dedication>> dedicationStream();
     Stream<List<Gender>> genderStream();
     Stream<List<Program>> programsStream();
     Stream<List<TimeSpentWeekly>> timeSpentWeeklyStream();
     Stream<List<TimeSearching>> timeSearchingStream();
     Stream<List<IpilEntry>> getIpilEntriesByUserStream(String userId);
     Stream<IpilEntry> getIpilEntry(String ipilEntryId);
     Future<void> addIpilEntry(IpilEntry ipilEntry);
     Future<void> updateIpilEntryContent(IpilEntry ipilEntry, String content);
     Future<void> updateIpilEntryDate(IpilEntry ipilEntry, DateTime date);
     Future<void> deleteIpilEntry(IpilEntry ipilEntry);
     Future<void> setIpilEntry(IpilEntry ipilEntry);
     /// Removes any IpilEntry documents that were auto-created from the given
     /// session for the given participant. Used by the Sesion detail page
     /// when attendance is toggled off / marked absent to reverse the IPIL
     /// auto-creation. No-op when nothing matches.
     Future<void> deleteIpilEntriesBySesionAndUser(
         String sesionId, String userId);
     Future<void> addDocumentationParticipant(String userId, String fileName, Uint8List data, DocumentationParticipant document);
     Future<void> editFileDocumentationParticipant(String userId, String fileName, Uint8List data, DocumentationParticipant document);
     Future<void> updateDocumentationParticipant(DocumentationParticipant document);
     Stream<InitialReport> initialReportsStreamByUserId(String? userId);
     Stream<InitialReport?> initialReportStreamById(String? initialReportId);
     Future<void> setInitialReport(InitialReport initialReport);
     Future<String> addInitialReport(InitialReport initialReport);
     Stream<List<String>> languagesStream();
     Stream<List<String>> nationsSpanishStream();
     Stream<ClosureReport> closureReportsStreamByUserId(String? userId);
     Stream<ClosureReport?> closureReportStreamById(String? closureReportId);
     Future<void> setClosureReport(ClosureReport closureReport);
     Future<String> addClosureReport(ClosureReport closureReport);
     Stream<List<KeepLearningOption>> keepLearningOptionsStream();
     Stream<FollowReport> followReportsStreamByUserId(String? userId);
     Stream<FollowReport?> followReportStreamById(String? followReportId);
     Future<void> setFollowReport(FollowReport followReport);
     Future<String> addFollowReport(FollowReport followReport);
     Stream<DerivationReport> derivationReportsStreamByUserId(String? userId);
     Stream<DerivationReport?> derivationReportStreamById(String? derivationReportId);
     Future<void> setDerivationReport(DerivationReport derivationReport);
     Future<String> addDerivationReport(DerivationReport derivationReport);
     /// Archives the currently-active social-reports cycle into the user's
     /// `socialItineraryHistory` and clears the active pointers on the user doc
     /// so a new cycle can begin. IPIL pointers are left untouched so IPILs
     /// remain persistent and cross-cycle.
     Future<void> archiveItinerary(UserEnreda user, ClosureReport closureReport);
     Future<void> updateDerivationReportField(String derivationReportId, Map<String, dynamic> fieldsToUpdate);
     Stream<List<IpilReinforcement>> ipilReinforcementStream();
     Stream<List<IpilReinforcement>> ipilReinforcementStreamByUser(List<String> idList);
     Stream<List<IpilContextualization>> ipilContextualizationStream();
     Stream<List<IpilContextualization>> ipilContextualizationStreamByUser(List<String> idList);
     Stream<List<IpilConnectionTerritory>> ipilConnectionTerritoryStream();
     Stream<List<IpilConnectionTerritory>> ipilConnectionTerritoryStreamByUser(List<String> idList);
     Stream<List<IpilInterviews>> ipilInterviewsStream();
     Stream<List<IpilInterviews>> ipilInterviewsStreamByUser(List<String> idList);
     Stream<List<IpilIntermediations>> ipilIntermediationsStream();
     Stream<List<IpilIntermediations>> ipilIntermediationsStreamByUser(List<String> idList);
     Stream<List<IpilObtainingEmployment>> ipilObtainingEmploymentStream();
     Stream<List<IpilImprovingEmployment>> ipilImprovingEmploymentStream();
     Stream<List<IpilPostWorkSupport>> ipilPostWorkSupportStream();
     Stream<List<IpilCoordination>> ipilCoordinationStream();
     Stream<List<IpilObtainingEmployment>> ipilObtainingEmploymentStreamByUser(List<String> idList);
     Stream<List<IpilImprovingEmployment>> ipilImprovingEmploymentStreamByUser(List<String> idList);
     Stream<List<IpilCoordination>> ipilCoordinationStreamByUser(List<String> idList);
     Stream<List<IpilLegal>> ipilLegalStream();
     Stream<List<IpilLegal>> ipilLegalStreamByUser(List<String> idList);     
     Stream<List<IpilEconomicBag>> ipilEconomicBagStream();
     Stream<List<IpilEconomicBag>> ipilEconomicBagStreamByUser(List<String> idList);
     Stream<List<IpilPostWorkSupport>> ipilPostWorkSupportStreamByUser(List<String> idList);
     Stream<List<IpilSpecificSkills>> ipilSpecificSkillsStream();
     Stream<List<IpilSpecificSkills>> ipilSpecificSkillsStreamByUser(List<String> idList);
     Stream<List<IpilSoftSkills>> ipilSoftSkillsStream();
     Stream<List<IpilSoftSkills>> ipilSoftSkillsStreamByUser(List<String> idList);
     Stream<List<IpilDigitalSkills>> ipilDigitalSkillsStream();
     Stream<List<IpilDigitalSkills>> ipilDigitalSkillsStreamByUser(List<String> idList);
     Stream<List<IpilLaborSkills>> ipilLaborSkillsStream();
     Stream<List<IpilLaborSkills>> ipilLaborSkillsStreamByUser(List<String> idList);
     Stream<List<IpilResults>> ipilResultsStream();
     Stream<IpilObjectives> ipilObjectivesStreamByUserId(String userId);
     Future<void> setIpilObjectives(IpilObjectives ipilObjectives);
     Future<void> addIpilObjectives(IpilObjectives ipilObjectives);
     Future<void> deleteDocumentationParticipant(DocumentationParticipant document);
     Future<List<Competency>> getCompetencies();
     Future<List<Interest>> getInterests();
     Future<List<ScopeAction>> getScopeActions();
     Future<void> populateScopeActions();
     Future<List<Ability>> getAbilities();
     Future<SocialEntity?> getSocialEntity(String id);
     Future<UserEnreda?> getUser(String id);
     Future<City?> getCity(String id);
     Future<Province?> getProvince(String id);
     Future<InitialReport?> getInitialReport(String userId);
     Future<ClosureReport?> getClosureReport(String id);

     // Sesiones (admin dashboard) — new collection.
     // Both list streams MUST include a server-side `where()` filter on
     // socialEntityId AND a server-side date bucket on scheduledAt, plus
     // a hard `.limit()` per CLAUDE.md §4.5 read-guards.
     Stream<List<Sesion>> sesionesProximasStream(String socialEntityId);
     Stream<List<Sesion>> sesionesPasadasStream(String socialEntityId);
     Stream<Sesion> sesionStream(String sesionId);
     Future<void> addSesion(Sesion sesion);
     Future<void> setSesion(Sesion sesion);
     Future<void> deleteSesion(Sesion sesion);
     /// All sessions belonging to a specific técnico (for the calendar view).
     /// Filtered by both socialEntityId and tecnicoId; no date filter so the
     /// calendar can display past and upcoming sessions together.
     Stream<List<Sesion>> sesionesCalendarioStream(
         String socialEntityId, String tecnicoId);
}

class FirestoreDatabase implements Database {
  FirestoreDatabase();

  final _service = FirestoreService.instance;
  final Set<String> _pendingCreations = {};

  @override
  Future<void> setResource(Resource resource) {
    ResourcesTracer.logWrite(
      op: 'setResource',
      path: APIPath.resource(resource.resourceId!),
      params: {'resourceId': resource.resourceId},
    );
    return _service.updateData(
        path: APIPath.resource(resource.resourceId!), data: resource.toMap());
  }

  @override
  Future<void> deleteResource(Resource resource) {
    ResourcesTracer.logWrite(
      op: 'deleteResource',
      path: APIPath.resource(resource.resourceId!),
      params: {'resourceId': resource.resourceId},
    );
    return _service.deleteData(path: APIPath.resource(resource.resourceId!));
  }

  @override
  Future<void> deleteExternalSocialEntity(ExternalSocialEntity socialEntity) =>
      _service.deleteData(path: APIPath.externalSocialEntity(socialEntity.externalSocialEntityId!));

  @override
  Future<void> setExternalSocialEntity(ExternalSocialEntity externalSocialEntity) => _service.updateData(
      path: APIPath.externalSocialEntity(externalSocialEntity.externalSocialEntityId!), data: externalSocialEntity.toMap());

  @override
    Stream<List<Resource>> myResourcesStream(String socialEntityId) =>
        ResourcesTracer.traceStream<List<Resource>>(
          op: 'myResourcesStream',
          path: APIPath.resources(),
          params: {'organizer': socialEntityId},
          countOf: (list) => list.length,
          source: _service.collectionStream(
            path: APIPath.resources(),
            queryBuilder: (query) =>
                query.where('organizer', isEqualTo: socialEntityId),
            builder: (data, documentId) => Resource.fromMap(data, documentId),
            sort: (rhs, lhs) => lhs.createdate.compareTo(rhs.createdate),
          ),
        );

    @override
    Stream<List<Resource>> myLimitResourcesStream(String socialEntityId, int limit) =>
      ResourcesTracer.traceStream<List<Resource>>(
        op: 'myLimitResourcesStream',
        path: APIPath.resources(),
        params: {'organizer': socialEntityId, 'limit': limit},
        countOf: (list) => list.length,
        source: _service.collectionStream(
          path: APIPath.resources(),
          queryBuilder: (query) => query
              .where('organizer', isEqualTo: socialEntityId)
              .limit(limit),
          builder: (data, documentId) => Resource.fromMap(data, documentId),
          sort: (rhs, lhs) => lhs.createdate.compareTo(rhs.createdate),
        ),
      );

  @override
  Stream<List<Resource>> filteredMyResourcesStream(String socialEntityId, String searchText) {
    return ResourcesTracer.traceStream<List<Resource>>(
      op: 'filteredMyResourcesStream',
      path: APIPath.resources(),
      params: {'organizer': socialEntityId, 'searchText': searchText},
      countOf: (list) => list.length,
      source: _service.filteredCollectionStream(
        path: APIPath.resources(),
        queryBuilder: (query) => query.where('organizer', isEqualTo: socialEntityId),
        builder: (data, documentId) {
        final searchTextCommunity = removeDiacritics((data['searchText'] ?? '').toLowerCase());
        final searchListCommunity = searchTextCommunity.split(';');
        final searchTextFilter = removeDiacritics(searchText.toLowerCase());
        final searchListFilter = searchTextFilter.split(' ');

        if (searchText == '')
          return Resource.fromMap(data, documentId);

        // The following code checks if a resource is selected by applying filters
        bool textFilterSelection = false; // Initialize textFilter result to false

        // If search text exists in filter, filter through the search list
        if (searchText != '') {
          searchListFilter.forEach((filterElement) {
            // For each element in searchListFilter, check against each element in searchListIdea
            if (searchListCommunity.any(
                    (resourceElement) => resourceElement.contains(filterElement))) {
              textFilterSelection = textFilterSelection || true; // Set ideaSelected false if a match isn't found
            }
          });
        }
        return textFilterSelection ? Resource.fromMap(data, documentId) : null;
      },
      sort: (rhs, lhs) => lhs.createdate.compareTo(rhs.createdate),
      ),
    );
  }

  @override
    Stream<List<Resource>> participantsResourcesStream(String? userId, String? organizerId) =>
      ResourcesTracer.traceStream<List<Resource>>(
        op: 'participantsResourcesStream',
        path: APIPath.resources(),
        params: {'userId': userId, 'organizer': organizerId},
        countOf: (list) => list.length,
        source: _service.collectionStream(
          path: APIPath.resources(),
          queryBuilder: (query) {
                query = query.where('participants', arrayContains: userId ?? '').where('organizer', isEqualTo: organizerId);
                return query;
              },
          builder: (data, documentId) => Resource.fromMap(data, documentId),
          sort: (rhs, lhs) => lhs.createdate.compareTo(rhs.createdate),
        ),
      );

    @override
    Stream<Resource> resourceStream(String? resourceId) =>
        ResourcesTracer.traceStream<Resource>(
          op: 'resourceStream',
          path: APIPath.resource(resourceId ?? ''),
          params: {'resourceId': resourceId},
          source: _service.documentStream<Resource>(
            path: APIPath.resource(resourceId!),
            builder: (data, documentId) => Resource.fromMap(data, documentId),
          ),
        );

    @override
    Stream<List<Resource>> resourcesStream() =>
        ResourcesTracer.traceStream<List<Resource>>(
          op: 'resourcesStream',
          path: APIPath.resources(),
          params: {'organizerType': 'Entidad Social'},
          countOf: (list) => list.length,
          source: _service.collectionStream(
            path: APIPath.resources(),
            queryBuilder: (query) =>
                query.where('organizerType', isEqualTo: "Entidad Social"),
            builder: (data, documentId) => Resource.fromMap(data, documentId),
            sort: (lhs, rhs) => lhs.createdate.compareTo(rhs.createdate),
          ),
        );

  @override
  Stream<List<Resource>> limitResourcesStream(int limit) =>
      ResourcesTracer.traceStream<List<Resource>>(
        op: 'limitResourcesStream',
        path: APIPath.resources(),
        params: {'organizerType': 'Entidad Social', 'limit': limit},
        countOf: (list) => list.length,
        source: _service.collectionStream(
          path: APIPath.resources(),
          queryBuilder: (query) => query
              .where('organizerType', isEqualTo: "Entidad Social")
              .limit(limit),
          builder: (data, documentId) => Resource.fromMap(data, documentId),
          sort: (rhs, lhs) => lhs.createdate.compareTo(rhs.createdate),
        ),
      );

    @override
    Stream<List<SocialEntity>> socialEntitiesStream() => _service.collectionStream(
      path: APIPath.socialEntities(),
      queryBuilder: (query) => query.where('trust', isEqualTo: true),
      builder: (data, documentId) => SocialEntity.fromMap(data, documentId),
      sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
    );

  @override
  Stream<List<ExternalSocialEntity>> filteredExternalSocialEntitiesStream(FilterResource filter, String socialEntityId) {
    return _service.filteredCollectionStream(
      path: APIPath.externalSocialEntities(),
      queryBuilder: (query) {
        query = query.where('trust', isEqualTo: true).where('associatedSocialEntityId', isEqualTo: socialEntityId);
        return query;
      },
      builder: (data, documentId) {
        final searchTextChallenge = removeDiacritics((data['searchText'] ?? '').toLowerCase());
        final searchListPost = searchTextChallenge.split(';');
        final searchTextFilter = removeDiacritics(filter.searchText.toLowerCase());
        final searchListFilter = searchTextFilter.split(' ');
        Set<dynamic> postCategoriesSet = filter.externalSocialEntityTypesIds.toSet();

        if (filter.searchText == '' && postCategoriesSet.isEmpty)
          return ExternalSocialEntity.fromMap(data, documentId);

        // The following code checks if an idea is selected by applying filters
        bool textFilterSelection = false; // Initialize textFilter result to false
        bool tagsFilterSelection = false; // Initialize tagsFilter result to false

        // If search text exists in filter, filter through the search list
        if (filter.searchText != '') {
          searchListFilter.forEach((filterElement) {
            // For each element in searchListFilter, check against each element in searchListIdea
            if (searchListPost.any(
                    (resourceElement) => resourceElement.contains(filterElement))) {
              textFilterSelection = textFilterSelection || true; // Set ideaSelected false if a match isn't found
            }
          });
        }
        // If the intersection of selected ecosystem tags (filter.ideaEcosystems)
        // with the ideas' ecosystems (data['ecosystemsIdList']) is empty,
        // then ideaSelected is false
        if (postCategoriesSet.isNotEmpty) {
          Set<dynamic> postsCategoriesIdSet = [...data['types']].toSet();
          tagsFilterSelection = postsCategoriesIdSet
              .intersection(postCategoriesSet)
              .isNotEmpty;
        }
        return textFilterSelection || tagsFilterSelection ? ExternalSocialEntity.fromMap(data, documentId) : null;
      },
      sort: (rhs, lhs) => lhs.createdAt.compareTo(rhs.createdAt),
    );
  }

    @override
    Stream<List<SocialEntity>> socialEntityByIdStream(String socialEntityId) =>
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
  Stream<ExternalSocialEntity> externalSocialEntityByIdStream(String externalSocialEntityId) =>
      _service.documentStream<ExternalSocialEntity>(
        path: APIPath.externalSocialEntity(externalSocialEntityId),
        builder: (data, documentId) => ExternalSocialEntity.fromMap(data, documentId),
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
    Stream<List<Region>> regionStreamByCountry(String? countryId) {
      // int countryIdInt = 0;
      // if (countryId != '') {
      //   countryIdInt = int.parse(countryId!);
      // }
      // return _service.collectionStream<Region>(
      //   path: APIPath.regions(),
      //   builder: (data, documentId) => Region.fromMap(data, documentId),
      //   queryBuilder: (query) => query.where('country_id', isEqualTo:countryIdInt),
      //   sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
      // );
      int? countryIdInt; // Make it nullable since it can be null

      // This checks for both non-null and non-empty countryId before parsing
      if (countryId != null && countryId.isNotEmpty) {
        countryIdInt = int.tryParse(countryId);

        // Handle the case when parsing fails (e.g., if countryId is not a valid integer)
        if (countryIdInt == null) {
          throw FormatException('Invalid countryId: $countryId is not an integer');
        }
      }

      return _service.collectionStream<Region>(
        path: APIPath.regions(),
        builder: (data, documentId) => Region.fromMap(data, documentId),
        queryBuilder: (query) => query.where('country_id', isEqualTo: countryIdInt),
        sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
      );
    }

    @override
    Stream<List<Province>> provincesStream() => _service.collectionStream(
      path: APIPath.provinces(),
      builder: (data, documentId) => Province.fromMap(data, documentId),
      sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
    );

    @override
    Stream<Province> provinceStream(String? provinceId) =>
        _service.documentStream<Province>(
          path: APIPath.province(provinceId),
          builder: (data, documentId) => Province.fromMap(data, documentId),
        );

    // @override
    // Stream<List<Province>> provincesCountryStream(String? countryId) {
    //
    //   if (countryId == null) {
    //     return const Stream<List<Province>>.empty();
    //   }
    //
    //   return _service.collectionStream(
    //     path: APIPath.provinces(),
    //     builder: (data, documentId) => Province.fromMap(data, documentId),
    //     queryBuilder: (query) => query.where('id', isEqualTo: countryId),
    //     sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
    //   );
    // }

  @override
  Stream<List<Province>> provincesCountryStream(String? countryId) {

    if (countryId == null) {
      return const Stream<List<Province>>.empty();
    }

    return _service.collectionStream(
      path: APIPath.provinces(),
      builder: (data, documentId) => Province.fromMap(data, documentId),
      queryBuilder: (query) => query.where('countryId', isEqualTo: countryId).where('active', isEqualTo: true),
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
  Stream<List<UserEnreda>> getParticipantsBySocialEntityStream(String socialEntityId, {int? limit}) {
    return _service.collectionStream<UserEnreda>(
      path: APIPath.users(),
      queryBuilder: (query) {
        query = query.where('assignedEntityId', isEqualTo: socialEntityId);
        if (limit != null) query = query.limit(limit);
        return query;
      },
      builder: (data, documentId) => UserEnreda.fromMap(data, documentId),
      sort: (lhs, rhs) => (lhs.firstName??"").compareTo(rhs.firstName??""),
    );
  }

  @override
  Stream<List<UserEnreda>> getParticipantsByProgramsStream(List<String> programs, {int? limit}) {
    if (programs.isEmpty) {
      return Stream.value([]);
    }
    return _service.collectionStream<UserEnreda>(
      path: APIPath.users(),
      queryBuilder: (query) {
        query = query.where('programId', whereIn: programs.take(30).toList());
        if (limit != null) query = query.limit(limit);
        return query;
      },
      builder: (data, documentId) => UserEnreda.fromMap(data, documentId),
      sort: (lhs, rhs) => (lhs.firstName??"").compareTo(rhs.firstName??""),
    );
  }

  @override
  Stream<List<UserEnreda>> getParticipantsByEntityStream(String socialEntityId) {
    return _service.collectionStream<UserEnreda>(
      path: APIPath.users(),
      queryBuilder: (query) => query.where('assignedEntityId', isEqualTo: socialEntityId),
      builder: (data, documentId) => UserEnreda.fromMap(data, documentId),
      sort: (lhs, rhs) => (lhs.firstName??"").compareTo(rhs.firstName??""),
    );
  }

  @override
  Future<(List<UserEnreda>, DocumentSnapshot?)> getParticipantsByEntityPaginated(String socialEntityId, {int limit = 10, DocumentSnapshot? startAfterDocument}) {
    return _service.paginatedCollectionGet<UserEnreda>(
      path: APIPath.users(),
      queryBuilder: (query) => query.where('assignedEntityId', isEqualTo: socialEntityId),
      builder: (data, documentId, snapshot) => UserEnreda.fromMap(data, documentId),
      limit: limit,
      startAfterDocument: startAfterDocument,
    );
  }

  @override
  Future<(List<UserEnreda>, DocumentSnapshot?)> getParticipantsByProgramsPaginated(List<String> programs, {int limit = 10, DocumentSnapshot? startAfterDocument}) {
    if (programs.isEmpty) {
      return Future.value((<UserEnreda>[], null));
    }
    return _service.paginatedCollectionGet<UserEnreda>(
      path: APIPath.users(),
      queryBuilder: (query) => query.where('programId', whereIn: programs.take(10).toList()),
      builder: (data, documentId, snapshot) => UserEnreda.fromMap(data, documentId),
      limit: limit,
      startAfterDocument: startAfterDocument,
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
  Stream<List<UserEnreda>> getSocialUsersByEntityId(String socialEntityId) {
    return _service.collectionStream<UserEnreda>(
      path: APIPath.users(),
      queryBuilder: (query) => query
          .where('role', isEqualTo: 'Entidad Social')
          .where('socialEntityId', isEqualTo: socialEntityId),
      builder: (data, documentId) => UserEnreda.fromMap(data, documentId),
    );
  }

  @override
  Stream<List<Resource>> resourcesParticipantsStream(List<String?> participantsIdList) {
    return ResourcesTracer.traceStream<List<Resource>>(
      op: 'resourcesParticipantsStream',
      path: APIPath.resources(),
      params: {'participantsCount': participantsIdList.length},
      countOf: (list) => list.length,
      source: _service.collectionStream<Resource>(
        path: APIPath.resources(),
        queryBuilder: (query) =>
            query.where('participants', arrayContainsAny: participantsIdList),
        builder: (data, documentId) => Resource.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.title.compareTo(rhs.title),
      ),
    );
  }

  @override
  Stream<List<Interest>> resourcesInterestsStream(List<String?> interestsIdList) async* {
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.interests());
    final batches = <Future<List<Interest>>>[];

    for (var i = 0; i < interestsIdList.length; i += 10) {
      final batch = interestsIdList.sublist(i, i + 10 < interestsIdList.length ? i + 10 : interestsIdList.length);
      final futureBatch = collectionPath
          .where('interestId', whereIn: batch)
          .get()
          .then((results) => results.docs.map<Interest>((result) => Interest.fromMap(result.data(), result.id)).toList());
      batches.add(futureBatch);
    }
    final results = await Future.wait(batches);
    var combinedResults = results.expand((i) => i).toSet().toList();
    yield combinedResults;
  }

  @override
  Stream<List<Competency>> resourcesCompetenciesStream(List<String?> competenciesIdList) async* {
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.competencies());
    final batches = <Future<List<Competency>>>[];

    for (var i = 0; i < competenciesIdList.length; i += 10) {
      final batch = competenciesIdList.sublist(i, i + 10 < competenciesIdList.length ? i + 10 : competenciesIdList.length);
      final futureBatch = collectionPath
          .where('id', whereIn: batch)
          .get()
          .then((results) => results.docs.map<Competency>((result) => Competency.fromMap(result.data(), result.id)).toList());
      batches.add(futureBatch);
    }
    final results = await Future.wait(batches);
    var combinedResults = results.expand((i) => i).toSet().toList();
    yield combinedResults;
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
    Stream<List<SocialEntityCategory>> socialEntitiesCategoriesStream() => _service.collectionStream(
      path: APIPath.socialEntitiesCategories(),
      queryBuilder: (query) => query.where('socialEntityCategoryId', isNotEqualTo: null),
      builder: (data, documentId) => SocialEntityCategory.fromMap(data, documentId),
      sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
    );

    @override
    Future<void> setUserEnreda(UserEnreda userEnreda) {
      return _service.updateData(
          path: APIPath.user(userEnreda.userId!), data: userEnreda.toMap());
    }

    @override
    Future<void> updateUserEnredaFields(
        String userId, Map<String, dynamic> fields) {
      // Surgical update for UserEnreda: only the keys provided are written.
      // Use this instead of `setUserEnreda` whenever the in-memory UserEnreda
      // object could be stale (e.g. after `archiveItinerary` mutated the
      // Firestore doc), because `setUserEnreda` writes the full `toMap()` and
      // would otherwise overwrite freshly-archived state.
      return _service.updateData(
          path: APIPath.user(userId), data: fields);
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
  Stream<List<PersonalDocumentType>> documentSubCategoriesByCategoryStream(String? categoryId) =>
      _service.collectionStream(
        path: APIPath.personalDocumentType(),
        queryBuilder: (query) =>
            query.where('documentCategoryId', isEqualTo: categoryId),
        builder: (data, documentId) =>
            PersonalDocumentType.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
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
  Future<void> uploadLogoAvatar(String socialEntityId, Uint8List data) async {
    var firebaseStorageRef =
    FirebaseStorage.instance.ref().child('externalSocialEntities/$socialEntityId/logoPic');
    UploadTask uploadTask = firebaseStorageRef.putData(data);
    TaskSnapshot taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then(
          (value) => {
        _service.updateData(path: APIPath.externalSocialEntity(socialEntityId), data: {
          "logoPic": {
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
  Future<void> addExternalSocialEntity(ExternalSocialEntity externalSocialEntity) => _service.addData(
      path: APIPath.externalSocialEntities(), data: externalSocialEntity.toMap());

  @override
  Future<void> addSocialEntityUser(SocialEntityUser socialEntityUser) =>
      _service.addData(path: APIPath.users(), data: socialEntityUser.toMap());

  @override
  Future<void> addResourceInvitation(ResourceInvitation resourceInvitation) =>
      _service.addData(path: APIPath.resourcesInvitations(), data: resourceInvitation.toMap());

  @override
  Future<void> addResource(Resource resource) {
    ResourcesTracer.logWrite(
      op: 'addResource',
      path: APIPath.resources(),
      params: {'organizer': resource.organizer, 'title': resource.title},
    );
    return _service.addData(
        path: APIPath.resources(), data: resource.toMap());
  }


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
        sort: (lhs, rhs) => (rhs.startDate?? Timestamp.fromMicrosecondsSinceEpoch(0))
            .compareTo(lhs.startDate?? Timestamp.fromMicrosecondsSinceEpoch(0)),
      );

  @override
  Stream<List<Competency>> competenciesStream() => _service.collectionStream(
    path: APIPath.competencies(),
    builder: (data, documentId) => Competency.fromMap(data, documentId),
    queryBuilder: (query) => query.where('name', isNotEqualTo: null),
    sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
  );

  @override
  Stream<List<CompetencyCategory>> competenciesCategoriesStream() => _service.collectionStream(
    path: APIPath.competenciesCategories(),
    builder: (data, documentId) => CompetencyCategory.fromMap(data, documentId),
    queryBuilder: (query) => query,
    sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
  );

  @override
  Stream<List<CompetencySubCategory>> competenciesSubCategoriesStream() => _service.collectionStream(
    path: APIPath.competenciesSubCategories(),
    builder: (data, documentId) => CompetencySubCategory.fromMap(data, documentId),
    queryBuilder: (query) => query,
    sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
  );

  @override
  Stream<List<CompetencySubCategory>> subCategoriesCompetenciesById(String? competencyCategoryId) =>
      _service.collectionStream(
        path: APIPath.competenciesSubCategories(),
        queryBuilder: (query) =>
            query.where('competencyCategoryId', isEqualTo: competencyCategoryId),
        builder: (data, documentId) =>
            CompetencySubCategory.fromMap(data, documentId),
        sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
      );

  @override
  Stream<List<Competency>> competenciesBySubCategoryId(String? competencySubCategoryId) =>
      _service.collectionStream(
        path: APIPath.competencies(),
        queryBuilder: (query) =>
            query.where('competencySubCategoryId', isEqualTo: competencySubCategoryId),
        builder: (data, documentId) =>
            Competency.fromMap(data, documentId),
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
  Stream<List<Program>> programsStream() => _service.collectionStream(
    path: APIPath.programs(),
    builder: (data, documentId) => Program.fromMap(data, documentId),
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
      sort: (lhs, rhs) => (rhs.lastUpdateDate ?? rhs.date).compareTo(lhs.lastUpdateDate ?? lhs.date),
    );
  }

  @override
  Stream<IpilEntry> getIpilEntry(String ipilEntryId) {
    return _service.documentStreamByField(
      path: APIPath.ipilEntry(),
      builder: (data, documentId) => IpilEntry.fromMap(data, documentId),
      queryBuilder: (query) => query.where(FieldPath.documentId, isEqualTo: ipilEntryId),
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

  @override
  Future<void> setIpilEntry(IpilEntry ipilEntry) {
    return _service.updateData(
        path: APIPath.ipilEntryById(ipilEntry.ipilId!), data: ipilEntry.toMap());
  }

  @override
  Future<void> deleteIpilEntriesBySesionAndUser(
      String sesionId, String userId) async {
    if (sesionId.isEmpty || userId.isEmpty) return;
    // Two equality filters — Firestore handles this with the auto-generated
    // single-field indexes (no composite index required).
    final snapshot = await FirebaseFirestore.instance
        .collection(APIPath.ipilEntry())
        .where('sesionId', isEqualTo: sesionId)
        .where('userId', isEqualTo: userId)
        .get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // ── Sesiones (admin dashboard) ───────────────────────────────────────────
  // Read-guards (CLAUDE.md §4.5):
  //   * server-side `where('socialEntityId', isEqualTo: ...)` on every query
  //   * server-side `where('scheduledAt', ...)` to bucket Próximas/Pasadas
  //   * hard `.limit(50)` cap on every list stream

  @override
  Stream<List<Sesion>> sesionesProximasStream(String socialEntityId) {
    return _service.collectionStream<Sesion>(
      path: APIPath.sesiones(),
      queryBuilder: (query) => query
          .where('socialEntityId', isEqualTo: socialEntityId)
          .where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.now())
          .orderBy('scheduledAt', descending: false)
          .limit(50),
      builder: (data, documentId) => Sesion.fromMap(data, documentId),
      sort: (lhs, rhs) => lhs.scheduledAt.compareTo(rhs.scheduledAt),
    );
  }

  @override
  Stream<List<Sesion>> sesionesPasadasStream(String socialEntityId) {
    return _service.collectionStream<Sesion>(
      path: APIPath.sesiones(),
      queryBuilder: (query) => query
          .where('socialEntityId', isEqualTo: socialEntityId)
          .where('scheduledAt', isLessThan: Timestamp.now())
          .orderBy('scheduledAt', descending: true)
          .limit(50),
      builder: (data, documentId) => Sesion.fromMap(data, documentId),
      // Most-recent-past first
      sort: (lhs, rhs) => rhs.scheduledAt.compareTo(lhs.scheduledAt),
    );
  }

  @override
  Stream<Sesion> sesionStream(String sesionId) {
    return _service.documentStreamByField(
      path: APIPath.sesiones(),
      builder: (data, documentId) => Sesion.fromMap(data, documentId),
      queryBuilder: (query) =>
          query.where(FieldPath.documentId, isEqualTo: sesionId),
    );
  }

  @override
  Future<void> addSesion(Sesion sesion) =>
      _service.addData(path: APIPath.sesiones(), data: sesion.toMap());

  @override
  Future<void> setSesion(Sesion sesion) {
    return _service.updateData(
      path: APIPath.sesion(sesion.sesionId!),
      data: sesion.toMap(),
    );
  }

  @override
  Future<void> deleteSesion(Sesion sesion) =>
      _service.deleteData(path: APIPath.sesion(sesion.sesionId!));

  @override
  Stream<List<Sesion>> sesionesCalendarioStream(
      String socialEntityId, String tecnicoId) {
    // Calendar shows every entity GROUP session (any técnico) plus the
    // logged-in técnica's own sessions (group + individual); other técnicos'
    // individual sessions stay private. Single equality filter keeps it
    // index-free; the grupal/own narrowing + scheduledAt sort run client-side.
    // ponytail: entity-wide limit(200) instead of a per-técnico 100 — bump if a
    // busy entity ever exceeds it within a viewed month.
    return _service
        .collectionStream<Sesion>(
          path: APIPath.sesionesCalendario(),
          queryBuilder: (query) => query
              .where('socialEntityId', isEqualTo: socialEntityId)
              .limit(200),
          builder: (data, documentId) => Sesion.fromMap(data, documentId),
          sort: (lhs, rhs) => lhs.scheduledAt.compareTo(rhs.scheduledAt),
        )
        .map((sesiones) => sesiones
            .where((s) =>
                s.sessionType == SesionType.grupal || s.tecnicoId == tecnicoId)
            .toList());
  }

  @override
  Stream<List<PersonalDocumentType>> personalDocumentTypeStream() => _service.collectionStream(
    path: APIPath.personalDocumentType(),
    queryBuilder: (query) => query.where('personalDocId', isNotEqualTo: null),
    builder: (data, documentId) => PersonalDocumentType.fromMap(data, documentId),
    sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
  );

  @override
  Stream<List<DocumentCategory>> documentCategoriesStream() => _service.collectionStream(
    path: APIPath.documentCategories(),
    queryBuilder: (query) => query.where('name', isNotEqualTo: null),
    builder: (data, documentId) => DocumentCategory.fromMap(data, documentId),
    sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
  );

  @override
  Stream<List<DocumentationParticipant>> documentationParticipantBySubCategoryStream(PersonalDocumentType documentSubCategory, UserEnreda user) => _service.collectionStream(
    path: APIPath.documentationParticipants(),
    queryBuilder: (query) => query.where('userId', isEqualTo: user.userId)
        .where('documentSubCategoryId', isEqualTo: documentSubCategory.personalDocId),
    builder: (data, documentId) => DocumentationParticipant.fromMap(data, documentId),
    sort: (lhs, rhs) => lhs.name.compareTo(rhs.name),
  );

  @override
  Stream<List<DocumentationParticipant>> documentationParticipantByUserStream(String userId) => _service.collectionStream(
    path: APIPath.documentationParticipants(),
    queryBuilder: (query) => query.where('userId', isEqualTo: userId),
    builder: (data, documentId) => DocumentationParticipant.fromMap(data, documentId),
  );

  @override
  Stream<DocumentationParticipant> documentationParticipantStream(String documentId) =>
      _service.documentStream<DocumentationParticipant>(
        path: APIPath.oneDocumentationParticipant(documentId),
        builder: (data, documentId) => DocumentationParticipant.fromMap(data, documentId),
      );

  @override
  Future<void> addDocumentationParticipant(String userId, String fileName, Uint8List data, DocumentationParticipant document) async {
    var firebaseStorageRef =
    FirebaseStorage.instance.ref().child('users/$userId/files/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putData(data);
    TaskSnapshot taskSnapshot = await uploadTask;
    await taskSnapshot.ref.getDownloadURL().then(
       (value) {
        _service.addDataFile(path: APIPath.documentationParticipants(), data: {
          "file": {
            'src': '$value',
            'title': '$fileName',
          },
          "userId": userId,
          "name": document.name,
          "createDate": document.createDate,
          "renovationDate": document.renovationDate,
          "documentCategoryId": document.documentCategoryId,
          "documentSubCategoryId": document.documentSubCategoryId,
          "createdBy": document.createdBy
        },).then((value) => _service.updateData(
            path: APIPath.oneDocumentationParticipant(value),
            data: {
              "documentationParticipantId": value,
            })
        );
      },
    );
  }

  @override
  Future<void> editFileDocumentationParticipant(String userId, String fileName, Uint8List data, DocumentationParticipant document) async {
    try {
      var firebaseStorageRef = FirebaseStorage.instance.ref().child('users/$userId/files/$fileName');
      UploadTask uploadTask = firebaseStorageRef.putData(data);

      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      await _service.updateData(
        path: APIPath.oneDocumentationParticipant(document.documentationParticipantId!),
        data: {
          "file": {
            'src': '$downloadUrl',
            'title': '$fileName',
          },
          "name": document.name,
          "createDate": document.createDate,
          "renovationDate": document.renovationDate,
        }
      );    
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  @override
  Future<void> updateDocumentationParticipant(DocumentationParticipant document) => _service.updateData(
      path: APIPath.oneDocumentationParticipant(document.documentationParticipantId!), data: document.toMap());

  @override
  Future<void> deleteDocumentationParticipant(DocumentationParticipant document) =>
      _service.deleteData(path: APIPath.oneDocumentationParticipant(document.documentationParticipantId!));

  @override
  Stream<InitialReport> initialReportsStreamByUserId(String? userId) {
    return _service.documentStreamByField(
      path: APIPath.initialReports(),
      builder: (data, documentId) => InitialReport.fromMap(data, documentId),
      queryBuilder: (query) => query.where('userId', isEqualTo: userId),
    );
  }

  @override
  Stream<InitialReport?> initialReportStreamById(String? initialReportId) {
    if (initialReportId == null || initialReportId.isEmpty) {
      return _emptyBroadcastStream<InitialReport?>();
    }
    return FirebaseFirestore.instance
        .doc(APIPath.initialReport(initialReportId))
        .snapshots()
        .map<InitialReport?>((snap) {
      final data = snap.data();
      if (data == null) return null;
      return InitialReport.fromMap(data, snap.id);
    });
  }

  @override
  Future<void> setInitialReport(InitialReport initialReport) {
    return _service.updateData(
        path: APIPath.initialReport(initialReport.initialReportId!), data: initialReport.toMap());
  }

  @override
  Future<String> addInitialReport(InitialReport initialReport) async {
    final lockKey = '${initialReport.userId}_initial';
    if (_pendingCreations.contains(lockKey)) return '';
    _pendingCreations.add(lockKey);

    try {
      return await _service.addDataFile(path: APIPath.initialReports(), data: initialReport.toMap());
    } catch (e) {
      print('Error adding initial report: $e');
      rethrow;
    } finally {
      _pendingCreations.remove(lockKey);
    }
  }

  @override
  Stream<List<String>> languagesStream() => _service.collectionStream(
    path: APIPath.languages(),
    queryBuilder: (query) => query.where('name', isNotEqualTo: null),
    builder: (data, documentId) => data['name'].toString(),
    sort: (lhs, rhs) => lhs.compareTo(rhs),
  );

  @override
  Stream<List<String>> nationsSpanishStream() => _service.collectionStream(
    path: APIPath.nations(),
    queryBuilder: (query) => query.where('name', isNotEqualTo: null),
    builder: (data, documentId) => data['translations']['es'].toString(),
    sort: (lhs, rhs) => lhs.compareTo(rhs),
  );

  @override
  Stream<ClosureReport> closureReportsStreamByUserId(String? userId) {
    return _service.documentStreamByField(
      path: APIPath.closureReports(),
      builder: (data, documentId) => ClosureReport.fromMap(data, documentId),
      queryBuilder: (query) => query.where('userId', isEqualTo: userId),
    );
  }

  @override
  Stream<ClosureReport?> closureReportStreamById(String? closureReportId) {
    if (closureReportId == null || closureReportId.isEmpty) {
      return _emptyBroadcastStream<ClosureReport?>();
    }
    return FirebaseFirestore.instance
        .doc(APIPath.closureReport(closureReportId))
        .snapshots()
        .map<ClosureReport?>((snap) {
      final data = snap.data();
      if (data == null) return null;
      return ClosureReport.fromMap(data, snap.id);
    });
  }

  @override
  Future<void> setClosureReport(ClosureReport closureReport) {
    return _service.updateData(
        path: APIPath.closureReport(closureReport.closureReportId!), data: closureReport.toMap());
  }

  @override
  Future<String> addClosureReport(ClosureReport closureReport) async {
    final lockKey = '${closureReport.userId}_closure';
    if (_pendingCreations.contains(lockKey)) return '';
    _pendingCreations.add(lockKey);

    try {
      return await _service.addDataFile(path: APIPath.closureReports(), data: closureReport.toMap());
    } catch (e) {
      print('Error adding closure report: $e');
      rethrow;
    } finally {
      _pendingCreations.remove(lockKey);
    }
  }

  @override
  Stream<List<KeepLearningOption>> keepLearningOptionsStream() => _service.collectionStream(
    path: APIPath.keepLearningOptions(),
    queryBuilder: (query) => query.where('title', isNotEqualTo: null),
    builder: (data, documentId) => KeepLearningOption.fromMap(data, documentId),
    sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
  );

  @override
  Stream<FollowReport> followReportsStreamByUserId(String? userId) {
    return _service.documentStreamByField(
      path: APIPath.followReports(),
      builder: (data, documentId) => FollowReport.fromMap(data, documentId),
      queryBuilder: (query) => query.where('userId', isEqualTo: userId),
    );
  }

  @override
  Stream<FollowReport?> followReportStreamById(String? followReportId) {
    if (followReportId == null || followReportId.isEmpty) {
      return _emptyBroadcastStream<FollowReport?>();
    }
    return FirebaseFirestore.instance
        .doc(APIPath.followReport(followReportId))
        .snapshots()
        .map<FollowReport?>((snap) {
      final data = snap.data();
      if (data == null) return null;
      return FollowReport.fromMap(data, snap.id);
    });
  }

  @override
  Future<void> setFollowReport(FollowReport followReport) {
    return _service.updateData(
        path: APIPath.followReport(followReport.followReportId!), data: followReport.toMap());
  }

  @override
  Future<String> addFollowReport(FollowReport followReport) async {
    final lockKey = '${followReport.userId}_follow';
    if (_pendingCreations.contains(lockKey)) return '';
    _pendingCreations.add(lockKey);

    try {
      return await _service.addDataFile(path: APIPath.followReports(), data: followReport.toMap());
    } catch (e) {
      print('Error adding follow report: $e');
      rethrow;
    } finally {
      _pendingCreations.remove(lockKey);
    }
  }

  @override
  Stream<DerivationReport> derivationReportsStreamByUserId(String? userId) {
    return _service.documentStreamByField(
      path: APIPath.derivationReports(),
      builder: (data, documentId) => DerivationReport.fromMap(data, documentId),
      queryBuilder: (query) => query.where('userId', isEqualTo: userId),
    );
  }

  @override
  Stream<DerivationReport?> derivationReportStreamById(
      String? derivationReportId) {
    if (derivationReportId == null || derivationReportId.isEmpty) {
      return _emptyBroadcastStream<DerivationReport?>();
    }
    return FirebaseFirestore.instance
        .doc(APIPath.derivationReport(derivationReportId))
        .snapshots()
        .map<DerivationReport?>((snap) {
      final data = snap.data();
      if (data == null) return null;
      return DerivationReport.fromMap(data, snap.id);
    });
  }

  /// A safe, reusable broadcast stream for "no id / no report yet" cases.
  /// StreamBuilder treats the absence of emissions as `snapshot.data == null`,
  /// which is the semantic we want. Broadcast semantics guarantee we can hand
  /// this stream to any number of StreamBuilders / rebuilds without hitting
  /// `Bad state: Stream has already been listened to`.
  static final Stream<dynamic> _nullBroadcastStream =
      StreamController<dynamic>.broadcast().stream;

  Stream<T?> _emptyBroadcastStream<T>() => _nullBroadcastStream.cast<T?>();

  @override
  Future<void> setDerivationReport(DerivationReport derivationReport) {
    return _service.updateData(
        path: APIPath.derivationReport(derivationReport.derivationReportId!), data: derivationReport.toMap());
  }

  @override
  Future<String> addDerivationReport(DerivationReport derivationReport) async {
    final lockKey = '${derivationReport.userId}_derivation';
    if (_pendingCreations.contains(lockKey)) return '';
    _pendingCreations.add(lockKey);

    try {
      return await _service.addDataFile(path: APIPath.derivationReports(), data: derivationReport.toMap());
    } catch (e) {
      print('Error adding derivation report: $e');
      rethrow;
    } finally {
      _pendingCreations.remove(lockKey);
    }
  }

  @override
  Future<void> updateDerivationReportField(String derivationReportId, Map<String, dynamic> fieldsToUpdate) {
    return _service.updateData(
      path: APIPath.derivationReport(derivationReportId),
      data: fieldsToUpdate,
    );
  }


  @override
  Stream<List<IpilReinforcement>> ipilReinforcementStreamByUser(List<String?> reinforcementIdList) async* {
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilReinforcement());
    final batches = <Future<List<IpilReinforcement>>>[];

    for (var i = 0; i < reinforcementIdList.length; i += 10) {
      final batch = reinforcementIdList.sublist(i, i + 10 < reinforcementIdList.length ? i + 10 : reinforcementIdList.length);
      final futureBatch = collectionPath
          .where('ipilReinforcementId', whereIn: batch)
          .get()
          .then((results) => results.docs.map<IpilReinforcement>((result) => IpilReinforcement.fromMap(result.data(), result.id)).toList());
      batches.add(futureBatch);
    }
    final results = await Future.wait(batches);
    var combinedResults = results.expand((i) => i).toSet().toList();
    yield combinedResults;
  }

  @override
  Stream<List<IpilContextualization>> ipilContextualizationStreamByUser(List<String?> contextualizationIdList) async* {
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilContextualization());
    final batches = <Future<List<IpilContextualization>>>[];

    for (var i = 0; i < contextualizationIdList.length; i += 10) {
      final batch = contextualizationIdList.sublist(i, i + 10 < contextualizationIdList.length ? i + 10 : contextualizationIdList.length);
      final futureBatch = collectionPath
          .where('ipilContextualizationId', whereIn: batch)
          .get()
          .then((results) => results.docs.map<IpilContextualization>((result) => IpilContextualization.fromMap(result.data(), result.id)).toList());
      batches.add(futureBatch);
    }
    final results = await Future.wait(batches);
    var combinedResults = results.expand((i) => i).toSet().toList();
    yield combinedResults;
  }

  @override
  Stream<List<IpilConnectionTerritory>> ipilConnectionTerritoryStreamByUser(List<String?> connectionTerritoryIdList) async* {
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilConnectionTerritory());
    final batches = <Future<List<IpilConnectionTerritory>>>[];

    for (var i = 0; i < connectionTerritoryIdList.length; i += 10) {
      final batch = connectionTerritoryIdList.sublist(i, i + 10 < connectionTerritoryIdList.length ? i + 10 : connectionTerritoryIdList.length);
      final futureBatch = collectionPath
          .where('ipilConnectionTerritoryId', whereIn: batch)
          .get()
          .then((results) => results.docs.map<IpilConnectionTerritory>((result) => IpilConnectionTerritory.fromMap(result.data(), result.id)).toList());
      batches.add(futureBatch);
    }
    final results = await Future.wait(batches);
    var combinedResults = results.expand((i) => i).toSet().toList();
    yield combinedResults;
  }

  @override
  Stream<List<IpilInterviews>> ipilInterviewsStreamByUser(List<String?> interviewsIdList) async* {
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilInterviews());
    final batches = <Future<List<IpilInterviews>>>[];

    for (var i = 0; i < interviewsIdList.length; i += 10) {
      final batch = interviewsIdList.sublist(i, i + 10 < interviewsIdList.length ? i + 10 : interviewsIdList.length);
      final futureBatch = collectionPath
          .where('ipilInterviewsId', whereIn: batch)
          .get()
          .then((results) => results.docs.map<IpilInterviews>((result) => IpilInterviews.fromMap(result.data(), result.id)).toList());
      batches.add(futureBatch);
    }
    final results = await Future.wait(batches);
    var combinedResults = results.expand((i) => i).toSet().toList();
    yield combinedResults;
  }

  @override
  Stream<List<IpilIntermediations>> ipilIntermediationsStreamByUser(List<String?> intermediationsIdList) async* {
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilIntermediations());
    final batches = <Future<List<IpilIntermediations>>>[];

    for (var i = 0; i < intermediationsIdList.length; i += 10) {
      final batch = intermediationsIdList.sublist(i, i + 10 < intermediationsIdList.length ? i + 10 : intermediationsIdList.length);
      final futureBatch = collectionPath
          .where('ipilIntermediationsId', whereIn: batch)
          .get()
          .then((results) => results.docs.map<IpilIntermediations>((result) => IpilIntermediations.fromMap(result.data(), result.id)).toList());
      batches.add(futureBatch);
    }
    final results = await Future.wait(batches);
    var combinedResults = results.expand((i) => i).toSet().toList();
    yield combinedResults;
  }

  @override
  Stream<List<IpilLegal>> ipilLegalStreamByUser(List<String?> legalsIdList) async* {
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilLegal());
    final batches = <Future<List<IpilLegal>>>[];

    for (var i = 0; i < legalsIdList.length; i += 10) {
      final batch = legalsIdList.sublist(i, i + 10 < legalsIdList.length ? i + 10 : legalsIdList.length);
      final futureBatch = collectionPath
          .where('ipilLegalId', whereIn: batch)
          .get()
          .then((results) => results.docs.map<IpilLegal>((result) => IpilLegal.fromMap(result.data(), result.id)).toList());
      batches.add(futureBatch);
    }
    final results = await Future.wait(batches);
    var combinedResults = results.expand((i) => i).toSet().toList();
    yield combinedResults;
  }

  @override
  Stream<List<IpilEconomicBag>> ipilEconomicBagStreamByUser(List<String?> economicBagIdList) async* {
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilEconomicBag());
    final batches = <Future<List<IpilEconomicBag>>>[];

    for (var i = 0; i < economicBagIdList.length; i += 10) {
      final batch = economicBagIdList.sublist(i, i + 10 < economicBagIdList.length ? i + 10 : economicBagIdList.length);
      final futureBatch = collectionPath
          .where('ipilEconomicBagId', whereIn: batch)
          .get()
          .then((results) => results.docs.map<IpilEconomicBag>((result) => IpilEconomicBag.fromMap(result.data(), result.id)).toList());
      batches.add(futureBatch);
    }
    final results = await Future.wait(batches);
    var combinedResults = results.expand((i) => i).toSet().toList();
    yield combinedResults;
  }

  @override
  Stream<List<IpilReinforcement>> ipilReinforcementStream() => _service.collectionStream(
    path: APIPath.ipilReinforcement(),
    builder: (data, documentId) => IpilReinforcement.fromMap({...data, 'ipilReinforcementId': data['ipilReinforcementId'] ?? documentId}, documentId),
    sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
  );

  @override
  Stream<List<IpilContextualization>> ipilContextualizationStream() => _service.collectionStream(
    path: APIPath.ipilContextualization(),
    builder: (data, documentId) => IpilContextualization.fromMap({...data, 'ipilContextualizationId': data['ipilContextualizationId'] ?? documentId}, documentId),
    sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
  );

  @override
  Stream<List<IpilConnectionTerritory>> ipilConnectionTerritoryStream() => _service.collectionStream(
    path: APIPath.ipilConnectionTerritory(),
    builder: (data, documentId) => IpilConnectionTerritory.fromMap({...data, 'ipilConnectionTerritoryId': data['ipilConnectionTerritoryId'] ?? documentId}, documentId),
    sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
  );

  @override
  Stream<List<IpilInterviews>> ipilInterviewsStream() => _service.collectionStream(
    path: APIPath.ipilInterviews(),
    builder: (data, documentId) => IpilInterviews.fromMap({...data, 'ipilInterviewsId': data['ipilInterviewsId'] ?? documentId}, documentId),
    sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
  );

  @override
  Stream<List<IpilIntermediations>> ipilIntermediationsStream() => _service.collectionStream(
    path: APIPath.ipilIntermediations(),
    builder: (data, documentId) => IpilIntermediations.fromMap({...data, 'ipilIntermediationsId': data['ipilIntermediationsId'] ?? documentId}, documentId),
    sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
  );

  @override
  Stream<List<IpilObtainingEmployment>> ipilObtainingEmploymentStream() => _service.collectionStream(
    path: APIPath.ipilObtainingEmployment(),
    builder: (data, documentId) => IpilObtainingEmployment.fromMap({...data, 'ipilObtainingEmploymentId': data['ipilObtainingEmploymentId'] ?? documentId}, documentId),
    sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
  );

  @override
  Stream<List<IpilLegal>> ipilLegalStream() => _service.collectionStream(
    path: APIPath.ipilLegal(),
    builder: (data, documentId) => IpilLegal.fromMap({...data, 'ipilLegalId': data['ipilLegalId'] ?? documentId}, documentId),
    sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
  );

  @override
  Stream<List<IpilEconomicBag>> ipilEconomicBagStream() => _service.collectionStream(
    path: APIPath.ipilEconomicBag(),
    builder: (data, documentId) => IpilEconomicBag.fromMap({...data, 'ipilEconomicBagId': data['ipilEconomicBagId'] ?? documentId}, documentId),
    sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
  );

  @override
  Stream<List<IpilObtainingEmployment>> ipilObtainingEmploymentStreamByUser(List<String?> obtainingEmploymentIdList) async* {
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilObtainingEmployment());
    final batches = <Future<List<IpilObtainingEmployment>>>[];

    for (var i = 0; i < obtainingEmploymentIdList.length; i += 10) {
      final batch = obtainingEmploymentIdList.sublist(i, i + 10 < obtainingEmploymentIdList.length ? i + 10 : obtainingEmploymentIdList.length);
      final futureBatch = collectionPath
          .where('ipilObtainingEmploymentId', whereIn: batch)
          .get()
          .then((results) => results.docs.map<IpilObtainingEmployment>((result) => IpilObtainingEmployment.fromMap(result.data(), result.id)).toList());
      batches.add(futureBatch);
    }
    final results = await Future.wait(batches);
    var combinedResults = results.expand((i) => i).toSet().toList();
    yield combinedResults;
  }

  @override
  Stream<List<IpilImprovingEmployment>> ipilImprovingEmploymentStream() => _service.collectionStream(
    path: APIPath.ipilImprovingEmployment(),
    builder: (data, documentId) => IpilImprovingEmployment.fromMap({...data, 'ipilImprovingEmploymentId': data['ipilImprovingEmploymentId'] ?? documentId}, documentId),
    sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
  );

  @override
  Stream<List<IpilImprovingEmployment>> ipilImprovingEmploymentStreamByUser(List<String?> improvingEmploymentIdList) async* {
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilImprovingEmployment());
    final batches = <Future<List<IpilImprovingEmployment>>>[];

    for (var i = 0; i < improvingEmploymentIdList.length; i += 10) {
      final batch = improvingEmploymentIdList.sublist(i, i + 10 < improvingEmploymentIdList.length ? i + 10 : improvingEmploymentIdList.length);
      final futureBatch = collectionPath
          .where('ipilImprovingEmploymentId', whereIn: batch)
          .get()
          .then((results) => results.docs.map<IpilImprovingEmployment>((result) => IpilImprovingEmployment.fromMap(result.data(), result.id)).toList());
      batches.add(futureBatch);
    }
    final results = await Future.wait(batches);
    var combinedResults = results.expand((i) => i).toSet().toList();
    yield combinedResults;
  }

  @override
  Stream<List<IpilPostWorkSupport>> ipilPostWorkSupportStream() => _service.collectionStream(
    path: APIPath.ipilPostWorkSupport(),
    builder: (data, documentId) => IpilPostWorkSupport.fromMap({...data, 'ipilPostWorkSupportId': data['ipilPostWorkSupportId'] ?? documentId}, documentId),
    sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
  );

  @override
  Stream<List<IpilPostWorkSupport>> ipilPostWorkSupportStreamByUser(List<String?> postWorkSupportIdList) async* {
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilPostWorkSupport());
    final batches = <Future<List<IpilPostWorkSupport>>>[];

    for (var i = 0; i < postWorkSupportIdList.length; i += 10) {
      final batch = postWorkSupportIdList.sublist(i, i + 10 < postWorkSupportIdList.length ? i + 10 : postWorkSupportIdList.length);
      final futureBatch = collectionPath
          .where('ipilPostWorkSupportId', whereIn: batch)
          .get()
          .then((results) => results.docs.map<IpilPostWorkSupport>((result) => IpilPostWorkSupport.fromMap(result.data(), result.id)).toList());
      batches.add(futureBatch);
    }
    final results = await Future.wait(batches);
    var combinedResults = results.expand((i) => i).toSet().toList();
    yield combinedResults;
  }

  @override
  Stream<List<IpilSpecificSkills>> ipilSpecificSkillsStream() => _service.collectionStream(
    path: APIPath.ipilSpecificSkills(),
    builder: (data, documentId) => IpilSpecificSkills.fromMap({...data, 'ipilSpecificSkillsId': data['ipilSpecificSkillsId'] ?? documentId}, documentId),
    sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
  );

  @override
  Stream<List<IpilSpecificSkills>> ipilSpecificSkillsStreamByUser(List<String?> specificSkillsIdList) async* {
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilSpecificSkills());
    final batches = <Future<List<IpilSpecificSkills>>>[];

    for (var i = 0; i < specificSkillsIdList.length; i += 10) {
      final batch = specificSkillsIdList.sublist(i, i + 10 < specificSkillsIdList.length ? i + 10 : specificSkillsIdList.length);
      final futureBatch = collectionPath
          .where('ipilSpecificSkillsId', whereIn: batch)
          .get()
          .then((results) => results.docs.map<IpilSpecificSkills>((result) => IpilSpecificSkills.fromMap(result.data(), result.id)).toList());
      batches.add(futureBatch);
    }
    final results = await Future.wait(batches);
    var combinedResults = results.expand((i) => i).toSet().toList();
    yield combinedResults;
  }

  @override
  Stream<List<IpilSoftSkills>> ipilSoftSkillsStream() => _service.collectionStream(
    path: APIPath.ipilSoftSkills(),
    builder: (data, documentId) => IpilSoftSkills.fromMap({...data, 'ipilSoftSkillsId': data['ipilSoftSkillsId'] ?? documentId}, documentId),
    sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
  );

  @override
  Stream<List<IpilSoftSkills>> ipilSoftSkillsStreamByUser(List<String?> softSkillsIdList) async* {
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilSoftSkills());
    final batches = <Future<List<IpilSoftSkills>>>[];

    for (var i = 0; i < softSkillsIdList.length; i += 10) {
      final batch = softSkillsIdList.sublist(i, i + 10 < softSkillsIdList.length ? i + 10 : softSkillsIdList.length);
      final futureBatch = collectionPath
          .where('ipilSoftSkillsId', whereIn: batch)
          .get()
          .then((results) => results.docs.map<IpilSoftSkills>((result) => IpilSoftSkills.fromMap(result.data(), result.id)).toList());
      batches.add(futureBatch);
    }
    final results = await Future.wait(batches);
    var combinedResults = results.expand((i) => i).toSet().toList();
    yield combinedResults;
  }

  @override
  Stream<List<IpilDigitalSkills>> ipilDigitalSkillsStream() => _service.collectionStream(
    path: APIPath.ipilDigitalSkills(),
    builder: (data, documentId) => IpilDigitalSkills.fromMap({...data, 'ipilDigitalSkillsId': data['ipilDigitalSkillsId'] ?? documentId}, documentId),
    sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
  );

  @override
  Stream<List<IpilDigitalSkills>> ipilDigitalSkillsStreamByUser(List<String?> digitalSkillsIdList) async* {
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilDigitalSkills());
    final batches = <Future<List<IpilDigitalSkills>>>[];

    for (var i = 0; i < digitalSkillsIdList.length; i += 10) {
      final batch = digitalSkillsIdList.sublist(i, i + 10 < digitalSkillsIdList.length ? i + 10 : digitalSkillsIdList.length);
      final futureBatch = collectionPath
          .where('ipilDigitalSkillsId', whereIn: batch)
          .get()
          .then((results) => results.docs.map<IpilDigitalSkills>((result) => IpilDigitalSkills.fromMap(result.data(), result.id)).toList());
      batches.add(futureBatch);
    }
    final results = await Future.wait(batches);
    var combinedResults = results.expand((i) => i).toSet().toList();
    yield combinedResults;
  }

  @override
  Stream<List<IpilLaborSkills>> ipilLaborSkillsStream() => _service.collectionStream(
    path: APIPath.ipilLaborSkills(),
    builder: (data, documentId) => IpilLaborSkills.fromMap({...data, 'ipilLaborSkillsId': data['ipilLaborSkillsId'] ?? documentId}, documentId),
    sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
  );

  @override
  Stream<List<IpilLaborSkills>> ipilLaborSkillsStreamByUser(List<String?> laborSkillsIdList) async* {
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilLaborSkills());
    final batches = <Future<List<IpilLaborSkills>>>[];

    for (var i = 0; i < laborSkillsIdList.length; i += 10) {
      final batch = laborSkillsIdList.sublist(i, i + 10 < laborSkillsIdList.length ? i + 10 : laborSkillsIdList.length);
      final futureBatch = collectionPath
          .where('ipilLaborSkillsId', whereIn: batch)
          .get()
          .then((results) => results.docs.map<IpilLaborSkills>((result) => IpilLaborSkills.fromMap(result.data(), result.id)).toList());
      batches.add(futureBatch);
    }
    final results = await Future.wait(batches);
    var combinedResults = results.expand((i) => i).toSet().toList();
    yield combinedResults;
  }

  @override
  Stream<List<IpilCoordination>> ipilCoordinationStream() => _service.collectionStream(
    path: APIPath.ipilCoordination(),
    builder: (data, documentId) => IpilCoordination.fromMap({...data, 'ipilCoordinationId': data['ipilCoordinationId'] ?? documentId}, documentId),
    sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
  );

  @override
  Stream<List<IpilCoordination>> ipilCoordinationStreamByUser(List<String?> coordinationIdList) async* {
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilCoordination());
    final batches = <Future<List<IpilCoordination>>>[];

    for (var i = 0; i < coordinationIdList.length; i += 10) {
      final batch = coordinationIdList.sublist(i, i + 10 < coordinationIdList.length ? i + 10 : coordinationIdList.length);
      final futureBatch = collectionPath
          .where('ipilCoordinationId', whereIn: batch)
          .get()
          .then((results) => results.docs.map<IpilCoordination>((result) => IpilCoordination.fromMap(result.data(), result.id)).toList());
      batches.add(futureBatch);
    }
    final results = await Future.wait(batches);
    var combinedResults = results.expand((i) => i).toSet().toList();
    yield combinedResults;
  }

  @override
  Stream<List<IpilResults>> ipilResultsStream() => _service.collectionStream(
    path: APIPath.ipilResults(),
    builder: (data, documentId) => IpilResults.fromMap({...data, 'ipilResultsId': data['ipilResultsId'] ?? documentId}, documentId),
    sort: (lhs, rhs) => lhs.order.compareTo(rhs.order),
  );

  @override
  Stream<IpilObjectives> ipilObjectivesStreamByUserId(String userId) {
    return _service.documentStreamByField(
      path: APIPath.ipilObjectives(),
      builder: (data, documentId) => IpilObjectives.fromMap(data, documentId),
      queryBuilder: (query) => query.where('userId', isEqualTo: userId),
    );
  }

  @override
  Future<void> setIpilObjectives(IpilObjectives ipilObjectives) {
    return _service.updateData(
        path: APIPath.ipilObjective(ipilObjectives.ipilObjectivesId!), data: ipilObjectives.toMap());
  }

  @override
  Future<void> addIpilObjectives(IpilObjectives ipilObjectives) async {
      await _service.addData(path: APIPath.ipilObjectives(), data: ipilObjectives.toMap());
  }

  @override
  Stream<List<UserEnreda>> filteredParticipantsStream(String filter, String socialEntityId) {
    return _service.filteredCollectionStream(
      path: APIPath.users(),
      queryBuilder: (query) {
        query = query.where('assignedEntityId', isEqualTo: socialEntityId);
        return query;
      },
      builder: (data, documentId) {
        final firstName = data['firstName'] ?? '';
        final lastName = data['lastName'] ?? '';
        final email = data['email'] ?? '';
        final searchTextChallenge = removeDiacritics((firstName + ';' + lastName + ';' + email).toLowerCase());
        final searchListPost = searchTextChallenge.split(';');
        final searchTextFilter = removeDiacritics(filter.toLowerCase());
        final searchListFilter = searchTextFilter.split(' ');
        //Set<dynamic> postCategoriesSet = filter.externalSocialEntityTypesIds.toSet();

        if (filter == '')
          return UserEnreda.fromMap(data, documentId);

        // The following code checks if an idea is selected by applying filters
        bool textFilterSelection = false; // Initialize textFilter result to false
        bool tagsFilterSelection = false; // Initialize tagsFilter result to false

        // If search text exists in filter, filter through the search list
        if (filter != '') {
          searchListFilter.forEach((filterElement) {
            // For each element in searchListFilter, check against each element in searchListIdea
            if (searchListPost.any(
                    (resourceElement) => resourceElement.contains(filterElement))) {
              textFilterSelection = textFilterSelection || true; // Set ideaSelected false if a match isn't found
            }
          });
        }
        return textFilterSelection || tagsFilterSelection ? UserEnreda.fromMap(data, documentId) : null;
      },
      sort: (rhs, lhs) => lhs.firstName!.compareTo(rhs.firstName!),
    );
  }
  @override
  Stream<List<UserEnreda>> filteredParticipantsByProgramsStream(String filter, List<String> programs) {
    if (programs.isEmpty) {
      return Stream.value([]);
    }
    return _service.filteredCollectionStream(
      path: APIPath.users(),
      queryBuilder: (query) {
        query = query.where('programId', whereIn: programs.take(30).toList());
        return query;
      },
      builder: (data, documentId) {
        final firstName = data['firstName'] ?? '';
        final lastName = data['lastName'] ?? '';
        final email = data['email'] ?? '';
        final searchTextChallenge = removeDiacritics((firstName + ';' + lastName + ';' + email).toLowerCase());
        final searchListPost = searchTextChallenge.split(';');
        final searchTextFilter = removeDiacritics(filter.toLowerCase());
        final searchListFilter = searchTextFilter.split(' ');

        if (filter == '')
          return UserEnreda.fromMap(data, documentId);

        bool textFilterSelection = false;

        if (filter != '') {
          searchListFilter.forEach((filterElement) {
            if (searchListPost.any(
                    (resourceElement) => resourceElement.contains(filterElement))) {
              textFilterSelection = textFilterSelection || true;
            }
          });
        }
        return textFilterSelection ? UserEnreda.fromMap(data, documentId) : null;
      },
      sort: (rhs, lhs) => lhs.firstName!.compareTo(rhs.firstName!),
    );
  }

  @override
  Future<List<Competency>> getCompetencies() => _service.getCollection(
    path: APIPath.competencies(),
    builder: (data, documentId) => Competency.fromMap(data, documentId),
    limit: 1000,
  );

  @override
  Future<List<Interest>> getInterests() => _service.getCollection(
    path: APIPath.interests(),
    builder: (data, documentId) => Interest.fromMap(data, documentId),
    limit: 1000,
  );

  @override
  Future<List<ScopeAction>> getScopeActions() => _service.getCollection(
    path: APIPath.scopeActions(),
    builder: (data, documentId) => ScopeAction.fromMap(data, documentId),
    limit: 1000,
  );

  @override
  Future<void> populateScopeActions() async {
    final List<String> staticOptions = ['Juventud', 'Migraciones', 'Género', 'Colectivo LGBTIQ+', 'Salud mental', 'Familia', 'Menores', 'Ocio y tiempo libre', 'Diversidad funcional', 'Educación-Formación', 'Inserción sociolaboral', 'Dependencia', 'Deporte', 'Comunidad y participación sociocomunitaria', 'Violencia de género', 'Asociación cultural', 'Asociación vecinal'];
    final collection = FirebaseFirestore.instance.collection(APIPath.scopeActions());
    for (var option in staticOptions) {
      final docRef = collection.doc();
      await docRef.set({
        'id': docRef.id,
        'name': option,
      });
    }
  }

  @override
  Future<List<Ability>> getAbilities() => _service.getCollection(
    path: APIPath.abilities(),
    builder: (data, documentId) => Ability.fromMap(data, documentId),
    limit: 1000,
  );

  @override
  Future<SocialEntity?> getSocialEntity(String id) => _service.getDocument(
    path: APIPath.socialEntity(id),
    builder: (data, documentId) => SocialEntity.fromMap(data, documentId),
  );

  @override
  Future<UserEnreda?> getUser(String id) => _service.getDocument(
    path: APIPath.user(id),
    builder: (data, documentId) => UserEnreda.fromMap(data, documentId),
  );

  @override
  Future<City?> getCity(String id) => _service.getDocument(
    path: APIPath.city(id),
    builder: (data, documentId) => City.fromMap(data, documentId),
  );

  @override
  Future<Province?> getProvince(String id) => _service.getDocument(
    path: APIPath.province(id),
    builder: (data, documentId) => Province.fromMap(data, documentId),
  );

  @override
  Future<List<IpilReinforcement>> getIpilReinforcements(List<String?> idList) async {
    if (idList.isEmpty) return [];
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilReinforcement());
    final batches = <Future<List<IpilReinforcement>>>[];
    for (var i = 0; i < idList.length; i += 10) {
      final batch = idList.sublist(i, i + 10 < idList.length ? i + 10 : idList.length);
      batches.add(collectionPath.where('ipilReinforcementId', whereIn: batch).get().then((res) => res.docs.map((d) => IpilReinforcement.fromMap(d.data(), d.id)).toList()));
    }
    final results = await Future.wait(batches);
    return results.expand((i) => i).toList();
  }

  @override
  Future<List<IpilContextualization>> getIpilContextualizations(List<String?> idList) async {
    if (idList.isEmpty) return [];
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilContextualization());
    final batches = <Future<List<IpilContextualization>>>[];
    for (var i = 0; i < idList.length; i += 10) {
      final batch = idList.sublist(i, i + 10 < idList.length ? i + 10 : idList.length);
      batches.add(collectionPath.where('ipilContextualizationId', whereIn: batch).get().then((res) => res.docs.map((d) => IpilContextualization.fromMap(d.data(), d.id)).toList()));
    }
    final results = await Future.wait(batches);
    return results.expand((i) => i).toList();
  }

  @override
  Future<List<IpilConnectionTerritory>> getIpilConnectionTerritories(List<String?> idList) async {
    if (idList.isEmpty) return [];
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilConnectionTerritory());
    final batches = <Future<List<IpilConnectionTerritory>>>[];
    for (var i = 0; i < idList.length; i += 10) {
      final batch = idList.sublist(i, i + 10 < idList.length ? i + 10 : idList.length);
      batches.add(collectionPath.where('ipilConnectionTerritoryId', whereIn: batch).get().then((res) => res.docs.map((d) => IpilConnectionTerritory.fromMap(d.data(), d.id)).toList()));
    }
    final results = await Future.wait(batches);
    return results.expand((i) => i).toList();
  }

  @override
  Future<List<IpilInterviews>> getIpilInterviews(List<String?> idList) async {
    if (idList.isEmpty) return [];
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilInterviews());
    final batches = <Future<List<IpilInterviews>>>[];
    for (var i = 0; i < idList.length; i += 10) {
      final batch = idList.sublist(i, i + 10 < idList.length ? i + 10 : idList.length);
      batches.add(collectionPath.where('ipilInterviewsId', whereIn: batch).get().then((res) => res.docs.map((d) => IpilInterviews.fromMap(d.data(), d.id)).toList()));
    }
    final results = await Future.wait(batches);
    return results.expand((i) => i).toList();
  }

  @override
  Future<List<IpilIntermediations>> getIpilIntermediations(List<String?> idList) async {
    if (idList.isEmpty) return [];
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilIntermediations());
    final batches = <Future<List<IpilIntermediations>>>[];
    for (var i = 0; i < idList.length; i += 10) {
      final batch = idList.sublist(i, i + 10 < idList.length ? i + 10 : idList.length);
      batches.add(collectionPath.where('ipilIntermediationsId', whereIn: batch).get().then((res) => res.docs.map((d) => IpilIntermediations.fromMap(d.data(), d.id)).toList()));
    }
    final results = await Future.wait(batches);
    return results.expand((i) => i).toList();
  }

  @override
  Future<List<IpilObtainingEmployment>> getIpilObtainingEmployments(List<String?> idList) async {
    if (idList.isEmpty) return [];
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilObtainingEmployment());
    final batches = <Future<List<IpilObtainingEmployment>>>[];
    for (var i = 0; i < idList.length; i += 10) {
      final batch = idList.sublist(i, i + 10 < idList.length ? i + 10 : idList.length);
      batches.add(collectionPath.where('ipilObtainingEmploymentId', whereIn: batch).get().then((res) => res.docs.map((d) => IpilObtainingEmployment.fromMap(d.data(), d.id)).toList()));
    }
    final results = await Future.wait(batches);
    return results.expand((i) => i).toList();
  }

  @override
  Future<List<IpilImprovingEmployment>> getIpilImprovingEmployments(List<String?> idList) async {
    if (idList.isEmpty) return [];
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilImprovingEmployment());
    final batches = <Future<List<IpilImprovingEmployment>>>[];
    for (var i = 0; i < idList.length; i += 10) {
      final batch = idList.sublist(i, i + 10 < idList.length ? i + 10 : idList.length);
      batches.add(collectionPath.where('ipilImprovingEmploymentId', whereIn: batch).get().then((res) => res.docs.map((d) => IpilImprovingEmployment.fromMap(d.data(), d.id)).toList()));
    }
    final results = await Future.wait(batches);
    return results.expand((i) => i).toList();
  }

  @override
  Future<List<IpilCoordination>> getIpilCoordinations(List<String?> idList) async {
    if (idList.isEmpty) return [];
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilCoordination());
    final batches = <Future<List<IpilCoordination>>>[];
    for (var i = 0; i < idList.length; i += 10) {
      final batch = idList.sublist(i, i + 10 < idList.length ? i + 10 : idList.length);
      batches.add(collectionPath.where('ipilCoordinationId', whereIn: batch).get().then((res) => res.docs.map((d) => IpilCoordination.fromMap(d.data(), d.id)).toList()));
    }
    final results = await Future.wait(batches);
    return results.expand((i) => i).toList();
  }

  @override
  Future<List<IpilLegal>> getIpilLegals(List<String?> idList) async {
    if (idList.isEmpty) return [];
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilLegal());
    final batches = <Future<List<IpilLegal>>>[];
    for (var i = 0; i < idList.length; i += 10) {
      final batch = idList.sublist(i, i + 10 < idList.length ? i + 10 : idList.length);
      batches.add(collectionPath.where('ipilLegalId', whereIn: batch).get().then((res) => res.docs.map((d) => IpilLegal.fromMap(d.data(), d.id)).toList()));
    }
    final results = await Future.wait(batches);
    return results.expand((i) => i).toList();
  }

  @override
  Future<List<IpilEconomicBag>> getIpilEconomicBags(List<String?> idList) async {
    if (idList.isEmpty) return [];
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilEconomicBag());
    final batches = <Future<List<IpilEconomicBag>>>[];
    for (var i = 0; i < idList.length; i += 10) {
      final batch = idList.sublist(i, i + 10 < idList.length ? i + 10 : idList.length);
      batches.add(collectionPath.where('ipilEconomicBagId', whereIn: batch).get().then((res) => res.docs.map((d) => IpilEconomicBag.fromMap(d.data(), d.id)).toList()));
    }
    final results = await Future.wait(batches);
    return results.expand((i) => i).toList();
  }

  @override
  Future<List<IpilSpecificSkills>> getIpilSpecificSkills(List<String?> idList) async {
    if (idList.isEmpty) return [];
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilSpecificSkills());
    final batches = <Future<List<IpilSpecificSkills>>>[];
    for (var i = 0; i < idList.length; i += 10) {
      final batch = idList.sublist(i, i + 10 < idList.length ? i + 10 : idList.length);
      batches.add(collectionPath.where('ipilSpecificSkillsId', whereIn: batch).get().then((res) => res.docs.map((d) => IpilSpecificSkills.fromMap(d.data(), d.id)).toList()));
    }
    final results = await Future.wait(batches);
    return results.expand((i) => i).toList();
  }

  @override
  Future<List<IpilSoftSkills>> getIpilSoftSkills(List<String?> idList) async {
    if (idList.isEmpty) return [];
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilSoftSkills());
    final batches = <Future<List<IpilSoftSkills>>>[];
    for (var i = 0; i < idList.length; i += 10) {
      final batch = idList.sublist(i, i + 10 < idList.length ? i + 10 : idList.length);
      batches.add(collectionPath.where('ipilSoftSkillsId', whereIn: batch).get().then((res) => res.docs.map((d) => IpilSoftSkills.fromMap(d.data(), d.id)).toList()));
    }
    final results = await Future.wait(batches);
    return results.expand((i) => i).toList();
  }

  @override
  Future<List<IpilDigitalSkills>> getIpilDigitalSkills(List<String?> idList) async {
    if (idList.isEmpty) return [];
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilDigitalSkills());
    final batches = <Future<List<IpilDigitalSkills>>>[];
    for (var i = 0; i < idList.length; i += 10) {
      final batch = idList.sublist(i, i + 10 < idList.length ? i + 10 : idList.length);
      batches.add(collectionPath.where('ipilDigitalSkillsId', whereIn: batch).get().then((res) => res.docs.map((d) => IpilDigitalSkills.fromMap(d.data(), d.id)).toList()));
    }
    final results = await Future.wait(batches);
    return results.expand((i) => i).toList();
  }

  @override
  Future<List<IpilLaborSkills>> getIpilLaborSkills(List<String?> idList) async {
    if (idList.isEmpty) return [];
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilLaborSkills());
    final batches = <Future<List<IpilLaborSkills>>>[];
    for (var i = 0; i < idList.length; i += 10) {
      final batch = idList.sublist(i, i + 10 < idList.length ? i + 10 : idList.length);
      batches.add(collectionPath.where('ipilLaborSkillsId', whereIn: batch).get().then((res) => res.docs.map((d) => IpilLaborSkills.fromMap(d.data(), d.id)).toList()));
    }
    final results = await Future.wait(batches);
    return results.expand((i) => i).toList();
  }

  @override
  Future<List<IpilPostWorkSupport>> getIpilPostWorkSupports(List<String?> idList) async {
    if (idList.isEmpty) return [];
    final collectionPath = FirebaseFirestore.instance.collection(APIPath.ipilPostWorkSupport());
    final batches = <Future<List<IpilPostWorkSupport>>>[];
    for (var i = 0; i < idList.length; i += 10) {
      final batch = idList.sublist(i, i + 10 < idList.length ? i + 10 : idList.length);
      batches.add(collectionPath.where('ipilPostWorkSupportId', whereIn: batch).get().then((res) => res.docs.map((d) => IpilPostWorkSupport.fromMap(d.data(), d.id)).toList()));
    }
    final results = await Future.wait(batches);
    return results.expand((i) => i).toList();
  }

  @override
  Future<List<IpilResults>> getIpilResults() => _service.getCollection(
    path: APIPath.ipilResults(),
    builder: (data, documentId) => IpilResults.fromMap(data, documentId),
    limit: 1000,
  );

  @override
  Future<IpilObjectives?> getIpilObjectivesByUserId(String userId) async {
    final objectives = await _service.getCollection(
      path: APIPath.ipilObjectives(),
      queryBuilder: (q) => q.where('userId', isEqualTo: userId),
      builder: (data, documentId) => IpilObjectives.fromMap(data, documentId),
      limit: 1,
    );
    return objectives.isNotEmpty ? objectives.first : null;
  }

  @override
  Future<List<SpecificInterest>> getSpecificInterests() => _service.getCollection(
    path: APIPath.specificInterests(),
    builder: (data, documentId) => SpecificInterest.fromMap(data, documentId),
    limit: 1000,
  );

  @override
  Future<InitialReport?> getInitialReport(String userId) async {
    final reports = await _service.getCollection(
      path: APIPath.initialReports(),
      queryBuilder: (q) => q.where('userId', isEqualTo: userId),
      builder: (data, documentId) => InitialReport.fromMap(data, documentId),
      limit: 1,
    );
    return reports.isNotEmpty ? reports.first : null;
  }

  @override
  Future<ClosureReport?> getClosureReport(String id) => _service.getDocument(
    path: APIPath.closureReport(id),
    builder: (data, documentId) => ClosureReport.fromMap(data, documentId),
  );

  @override
  Future<void> archiveItinerary(
      UserEnreda user, ClosureReport closureReport) async {
    if (user.userId == null || user.userId!.isEmpty) {
      throw StateError('archiveItinerary: user.userId is required');
    }

    final cycle = SocialItineraryCycle(
      initialReportId: user.initialReportId,
      followReportId: user.followReportId,
      derivationReportId: user.derivationReportId,
      closureReportId: user.closureReportId,
      startDate: user.startDateItinerary,
      closureDate: closureReport.completedDate,
      programId: user.programId,
      archivedAt: DateTime.now(),
    );

    final Map<String, dynamic> archiveUpdate = <String, dynamic>{
      'initialReportId': null,
      'followReportId': null,
      'derivationReportId': null,
      'closureReportId': null,
      'startDateItinerary': null,
      'socialItineraryHistory': FieldValue.arrayUnion([cycle.toMap()]),
    };

    await _service.updateData(
      path: APIPath.user(user.userId!),
      data: archiveUpdate,
    );

    user.initialReportId = null;
    user.followReportId = null;
    user.derivationReportId = null;
    user.closureReportId = null;
    user.startDateItinerary = null;
    user.socialItineraryHistory = [
      ...user.socialItineraryHistory,
      cycle,
    ];

    globals.currentInitialReportUser = InitialReport();
    globals.currentFollowReportUser = FollowReport();
    globals.currentDerivationReportUser = DerivationReport();
    globals.currentClosureReportUser = ClosureReport();
  }
}


