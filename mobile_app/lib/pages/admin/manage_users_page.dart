import 'package:flutter/material.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  List users = [];
  bool loading = true;

  // -----------------------
  // Load Users
  // -----------------------
  loadUsers() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    users = await ApiService.getUsers(auth);
    loading = false;
    setState(() {});
  }

  // -----------------------
  // Delete user
  // -----------------------
  deleteUser(id) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    await ApiService.deleteUser(id, auth);
    loadUsers();
  }

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  // -----------------------
  // Add User Dialog
  // -----------------------
  void showAddDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add User"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: "Name")),
            TextField(controller: emailCtrl, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: passCtrl, decoration: InputDecoration(labelText: "Password")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final auth = Provider.of<AuthService>(context, listen: false);
              await ApiService.createUser({
                "name": nameCtrl.text,
                "email": emailCtrl.text,
                "password": passCtrl.text,
                "role": "user",
              }, auth);

              Navigator.pop(context);
              loadUsers();
            },
            child: Text("Save"),
          )
        ],
      ),
    );
  }

  // -----------------------
  // Edit User Dialog
  // -----------------------
  void showEditDialog(Map user) {
    final nameCtrl = TextEditingController(text: user['name']);
    final emailCtrl = TextEditingController(text: user['email']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit User"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: "Name")),
            TextField(controller: emailCtrl, decoration: InputDecoration(labelText: "Email")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final auth = Provider.of<AuthService>(context, listen: false);
              await ApiService.updateUser(user['id'], {
                "name": nameCtrl.text,
                "email": emailCtrl.text,
              }, auth);

              Navigator.pop(context);
              loadUsers();
            },
            child: Text("Update"),
          )
        ],
      ),
    );
  }

  // -----------------------
  // UI
  // -----------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Users"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: showAddDialog, // ADD USER
          )
        ],
      ),

      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (_, i) {
                final u = users[i];

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(u['name'][0].toUpperCase()),
                    ),
                    title: Text(u['name']),
                    subtitle: Text(u['email']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit Button
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => showEditDialog(u),
                        ),

                        // Delete Button
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteUser(u['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
