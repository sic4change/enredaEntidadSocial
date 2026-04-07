import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PersistenceService {
  PersistenceService._();
  static final PersistenceService instance = PersistenceService._();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> saveCatalog(String key, List<dynamic> data) async {
    final prefs = await _prefs;
    final jsonString = jsonEncode(data.map((e) {
      try {
        final map = e.toMap();
        // Convert any DateTime to String for JSON safety
        map.forEach((key, value) {
          if (value is DateTime) {
            map[key] = value.toIso8601String();
          }
        });
        return map;
      } catch (_) {
        return e;
      }
    }).toList());
    await prefs.setString(key, jsonString);
  }

  Future<List<dynamic>?> loadCatalog(String key) async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(key);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final list = jsonDecode(jsonString) as List<dynamic>;
        // DateTime strings don't need explicit back-conversion here 
        // IF the model.fromMap handles strings or we handle it in fromMap
        return list;
      } catch (e) {
        print("Error decoding catalog $key: $e");
        return null;
      }
    }
    return null;
  }

  Future<bool> hasCatalog(String key) async {
    final prefs = await _prefs;
    return prefs.containsKey(key);
  }
  
  Future<void> clearCatalog(String key) async {
    final prefs = await _prefs;
    await prefs.remove(key);
  }
}
