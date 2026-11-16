import 'package:agroedge_shared/models/income-record.dart';

import '../core/api_client.dart';

/// Maps to the /income-records resource in
/// packages/shared/openapi/openapi.yaml. Backs the Log Income screen and
/// the Home screen's income stats and activity feed.
class IncomeRepository {
  IncomeRepository(this._client);

  final ApiClient _client;

  Future<List<IncomeRecord>> list({int limit = 100}) async {
    final json = await _client.getJson('/income-records', query: {'limit': limit});
    return IncomeRecordListResponse.fromJson(json).data;
  }

  Future<IncomeRecord> create(IncomeRecordCreate input) async {
    final json = await _client.postJson('/income-records', input.toJson());
    return IncomeRecord.fromJson(json);
  }
}
