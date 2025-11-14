// lib/presentation/views/widgets/contact_tile.dart
import 'package:flutter/material.dart';
import '../../../data/models/contact_model.dart';

class ContactTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ContactTile({
    super.key,
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(contact.name[0].toUpperCase())),
      title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("${contact.email}\n${contact.phone}", style: const TextStyle(fontSize: 12)),
      isThreeLine: true,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: onEdit),
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onDelete),
        ],
      ),
    );
  }
}