// import 'package:flutter/material.dart';
// import 'package:mobile_app/services/api_service.dart';
// import 'package:provider/provider.dart';
// import 'package:mobile_app/services/auth_service.dart';

// class HistoryPage extends StatefulWidget {
//   const HistoryPage({super.key});

//   @override
//   State<HistoryPage> createState() => _HistoryPageState();
// }

// class _HistoryPageState extends State<HistoryPage> {
//   bool loading = true;
//   List history = [];

//   loadHistory() async {
//     final auth = Provider.of<AuthService>(context, listen: false);
//     history = await ApiService.getHistory(auth);
//     loading = false;
//     setState(() {});
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => loadHistory());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: Text(" Results History"),
//         centerTitle: true,
//         backgroundColor: Colors.deepOrange,
//       ),
//       body: loading
//           ? Center(child: CircularProgressIndicator())
//           : history.isEmpty
//               ? Center(
//                   child: Text(
//                     "No AI results yet",
//                     style: TextStyle(fontSize: 16, color: Colors.grey),
//                   ),
//                 )
//               : ListView.builder(
//                   padding: EdgeInsets.all(14),
//                   itemCount: history.length,
//                   itemBuilder: (_, i) {
//                     final item = history[i];
//                     final ai = item["ai_report"];

//                     return Container(
//                       margin: EdgeInsets.only(bottom: 14),
//                       padding: EdgeInsets.all(18),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(14),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black12,
//                             blurRadius: 6,
//                             offset: Offset(0, 3),
//                           )
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Title + Date Row
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 "Result #${item['id']}",
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Row(
//                                 children: [
//                                   Icon(Icons.calendar_today,
//                                       size: 16, color: Colors.grey),
//                                   SizedBox(width: 6),
//                                   Text(
//                                     item["created_at"]
//                                         .toString()
//                                         .substring(0, 10),
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.grey[700],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),

//                           SizedBox(height: 12),
//                           Divider(),
//                           SizedBox(height: 12),

//                           // Scores Section
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               _scoreBox(
//                                 icon: Icons.warning_amber,
//                                 label: "Stress",
//                                 value: ai["stress_score"],
//                                 color: Colors.redAccent,
//                               ),
//                               _scoreBox(
//                                 icon: Icons.flash_on,
//                                 label: "Motivation",
//                                 value: ai["motivation_score"],
//                                 color: Colors.blueAccent,
//                               ),
//                               _scoreBox(
//                                 icon: Icons.sentiment_satisfied_alt,
//                                 label: "Satisfaction",
//                                 value: ai["satisfaction_score"],
//                                 color: Colors.green,
//                               ),
//                             ],
//                           ),

//                           SizedBox(height: 20),

//                           // Risk level badge
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 10, vertical: 6),
//                             decoration: BoxDecoration(
//                               color: _riskColor(ai["risk_level"]),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Text(
//                               "Risk: ${ai["risk_level"].toString().toUpperCase()}",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }

//   // Score Box Widget
//   Widget _scoreBox({
//     required IconData icon,
//     required String label,
//     required dynamic value,
//     required Color color,
//   }) {
//     return Column(
//       children: [
//         Icon(icon, color: color, size: 28),
//         SizedBox(height: 6),
//         Text(
//           "$value",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         Text(
//           label,
//           style: TextStyle(fontSize: 13, color: Colors.grey),
//         ),
//       ],
//     );
//   }

