// Gemini service with stable v1 API and model fallback (restored standard key)
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../env.dart';
import 'ai_service.dart';

/// Central service for all Gemini AI features.
class GeminiService {
  GeminiService._();
  static final GeminiService instance = GeminiService._();

  GenerativeModel? _model;
  GenerativeModel? _visionModel;

  String _activeModelName = 'gemini-1.5-flash';

  final List<String> _fallbackModels = [
    'gemini-1.5-flash',
    'gemini-1.5-flash-8b',
    'gemini-1.5-flash-latest',
    'gemini-1.5-pro',
    'gemini-2.0-flash',
    'gemini-pro',
  ];

  bool get isAvailable => Env.aiApiKey.isNotEmpty;
  bool get _isGroq => Env.aiApiKey.startsWith('gsk_');

  Future<String> _callGroq({
    required String systemInstruction,
    required String prompt,
    List<({String mimeType, List<int> bytes})>? images,
  }) async {
    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    final headers = {
      'Authorization': 'Bearer ${Env.aiApiKey}',
      'Content-Type': 'application/json',
    };

    final isVision = images != null && images.isNotEmpty;
    final model = isVision
        ? 'llama-3.2-11b-vision-preview'
        : 'llama-3.1-70b-versatile';

    final messages = <Map<String, dynamic>>[];
    if (systemInstruction.isNotEmpty) {
      messages.add({'role': 'system', 'content': systemInstruction});
    }

    if (isVision) {
      final contentList = <Map<String, dynamic>>[
        {'type': 'text', 'text': prompt},
      ];
      for (final img in images) {
        final base64Img = base64Encode(img.bytes);
        contentList.add({
          'type': 'image_url',
          'image_url': {'url': 'data:${img.mimeType};base64,$base64Img'},
        });
      }
      messages.add({'role': 'user', 'content': contentList});
    } else {
      messages.add({'role': 'user', 'content': prompt});
    }

    final body = jsonEncode({
      'model': model,
      'messages': messages,
      'temperature': 0.2,
    });

    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] ?? '';
    } else {
      throw Exception(
        'Groq API Error: ${response.statusCode} - ${response.body}',
      );
    }
  }

  void _resetModel(String newModelName) {
    _activeModelName = newModelName;
    _model = null;
    _visionModel = null;
  }

  GenerativeModel get _chat {
    _model ??= GenerativeModel(
      model: _activeModelName,
      apiKey: Env.geminiApiKey,
      requestOptions: const RequestOptions(apiVersion: 'v1beta'),
      systemInstruction: Content.system(
        'You are an expert AI agronomist specializing in smallholder farming '
        'in Southern and East Africa. You give practical, concise advice '
        'tailored to local conditions, common crops like maize, tobacco, '
        'cotton, and soya. Always be encouraging, use simple language, '
        'and be aware of limited resources. Format responses with clear '
        'bullet points or short paragraphs. Keep responses under 200 words '
        'unless a detailed explanation is specifically needed.',
      ),
    );
    return _model!;
  }

  GenerativeModel get _vision {
    _visionModel ??= GenerativeModel(
      model: _activeModelName,
      apiKey: Env.geminiApiKey,
      requestOptions: const RequestOptions(apiVersion: 'v1beta'),
    );
    return _visionModel!;
  }

  Future<T> _runWithFallback<T>(Future<T> Function() action) async {
    int attempt = _fallbackModels.indexOf(_activeModelName);
    if (attempt < 0) attempt = 0;

    while (true) {
      try {
        return await action();
      } catch (e) {
        final errStr = e.toString().toLowerCase();
        if ((errStr.contains('not found') ||
                errStr.contains('404') ||
                errStr.contains('not supported') ||
                errStr.contains('quota exceeded') ||
                errStr.contains('exhausted') ||
                errStr.contains('limit: 0')) &&
            attempt < _fallbackModels.length - 1) {
          attempt++;
          _resetModel(_fallbackModels[attempt]);
          continue; // Try with the next model
        }
        rethrow;
      }
    }
  }

  /// Ask the AI agronomist a question with optional farm context.
  Future<String> askAgronomist(
    String question, {
    String? farmContext,
    List<({String mimeType, List<int> bytes})>? images,
  }) async {
    if (!isAvailable) return _offlineMessage;
    final systemPrompt =
        'You are an expert AI agronomist specializing in smallholder farming '
        'in Southern and East Africa. You give practical, concise advice '
        'tailored to local conditions, common crops like maize, tobacco, '
        'cotton, and soya. Always be encouraging, use simple language, '
        'and be aware of limited resources. Format responses with clear '
        'bullet points or short paragraphs. Keep responses under 200 words '
        'unless a detailed explanation is specifically needed.';
    final userPrompt = farmContext != null
        ? 'Farm context: $farmContext\n\nQuestion: $question'
        : question;

    if (_isGroq) {
      try {
        return await _callGroq(
          systemInstruction: systemPrompt,
          prompt: userPrompt,
          images: images,
        );
      } catch (e) {
        return 'AI is temporarily unavailable. Please try again. ($e)';
      }
    }

    return _runWithFallback(() async {
      final parts = <Part>[];
      if (farmContext != null) {
        parts.add(
          TextPart('Farm context: $farmContext\n\nQuestion: $question'),
        );
      } else {
        parts.add(TextPart(question));
      }
      if (images != null) {
        for (final img in images) {
          parts.add(DataPart(img.mimeType, Uint8List.fromList(img.bytes)));
        }
      }
      final response = await _vision.generateContent([Content.multi(parts)]);
      return response.text ?? 'No response received.';
    }).catchError((e) {
      return 'AI is temporarily unavailable. Please try again. ($e)';
    });
  }

  /// Process a free-text entry and structure it into form fields.
  /// Returns a JSON-like string that the calling screen parses.
  Future<Map<String, String>> processEntry(
    String rawText,
    String entryType, {
    String? farmCrops,
  }) async {
    if (!isAvailable) return {};

    final schema = <String, dynamic>{};
    if (entryType == 'activity') {
      schema.addAll({
        'activity_type': 'String',
        'crop': 'String',
        'date': 'YYYY-MM-DD',
        'notes': 'String',
        'yield_quantity': 'double',
        'yield_unit': 'String',
      });
    } else if (entryType == 'expense') {
      schema.addAll({
        'amount': 'double',
        'category': 'String',
        'date': 'YYYY-MM-DD',
        'notes': 'String',
      });
    } else {
      schema.addAll({
        'crop': 'String',
        'buyer': 'String',
        'date': 'YYYY-MM-DD',
        'price_per_unit': 'double',
        'quantity_sold': 'double',
        'total_revenue': 'double',
      });
    }

    final prompt =
        'You are helping a farmer fill in a form. Extract key information from this note:\n'
        '"$rawText"\n\n'
        'Entry type: $entryType\n'
        '${farmCrops != null ? "Known crops on this farm: $farmCrops\n" : ""}'
        'Use today (${DateTime.now().toIso8601String().substring(0, 10)}) as default date if not specified.';

    try {
      final jsonMap = await AIService.instance.structured(
        prompt,
        schema,
        systemInstruction:
            'You are a precise data extractor. You only return valid JSON.',
      );

      final Map<String, String> result = {};
      jsonMap.forEach((key, val) {
        if (val != null) {
          result[key] = val.toString();
        }
      });
      return result;
    } catch (_) {
      return {};
    }
  }

  /// Generate smart dashboard insights based on farm data.
  Future<List<String>> generateDashboardInsights({
    required String farmName,
    required List<String> crops,
    required String region,
    required String country,
    required int activityCount,
    required double totalRevenue,
    required double totalExpenses,
  }) async {
    if (!isAvailable) {
      return [
        'Log your first activity to receive personalised AI recommendations.',
        'Set up your full farm profile for better crop advice.',
      ];
    }
    final prompt =
        '''
Generate 3 short, practical agronomic recommendations for this farm:
- Farm: $farmName
- Location: $region, $country
- Crops: ${crops.join(', ')}
- Activities logged this month: $activityCount
- Revenue: \$$totalRevenue
- Expenses: \$$totalExpenses
- Current season: ${_currentSeason(country)}

Each recommendation should be 1-2 sentences, actionable, and specific to their crops and region.
Return as a JSON array of strings. Example: ["Tip 1", "Tip 2", "Tip 3"]
Return ONLY the JSON array, no other text.
''';

    String text;
    if (_isGroq) {
      try {
        text = await _callGroq(
          systemInstruction:
              'You are a precise agricultural intelligence assistant. Always return recommendations as a JSON array of strings.',
          prompt: prompt,
        );
      } catch (_) {
        return [
          'Keep logging activities for personalised AI advice.',
          'Track your expenses to understand your profit margins.',
        ];
      }
    } else {
      try {
        final response = await _chat.generateContent([Content.text(prompt)]);
        text = response.text ?? '[]';
      } catch (_) {
        return [
          'Keep logging activities for personalised AI advice.',
          'Track your expenses to understand your profit margins.',
        ];
      }
    }

    final cleaned = text.replaceAll('```json', '').replaceAll('```', '').trim();
    final regex = RegExp(r'"([^"]+)"');
    return regex
        .allMatches(cleaned)
        .map((m) => m.group(1)!)
        .where((s) => s.length > 10)
        .take(3)
        .toList();
  }

  /// Generate smart financial/accounting advice and a credit score rationale.
  Future<String> generateAccountingAdvice({
    required double totalIncome,
    required double totalExpenses,
    required double netProfit,
    required double creditScore,
    required String country,
    required List<String> crops,
  }) async {
    if (!isAvailable) {
      return 'Connect to the internet to load AI accounting recommendations.';
    }
    final prompt =
        '''
Provide financial/accounting advice and loan readiness feedback for this farm:
- Country: $country
- Crops: ${crops.join(', ')}
- Total Income: \$$totalIncome
- Total Expenses: \$$totalExpenses
- Net Profit: \$$netProfit
- Calculated Credit Score: ${creditScore.toInt()}/1000

Format your response as a concise summary with:
1. **Financial Health Rating**: An assessment of their income-to-expense ratio.
2. **Loan Readiness Tips**: Actionable steps to improve their eligibility for bank loans.
3. **Tailored Financial Advice**: specific advice for managing cash flow for their crops in their region.

Keep it professional, encouraging, and under 250 words. Use bullet points where appropriate.
''';

    if (_isGroq) {
      try {
        return await _callGroq(
          systemInstruction:
              'You are an expert farm accounting advisor and microfinance credit officer specializing in smallholder agriculture in Southern and East Africa.',
          prompt: prompt,
        );
      } catch (e) {
        return 'AI accounting advice is temporarily unavailable. ($e)';
      }
    } else {
      return _runWithFallback(() async {
        final response = await _chat.generateContent([Content.text(prompt)]);
        return response.text ?? 'Could not retrieve financial advice.';
      }).catchError(
        (e) => 'AI accounting advice is temporarily unavailable. ($e)',
      );
    }
  }

  String _currentSeason(String country) {
    final month = DateTime.now().month;
    // Southern hemisphere
    final southernCountries = [
      'Zimbabwe',
      'Zambia',
      'Mozambique',
      'South Africa',
      'Malawi',
    ];
    if (southernCountries.contains(country)) {
      if (month >= 11 || month <= 3) return 'Rainy season (planting)';
      if (month >= 4 && month <= 7) return 'Post-harvest / dry season';
      return 'Pre-planting preparation';
    }
    // East Africa
    if (month >= 3 && month <= 5) return 'Long rains (planting)';
    if (month >= 10 && month <= 12) return 'Short rains (second planting)';
    return 'Dry season';
  }

  /// Generate dynamic export reports based on database snapshot in chosen format.
  Future<String> generateExportReport({
    required String format,
    required List<dynamic> profiles,
    required List<dynamic> incomes,
    required List<dynamic> expenses,
    required List<dynamic> activities,
  }) async {
    if (!isAvailable) {
      return 'AI features require a valid connection to generate reports.';
    }

    final p = profiles.isNotEmpty ? profiles.first : null;
    final farmName = p?.farmName ?? 'My Farm';
    final region = p?.region ?? 'Harare';
    final country = p?.country ?? 'Zimbabwe';
    final primaryCrop = p?.primaryCrop ?? 'Maize';
    final size = p?.farmSize ?? 0.0;

    final prompt =
        '''
You are an expert agricultural accountant and farm inspector. Generate a comprehensive farm export report for the following farm details:
- Farm Name: $farmName
- Location: $region, $country
- Farm Size: $size hectares
- Primary Crop: $primaryCrop

Database Records:
- Income Records: ${incomes.map((i) => '{Crop: ${i.crop}, Buyer: ${i.buyer}, Revenue: ${i.totalRevenue}, Date: ${i.incomeDate}}').join(', ')}
- Expense Records: ${expenses.map((e) => '{Category: ${e.category}, Amount: ${e.amount}, Date: ${e.expenseDate}, Notes: ${e.notes}}').join(', ')}
- Activities: ${activities.map((a) => '{Type: ${a.activityType}, Crop: ${a.crop}, Date: ${a.activityDate}}').join(', ')}

Requested Export Format: $format

INSTRUCTIONS:
1. If the format is 'CSV', output only a valid, comma-separated CSV with headers: Date,Record Type,Category/Crop,Details,Amount. Start immediately with the CSV header, no other conversational filler.
2. If the format is 'WORD' or 'PDF', output a beautifully styled, complete HTML document starting with <html> and ending with </html>. Use CSS in <style> to format the layout with a dark forest green header, tables, bullet points, clean margins, and clear sections. Include sections:
   - Executive Farm Summary
   - AI Cash Flow & P&L Statement (with dynamic tables)
   - Farm Health & Activity Log Analysis
   - Personalized Agronomic Recommendations & Cost Optimization Tips
   Keep the styling premium (gold borders, forest green headers, clean modern sans-serif typography). Do not output markdown code blocks (e.g., ```html). Just return the raw HTML code immediately starting with <html>.
''';

    if (_isGroq) {
      try {
        return await _callGroq(
          systemInstruction:
              'You are an expert farm accounting advisor and auditor specializing in Southern and East Africa.',
          prompt: prompt,
        );
      } catch (e) {
        return 'Failed to generate report: $e';
      }
    } else {
      return _runWithFallback(() async {
        final response = await _chat.generateContent([Content.text(prompt)]);
        return response.text ?? 'Failed to generate report.';
      }).catchError((e) => 'Failed to generate report: $e');
    }
  }

  static const _offlineMessage =
      'AI agronomist requires an internet connection. Please check your connection and try again.';
}
