import 'package:enreda_empresas/app/models/externalSocialEntity.dart';
import 'package:enreda_empresas/app/services/database.dart';

/// Session-scoped cache for a social entity's contacts (agenda de contactos).
/// Fetched once with a single .get() and reused across navigation, so
/// returning to the list re-reads 0 documents. Invalidate after any
/// create/edit/delete so the next visit reloads fresh data.
class ExternalEntitiesCache {
  ExternalEntitiesCache._();
  static final ExternalEntitiesCache instance = ExternalEntitiesCache._();

  String? _socialEntityId;
  List<ExternalSocialEntity>? _entities;

  bool isLoadedFor(String socialEntityId) =>
      _entities != null && _socialEntityId == socialEntityId;

  Future<List<ExternalSocialEntity>> load(
      Database database, String socialEntityId) async {
    if (isLoadedFor(socialEntityId)) return _entities!;
    final list = await database.getExternalSocialEntities(socialEntityId);
    _socialEntityId = socialEntityId;
    _entities = list;
    return list;
  }

  void invalidate() {
    _entities = null;
    _socialEntityId = null;
  }
}