//   // Risk color
//   Color _riskColor(String risk) {
//     switch (risk.toLowerCase()) {
//       case "high":
//         return Colors.red;
//       case "medium":
//         return Colors.orange;
//       default:
//         return Colors.green;
//     }
//   }
// }
// (
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

  loadHistory() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    try {
      history = await ApiService.getHistory(auth);
      print('📊 Histoire chargée: ${history.length} éléments');
      
      // Debug: afficher la structure des données
      if (history.isNotEmpty) {
        print('📋 Premier élément: ${history.first}');
        if (history.first["ai_report"] != null) {
          print('🔍 Structure ai_report: ${history.first["ai_report"]}');
        }
      }
      
      prepareChartData();
    } catch (e) {
      print('❌ Erreur lors du chargement: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement: ${e.toString()}")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  void prepareChartData() {
    stressScores.clear();
    motivationScores.clear();
    satisfactionScores.clear();
    dates.clear();
    
    if (history.isEmpty) return;
    
    // Trier par date (plus récent en premier)
    history.sort((a, b) {
      try {
        return (b['created_at'] as String).compareTo(a['created_at'] as String);
      } catch (e) {
        return 0;
      }
    });
    
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
    
    print('📈 Scores préparés:');
    print('   Stress: $stressScores');
    print('   Motivation: $motivationScores');
    print('   Satisfaction: $satisfactionScores');
    print('   Dates: $dates');
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
    
      body: loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Chargement de l'historique...",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_toggle_off,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Aucun résultat pour le moment",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Complétez un questionnaire pour voir vos résultats",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // En-tête avec statistiques
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
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
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "${history.length} résultats enregistrés",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          SizedBox(height: 20),
                          
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
                    ),
                    
                    // Onglets
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
                    ),
                    
                    // Contenu selon l'onglet
                    Expanded(
                      child: _selectedTab == 0 
                          ? _buildChartsTab()
                          : _buildListTab(),
                    ),
                  ],
                ),
    );
  }

  Widget _miniStat({required String label, required String value, required IconData icon, required Color color}) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
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

  Widget _tabButton({required String text, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildChartsTab() {
    // Vérifier si on a des données pour les graphiques
    final hasChartData = stressScores.isNotEmpty && 
                        motivationScores.isNotEmpty && 
                        satisfactionScores.isNotEmpty;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          if (hasChartData) ...[
            // Graphique combiné
            _buildCombinedChart(),
            SizedBox(height: 20),
            
            // Graphiques individuels
            _buildSingleChart(
              title: "Évolution du Stress",
              scores: stressScores,
              color: Colors.redAccent,
              icon: Icons.warning_amber,
            ),
            SizedBox(height: 20),
            
            _buildSingleChart(
              title: "Évolution de la Motivation",
              scores: motivationScores,
              color: Colors.blueAccent,
              icon: Icons.flash_on,
            ),
            SizedBox(height: 20),
            
            _buildSingleChart(
              title: "Évolution de la Satisfaction",
              scores: satisfactionScores,
              color: Colors.greenAccent,
              icon: Icons.sentiment_satisfied,
            ),
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Pas assez de données pour les graphiques",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Complétez plus de questionnaires pour voir vos tendances",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                Icon(Icons.show_chart, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  "Tendances Générales",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              "Comparaison des scores sur les 7 derniers tests",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            
            // Graphique combiné
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
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
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
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
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  lineBarsData: [
                    // Ligne du stress
                    LineChartBarData(
                      spots: stressScores.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value);
                      }).toList(),
                      isCurved: true,
                      color: Colors.redAccent,
                      barWidth: 3,
                      belowBarData: BarAreaData(show: false),
                    ),
                    // Ligne de la motivation
                    LineChartBarData(
                      spots: motivationScores.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value);
                      }).toList(),
                      isCurved: true,
                      color: Colors.blueAccent,
                      barWidth: 3,
                      belowBarData: BarAreaData(show: false),
                    ),
                    // Ligne de la satisfaction
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
            
            SizedBox(height: 20),
            
            // Légende
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendItem(color: Colors.redAccent, text: "Stress"),
                SizedBox(width: 20),
                _legendItem(color: Colors.blueAccent, text: "Motivation"),
                SizedBox(width: 20),
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
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            
            // Bar chart simple
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
                      SizedBox(height: 8),
                      Text(
                        index < dates.length ? dates[index] : '',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${score.toInt()}',
                        style: TextStyle(
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
        SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildListTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (_, i) {
        final item = history[i];
        final ai = item["ai_report"] ?? {};
        final dateStr = item["created_at"]?.toString() ?? '';
        final formattedDate = dateStr.length >= 10 
            ? "${dateStr.substring(8, 10)}/${dateStr.substring(5, 7)}/${dateStr.substring(0, 4)}"
            : dateStr;

        final stressScore = _safeExtractScoreString(ai, "stress_score");
        final motivationScore = _safeExtractScoreString(ai, "motivation_score");
        final satisfactionScore = _safeExtractScoreString(ai, "satisfaction_score");
        final riskLevel = ai["risk_level"]?.toString() ?? "unknown";

        return Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                // Navigation vers le détail du résultat
                // Navigator.push(...);
              },
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
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.assignment,
                                size: 20,
                                color: Colors.deepPurple,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Test #${item['id'] ?? i + 1}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _riskColor(riskLevel),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            riskLevel.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 12),
                    Divider(height: 1, color: Colors.grey[200]),
                    SizedBox(height: 12),
                    
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
                    
                    SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey[500]),
                        SizedBox(width: 6),
                        Text(
                          formattedDate.isNotEmpty ? "Le $formattedDate" : "Date inconnue",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        Spacer(),
          
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
                SizedBox(height: 4),
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
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
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
}