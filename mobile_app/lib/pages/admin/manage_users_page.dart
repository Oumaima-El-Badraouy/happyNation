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
  String? errorMessage;

  // -----------------------
  // Load Users
  // -----------------------
  Future<void> loadUsers() async {
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      users = await ApiService.getUsers(auth);
      errorMessage = null;
    } catch (e) {
      errorMessage = "Erreur de chargement: ${e.toString()}";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage!)),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  // -----------------------
  // Delete user
  // -----------------------
  Future<void> deleteUser(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Voulez-vous vraiment supprimer cet utilisateur ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final auth = Provider.of<AuthService>(context, listen: false);
        await ApiService.deleteUser(id, auth);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Utilisateur supprimé avec succès")),
        );
        await loadUsers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de suppression: ${e.toString()}")),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  // -----------------------
  // Add User Dialog avec validation
  // -----------------------
  void showAddDialog() {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final roleCtrl = TextEditingController(text: "user");
    bool creating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Ajouter un utilisateur"),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: "Nom complet",
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un nom';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un email';
                          }
                          if (!value.contains('@')) {
                            return 'Email invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passCtrl,
                        decoration: const InputDecoration(
                          labelText: "Mot de passe",
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un mot de passe';
                          }
                          if (value.length < 6) {
                            return 'Le mot de passe doit contenir au moins 6 caractères';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: roleCtrl.text,
                        decoration: const InputDecoration(
                          labelText: "Rôle",
                          prefixIcon: Icon(Icons.security),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'user', child: Text('Utilisateur')),
                          DropdownMenuItem(value: 'admin', child: Text('Administrateur')),
                        ],
                        onChanged: (value) {
                          if (value != null) roleCtrl.text = value;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: creating ? null : () => Navigator.pop(context),
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: creating
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setState(() => creating = true);
                            try {
                              final auth = Provider.of<AuthService>(context, listen: false);
                              final success = await ApiService.createUser({
                                "name": nameCtrl.text,
                                "email": emailCtrl.text,
                                "password": passCtrl.text,
                                "role": roleCtrl.text,
                              }, auth);

                              if (success) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Utilisateur créé avec succès")),
                                );
                                await loadUsers();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Échec de la création de l'utilisateur")),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Erreur: ${e.toString()}")),
                              );
                            } finally {
                              setState(() => creating = false);
                            }
                          }
                        },
                  child: creating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Créer"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // -----------------------
  // Edit User Dialog avec validation
  // -----------------------
  void showEditDialog(Map<String, dynamic> user) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: user['name']);
    final emailCtrl = TextEditingController(text: user['email']);
    final roleCtrl = TextEditingController(text: user['role'] ?? 'user');
    bool updating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Modifier l'utilisateur"),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: "Nom complet",
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un nom';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un email';
                          }
                          if (!value.contains('@')) {
                            return 'Email invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: roleCtrl.text,
                        decoration: const InputDecoration(
                          labelText: "Rôle",
                          prefixIcon: Icon(Icons.security),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'user', child: Text('Utilisateur')),
                          DropdownMenuItem(value: 'admin', child: Text('Administrateur')),
                        ],
                        onChanged: (value) {
                          if (value != null) roleCtrl.text = value;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: updating ? null : () => Navigator.pop(context),
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: updating
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setState(() => updating = true);
                            try {
                              final auth = Provider.of<AuthService>(context, listen: false);
                              final success = await ApiService.updateUser(user['id'], {
                                "name": nameCtrl.text,
                                "email": emailCtrl.text,
                                "role": roleCtrl.text,
                              }, auth);

                              if (success) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Utilisateur mis à jour avec succès")),
                                );
                                await loadUsers();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Échec de la mise à jour de l'utilisateur")),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Erreur: ${e.toString()}")),
                              );
                            } finally {
                              setState(() => updating = false);
                            }
                          }
                        },
                  child: updating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Mettre à jour"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // -----------------------
  // UI avec design amélioré
  // -----------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Gestion des Utilisateurs",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadUsers,
            tooltip: "Rafraîchir",
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: showAddDialog,
            tooltip: "Ajouter un utilisateur",
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Chargement des utilisateurs..."),
                ],
              ),
            )
          : users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_outline, size: 80, color: Colors.grey),
                      const SizedBox(height: 20),
                      const Text(
                        "Aucun utilisateur",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Ajoutez votre premier utilisateur",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: showAddDialog,
                        icon: const Icon(Icons.add),
                        label: const Text("Ajouter un utilisateur"),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadUsers,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: users.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final isAdmin = user['role'] == 'admin';

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: isAdmin ? Colors.blue : Colors.green,
                            child: Text(
                              user['name']?[0]?.toString().toUpperCase() ?? 'U',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            user['name'] ?? 'Sans nom',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['email'] ?? 'Pas d\'email',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isAdmin
                                      ? Colors.blue.shade50
                                      : Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isAdmin
                                        ? Colors.blue.shade100
                                        : Colors.green.shade100,
                                  ),
                                ),
                                child: Text(
                                  isAdmin ? 'Administrateur' : 'Utilisateur',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isAdmin ? Colors.blue : Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => showEditDialog(user),
                                tooltip: "Modifier",
                                color: Colors.blue,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () => deleteUser(user['id']),
                                tooltip: "Supprimer",
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}