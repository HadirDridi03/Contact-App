import 'package:uuid/uuid.dart';

class Contact {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? photoPath;  // nullable pour la photo

  Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photoPath,
  });

  // INDISPENSABLE pour saveContact()
  Contact copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoPath,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photoPath': photoPath,
    };
  }

  static Contact fromMap(String id, Map<String, dynamic> map) {
    return Contact(
      id: id,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      photoPath: map['photoPath'] as String?,
    );
  }
}