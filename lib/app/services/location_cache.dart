import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enreda_empresas/app/services/persistence_service.dart';
import 'package:enreda_empresas/app/models/city.dart';
import 'package:enreda_empresas/app/models/country.dart';
import 'package:enreda_empresas/app/models/gamificationFlags.dart';
import 'package:enreda_empresas/app/models/province.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/models/competency.dart';
import 'package:enreda_empresas/app/models/interest.dart';
import 'package:enreda_empresas/app/models/ability.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
import 'package:enreda_empresas/app/models/specificinterest.dart';
import 'package:enreda_empresas/app/models/socialEntitiesType.dart';
import 'package:enreda_empresas/app/models/ipilReinforcement.dart';
import 'package:enreda_empresas/app/models/ipilContextualization.dart';
import 'package:enreda_empresas/app/models/ipilConnectionTerritory.dart';
import 'package:enreda_empresas/app/models/ipilInterviews.dart';
import 'package:enreda_empresas/app/models/ipilIntermediations.dart';
import 'package:enreda_empresas/app/models/ipilObtainingEmployment.dart';
import 'package:enreda_empresas/app/models/ipilImprovementEmployment.dart';
import 'package:enreda_empresas/app/models/ipilPostWorkSupport.dart';
import 'package:enreda_empresas/app/models/ipilCoordination.dart';
import 'package:enreda_empresas/app/models/ipilLegal.dart';
import 'package:enreda_empresas/app/models/ipilEconomicBag.dart';
import 'package:enreda_empresas/app/models/ipilSpecificSkills.dart';
import 'package:enreda_empresas/app/models/ipilSoftSkills.dart';
import 'package:enreda_empresas/app/models/ipilDigitalSkills.dart';
import 'package:enreda_empresas/app/models/ipilLaborSkills.dart';
import 'package:enreda_empresas/app/models/experience.dart';
import 'package:enreda_empresas/app/models/education.dart';
import 'package:enreda_empresas/app/models/resource.dart';
import 'package:enreda_empresas/app/models/personalDocumentType.dart';
import 'package:enreda_empresas/app/models/gender.dart';
import 'package:enreda_empresas/app/models/dedication.dart';
import 'package:enreda_empresas/app/models/keepLearningOption.dart';
import 'package:enreda_empresas/app/models/documentCategory.dart';
import 'package:enreda_empresas/app/services/database.dart';

class LocationCache {
  LocationCache._();
  static final LocationCache instance = LocationCache._();

  Future<void>? _warmUpFuture;

  List<Country> countries = [];
  List<Province> provinces = [];
  List<City> cities = [];
  List<GamificationFlag> gamificationFlags = [];
  List<Competency> competencies = [];
  List<Interest> interests = [];
  List<Ability> abilities = [];
  List<SpecificInterest> specificInterests = [];
  List<SocialEntitiesType> socialEntitiesTypes = [];

  // IPIL Master Data
  List<IpilReinforcement> ipilReinforcements = [];
  List<IpilContextualization> ipilContextualizations = [];
  List<IpilConnectionTerritory> ipilConnectionTerritories = [];
  List<IpilInterviews> ipilInterviews = [];
  List<IpilIntermediations> ipilIntermediations = [];
  List<IpilObtainingEmployment> ipilObtainingEmployments = [];
  List<IpilImprovingEmployment> ipilImprovingEmployments = [];
  List<IpilPostWorkSupport> ipilPostWorkSupports = [];
  List<IpilCoordination> ipilCoordinations = [];
  List<IpilLegal> ipilLegals = [];
  List<IpilEconomicBag> ipilEconomicBags = [];
  List<IpilSpecificSkills> ipilSpecificSkills = [];
  List<IpilSoftSkills> ipilSoftSkills = [];
  List<IpilDigitalSkills> ipilDigitalSkills = [];
  List<IpilLaborSkills> ipilLaborSkills = [];
  List<Experience> experiences = [];
  List<Education> educations = [];
  List<String> nations = [];
  List<Resource> resources = [];
  List<PersonalDocumentType> personalDocumentTypes = [];
  List<Gender> genders = [];
  List<Dedication> dedications = [];
  List<KeepLearningOption> keepLearningOptions = [];
  List<DocumentCategory> documentCategories = [];
  List<String> languages = [];

