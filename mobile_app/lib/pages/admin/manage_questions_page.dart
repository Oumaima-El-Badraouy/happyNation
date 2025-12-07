import 'package:flutter/material.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/services/auth_service.dart'; // <-- add this
import 'package:provider/provider.dart';

class ManageQuestionsPage extends StatefulWidget {
  const ManageQuestionsPage({super.key});

  @override
  State<ManageQuestionsPage> createState() => _ManageQuestionsPageState();
}

class _ManageQuestionsPageState extends State<ManageQuestionsPage> {
  List questions = [];
  bool loading = true;

  loadQuestions() async {
    final auth = Provider.of<AuthService>(context, listen: false); // <-- get AuthService instance
    questions = await ApiService.getQuestions(auth); // <-- pass auth
    loading = false;
    setState(() {});
  }

  deleteQuestion(id) async {
    final auth = Provider.of<AuthService>(context, listen: false); // <-- get AuthService instance
    await ApiService.deleteQuestion(id, auth); // <-- pass auth
    loadQuestions();
  }

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Questions")),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                for (var q in questions)
                  ListTile(
                    title: Text(q['text']),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteQuestion(q['id']),
                    ),
                  )
              ],
            ),
    );
  }
}
