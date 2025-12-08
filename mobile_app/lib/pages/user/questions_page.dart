// lib/pages/questions_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/services/auth_service.dart';

class QuestionsPage extends StatefulWidget {
  const QuestionsPage({super.key});

  @override
  State<QuestionsPage> createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  List<Map<String, dynamic>> questions = [];
  Map<String, dynamic> answers = {};
  bool loading = true;
  String? message;

  // -------------------------
  // Charger questions
  // -------------------------
  Future<void> loadQuestions() async {
    final auth = Provider.of<AuthService>(context, listen: false);

    try {
      final data = await ApiService.getQuestions(auth);

      if (data is Map<String, dynamic> && data.containsKey('message')) {
        // Pas de questionnaire aujourd'hui
        setState(() {
          message = data['message'].toString();
          questions = [];
          loading = false;
        });
      } else if (data is List) {
        if (data.isEmpty) {
          setState(() {
            message = "Pas de questionnaire pour aujourd'hui";
            questions = [];
            loading = false;
          });
        } else {
          // Convertir chaque item en Map
          questions = data.map<Map<String, dynamic>>((item) {
            return Map<String, dynamic>.from(item);
          }).toList();
          setState(() {
            loading = false;
            message = null;
          });
        }
      } else {
        setState(() {
          message = "Format de données inattendu";
          questions = [];
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        message = "Erreur de chargement: ${e.toString()}";
        questions = [];
        loading = false;
      });
    }
  }

  // -------------------------
  // Soumettre réponses
  // -------------------------
  Future<void> submitAnswers() async {
    if (answers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez répondre à au moins une question")),
      );
      return;
    }

    final auth = Provider.of<AuthService>(context, listen: false);

    try {
      final response = await ApiService.sendResponses(answers, auth);
      if (response.containsKey('ai_report')) {
        final aiReport = Map<String, dynamic>.from(response['ai_report']);
        Navigator.pushNamed(context, "/user/result", arguments: aiReport);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Réponses soumises avec succès!")),
        );
        setState(() {
          loading = true;
          answers.clear();
        });
        await loadQuestions();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Échec de la soumission: ${e.toString()}")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadQuestions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Questionnaire du jour"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                loading = true;
                answers.clear();
                message = null;
              });
              loadQuestions();
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : message != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 80, color: Colors.grey.shade600),
                        const SizedBox(height: 20),
                        Text(
                          message!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, "/responses/history");
                          },
                          icon: const Icon(Icons.history),
                          label: const Text("Voir l'historique"),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: questions.length + 1,
                  itemBuilder: (context, index) {
                    if (index == questions.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: submitAnswers,
                          child: const Text("Soumettre"),
                        ),
                      );
                    }

                    final q = questions[index];
                    final qId = q['id'].toString();
                    final qText = q['text'].toString();
                    final qType = q['type'].toString();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(qText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),
                            if (qType == 'text')
                              TextField(
                                onChanged: (val) => setState(() => answers[qId] = val),
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  hintText: "Votre réponse...",
                                  border: OutlineInputBorder(),
                                ),
                              )
                            else if (qType == 'likert' && q['options'] is List)
                              ...List<Widget>.from(
                                (q['options'] as List).map((opt) => RadioListTile<String>(
                                      title: Text(opt.toString()),
                                      value: opt.toString(),
                                      groupValue: answers[qId],
                                      onChanged: (val) => setState(() => answers[qId] = val),
                                    )),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