  final Map<String, SocialEntity> socialEntitiesCache = {};
  final Map<String, UserEnreda> userCache = {};
  final Map<String, Future<UserEnreda?>> _pendingUserFetches = {};

  // --- Participant State ---
  final List<UserEnreda> allParticipants = [];
  final Map<String, UserEnreda> _participantCache = {};
  bool isLoadingParticipants = false;
  String? _currentEntityId;
  List<String> _currentPrograms = [];
  bool _initialLoadDone = false;
  bool _hasMoreEntityParticipants = true;
  bool _hasMoreProgramParticipants = true;
  DocumentSnapshot? _lastEntityParticipantDoc;
  DocumentSnapshot? _lastProgramParticipantDoc;

  /// Stream to notify listeners when allParticipants changes
  final StreamController<void> _paginationController = StreamController<void>.broadcast();
  Stream<void> get paginationUpdates => _paginationController.stream;

  void _notifyPaginationListeners() {
    if (!_paginationController.isClosed) {
      _paginationController.add(null);
    }
  }

  /// Loads all participants for the active entity/programs into session cache.
  /// Data is fetched in paginated batches internally to avoid giant single queries.
  Future<void> loadAllParticipants(Database database, String socialEntityId, List<String> programs, {int pageSize = 30}) async {
    final normalizedPrograms = programs.toSet().toList();
    final sameScope = _currentEntityId == socialEntityId &&
        _currentPrograms.length == normalizedPrograms.length &&
        _currentPrograms.toSet().containsAll(normalizedPrograms);

    if (_initialLoadDone && sameScope && allParticipants.isNotEmpty) return;

    _currentEntityId = socialEntityId;
    _currentPrograms = normalizedPrograms;
    allParticipants.clear();
    _participantCache.clear();
    _lastEntityParticipantDoc = null;
    _lastProgramParticipantDoc = null;
    _hasMoreEntityParticipants = true;
    _hasMoreProgramParticipants = normalizedPrograms.isNotEmpty;
    isLoadingParticipants = true;
    _initialLoadDone = false;
    _notifyPaginationListeners();

    try {
      while (_hasMoreEntityParticipants || _hasMoreProgramParticipants) {
        await _fetchParticipantPage(
          database,
          socialEntityId,
          normalizedPrograms,
          pageSize,
        );
      }
      _initialLoadDone = true;
    } catch (e) {
      print('Error loading participants: $e');
    } finally {
      isLoadingParticipants = false;
      _notifyPaginationListeners();
    }
  }

  Future<void> _fetchParticipantPage(
    Database database,
    String socialEntityId,
    List<String> programs,
    int pageSize,
  ) async {
    List<UserEnreda> entityUsers = <UserEnreda>[];
    DocumentSnapshot? entityLastDoc;
    if (_hasMoreEntityParticipants) {
      final entityPage = await database.getParticipantsByEntityPaginated(
        socialEntityId,
        limit: pageSize,
        startAfterDocument: _lastEntityParticipantDoc,
      );
      entityUsers = entityPage.$1;
      entityLastDoc = entityPage.$2;
    }
    _lastEntityParticipantDoc = entityLastDoc;
    _hasMoreEntityParticipants = entityUsers.length == pageSize && _lastEntityParticipantDoc != null;

    List<UserEnreda> programUsers = <UserEnreda>[];
    DocumentSnapshot? programLastDoc;
    if (_hasMoreProgramParticipants && programs.isNotEmpty) {
      final programPage = await database.getParticipantsByProgramsPaginated(
        programs,
        limit: pageSize,
        startAfterDocument: _lastProgramParticipantDoc,
      );
      programUsers = programPage.$1;
      programLastDoc = programPage.$2;
    }
    _lastProgramParticipantDoc = programLastDoc;
    _hasMoreProgramParticipants = programs.isNotEmpty && programUsers.length == pageSize && _lastProgramParticipantDoc != null;

    for (final user in [...entityUsers, ...programUsers]) {
      final key = user.userId ?? user.email;
      if (!_participantCache.containsKey(key)) {
        _participantCache[key] = user;
        allParticipants.add(user);
      }
    }
    allParticipants.sort((a, b) => (a.firstName ?? '').compareTo(b.firstName ?? ''));
  }

