// lib/data/models/contact_model.dart
class Contact {
  final String id;
  final String name;
  final String email;
  final String phone;

  Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email, 'phone': phone};
  }

  factory Contact.fromMap(String id, Map<String, dynamic> map) {
    return Contact(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
    );
  }

  Contact copyWith({String? name, String? email, String? phone}) {
    return Contact(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}