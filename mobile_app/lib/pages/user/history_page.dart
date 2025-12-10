import 'package:flutter/material.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool loading = true;
  List history = [];
  int _selectedTab = 0;
  List<double> stressScores = [];
  List<double> motivationScores = [];
  List<double> satisfactionScores = [];
  List<String> dates = [];
  
  Map<String, dynamic> userProfile = {};
  bool loadingProfile = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadHistory();
      loadUserProfile();
    });
  }

  // ========================
  // Load User Profile
  // ========================
  Future<void> loadUserProfile() async {
    try {
      setState(() => loadingProfile = true);
      final auth = Provider.of<AuthService>(context, listen: false);
     final profile = await auth.getProfile();
setState(() {
  userProfile = profile ?? {};  // Map vide si null
  loadingProfile = false;
});

if (profile != null) {
  print('👤 Profil chargé: ${profile['name']}');
} else {
  print('❌ Profil vide ou introuvable');
}
   } catch (e) {
      print('❌ Erreur chargement profil: $e');
      setState(() => loadingProfile = false);
    }
  }

  // ========================
  // Load History
  // ========================
  Future<void> loadHistory() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    try {
      setState(() => loading = true);
      history = await ApiService.getHistory(auth);
      print('📊 Histoire chargée: ${history.length} éléments');
      prepareChartData();
    } catch (e) {
      print('❌ Erreur lors du chargement: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur de chargement: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  // ========================
  // Prepare Chart Data
  // ========================
  void prepareChartData() {
    stressScores.clear();
    motivationScores.clear();
    satisfactionScores.clear();
    dates.clear();
    
    if (history.isEmpty) return;
    
    // Trier par date (plus récent en premier)
    try {
      history.sort((a, b) {
        final aDate = a['created_at']?.toString() ?? '';
        final bDate = b['created_at']?.toString() ?? '';
        return bDate.compareTo(aDate);
      });
    } catch (e) {
      print('⚠️ Erreur tri dates: $e');
    }
    
    // Prendre les 7 derniers résultats
    final recentHistory = history.take(7).toList().reversed.toList();
    
    for (var item in recentHistory) {
      final ai = item["ai_report"];
      if (ai == null) continue;
      
      // Extraire les scores avec sécurité
      final stress = _safeExtractScore(ai, "stress_score");
      final motivation = _safeExtractScore(ai, "motivation_score");
      final satisfaction = _safeExtractScore(ai, "satisfaction_score");
      
      stressScores.add(stress);
      motivationScores.add(motivation);
      satisfactionScores.add(satisfaction);
      
      // Formater la date
      final dateStr = item["created_at"]?.toString() ?? '';
      if (dateStr.length >= 10) {
        dates.add(dateStr.substring(5, 10)); // MM-DD
      } else {
        dates.add(dateStr);
      }
    }
  }

  double _safeExtractScore(Map<String, dynamic> ai, String key) {
    try {
      final value = ai[key];
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        return parsed ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      print('⚠️ Erreur extraction score $key: $e');
      return 0.0;
    }
  }

  String _safeExtractScoreString(Map<String, dynamic> ai, String key) {
    try {
      final value = ai[key];
      if (value == null) return "0";
      if (value is num) return value.toString();
      if (value is String) return value;
      return value.toString();
    } catch (e) {
      print('⚠️ Erreur extraction string $key: $e');
      return "0";
    }
  }

  // ========================
  // Navigation Functions
  // ========================
  Future<void> _logout(BuildContext context) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Voulez-vous vraiment vous déconnecter ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Déconnexion"),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await auth.logout();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  

  void _navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, '/settings');
  }

  // ========================
  // UI
  // ========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Historique des Résultats",
          style: TextStyle(
            fontSize: 18,
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
            onPressed: () {
              loadHistory();
              loadUserProfile();
            },
            tooltip: "Rafraîchir",
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              "Chargement de l'historique...",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (history.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Header avec statistiques
        _buildHeader(),
        
        // Onglets
        _buildTabs(),
        
        // Contenu selon l'onglet
        Expanded(
          child: _selectedTab == 0 ? _buildChartsTab() : _buildListTab(),
        ),
      ],
    );
  }

  // ========================
  // Header Section
  // ========================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 24, 13, 187).withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Votre Évolution",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "${history.length} résultats enregistrés",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 20),
          
          // Mini statistiques
          if (history.isNotEmpty && history.last["ai_report"] != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _miniStat(
                  label: "Dernier Stress",
                  value: _safeExtractScoreString(
                    history.last["ai_report"], 
                    "stress_score"
                  ),
                  icon: Icons.warning_amber,
                  color: Colors.redAccent,
                ),
                _miniStat(
                  label: "Dernière Motivation",
                  value: _safeExtractScoreString(
                    history.last["ai_report"], 
                    "motivation_score"
                  ),
                  icon: Icons.flash_on,
                  color: Colors.blueAccent,
                ),
                _miniStat(
                  label: "Dernière Satisfaction",
                  value: _safeExtractScoreString(
                    history.last["ai_report"], 
                    "satisfaction_score"
                  ),
                  icon: Icons.sentiment_satisfied,
                  color: Colors.greenAccent,
                ),
              ],
            )
          else
            Text(
              "Données incomplètes",
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  Widget _miniStat({required String label, required String value, required IconData icon, required Color color}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  // ========================
  // Tabs Section
  // ========================
  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tabButton(
              text: "📊 Graphiques",
              isSelected: _selectedTab == 0,
              onTap: () => setState(() => _selectedTab = 0),
            ),
          ),
          Expanded(
            child: _tabButton(
              text: "📋 Liste",
              isSelected: _selectedTab == 1,
              onTap: () => setState(() => _selectedTab = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton({required String text, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(183, 4, 132, 236) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  // ========================
  // Charts Tab
  // ========================
  Widget _buildChartsTab() {
    final hasChartData = stressScores.isNotEmpty && 
                        motivationScores.isNotEmpty && 
                        satisfactionScores.isNotEmpty;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (hasChartData) ...[
            _buildCombinedChart(),
            const SizedBox(height: 20),
            _buildSingleChart(
              title: "Évolution du Stress",
              scores: stressScores,
              color: Colors.redAccent,
              icon: Icons.warning_amber,
            ),
            const SizedBox(height: 20),
            _buildSingleChart(
              title: "Évolution de la Motivation",
              scores: motivationScores,
              color: Colors.blueAccent,
              icon: Icons.flash_on,
            ),
            const SizedBox(height: 20),
            _buildSingleChart(
              title: "Évolution de la Satisfaction",
              scores: satisfactionScores,
              color: Colors.greenAccent,
              icon: Icons.sentiment_satisfied,
            ),
          ] else
            _buildNoChartData(),
        ],
      ),
    );
  }

  Widget _buildCombinedChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart, color: Colors.deepPurple),
                const SizedBox(width: 8),
                const Text(
                  "Tendances Générales",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "Comparaison des scores sur les 7 derniers tests",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          return index >= 0 && index < dates.length
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    dates[index],
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : Container();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: stressScores.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value);
                      }).toList(),
                      isCurved: true,
                      color: Colors.redAccent,
                      barWidth: 3,
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: motivationScores.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value);
                      }).toList(),
                      isCurved: true,
                      color: Colors.blueAccent,
                      barWidth: 3,
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: satisfactionScores.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value);
                      }).toList(),
                      isCurved: true,
                      color: Colors.greenAccent,
                      barWidth: 3,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendItem(color: Colors.redAccent, text: "Stress"),
                const SizedBox(width: 20),
                _legendItem(color: Colors.blueAccent, text: "Motivation"),
                const SizedBox(width: 20),
                _legendItem(color: Colors.greenAccent, text: "Satisfaction"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleChart({
    required String title,
    required List<double> scores,
    required Color color,
    required IconData icon,
  }) {
    final maxScore = scores.isNotEmpty ? scores.reduce((a, b) => a > b ? a : b) : 1.0;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            Container(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: scores.asMap().entries.map((entry) {
                  final index = entry.key;
                  final score = entry.value;
                  final height = maxScore > 0 ? ((score / maxScore) * 100) : 0.0;
                  
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 25,
                        height: height,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        index < dates.length ? dates[index] : '',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${score.toInt()}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoChartData() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            Icon(
              Icons.bar_chart,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            const Text(
              "Pas assez de données pour les graphiques",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Complétez plus de questionnaires pour voir vos tendances",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // ========================
  // List Tab
  // ========================
  Widget _buildListTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (_, i) {
        final item = history[i];
        final ai = item["ai_report"] ?? {};
        final dateStr = item["created_at"]?.toString() ?? '';
        final formattedDate = _formatDate(dateStr);

        final stressScore = _safeExtractScoreString(ai, "stress_score");
        final motivationScore = _safeExtractScoreString(ai, "motivation_score");
        final satisfactionScore = _safeExtractScoreString(ai, "satisfaction_score");
        final riskLevel = ai["risk_level"]?.toString() ?? "unknown";

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.assignment,
                                size: 20,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Test #${item['id'] ?? i + 1}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _riskColor(riskLevel),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            riskLevel.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Colors.grey),
                    const SizedBox(height: 12),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _scoreCircle(
                          value: stressScore,
                          label: "Stress",
                          color: Colors.redAccent,
                          icon: Icons.warning_amber,
                        ),
                        _scoreCircle(
                          value: motivationScore,
                          label: "Motivation",
                          color: Colors.blueAccent,
                          icon: Icons.flash_on,
                        ),
                        _scoreCircle(
                          value: satisfactionScore,
                          label: "Satisfaction",
                          color: Colors.greenAccent,
                          icon: Icons.sentiment_satisfied,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          formattedDate.isNotEmpty ? "Le $formattedDate" : "Date inconnue",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.length >= 10) {
      final year = dateStr.substring(0, 4);
      final month = dateStr.substring(5, 7);
      final day = dateStr.substring(8, 10);
      return "$day/$month/$year";
    }
    return dateStr;
  }

  Widget _scoreCircle({
    required String value,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
              ),
            ),
            Column(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Color _riskColor(String risk) {
    final riskLower = risk.toLowerCase();
    if (riskLower.contains("high")) return Colors.red;
    if (riskLower.contains("medium")) return Colors.orange;
    if (riskLower.contains("low")) return Colors.green;
    return Colors.blueGrey;
  }

  // ========================
  // Empty State
  // ========================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          const Text(
            "Aucun résultat pour le moment",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Complétez un questionnaire pour voir vos résultats",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ========================
  // Drawer
  // ========================
  Widget _buildDrawer() {
    final userName = userProfile['name'] ?? 'Utilisateur';
    final userEmail = userProfile['email'] ?? '';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    final userRole = userProfile['role'] == 'admin' ? 'Administrateur' : 'Utilisateur';

    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // En-tête du drawer avec profil
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade700, Colors.blue.shade900],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  loadingProfile
                      ? const CircularProgressIndicator(color: Colors.white)
                      : CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Text(
                            userInitial,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (userEmail.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      userRole,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Menu de navigation
            _drawerMenuItem(
              icon: Icons.history,
              title: "Historique",
              isSelected: true,
              onTap: () => Navigator.pop(context),
            ),
          
            
            _drawerMenuItem(
              icon: Icons.person,
              title: "Mon Profil",
              isSelected: false,
              onTap: () {
                Navigator.pop(context);
                _navigateToSettings(context);
              },
            ),

            const Divider(height: 32, thickness: 1),

            // Section système
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Compte",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Déconnexion",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerMenuItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.blue : Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.grey[800],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? Colors.blue.shade50 : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onTap: onTap,
    );
  }
}