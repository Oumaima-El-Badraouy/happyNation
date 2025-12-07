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
    final auth = Provider.of<AuthService>(context, listen: false); // get AuthService instance
    history = await ApiService.getHistory(auth); // <-- pass it here
    loading = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // use addPostFrameCallback to safely access context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("History")),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (_, i) {
                final item = history[i];
                return ListTile(
                  title: Text("Response #${item['id']}"),
                  subtitle: Text(item['created_at']),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      "/responses/history",
                      arguments: item['ai_report'],
                    );
                  },
                );
              },
            ),
    );
  }
}
