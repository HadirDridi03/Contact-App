import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

import '../../model/contact_model.dart';
import '../../service/database/app_database.dart';
import '../../service/auth_service.dart';

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
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _photoPath = picked.path);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nouveau contact"),
        leading: BackButton(onPressed: () => context.go('/')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: ClipOval(
                  child: SizedBox(
                    width: 120, height: 120,
                    child: _photoPath != null
                        ? Image.file(File(_photoPath!), fit: BoxFit.cover)
                        : Container(
                            color: const Color(0xFFFFF3E0),
                            child: Center(
                              child: Text(
                                _nameController.text.isEmpty
                                    ? "+" 
                                    : _nameController.text[0].toUpperCase(),
                                style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.brown),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: "Nom complet"), validator: (v) => v?.trim().isEmpty ?? true ? "Nom obligatoire" : null),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: "Email"), keyboardType: TextInputType.emailAddress, validator: (v) => v?.trim().isEmpty ?? true ? "Email obligatoire" : null),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Téléphone (+216)"),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Téléphone obligatoire";
                  final cleaned = v.replaceAll(RegExp(r'\D'), '');
                  return RegExp(r'^216?[2579]\d{7}$').hasMatch(cleaned) ? null : "Numéro invalide";
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _isLoading = true);

                  try {
                    final userId = await LocalAuthService.instance.getRequiredUserId();

                   final contact = Contact.createNew(
  userId: await LocalAuthService.instance.getRequiredUserId(),
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
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Session expirée – veuillez vous reconnecter")),
                      );
                      context.go('/login');
                    }
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
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