import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RagService {
  static const String _baseUrlFromEnv =
      String.fromEnvironment(
        'SPENDSENSE_API_BASE_URL',
        defaultValue: 'http://localhost:8000',
      );

  String get baseUrl => _baseUrlFromEnv;

  Future<Map<String, dynamic>> analyzeText(String text) async {
    final uri = Uri.parse("$baseUrl/transaction");

    try {
      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "text": text,
              "current_monthly_spend": 0,
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw Exception(
          "API failed (${response.statusCode}) at $uri: ${response.body}",
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception("Unexpected API response format from $uri");
      }

      return decoded;
    } on TimeoutException {
      throw Exception("API request timed out for $uri");
    }
  }
}
