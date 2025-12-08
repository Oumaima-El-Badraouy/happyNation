import 'package:flutter/material.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/services/auth_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool loading = true;
  List history = [];

  loadHistory() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    history = await ApiService.getHistory(auth);
    loading = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(" Results History"),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : history.isEmpty
              ? Center(
                  child: Text(
                    "No AI results yet",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(14),
                  itemCount: history.length,
                  itemBuilder: (_, i) {
                    final item = history[i];
                    final ai = item["ai_report"];

                    return Container(
                      margin: EdgeInsets.only(bottom: 14),
                      padding: EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title + Date Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Result #${item['id']}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      size: 16, color: Colors.grey),
                                  SizedBox(width: 6),
                                  Text(
                                    item["created_at"]
                                        .toString()
                                        .substring(0, 10),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(height: 12),
                          Divider(),
                          SizedBox(height: 12),

                          // Scores Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _scoreBox(
                                icon: Icons.warning_amber,
                                label: "Stress",
                                value: ai["stress_score"],
                                color: Colors.redAccent,
                              ),
                              _scoreBox(
                                icon: Icons.flash_on,
                                label: "Motivation",
                                value: ai["motivation_score"],
                                color: Colors.blueAccent,
                              ),
                              _scoreBox(
                                icon: Icons.sentiment_satisfied_alt,
                                label: "Satisfaction",
                                value: ai["satisfaction_score"],
                                color: Colors.green,
                              ),
                            ],
                          ),

                          SizedBox(height: 20),

                          // Risk level badge
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _riskColor(ai["risk_level"]),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "Risk: ${ai["risk_level"].toString().toUpperCase()}",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  // Score Box Widget
  Widget _scoreBox({
    required IconData icon,
    required String label,
    required dynamic value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        SizedBox(height: 6),
        Text(
          "$value",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }

  // Risk color
  Color _riskColor(String risk) {
    switch (risk.toLowerCase()) {
      case "high":
        return Colors.red;
      case "medium":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}