  /// Reset cached participants (e.g., when navigating away or force refresh)
  void resetParticipants() {
    _initialLoadDone = false;
    _currentEntityId = null;
    _currentPrograms = [];
    _lastEntityParticipantDoc = null;
    _lastProgramParticipantDoc = null;
    _hasMoreEntityParticipants = true;
    _hasMoreProgramParticipants = true;
    allParticipants.clear();
    _participantCache.clear();
  }

  Future<List<T>> _loadOrFetchCatalog<T>(
    String key,
    Future<List<T>> Function() fetchFunction,
    T Function(Map<String, dynamic> data, String id) fromMap,
  ) async {
    final cached = await PersistenceService.instance.loadCatalog(key);
    if (cached != null && cached.isNotEmpty) {
      return cached.map((e) => fromMap(e as Map<String, dynamic>, '')).toList();
    }
    final fetched = await fetchFunction();
    await PersistenceService.instance.saveCatalog(key, fetched);
    return fetched;
  }

  Future<List<String>> _loadOrFetchList(
    String key,
    Future<List<String>> Function() fetchFunction,
  ) async {
    final cached = await PersistenceService.instance.loadCatalog(key);
    if (cached != null && cached.isNotEmpty) {
      return cached.cast<String>();
    }
    final fetched = await fetchFunction();
    await PersistenceService.instance.saveCatalog(key, fetched);
    return fetched;
  }

