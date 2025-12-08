import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/services/auth_service.dart';

class ManageQuestionsPage extends StatefulWidget {
  const ManageQuestionsPage({super.key});

  @override
  State<ManageQuestionsPage> createState() => _ManageQuestionsPageState();
}

class _ManageQuestionsPageState extends State<ManageQuestionsPage> {
  List questions = [];
  bool loading = true;

  loadQuestions() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    questions = await ApiService.getQuestions(auth); // ✅ passer auth
    loading = false;
    setState(() {});
  }

  deleteQuestion(id) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    await ApiService.deleteQuestion(id, auth); // ✅ passer auth
    loadQuestions();
  }

  @override
  void initState() {
    super.initState();
    // utiliser addPostFrameCallback pour éviter Provider avant le build
    WidgetsBinding.instance.addPostFrameCallback((_) => loadQuestions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Questions")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                for (var q in questions)
                  ListTile(
                    title: Text(q['text'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteQuestion(q['id']),
                    ),
                  )
              ],
            ),
    );
  }
}
