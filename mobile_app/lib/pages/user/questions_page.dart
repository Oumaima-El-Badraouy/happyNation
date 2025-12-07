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
  List questions = [];
  Map<String, dynamic> answers = {};
  bool loading = true;

  // -------------------------
  // Load questions from API
  // -------------------------
  loadQuestions() async {
    final auth = Provider.of<AuthService>(context, listen: false);

    try {
      final data = await ApiService.getQuestions(auth);
      setState(() {
        questions = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load questions: $e")),
      );
    }
  }

  // -------------------------
  // Submit answers to API
  // -------------------------

 submitAnswers() async {
  final auth = Provider.of<AuthService>(context, listen: false);

  try {
    final response = await ApiService.sendResponses(answers, auth);

    // Assure-toi que c'est un Map<String, dynamic>
    final aiReport = Map<String, dynamic>.from(response['ai_report']);

    Navigator.pushNamed(
      context,
      "/user/result",
      arguments: aiReport,
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to submit answers: $e")),
    );
  }
}



  @override
  void initState() {
    super.initState();
    // Post frame callback to use Provider safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Questions")),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : questions.isEmpty
              ? Center(child: Text("No questions available"))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: questions.length + 1, // +1 for submit button
                  itemBuilder: (context, index) {
                    if (index == questions.length) {
                      return ElevatedButton(
                        onPressed: submitAnswers,
                        child: Text("Submit"),
                      );
                    }

                    final q = questions[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(q['text'],
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        if (q['type'] == 'text')
                          TextField(
                            onChanged: (val) =>
                                answers[q['id'].toString()] = val,
                            decoration: InputDecoration(hintText: "Type your answer"),
                          )
                        else if (q['type'] == 'likert' && q['options'] != null)
                          ...List.generate(q['options'].length, (i) {
                            final option = q['options'][i];
                            return RadioListTile(
                              title: Text(option),
                              value: option,
                              groupValue: answers[q['id'].toString()],
                              onChanged: (val) {
                                setState(() {
                                  answers[q['id'].toString()] = val;
                                });
                              },
                            );
                          }),
                        SizedBox(height: 20),
                      ],
                    );
                  },
                ),
    );
  }
}
