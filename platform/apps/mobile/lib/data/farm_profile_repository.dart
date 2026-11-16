import 'package:agroedge_shared/models/farm-profile.dart';

import '../core/api_client.dart';

/// Reads and writes the authenticated farmer's farm profile via
/// services/api. Maps directly to the /farm-profiles resource in
/// packages/shared/openapi/openapi.yaml.
class FarmProfileRepository {
  FarmProfileRepository(this._client);

  final ApiClient _client;

  Future<List<FarmProfile>> list() async {
    final json = await _client.getJson('/farm-profiles');
    return FarmProfileListResponse.fromJson(json).data;
  }

  Future<FarmProfile> create(FarmProfileCreate input) async {
    final json = await _client.postJson('/farm-profiles', input.toJson());
    return FarmProfile.fromJson(json);
  }

  Future<FarmProfile> update(String id, FarmProfileCreate input) async {
    final json = await _client.patchJson('/farm-profiles/$id', input.toJson());
    return FarmProfile.fromJson(json);
  }
}
