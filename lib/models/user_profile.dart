import 'package:flutter/material.dart';

class UserProfile {
  final String lastName;
  final String firstName;
  final String email;
  final String phone;
  final String? photoPath;

  const UserProfile({
    required this.lastName,
    required this.firstName,
    required this.email,
    required this.phone,
    this.photoPath,
  });

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return (f + l).toUpperCase();
  }

  UserProfile copyWith({
    String? lastName,
    String? firstName,
    String? email,
    String? phone,
    String? photoPath,
  }) {
    return UserProfile(
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}

/// Utilisateur connecté (en mémoire pour l'instant, remplacé par l'API plus tard)
final ValueNotifier<UserProfile> currentUser = ValueNotifier(
  const UserProfile(
    lastName: 'WEKESSI',
    firstName: 'Philippe',
    email: 'philippe@mail.com',
    phone: '+229 00000000',
  ),
);