import 'package:flutter/material.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/services/auth_service.dart'; // <-- add this
import 'package:provider/provider.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});
  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  List users = [];
  bool loading = true;

  loadUsers() async {
    final auth = Provider.of<AuthService>(context, listen: false); // <-- get instance
    users = await ApiService.getUsers(auth);
    loading = false;
    setState(() {});
  }

  deleteUser(id) async {
    final auth = Provider.of<AuthService>(context, listen: false); // <-- get instance
    await ApiService.deleteUser(id, auth);
    loadUsers();
  }

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Users")),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                for (var u in users)
                  ListTile(
                    title: Text(u['name']),
                    subtitle: Text(u['email']),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteUser(u['id']),
                    ),
                  )
              ],
            ),
    );
  }
}
