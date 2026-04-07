import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enreda_empresas/app/models/city.dart';
import 'package:enreda_empresas/app/models/country.dart';
import 'package:enreda_empresas/app/models/gamificationFlags.dart';
import 'package:enreda_empresas/app/models/province.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/models/competency.dart';
import 'package:enreda_empresas/app/models/interest.dart';
import 'package:enreda_empresas/app/models/ability.dart';
import 'package:enreda_empresas/app/models/socialEntity.dart';
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

  final Map<String, SocialEntity> socialEntitiesCache = {};
  final Map<String, UserEnreda> userCache = {};

  // --- Paginated Participant State ---
  final List<UserEnreda> allParticipants = [];
  final Map<String, UserEnreda> _participantCache = {};
  bool isLoadingParticipants = false;
  bool hasMoreEntityParticipants = true;
  bool hasMoreProgramParticipants = true;
  bool get hasMoreParticipants => hasMoreEntityParticipants || hasMoreProgramParticipants;
  DocumentSnapshot? _lastEntityDoc;
  DocumentSnapshot? _lastProgramDoc;
  String? _currentEntityId;
  List<String> _currentPrograms = [];
  bool _initialLoadDone = false;

  // Keep old stream-based fields for backward compatibility (e.g. my_participants_list)
  List<UserEnreda>? cachedParticipants;
  StreamSubscription? _assignedSubscription;
  StreamSubscription? _programSubscription;
  final StreamController<List<UserEnreda>> _participantsController = StreamController<List<UserEnreda>>.broadcast();
  Stream<List<UserEnreda>> get participantsStream => _participantsController.stream;

  /// Listeners for pagination state changes
  final StreamController<void> _paginationController = StreamController<void>.broadcast();
  Stream<void> get paginationUpdates => _paginationController.stream;

  void _notifyPaginationListeners() {
    if (!_paginationController.isClosed) {
      _paginationController.add(null);
    }
  }

  void startParticipantsStream(Database database, String socialEntityId, List<String> programs) {
    if (_assignedSubscription != null) return; // already started

    List<UserEnreda> assigned = [];
    List<UserEnreda> programList = [];

    void emit() {
      final Map<String, UserEnreda> allUsersMap = {};
      for (var u in assigned) if (u.userId != null) allUsersMap[u.userId!] = u;
      for (var u in programList) if (u.userId != null) allUsersMap[u.userId!] = u;
      final users = allUsersMap.values.toList();
      users.sort((lhs, rhs) => (lhs.firstName ?? '').compareTo(rhs.firstName ?? ''));
      cachedParticipants = users;
      _participantsController.add(users);
    }

    _assignedSubscription = database.getParticipantsByEntityStream(socialEntityId).listen((data) {
      assigned = data;
      emit();
    });

    if (programs.isNotEmpty) {
      _programSubscription = database.getParticipantsByProgramsStream(programs).listen((data) {
        programList = data;
        emit();
      });
    }
  }

  /// Initialize paginated loading for participants.
  /// Call this once when the participants page is first shown.
  Future<void> initPaginatedParticipants(Database database, String socialEntityId, List<String> programs) async {
    if (_initialLoadDone && _currentEntityId == socialEntityId) return;

    _currentEntityId = socialEntityId;
    _currentPrograms = programs;
    _lastEntityDoc = null;
    _lastProgramDoc = null;
    hasMoreEntityParticipants = true;
    hasMoreProgramParticipants = programs.isNotEmpty;
    allParticipants.clear();
    _participantCache.clear();
    _initialLoadDone = true;

    await fetchNextParticipantsPage(database);
  }

  /// Fetch the next page of 10 participants, deduplicating as we go.
  Future<void> fetchNextParticipantsPage(Database database) async {
    if (isLoadingParticipants || !hasMoreParticipants) return;
    isLoadingParticipants = true;
    _notifyPaginationListeners();

    try {
      int added = 0;

      // Fetch from entity query
      if (hasMoreEntityParticipants) {
        final (entityUsers, lastEntityDoc) = await database.getParticipantsByEntityPaginated(
          _currentEntityId!,
          limit: 10,
          startAfterDocument: _lastEntityDoc,
        );

        if (entityUsers.isEmpty) {
          hasMoreEntityParticipants = false;
        } else {
          _lastEntityDoc = lastEntityDoc;
          for (var user in entityUsers) {
            final key = user.userId ?? user.email;
            if (!_participantCache.containsKey(key)) {
              _participantCache[key] = user;
              allParticipants.add(user);
              added++;
            }
          }
          if (entityUsers.length < 10) {
            hasMoreEntityParticipants = false;
          }
        }
      }

      // Fetch from programs query
      if (hasMoreProgramParticipants && _currentPrograms.isNotEmpty) {
        final (programUsers, lastProgramDoc) = await database.getParticipantsByProgramsPaginated(
          _currentPrograms,
          limit: 10,
          startAfterDocument: _lastProgramDoc,
        );

        if (programUsers.isEmpty) {
          hasMoreProgramParticipants = false;
        } else {
          _lastProgramDoc = lastProgramDoc;
          for (var user in programUsers) {
            final key = user.userId ?? user.email;
            if (!_participantCache.containsKey(key)) {
              _participantCache[key] = user;
              allParticipants.add(user);
              added++;
            }
          }
          if (programUsers.length < 10) {
            hasMoreProgramParticipants = false;
          }
        }
      }
    } catch (e) {
      print('Error fetching paginated participants: $e');
    } finally {
      isLoadingParticipants = false;
      _notifyPaginationListeners();
    }
  }

  /// Reset pagination state (e.g., when navigating away)
  void resetPagination() {
    _initialLoadDone = false;
    _lastEntityDoc = null;
    _lastProgramDoc = null;
    hasMoreEntityParticipants = true;
    hasMoreProgramParticipants = true;
    allParticipants.clear();
    _participantCache.clear();
  }

  Future<void> warmUpAll(Database database) {
    if (_warmUpFuture != null) return _warmUpFuture!;

    _warmUpFuture = Future.wait([
      database.countriesStream().first.then((value) => countries = value),
      database.provincesStream().first.then((value) => provinces = value),
      database.citiesStream().first.then((value) => cities = value),
      database.gamificationFlagsStream().first.then((value) => gamificationFlags = value),
      database.getCompetencies().then((value) => competencies = value),
      database.getInterests().then((value) => interests = value),
      database.getAbilities().then((value) => abilities = value),
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
    final user = await database.getUser(id);
    if (user != null) userCache[id] = user;
    return user;
  }
}
