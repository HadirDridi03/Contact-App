// lib/presentation/views/home/home_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/contact_controller.dart';
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

  // Écoute le rafraîchissement
  contactController.refreshStream.listen((_) {
    if (mounted) setState(() {});
  });
}

@override
void dispose() {
  contactController.dispose();
  controller.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Contacts"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthController().logout(context);
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // CHAMP DE RECHERCHE
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: "Rechercher par nom...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: controller.updateSearch,
            ),
          ),

          // LISTE DES CONTACTS EN TEMPS RÉEL
          Expanded(
            child: StreamBuilder<List<Contact>>(
              stream: controller.contactController.getContacts(),
              builder: (context, snapshot) {
                // Chargement
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Erreur
                if (snapshot.hasError) {
                  return Center(child: Text("Erreur: ${snapshot.error}"));
                }

                // Pas de données
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Aucun contact"));
                }

                // Filtrer par recherche
                var contacts = snapshot.data!;
                if (controller.searchQuery.isNotEmpty) {
                  contacts = contacts
                      .where((c) => c.name.toLowerCase().contains(controller.searchQuery))
                      .toList();
                }

                // Liste des contacts
                return ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];

                    return ListTile(
                      title: Text(
                        contact.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(contact.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // BOUTON MODIFIER
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              context.go('/edit/${contact.id}', extra: contact);
                            },
                          ),
                          // BOUTON SUPPRIMER
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await controller.contactController.deleteContact(contact.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Contact supprimé"),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // BOUTON AJOUTER
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add'),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}