import 'dart:convert';

import 'package:agroedge_shared/models/_generated/openapi.models.swagger.dart'
    show ApiError;
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'env.dart';

/// Thrown when services/api returns a non-2xx response.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Thin HTTP client for services/api. Every farmer-facing screen goes
/// through this -- no screen calls Supabase or any vendor SDK for farm
/// data directly. Attaches the current Supabase session's JWT so
/// services/api's row-level-security-backed auth can scope the request.
class ApiClient {
  ApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final normalized = query?.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    return Uri.parse(
      '${Env.apiBaseUrl}$path',
    ).replace(queryParameters: normalized);
  }

  Map<String, String> _headers() {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final response = await _httpClient.get(
      _uri(path, query),
      headers: _headers(),
    );
    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _httpClient.post(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body),
    );
    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> patchJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _httpClient.patch(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body),
    );
    return _decodeObject(response);
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return const {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw ApiException(
      _extractMessage(response),
      statusCode: response.statusCode,
    );
  }

  String _extractMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiError.fromJson(decoded).message;
    } catch (_) {
      return 'Request failed with status ${response.statusCode}.';
    }
  }
}
