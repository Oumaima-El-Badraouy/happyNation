// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api";

  // -------------------------
  // Questions
  // -------------------------
static Future<dynamic> getQuestions(AuthService auth) async {
  final token = await auth.getToken();
  final res = await http.get(
    Uri.parse("$baseUrl/questions"),
    headers: _headers(token),
  );

  if (res.statusCode == 200) {
    return jsonDecode(res.body); // peut être Map ou List
  }
  return null;
}


  static Future<bool> createQuestion(Map<String, dynamic> payload, AuthService auth) async {
    final token = await auth.getToken();
    final res = await http.post(
      Uri.parse("$baseUrl/questions"),
      headers: _headers(token),
      body: jsonEncode(payload),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  static Future<bool> updateQuestion(int id, Map<String, dynamic> payload, AuthService auth) async {
    final token = await auth.getToken();
    final res = await http.put(
      Uri.parse("$baseUrl/questions/$id"),
      headers: _headers(token),
      body: jsonEncode(payload),
    );
    return res.statusCode == 200;
  }

  static Future<bool> deleteQuestion(int id, AuthService auth) async {
    final token = await auth.getToken();
    final res = await http.delete(
      Uri.parse("$baseUrl/questions/$id"),
      headers: _headers(token),
    );
    return res.statusCode == 200 || res.statusCode == 204;
  }

  // -------------------------
  // Responses (user)
  // -------------------------
  static Future<Map<String, dynamic>> sendResponses(Map answers, AuthService auth) async {
    final token = await auth.getToken();
    print('token est : $token');
print('answers est : $answers');
    final res = await http.post(
      Uri.parse("$baseUrl/responses"),
      headers: _headers(token),
      body: jsonEncode({"answers": answers}),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception("Failed to submit responses: ${res.statusCode} ${res.body}");
  }

  static Future<List<dynamic>> getHistory(AuthService auth) async {
    final token = await auth.getToken();
    final res = await http.get(
      Uri.parse("$baseUrl/responses/history"),
      headers: _headers(token),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  // -------------------------
  // Admin - Users
  // -------------------------
  static Future<List<dynamic>> getUsers(AuthService auth) async {
    final token = await auth.getToken();
    final res = await http.get(
      Uri.parse("$baseUrl/users"),
      headers: _headers(token),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    return [];
  }

  static Future<bool> createUser(Map<String, dynamic> body, AuthService auth) async {
    final token = await auth.getToken();
    final res = await http.post(
      Uri.parse("$baseUrl/users"),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  static Future<bool> updateUser(int id, Map<String, dynamic> body, AuthService auth) async {
    final token = await auth.getToken();
    final res = await http.put(
      Uri.parse("$baseUrl/users/$id"),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    return res.statusCode == 200;
  }

  static Future<bool> deleteUser(int id, AuthService auth) async {
    final token = await auth.getToken();
    final res = await http.delete(
      Uri.parse("$baseUrl/users/$id"),
      headers: _headers(token),
    );
    return res.statusCode == 200 || res.statusCode == 204;
  }

  // -------------------------
  // Admin - Dashboard / Stats
  // -------------------------
 static Future<Map<String, dynamic>> getDashboardStats(AuthService auth) async {
  final token = await auth.getToken();
  print("Token: $token"); // debug
  final res = await http.get(
    Uri.parse("$baseUrl/admin/statistics/global"),
    headers: _headers(token),
  );
  print("Status code: ${res.statusCode}");
  print("Body: ${res.body}");
  if (res.statusCode == 200) {
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
  throw Exception("Failed to load stats: ${res.statusCode}");
}


  // -------------------------
  // AI Config
  // -------------------------
  static Future<Map<String, dynamic>> getAiSettings(AuthService auth) async {
    final token = await auth.getToken();
    final res = await http.get(
      Uri.parse("$baseUrl/admin/aiconfig"),
      headers: _headers(token),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {};
  }

  static Future<bool> updateAiSettings(Map<String, dynamic> body, AuthService auth) async {
    final token = await auth.getToken();
    final res = await http.put(
      Uri.parse("$baseUrl/admin/aiconfig"),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    return res.statusCode == 200;
  }

  // -------------------------
  // Helpers
  // -------------------------
  static Map<String, String> _headers(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }


  
}
