// lib/views/home/edit_contact_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';     // ← AJOUTÉ
import 'package:uuid/uuid.dart';

import '../../controller/contact_controller.dart';
import '../../model/contact_model.dart';

class EditContactView extends StatefulWidget {
  final Contact contact;
  const EditContactView({super.key, required this.contact});

  @override
  State<EditContactView> createState() => _EditContactViewState();
}

class _EditContactViewState extends State<EditContactView> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.contact.name);
  late final _emailController = TextEditingController(text: widget.contact.email);
  late final _phoneController = TextEditingController(text: widget.contact.phone);

  final contactController = ContactController();

  String? _photoPath;           // nouvelle photo choisie
  bool _isLoading = false;

  // Sélectionner une photo depuis la galerie
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,   // ← C’était ça le bug !
      imageQuality: 85,
    );

    if (pickedFile != null && mounted) {
      setState(() {
        _photoPath = pickedFile.path;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Validation (même que dans add_contact_view)
  String? _validateName(String? v) =>
      v == null || v.trim().trim().isEmpty ? 'Nom requis' : v.trim().length < 2 ? 'Min 2 caractères' : null;

  String? _validateEmail(String? v) =>
      v == null || v.trim().isEmpty ? 'Email requis' : RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim()) ? null : 'Email invalide';

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Téléphone requis';
    final clean = v.replaceAll(RegExp(r'\D'), '');
    return RegExp(r'^(?:\+216|216)?[2579]\d{7}$').hasMatch(clean) ? null : 'Format: +216 XX XXX XXX';
  }

  // Sauvegarde avec photo
  Future<void> _updateContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedContact = Contact(
        id: widget.contact.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        photoPath: _photoPath ?? widget.contact.photoPath, // garde l’ancienne si pas changée
      );

      await contactController.saveContact(updatedContact);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contact modifié !"), backgroundColor: Colors.green),
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
      appBar: AppBar(title: const Text("Modifier le contact")),
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
                      backgroundImage: _photoPath != null
                          ? FileImage(File(_photoPath!))
                          : widget.contact.photoPath != null
                              ? FileImage(File(widget.contact.photoPath!))
                              : null,
                      child: _photoPath == null && widget.contact.photoPath == null
                          ? const Icon(Icons.camera_alt, size: 60, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _photoPath == null && widget.contact.photoPath == null
                        ? "Appuyez pour ajouter une photo"
                        : "Photo sélectionnée",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 30),

                  // CHAMPS
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Nom", prefixIcon: Icon(Icons.person)),
                    validator: _validateName,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: "Téléphone", prefixIcon: Icon(Icons.phone)),
                    validator: _validatePhone,
                  ),
                  const SizedBox(height: 40),

                  // BOUTON
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isLoading ? null : _updateContact,
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF8B4513)),
                      icon: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                          : const Icon(Icons.save),
                      label: Text(_isLoading ? "Mise à jour..." : "Enregistrer les modifications"),
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