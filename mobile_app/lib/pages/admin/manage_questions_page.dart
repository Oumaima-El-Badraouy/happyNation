import 'package:flutter/material.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class ManageQuestionsPage extends StatefulWidget {
  const ManageQuestionsPage({super.key});

  @override
  State<ManageQuestionsPage> createState() => _ManageQuestionsPageState();
}

class _ManageQuestionsPageState extends State<ManageQuestionsPage> {
  List questions = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    setState(() => loading = true);

    final data = await ApiService.getQuestions(auth);

    setState(() {
      questions = data is List ? data : [];
      loading = false;
    });
  }

  // ========================
  // DELETE
  // ========================
  void deleteQuestion(int id) async {
    final auth = Provider.of<AuthService>(context, listen: false);

    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 12),
            Text("Supprimer la question"),
          ],
        ),
        content: const Text("Êtes-vous sûr de vouloir supprimer cette question ? Cette action est irréversible."),
        actions: [
          TextButton(
            child: const Text("Annuler"),
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
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
        SnackBar(
          content: const Text("Question supprimée avec succès"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      loadQuestions();
    }
  }

  // ========================
  // OPEN FORM ADD / EDIT
  // ========================
  void openQuestionForm({Map? question}) {
    final textController = TextEditingController(text: question?['text'] ?? '');
    final typeController = TextEditingController(text: question?['type'] ?? '');
    final optionsController =
        TextEditingController(text: (question?['options'] ?? []).join(","));
    final orderController = TextEditingController(
        text: question?['order']?.toString() ?? '');
    bool active = question?['active'] ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 0,
              ),
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
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: textController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: "Texte de la question",
                    prefixIcon: const Icon(Icons.question_mark),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                      const Text(
                        "Active",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text(
                      "Enregistrer",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () async {
                      final auth = Provider.of<AuthService>(context, listen: false);

                      final payload = {
                        "text": textController.text,
                        "type": typeController.text,
                        "options":
                            optionsController.text.isNotEmpty ? optionsController.text.split(",") : [],
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
  // DETAILS
  // ========================
 void openDetails(int id) async {
  final auth = Provider.of<AuthService>(context, listen: false);
  final details = await ApiService.getDetails(id, auth);

  if (details == null) {
    return;
  }

  String text = details['text'] ?? "—";
  String type = details['type'] ?? "—";
  bool active = details['active'] ?? false;
  int order = details['order'] ?? 0;

  List optionsList = [];
  if (details['options'] is List) {
    optionsList = details['options'];
  }

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.help_outline,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "Détails de la question",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailCard("Texte", text),
            const SizedBox(height: 12),
            _detailCard("Type", type.toUpperCase()),
            const SizedBox(height: 12),
            _detailCard(
              "Statut",
              active ? "Active" : "Inactive",
              color: active ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 12),
            _detailCard("Ordre", order.toString()),
            if (optionsList.isNotEmpty) ...[
              const SizedBox(height: 12),
              _detailCard(
                "Options",
                optionsList.join(', '),
                maxLines: 3,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey,
          ),
          child: const Text("Fermer"),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}

  Widget _detailCard(String label, String value, {Color? color, int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: color ?? Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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
        title: const Text(
          "Gestion des Questions",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.1),
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadQuestions,
            tooltip: "Rafraîchir",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openQuestionForm(),
        icon: const Icon(Icons.add),
        label: const Text("Nouvelle question"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      body: loading
          ? _buildLoadingScreen()
          : questions.isEmpty
              ? _buildEmptyScreen()
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Header avec statistiques
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Questions",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  questions.length.toString(),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green.shade100),
                              ),
                              child: const Icon(
                                Icons.quiz,
                                color: Colors.green,
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Liste des questions
                      Expanded(
                        child: ListView.separated(
                          itemCount: questions.length,
                          separatorBuilder: (_, index) => const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final q = questions[i];
                            return _buildQuestionCard(q);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildQuestionCard(Map q) {
    final bool isActive = q['active'] ?? true;
    final String questionType = q['type'] ?? 'text';
    
    Color getTypeColor() {
      switch (questionType) {
        case 'choice':
          return Colors.blue;
        case 'scale':
          return Colors.purple;
        case 'yes_no':
          return Colors.green;
        case 'multiple_choice':
          return Colors.orange;
        case 'rating':
          return Colors.red;
        default:
          return Colors.blueGrey;
      }
    }
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => openDetails(q['id']),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec type et statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getTypeColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: getTypeColor().withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      questionType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: getTypeColor(),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isActive ? "Active" : "Inactive",
                        style: TextStyle(
                          fontSize: 12,
                          color: isActive ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Texte de la question
              Text(
                q['text'] ?? "Sans texte",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // Footer avec infos et actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Ordre: #${q['order'] ?? 0}",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined, size: 20),
                        onPressed: () => openDetails(q['id']),
                        tooltip: "Voir détails",
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => openQuestionForm(question: q),
                        tooltip: "Modifier",
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () => deleteQuestion(q['id']),
                        tooltip: "Supprimer",
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Chargement des questions...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.quiz_outlined,
              size: 60,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Aucune question trouvée",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Commencez par créer votre première question",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => openQuestionForm(),
            icon: const Icon(Icons.add),
            label: const Text("Créer une question"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}