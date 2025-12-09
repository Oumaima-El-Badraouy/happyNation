import 'package:flutter/material.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class ManageQuestionsPage extends StatefulWidget {
  const ManageQuestionsPage({super.key});

  @override
  State<ManageQuestionsPage> createState() => _ManageQuestionsPageState();
}

class _ManageQuestionsPageState extends State<ManageQuestionsPage> {
  List questions = [];
  bool loadingQuestions = true;

  // Dropdown statique
  final List<String> frequencyOptions = ['daily', 'weekly', 'monthly'];
  String selectedFrequency = 'daily'; // valeur par défaut

  @override
  void initState() {
    super.initState();
    loadUsers();
    loadQuestions();
  }

  // ========================
  // Load Questions
  // ========================
  Future<void> loadQuestions() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    setState(() => loadingQuestions = true);

    final data = await ApiService.getQuestions(auth);
    setState(() {
      questions = data is List ? data : [];
      loadingQuestions = false;
    });
  }

  // ========================
  // Load Users
  // ========================
  Future<void> loadUsers() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    await ApiService.getUsers(auth);
  }

  // ========================
  // Update Frequency
  // ========================
  Future<void> updateFrequency(String value) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    bool ok = await ApiService.updateFrequency(value, auth);
    if (ok) {
      setState(() {
        selectedFrequency = value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fréquence mise à jour : $value")),
      );
    }
  }

  // ========================
  // DELETE Question
  // ========================
  void deleteQuestion(int id) async {
    final auth = Provider.of<AuthService>(context, listen: false);

    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 12),
            Text("Supprimer la question"),
          ],
        ),
        content: const Text(
            "Êtes-vous sûr de vouloir supprimer cette question ? Cette action est irréversible."),
        actions: [
          TextButton(
            child: const Text("Annuler"),
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    bool ok = await ApiService.deleteQuestion(id, auth);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Question supprimée avec succès"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      loadQuestions();
    }
  }

  // ========================
  // Open Question Form
  // ========================
  void openQuestionForm({Map? question}) {
    final textController = TextEditingController(text: question?['text'] ?? '');
    final typeController = TextEditingController(text: question?['type'] ?? '');
    final optionsController = TextEditingController(
      text: (question?['options'] ?? []).join(","),
    );
    final orderController = TextEditingController(
      text: question?['order']?.toString() ?? '',
    );
    bool active = question?['active'] ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      question == null ? "Ajouter une question" : "Modifier la question",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: textController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: "Texte de la question",
                    prefixIcon: const Icon(Icons.question_mark),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: typeController,
                  decoration: InputDecoration(
                    labelText: "Type (text, choice...)",
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: optionsController,
                  decoration: InputDecoration(
                    labelText: "Options (séparées par , )",
                    prefixIcon: const Icon(Icons.list),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: orderController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Ordre",
                    prefixIcon: const Icon(Icons.sort),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Active", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      Switch.adaptive(
                        value: active,
                        activeColor: Colors.green,
                        onChanged: (v) => setState(() => active = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text("Enregistrer", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    onPressed: () async {
                      final auth = Provider.of<AuthService>(context, listen: false);
                      final payload = {
                        "text": textController.text,
                        "type": typeController.text,
                        "options": optionsController.text.isNotEmpty ? optionsController.text.split(",") : [],
                        "order": int.tryParse(orderController.text) ?? 0,
                        "active": active,
                      };
                      bool ok;
                      if (question == null) {
                        ok = await ApiService.createQuestion(payload, auth);
                      } else {
                        ok = await ApiService.updateQuestion(question['id'], payload, auth);
                      }
                      if (ok) {
                        Navigator.pop(context);
                        loadQuestions();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // ========================
  // UI
  // ========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Gestion des Questions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.1),
        foregroundColor: Colors.black87,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadQuestions, tooltip: "Rafraîchir"),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openQuestionForm(),
        icon: const Icon(Icons.add),
        label: const Text("Nouvelle question"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),

          // -------- Dropdown unique --------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Fréquence", style: TextStyle(fontSize: 16)),
              DropdownButton<String>(
                value: selectedFrequency,
                items: frequencyOptions.map((v) {
                  return DropdownMenuItem(value: v, child: Text(v));
                }).toList(),
                onChanged: (val) {
                  if (val != null) updateFrequency(val);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // -------- Questions --------
          loadingQuestions
              ? const Center(child: CircularProgressIndicator())
              : questions.isEmpty
                  ? const Center(child: Text("Aucune question trouvée"))
                  : Column(
                      children: questions.map((q) {
                        return Card(
                          child: ListTile(
                            title: Text(q['text'] ?? ""),
                            subtitle: Text("Type: ${q['type'] ?? ''} - Ordre: ${q['order'] ?? 0}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.edit), onPressed: () => openQuestionForm(question: q)),
                                IconButton(icon: const Icon(Icons.delete), onPressed: () => deleteQuestion(q['id'])),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
        ],
      ),
    );
  }
}
