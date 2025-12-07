import 'package:flutter/material.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  Map stats = {};
  bool loading = true;

  loadStats() async {
    final auth = Provider.of<AuthService>(context, listen: false); // <-- get AuthService
    stats = await ApiService.getDashboardStats(auth); // <-- pass auth
    loading = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Dashboard")),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text("Total Users: ${stats['users']}"),
                  Text("Total Responses: ${stats['responses']}"),
                  Text("Average Stress: ${stats['avg_stress']}"),
                ],
              ),
            ),
    );
  }
}
