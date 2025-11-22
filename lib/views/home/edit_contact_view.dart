import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../model/contact_model.dart';
import '../../service/database/app_database.dart';

class EditContactView extends StatefulWidget {
  final Contact contact;
  const EditContactView({Key? key, required this.contact}) : super(key: key);

  @override
  State<EditContactView> createState() => _EditContactViewState();
}

class _EditContactViewState extends State<EditContactView> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String? _photoPath;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact.name);
    _emailController = TextEditingController(text: widget.contact.email);
    _phoneController = TextEditingController(text: widget.contact.phone);
    _photoPath = widget.contact.photoPath;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _photoPath = pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modifier le contact"),
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
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: "Nom"), validator: (v) => v!.isEmpty ? "Requis" : null),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: "Email"), validator: (v) => v!.isEmpty ? "Requis" : null),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Téléphone"),
                validator: (v) {
                  if (v!.isEmpty) return "Requis";
                  final regex = RegExp(r'^(?:\+216|216)?[2579]\d{7}$');
                  return regex.hasMatch(v) ? null : "Numéro invalide";
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _isLoading = true);
                    try {
                      final userId = await AppDatabase.instance.getLoggedInUserId();

                      final updatedContact = Contact(
                        id: widget.contact.id,
                        name: _nameController.text.trim(),
                        email: _emailController.text.trim(),
                        phone: _phoneController.text.trim(),
                        photoPath: _photoPath ?? widget.contact.photoPath,
                      );

                      await AppDatabase.instance.saveContact(updatedContact, userId!);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Contact modifié !")),
                        );
                        context.go('/');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  }
                },
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Mettre à jour"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}