// lib/presentation/views/home/edit_contact_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/contact_model.dart';
import '../../controllers/contact_controller.dart';

class EditContactView extends StatefulWidget {
  final Contact contact;
  const EditContactView({super.key, required this.contact});

  @override
  State<EditContactView> createState() => _EditContactViewState();
}

class _EditContactViewState extends State<EditContactView> {
  late final _name = TextEditingController(text: widget.contact.name);
  late final _email = TextEditingController(text: widget.contact.email);
  late final _phone = TextEditingController(text: widget.contact.phone);
  final _controller = ContactController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modifier")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: "Nom"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
              decoration: const InputDecoration(labelText: "Téléphone"),
            ),
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      setState(() => _loading = true);
                      try {
                        final updatedContact = Contact(
                          id: widget.contact.id,
                          name: _name.text,
                          email: _email.text,
                          phone: _phone.text,
                        );
                        await _controller.updateContact(updatedContact);
                        if (context.mounted) context.pop();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Erreur: $e")),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _loading = false);
                      }
                    },
                    child: const Text("Mettre à jour"),
                  ),
          ],
        ),
      ),
    );
  }
}