import 'dart:async';
import 'package:enreda_empresas/app/models/city.dart';
import 'package:enreda_empresas/app/models/country.dart';
import 'package:enreda_empresas/app/models/gamificationFlags.dart';
import 'package:enreda_empresas/app/models/province.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/database.dart';

class LocationCache {
  LocationCache._();
  static final LocationCache instance = LocationCache._();

  Future<void>? _warmUpFuture;

  List<Country> countries = [];
  List<Province> provinces = [];
  List<City> cities = [];
  List<GamificationFlag> gamificationFlags = [];
  
  List<UserEnreda>? cachedParticipants;
  StreamSubscription? _assignedSubscription;
  StreamSubscription? _programSubscription;
  final StreamController<List<UserEnreda>> _participantsController = StreamController<List<UserEnreda>>.broadcast();

  Stream<List<UserEnreda>> get participantsStream => _participantsController.stream;

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


  Future<void> warmUpAll(Database database) {
    if (_warmUpFuture != null) return _warmUpFuture!;

    _warmUpFuture = Future.wait([
      database.countriesStream().first.then((value) => countries = value),
      database.provincesStream().first.then((value) => provinces = value),
      database.citiesStream().first.then((value) => cities = value),
      database.gamificationFlagsStream().first.then((value) => gamificationFlags = value),
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
}
