import 'package:flutter/material.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  Map<String, dynamic> stats = {};
  bool loading = true;
  int _selectedMenu = 0;

  Future<void> loadStats() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    try {
      stats = await ApiService.getDashboardStats(auth);
      setState(() => loading = false);
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement: ${e.toString()}")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  void refreshStats() {
    setState(() => loading = true);
    loadStats();
  }

  Future<void> _logout(BuildContext context) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    
    // Afficher un dialogue de confirmation
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
      
      // Rediriger vers la page de login et supprimer toutes les pages de la pile
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.blue.shade700;
    final Color backgroundColor = Colors.grey.shade50;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Tableau de Bord Admin",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
       
      ),
      drawer: _buildDrawer(primaryColor),
      body: loading
          ? _buildLoadingScreen()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec titre
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // Statistiques principales
                  _buildMainStats(),
                  const SizedBox(height: 24),

                  // Graphiques/cartes des métriques
                  _buildMetricsCards(),
                  const SizedBox(height: 24),

                  // Répartition des risques
                  _buildRiskDistribution(),
                  const SizedBox(height: 24),

                  // Dernières réponses
                  _buildRecentResponses(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        onPressed: refreshStats,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildDrawer(Color primaryColor) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // En-tête du drawer
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Administration",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Dashboard",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Menu de navigation
            _drawerMenuItem(
              icon: Icons.dashboard,
              title: "Tableau de Bord",
              isSelected: _selectedMenu == 0,
              onTap: () {
                setState(() => _selectedMenu = 0);
                Navigator.pop(context);
              },
            ),
            _drawerMenuItem(
              icon: Icons.people,
              title: "Gestion des Utilisateurs",
              isSelected: _selectedMenu == 1,
              onTap: () {
                Navigator.pushNamed(context, '/admin/users');
              },
            ),
            _drawerMenuItem(
              icon: Icons.assignment,
              title: "Gestion des Questions",
              isSelected: _selectedMenu == 2,
              onTap: () {
                Navigator.pushNamed(context, '/admin/questions');
              },
            ),
            _drawerMenuItem(
              icon: Icons.settings,
              title: "Configuration IA",
              isSelected: _selectedMenu == 4,
              onTap: () {
                Navigator.pushNamed(context, '/admin/ai-config');
              },
            ),

            const Divider(height: 32, thickness: 1),

            // Section système
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Système",
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
                Navigator.pop(context); // Fermer le drawer
                _logout(context); // Appeler la fonction de déconnexion
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

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
          ),
          const SizedBox(height: 20),
          const Text(
            "Chargement des statistiques...",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bienvenue, Admin",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Aperçu général du système",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 4,
          width: 80,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildMainStats() {
    final totalResponses = stats['total_responses'] ?? 0;
    final avgStress = double.tryParse((stats['average_stress'] ?? 0).toString()) ?? 0.0;
    final avgMotivation = double.tryParse((stats['average_motivation'] ?? 0).toString()) ?? 0.0;
    final avgSatisfaction = double.tryParse((stats['average_satisfaction'] ?? 0).toString()) ?? 0.0;

    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Statistiques Globales",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up, size: 16, color: Colors.green),
                      const SizedBox(width: 6),
                      Text(
                        "En direct",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Carte principale
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "Réponses Total",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          totalResponses.toString(),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "soumissions",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: Colors.blue.shade200,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          "Moyenne Générale",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${((avgStress + avgMotivation + avgSatisfaction) / 3).toStringAsFixed(1)}/10",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "score moyen",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsCards() {
    final avgStress = double.tryParse((stats['average_stress'] ?? 0).toString()) ?? 0.0;
    final avgMotivation = double.tryParse((stats['average_motivation'] ?? 0).toString()) ?? 0.0;
    final avgSatisfaction = double.tryParse((stats['average_satisfaction'] ?? 0).toString()) ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Métriques Clés",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _metricCard(
              title: "Stress Moyen",
              value: avgStress,
              icon: Icons.warning,
              color: Colors.redAccent,
              maxValue: 10,
            )),
            const SizedBox(width: 12),
            Expanded(child: _metricCard(
              title: "Motivation Moyenne",
              value: avgMotivation,
              icon: Icons.flash_on,
              color: Colors.orangeAccent,
              maxValue: 10,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _metricCard(
              title: "Satisfaction Moyenne",
              value: avgSatisfaction,
              icon: Icons.sentiment_satisfied,
              color: Colors.greenAccent,
              maxValue: 10,
            )),
            const SizedBox(width: 12),
            Expanded(child: _metricCard(
              title: "Utilisateurs Actifs",
              value: (stats['active_users'] ?? 0).toDouble(),
              icon: Icons.people,
              color: Colors.blueAccent,
              maxValue: null,
            )),
          ],
        ),
      ],
    );
  }

  Widget _metricCard({
    required String title,
    required double value,
    required IconData icon,
    required Color color,
    required double? maxValue,
  }) {
    final grey200 = Colors.grey.shade200;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const Spacer(),
              if (maxValue != null)
                Text(
                  "${(value / maxValue * 100).toInt()}%",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            maxValue != null ? "${value.toStringAsFixed(1)}/$maxValue" : value.toInt().toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          if (maxValue != null)
            LinearProgressIndicator(
              value: value / maxValue,
              backgroundColor: grey200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
        ],
      ),
    );
  }

  Widget _buildRiskDistribution() {
    final highRisk = (stats['high_risk_count'] ?? 0).toDouble();
    final mediumRisk = (stats['medium_risk_count'] ?? 0).toDouble();
    final lowRisk = (stats['low_risk_count'] ?? 0).toDouble();
    final total = highRisk + mediumRisk + lowRisk;

    final grey200 = Colors.grey.shade200;

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Répartition des Risques",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          if (total > 0) ...[
            _riskBar(
              label: "Risque Élevé",
              value: highRisk,
              total: total,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            _riskBar(
              label: "Risque Moyen",
              value: mediumRisk,
              total: total,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _riskBar(
              label: "Risque Faible",
              value: lowRisk,
              total: total,
              color: Colors.green,
            ),
          ] else
            Center(
              child: Column(
                children: [
                  Icon(Icons.pie_chart, size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  const Text(
                    "Aucune donnée de risque disponible",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _riskBar({
    required String label,
    required double value,
    required double total,
    required Color color,
  }) {
    final percentage = total > 0 ? (value / total * 100) : 0;
    final grey200 = Colors.grey.shade200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Text(
              "${percentage.toInt()}% (${value.toInt()})",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: total > 0 ? value / total : 0,
            backgroundColor: grey200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentResponses() {
    final recentResponses = stats['recent_responses'] is List ? stats['recent_responses'] as List : [];
    final grey200 = Colors.grey.shade200;

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Réponses Récentes",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              TextButton(
                onPressed: () {
                  // Voir toutes les réponses
                },
                child: const Text("Voir tout"),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (recentResponses.isNotEmpty)
            ...recentResponses.take(5).map((response) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: grey200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          (response['user_name']?.toString().isNotEmpty ?? false)
                              ? response['user_name'].toString().substring(0, 1)
                              : "U",
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              response['user_name']?.toString() ?? "Utilisateur",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              response['created_at']?.toString() ?? "",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getRiskColor(response['risk_level']?.toString() ?? "low").withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          (response['risk_level']?.toString().toUpperCase() ?? "LOW"),
                          style: TextStyle(
                            color: _getRiskColor(response['risk_level']?.toString() ?? "low"),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList()
          else
            Center(
              child: Column(
                children: [
                  Icon(Icons.assignment, size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  const Text(
                    "Aucune réponse récente",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}