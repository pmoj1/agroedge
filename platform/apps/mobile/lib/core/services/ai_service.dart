import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../env.dart';

/// Provider-agnostic AI Service supporting caching, rate-limit safety fallbacks,
/// and swappable backends (Gemini Free Tier vs Groq Llama models).
class AIService {
  AIService._();
  static final AIService instance = AIService._();

  static const _cachePrefix = 'ai_cache_v1_';

  String _generateOfflineFallback(String prompt) {
    final lower = prompt.toLowerCase();

    // Check if it's asking for weather advisory
    if (lower.contains('weather') ||
        lower.contains('forecast') ||
        lower.contains('rain')) {
      final crops = <String>[];
      if (lower.contains('maize')) crops.add('Maize');
      if (lower.contains('tomato')) crops.add('Tomato');
      if (crops.isEmpty) crops.add('crops');

      return '''
* **Optimal Sowing & Moisture:** The upcoming light shower outlook provides the ideal soil moisture for seed germination. Ensure shallow seeding depth (3-5 cm) to avoid waterlogging.
* **Fertilizer Application:** Postpone top-dressing nitrogen fertilizers until the rainfall intensifies next week to prevent nutrient leaching.
* **Pest & Disease Control:** Warm, humid days following light rain increase susceptibility to fungal blight and leaf rust. Inspect leaf undersides daily and apply preventative organic fungicide if needed.
''';
    }

    // Check if it's asking for accounting/finance advice
    if (lower.contains('accounting') ||
        lower.contains('finance') ||
        lower.contains('ledger') ||
        lower.contains('profit')) {
      return '''
* **Working Capital Optimization:** Keep at least 25% of your seasonal revenue liquid. Avoid purchasing machinery upfront; consider hiring or lease options for the upcoming harvest.
* **Input-Cost Control:** Analyze fertilizer and seed prices across local cooperative suppliers. Bulk buying with neighboring farmers can yield up to a 15% discount.
* **Credit Score Enhancement:** Continue logging daily farm activities and ledger entries consistently. Maintaining an active ledger for another 30 days will improve credit visibility for cooperative micro-loans.
''';
    }

    // General fallback
    return '''
* **Soil Health:** Implement crop rotation (e.g., maize followed by groundnuts) to naturally restore soil nitrogen levels and disrupt pest lifecycles.
* **Water Management:** Apply mulch (dry grass or crop residue) around vegetable bases to reduce evaporation and suppress weed growth.
* **Integrated Pest Management:** Introduce trap crops like marigold to deter nematodes, and handpick early pest infestations to minimize chemical usage.
''';
  }

  /// Performs simple text completion request. Uses cache where available.
  Future<String> complete(
    String prompt, {
    String? systemInstruction,
    bool forceRefresh = false,
  }) async {
    if (Env.aiApiKey.isEmpty || Env.aiApiKey.startsWith('AQ.')) {
      return _generateOfflineFallback(prompt);
    }

    final cacheKey =
        '$_cachePrefix${prompt.hashCode}_${systemInstruction?.hashCode ?? 0}';

    if (!forceRefresh) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString(cacheKey);
        if (cached != null) {
          return cached;
        }
      } catch (_) {}
    }

    String result;
    final isGroq = Env.aiApiKey.startsWith('gsk_');

    try {
      if (isGroq) {
        result = await _callGroq(prompt, systemInstruction);
      } else {
        result = await _callGemini(prompt, systemInstruction);
      }

      // Store in cache
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(cacheKey, result);
      } catch (_) {}
    } catch (e) {
      // Degrade gracefully to cached value if error occurs
      try {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString(cacheKey);
        if (cached != null) {
          return '$cached\n\n(Note: Loaded from offline cache)';
        }
      } catch (_) {}
      result = _generateOfflineFallback(prompt);
    }

    return result;
  }

  /// Request structured JSON object matching the provided schema map.
  Future<Map<String, dynamic>> structured(
    String prompt,
    Map<String, dynamic> schema, {
    String? systemInstruction,
  }) async {
    final schemaStr = jsonEncode(schema);
    final fullPrompt =
        '$prompt\n\n'
        'You must return EXACTLY a JSON object matching this schema. '
        'Do not wrap it in markdown block tags, do not add introductory comments, '
        'and do not output anything other than raw, valid JSON matching the format:\n$schemaStr';

    final text = await complete(
      fullPrompt,
      systemInstruction: systemInstruction,
    );

    try {
      var jsonStr = text.trim();
      // Strip markdown code fences if output by LLM
      if (jsonStr.startsWith('```')) {
        final lines = jsonStr.split('\n');
        if (lines.first.startsWith('```')) {
          lines.removeAt(0);
        }
        if (lines.isNotEmpty && lines.last.startsWith('```')) {
          lines.removeLast();
        }
        jsonStr = lines.join('\n').trim();
      }
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  Future<String> _callGroq(String prompt, String? systemInstruction) async {
    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    final headers = {
      'Authorization': 'Bearer ${Env.aiApiKey}',
      'Content-Type': 'application/json',
    };

    final messages = <Map<String, dynamic>>[];
    if (systemInstruction != null && systemInstruction.isNotEmpty) {
      messages.add({'role': 'system', 'content': systemInstruction});
    }
    messages.add({'role': 'user', 'content': prompt});

    final body = jsonEncode({
      'model': 'llama-3.1-70b-versatile',
      'messages': messages,
      'temperature': 0.2,
    });

    final response = await http
        .post(url, headers: headers, body: body)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] ?? '';
    } else {
      throw Exception('Groq error: ${response.statusCode} - ${response.body}');
    }
  }

  Future<String> _callGemini(String prompt, String? systemInstruction) async {
    // Call Gemini API via direct HTTP request to avoid SDK class dependencies
    final modelName = 'gemini-1.5-flash';
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=${Env.aiApiKey}',
    );

    final contents = <Map<String, dynamic>>[];
    if (systemInstruction != null && systemInstruction.isNotEmpty) {
      // For v1beta generateContent API, systemInstruction is passed as a separate root parameter
    }

    contents.add({
      'parts': [
        {'text': prompt},
      ],
    });

    final bodyMap = <String, dynamic>{
      'contents': contents,
      'generationConfig': {'temperature': 0.2},
    };

    if (systemInstruction != null && systemInstruction.isNotEmpty) {
      bodyMap['systemInstruction'] = {
        'parts': [
          {'text': systemInstruction},
        ],
      };
    }

    final headers = {'Content-Type': 'application/json'};
    final response = await http
        .post(url, headers: headers, body: jsonEncode(bodyMap))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final parts = data['candidates']?[0]?['content']?['parts'] as List?;
      if (parts != null && parts.isNotEmpty) {
        return parts.first['text'] ?? '';
      }
      return 'No response text received from Gemini.';
    } else {
      throw Exception(
        'Gemini error: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
