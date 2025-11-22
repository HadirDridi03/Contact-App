import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../model/contact_model.dart';
import '../../service/database/app_database.dart';  

class AddContactView extends StatefulWidget {
  const AddContactView({Key? key}) : super(key: key);

  @override
  State<AddContactView> createState() => _AddContactViewState();
}

class _AddContactViewState extends State<AddContactView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _photoPath;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _photoPath = pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nouveau contact"),
        leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => context.go('/'), // Retour à la page d'accueil
  ),
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
             GestureDetector(
  onTap: _pickImage,
 child: ClipOval( // Rétablissement de ClipOval
    child: SizedBox(
      width: 120,
      height: 120,
      child: _photoPath != null
          ? Image.file(
              File(_photoPath!),
              fit: BoxFit.cover, // Conserve BoxFit.cover pour un remplissage sans étirement
            )

          : Container(
              color: const Color(0xFFFFF3E0), // Fond beige clair comme ton design
              child: Center(
                child: Text(
                  _nameController.text.trim().isEmpty
                      ? "+"
                      : _nameController.text.trim()[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              ),
            ),
    ),
  ),
),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nom complet"),
                validator: (v) => v!.isEmpty ? "Nom obligatoire" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty ? "Email obligatoire" : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Téléphone (+216)"),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v!.isEmpty) return "Téléphone obligatoire";
                  final regex = RegExp(r'^(?:\+216|216)?[0-9]{8}$');
                  return regex.hasMatch(v) ? null : "Numéro tunisien invalide";
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _isLoading = true);
                    try {
                      final userId = await AppDatabase.instance.getLoggedInUserId();
                      if (userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Erreur : utilisateur non connecté")),
                        );
                        return;
                      }

                      final contact = Contact(
                        id: '', // vide = nouveau contact → saveContact génère l'UUID
                        name: _nameController.text.trim(),
                        email: _emailController.text.trim(),
                        phone: _phoneController.text.trim(),
                        photoPath: _photoPath,
                      );

                      await AppDatabase.instance.saveContact(contact, userId);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Contact ajouté avec succès !")),
                        );
                        context.go('/');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Erreur : $e")),
                      );
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  }
                },
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Enregistrer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}