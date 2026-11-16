import 'package:agroedge_shared/models/ai-crop-plan.dart';

import '../core/api_client.dart';

/// Maps to the /ai-crop-plans resource in
/// packages/shared/openapi/openapi.yaml. Backs the Home screen's AI
/// Insights section (read-only for this pilot -- no create/edit UI).
class AiCropPlanRepository {
  AiCropPlanRepository(this._client);

  final ApiClient _client;

  Future<List<AiCropPlan>> list({int limit = 20}) async {
    final json = await _client.getJson(
      '/ai-crop-plans',
      query: {'limit': limit},
    );
    return AiCropPlanListResponse.fromJson(json).data;
  }
}
