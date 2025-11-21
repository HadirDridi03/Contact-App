import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../controller/contact_controller.dart';
import '../../controller/auth_controller.dart';
import '../../model/contact_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final contactController = ContactController();
  final authController = AuthController();
  final TextEditingController searchController = TextEditingController();
  List<Contact> allContacts = [];
  List<Contact> filteredContacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
    searchController.addListener(() {
      _filterContacts(searchController.text);
    });
  }

  Future<void> _loadContacts() async {
    final contacts = await contactController.getContacts();
    setState(() {
      allContacts = contacts;
      filteredContacts = contacts;
    });
  }

  void _filterContacts(String query) {
    if (query.isEmpty) {
      setState(() => filteredContacts = allContacts);
    } else {
      setState(() {
        filteredContacts = allContacts
            .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  void _showDeleteDialog(Contact contact) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Supprimer ?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Voulez-vous vraiment supprimer ${contact.name} ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await contactController.deleteContact(contact.id);
      _loadContacts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contact supprimé"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Contacts", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => authController.logout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // BARRE DE RECHERCHE
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Rechercher un contact...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),

          // LISTE DES CONTACTS
          Expanded(
            child: filteredContacts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          searchController.text.isEmpty ? "Aucun contact" : "Aucun résultat",
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = filteredContacts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 6,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: contact.photoPath == null
                                ? const Color(0xFF8B4513).withOpacity(0.2)
                                : null,
                            backgroundImage: contact.photoPath != null
                                ? FileImage(File(contact.photoPath!))
                                : null,
                            child: contact.photoPath == null
                                ? Text(
                                    contact.name.isNotEmpty ? contact.name[0].toUpperCase() : "?",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: Color(0xFF8B4513),
                                    ),
                                  )
                                : null,
                          ),
                          title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (contact.email.isNotEmpty) Text(contact.email),
                              if (contact.phone.isNotEmpty) Text(contact.phone),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => GoRouter.of(context).go('/edit', extra: contact),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _showDeleteDialog(contact),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => GoRouter.of(context).go('/add'),
        backgroundColor: const Color(0xFF8B4513),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Ajouter", style: TextStyle(color: Colors.white)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}