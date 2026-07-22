import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enreda_empresas/app/services/persistence_service.dart';
import 'package:enreda_empresas/app/models/city.dart';
import 'package:enreda_empresas/app/models/country.dart';
import 'package:enreda_empresas/app/models/gamificationFlags.dart';
import 'package:enreda_empresas/app/models/province.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/models/competency.dart';
import 'package:enreda_empresas/app/models/competencyCategory.dart';
import 'package:enreda_empresas/app/models/competencySubCategory.dart';
import 'package:enreda_empresas/app/models/interest.dart';
import 'package:enreda_empresas/app/models/scope_action.dart';
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
import 'package:enreda_empresas/app/models/program.dart';
import 'package:enreda_empresas/app/models/resourcetype.dart';
import 'package:enreda_empresas/app/models/resourceCategory.dart';
import 'package:enreda_empresas/app/models/resourcePicture.dart';
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
  List<CompetencyCategory> competencyCategories = [];
  List<CompetencySubCategory> competencySubCategories = [];
  List<Interest> interests = [];
  List<ScopeAction> scopeActions = [];
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
  List<Program> programs = [];
  List<ResourceType> resourceTypes = [];
  List<ResourceCategory> resourceCategories = [];
  List<ResourcePicture> resourcePictures = [];
  List<String> languages = [];

  final Map<String, SocialEntity> socialEntitiesCache = {};
  final Map<String, UserEnreda> userCache = {};
  final Map<String, Future<UserEnreda?>> _pendingUserFetches = {};
  final Map<String, City> cityCache = {};
  final Map<String, Future<City?>> _pendingCityFetches = {};
  final Map<String, Province> provinceCache = {};
  final Map<String, Future<Province?>> _pendingProvinceFetches = {};

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

  // --- Shared Resources Stream ---
  final StreamController<void> _resourcesController = StreamController<void>.broadcast();
  Stream<void> get resourceUpdates => _resourcesController.stream;
  StreamSubscription<List<Resource>>? _resourcesSubscription;
  String? _resourcesEntityId;

  /// Initialises a single shared Firestore subscription for the entity's resources.
  /// Safe to call multiple times — re-uses the existing subscription when entityId unchanged.
  void initResourcesStream(Database database, String entityId) {
    if (_resourcesEntityId == entityId && _resourcesSubscription != null) return;
    _resourcesSubscription?.cancel();
    _resourcesEntityId = entityId;
    _resourcesSubscription = database.myResourcesStream(entityId).listen((data) {
      resources = data;
      if (!_resourcesController.isClosed) _resourcesController.add(null);
    });
  }

  void _notifyPaginationListeners() {
    if (!_paginationController.isClosed) {
      _paginationController.add(null);
    }
  }

  /// Loads all participants for the active entity/programs into session cache.
  /// Data is fetched in paginated batches and the UI is notified after each batch
  /// so the list renders progressively instead of blocking.
  Future<void> loadAllParticipants(Database database, String socialEntityId, List<String> programs, {int pageSize = 30}) async {
    final normalizedPrograms = programs.toSet().toList();
    final sameScope = _currentEntityId == socialEntityId &&
        _currentPrograms.length == normalizedPrograms.length &&
        _currentPrograms.toSet().containsAll(normalizedPrograms);

    if (isLoadingParticipants && sameScope) return;
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
        _notifyPaginationListeners();
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
    T Function(Map<String, dynamic> data, String id) fromMap, {
    String Function(T)? getDocId,
  }) async {
    final cached = await PersistenceService.instance.loadCatalog(key);
    if (cached != null && cached.isNotEmpty) {
      return cached.map((e) {
        final map = Map<String, dynamic>.from(e as Map<String, dynamic>);
        final docId = (map.remove('_docId') as String?) ?? '';
        return fromMap(map, docId);
      }).toList();
    }
    final fetched = await fetchFunction();
    await _saveCatalogWithDocIds(key, fetched, getDocId);
    return fetched;
  }

  Future<void> _saveCatalogWithDocIds<T>(
    String key, List<T> data, String Function(T)? getDocId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data.map((e) {
      try {
        final map = (e as dynamic).toMap() as Map<String, dynamic>;
        map.forEach((k, v) {
          if (v is DateTime) map[k] = v.toIso8601String();
        });
        if (getDocId != null) map['_docId'] = getDocId(e);
        return map;
      } catch (_) {
        return e;
      }
    }).toList());
    await prefs.setString(key, jsonString);
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
    _warmUpFuture = _doWarmUp(database);
    return _warmUpFuture!;
  }

  static const int _cacheVersion = 5;

  /// Batched warm-up: max ~5 concurrent Firestore reads at a time.
  /// All catalogs use persistence cache so subsequent launches skip Firestore entirely.
  Future<void> _doWarmUp(Database database) async {
    final prefs = await SharedPreferences.getInstance();
    final storedVersion = prefs.getInt('_cacheVersion') ?? 0;
    if (storedVersion < _cacheVersion) {
      const catalogKeys = [
        'countries', 'gamificationFlags', 'competencies', 'competencyCategories', 'competencySubCategories', 'interests', 'scopeActions', 'abilities',
        'socialEntitiesTypes', 'personalDocumentTypes', 'educations', 'genders', 'dedications',
        'keepLearningOptions', 'documentCategories', 'programs', 'resourceTypes', 'languages',
        'resourceCategories', 'resourcePictures',
        'ipilReinforcements', 'ipilContextualizations', 'ipilConnectionTerritories',
        'ipilInterviews', 'ipilIntermediations', 'ipilObtainingEmployments',
        'ipilImprovingEmployments', 'ipilPostWorkSupports',
        'ipilCoordinations', 'ipilLegals', 'ipilEconomicBags',
        'ipilSpecificSkills', 'ipilSoftSkills', 'ipilDigitalSkills', 'ipilLaborSkills',
      ];
      for (final k in catalogKeys) {
        await prefs.remove(k);
      }
      await prefs.setInt('_cacheVersion', _cacheVersion);
    }

    // Batch 1: Core lookup data
    await Future.wait([
      _loadOrFetchCatalog<Country>('countries', () => database.countriesStream().first, (data, id) => Country.fromMap(data, id), getDocId: (e) => e.countryId ?? '').then((v) => countries = v),
      _loadOrFetchCatalog<GamificationFlag>('gamificationFlags', () => database.gamificationFlagsStream().first, (data, id) => GamificationFlag.fromMap(data, id)).then((v) => gamificationFlags = v),
      _loadOrFetchCatalog<Competency>('competencies', () => database.getCompetencies(), (data, id) => Competency.fromMap(data, id)).then((v) => competencies = v),
      _loadOrFetchCatalog<CompetencyCategory>('competencyCategories', () => database.competenciesCategoriesStream().first, (data, id) => CompetencyCategory.fromMap(data, id), getDocId: (e) => e.competencyCategoryId ?? '').then((v) => competencyCategories = v).catchError((e) { print("Error: e"); return <CompetencyCategory>[]; }),
      _loadOrFetchCatalog<CompetencySubCategory>('competencySubCategories', () => database.competenciesSubCategoriesStream().first, (data, id) => CompetencySubCategory.fromMap(data, id), getDocId: (e) => e.competencySubCategoryId ?? '').then((v) => competencySubCategories = v).catchError((e) { print("Error: e"); return <CompetencySubCategory>[]; }),
      _loadOrFetchCatalog<Interest>('interests', () => database.getInterests(), (data, id) => Interest.fromMap(data, id)).then((v) => interests = v),
      _loadOrFetchCatalog<ScopeAction>('scopeActions', () => database.getScopeActions(), (data, id) => ScopeAction.fromMap(data, id)).then((v) => scopeActions = v),
      _loadOrFetchCatalog<Ability>('abilities', () => database.getAbilities(), (data, id) => Ability.fromMap(data, id)).then((v) => abilities = v),
    ]);

    // Batch 2: More lookups
    await Future.wait([
      _loadOrFetchCatalog<SocialEntitiesType>('socialEntitiesTypes', () => database.socialEntitiesTypeStream().first, (data, id) => SocialEntitiesType.fromMap(data, id)).then((v) => socialEntitiesTypes = v),
      _loadOrFetchCatalog<PersonalDocumentType>('personalDocumentTypes', () => database.personalDocumentTypeStream().first, (data, id) => PersonalDocumentType.fromMap(data, id), getDocId: (p) => p.personalDocId).then((v) => personalDocumentTypes = v),
      _loadOrFetchCatalog<Education>('educations', () => database.educationStream().first, (data, id) => Education.fromMap(data, id)).then((v) => educations = v).catchError((e) { print("Error: e"); return <Education>[]; }),
      _loadOrFetchCatalog<Gender>('genders', () => database.genderStream().first, (data, id) => Gender.fromMap(data, id)).then((v) => genders = v).catchError((e) { print("Error: e"); return <Gender>[]; }),
      _loadOrFetchCatalog<Dedication>('dedications', () => database.dedicationStream().first, (data, id) => Dedication.fromMap(data, id)).then((v) => dedications = v).catchError((e) { print("Error: e"); return <Dedication>[]; }),
    ]);

    // Batch 3: Remaining small catalogs + resource metadata
    await Future.wait([
      _loadOrFetchCatalog<KeepLearningOption>('keepLearningOptions', () => database.keepLearningOptionsStream().first, (data, id) => KeepLearningOption.fromMap(data, id)).then((v) => keepLearningOptions = v).catchError((e) { print("Error: e"); return <KeepLearningOption>[]; }),
      _loadOrFetchCatalog<DocumentCategory>('documentCategories', () => database.documentCategoriesStream().first, (data, id) => DocumentCategory.fromMap(data, id), getDocId: (d) => d.documentCategoryId).then((v) => documentCategories = v).catchError((e) { print("Error: e"); return <DocumentCategory>[]; }),
      _loadOrFetchCatalog<Program>('programs', () => database.programsStream().first, (data, id) => Program.fromMap(data, id), getDocId: (p) => p.programId ?? '').then((v) => programs = v).catchError((e) { print("Error: e"); return <Program>[]; }),
      _loadOrFetchCatalog<ResourceType>('resourceTypes', () => database.resourceTypeStream().first, (data, id) => ResourceType.fromMap(data, id)).then((v) => resourceTypes = v).catchError((e) { print("Error: e"); return <ResourceType>[]; }),
      _loadOrFetchList('languages', () => database.languagesStream().first).then((v) => languages = v).catchError((e) { print("Error: e"); return <String>[]; }),
    ]);

    // Batch 4: Resource categories, pictures + IPIL master data (part 1)
    await Future.wait([
      _loadOrFetchCatalog<ResourceCategory>('resourceCategories', () => database.resourceCategoryStream().first, (data, id) => ResourceCategory.fromMap(data, id), getDocId: (r) => r.id).then((v) => resourceCategories = v).catchError((e) { print("Error: e"); return <ResourceCategory>[]; }),
      _loadOrFetchCatalog<ResourcePicture>('resourcePictures', () => database.resourcePicturesStream().first, (data, id) => ResourcePicture.fromMap(data, id)).then((v) => resourcePictures = v).catchError((e) { print("Error: e"); return <ResourcePicture>[]; }),
      _loadOrFetchCatalog<IpilReinforcement>('ipilReinforcements', () => database.ipilReinforcementStream().first, (data, id) => IpilReinforcement.fromMap(data, id), getDocId: (e) => e.ipilReinforcementId ?? '').then((v) => ipilReinforcements = v).catchError((e) { print("Error: e"); return <IpilReinforcement>[]; }),
      _loadOrFetchCatalog<IpilContextualization>('ipilContextualizations', () => database.ipilContextualizationStream().first, (data, id) => IpilContextualization.fromMap(data, id), getDocId: (e) => e.ipilContextualizationId ?? '').then((v) => ipilContextualizations = v).catchError((e) { print("Error: e"); return <IpilContextualization>[]; }),
      _loadOrFetchCatalog<IpilConnectionTerritory>('ipilConnectionTerritories', () => database.ipilConnectionTerritoryStream().first, (data, id) => IpilConnectionTerritory.fromMap(data, id), getDocId: (e) => e.ipilConnectionTerritoryId ?? '').then((v) => ipilConnectionTerritories = v).catchError((e) { print("Error: e"); return <IpilConnectionTerritory>[]; }),
    ]);

    // Batch 5: IPIL master data (part 2)
    await Future.wait([
      _loadOrFetchCatalog<IpilInterviews>('ipilInterviews', () => database.ipilInterviewsStream().first, (data, id) => IpilInterviews.fromMap(data, id), getDocId: (e) => e.ipilInterviewsId ?? '').then((v) => ipilInterviews = v).catchError((e) { print("Error: e"); return <IpilInterviews>[]; }),
      _loadOrFetchCatalog<IpilIntermediations>('ipilIntermediations', () => database.ipilIntermediationsStream().first, (data, id) => IpilIntermediations.fromMap(data, id), getDocId: (e) => e.ipilIntermediationsId ?? '').then((v) => ipilIntermediations = v).catchError((e) { print("Error: e"); return <IpilIntermediations>[]; }),
      _loadOrFetchCatalog<IpilObtainingEmployment>('ipilObtainingEmployments', () => database.ipilObtainingEmploymentStream().first, (data, id) => IpilObtainingEmployment.fromMap(data, id), getDocId: (e) => e.ipilObtainingEmploymentId ?? '').then((v) => ipilObtainingEmployments = v).catchError((e) { print("Error: e"); return <IpilObtainingEmployment>[]; }),
      _loadOrFetchCatalog<IpilImprovingEmployment>('ipilImprovingEmployments', () => database.ipilImprovingEmploymentStream().first, (data, id) => IpilImprovingEmployment.fromMap(data, id), getDocId: (e) => e.ipilImprovingEmploymentId ?? '').then((v) => ipilImprovingEmployments = v).catchError((e) { print("Error: e"); return <IpilImprovingEmployment>[]; }),
      _loadOrFetchCatalog<IpilPostWorkSupport>('ipilPostWorkSupports', () => database.ipilPostWorkSupportStream().first, (data, id) => IpilPostWorkSupport.fromMap(data, id), getDocId: (e) => e.ipilPostWorkSupportId ?? '').then((v) => ipilPostWorkSupports = v).catchError((e) { print("Error: e"); return <IpilPostWorkSupport>[]; }),
    ]);

    // Batch 6: IPIL master data (part 3)
    await Future.wait([
      _loadOrFetchCatalog<IpilCoordination>('ipilCoordinations', () => database.ipilCoordinationStream().first, (data, id) => IpilCoordination.fromMap(data, id), getDocId: (e) => e.ipilCoordinationId ?? '').then((v) => ipilCoordinations = v).catchError((e) { print("Error: e"); return <IpilCoordination>[]; }),
      _loadOrFetchCatalog<IpilLegal>('ipilLegals', () => database.ipilLegalStream().first, (data, id) => IpilLegal.fromMap(data, id), getDocId: (e) => e.ipilLegalId ?? '').then((v) => ipilLegals = v).catchError((e) { print("Error: e"); return <IpilLegal>[]; }),
      _loadOrFetchCatalog<IpilEconomicBag>('ipilEconomicBags', () => database.ipilEconomicBagStream().first, (data, id) => IpilEconomicBag.fromMap(data, id), getDocId: (e) => e.ipilEconomicBagId ?? '').then((v) => ipilEconomicBags = v).catchError((e) { print("Error: e"); return <IpilEconomicBag>[]; }),
      _loadOrFetchCatalog<IpilSpecificSkills>('ipilSpecificSkills', () => database.ipilSpecificSkillsStream().first, (data, id) => IpilSpecificSkills.fromMap(data, id), getDocId: (e) => e.ipilSpecificSkillsId ?? '').then((v) => ipilSpecificSkills = v).catchError((e) { print("Error: e"); return <IpilSpecificSkills>[]; }),
      _loadOrFetchCatalog<IpilSoftSkills>('ipilSoftSkills', () => database.ipilSoftSkillsStream().first, (data, id) => IpilSoftSkills.fromMap(data, id), getDocId: (e) => e.ipilSoftSkillsId ?? '').then((v) => ipilSoftSkills = v).catchError((e) { print("Error: e"); return <IpilSoftSkills>[]; }),
    ]);

    // Batch 7: Final IPIL data
    await Future.wait([
      _loadOrFetchCatalog<IpilDigitalSkills>('ipilDigitalSkills', () => database.ipilDigitalSkillsStream().first, (data, id) => IpilDigitalSkills.fromMap(data, id), getDocId: (e) => e.ipilDigitalSkillsId ?? '').then((v) => ipilDigitalSkills = v).catchError((e) { print("Error: e"); return <IpilDigitalSkills>[]; }),
      _loadOrFetchCatalog<IpilLaborSkills>('ipilLaborSkills', () => database.ipilLaborSkillsStream().first, (data, id) => IpilLaborSkills.fromMap(data, id), getDocId: (e) => e.ipilLaborSkillsId ?? '').then((v) => ipilLaborSkills = v).catchError((e) { print("Error: e"); return <IpilLaborSkills>[]; }),
    ]);
  }

  int get gamificationFlagsCount => gamificationFlags.length;

  // O(1) id lookups. A linear firstWhere (+ thrown StateError on miss) per
  // call is too slow when hundreds of list tiles resolve locations per build.
  // Maps are rebuilt only when the source list changes size (set at warm-up).
  Map<String, Country>? _countryMap;
  int _countryMapSourceLength = -1;
  Map<String, Province>? _provinceMap;
  int _provinceMapSourceLength = -1;
  Map<String, City>? _cityMap;
  int _cityMapSourceLength = -1;

  Country? countryById(String? id) {
    if (id == null || id.isEmpty) return null;
    if (_countryMap == null || _countryMapSourceLength != countries.length) {
      _countryMap = {
        for (final c in countries)
          if (c.countryId != null) c.countryId!: c
      };
      _countryMapSourceLength = countries.length;
    }
    return _countryMap![id];
  }

  Province? provinceById(String? id) {
    if (id == null || id.isEmpty) return null;
    if (_provinceMap == null || _provinceMapSourceLength != provinces.length) {
      _provinceMap = {
        for (final p in provinces)
          if (p.provinceId != null) p.provinceId!: p
      };
      _provinceMapSourceLength = provinces.length;
    }
    return _provinceMap![id];
  }

  City? cityById(String? id) {
    if (id == null || id.isEmpty) return null;
    if (_cityMap == null || _cityMapSourceLength != cities.length) {
      _cityMap = {
        for (final c in cities)
          if (c.cityId != null) c.cityId!: c
      };
      _cityMapSourceLength = cities.length;
    }
    return _cityMap![id];
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

  Future<City?> getCity(Database database, String id) async {
    if (cityCache.containsKey(id)) {
      return cityCache[id];
    }
    if (id.isEmpty) return null;
    
    if (_pendingCityFetches.containsKey(id)) {
      return _pendingCityFetches[id];
    }

    final fetchFuture = database.getCity(id).then((city) {
      if (city != null) cityCache[id] = city;
      _pendingCityFetches.remove(id);
      return city;
    });

    _pendingCityFetches[id] = fetchFuture;
    return fetchFuture;
  }

  Future<Province?> getProvince(Database database, String id) async {
    if (provinceCache.containsKey(id)) {
      return provinceCache[id];
    }
    if (id.isEmpty) return null;
    
    if (_pendingProvinceFetches.containsKey(id)) {
      return _pendingProvinceFetches[id];
    }

    final fetchFuture = database.getProvince(id).then((province) {
      if (province != null) provinceCache[id] = province;
      _pendingProvinceFetches.remove(id);
      return province;
    });

    _pendingProvinceFetches[id] = fetchFuture;
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