  Future<void> warmUpAll(Database database) {
    if (_warmUpFuture != null) return _warmUpFuture!;

    _warmUpFuture = Future.wait([
      _loadOrFetchCatalog<Country>('countries', () => database.countriesStream().first, (data, id) => Country.fromMap(data, id)).then((value) => countries = value),
      // NOTE: provinces, cities — fetched on-demand per country/province via filtered Firestore queries
      _loadOrFetchCatalog<GamificationFlag>('gamificationFlags', () => database.gamificationFlagsStream().first, (data, id) => GamificationFlag.fromMap(data, id)).then((value) => gamificationFlags = value),
      _loadOrFetchCatalog<Competency>('competencies', () => database.getCompetencies(), (data, id) => Competency.fromMap(data, id)).then((value) => competencies = value),
      _loadOrFetchCatalog<Interest>('interests', () => database.getInterests(), (data, id) => Interest.fromMap(data, id)).then((value) => interests = value),
      _loadOrFetchCatalog<Ability>('abilities', () => database.getAbilities(), (data, id) => Ability.fromMap(data, id)).then((value) => abilities = value),
      // NOTE: specificInterests — fetched on-demand per interest via filtered Firestore queries
      _loadOrFetchCatalog<SocialEntitiesType>('socialEntitiesTypes', () => database.socialEntitiesTypeStream().first, (data, id) => SocialEntitiesType.fromMap(data, id)).then((value) => socialEntitiesTypes = value),
      _loadOrFetchCatalog<PersonalDocumentType>('personalDocumentTypes', () => database.personalDocumentTypeStream().first, (data, id) => PersonalDocumentType.fromMap(data, id)).then((value) => personalDocumentTypes = value),
      _loadOrFetchCatalog<Education>('educations', () => database.educationStream().first, (data, id) => Education.fromMap(data, id)).then((value) => educations = value).catchError((_) => []),
      // NOTE: nations (250 docs) and resources (120 docs) are now fetched on-demand
      database.genderStream().first.then((value) => genders = value).catchError((_) => []),
      database.dedicationStream().first.then((value) => dedications = value).catchError((_) => []),
      database.keepLearningOptionsStream().first.then((value) => keepLearningOptions = value).catchError((_) => []),
      database.documentCategoriesStream().first.then((value) => documentCategories = value).catchError((_) => []),
      _loadOrFetchList('languages', () => database.languagesStream().first).then((value) => languages = value).catchError((_) => []),
      // Warm up IPIL Master Data
      database.getIpilReinforcements([]).then((_) => database.ipilReinforcementStream().first).then((value) => ipilReinforcements = value).catchError((_) => []),
      database.ipilContextualizationStream().first.then((value) => ipilContextualizations = value).catchError((_) => []),
      database.ipilConnectionTerritoryStream().first.then((value) => ipilConnectionTerritories = value).catchError((_) => []),
      database.ipilInterviewsStream().first.then((value) => ipilInterviews = value).catchError((_) => []),
      database.ipilIntermediationsStream().first.then((value) => ipilIntermediations = value).catchError((_) => []),
      database.ipilObtainingEmploymentStream().first.then((value) => ipilObtainingEmployments = value).catchError((_) => []),
      database.ipilImprovingEmploymentStream().first.then((value) => ipilImprovingEmployments = value).catchError((_) => []),
      database.ipilPostWorkSupportStream().first.then((value) => ipilPostWorkSupports = value).catchError((_) => []),
      database.ipilCoordinationStream().first.then((value) => ipilCoordinations = value).catchError((_) => []),
      database.ipilLegalStream().first.then((value) => ipilLegals = value).catchError((_) => []),
      database.ipilEconomicBagStream().first.then((value) => ipilEconomicBags = value).catchError((_) => []),
      database.ipilSpecificSkillsStream().first.then((value) => ipilSpecificSkills = value).catchError((_) => []),
      database.ipilSoftSkillsStream().first.then((value) => ipilSoftSkills = value).catchError((_) => []),
      database.ipilDigitalSkillsStream().first.then((value) => ipilDigitalSkills = value).catchError((_) => []),
      database.ipilLaborSkillsStream().first.then((value) => ipilLaborSkills = value).catchError((_) => []),
    ]);
    return _warmUpFuture!;
  }

  int get gamificationFlagsCount => gamificationFlags.length;

  Country? countryById(String? id) {
    if (id == null) return null;
    try {
      return countries.firstWhere((element) => element.countryId == id);
    } catch (_) {
      return null;
    }
  }

  Province? provinceById(String? id) {
    if (id == null) return null;
    try {
      return provinces.firstWhere((element) => element.provinceId == id);
    } catch (_) {
      return null;
    }
  }

  City? cityById(String? id) {
    if (id == null) return null;
    try {
      return cities.firstWhere((element) => element.cityId == id);
    } catch (_) {
      return null;
    }
  }

  SpecificInterest? specificInterestById(String? id) {
    if (id == null) return null;
    try {
      return specificInterests.firstWhere((element) => element.specificInterestId == id);
    } catch (_) {
      return null;
    }
  }

  PersonalDocumentType? personalDocumentTypeById(String? id) {
    if (id == null) return null;
    try {
      return personalDocumentTypes.firstWhere((element) => element.personalDocId == id);
    } catch (_) {
      return null;
    }
  }

  Gender? genderById(String? id) {
    if (id == null) return null;
    try {
      return genders.firstWhere((element) => element.genderId == id);
    } catch (_) {
      return null;
    }
  }

  Dedication? dedicationById(String? id) {
    if (id == null) return null;
    try {
      return dedications.firstWhere((element) => element.dedicationId == id);
    } catch (_) {
      return null;
    }
  }

  KeepLearningOption? keepLearningOptionById(String? id) {
    if (id == null) return null;
    try {
      return keepLearningOptions.firstWhere((element) => element.keepLearningOptionId == id);
    } catch (_) {
      return null;
    }
  }

