import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  String? _token;
  String? _role;

  String? get token => _token;
  String? get role => _role;

  // =========================================================
  // Headers
  // =========================================================
  static Map<String, String> _headers(String? token) {
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }
  // =========================================================
  // LOGIN
  // =========================================================
  Future<void> login(String email, String password) async {
    final url = Uri.parse("http://127.0.0.1:8000/api/login"); // important si emulator
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      _token = data['access_token'];
      _role = data['user']['role'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", _token!);
      await prefs.setString("role", _role!);

      notifyListeners();
    } else {
      throw Exception("Login failed");
    }
  }

  // =========================================================
  // GET TOKEN
  // =========================================================
  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("token");
    return _token;
  }

  // =========================================================
  // GET PROFILE
  // =========================================================

Future<bool> updateProfile(Map<String, dynamic> payload) async {
  try {
    print('🔹 URL: http://127.0.0.1:8000/api/me/updates');
    print('🔹 Payload envoyé: ${jsonEncode(payload)}');
    print('🔹 Headers: ${_headers(token)}');

    final res = await http.put(
      Uri.parse("http://127.0.0.1:8000/api/me/update"),
      headers: _headers(token),
      body: jsonEncode(payload),
    );

    print('🔹 Status code: ${res.statusCode}');
    print('🔹 Body de la réponse: ${res.body}');

    return res.statusCode == 200;
  } catch (e) {
    print('❌ Erreur lors de la mise à jour: $e');
    return false;
  }
}



Future<Map<String, dynamic>?> getProfile() async {
  final res = await http.get(
    Uri.parse("http://127.0.0.1:8000/api/me"),
    headers: _headers(token),
  );

  if (res.statusCode == 200) {
    final data = jsonDecode(res.body); // {"status": true, "user": {...}}
    return data['user'] as Map<String, dynamic>?;
  }

  return null;
}


  // =========================================================
  // LOGOUT
  // =========================================================
  Future<void> logout() async {
    _token = null;
    _role = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("role");

    notifyListeners();
  }
}
