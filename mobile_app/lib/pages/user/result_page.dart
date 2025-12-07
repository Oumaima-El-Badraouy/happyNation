import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ai = ModalRoute.of(context)!.settings.arguments as Map;

    return Scaffold(
      appBar: AppBar(title: Text("Your Results")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            Text("Stress: ${ai['stress_score']}", style: TextStyle(fontSize: 18)),
            Text("Motivation: ${ai['motivation_score']}", style: TextStyle(fontSize: 18)),
            Text("Satisfaction: ${ai['satisfaction_score']}", style: TextStyle(fontSize: 18)),
            Text("Risk level: ${ai['risk_level']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            
            SizedBox(height: 20),
            Text("Summary:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(ai['summary']),

            SizedBox(height: 20),
            Text("Recommendations:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            for (var r in ai['recommendations']) Text("- $r"),

            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // revient à la page précédente (History)
              },
             
              label: Text("Return to History"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
