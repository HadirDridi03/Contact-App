// lib/presentation/views/home/home_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/auth_controller.dart';
//import '../controllers/contact_controller.dart';
//import '../widgets/contact_tile.dart';
import '../../../data/models/contact_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = HomeController();
   // final contactController = ContactController();

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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: homeController.searchController,
              decoration: InputDecoration(
                hintText: "Rechercher...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) => homeController.updateSearch(value),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Contact>>(
              stream: homeController.contactsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Erreur: ${snapshot.error}"));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final contacts = snapshot.data!;
                if (contacts.isEmpty) return const Center(child: Text("Aucun contact"));

                return ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return ContactTile(
                      contact: contact,
                      onEdit: () => context.go('/edit/${contact.id}', extra: contact),
                      onDelete: () => contactController.deleteContact(contact.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}*/