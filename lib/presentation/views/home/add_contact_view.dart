// lib/presentation/views/home/add_contact_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/contact_model.dart';
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
final nameRegex = RegExp(r'^[a-zA-ZÀ-ÿ\s-]+$');
if (!nameRegex.hasMatch(value.trim())) return 'Lettres et espaces seulement';
return null;
}
// VALIDATION EMAIL
String? _validateEmail(String? value) {
if (value == null || value.trim().isEmpty) return 'Email requis';
final emailRegex = RegExp(r'^[\w-.]+@([\w-]+.)+[\w-]{2,4}$');
if (!emailRegex.hasMatch(value.trim())) return 'Email invalide';
return null;
}
// VALIDATION TÉLÉPHONE TUNISIEN
String? _validatePhone(String? value) {
if (value == null || value.trim().isEmpty) return 'Téléphone requis';
final clean = value.trim().replaceAll(RegExp(r'\D'), '');
final phoneRegex = RegExp(r'^(?:+216|216)?[2579]\d{7}$');
if (!phoneRegex.hasMatch(clean)) return 'Format: +216 XX XXX XXX';
return null;
}
Future<void> _addContact() async {
if (!_formKey.currentState!.validate()) return;
setState(() => _isLoading = true);
try {
final id = const Uuid().v4();
final contact = Contact(id: id, name: _name.text.trim(), email: _email.text.trim(), phone: _phone.text.trim());
await FirebaseFirestore.instance
.collection('users')
.doc(FirebaseAuth.instance.currentUser!.uid)
.collection('contacts')
.doc(id)
.set(contact.toMap());
if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ajouté !")));
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
title: const Text("Nouveau contact"),
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
TextFormField(controller: _name, decoration: const InputDecoration(labelText: "Nom"), validator: _validateName),
const SizedBox(height: 16),
TextFormField(controller: _email, decoration: const InputDecoration(labelText: "Email"), validator: _validateEmail),
const SizedBox(height: 16),
TextFormField(controller: _phone, decoration: const InputDecoration(labelText: "Téléphone"), validator: _validatePhone),
const SizedBox(height: 32),
SizedBox(
width: double.infinity,
child: FilledButton.icon(
onPressed: _isLoading ? null : _addContact,
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