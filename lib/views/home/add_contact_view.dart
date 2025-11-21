// lib/views/home/add_contact_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../controller/contact_controller.dart';
import '../../model/contact_model.dart';

class AddContactView extends StatefulWidget {
  const AddContactView({super.key});

  @override
  State<AddContactView> createState() => _AddContactViewState();
}

class _AddContactViewState extends State<AddContactView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final contactController = ContactController();

  String? _photoPath;
  bool _isLoading = false;

  // Sélectionner une photo
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null && mounted) {
      setState(() => _photoPath = picked.path);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  // Validation (inchangée)
  String? _validateName(String? v) => v == null || v.trim().isEmpty ? 'Nom requis' : v.trim().length < 2 ? 'Min 2 caractères' : null;
  String? _validateEmail(String? v) => v == null || v.trim().isEmpty ? 'Email requis' : RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim()) ? null : 'Email invalide';
  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Téléphone requis';
    final clean = v.replaceAll(RegExp(r'\D'), '');
    return RegExp(r'^(?:\+216|216)?[2579]\d{7}$').hasMatch(clean) ? null : 'Format: +216 XX XXX XXX';
  }

  // SAUVEGARDE → utilise updateContact() qui existe déjà !
  Future<void> _saveContact() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    final newContact = Contact(
      id: const Uuid().v4(),
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      photoPath: _photoPath,
    );

    await contactController.saveContact(newContact);  // ← LIGNE MAGIQUE

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Contact ajouté !"), backgroundColor: Colors.green),
    );

    GoRouter.of(context).go('/');
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur : $e")));
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nouveau contact")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // PHOTO
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _photoPath != null ? FileImage(File(_photoPath!)) : null,
                      child: _photoPath == null
                          ? const Icon(Icons.add_a_photo, size: 60, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _photoPath == null ? "Appuyez pour ajouter une photo" : "Photo sélectionnée",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 30),

                  // CHAMPS
                  TextFormField(controller: _name, decoration: const InputDecoration(labelText: "Nom", prefixIcon: Icon(Icons.person)), validator: _validateName),
                  const SizedBox(height: 16),
                  TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)), validator: _validateEmail),
                  const SizedBox(height: 16),
                  TextFormField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "Téléphone", prefixIcon: Icon(Icons.phone)), validator: _validatePhone),
                  const SizedBox(height: 40),

                  // BOUTON
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isLoading ? null : _saveContact,
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF8B4513)),
                      icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)) : const Icon(Icons.save),
                      label: Text(_isLoading ? "Enregistrement..." : "Enregistrer"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}