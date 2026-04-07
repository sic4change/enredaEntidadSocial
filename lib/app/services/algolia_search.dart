import 'package:algoliasearch/algoliasearch.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';

class AlgoliaSearch {
  static final SearchClient _client = SearchClient(
    appId: 'BHQG81KUSV',
    apiKey: 'bd1a42613c3da346253dc30f36e820dd',
  );

  /// Search for participants (users)
  static Future<List<UserEnreda>> queryParticipants(String searchQuery) async {
    if (searchQuery.isEmpty) return [];

    try {
      final result = await _client.searchIndex(
        request: SearchForHits(
          indexName: 'users_index', // Assuming this is the index name
          query: searchQuery,
        ),
      );

      return result.hits.map((hit) {
        // Create a mutable copy and ensure userId is present for the model
        final data = Map<String, dynamic>.from(hit.toJson());
        final objectID = hit.objectID;
        if (data['userId'] == null) data['userId'] = objectID;
        
        return UserEnreda.fromMap(data, objectID);
      }).toList();
    } catch (e) {
      print('Algolia search error: $e');
      return [];
    }
  }
}
