import 'package:agroedge_shared/models/ai-insight.dart';

import '../core/api_client.dart';

/// Maps to the /ai-insights resource in
/// packages/shared/openapi/openapi.yaml. Backs the Home screen's AI
/// Insights section (read-only for this pilot -- no create/edit UI).
class AiInsightRepository {
  AiInsightRepository(this._client);

  final ApiClient _client;

  Future<List<AiInsight>> list({int limit = 20}) async {
    final json = await _client.getJson('/ai-insights', query: {'limit': limit});
    return AiInsightListResponse.fromJson(json).data;
  }
}
