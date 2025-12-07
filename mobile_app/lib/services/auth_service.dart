import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  String? _token;
  String? _role;

  String? get token => _token;
  String? get role => _role;

  // -------------------------
  // Login
  // -------------------------
  Future<void> login(String email, String password) async {
    final url = Uri.parse("http://127.0.0.1:8000/api/login");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      _token = data['access_token'];        // token réel
      _role = data['user']['role'] ?? 'user'; // role réel

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", _token!);
      await prefs.setString("role", _role!);

      notifyListeners();
    } else {
      final error = jsonDecode(res.body);
      throw Exception(error['message'] ?? "Login failed");
    }
  }

  // -------------------------
  // Get token
  // -------------------------
  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("token");
    return _token;
  }

  // -------------------------
  // Logout
  // -------------------------
  Future<void> logout() async {
    _token = null;
    _role = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("role");
    notifyListeners();
  }
}
