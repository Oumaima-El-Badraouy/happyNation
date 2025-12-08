import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/api_service.dart';
import 'services/auth_service.dart';

import 'pages/auth/login_page.dart';
import 'pages/user/questions_page.dart';
import 'pages/user/result_page.dart';
import 'pages/user/history_page.dart';

import 'pages/admin/dashboard_page.dart';
import 'pages/admin/manage_users_page.dart';
import 'pages/admin/manage_questions_page.dart';
import 'pages/admin/ai_config_page.dart';

void main() {
  runApp(const HappyNationApp());
}

class HappyNationApp extends StatelessWidget {
  const HappyNationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Happy Nation',
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          fontFamily: 'Roboto',
        ),

        // First Screen (Login)
        initialRoute: "/login",

        routes: {
          // Authentication
          "/login": (context) => const LoginPage(),

          // User pages
          "/questions": (context) => const QuestionsPage(),
          "/user/result": (context) => const ResultPage(),
          "/responses/history": (context) => const HistoryPage(),

          // Admin pages
          "/admin/dashboard": (context) => const AdminDashboardPage(),
          "/admin/users": (context) => const ManageUsersPage(),
          "/admin/questions": (context) => const ManageQuestionsPage(),
          "/admin/ai-config": (context) => const AIConfigPage(),
        },
      ),
    );
  }
}
