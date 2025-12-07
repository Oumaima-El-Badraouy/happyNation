import 'package:flutter/material.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class AIConfigPage extends StatefulWidget {
  const AIConfigPage({super.key});

  @override
  State<AIConfigPage> createState() => _AIConfigPageState();
}

class _AIConfigPageState extends State<AIConfigPage> {
  Map settings = {};
  bool loading = true;

  final stress = TextEditingController();
  final motivation = TextEditingController();
  final satisfaction = TextEditingController();
  final model = TextEditingController();

  loadSettings() async {
    final auth = Provider.of<AuthService>(context, listen: false); // <-- get AuthService
    settings = await ApiService.getAiSettings(auth); // <-- pass auth

    stress.text = settings['stress_weight'].toString();
    motivation.text = settings['motivation_weight'].toString();
    satisfaction.text = settings['satisfaction_weight'].toString();
    model.text = settings['model'];

    loading = false;
    setState(() {});
  }

  save() async {
    final auth = Provider.of<AuthService>(context, listen: false); // <-- get AuthService
    await ApiService.updateAiSettings({
      "stress_weight": stress.text,
      "motivation_weight": motivation.text,
      "satisfaction_weight": satisfaction.text,
      "model": model.text,
    }, auth); // <-- pass auth

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Settings updated")),
    );
  }

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI Config")),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  TextField(controller: stress, decoration: InputDecoration(labelText: "Stress weight")),
                  TextField(controller: motivation, decoration: InputDecoration(labelText: "Motivation weight")),
                  TextField(controller: satisfaction, decoration: InputDecoration(labelText: "Satisfaction weight")),
                  TextField(controller: model, decoration: InputDecoration(labelText: "AI Model")),

                  SizedBox(height: 20),
                  ElevatedButton(onPressed: save, child: Text("Save"))
                ],
              ),
            ),
    );
  }
}
