// lib/presentation/views/home/edit_contact_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/contact_model.dart';

class EditContactView extends StatefulWidget {
  final Contact contact;
  const EditContactView({super.key, required this.contact});

  @override
  State<EditContactView> createState() => _EditContactViewState();
}

class _EditContactViewState extends State<EditContactView> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.contact.name);
  late final _email = TextEditingController(text: widget.contact.email);
  late final _phone = TextEditingController(text: widget.contact.phone);
  bool _isLoading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  // VALIDATION NOM
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nom requis';
    if (value.trim().length < 2) return 'Min 2 caractères';
    final nameRegex = RegExp(r'^[a-zA-ZÀ-ÿ\s\-]+$');
    if (!nameRegex.hasMatch(value.trim())) return 'Lettres et espaces seulement';
    return null;
  }

  // VALIDATION EMAIL
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email requis';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Email invalide';
    return null;
  }

  // VALIDATION TÉLÉPHONE TUNISIEN
  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Téléphone requis';
    final clean = value.trim().replaceAll(RegExp(r'\D'), '');
    final phoneRegex = RegExp(r'^(?:\+216|216)?[2579]\d{7}$');
    if (!phoneRegex.hasMatch(clean)) return 'Format: +216 XX XXX XXX';
    return null;
  }

  Future<void> _updateContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedContact = Contact(
        id: widget.contact.id,
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('contacts')
          .doc(updatedContact.id)
          .update(updatedContact.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mis à jour !")));
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier le contact"),
        leading: IconButton(
  icon: const Icon(Icons.arrow_back),
  onPressed: () => context.go('/'), // RETOUR À L'ACCUEIL
),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _name,
                    decoration: InputDecoration(labelText: "Nom complet", prefixIcon: const Icon(Icons.person)),
                    validator: _validateName,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _email,
                    decoration: InputDecoration(labelText: "Email", prefixIcon: const Icon(Icons.email)),
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phone,
                    decoration: InputDecoration(labelText: "Téléphone", prefixIcon: const Icon(Icons.phone)),
                    keyboardType: TextInputType.phone,
                    validator: _validatePhone,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isLoading ? null : _updateContact,
                      icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)) : const Icon(Icons.save),
                      label: Text(_isLoading ? "Mise à jour..." : "Mettre à jour"),
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