import 'package:flutter/material.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  login() async {
    setState(() => loading = true);

    final auth = Provider.of<AuthService>(context, listen: false);

    try {
      await auth.login(email.text, password.text);

      setState(() => loading = false);

      // redirect based on role
      if (auth.role == "admin") {
        Navigator.pushReplacementNamed(context, "/admin/dashboard");
      } else if (auth.role == "user") {
        Navigator.pushReplacementNamed(context, "/questions");
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Login", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              TextField(controller: email, decoration: InputDecoration(labelText: "Email")),
              TextField(controller: password, obscureText: true, decoration: InputDecoration(labelText: "Password")),
              const SizedBox(height: 20),
              loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: login,
                      child: Text("Login"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
