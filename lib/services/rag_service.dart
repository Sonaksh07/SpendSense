import 'dart:convert';
import 'package:http/http.dart' as http;

class RagService {
  final String baseUrl = "http://10.93.3.38:8000";
//10.0.2.2
  Future<Map<String, dynamic>> analyzeText(String text) async {
    final response = await http.post(
      Uri.parse("$baseUrl/transaction"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "text": text,
        "current_monthly_spend": 0
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("API failed");
    }
  }
}