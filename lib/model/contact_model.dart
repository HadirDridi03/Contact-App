// lib/model/contact_model.dart
class Contact {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? photoPath;        // ← NOUVEAU : chemin local de la photo

  Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photoPath,
  });

  factory Contact.fromMap(String id, Map<String, dynamic> map) {
    return Contact(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      photoPath: map['photoPath'] as String?,   // ← lecture
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photoPath': photoPath,                 // ← sauvegarde
    };
  }
}