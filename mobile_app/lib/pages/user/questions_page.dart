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
  int _currentQuestionIndex = 0;
  final PageController _pageController = PageController();

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
    if (answers.length < questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veuillez répondre à toutes les questions (${answers.length}/${questions.length})"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Soumission"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Traitement de vos réponses..."),
          ],
        ),
      ),
    );

    final auth = Provider.of<AuthService>(context, listen: false);

    try {
      final response = await ApiService.sendResponses(answers, auth);
      Navigator.pop(context); // Fermer le dialogue

      if (response.containsKey('ai_report')) {
        final aiReport = Map<String, dynamic>.from(response['ai_report']);
        Navigator.pushReplacementNamed(context, "/user/result", arguments: aiReport);
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Succès!"),
            content: const Text("Vos réponses ont été soumises avec succès."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    loading = true;
                    answers.clear();
                    _currentQuestionIndex = 0;
                    _pageController.jumpToPage(0);
                  });
                  loadQuestions();
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Fermer le dialogue
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Échec de la soumission: ${e.toString()}"),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: "Réessayer",
            onPressed: submitAnswers,
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadQuestions());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: questions.isNotEmpty && !loading && message == null
          ? _buildBottomNavBar()
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Column(
        children: [
          const Text(
            "Questionnaire du jour",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (questions.isNotEmpty && !loading && message == null)
            Text(
              "Question ${_currentQuestionIndex + 1}/${questions.length}",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.black),
          onPressed: () {
            setState(() {
              loading = true;
              answers.clear();
              message = null;
              _currentQuestionIndex = 0;
            });
            loadQuestions();
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (loading) {
      return _buildLoadingScreen();
    }

    if (message != null) {
      return _buildMessageScreen();
    }

    if (questions.isEmpty) {
      return _buildEmptyScreen();
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: questions.length,
      onPageChanged: (index) {
        setState(() {
          _currentQuestionIndex = index;
        });
      },
      itemBuilder: (context, index) {
        return _buildQuestionCard(index);
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
          ),
          const SizedBox(height: 20),
          Text(
            "Chargement des questions...",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                size: 60,
                color: Color(0xFF7C3AED),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Revenez demain pour un nouveau questionnaire",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/responses/history");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 20),
                  SizedBox(width: 8),
                  Text("Voir l'historique", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() => loading = true);
                loadQuestions();
              },
              child: const Text(
                "Actualiser",
                style: TextStyle(color: Color(0xFF7C3AED)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.question_mark_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          const Text(
            "Aucune question disponible",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              setState(() => loading = true);
              loadQuestions();
            },
            child: const Text("Recharger"),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    final q = questions[index];
    final qId = q['id'].toString();
    final qText = q['text'].toString();
    final qType = q['type'].toString();
    final bool hasAnswer = answers.containsKey(qId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicateur de progression
          LinearProgressIndicator(
            value: (index + 1) / questions.length,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 30),

          // Numéro de question
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "QUESTION ${index + 1}",
              style: const TextStyle(
                color: Color(0xFF7C3AED),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Texte de la question
          Text(
            qText,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Type de question
          Text(
            qType == 'text' ? "Réponse libre" : "Choix multiple",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 32),

          // Indicateur de réponse (conditionnel)
          _buildAnswerIndicator(hasAnswer, qId),
          
          // Zone de réponse
          if (qType == 'text')
            _buildTextAnswer(qId, hasAnswer)
          else if (qType == 'likert' && q['options'] is List)
            _buildLikertAnswer(qId, q['options'] as List),
        ],
      ),
    );
  }

  Widget _buildAnswerIndicator(bool hasAnswer, String qId) {
    if (hasAnswer) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
           
            child: Row(
            ),
          ),
          const SizedBox(height: 24),
        ],
      );
    } else {
      return const SizedBox.shrink(); // Widget vide si pas de réponse
    }
  }

  Widget _buildTextAnswer(String qId, bool hasAnswer) {
    return Column(
      children: [
        TextField(
          onChanged: (val) {
            setState(() {
              answers[qId] = val;
            });
          },
          controller: TextEditingController(text: answers[qId]?.toString() ?? ''),
          maxLines: 5,
          decoration: InputDecoration(
            hintText: "Tapez votre réponse ici...",
            hintStyle: TextStyle(color: Colors.grey.shade400),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.all(16),
          ),
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 12),
        Text(
          "Réponse libre - Soyez aussi détaillé que vous le souhaitez",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildLikertAnswer(String qId, List options) {
    return Column(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value.toString();
        final bool isSelected = answers[qId] == option;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Card(
            elevation: isSelected ? 2 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? const Color(0xFF7C3AED) : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: ListTile(
              onTap: () {
                setState(() {
                  answers[qId] = option;
                });
              },
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF7C3AED) : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              title: Text(
                option,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? const Color(0xFF7C3AED) : Colors.black87,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Color(0xFF7C3AED))
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomNavBar() {
    final bool isLastQuestion = _currentQuestionIndex == questions.length - 1;
    final bool isFirstQuestion = _currentQuestionIndex == 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bouton précédent
          if (!isFirstQuestion)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF7C3AED),
                  side: const BorderSide(color: Color(0xFF7C3AED)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, size: 18),
                    SizedBox(width: 8),
                    Text("Précédent"),
                  ],
                ),
              ),
            ),
          if (!isFirstQuestion) const SizedBox(width: 12),

          // Bouton suivant/soumettre
          Expanded(
            flex: isFirstQuestion ? 2 : 1,
            child: ElevatedButton(
              onPressed: () {
                if (!isLastQuestion) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  submitAnswers();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLastQuestion ? "Soumettre" : "Suivant",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isLastQuestion ? Icons.send : Icons.arrow_forward,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}