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
        SnackBar(
          content: Text("Fréquence mise à jour : $value"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
  // UI améliorée
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
        elevation: 0,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: Column(
        children: [
          // -------- Header avec fréquence --------
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre et compteur
                Row(
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
                          "${questions.length} questions",
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
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.quiz,
                        color: Colors.blue,
                        size: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Carte fréquence
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.purple.shade100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.schedule,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Fréquence des questionnaires",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getFrequencyText(selectedFrequency),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedFrequency,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                            items: frequencyOptions.map((v) {
                              return DropdownMenuItem(
                                value: v,
                                child: Text(
                                  _getFrequencyText(v),
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) updateFrequency(val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // -------- Liste des questions --------
          Expanded(
            child: loadingQuestions
                ? _buildLoadingState()
                : questions.isEmpty
                    ? _buildEmptyState()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Toutes les questions",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...questions.map((q) {
                              return _buildQuestionCard(q);
                            }).toList(),
                            const SizedBox(height: 80), // Espace pour le FAB
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map q) {
    bool isActive = q['active'] ?? true;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec type et statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Text(
                      (q['type'] ?? 'text').toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Texte de la question
              Text(
                q['text'] ?? "",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Footer avec ordre et actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Ordre: #${q['order'] ?? 0}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Row(
                    children: [
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

  String _getFrequencyText(String frequency) {
    switch (frequency) {
      case 'daily':
        return "Quotidien";
      case 'weekly':
        return "Hebdomadaire";
      case 'monthly':
        return "Mensuel";
      default:
        return frequency;
    }
  }

  Widget _buildLoadingState() {
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

  Widget _buildEmptyState() {
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