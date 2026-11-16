import 'package:agroedge_shared/models/activity.dart';

import '../core/api_client.dart';

/// Maps to the /activities resource in
/// packages/shared/openapi/openapi.yaml. Backs both the Home screen's
/// recent-activities list and the Log Activity screen.
class ActivityRepository {
  ActivityRepository(this._client);

  final ApiClient _client;

  Future<List<Activity>> list({int limit = 20}) async {
    final json = await _client.getJson('/activities', query: {'limit': limit});
    return ActivityListResponse.fromJson(json).data;
  }

  Future<Activity> create(ActivityCreate input) async {
    final json = await _client.postJson('/activities', input.toJson());
    return Activity.fromJson(json);
  }
}