  DocumentCategory? documentCategoryById(String? id) {
    if (id == null) return null;
    try {
      return documentCategories.firstWhere((element) => element.documentCategoryId == id);
    } catch (_) {
      return null;
    }
  }

  Future<SocialEntity?> getSocialEntity(Database database, String id) async {
    if (socialEntitiesCache.containsKey(id)) {
      return socialEntitiesCache[id];
    }
    final entity = await database.getSocialEntity(id);
    if (entity != null) socialEntitiesCache[id] = entity;
    return entity;
  }

  Future<UserEnreda?> getUser(Database database, String id) async {
    if (userCache.containsKey(id)) {
      return userCache[id];
    }
    if (id.isEmpty) return null;
    
    if (_pendingUserFetches.containsKey(id)) {
      return _pendingUserFetches[id];
    }

    final fetchFuture = database.getUser(id).then((user) {
      if (user != null) userCache[id] = user;
      _pendingUserFetches.remove(id);
      return user;
    });

    _pendingUserFetches[id] = fetchFuture;
    return fetchFuture;
  }

  // --- IPIL Helper Methods ---

  String getReinforcementLabels(List<String?> ids) =>
      ipilReinforcements.where((e) => ids.contains(e.ipilReinforcementId)).map((e) => e.label).join(', ');

  String getContextualizationLabels(List<String?> ids) =>
      ipilContextualizations.where((e) => ids.contains(e.ipilContextualizationId)).map((e) => e.label).join(', ');

  String getConnectionTerritoryLabels(List<String?> ids) =>
      ipilConnectionTerritories.where((e) => ids.contains(e.ipilConnectionTerritoryId)).map((e) => e.label).join(', ');

  String getInterviewsLabels(List<String?> ids) =>
      ipilInterviews.where((e) => ids.contains(e.ipilInterviewsId)).map((e) => e.label).join(', ');

  String getIntermediationsLabels(List<String?> ids) =>
      ipilIntermediations.where((e) => ids.contains(e.ipilIntermediationsId)).map((e) => e.label).join(', ');

  String getObtainingEmploymentLabels(List<String?> ids) =>
      ipilObtainingEmployments.where((e) => ids.contains(e.ipilObtainingEmploymentId)).map((e) => e.label).join(', ');

  String getImprovingEmploymentLabels(List<String?> ids) =>
      ipilImprovingEmployments.where((e) => ids.contains(e.ipilImprovingEmploymentId)).map((e) => e.label).join(', ');

  String getPostWorkSupportLabels(List<String?> ids) =>
      ipilPostWorkSupports.where((e) => ids.contains(e.ipilPostWorkSupportId)).map((e) => e.label).join(', ');

  String getCoordinationLabels(List<String?> ids) =>
      ipilCoordinations.where((e) => ids.contains(e.ipilCoordinationId)).map((e) => e.label).join(', ');

  String getLegalLabels(List<String?> ids) =>
      ipilLegals.where((e) => ids.contains(e.ipilLegalId)).map((e) => e.label).join(', ');

  String getEconomicBagLabels(List<String?> ids) =>
      ipilEconomicBags.where((e) => ids.contains(e.ipilEconomicBagId)).map((e) => e.label).join(', ');

  String getSpecificSkillsLabels(List<String?> ids) =>
      ipilSpecificSkills.where((e) => ids.contains(e.ipilSpecificSkillsId)).map((e) => e.label).join(', ');

  String getSoftSkillsLabels(List<String?> ids) =>
      ipilSoftSkills.where((e) => ids.contains(e.ipilSoftSkillsId)).map((e) => e.label).join(', ');

  String getDigitalSkillsLabels(List<String?> ids) =>
      ipilDigitalSkills.where((e) => ids.contains(e.ipilDigitalSkillsId)).map((e) => e.label).join(', ');

  String getLaborSkillsLabels(List<String?> ids) =>
      ipilLaborSkills.where((e) => ids.contains(e.ipilLaborSkillsId)).map((e) => e.label).join(', ');
}

