import 'package:uuid/uuid.dart';

class Contact {
  final String id;
  final int userId;           
  final String name;
  final String email;
  final String phone;
  final String? photoPath;

  Contact({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    this.photoPath,
  });

  Contact copyWith({
    String? id,
    int? userId,
    String? name,
    String? email,
    String? phone,
    String? photoPath,
  }) {
    return Contact(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,       
      'name': name,
      'email': email,
      'phone': phone,
      'photoPath': photoPath,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as String,
      userId: map['userId'] as int,           
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      photoPath: map['photoPath'] as String?,
    );
  }


  factory Contact.createNew({
    required int userId,
    required String name,
    required String email,
    required String phone,
    String? photoPath,
  }) {
    return Contact(
      id: const Uuid().v4(),
      userId: userId,
      name: name,
      email: email,
      phone: phone,
      photoPath: photoPath,
    );
  }
}