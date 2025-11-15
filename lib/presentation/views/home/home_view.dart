// lib/presentation/views/home/home_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/contact_controller.dart';
import '../home/edit_contact_view.dart';
import '../../../data/models/contact_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeController controller;
  late final ContactController contactController;

  @override
  void initState() {
    super.initState();
    contactController = ContactController();
    controller = HomeController(contactController: contactController);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // DIALOGUE DE SUPPRESSION
  void _showDeleteDialog(Contact contact) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Supprimer ?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Voulez-vous supprimer ${contact.name} ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await contactController.deleteContact(contact.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Contact supprimé"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mes Contacts",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await AuthController().logout(context);
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // BARRE DE RECHERCHE
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: "Rechercher un contact...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
            ),
          ),

          // LISTE DES CONTACTS
          Expanded(
            child: ValueListenableBuilder<String>(
              valueListenable: controller.searchQuery,
              builder: (context, query, _) {
                return StreamBuilder<List<Contact>>(
                  stream: contactController.searchContacts(query),
                  builder: (context, snapshot) {
                    // CHARGEMENT
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // ERREUR
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Erreur: ${snapshot.error}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    // AUCUN CONTACT
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.contacts, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              query.isEmpty ? "Aucun contact" : "Aucun résultat",
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      );
                    }

                    // LISTE
                    final contacts = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                contact.name.isNotEmpty
                                    ? contact.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            title: Text(
                              contact.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                if (contact.email.isNotEmpty)
                                  Text(
                                    contact.email,
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                if (contact.phone.isNotEmpty)
                                  Text(
                                    contact.phone,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // MODIFIER
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    context.go('/edit', extra: contact);
                                  },
                                ),
                                // SUPPRIMER
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _showDeleteDialog(contact),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // BOUTON AJOUTER
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/add'),
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Ajouter", style: TextStyle(color: Colors.white)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}