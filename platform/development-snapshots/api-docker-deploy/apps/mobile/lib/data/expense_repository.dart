import 'package:agroedge_shared/models/expense.dart';

import '../core/api_client.dart';

/// Maps to the /expenses resource in
/// packages/shared/openapi/openapi.yaml. Backs the Log Expense screen.
class ExpenseRepository {
  ExpenseRepository(this._client);

  final ApiClient _client;

  Future<Expense> create(ExpenseCreate input) async {
    final json = await _client.postJson('/expenses', input.toJson());
    return Expense.fromJson(json);
  }
}
